// Sansanバッチログ削除バッチスケジューラ
global without sharing class SansanDeleteBatchLogBatchScheduler implements Schedulable {
    // バッチ起動
    global void execute(SchedulableContext context) {
        Map<String, String> settings = SansanBatchUtility.getSettings();
        // Exceptionが発生する可能性があるが考慮しない(問題が明らかであるため)
        Integer SansanDeleteBatchLogBatchSize = Integer.valueOf(settings.get('sansanDeleteBatchLogBatchSize'));

        SansanDeleteBatchLogBatch batch = new SansanDeleteBatchLogBatch();
        Database.executeBatch(batch, SansanDeleteBatchLogBatchSize);
    }
}