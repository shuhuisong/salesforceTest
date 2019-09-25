/**--------------------------------------------------------------------------
 * プログラム名 ：Backlog連携テストクラス
 * 作成日        ：2019/08/19
 * 作成者        ：Sou
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2019/08/19:Sou:新規作成
 *----------------------------------------------------------------------------
 */
 @isTest
public with sharing class UpsertSeisakuSetteiTest {

    static testMethod void testdoPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String result  ;

        req.headers.put('Accept','application/json');
        req.requestURI = 'https://dev02-backlogapisbtest.cs5.force.com/services/apexrest/ups_ss';
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('{"id":78737106,"project":{"id":113336,"projectKey":"TK_BPSFDCPJ","name":"BP局SalesforcePJ連携テスト","chartEnabled":true,"subtaskingEnabled":false,"projectLeaderCanEditProjectLeader":false,"useWikiTreeView":true,"textFormattingRule":"markdown","archived":false},"type":2,"content":{"id":10838531,"key_id":38,"summary":"SongTest22444","description":"ccvxcvcxvxcvx","issueType":{"id":538632,"projectId":113336,"name":"タスク","color":"#7ea800","displayOrder":0},"resolution":null,"priority":{"id":3,"name":"中"},"status":{"id":4,"name":"完了"},"assignee":{"id":284213,"userId":"subr-ktokura","name":"戸倉 健太@sunbridge","roleType":94,"lang":"ja"},"category":[{"id":256527,"name":"テストカテゴリ","displayOrder":0},{"id":256527,"name":"テストカテゴリ2","displayOrder":0},{"id":256527,"name":"テストカテゴリ3","displayOrder":0}],"versions":[],"milestone":[],"startDate":"2019-08-21","dueDate":"2019-08-23","estimatedHours":null,"actualHours":null,"parentIssueId":null,"customFields":[{"id":72352,"fieldTypeId":1,"field":"ID","value":"00002_01_01_001"}],"attachments":[],"shared_files":[],"diff":null,"comment":{"id":57786960,"content":""},"changes":[{"field":"status","new_value":"4","old_value":"3","type":"standard"}]},"notifications":[],"createdUser":{"id":284213,"userId":null,"name":"戸倉 健太@sunbridge","roleType":2,"lang":"ja","mailAddress":null,"nulabAccount":{"nulabId":"a0bYTsD3GT6Ht0RokF6efw3rWFwtM7zKM9LBRZAvl1c8kjXnud","name":"subr-ktokura","uniqueId":"ktokura"}},"created":"2019-08-19T06:50:12Z"}');

        RestContext.request = req;
        RestContext.response = res;
        System.assertEquals('POST', req.httpMethod,'連携のメソッドが不正です');
        UpsertSeisakuSettei.upsertSeisakuSettei();

    }
        static testMethod void testdoPost2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String result  ;

        
        req.headers.put('Accept','application/json');
        req.requestURI = 'https://dev02-backlogapisbtest.cs5.force.com/services/apexrest/ups_ss';
        req.httpMethod = 'POST';
        req.requestBody=Blob.valueof('{"id":78757771,"project":{"id":113336,"projectKey":"TK_BPSFDCPJ","name":"BP局SalesforcePJ連携テスト","chartEnabled":true,"subtaskingEnabled":false,"projectLeaderCanEditProjectLeader":false,"useWikiTreeView":true,"textFormattingRule":"markdown","archived":false},"type":1,"content":{"id":10843360,"key_id":39,"summary":"SongTest3334","description":"cvxvxvxvxvcxv","issueType":{"id":538632,"projectId":113336,"name":"タスク","color":"#7ea800","displayOrder":0},"resolution":null,"priority":{"id":3,"name":"中"},"status":{"id":1,"name":"未対応"},"assignee":{"id":284213,"userId":"subr-ktokura","name":"戸倉 健太@sunbridge","roleType":94,"lang":"ja"},"category":[{"id":256527,"name":"テストカテゴリ","displayOrder":0}],"versions":[],"milestone":[],"startDate":null,"dueDate":null,"estimatedHours":null,"actualHours":null,"parentIssueId":null,"customFields":[{"id":72352,"fieldTypeId":1,"field":"ID","value":"00002_001_01_001"}],"attachments":[]},"notifications":[],"createdUser":{"id":284213,"userId":null,"name":"戸倉 健太@sunbridge","roleType":2,"lang":"ja","mailAddress":null,"nulabAccount":{"nulabId":"a0bYTsD3GT6Ht0RokF6efw3rWFwtM7zKM9LBRZAvl1c8kjXnud","name":"subr-ktokura","uniqueId":"ktokura"}},"created":"2019-08-19T08:38:20Z"}');

        RestContext.request = req;
        RestContext.response = res;

        IdNumberingInsert__c idNumber = new IdNumberingInsert__c(AccountID__c = 1);
        insert idNumber;
       //取引先の新規入力
        Account accnt = new Account(name = 'Test_00001',user_id__c='00013');
        insert accnt;
        //C商談の新規入力
        Account accnt2 = [select Id from Account where name = 'Test_00001'];
        CustomOpportunity__c oppo = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        insert oppo;
        //メニューの新規入力
        System.assertEquals(null, oppo.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00002_001'];
        Menu__c menu = new Menu__c(name='*',custom_opportunity__c=oppo2.Id);
        insert menu;
        //制作・支払の新規入力
        System.assertEquals(null, menu.last_id__c,'メニューの最終IDが不正です');
        Menu__c menu2 = [select Id from Menu__c where name = '00002_001_01'];
        SeisakuSiharai__c siha = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        insert siha;
        //制作設定の新規入力
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '00002_001_01_001'];
        SeisakuSettei__c sett = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id,Backlog_Id__c='10843360');
        insert sett;
        System.assertEquals('POST', req.httpMethod,'連携のメソッドが不正です');
        UpsertSeisakuSettei.upsertSeisakuSettei();

    }
}