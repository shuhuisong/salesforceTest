/**--------------------------------------------------------------------------
 * プログラム名 ：ID採番処理ハンドラー（共通）テストクラス
 * 作成日        ：2019/08/08
 * 作成者        ：Sou
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2019/08/08:Sou:新規作成
 *----------------------------------------------------------------------------
 */
@isTest
private class CommonIdInsertHandlerTest {
    //取引先から行動までの主従オブジェクトのIDを採番する
    static testMethod void unitTest1() {
        //取引先の新規入力
        Account accnt = new Account(name = 'Test_00001',user_id__c='00001');
        insert accnt;
        //C商談の新規入力
        Account accnt2 = [select Id from Account where name = 'Test_00001'];
        CustomOpportunity__c oppo = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        insert oppo;
        //メニューの新規入力
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00001_01'];
        Menu__c menu = new Menu__c(name='*',custom_opportunity__c=oppo2.Id);
        insert menu;
        //制作・支払の新規入力
        Menu__c menu2 = [select Id from Menu__c where name = '00001_01_01'];
        SeisakuSiharai__c siha = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        insert siha;
        //制作設定の新規入力
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '00001_01_01_001'];
        SeisakuSettei__c sett = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        insert sett;
        //制作設定の新規入力 （C商談から）
        Task task = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        insert task;
        //制作設定の新規入力（取引先から） 
        Task task2 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        insert task2;
        //制作設定の新規入力 （C商談から）
        Event event = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        insert event;
        //制作設定の新規入力（取引先から） 
        Event event2 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        insert event2;
    }

}