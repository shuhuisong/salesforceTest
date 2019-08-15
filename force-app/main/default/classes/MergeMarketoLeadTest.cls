@isTest
public class MergeMarketoLeadTest {
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            if (req.getEndpoint().contains('leads.json')) {
                // リード検索
                res.setBody('{"requestId":"dd2c#16488eb2ca7","result":[{"id":25697,"firstName":"サンブリッジテスト","lastName":"Unknown","email":"arata.miura@sunbridge.com","updatedAt":"2018-07-11T10:29:40Z","createdAt":"2018-07-11T10:25:13Z","SalesforceId__c":"11111111"},{"id":25698,"firstName":"サンブリッジテスト","lastName":"Unknown","email":"arata.miura@sunbridge.com","updatedAt":"2018-07-11T10:29:40Z","createdAt":"2018-07-11T10:25:13Z","SalesforceId__c":"22222222"}],"success":true}');
            } else if(req.getEndpoint().contains('merge.json')) {
                // マージ
                res.setBody('{"requestId":"78b7#164acdab46d","result":[],"success":true}');
            } else {
                // 認証
                res.setBody('{"access_token":"bd45cbee-22b0-40fe-83b5-b3ab3ab0414b:ab","token_type":"bearer","expires_in":3599,"scope":"arata.miura@sunbridge.com"}');
            }

            res.setStatusCode(200);
            return res;
       }
    }

    private class HttpCalloutMockErrorImpl implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            if (req.getEndpoint().contains('leads.json')) {
                // リード検索
                res.setBody('{"requestId":"dd2c#16488eb2ca7","result":[{"id":25697,"firstName":"サンブリッジテスト","lastName":"Unknown","email":"arata.miura@sunbridge.com","updatedAt":"2018-07-11T10:29:40Z","createdAt":"2018-07-11T10:25:13Z","SalesforceId__c":"11111111"},{"id":25698,"firstName":"サンブリッジテスト","lastName":"Unknown","email":"arata.miura@sunbridge.com","updatedAt":"2018-07-11T10:29:40Z","createdAt":"2018-07-11T10:25:13Z","SalesforceId__c":"22222222"}],"success":true}');
            } else if(req.getEndpoint().contains('merge.json')) {
                // マージ
                res.setBody('{"requestId":"e0e6#164acf51ca3","success":false,"errors":[{"code":"1004","message":"Lead \'25698\' not found"}]}');
            } else {
                // 認証
                res.setBody('{"access_token":"bd45cbee-22b0-40fe-83b5-b3ab3ab0414b:ab","token_type":"bearer","expires_in":3599,"scope":"arata.miura@sunbridge.com"}');
            }

            res.setStatusCode(200);
            return res;
       }
    }

    // 正常系
    @isTest static void unitTest1() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

        MergeHistory__c mh = new MergeHistory__c(
            SrcSfId__c = '11111111',
            DstSfId__c = '22222222'
        );
        insert mh;
        Test.setCreatedDate(mh.Id, DateTime.newInstance(2011,3,11));

        Test.startTest();

        String jobId = System.schedule('TestScheduledApex', '0 0 * * * ?', new MergeMarketoLead());

        Test.stopTest();

        // 外部Calloutは時間差実行となるため、Test内でassertしない
    }

    // 異常系
    @isTest static void unitTest2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockErrorImpl());

        MergeHistory__c mh = new MergeHistory__c(
            SrcSfId__c = '11111111',
            DstSfId__c = '22222222'
        );
        insert mh;
        Test.setCreatedDate(mh.Id, DateTime.newInstance(2011,3,11));

        Test.startTest();

        String jobId = System.schedule('TestScheduledApex', '0 0 * * * ?', new MergeMarketoLead());

        Test.stopTest();

        // 外部Calloutは時間差実行となるため、Test内でassertしない
    }
}