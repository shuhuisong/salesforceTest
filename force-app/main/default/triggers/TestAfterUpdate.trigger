/*----------------------------------------------------------------------------
 * プログラム名：二回目更新起動が大丈夫か？
 * 作成日：2017/11/13
 * 作成者：SunBridge
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 *----------------------------------------------------------------------------
 */
trigger TestAfterUpdate on Contact(after undelete, after insert, after update) {

    System.debug(LoggingLevel.DEBUG, System.now() + '#####86__：\n①__:' + Trigger.new + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');

    //新しい取引先責任者のId整理
    List < Id > idList = new List < Id > ();
    for (Contact tpContact: Trigger.new) {
        //名前が空白の場合処理対処 
        if (String.isBlank(tpContact.FirstName)) {
            idList.add(tpContact.id);
        }
    }
    List < Contact > newContactList = [SELECT Id, Name, Email FROM Contact WHERE ID =: idList];

    System.debug(LoggingLevel.DEBUG, System.now() + '#####87__：\n①__:' +newContactList + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
    for (Contact tpContact: newContactList) {
        tpContact.FirstName = 'Toyokeizai_accenture';
    }
    //更新処理
    update newContactList;
    
    System.debug(LoggingLevel.DEBUG, System.now() + '#####88__：\n①__:' + '' + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');

}