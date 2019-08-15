@isTest
public with sharing class RecordTypeUpdateHandlerTest {
    //法人ー＞個人
    static testMethod void unitTest1() {
    	
    	        //取引先責任者レコードタイプID 法人かつ個人
        Id corporateAndPersonlId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('法人かつ個人').getRecordTypeId();
    	
    	Account Accnt = new Account(name = 'Test_FName_111');
            insert Accnt;
    	    List < Contact > contactList = new List < Contact > ();
            for (Integer i = 0; i < 10; i++) {
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

            Accnt = new Account(name = 'Test_FName_222');
            insert Accnt;

            for (Integer i = 0; i < 10; i++) {
                Contact contact = new Contact();
                contact.AccountId = Accnt.Id;
                contact.LastName = 'アクセンチュア2';
                contact.Email = 'faketo@accenture.com';
                contact.SansanTitle__c = null;
                contact.ToyokeizaiId__c = '33893';
                contactList.add(contact);
            }
            Accnt = new Account(name = 'Test_FName_333');
            insert Accnt;
            
            Accnt.name='TKK';
            update Accnt;

            for (Integer i = 0; i < 10; i++) {
                Contact contact = new Contact();
                contact.AccountId = Accnt.Id;
                contact.LastName = 'アクセンチュア2' + String.valueOf(i * i);
                contact.SansanTitle__c = null;
                contact.Email = String.valueOf(i * i) + 'faketo@accenture.com';
                contact.ToyokeizaiId__c = String.valueOf(i * i) + '33893';
                contactList.add(contact);
            }
            insert contactList;
    	
    }
    static testMethod void unitTest2() {
    }
    static testMethod void unitTest3() { 
    }
}