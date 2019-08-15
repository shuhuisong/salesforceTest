@isTest
public with sharing class LeadTriggerHandlerTest {

    private static Profile pf_sy =  [SELECT ID FROM Profile WHERE Name = 'システム管理者' Limit 1];
    static testMethod void UnitTest() {
        //User u = crtUser('952040', '㈱SB', 0);
        //insert u;
        
        User u = [select Id, lastname from User where Name='マルケト連携用'];
        
        Test.startTest();
        System.runAs(u) {
            Lead lead = new Lead();
            lead.FirstName = '太郎'; //名
            lead.LastName = 'サンブリッジ'; //姓
            lead.Company = '株式会社恵比寿'; //会社名
            lead.UserType__c = '法人';
            lead.Email = 'test@test.com';
            
            insert lead;
        }
        
        Integer count = [SELECT count() FROM Contact where Email='test@test.com'];
        System.assertEquals(1, count);

        Test.stopTest();
    }

    // メール重複時の挙動確認(法人)
    static testMethod void UnitTest2() {
        //User u = crtUser('952040', '㈱SB', 0);
        //insert u;

        Id corporateId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人').getRecordTypeId();
        
        User u = [select Id, lastname from User where Name='マルケト連携用'];
        
        Test.startTest();

        Account account = new Account(name = 'Test_FName_111');
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'アクセンチュア2';
        contact.Email = 'test@test.com';
        contact.SansanTitle__c = null;
        contact.ToyokeizaiId__c = String.valueOf(33893);
        contact.RecordTypeId = corporateId;
        insert contact;

        System.runAs(u) {
            Lead lead = new Lead();
            lead.FirstName = '太郎'; //名
            lead.LastName = 'サンブリッジ'; //姓
            lead.Company = '株式会社恵比寿'; //会社名
            lead.UserType__c = '法人';
            lead.Email = 'test@test.com';
            
            insert lead;
        }
        
        Integer count = [SELECT count() FROM Contact where Email='test@test.com'];
        System.assertEquals(1, count);

        Integer count2 = [SELECT count() FROM Account where PersonEmail='test@test.com'];
        System.assertEquals(0, count2);
        
        Contact resultContact = [select Name, Email from Contact where Email='test@test.com' limit 1];
        System.debug(resultContact);
        
        Test.stopTest();
    }

    // メール重複時の挙動確認(個人)
    static testMethod void UnitTest3() {
        //User u = crtUser('952040', '㈱SB', 0);
        //insert u;

        Id personId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('個人').getRecordTypeId();
        
        User u = [select Id, lastname from User where Name='マルケト連携用'];
        
        Test.startTest();

        Account account = new Account();
        account.LastName = 'test_name';
        account.FirstName = 'test_first';
        account.PersonEmail = 'faketo@accenture.com';
        account.RecordTypeId = personId;

        insert account;

        System.runAs(u) {
            Lead lead = new Lead();
            lead.FirstName = '太郎'; //名
            lead.LastName = 'サンブリッジ'; //姓
            lead.Company = '株式会社恵比寿'; //会社名
            lead.UserType__c = '個人';
            lead.Email = 'test@test.com';
            
            insert lead;
        }
        
        // 個人取引先のため
        Integer count = [SELECT count() FROM Contact where Email='test@test.com'];
        System.assertEquals(1, count);

        Integer count2 = [SELECT count() FROM Account where PersonEmail='test@test.com'];
        System.assertEquals(1, count2);
        
        Account resultAccount = [select FirstName, LastName, PersonEmail from Account where PersonEmail='test@test.com' limit 1];
        System.debug(resultAccount);
        
        Test.stopTest();
    }
    
    // メール重複時の挙動確認(法人かつ個人)
    static testMethod void UnitTest4() {
        //User u = crtUser('952040', '㈱SB', 0);
        //insert u;

        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
        
        User u = [select Id, lastname from User where Name='マルケト連携用'];
        
        Test.startTest();

        Account account = new Account(name = 'Test_FName_111');
        insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'アクセンチュア2';
        contact.Email = 'test@test.com';
        contact.SansanTitle__c = null;
        contact.ToyokeizaiId__c = String.valueOf(33893);
        contact.RecordTypeId = corporateAndPersonlId;
        insert contact;

        System.runAs(u) {
            Lead lead = new Lead();
            lead.FirstName = '太郎'; //名
            lead.LastName = 'サンブリッジ'; //姓
            lead.Company = '株式会社恵比寿'; //会社名
            lead.UserType__c = '個人';
            lead.Email = 'test@test.com';
            
            insert lead;
        }
        
        Integer count = [SELECT count() FROM Contact where Email='test@test.com'];
        System.assertEquals(1, count);

        Integer count2 = [SELECT count() FROM Account where PersonEmail='test@test.com'];
        System.assertEquals(0, count2);

        Contact resultContact = [select LastName, Email from Contact where Email='test@test.com' limit 1];
        System.debug(resultContact);

        Test.stopTest();
    }

    //　ユーザ作成
    static private User crtUser(String strCode, String strName, Integer Num) {

        User Objuser = new User();
        // ユーザの登録
        Objuser.alias = 'standt';
        Objuser.email = 'testUser_' + Num + '@SB.com.dev';
        Objuser.emailencodingkey = 'UTF-8';
        Objuser.languagelocalekey = 'en_US';
        Objuser.localesidkey = 'en_US';
        Objuser.profileid = pf_sy.Id;
        Objuser.timezonesidkey = 'Asia/Tokyo';
        Objuser.username = 'testUser_' + Num + '@SB.com.dev';
        Objuser.lastname = 'testUser_' + Num;
        Objuser.lastname = 'マルケト連携用';
        Objuser.ManagerId = UserInfo.getUserId();

        return Objuser;
    }
}