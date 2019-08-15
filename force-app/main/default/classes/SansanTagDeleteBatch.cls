// Sansanタグ削除バッチ
public with sharing class SansanTagDeleteBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static String BATCH_NAME = 'SansanTagDeleteBatch';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // 設定情報
    private Map<String, String> settings { get; set; }

    // コンストラクタ
    public SansanTagDeleteBatch() {
        this.hasError = false;
        this.settings = SansanBatchUtility.getSettings();
    }

    // バッチ初期処理
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id, TagNames__c from SansanNameCard__c where TagNames__c != null');
    }

    // バッチメイン処理。全名刺のタグ情報をクリア
    public void execute(Database.BatchableContext BC, List<SansanNameCard__c> scope) {
        try {
            for (SansanNameCard__c sansanNameCard : scope) {
                sansanNameCard.TagNames__c = null;
            }

            // 一部だけ更新する意味はないので、updateに失敗したらバッチ停止
            update scope;
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理。エラーがなければ名刺タグ取得バッチを呼び出し
    public void finish(Database.BatchableContext BC) {
        try {
            Integer sansanTagRetrieveBatchSize = Integer.valueOf(this.settings.get('sansanTagRetrieveBatchSize'));

            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了: 後続バッチあり');
                SansanTagRetrieveBatch batch = new SansanTagRetrieveBatch(null, null, null, null);
                Database.executeBatch(batch, sansanTagRetrieveBatchSize);
            }
        } catch (Exception e) {
            System.debug(e);

            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了: ' + SansanBatchUtility.getExceptionString(e));
        }
    }
}