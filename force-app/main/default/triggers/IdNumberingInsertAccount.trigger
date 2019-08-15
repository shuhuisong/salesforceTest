trigger IdNumberingInsertAccount on Account (after insert) {
CommonIdInsertHandler handler = new CommonIdInsertHandler(Trigger.isExecuting, Trigger.size);

if(Trigger.isInsert && Trigger.isAfter){

      //採番処理を呼出す
     handler.onAfterInsert(Trigger.new);

  }
}