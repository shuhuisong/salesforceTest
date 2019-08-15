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

public without sharing class RecordTypeUpdateHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    // トランザクションフラグ
    public static boolean tranFlg = false;

    /**
     * コンストラクタ
     */
    public RecordTypeUpdateHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;

    }


    /**
     * レコードタイプ更新処理
     */
    public void doUpdateRecordType(Contact[] newObjs, Map < ID, Contact > newMap, Contact[] oldObjs, Map < ID, Contact > oldMap) {
        System.debug(LoggingLevel.DEBUG, '#S100__：\n①__:' + '' + '\n②__:' + 88 + '\n③__:' + newObjs + '\n④__:' + oldObjs + '\n⑤__:' + '' + '\n⑥__:' + '');
        // オペレーターが'マルケト連携用'では無ければ、処理しない。
        if (!UserInfo.getName().equals('マルケト連携用')) {
            return;
        }
        //取引先責任者レコードタイプID 個人
        Id personId = null;
        //取引先責任者レコードタイプID 法人
        Id corporativeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人').getRecordTypeId();
        //取引先責任者レコードタイプID 法人かつ個人
        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
        //取引先レコードタイプID 法人
        Id accountCorporativeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('法人').getRecordTypeId();
        //取引先レコードタイプID 個人 
        Id accountPersonId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();
        //取引先レコードタイプID 法人
        RecordType accountCorporativeIDII = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Account'
            AND SObjectType = 'Account'
            LIMIT 1
        ];
        //取引先レコードタイプID 個人        
        RecordType accountPersonIDII = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'
            AND SObjectType = 'Account'
            LIMIT 1
        ];
        //DBロールバック用
        Savepoint sp = Database.setSavepoint();
        try {  
            System.debug(LoggingLevel.DEBUG, '#S11__：\n①__:' + '' + '\n②__:' + sp + '\n③__:' + newObjs + '\n④__:' + oldObjs + '\n⑤__:' + '' + '\n⑥__:' + '');
            //取引先更新対象		
            List < Account > accountList = new List < Account > ();

			//TODO COM
            for (Contact tpContact: newObjs) {
            	if(oldObjs==null||oldMap.get(tpContact.Id)==null){
            		continue;
            	}
            	
                System.debug(LoggingLevel.DEBUG, '#S12__：\n①__:' + oldMap.get(tpContact.Id).IsPersonAccount + '\n②__:' + tpContact.IsPersonAccount + '\n③__:' + personId + '\n④__:' + corporativeId + '\n⑤__:' + 88 + '\n⑥__:' + 88);
                //レコードタイプ：【個人】に対し_ユーザータイプ：【法人】で更新
                if (oldMap.get(tpContact.Id).IsPersonAccount == true && tpContact.IsPersonAccount == false) {
                    System.debug(LoggingLevel.DEBUG, '#S13__：\n①__:' + oldMap.get(tpContact.Id).RecordTypeId + '\n②__:' + tpContact.UserType__c + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + 88 + '\n⑥__:' + 88);
                    //取引先レコードタイプ【法人】へ変更                    
                    accountList.add(new Account(Id = tpContact.AccountId,
                        RecordTypeId = accountCorporativeIDII.Id
                    ));
                    //取引先責任者レコードタイプ【法人かつ個人】へ変更                	
                    tpContact.RecordTypeId = corporateAndPersonlId;
                }
                //レコードタイプ：【法人】に対しユーザータイプ：【個人】で更新
                else if (oldMap.get(tpContact.Id).RecordTypeId == corporativeId && (tpContact.RecordTypeId == personId || tpContact.UserType__c == '個人')) {
                    //取引先責任者レコードタイプ【法人かつ個人】へ変更                	
                    tpContact.RecordTypeId = corporateAndPersonlId;
                } 
            }
            //   Update accountList;
            System.debug(LoggingLevel.DEBUG, '#S15__：\n①__:' + newObjs + '\n②__:' + oldObjs + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
      } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.DEBUG, '#S16__：\n①__:' + 'ERROR' + e.getMessage() + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        }
    }

    /**
     * レコードタイプ更新処理_取引先
     */
    public void doUpdateRecordTypeAccount(Account[] newObjs, Map < ID, Account > newMap, Account[] oldObjs, Map < ID, Account > oldMap) {
        System.debug(LoggingLevel.DEBUG, '#S800__：\n①__:' + '' + '\n②__:' + 88 + '\n③__:' + newObjs + '\n④__:' + oldObjs + '\n⑤__:' + '' + '\n⑥__:' + '');

        // オペレーターが'マルケト連携用'では無ければ、処理しない。          
        if (!UserInfo.getName().equals('マルケト連携用')) {
            return;
        }
        //取引先責任者レコードタイプID 個人
        Id personId = null;
        //取引先責任者レコードタイプID 法人
        Id corporativeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人').getRecordTypeId();
        //取引先責任者レコードタイプID 法人かつ個人
        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
        //取引先レコードタイプID 法人
        Id accountCorporativeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('法人').getRecordTypeId();
        //取引先レコードタイプID 個人 
        Id accountPersonId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();
        //取引先レコードタイプID 法人
        RecordType accountCorporativeIDII = [SELECT Id FROM RecordType WHERE DeveloperName = 'Business_Account'
            AND SObjectType = 'Account'
            LIMIT 1
        ];
        //取引先レコードタイプID 個人        
        RecordType accountPersonIDII = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'
            AND SObjectType = 'Account'
            LIMIT 1
        ];
        //DBロールバック用
        Savepoint sp = Database.setSavepoint();
       try { 
            System.debug(LoggingLevel.DEBUG, '#S00__：\n①__:' + '' + '\n②__:' + sp + '\n③__:' + newObjs + '\n④__:' + oldObjs + '\n⑤__:' + '' + '\n⑥__:' + '');
            //取引先更新対象		
            List < Contact > contactList = new List < Contact > ();
            List < Account > accountList = new List < Account > ();
            set < Id > ids = new set < Id > ();
            set < Id > contactids = new set < Id > ();

            for (Account tpAccount: newObjs) {
                System.debug(LoggingLevel.DEBUG, '#S02__処理開始：\n①__:' + oldMap.get(tpAccount.Id) + '\n②__:' + tpAccount.RecordTypeId + '\n③__:' + personId + '\n④__:' + corporativeId + '\n⑤__:' + tpAccount + '\n⑥__:' + tpAccount.UserType__pc);
                //レコードタイプ：【個人】に対し_ユーザータイプ：【法人】で更新
                if (oldMap.get(tpAccount.Id).IsPersonAccount && (tpAccount.UserType__pc == '法人')) {
                    //System.debug(LoggingLevel.DEBUG, '#S04__：\n①__:' + oldMap.get(tpAccount.Id).RecordTypeId + '\n②__:' + tpAccount.UserType__pc + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + oldMap.get(tpAccount.Id).IsPersonAccount + '\n⑥__:' + 88);
                    ids.add(tpAccount.Id);
                    //tpAccount.RecordTypeId = accountCorporativeId;
                    //取引先責任者レコードタイプ【法人かつ個人】へ変更                	  
                    contactList.add(new Contact(Id = tpAccount.PersonContactId,
                        RecordTypeId = corporateAndPersonlId
                    ));
                    contactids.add(tpAccount.PersonContactId);
                    //取引先レコードタイプ【法人】へ変更                	
                    //  tpAccount.RecordTypeId = accountCorporativeIDII.Id;  
                }
                //レコードタイプ：【法人】に対しユーザータイプ：【個人】で更新
                else if (oldMap.get(tpAccount.Id).RecordTypeId == accountCorporativeId && (tpAccount.RecordTypeId == personId || tpAccount.UserType__pc == '個人')) {
                    System.debug(LoggingLevel.DEBUG, '#S06__：\n①__:' + oldMap.get(tpAccount.Id).RecordTypeId + '\n②__:' + tpAccount.UserType__pc + '\n③__:' + 88 + '\n④__:' + 88 + '\n⑤__:' + oldMap.get(tpAccount.Id).IsPersonAccount + '\n⑥__:' + 88);
                     //取引先責任者レコードタイプ【法人かつ個人】へ変更                	
                    // tpAccount.RecordTypeId = accountCorporativeId;
                } 
            }

            System.debug(LoggingLevel.DEBUG, '#S08__：\n①__:' + ids + '\n②__:' +  + '\n③__:' + contactids + '\n④__:' + contactList + '\n⑤__:' +  + '\n⑥__:' + 88);

            //取引先更新対象
            List < Account > updateAccountList = new List < Account > ();
            List < Account > accountUpList = Database.query('SELECT Id,RecordTypeId FROM Account WHERE Id =:ids ORDER BY LastModifiedDate ASC');
            for (Account tp: accountUpList) {
                updateAccountList.add(
                    new Account(Id = tp.Id,
                        RecordTypeId = accountCorporativeId));
            }
            System.debug(LoggingLevel.DEBUG, '#S18__：\n①__:' + ids + '\n②__:' + accountUpList + '\n③__:' + contactids + '\n④__:' + updateAccountList + '\n⑤__:' + '' + '\n⑥__:' + '');
            update updateAccountList;
			//取引先責任者更新対象
            List < Contact > contactUpList = Database.query('SELECT Id,RecordTypeId FROM Contact WHERE Id =:contactids ORDER BY LastModifiedDate ASC');
            for (Contact tp: contactUpList) {
                tp.RecordTypeId = corporateAndPersonlId;
            }
            System.debug(LoggingLevel.DEBUG, '#S28__：\n①__:' +  + '\n②__:' +  + '\n③__:' + contactUpList + '\n④__:' + contactids + '\n⑤__:' + '' + '\n⑥__:' + '');
            update contactUpList;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.DEBUG, '#S38__：\n①__:' + 'ERROR' + e.getMessage() + '\n②__:' + '' + '\n③__:' + '' + '\n④__:' + '' + '\n⑤__:' + '' + '\n⑥__:' + '');
        }
    }
}