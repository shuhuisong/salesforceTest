// Sansan名刺タグ削除バッチスケジューラ
global without sharing class SansanTagDeleteBatchScheduler implements Schedulable {
    // バッチ起動
    global void execute(SchedulableContext context) {
        Map<String, String> settings = SansanBatchUtility.getSettings();
        // Exceptionが発生する可能性があるが考慮しない(問題が明らかであるため)
        Integer sansanTagDeleteBatchSize = Integer.valueOf(settings.get('sansanTagDeleteBatchSize'));

        SansanTagDeleteBatch batch = new SansanTagDeleteBatch();
        Database.executeBatch(batch, sansanTagDeleteBatchSize);
    }
}