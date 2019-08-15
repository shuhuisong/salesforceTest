// Sansanバッチログ削除バッチ
public with sharing class SansanDeleteBatchLogBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static String BATCH_NAME = 'SansanDeleteBatchLogBatch';

    // エラーフラグ
    private Boolean hasError { get; set; }

    // コンストラクタ
    public SansanDeleteBatchLogBatch() {
        this.hasError = false;
    }

    // バッチ初期処理
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id from BatchLog__c where CreatedDate < LAST_N_DAYS:30');
    }

    // バッチメイン処理。1月前以上のログを削除
    public void execute(Database.BatchableContext BC, List<BatchLog__c> scope) {
        try {
            // 一部だけ削除する意味はないので、deleteに失敗したらバッチ停止
            delete scope;
        } catch (Exception e) {
            System.debug(e);

            this.hasError = true;
            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, SansanBatchUtility.getExceptionString(e));
        }
    }

    // バッチ終了処理
    public void finish(Database.BatchableContext BC) {
        try {
            if (this.hasError) {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了');
            } else {
                SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, BATCH_NAME, 'バッチ正常終了');
            }
        } catch (Exception e) {
            System.debug(e);

            SansanBatchUtility.createLog(SansanBatchUtility.LOG_ERROR, BATCH_NAME, 'バッチ異常終了: ' + SansanBatchUtility.getExceptionString(e));
        }
    }
}