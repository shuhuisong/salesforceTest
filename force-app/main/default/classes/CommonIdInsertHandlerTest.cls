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
        System.assertEquals(null, oppo.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00001_001'];
        Menu__c menu = new Menu__c(name='*',custom_opportunity__c=oppo2.Id);
        insert menu;
        //制作・支払の新規入力
        System.assertEquals(null, menu.last_id__c,'メニューの最終IDが不正です');
        Menu__c menu2 = [select Id from Menu__c where name = '00001_001_01'];
        SeisakuSiharai__c siha = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        insert siha;
        //制作設定の新規入力
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '00001_001_01_001'];
        SeisakuSettei__c sett = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        insert sett;
        //日報の新規入力 （C商談から）
        Task task = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        insert task;
        //日報の新規入力（取引先から） 
        Task task2 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        insert task2;
        //行動の新規入力 （C商談から）
        Event event = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        insert event;
        //行動の新規入力（取引先から） 
        Event event2 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        insert event2;
    }
        static testMethod void unitTest2() {
        //取引先の新規入力
        Account accnt = new Account(name = 'Test_00002',user_id__c='00002',last_opp_id__c=1,last_act_id__c=1);
        insert accnt;
        //C商談の新規入力
        Account accnt2 = [select Id from Account where name = 'Test_00002'];
        CustomOpportunity__c oppo = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',last_act_id__c=1,last_menu_id__c=1,clent_name__c=Accnt2.ID);
        insert oppo;
        //メニューの新規入力
        System.assertEquals(1, oppo.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00002_002'];
        Menu__c menu = new Menu__c(name='*',last_id__c=1,custom_opportunity__c=oppo2.Id);
        insert menu;
        //制作・支払の新規入力
        System.assertEquals(1, menu.last_id__c,'メニューの最終IDが不正です');
        Menu__c menu2 = [select Id from Menu__c where name = '00002_002_02'];
        SeisakuSiharai__c siha = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',last_id__c=1,menu__c=menu2.Id);
        insert siha;
        //制作設定の新規入力
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '00002_002_02_002'];
        SeisakuSettei__c sett = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        insert sett;
        //日報の新規入力 （C商談から）
        Task task = new Task(Subject='Test_00002',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        insert task;
        //日報の新規入力（取引先から） 
        Task task2 = new Task(Subject='Test_00002',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        insert task2;
        //行動の新規入力 （C商談から）
        Event event = new Event(Subject='Test_00002',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        insert event;
        //行動の新規入力（取引先から） 
        Event event2 = new Event(Subject='Test_00002',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        insert event2;
    }
        static testMethod void unitTest3() {
        //取引先の新規入力
        Account accnt = new Account(name = '1',user_id__c='1');
        insert accnt;
        //C商談の新規入力
        Account accnt2 = [select Id from Account where name = '1'];
        CustomOpportunity__c oppo = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        insert oppo;
        //メニューの新規入力
        System.assertEquals(null, oppo.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '1_001'];
        Menu__c menu = new Menu__c(name='*',last_id__c=1,custom_opportunity__c=oppo2.Id);
        insert menu;
        //制作・支払の新規入力
        System.assertEquals(1, menu.last_id__c,'メニューの最終IDが不正です');
        Menu__c menu2 = [select Id from Menu__c where name = '*'];
        SeisakuSiharai__c siha = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        insert siha;
        //制作設定の新規入力
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '*'];
        SeisakuSettei__c sett = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        insert sett;
        //行動の新規入力 （C商談から）
        Event event = new Event(Subject='1004',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        insert event;
        //行動の新規入力（取引先から） 
        Event event2 = new Event(Subject='1005',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        insert event2;
        //日報の新規入力 （C商談から）
        Task task = new Task(Subject='1002',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        insert task;
        //日報の新規入力（取引先から） 
        Task task2 = new Task(Subject='1003',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        insert task2;
    }

}