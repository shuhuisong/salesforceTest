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

trigger RecordTypeUpdateAccount on Account(after update) {
  
        RecordTypeUpdateHandler handler = new RecordTypeUpdateHandler(Trigger.isExecuting, Trigger.size);
        System.debug(LoggingLevel.DEBUG, '#R00__：\n①__:' + Trigger.new + '\n②__:' + Trigger.old + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        if (Trigger.isUpdate && Trigger.isAfter) {
            System.debug(LoggingLevel.DEBUG, '#R09__：\n①__:' + Trigger.new + '\n②__:' + Trigger.old + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
            handler.doUpdateRecordTypeAccount(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
       if (StaticclassForFlag.firstRun) {   StaticclassForFlag.firstRun = false;
    }
}