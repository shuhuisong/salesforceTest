/*----------------------------------------------------------------------------
 * プログラム名：Marketoからリード導入の前処理
 * 作成日：2017/11/02
 * 作成者：SunBridge
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 *----------------------------------------------------------------------------
 */  
trigger MarketoToLeadBefore on Lead (before insert) {
    
    LeadTriggerHandler handler = new LeadTriggerHandler(Trigger.isExecuting, Trigger.size);
    if (Trigger.isInsert && Trigger.isBefore) {
        System.debug(LoggingLevel.DEBUG, '#L01__：\n①__:'+''+  '\n②__:'+''+  '\n③__:'+''+  '\n④__:'+''+  '\n⑤__:'+ ''+ '\n⑥__:'+'' );
        handler.onBeforeInsert(Trigger.new, Trigger.newMap);
    }
}