/**--------------------------------------------------------------------------
 * プログラム名 ：Marketoからリード導入の後処理ハンドラー
 * 作成日        ：2017/10/23
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/10/23:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */
 
public with sharing class LeadTriggerHandler {

    /**
     * コンストラクタ
     */
    public LeadTriggerHandler(boolean isExecuting, integer size) {}

    public void onBeforeInsert(Lead[] newObjs, Map < ID, Lead > newObjMap) {
        System.debug(LoggingLevel.DEBUG, '#L07__：\n①__:' + '' + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        //「個人・法人」比較フラグ
        for (Lead tpLead: newObjs) {
            System.debug(LoggingLevel.DEBUG, '#L08__：\n①__:' + '' + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
            if (tpLead.UserType__c != null && tpLead.UserType__c.equals('個人') || String.isBlank(tpLead.UserType__c)) {
                tpLead.Company = null;
            }
        }
    }

    public void onAfterInsert(Lead[] newObjs, Map < ID, Lead > newObjMap) {
        System.debug(LoggingLevel.DEBUG, '#L01__：\n①__:' + '' + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        //取引先,取引先責任者自動作成
        addAccountAndContact(newObjs, newObjMap);
    }

    /**
     * 取引先,取引先責任者自動作成
     */
    private void addAccountAndContact(Lead[] newObjs, Map < ID, Lead > newObjMap) {

        Id userId = [SELECT ID FROM user WHERE Name = 'マルケト連携用' Limit 1].get(0).Id;
        Savepoint sp = Database.setSavepoint();
        System.debug(LoggingLevel.DEBUG, '#L16__：\n①__:' + userId + '\n②__:' + sp + '\n③__:' + newObjs + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
    try {   
            //LeadStatus を取得する
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            List < Database.LeadConvert > leadsToConvert = new List < Database.LeadConvert > ();
            for (Lead tpLead: newObjs) {
                // リードが取引開始かどうかをチェック、または情報源がマルケトでは無ければ、処理しない。
                if (tpLead.IsConverted || tpLead.CreatedById != userId) {
                    continue;
                }
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setLeadId(tpLead.id);
                lc.setDoNotCreateOpportunity(True);
                lc.ownerId = userId;
                leadsToConvert.add(lc);
            }

            System.debug(LoggingLevel.DEBUG, '#L66__：\n①__:' + leadsToConvert + '\n②__:' + leadsToConvert.size() + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
            //コンバート処理
            ContactMergeHandler.isLeadConverting = true;
            Database.LeadConvertResult[] lcr = Database.convertLead(leadsToConvert);
            ContactMergeHandler.isLeadConverting = false;
            //新しい取引先のIdリスト整理
            List < Id > accountIdList = new List < Id > ();
            //新しい取引先責任者のIdリスト整理
            List < Id > contactIdList = new List < Id > ();
            //メールを整理する。
            Map < Id, String > idMailMap = new Map < Id, String > ();
            //コンバート処理結果出力
            for (Integer j = 0; j < lcr.size(); ++j) {
                if (lcr[j].isSuccess()) {
                    System.debug(LoggingLevel.DEBUG, '#L67__：\n①__:' + 'Lead converted successfully!' + '\n②__:' + 'Account ID: ' + lcr[j].getAccountId() + '\n③__:' + 'Contact ID: ' + lcr[j].getContactId() + '\n④__:' + 'Opportunity ID: ' + lcr[j].getOpportunityId() + '\n⑤__:' + '' + '\n⑥__:' + '');
                    System.debug('Lead converted successfully!');
                    System.debug('Account ID: ' + lcr[j].getAccountId());
                    System.debug('Contact ID: ' + lcr[j].getContactId());
                    accountIdList.add(lcr[j].getAccountId());
                    contactIdList.add(lcr[j].getContactId());
                    idMailMap.put(lcr[j].getAccountId(), newObjs[j].Email);
                } else {
                    System.debug(LoggingLevel.DEBUG, '#L68__：\n①__:' + '\nError converting new Lead: ' + lcr[j].getErrors()[0].getMessage() + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
                    System.debug('\nError converting new Lead: ' + lcr[j].getErrors()[0].getMessage());
                }
            }

            //取引先：メール（外部ID)を更新する。 
            List < Account > accountList = new List < Account > ();
            for (Account tpAccount: [SELECT Id,MailExternalId__c FROM Account WHERE Id =: accountIdList]) {
                tpAccount.MailExternalId__c = idMailMap.get(tpAccount.Id);
                accountList.add(tpAccount);
            }
            System.debug(LoggingLevel.DEBUG, '#L69__：\n①__:' + idMailMap + '\n②__:' + accountList + '\n③__:' + '' + '\n④__:' + accountIdList + '\n⑤__:' + '' + '\n⑥__:' + '');
            //更新する。
            UPDATE accountList;

            //取引先責任者：空更新する(重複レコードをマージする)
            List < Contact > contactList = new List < Contact > ();
            for (Contact tpContact: [SELECT Id FROM Contact WHERE Id =: contactIdList]) {
                contactList.add(tpContact);
            }
            System.debug(LoggingLevel.DEBUG, '#L70__：\n①__:' + idMailMap + '\n②__:' + contactList + '\n③__:' + '' + '\n④__:' + contactIdList + '\n⑤__:' + '' + '\n⑥__:' + '');
            //更新する。
            UPDATE contactList;

         } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.DEBUG, '#L69__：\n①__:' + 'ERROR' + e.getMessage() + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        }
    }
}