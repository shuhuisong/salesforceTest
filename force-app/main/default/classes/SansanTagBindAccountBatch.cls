// Sansanタグ取引先連携バッチ
public with sharing class SansanTagBindAccountBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static String BATCH_NAME = 'SansanTagBindAccountBatch';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // 設定情報
    private Map<String, String> settings { get; set; }

    // コンストラクタ
    public SansanTagBindAccountBatch() {
        this.hasError = false;
        this.settings = SansanBatchUtility.getSettings();
    }

    // バッチ初期処理
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id, Name, TagNames__c from Account where RecordType.IsPersonType = false');
    }

    // バッチメイン処理。取引先にタグ情報の付与を行う
    public void execute(Database.BatchableContext BC, List<Account> scope) {
        try {
            Set<String> names = new Set<String>();

            for (Account account : scope) {
                names.add(account.Name);
            }

            // マージ処理の都合上関連が取れるとは限らないため、必ずキー項目で調べ直す
            List<SansanNameCard__c> sansanNameCards =
                [select Id, CompanyName__c, TagNames__c from SansanNameCard__c where CompanyName__c in :names];

            Map<String, Set<String>> companyNameTagsMap = new Map<String, Set<String>>(); 

            for (SansanNameCard__c sansanNameCard : sansanNameCards) {
                Set<String> target = companyNameTagsMap.get(sansanNameCard.CompanyName__c);
                if (target == null) {
                    target = new Set<String>();
                    companyNameTagsMap.put(sansanNameCard.CompanyName__c, target);
                }

                if (String.isNotBlank(sansanNameCard.TagNames__c)) {
                    target.addAll(sansanNameCard.TagNames__c.split(';'));
                }
            }

            List<Account> accountsToUpdate = new List<Account>();
            
            for (Account account : scope) {
                Set<String> oldTagNames = new Set<String>();
                if (String.isNotBlank(account.TagNames__c)) {
                    oldTagNames.addAll(account.TagNames__c.split(';'));
                }

                if (companyNameTagsMap.get(account.Name) != null && companyNameTagsMap.get(account.Name) != oldTagNames) {
                    // 変更がある場合のみ更新
                    List<String> newTags = new List<String>(companyNameTagsMap.get(account.Name));
                    newTags.sort();
                    String newTagNames = String.join(newTags, ';');

                    account.TagNames__c = newTagNames;
                    accountsToUpdate.add(account);
                }
            }

            update accountsToUpdate;
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理。正常終了ならSansanタグ取引先責任者連携バッチを呼び出し
    public void finish(Database.BatchableContext BC) {
        try {
            Integer sansanTagBindContactBatchSize = Integer.valueOf(this.settings.get('sansanTagBindContactBatchSize'));

            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり');
                SansanTagBindContactBatch batch = new SansanTagBindContactBatch();
                Database.executeBatch(batch, sansanTagBindContactBatchSize);
            }
        } catch (Exception e) {
            System.debug(e);

            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了: ' + SansanBatchUtility.getExceptionString(e));
        }
    }
}