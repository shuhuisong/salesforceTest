// Sansanタグ情報取得バッチ
public with sharing class SansanTagRetrieveBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    private static String BATCH_NAME = 'SansanTagRetrieveBatch';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // バッチ状態
    private String nextPageToken { get; set; }
    private List<SansanTag> tags { get; set; }
    private Integer counter { get; set; }
    private Integer tagIndex { get; set; }

    // 設定情報
    private Map<String, String> settings { get; set; }

    // Sansanタグ情報
    private class SansanTag {
        public String id { get; set; }
        public String name { get; set; }
    }

    // コンストラクタ
    public SansanTagRetrieveBatch(List<SansanTag> tags, Integer tagIndex, String nextPageToken, Integer counter) {
        System.debug(tags);
        System.debug(tagIndex);
        System.debug(nextPageToken);
        System.debug(counter);

        this.tags = tags;
        this.tagIndex = tagIndex;
        this.nextPageToken = nextPageToken;
        this.counter = counter;

        this.hasError = false;
        this.settings = SansanBatchUtility.getSettings();
    }

    // バッチ初期処理。APIでタグ取得->名刺情報取得後、メイン処理に名刺情報を渡す。
    public Iterable<String> start(Database.BatchableContext BC) {
        List<String> nameCardIds = new List<String>();

        try {
            // 名刺タグ情報取得
            procGetSansanTagApi();
            // 名刺情報取得
            nameCardIds = procGetNameCardApi();

            System.debug(nameCardIds.size());
            System.debug(nameCardIds);
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }

        return nameCardIds;
    }

    // バッチメイン処理。名刺にタグ情報の付与を行う
    public void execute(Database.BatchableContext info, List<String> nameCardIds) {
        if (nameCardIds == null || nameCardIds.isEmpty()) {
            return;
        }

        try {
            List<SansanNameCard__c> sansanNameCardsToUpdate = new List<SansanNameCard__c>();

            List<SansanNameCard__c> sansanNameCards = [select TagNames__c from SansanNameCard__c where NameCardId__c in :nameCardIds];

            for (SansanNameCard__c sansanNameCard : sansanNameCards) {
                Set<String> tagNames = new Set<String>();
                if (String.isNotBlank(sansanNameCard.TagNames__c)) {
                    tagNames.addAll(sansanNameCard.TagNames__c.split(';'));
                }

                tagNames.add(this.tags.get(this.tagIndex).name);
                List<String> newTags = new List<String>(tagNames);
                newTags.sort();
                sansanNameCard.TagNames__c = String.join(newTags, ';');

                sansanNameCardsToUpdate.add(sansanNameCard);
            }

            if (sansanNameCardsToUpdate.size() > 0) {
                update sansanNameCardsToUpdate;
            }
        } catch(Exception e) {
            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理。名刺が全て取得できていなければ、トークンを渡して自バッチを呼び出し。タグが全て取得できていなければ、インデックスを更新して自バッチを呼び出し
    public void finish(Database.BatchableContext info) {
        try {
            Integer sansanTagRetrieveBatchSize = Integer.valueOf(this.settings.get('sansanTagRetrieveBatchSize'));
            Integer sansanTagBindAccountBatchSize = Integer.valueOf(this.settings.get('sansanTagBindAccountBatchSize'));
            Integer sansanTagRetrieveBatchMaxCount = Integer.valueOf(settings.get('sansanTagRetrieveBatchMaxCount'));
            Integer sleepTime = Integer.valueOf(this.settings.get('sleepTime'));

            System.debug(this.tags);
            System.debug(this.tagIndex);
            System.debug(this.nextPageToken);
            System.debug(this.counter);

            this.counter += 1;

            Boolean isCountOver = this.counter >= sansanTagRetrieveBatchMaxCount;
            Boolean hasToken = String.isNotBlank(this.nextPageToken);
            Boolean hasNextTag = this.tags.size() > this.tagIndex + 1;
            
            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                if (isCountOver && (hasToken || hasNextTag)) {
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: リミットオーバーのため後続バッチ中止');
                } else if (hasToken) {
                    SansanTagRetrieveBatch batch = new SansanTagRetrieveBatch(this.tags, this.tagIndex, this.nextPageToken, this.counter);

                    // 2秒スリープ
                    SansanBatchUtility.sleep(sleepTime);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり(次名刺トークン)');
                    Database.executeBatch(batch, sansanTagRetrieveBatchSize);
                } else if (hasNextTag) {
                    this.tagIndex += 1;
                    SansanTagRetrieveBatch batch = new SansanTagRetrieveBatch(this.tags, this.tagIndex, this.nextPageToken, this.counter);
        
                    // 2秒スリープ
                    SansanBatchUtility.sleep(sleepTime);
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり(次名刺タグ)');
                    Database.executeBatch(batch, sansanTagRetrieveBatchSize);
                } else {
                    SansanTagBindAccountBatch batch = new SansanTagBindAccountBatch();
                    SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり');
                    Database.executeBatch(batch, sansanTagBindAccountBatchSize);
                }
            }
        } catch (Exception e) {
            System.debug(e);

            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了: ' + SansanBatchUtility.getExceptionString(e));
        }
    }

    // 名刺タグ情報取得処理
    private void procGetSansanTagApi() {
        if (this.tags == null) {
            Map<String, String> params = new Map<String, String>();

            params.put('range', 'all');
            params.put('type', 'shared');
            params.put('number', this.settings.get('sansanTagApiLimit'));

            String apiResult = SansanBatchUtility.getRequest('/tags', params, BATCH_NAME, this.settings);

            if (apiResult == null) {
                this.hasError = true;
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '名刺タグ情報取得APIエラー');
                return;
            }

            Map<String, Object> jsonResults = (Map<String, Object>) JSON.deserializeUntyped(apiResult);
            List<Object> datas = (List<Object>) jsonResults.get('data');

            this.tags = new List<SansanTag>();
            for (Object data : datas) {
                Map<String, Object> dataMap = (Map<String, Object>) data;

                SansanTag sansanTag = new SansanTag();
            
                sansanTag.id = (String) dataMap.get('id');
                sansanTag.name = (String) dataMap.get('name');

                this.tags.add(sansanTag);
            }
            this.tagIndex = 0;
            this.counter = 0;
            this.nextPageToken = null;
        }
    }

    // 名刺情報取得処理
    private List<String> procGetNameCardApi() {
        System.debug(this.tags);
        System.debug(this.tagIndex);
        Map<String, String> params = new Map<String, String>();
        List<String> result = new List<String>();

        params.put('range', 'all');
        params.put('tagId', this.tags.get(this.tagIndex).id);
        params.put('limit', this.settings.get('sansanNameCardApiLimit'));

        if (String.isNotBlank(this.nextPageToken)) {
            params.put('nextPageToken', this.nextPageToken);
        }

        String apiResult = SansanBatchUtility.getRequest('/bizCards/search', params, BATCH_NAME, this.settings);

        System.debug('test');

        if (apiResult == null) {
            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, '名刺情報取得APIエラー');
            return result;
        }

        Map<String, Object> jsonResults = (Map<String, Object>) JSON.deserializeUntyped(apiResult);
        this.nextPageToken = (String) jsonResults.get('nextPageToken');
        List<Object> datas = (List<Object>) jsonResults.get('data');

        for (Object data : datas) {
            Map<String, Object> dataMap = (Map<String, Object>) data;
            // 名刺ID
            result.add((String) dataMap.get('id'));
        }

        return result;
    }
}