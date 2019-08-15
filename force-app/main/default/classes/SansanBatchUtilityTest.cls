/**
 * ユーティリティクラス　テスト
 */
@istest
public class SansanBatchUtilityTest {
    private class TestException extends Exception {}

    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody('apiTest');

            res.setStatusCode(200);
            return res;
        }
    }

    static testMethod void testAll() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        Map<String, String> settings = SansanBatchUtility.getSettings();
        System.assertEquals(true, settings.keySet().size() > 0);

        String body = SansanBatchUtility.getRequest('/test', new Map<String, String> {'a' => 'b'}, 'BATCH_NAME', settings);
        System.assertEquals('apiTest', body);

        String testStr = 'aaaa';
        System.assertEquals('aaaa', SansanBatchUtility.getStr(testStr));
        System.assertEquals('aaa', SansanBatchUtility.getStr(testStr, 3));
        testStr = null;
        System.assertEquals('', SansanBatchUtility.getStr(testStr));
        System.assertEquals('', SansanBatchUtility.getStr(testStr, 1));

        Exception e = new TestException('error');
        System.assertEquals('SansanBatchUtilityTest.TestException: error', SansanBatchUtility.getExceptionString(e));

        Database.SaveResult[] results = Database.insert(new List<Contact> {new Contact()}, false);
        String errorMsg = SansanBatchUtility.getErrorMsg(results[0].getErrors());
        System.assertEquals(true, String.isNotBlank(errorMsg));
        
        String dateString = SansanBatchUtility.getGmtDateTimeString(DateTime.newInstance(2017, 1, 1, 9, 0, 0));
        System.assertEquals('2017-01-01T00:00:00Z', dateString);
        dateString = SansanBatchUtility.getGmtDateTimeString(DateTime.newInstance(2017, 1, 1, 8, 0, 0));
        System.assertEquals('2016-12-31T23:00:00Z', dateString);

        SansanBatchUtility.createLog(SansanBatchUtility.LOG_INFO, 'testBatch', 'aaa');
        List<BatchLog__c> logs = [select Id, Message__c, BatchName__c, Type__c from BatchLog__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('INFO', logs[0].Type__c);
        System.assertEquals('testBatch', logs[0].BatchName__c);
        System.assertEquals('aaa', logs[0].Message__c);

        DateTime dt = SansanBatchUtility.parseDateTime('2017-01-01 00:00:00');
        System.assertEquals(DateTime.newInstance(2017, 1, 1, 0, 0, 0), dt);

        SansanBatchUtility.sleep(1);

        List<User> users = [SELECT Id FROM User WHERE Name = 'Sansan連携用'];
        System.assert(users.size() > 0);

        Id ownerId = SansanBatchUtility.getOwnerUserId('Sansan連携用');
        System.assertEquals(users[0].Id, ownerId);
    }
}