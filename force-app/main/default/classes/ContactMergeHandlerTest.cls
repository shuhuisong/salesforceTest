/**--------------------------------------------------------------------------
 * プログラム名 ：取引先責任者のマージ処理ハンドラーテストクラス
 * 作成日        ：2017/11/24
 * 作成者        ：SunBridge
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2017/11/24:SunBridge:新規作成
 *----------------------------------------------------------------------------
 */

@isTest
private class ContactMergeHandlerTest {

    //キャンペーンメンバの追加(マージなし、新規、1000件、法人アカウント)
    static testMethod void unitTest1() {
        //取引先責任者レコードタイプID 法人かつ個人
        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人').getRecordTypeId();

        Campaign campaign = new Campaign(name = 'Test_CName_111');
        insert campaign;

        Account Accnt = new Account(name = 'Test_FName_111');
        insert Accnt;

        List < Contact > contactList = new List < Contact > ();
        for (Integer i = 0; i < 500; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア1';
            contact.Email = String.valueOf(i) + 'faketo@accenture.com';
            contact.ToyokeizaiId__c = String.valueOf(i + 33893);
            contact.EbisuTaikaiDate__c = datetime.now();
            contact.SansanTitle__c = null;
            contact.EbisuDelDate__c = datetime.now();
            contact.RecordTypeId = corporateAndPersonlId;
            contact.CampaignId__c = campaign.Id;
            contactList.add(contact);
        }

        Accnt = new Account(name = 'Test_FName_222');
        insert Accnt;

        for (Integer i = 500; i < 750; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア2';
            contact.Email = String.valueOf(i) + 'faketo@accenture.com';
            contact.SansanTitle__c = null;
            contact.ToyokeizaiId__c = String.valueOf(i + 33893);
            contact.CampaignId__c = campaign.Id;
            contactList.add(contact);
        }
        Accnt = new Account(name = 'Test_FName_333');
        insert Accnt;

        for (Integer i = 750; i < 1000; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア3';
            contact.SansanTitle__c = null;
            contact.Email = String.valueOf(i) + 'faketo@accenture.com';
            contact.ToyokeizaiId__c = String.valueOf(i + 33893);
            contact.CampaignId__c = campaign.Id;
            contactList.add(contact);
        }

        for (Integer i = 1000; i < 1015; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア3';
            contact.SansanTitle__c = null;
            contact.Email = String.valueOf(i) + 'faketo@accenture.com';
            contact.ToyokeizaiId__c = String.valueOf(i + 33893);
            // キャンペーンIDを設定しないので追加されない
            contactList.add(contact);
        }

        for (Integer i = 1015; i < 1020; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア3';
            contact.SansanTitle__c = null;
            contact.Email = String.valueOf(i) + 'faketo@accenture.com';
            contact.ToyokeizaiId__c = String.valueOf(i + 33893);
            // 存在しないキャンペーンIDは処理されない
            contact.CampaignId__c = '888888';
            contactList.add(contact);
        }

        insert contactList;

        Integer count = [select count() from CampaignMember];

        System.assertEquals(1000, count);
    }

    //「法人かつ個人」と「個人」
    static testMethod void unitTest2() {
        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
        List < Contact > contactList = new List < Contact > ();

        Account Accnt = new Account(name = 'Test_FName_111');
        insert Accnt;

        for (Integer i = 0; i < 3; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア1';
            contact.Email = 'faketo@accenture.com';
            contact.ToyokeizaiId__c = '33893';
            contact.EbisuTaikaiDate__c = datetime.now();
            contact.SansanTitle__c = null;
            contact.EbisuDelDate__c = datetime.now();
            contact.RecordTypeId = corporateAndPersonlId;
            contactList.add(contact);
        }

        insert contactList;

        List < Account > accounts = new List < Account > ();
        Id personId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();

        for (Integer i = 0; i < 3; i++) {
            Account account = new Account();
            account.LastName = 'test_name';
            account.FirstName = 'test_first';
            account.PersonEmail = 'faketo@accenture.com';
            account.RecordTypeId = personId;
            account.ToyokeizaiId__pc = '33893';
            accounts.add(account);
        }

        insert accounts;
    }

    //「法人」と「個人」
    static testMethod void unitTest3() {
        List < Contact > contactList = new List < Contact > ();

        Account Accnt = new Account(name = 'Test_FName_111');
        insert Accnt;
        for (Integer i = 0; i < 3; i++) {
            Contact contact = new Contact();
            contact.AccountId = Accnt.Id;
            contact.LastName = 'アクセンチュア2' + String.valueOf(i * i);
            contact.SansanTitle__c = null;
            contact.Email = String.valueOf(i * i) + 'faketo@accenture.com';
            contact.ToyokeizaiId__c = String.valueOf(i * i) + '33893';
            contactList.add(contact);
        }

        insert contactList;

        List < Account > accounts = new List < Account > ();
        Id personId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();

        for (Integer i = 0; i < 3; i++) {
            Account account = new Account();
            account.LastName = 'test_name';
            account.FirstName = 'test_first';
            account.PersonEmail = 'faketo@accenture.com';
            account.RecordTypeId = personId;
            account.ToyokeizaiId__pc = '33893';
            accounts.add(account);
        }

        insert accounts;
    }

    //「個人」と「個人」
    static testMethod void unitTest4() {
        List < Account > accounts = new List < Account > ();
        Id personId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();

        for (Integer i = 0; i < 2; i++) {
            Account account = new Account();
            account.LastName = 'test_name';
            account.FirstName = 'test_first';
            account.PersonEmail = 'faketo@accenture.com';
            account.RecordTypeId = personId;
            account.ToyokeizaiId__pc = '33893';
            accounts.add(account);
        }

        insert accounts;
    }

    //東洋経済IDの一致でマージするケースとメールでマッチするケースのワークフロー前後混じり
    static testMethod void unitTest5() {
        List < Account > accounts = new List < Account > ();
        Id personId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();

        Account account = new Account();
        account.LastName = 'test_name';
        account.FirstName = 'test_first';
        account.MailExternalId__c = 'test1@test.com';
        account.PersonEmail = 'test1@test.com';
        account.RecordTypeId = personId;
        accounts.add(account);

        account = new Account();
        account.LastName = 'test_name';
        account.FirstName = 'test_first';
        account.MailExternalId__c = 'test2@test.com';
        account.PersonEmail = 'test2@test.com';
        account.RecordTypeId = personId;
        accounts.add(account);

        insert accounts;

        List < Account > accounts2 = new List < Account > ();

        account = new Account();
        account.LastName = 'test_name';
        account.FirstName = 'test_first';
        account.MailExternalId__c = 'test1@test.com';
        account.PersonEmail = 'test1@test.com';
        account.RecordTypeId = personId;
        accounts2.add(account);

        // NG版ではこのパターンでワークフロー後にメール外部IDがPersonEmailに上書きされるとトリガが発火しない
        account = new Account();
        account.LastName = 'test_name';
        account.FirstName = 'test_first';
        account.MailExternalId__c = 'test2@test.com';
        account.PersonEmail = 'test5@test.com';
        account.RecordTypeId = personId;
        accounts2.add(account);

        insert accounts2;

        Integer count = [select count() from account];

        System.assertEquals(count, 2);

        Integer sameMailCount = [select count() from account where account.PersonEmail = 'test2@test.com'];

        System.assertEquals(1, sameMailCount);

        System.debug([select count() from account]);
    }

}