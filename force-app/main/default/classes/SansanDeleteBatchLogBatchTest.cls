// Sansanバッチログ削除バッチテスト
@isTest
private class SansanDeleteBatchLogBatchTest {
    // CRON スケジュール
    private static String CRON_EXP = '0 0 0 1 1 ? 2099';

    // 正常系
    static testMethod void unitTest1() {
        BatchLog__c batchLog1 = new BatchLog__c(Message__c = '消える');
        insert batchLog1;
        Test.setCreatedDate(batchLog1.Id, DateTime.now() - 31);

        BatchLog__c batchLog2 = new BatchLog__c(Message__c = '消えない');
        insert batchLog2;
        Test.setCreatedDate(batchLog2.Id, DateTime.now() - 29);

        // テスト
        Test.startTest();

        SansanDeleteBatchLogBatch batch = new SansanDeleteBatchLogBatch();
        Database.executeBatch(batch);

        Test.stopTest();

        List<BatchLog__c> batchLogs = [select Id, BatchName__c, Message__c from BatchLog__c order by CreatedDate];
        // バッチ自身が作成したログと残ったログで2件となる
        System.assertEquals(2, batchLogs.size());
        System.assertEquals('消えない', batchLogs[0].Message__c);
        System.assertEquals('SansanDeleteBatchLogBatch', batchLogs[1].BatchName__c);
    }

    // 異常系
    static testMethod void unitTest2() {
        BatchLog__c batchLog1 = new BatchLog__c(Message__c = '消える');
        insert batchLog1;
        Test.setCreatedDate(batchLog1.Id, DateTime.now() - 31);

        // テスト
        Test.startTest();

        SansanDeleteBatchLogBatch batch = new SansanDeleteBatchLogBatch();
        batch.execute(null, null);

        Test.stopTest();
    }

    // スケジューラのテスト
    static testMethod void unitTestScheduler() {
        // テスト
        Test.startTest();

        SansanDeleteBatchLogBatchScheduler scheduler = new SansanDeleteBatchLogBatchScheduler();
        String jobID = System.schedule('testScheduleSansanDeleteBatchLogBatch', CRON_EXP, scheduler);

        Test.stopTest();
    }
}