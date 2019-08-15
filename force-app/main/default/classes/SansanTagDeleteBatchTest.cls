// Sansan名刺タグ削除バッチテスト
@isTest
private class SansanTagDeleteBatchTest {
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Map<String, Object> result = new Map<String, Object>();

            if (req.getEndpoint().contains('/tags')) {
                List<Map<String, Object>> tagDatas = new List<Map<String, Object>>();

                Map<String, Object> tagData = new Map<String, Object>();
                tagData.put('id', 'TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT');
                tagData.put('name', 'テストタグ');
                tagDatas.add(tagData);

                tagData = new Map<String, Object>();
                tagData.put('id', 'TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTZ');
                tagData.put('name', 'テストタグ2');
                tagDatas.add(tagData);

                result.put('hasMore', false);
                result.put('nextPageToken', null);
                result.put('data', tagDatas);
            } else {
                List<Map<String, Object>> cardDatas = new List<Map<String, Object>>();

                Map<String, Object> cardData = new Map<String, Object>();
                cardData.put('id', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
                cardDatas.add(cardData);

                if (req.getEndpoint().contains('nextPageToken')) {
                    result.put('hasMore', false);
                    result.put('nextPageToken', null);
                } else {
                    result.put('hasMore', true);
                    result.put('nextPageToken', 'AAAA');
                }
                result.put('data', cardDatas);
            }

            res.setBody(JSON.serialize(result));
            res.setStatusCode(200);
            return res;
       }
    }

    // CRON スケジュール
    private static String CRON_EXP = '0 0 0 1 1 ? 2099';

    // テスト
    static testMethod void unitTest1() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        SansanNameCard__c sansanNameCard = new SansanNameCard__c(name = 'テスト名刺', companyName__c = '株式会社テスト', NameCardId__c = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', personId__c = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC', TagNames__c = 'a;b');
        insert sansanNameCard;

        // レコードタイプ法人
        List<RecordType> recordTypes = [select id from RecordType where SobjectType = 'Account' and IsPersonType = false];
        System.assert(recordTypes.size() > 0);

        Account account = new Account(Name = '株式会社テスト', RecordTypeId = recordTypes.get(0).Id);
        insert account;

        Contact contact = new Contact(AccountId = account.Id, LastName = 'テスト更新前', personId__c = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');
        insert contact;

        // テスト
        Test.startTest();

        SansanTagDeleteBatch batch = new SansanTagDeleteBatch();
        // 本来はsettingから取る項目だが、テスト時固定
        Database.executeBatch(batch, 200);

        Test.stopTest();

        List<SansanNameCard__c> nameCards = [select Id, TagNames__c from SansanNameCard__c where Id = :sansanNameCard.Id];
        List<Account> accounts = [select Id, TagNames__c from Account where Id = :account.Id];
        List<Contact> contacts = [select Id, TagNames__c from Contact where Id = :contact.Id];

        System.assertEquals(1, nameCards.size());
        System.assert('テストタグ;テストタグ2' == nameCards[0].TagNames__c || 'テストタグ2;テストタグ' == nameCards[0].TagNames__c);
        System.assertEquals(1, accounts.size());
        System.assert('テストタグ;テストタグ2' == accounts[0].TagNames__c || 'テストタグ2;テストタグ' == accounts[0].TagNames__c);
        System.assertEquals(1, contacts.size());
        System.assert('テストタグ;テストタグ2' == contacts[0].TagNames__c || 'テストタグ2;テストタグ' == contacts[0].TagNames__c);

    }

    // スケジューラのテスト
    static testMethod void unitTestScheduler() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        // テスト
        Test.startTest();

        SansanTagDeleteBatchScheduler scheduler = new SansanTagDeleteBatchScheduler();
        String jobID = System.schedule('testScheduleSansanTagDeleteBatch', CRON_EXP, scheduler);

        Test.stopTest();
    }
}