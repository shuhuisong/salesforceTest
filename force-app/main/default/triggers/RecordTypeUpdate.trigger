/**--------------------------------------------------------------------------
 * プログラム名 ：レコードタイプ更新
 * 作成日        ：2017/11/16
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/11/16:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */
trigger RecordTypeUpdate on Contact(before update,before insert) {
    system.debug('$RecordTypeUpdate firing!');
    System.debug(LoggingLevel.DEBUG, '#####08__：\n①__:' + Trigger.new + '\n②__:' + Trigger.old + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
    if ((Trigger.isInsert||Trigger.isUpdate) && Trigger.isBefore) {
        RecordTypeUpdateHandler handler = new RecordTypeUpdateHandler(Trigger.isExecuting, Trigger.size);
        System.debug(LoggingLevel.DEBUG, '#####09__：\n①__:' + Trigger.new + '\n②__:' + Trigger.old + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        handler.doUpdateRecordType(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}