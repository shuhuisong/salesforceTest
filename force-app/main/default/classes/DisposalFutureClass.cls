public class DisposalFutureClass {
 
    @future
    public static void processRecords(set < String > recordIds) { 
        System.debug(LoggingLevel.DEBUG, '#####911__：\n①__:' + +recordIds + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
 
        ContactMergeHandler handler = new ContactMergeHandler(true, 1);
        List < Contact > contactUpList = Database.query('SELECT Id,Email,ToyokeizaiId__c FROM Contact WHERE Id =: recordIds ORDER BY LastModifiedDate ASC');
        System.debug(LoggingLevel.DEBUG, '#####912__：\n①__:' + +contactUpList + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');

        List < Contact > contactUpList1 = null;
        if (contactUpList != null) contactUpList1 = contactUpList.clone();
        handler.doMerge(contactUpList1, null, null, null);
    }

    //個人取引先クリア処理
    @future
    public static void clearPersonAccount(set < Id > recordIds) {
        System.debug(LoggingLevel.DEBUG, '#####811__：\n①__:' + +recordIds + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');

        Map < String, Schema.SObjectField > accountFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        //特殊項目
        List < String > columnlList = new List < String > ();
        columnlList.add('firstname');
        columnlList.add('ownerid');
        columnlList.add('iscustomerportal');
        columnlList.add('personhasoptedoutofemail');
        columnlList.add('personhasoptedoutoffax');
        columnlList.add('persondonotcall');
        columnlList.add('name');
        columnlList.add('lastname');
        columnlList.add('recordTypeid');
        columnlList.add('salutation');
        //クリア処理
        Set < String > columnlMap = new Set < String > (columnlList);
        List < Account > accountList = Database.query('SELECT Id,Name,RecordTypeId FROM Account WHERE Id =: recordIds ORDER BY LastModifiedDate ASC');
        List < Account > accountUpList = new List < Account > ();
        for (Account tpAccount: accountList) {
            for (String fieldName: accountFieldMap.keySet()) {
                if (fieldName.endsWith('__pc')) {
                    continue;
                }
                if (columnlMap.contains(fieldName)) {
                    continue;
                }
                if (accountFieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    tpAccount.put(fieldName, null);
                }
            }
            accountUpList.add(tpAccount);
            System.debug(LoggingLevel.DEBUG, '#####2213__：\n①__:' + tpAccount + '\n②__:' + accountUpList + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        }
        update accountUpList;
    }
}