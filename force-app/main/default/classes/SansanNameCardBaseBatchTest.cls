// Sansan名刺差分情報取り込みバッチテスト
@isTest
private class SansanNameCardBaseBatchTest {
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('/organization/users')) {
                res.setHeader('Content-Type', 'text/csv');
                res.setBody('"","","","user_id1","","","","","","","","","","","","","","","","","1",""\n"","","","user_id2","","","","","","","","","","","","","","","","","0",""');
            } else {
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');

                Map<String, Object> result = new Map<String, Object>();
                List<Map<String, Object>> cardDatas = new List<Map<String, Object>>();

                Map<String, Object> ownerData = new Map<String, Object>();
                ownerData.put('id', 'user_id1');
                ownerData.put('name', '所有者名');
                ownerData.put('email', 'owner@example.com');

                Map<String, Object> ownerData2 = new Map<String, Object>();
                ownerData2 = ownerData.clone();
                ownerData2.put('id', 'user_id2');

                Map<String, Object> cardData = new Map<String, Object>();
                cardData.put('id', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
                cardData.put('companyId', 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB');
                cardData.put('personId', 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');
                cardData.put('exchangeDate', '2018-12-11');
                cardData.put('registeredTime', '2018-12-12T09:10:28+09:00');
                cardData.put('updatedTime', '2018-12-12T09:13:15+09:00');
                cardData.put('owner', ownerData);
                cardData.put('lastName', 'Sansan姓');
                cardData.put('firstName', 'Sansan名');
                cardData.put('lastNameReading', 'セイ');
                cardData.put('firstNameReading', 'メイ');
                cardData.put('departmentName', 'テストグループ');
                cardData.put('title', null);
                cardData.put('email', 'test@example.com');
                cardData.put('mobile', '090-0000-0000');
                cardData.put('companyName', '株式会社テスト');
                cardData.put('countryCode', 'JP');
                cardData.put('postalCode', '1000000');
                cardData.put('address', '');
                cardData.put('prefecture', '東京都');
                cardData.put('city', '千代田区');
                cardData.put('street', '中央1-1-1');
                cardData.put('building', null);
                cardData.put('tel', '03-0000-0000');
                cardData.put('secondTel', null);
                cardData.put('fax', '03-0000-0001');
                cardData.put('url', 'https://test.example.com/');
                cardData.put('memo', null);
                cardData.put('entryStatus', 'completed');
                cardData.put('isUserCreated', false);

                cardDatas.add(cardData);
                
                Map<String, Object> cardData2 = new Map<String, Object>();
                cardData2 = cardData.clone();
                cardData2.put('id', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2');
                cardData2.put('personId', 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC2');
                cardData2.put('lastName', 'Sansan姓2');
                cardData2.put('firstName', 'Sansan名2');
                cardData2.put('companyName', '株式会社テスト2');
                cardData2.put('owner', ownerData2);

                cardDatas.add(cardData2);

                result.put('hasMore', false);
                result.put('nextPageToken', null);
                result.put('data', cardDatas);

                res.setBody(JSON.serialize(result));
            }

            res.setStatusCode(200);
            return res;
        }
    }

    private class HttpCalloutMockImpl2 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('/organization/users')) {
                res.setHeader('Content-Type', 'text/csv');
                res.setBody('"","","","user_id1","","","","","","","","","","","","","","","","","1",""\n"","","","user_id2","","","","","","","","","","","","","","","","","0",""');
            } else {
                res.setHeader('Content-Type', 'application/json;charset=UTF-8');

                Map<String, Object> result = new Map<String, Object>();
                List<Map<String, Object>> cardDatas = new List<Map<String, Object>>();

                Map<String, Object> ownerData = new Map<String, Object>();
                ownerData.put('id', 'user_id1');
                ownerData.put('name', '所有者名');
                ownerData.put('email', 'owner@example.com');

                Map<String, Object> cardData = new Map<String, Object>();
                cardData.put('id', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
                cardData.put('companyId', 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB');
                cardData.put('personId', 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');
                cardData.put('exchangeDate', '2018-12-11');
                cardData.put('registeredTime', '2018-12-12T09:10:28+09:00');
                cardData.put('updatedTime', '2018-12-12T09:13:15+09:00');
                cardData.put('owner', ownerData);
                cardData.put('lastName', 'Sansan姓');
                cardData.put('firstName', 'Sansan名');
                cardData.put('lastNameReading', 'セイ');
                cardData.put('firstNameReading', 'メイ');
                cardData.put('departmentName', 'テストグループ');
                cardData.put('title', null);
                cardData.put('email', 'test@example.com');
                cardData.put('mobile', '090-0000-0000');
                cardData.put('companyName', '株式会社テスト');
                cardData.put('countryCode', 'JP');
                cardData.put('postalCode', '1000000');
                cardData.put('address', '');
                cardData.put('prefecture', '東京都');
                cardData.put('city', '千代田区');
                cardData.put('street', '中央1-1-1');
                cardData.put('building', null);
                cardData.put('tel', '03-0000-0000');
                cardData.put('secondTel', null);
                cardData.put('fax', '03-0000-0001');
                cardData.put('url', 'https://test.example.com/');
                cardData.put('memo', null);
                cardData.put('entryStatus', 'completed');
                cardData.put('isUserCreated', false);

                cardDatas.add(cardData);
                
                Map<String, Object> cardData2 = new Map<String, Object>();
                cardData2 = cardData.clone();
                cardData2.put('id', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2');
                cardData2.put('companyId', 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB');
                cardData2.put('personId', 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');
                cardData2.put('exchangeDate', '2018-12-10');
                cardData2.put('lastName', 'Sansan姓2');
                cardData2.put('firstName', 'Sansan名2');
                cardData2.put('companyName', '株式会社テスト');
                cardData2.put('owner', ownerData);
                cardData2.put('entryStatus', 'completed');

                cardDatas.add(cardData2);

                result.put('hasMore', false);
                result.put('nextPageToken', null);
                result.put('data', cardDatas);

                res.setBody(JSON.serialize(result));
            }

            res.setStatusCode(200);
            return res;
        }
    }

    // CRON スケジュール
    private static String CRON_EXP = '0 0 0 1 1 ? 2099';

    // 新規
    static testMethod void unitTest1() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        // テスト
        Test.startTest();

        SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(0, null, null);
        Database.executeBatch(batch);

        Test.stopTest();

        List<Account> accounts = [select Id, name, Website from Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('株式会社テスト', accounts[0].name);
        System.assertEquals('https://test.example.com/', accounts[0].Website);

        List<Contact> contacts = [select Id, name, LastName, FirstName from Contact];
        System.assertEquals(1, contacts.size());
        System.assertEquals('Sansan姓', contacts[0].LastName);
        System.assertEquals('Sansan名', contacts[0].FirstName);
    }

    // 更新
    static testMethod void unitTest2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        Account account = new Account(Name = '株式会社テスト');
        insert account;

        Contact contact = new Contact(AccountId = account.Id, LastName = 'テスト更新前', personId__c = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');
        insert contact;

        SansanNameCard__c sansanNameCard = new SansanNameCard__c(Name = 'テスト名刺', NameCardId__c = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        insert sansanNameCard;

        // テスト
        Test.startTest();

        SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(0, null, null);
        Database.executeBatch(batch);

        Test.stopTest();

        List<Account> accounts = [select Id, name, Website from Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('株式会社テスト', accounts[0].name);
        System.assertEquals('https://test.example.com/', accounts[0].Website);

        List<Contact> contacts = [select Id, name, LastName, FirstName from Contact];
        System.assertEquals(1, contacts.size());
        System.assertEquals('Sansan姓', contacts[0].LastName);
        System.assertEquals('Sansan名', contacts[0].FirstName);
    }

    // 既存取引先・取引先責任者があり、名刺交換日が新しい
    static testMethod void unitTest3() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        Account account = new Account(Name = '株式会社テスト', BizCardExchangeDate__c = Date.parse('2018/12/12'));
        insert account;

        Contact contact = new Contact(AccountId = account.Id, LastName = 'テスト更新前', personId__c = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC', BizCardExchangeDate__c = Date.parse('2018/12/12'));
        insert contact;

        SansanNameCard__c sansanNameCard = new SansanNameCard__c(Name = 'テスト名刺', NameCardId__c = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        insert sansanNameCard;

        // テスト
        Test.startTest();

        SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(0, null, null);
        Database.executeBatch(batch);

        Test.stopTest();

        List<Account> accounts = [select Id, name, Website from Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('株式会社テスト', accounts[0].name);
        System.assertNotEquals('https://test.example.com/', accounts[0].Website);

        List<Contact> contacts = [select Id, name, LastName, FirstName from Contact];
        System.assertEquals(1, contacts.size());
        System.assertNotEquals('Sansan姓', contacts[0].LastName);
        System.assertNotEquals('Sansan名', contacts[0].FirstName);
    }

    // 新規(同一人物IDの名刺2件)
    static testMethod void unitTest4() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl2());

        // テスト
        Test.startTest();

        SansanNameCardBaseBatch batch = new SansanNameCardBaseBatch(0, null, null);
        Database.executeBatch(batch);

        Test.stopTest();

        List<Account> accounts = [select Id, name, Website from Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('株式会社テスト', accounts[0].name);
        System.assertEquals('https://test.example.com/', accounts[0].Website);

        List<Contact> contacts = [select Id, name, LastName, FirstName from Contact];
        System.assertEquals(1, contacts.size());
        System.assertEquals('Sansan姓', contacts[0].LastName);
        System.assertEquals('Sansan名', contacts[0].FirstName);
    }

    // スケジューラのテスト
    static testMethod void unitTestScheduler() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        // テスト
        Test.startTest();

        SansanNameCardBaseBatchScheduler scheduler = new SansanNameCardBaseBatchScheduler();
        String jobID = System.schedule('testScheduleSansanNameCardBaseBatch', CRON_EXP, scheduler);

        Test.stopTest();
    }
}