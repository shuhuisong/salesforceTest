/**--------------------------------------------------------------------------
 * プログラム名 ：ID採番処理ハンドラー（共通）
 * 作成日        ：2019/08/08
 * 作成者        ：Sou
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2019/08/08:Sou:新規作成
 *----------------------------------------------------------------------------
 */
public with sharing class CommonIdInsertHandler {

        //親オブジェクトのID格納用
        String name = '';
        //親オブジェクトのIDの先頭5桁 
        String name_5keta = '';
        //最終ID
        Decimal lastID = 0.0;
        String lastID_2keta = '01';
        String lastID_3keta = '001';
        String lastIDResult = '';
        String type = '';
        List<String> listName = new List<String>();
        List<Account> updateListAccount = new List<Account>();
        List<CustomOpportunity__c> updateListOppo = new List<CustomOpportunity__c>();
        List<Menu__c> updateListMenu = new List<Menu__c>();
        List<SeisakuSiharai__c> updateListSiharai = new List<SeisakuSiharai__c>();
        //カスタム設定から最終IDの取得
        IdNumberingInsert__c idNum = IdNumberingInsert__c.getOrgDefaults();
        // 取引先レコードタイプID 法人
        Id accountCorporativeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('法人').getRecordTypeId();

    public CommonIdInsertHandler(boolean isExecuting, integer size) {

        System.debug(LoggingLevel.DEBUG, '#CommonIdInsert00__：\n①__:' + isExecuting + '\n②__:' + size + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
    
    }
    /**
     * 取引先オブジェクトのID採番処理
     */
    public void accountBeforeInsert(Account[] newObjs) {
        for (Account a: newObjs) {
            if(a.BizCardExchangeDate__c == null && a.RecordTypeId == accountCorporativeId){
                //名刺交換日 = null の場合
               idNum.AccountID__c = idNum.AccountID__c + 1;
               a.user_id__c = String.valueOf((idNum.AccountID__c).intValue()).leftPad(5, '0');
            }else{
               //名刺交換日 <> null の場合
               continue;
            }
        }
        //カスタム設定の最終IDを更新
        if(idNum != null){
           update idNum;
        }
    }
    /**
     * C商談オブジェクトのID採番処理
     */
    public void customOppoBeforeInsert(CustomOpportunity__c[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listId = new list<Id>();
        for (CustomOpportunity__c oppo: newObjs) {
            listId.add(oppo.clent_name__c);
        }
        //親オブジェクト情報を取得する
        Map<Id,Account> mapAccount = new Map<Id,Account>([select user_id__c,last_opp_id__c from Account where ID IN : listId]);

        for (CustomOpportunity__c c: newObjs) {
          if(mapAccount.containskey(c.clent_name__c)){
            name = mapAccount.get(c.clent_name__c).user_id__c;
            if(name == null){
               //親オブジェクトの IDを取得できない場合
               continue;
            }else{
               //親オブジェクトの ID を取得できる場合
               lastID = mapAccount.get(c.clent_name__c).last_opp_id__c;
               if(lastID == null){
                   lastID = 1;
                   lastIDResult = lastID_3keta;
               }else{
                  lastID = lastID +1;
                  lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                }
                c.Name = name + '_' + lastIDResult;
                mapAccount.get(c.clent_name__c).last_opp_id__c = lastID;
                updateListAccount.add(mapAccount.get(c.clent_name__c));
            }
          }
        }
        //親オブジェクトの最終IDを更新
        if(updateListAccount.size() > 0){
            Map<Id,Account> mapAccount2 = new Map<Id,Account>();
            mapAccount2.putAll(updateListAccount);
            update mapAccount2.values();
        }
    }
    /**
     * メニューオブジェクトのID採番処理
     */
    public void menuBeforeInsert(Menu__c[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listId = new list<Id>();
        //親オブジェクト情報を取得する
        for (Menu__c menu: newObjs) {
            listId.add(menu.custom_opportunity__c);
        }
        Map<Id,CustomOpportunity__c> mapOppo = new Map<Id,CustomOpportunity__c>([select Name,last_menu_id__c from CustomOpportunity__c where ID IN :listId]);
        for (CustomOpportunity__c c: mapOppo.values()) {
            name = c.Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   String name_5keta2 = name.substring(0, 5);
                   listName.add(name_5keta2);  
                } 
            }
        }
        list<Account> listAccount = [select user_id__c from Account where user_id__c IN :listName];
        for (Menu__c m: newObjs) {
          if(mapOppo.containskey(m.custom_opportunity__c)){
            name = mapOppo.get(m.custom_opportunity__c).Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   name_5keta = name.substring(0, 5);  
                } 
                lastID = mapOppo.get(m.custom_opportunity__c).last_menu_id__c;
                for(Account account:listAccount){
                if(account.user_id__c == name_5keta){
                    //親オブジェクトの ID を取得できる場合
                    if(lastID == null){
                        lastID = 1;
                        lastIDResult = lastID_2keta;
                    }else{
                        lastID = lastID +1;
                        lastIDResult = String.valueOf((lastID).intValue()).leftPad(2, '0');
                    }
                    m.Name = name + '_' + lastIDResult;
                    mapOppo.get(m.custom_opportunity__c).last_menu_id__c = lastID;
                    updateListOppo.add(mapOppo.get(m.custom_opportunity__c));
                }
                }
            }
          }
        }
        if(updateListOppo.size() > 0){
            Map<Id,CustomOpportunity__c> mapOppo2 = new Map<Id,CustomOpportunity__c>();
            mapOppo2.putAll(updateListOppo);
            update mapOppo2.values();
        }
    }
    /**
     * 制作・支払オブジェクトのID採番処理
     */
    public void seiSiharaiBeforeInsert(SeisakuSiharai__c[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listId = new list<Id>();
        for (SeisakuSiharai__c sesiha: newObjs) {
            listId.add(sesiha.menu__c);
        }
        Map<Id,Menu__c> mapMenu = new Map<Id,Menu__c>([select Name,last_id__c from Menu__c where ID IN :listId]);
        for (Menu__c m: mapMenu.values()) {
            name = m.Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   String name_5keta2 = name.substring(0, 5);
                   listName.add(name_5keta2);  
                } 
            }
        }
        list<Account> listAccount = [select user_id__c from Account where user_id__c IN :listName];
        //親オブジェクト情報を取得する
        for (SeisakuSiharai__c s: newObjs) {
          if(mapMenu.containskey(s.menu__c)){            
            name = mapMenu.get(s.menu__c).Name;
            if(name == null){
               //親オブジェクトの IDを取得できない場合
               return;
            }else{
                //親オブジェクトの IDを取得出来た場合 
                if(name.length()<5){
                return;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   name_5keta = name.substring(0, 5);  
                } 
                lastID = mapMenu.get(s.menu__c).last_id__c;
                for(Account account:listAccount){                
                if(account.user_id__c == name_5keta){
                   //親オブジェクトの ID を取得できる場合
                   if(lastID == null){
                       lastID = 1;
                       lastIDResult = lastID_3keta;
                   }else{
                       lastID = lastID +1;
                       lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                   }
                    s.Name = name + '_' + lastIDResult;
                    mapMenu.get(s.menu__c).last_id__c = lastID;
                    updateListMenu.add(mapMenu.get(s.menu__c));
                }
                }
            }
          }
        }
        if(updateListMenu.size() > 0){
           Map<Id,Menu__c> mapMenu2 = new Map<Id,Menu__c>();
           mapMenu2.putAll(updateListMenu);
           update mapMenu2.values();
        }        
    }
    /**
     * 制作設定オブジェクトのID採番処理
     */
    public void seiSetteiBeforeInsert(SeisakuSettei__c[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listId = new list<Id>();
        for (SeisakuSettei__c sett: newObjs) {
            listId.add(sett.seisaku_siharai__c);
        }
        //親オブジェクト情報を取得する
        Map<Id,SeisakuSiharai__c> seisa = new Map<Id,SeisakuSiharai__c>([select Name,last_id__c from SeisakuSiharai__c where ID = :listId]);
        for (SeisakuSiharai__c s: seisa.values()) {
            name = s.Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   String name_5keta2 = name.substring(0, 5);
                   listName.add(name_5keta2);  
                } 
            }
        }
        list<Account> listAccount = [select user_id__c from Account where user_id__c IN :listName];
        for (SeisakuSettei__c se: newObjs) {
            if(se.seisaku_siharai__c == null){
               continue;
            }else{
                name = seisa.get(se.seisaku_siharai__c).Name;
            }
            if(name == null){
               //親オブジェクトの IDを取得できない場合
               continue;
            }else{
               //親オブジェクトの IDを取得出来た場合 
               if(name.length()<5){
                   continue;
               }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   name_5keta = name.substring(0, 5);  
               } 
               lastID = seisa.get(se.seisaku_siharai__c).last_id__c;
                for(Account account:listAccount){
                if(account.user_id__c == name_5keta){
                    //親オブジェクトの ID を取得できる場合
                    if(lastID == null){
                        lastID = 1;
                        lastIDResult = lastID_2keta;
                    }else{
                        lastID = lastID +1;
                        lastIDResult = String.valueOf((lastID).intValue()).leftPad(2, '0');
                    }
                    se.Name = name + '_' + lastIDResult;
                    seisa.get(se.seisaku_siharai__c).last_id__c = lastID;
                    updateListSiharai.add(seisa.get(se.seisaku_siharai__c));
                }
                }
            }
        }
        if(updateListSiharai.size() > 0){
            Map<Id,SeisakuSiharai__c> seisa2 = new Map<Id,SeisakuSiharai__c>();
            seisa2.putAll(updateListSiharai);
            update seisa2.values();
        }
    }
    /**
     * 日報オブジェクトのID番処理
     */
    public void taskBeforeInsert(Task[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listOppoId = new list<Id>();
        list<Id> listAccountId = new list<Id>();
        list<Account> listAccount = null;
        Map<Id,CustomOpportunity__c> mapOppo = null;
        Map<Id,Account> mapAccount = null;
        for (Task task: newObjs) {
            String type2 = String.valueOf(task.WhatId.getSObjectType());
            if(type2 == 'CustomOpportunity__c'){
                listOppoId.add(task.WhatId);
            }
            if(type2 == 'Account'){
                listAccountId.add(task.WhatId);
            }
        }
        if(listOppoId.size() > 0){
            mapOppo = new Map<Id,CustomOpportunity__c>([select Name,last_act_id__c from CustomOpportunity__c where ID IN :listOppoId]);
            for (CustomOpportunity__c c: mapOppo.values()) {
            name = c.Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   String name_5keta2 = name.substring(0, 5);
                   listName.add(name_5keta2);  
                } 
            }
        }
        listAccount = [select user_id__c from Account where user_id__c IN :listName];
        }
        if(listAccountId.size() > 0){
            mapAccount = new Map<Id,Account>([select user_id__c,last_act_id__c from Account where ID IN :listAccountId]);
        }
        //list<Account> listAccount = [select user_id__c from Account where user_id__c IN :listName];
        //親オブジェクト情報を取得する
        for (Task t: newObjs) {
            type = String.valueOf(t.WhatId.getSObjectType());
            //商談からの新規
            if (type == 'CustomOpportunity__c'){
                name = mapOppo.get(t.WhatId).Name;
                if(name == null){
                    //親オブジェクトの IDを取得できない場合
                    return;
                }else{
                    //親オブジェクトの IDを取得出来た場合 
                    if(name.length()<5){
                        return;
                    }else{
                        //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                        name_5keta = name.substring(0, 5);  
                    } 
                    lastID = mapOppo.get(t.WhatId).last_act_id__c;
                for(Account account:listAccount){
                if(account.user_id__c == name_5keta){   
                        //親オブジェクトの ID を取得できる場合
                        if(lastID == null){
                            lastID = 1;
                            lastIDResult = lastID_3keta;
                        }else{
                            lastID = lastID +1;
                            lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                        }
                        t.nippou_id__c = name + '_' + lastIDResult;
                        mapOppo.get(t.WhatId).last_act_id__c = lastID;
                        updateListOppo.add(mapOppo.get(t.WhatId));
                    }
                    }
                }
            }
            //取引先からの新規
           if (type == 'Account'){
                name = mapAccount.get(t.WhatId).user_id__c;
                if(name == null){
                    //親オブジェクトの IDを取得できない場合
                    return;
                }else{
                    //親オブジェクトの IDを取得出来た場合 
                    lastID = mapAccount.get(t.WhatId).last_act_id__c;
                    //親オブジェクトの ID を取得できる場合
                    if(lastID == null){
                       lastID = 1;
                       lastIDResult = lastID_3keta;
                    }else{
                       lastID = lastID +1;
                       lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                    }
                    t.nippou_id__c = name + '_000_' + lastIDResult;
                    mapAccount.get(t.WhatId).last_act_id__c = lastID;
                    updateListAccount.add(mapAccount.get(t.WhatId));
                }
            }
        }
        //親オブジェクトの最終IDを更新
        if(updateListAccount.size() > 0){
            Map<Id,Account> mapAccount2 = new Map<Id,Account>();
            mapAccount2.putAll(updateListAccount);
            update mapAccount2.values();
        }
        if(updateListOppo.size() > 0){
            Map<Id,CustomOpportunity__c> mapOppo2 = new Map<Id,CustomOpportunity__c>();
            mapOppo2.putAll(updateListOppo);
            update mapOppo2.values();
        }        
    }
    /**
     * 行動オブジェクトのID採番処理
     */
    public void eventBeforeInsert(Event[] newObjs) {
        //親オブジェクトIDを取得する
        list<Id> listOppoId = new list<Id>();
        list<Id> listAccountId = new list<Id>();
        list<Account> listAccount = null;
        Map<Id,CustomOpportunity__c> mapOppo = null;
        Map<Id,Account> mapAccount = null;
        for (Event event: newObjs) {
            String type2 = String.valueOf(event.WhatId.getSObjectType());
            if(type2 == 'CustomOpportunity__c'){
                listOppoId.add(event.WhatId);
            }
            if(type2 == 'Account'){
                listAccountId.add(event.WhatId);
            }
        }
        if(listOppoId.size() > 0){
            mapOppo = new Map<Id,CustomOpportunity__c>([select Name,last_act_id__c from CustomOpportunity__c where ID IN :listOppoId]);
            for (CustomOpportunity__c c: mapOppo.values()) {
            name = c.Name;
            if(name == null){
              //親オブジェクトの IDを取得できない場合
              continue;
            }else{
                //親オブジェクトの IDを取得出来た場合
                if(name.length()<5){
                continue;
                }else{
                   //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                   String name_5keta2 = name.substring(0, 5);
                   listName.add(name_5keta2);  
                } 
            }
        }
        listAccount = [select user_id__c from Account where user_id__c IN :listName];
        }
        if(listAccountId.size() > 0){
            mapAccount = new Map<Id,Account>([select user_id__c,last_act_id__c from Account where ID IN :listAccountId]);
        }
        //list<Account> listAccount = [select user_id__c from Account];
        //親オブジェクト情報を取得する
        for (Event e: newObjs) {
            type = String.valueOf(e.WhatId.getSObjectType());
            //商談からの新規
            if (type == 'CustomOpportunity__c'){
                name = mapOppo.get(e.WhatId).Name;
                if(name == null){
                    //親オブジェクトの IDを取得できない場合
                    return;
                }else{
                    //親オブジェクトの IDを取得出来た場合 
                    if(name.length()<5){
                        return;
                    }else{
                        //取得したID の先頭 5桁で取引先（クライアントID）を検索   
                        name_5keta = name.substring(0, 5);  
                    } 
                    lastID = mapOppo.get(e.WhatId).last_act_id__c;
                for(Account account:listAccount){
                if(account.user_id__c == name_5keta){   
                        //親オブジェクトの ID を取得できる場合
                        if(lastID == null){
                            lastID = 1;
                            lastIDResult = lastID_3keta;
                        }else{
                            lastID = lastID +1;
                            lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                        }
                        e.nippou_id__c = name + '_' + lastIDResult;
                        mapOppo.get(e.WhatId).last_act_id__c = lastID;
                        updateListOppo.add(mapOppo.get(e.WhatId));
                    }
                    }
                }
            }
            //取引先からの新規
           if (type == 'Account'){
                name = mapAccount.get(e.WhatId).user_id__c;
                if(name == null){
                    //親オブジェクトの IDを取得できない場合
                    return;
                }else{
                    //親オブジェクトの IDを取得出来た場合 
                    lastID = mapAccount.get(e.WhatId).last_act_id__c;
                    //親オブジェクトの ID を取得できる場合
                    if(lastID == null){
                       lastID = 1;
                       lastIDResult = lastID_3keta;
                    }else{
                       lastID = lastID +1;
                       lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                    }
                    e.nippou_id__c = name + '_000_' + lastIDResult;
                    mapAccount.get(e.WhatId).last_act_id__c = lastID;
                    updateListAccount.add(mapAccount.get(e.WhatId));
                }
            }
        }
        //親オブジェクトの最終IDを更新
        if(updateListAccount.size() > 0){
            Map<Id,Account> mapAccount2 = new Map<Id,Account>();
            mapAccount2.putAll(updateListAccount);
            update mapAccount2.values();
        }
        if(updateListOppo.size() > 0){
            Map<Id,CustomOpportunity__c> mapOppo2 = new Map<Id,CustomOpportunity__c>();
            mapOppo2.putAll(updateListOppo);
            update mapOppo2.values();
        }
    }
}