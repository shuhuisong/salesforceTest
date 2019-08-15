/**--------------------------------------------------------------------------
 * プログラム名 ：Marketoからリード導入の後処理トリガー
 * 作成日        ：2017/10/23
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/10/23:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */
 
trigger MarketoToLeadAfter on Lead(after insert) {
    
    LeadTriggerHandler handler = new LeadTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if (Trigger.isInsert && Trigger.isAfter) {
        System.debug(LoggingLevel.DEBUG, '#####00__：\n①__:'+''+  '\n②__:'+''+  '\n③__:'+''+  '\n④__:'+''+  '\n⑤__:'+ ''+ '\n⑥__:'+'' );
        handler.onAfterInsert(Trigger.new, Trigger.newMap);
    }
    
}