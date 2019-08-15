/**--------------------------------------------------------------------------
 * プログラム名 ：取引先責任者のマージ処理トリガー
 * 作成日        ：2017/11/07
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/11/07:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */
trigger ContactMerge on Contact(after insert, after undelete, after update) {
    System.debug(LoggingLevel.ERROR, '#####00__：\n①__:' + ContactMergeHandler.isTriggerCalled + '\n②__:' + ContactMergeHandler.isLeadConverting + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88);
    if (ContactMergeHandler.isTriggerCalled || ContactMergeHandler.isLeadConverting) {
        System.debug(LoggingLevel.ERROR, '#####01__：exit ContactMerge for recursive call.');
        return;
    }

    ContactMergeHandler handler = new ContactMergeHandler(Trigger.isExecuting, Trigger.size);
    if ((Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) && Trigger.isAfter) {
        System.debug(LoggingLevel.DEBUG, '#####11__：\n①__:' + 88 + '\n②__:' + 88 + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88);
        ContactMergeHandler.isTriggerCalled = true;
        handler.doMerge(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        ContactMergeHandler.isTriggerCalled = false;
    }
}