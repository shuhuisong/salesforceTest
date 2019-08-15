// Sansan名刺差分情報取り込みバッチスケジューラ
global without sharing class SansanNameCardBaseBatchScheduler implements Schedulable {
    // バッチ起動
    global void execute(SchedulableContext context) {
        Map<String, String> settings = SansanBatchUtility.getSettings();
        // Exceptionが発生する可能性があるが考慮しない(問題が明らかであるため)
        Integer sansanNameCardBaseBatchSize = Integer.valueOf(settings.get('sansanNameCardBaseBatchSize'));

        SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(0, null, null);
        Database.executeBatch(batch, sansanNameCardBaseBatchSize);
    }
}