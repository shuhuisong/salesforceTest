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
        IdNumberingInsert__c idNumber = new IdNumberingInsert__c(AccountID__c = 1);
        insert idNumber;
        //取引先の新規入力
        list<Account> accnt = new list<Account>();
        Account listAccnt2 = new Account(name = 'Test_00001',user_id__c='00001');
        Account listAccnt3 = new Account(name = 'Test_00002',user_id__c='00001');
        accnt.add(listAccnt2);
        accnt.add(listAccnt3);
        insert accnt;
        //C商談の新規入力
        list<CustomOpportunity__c> oppo = new list<CustomOpportunity__c>();
        Account accnt2 = [select Id,user_id__c from Account where name = 'Test_00001'];
        Account accnt3 = [select Id,user_id__c from Account where name = 'Test_00002'];
        System.assertEquals('00002', accnt2.user_id__c,accnt2.user_id__c);
        System.assertEquals('00003', accnt3.user_id__c,accnt3.user_id__c);
        CustomOpportunity__c listOppo2 = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        CustomOpportunity__c listOppo3 = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        CustomOpportunity__c listOppo4 = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt3.ID);
        oppo.add(listOppo2);
        oppo.add(listOppo3);
        oppo.add(listOppo4);
        insert oppo;
        //メニューの新規入力
        list<Menu__c> menu = new list<Menu__c>();
        System.assertEquals(null, listOppo2.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00002_001'];
        CustomOpportunity__c oppo3 = [select Id from CustomOpportunity__c where name = '00003_001'];
        Menu__c listmenu2 = new Menu__c(name='*',custom_opportunity__c=oppo2.Id);
        Menu__c listmenu3 = new Menu__c(name='*',custom_opportunity__c=oppo2.Id);
        Menu__c listmenu4 = new Menu__c(name='*',custom_opportunity__c=oppo3.Id);
        menu.add(listmenu2);
        menu.add(listmenu3);
        menu.add(listmenu4);
        insert menu;
        //制作・支払の新規入力
        list<SeisakuSiharai__c> siha = new list<SeisakuSiharai__c>();
        System.assertEquals(null, listmenu2.last_id__c,'メニューの最終IDが不正です');
        Menu__c menu2 = [select Id from Menu__c where name = '00002_001_01'];
        Menu__c menu3 = [select Id from Menu__c where name = '00003_001_01'];
        SeisakuSiharai__c listsiha2 = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        SeisakuSiharai__c listsiha3 = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu2.Id);
        SeisakuSiharai__c listsiha4 = new SeisakuSiharai__c(name='*',Type__c='その他制作・支払',menu__c=menu3.Id);
        siha.add(listsiha2);
        siha.add(listsiha3); 
        siha.add(listsiha4);         
        insert siha;
        //制作設定の新規入力
        list<SeisakuSettei__c> sett = new list<SeisakuSettei__c>();
        SeisakuSiharai__c siha2 = [select Id from SeisakuSiharai__c where name = '00002_001_01_001'];
        SeisakuSiharai__c siha3 = [select Id from SeisakuSiharai__c where name = '00003_001_01_001'];
        SeisakuSettei__c listsett2 = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        SeisakuSettei__c listsett3 = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha2.Id);
        SeisakuSettei__c listsett4 = new SeisakuSettei__c(name='*',seisaku_siharai__c=siha3.Id);
        sett.add(listsett2);
        sett.add(listsett3);
        sett.add(listsett4);
        insert sett;
        //日報の新規入力 （C商談から）
        list<Task> Task = new list<Task>();
        Task listtask = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        Task listtask2 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=oppo2.Id);
        Task listtask3 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=oppo3.Id);
        Task.add(listtask);
        Task.add(listtask2);
        Task.add(listtask3);
        insert Task;
        //日報の新規入力（取引先から） 
        list<Task> Task2 = new list<Task>();
        Task listtask4 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        Task listtask5 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=Accnt2.ID);
        Task listtask6 = new Task(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',WhatId=Accnt3.ID);
        Task2.add(listtask4);
        Task2.add(listtask5);
        Task2.add(listtask6);
        insert task2;
        //行動の新規入力 （C商談から）
        list<Event> event = new list<Event>();
        Event listevent = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        Event listevent2 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        Event listevent3 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo3.Id);
        insert event;
        //行動の新規入力（取引先から）
        list<Event> event2 = new list<Event>(); 
        Event listevent4 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        Event listevent5 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        Event listevent6 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt3.ID);
        insert event2;
    }
        static testMethod void unitTest2() {
        IdNumberingInsert__c idNumber = new IdNumberingInsert__c(AccountID__c = 1);
        insert idNumber;
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
        IdNumberingInsert__c idNumber = new IdNumberingInsert__c(AccountID__c = 1);
        insert idNumber;
        //取引先の新規入力
        Account accnt = new Account(name = '1',user_id__c='1',BizCardExchangeDate__c = Date.today());
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
        static testMethod void unitTest4() {
        IdNumberingInsert__c idNumber = new IdNumberingInsert__c(AccountID__c = 1);
        insert idNumber;
        //取引先の新規入力
        Account accnt = new Account(name = 'Test_00001',user_id__c='00001');
        insert accnt;
        //C商談の新規入力
        Account accnt2 = [select Id from Account where name = 'Test_00001'];
        CustomOpportunity__c oppo = new CustomOpportunity__c(
        name = '*',syoudan_c_date__c=Date.today(),syoudan_status__c='訪問',background__c='代理店からの問い合わせ',clent_name__c=Accnt2.ID);
        insert oppo;
        System.assertEquals(null, oppo.last_menu_id__c,'C商談の最終IDが不正です');
        CustomOpportunity__c oppo2 = [select Id from CustomOpportunity__c where name = '00002_001'];
        //行動の新規入力 （C商談から）
        Event event = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=oppo2.Id);
        insert event;
        //行動の新規入力（取引先から） 
        Event event2 = new Event(Subject='Test_00001',OwnerId='0057F000001Zc39QAC',StartDateTime=Datetime.now(),EndDateTime=Datetime.now(),WhatId=Accnt2.ID);
        insert event2;
    }

}