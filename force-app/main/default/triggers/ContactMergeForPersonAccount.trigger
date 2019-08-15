/**--------------------------------------------------------------------------
 * プログラム名 ：取引先責任者のマージ(個人)処理トリガー
 * 作成日        ：2017/11/24
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/11/24:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */

trigger ContactMergeForPersonAccount on Account(after insert, after undelete, after update) {
    System.debug(LoggingLevel.ERROR, '#Z0000：\n①__:' + ContactMergeHandler.isTriggerCalled + '\n②__:' + ContactMergeHandler.isLeadConverting + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88);
    if (ContactMergeHandler.isTriggerCalled || ContactMergeHandler.isLeadConverting) {
        System.debug(LoggingLevel.ERROR, '#Z0001：exit ContactMergeForPersonAccount for recursive call.');
        return;
    }
    System.debug(LoggingLevel.ERROR, '#Z00__：\n①__:' + Trigger.new + '\n②__:' + Trigger.newMap + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88);
    if ((Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) && Trigger.isAfter) {
        System.debug(LoggingLevel.ERROR, '#Z03__：\n①__:' + Trigger.new + '\n②__:' + Trigger.newMap + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88);
        List < Contact > contactList = new List < Contact > ();
        Set < String > cIds = new Set < String > ();
        for (Account tpAccount: Trigger.new) {
            if (tpAccount.IsPersonAccount) {
                Contact contact = new Contact();
                contact.id = tpAccount.PersonContactId;
                contact.Email = tpAccount.PersonEmail;
                contactList.add(contact);
            }
            if ((Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate)) {
                cIds.add(tpAccount.PersonContactId);
            }
        }
        if (contactList.size() > 0) {
            Map<Id, Contact> contactUpMap = new Map<Id, Contact>([SELECT Id, Email, ToyokeizaiId__c, CampaignId__c FROM Contact WHERE Id = :cIds ORDER BY LastModifiedDate ASC]);
            //System.debug(LoggingLevel.ERROR, '#Z04__：\n①__:' + contactUpList + '\n②__:' + + '\n③__:' + cIds + '\n④__:' + 88 + '\n⑤__:' + 88);
            if(contactUpMap.size() < 1) {
                return;
            }

            // 東洋経済ID, メールアドレスの更新対象外部キーからの更新を事前実施
            for (Account tpAccount: Trigger.new) {
                Contact targetContact = contactUpMap.get(tpAccount.PersonContactId);
                if (targetContact != null && tpAccount.IsPersonAccount) {
                    if (tpAccount.ToyokeizaiId__pc <> tpAccount.ToyokeizaiId__c && tpAccount.ToyokeizaiId__c != null) {
                        targetContact.ToyokeizaiId__c = tpAccount.ToyokeizaiId__c;
                    }
                    if (
                        (
                            Trigger.oldMap != null &&
                            Trigger.oldMap.get(tpAccount.Id) != null &&
                            tpAccount.MailExternalId__c <> Trigger.oldMap.get(tpAccount.Id).MailExternalId__c
                        ) ||
                        (
                            tpAccount.MailExternalId__c != null &&
                            tpAccount.MailExternalId__c.contains('@')
                        )
                    ) {
                        System.debug('X0001:update Contact Email');
                        targetContact.Email = tpAccount.MailExternalId__c;
                    }
                }
            }

            System.debug('X11:' + contactUpMap);

            ContactMergeHandler handler = new ContactMergeHandler(true, 1);
            ContactMergeHandler.isTriggerCalled = true;
            System.debug(LoggingLevel.ERROR, '#Z05__：\n①__:' + contactUpMap.values() + '\n②__:' + contactUpMap.values().get(0).Email + '\n③__:' + cIds + '\n④__:' + 88 + '\n⑤__:' + 88);
            handler.doMerge(contactUpMap.values(), null, null, null);
            System.debug(LoggingLevel.ERROR, '#Z06__：\n①__:' + contactUpMap.values() + '\n②__:' + contactUpMap.values().get(0).Email + '\n③__:' + cIds + '\n④__:' + 88 + '\n⑤__:' + 88);
            ContactMergeHandler.isTriggerCalled = false;
        }
    }
}