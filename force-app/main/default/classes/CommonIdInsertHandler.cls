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
    public CommonIdInsertHandler(boolean isExecuting, integer size) {

        System.debug(LoggingLevel.DEBUG, '#CommonIdInsert00__：\n①__:' + isExecuting + '\n②__:' + size + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
    
    }
    /**
     * ID採番処理
     */
    public void onAfterInsert(SObject[] newObjs) {
        
        //親オブジェクトのID格納用
        String name = '';
        //親オブジェクトのIDの先頭5桁 
        String name_5keta = '';
        //最終ID
        Decimal lastID = 0.0;
        String lastIDResult = '';
        String type = '';
        List<Account> updateListAccount = new List<Account>();
        List<CustomOpportunity__c> updateListOppo = new List<CustomOpportunity__c>();
        List<Menu__c> updateListMenu = new List<Menu__c>();
        List<SeisakuSiharai__c> updateListSiharai = new List<SeisakuSiharai__c>();
        List<SeisakuSettei__c> updateListSet = new List<SeisakuSettei__c>();
        List<Task> updateListTask = new List<Task>();
        List<Event> updateListEvent = new List<Event>();
        //カスタム設定の項目
        IdNumberingInsert__c idNum = null;
        //DBロールバック用
        Savepoint sp = Database.setSavepoint();
        //親オブジェクトの IDと最終ID を取得
        try{
            for (SObject sj: newObjs) {
               switch on sj {
                //取引先オブジェクトの採番処理
                when Account a{
                    //カスタム設定から最終IDの取得
                    idNum = IdNumberingInsert__c.getOrgDefaults();
                    Account Account2= [select Id,user_id__c from Account where Id = : a.Id];
                    if(a.BizCardExchangeDate__c != null){
                       //名刺交換日 <> null の場合
                       return;
                    }else{
                       //名刺交換日 = null の場合
                       idNum.AccountID__c = idNum.AccountID__c + 1;
                       Account2.user_id__c = String.valueOf((idNum.AccountID__c).intValue()).leftPad(5, '0');
                       updateListAccount.add(Account2);
                    }
                }
                //C商談オブジェクトの採番処理
                when CustomOpportunity__c c{
                    CustomOpportunity__c oppo = [select Name,clent_name__r.user_id__c,clent_name__r.last_opp_id__c from CustomOpportunity__c where ID = :c.ID];
                    name = oppo.clent_name__r.user_id__c;
                    if(name == null){
                       //親オブジェクトの IDを取得できない場合
                       return;
                    }else{
                       //親オブジェクトの ID を取得できる場合
                       lastID = oppo.clent_name__r.last_opp_id__c;
                       if(lastID == null){
                           lastID = 1;
                           lastIDResult = '01';
                       }else{
                          lastID = lastID +1;
                          lastIDResult = String.valueOf((lastID).intValue()).leftPad(2, '0');
                        }
                        oppo.Name = name + '_' + lastIDResult;
                        oppo.clent_name__r.last_opp_id__c = lastID;
                        updateListOppo.add(oppo);
                        updateListAccount.add(oppo.clent_name__r);
                    }
                }
                //メニューオブジェクトの採番処理
                when Menu__c m{        
                    //メニューの親オブジェクトの ID を取得
                    Menu__c menu = [select Name,custom_opportunity__r.Name,custom_opportunity__r.last_menu_id__c from Menu__c where ID = :m.ID];
                    name = menu.custom_opportunity__r.Name;
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
                    lastID = menu.custom_opportunity__r.last_menu_id__c;
                    list<Account> account = [select user_id__c from Account where user_id__c = :name_5keta];
                    if(account.size()==0){
                      //親オブジェクトの ID を取得できない場合
                      return;
                    }else{
                       //親オブジェクトの ID を取得できる場合
                       if(lastID == null){
                       lastID = 1;
                       lastIDResult = '01';
                       }else{
                           lastID = lastID +1;
                           lastIDResult = String.valueOf((lastID).intValue()).leftPad(2, '0');
                       }
                        menu.Name = name + '_' + lastIDResult;
                        menu.custom_opportunity__r.last_menu_id__c = lastID;
                        updateListMenu.add(menu);
                        updateListOppo.add(menu.custom_opportunity__r);
                    }
                }
                }
                //制作・支払オブジェクトの採番処理
                when SeisakuSiharai__c s{        
                    //制作・支払の親オブジェクトのIDを取得
                    SeisakuSiharai__c siharai = [select Name,menu__r.Name,menu__r.last_id__c from SeisakuSiharai__c where ID = :s.ID];
                    name = siharai.menu__r.Name;
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
                        lastID = siharai.menu__r.last_id__c;
                        list<Account> account = [select user_id__c from Account where user_id__c = :name_5keta];
                        if(account.size()==0){
                           //親オブジェクトの ID を取得できない場合
                           return;
                        }else{
                           //親オブジェクトの ID を取得できる場合
                           if(lastID == null){
                               lastID = 1;
                               lastIDResult = '001';
                           }else{
                               lastID = lastID +1;
                               lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                           }
                           siharai.Name = name + '_' + lastIDResult;
                           siharai.menu__r.last_id__c = lastID;
                           updateListSiharai.add(siharai);
                           updateListMenu.add(siharai.menu__r);
                        }
                    }
                }
                //制作設定オブジェクトの採番処理
                when SeisakuSettei__c se{        
                    //制作設定の親オブジェクトのIDを取得
                    SeisakuSettei__c sett = [select Name,seisaku_siharai__r.Name,seisaku_siharai__r.last_id__c from SeisakuSettei__c where ID = :se.ID];
                    name = sett.seisaku_siharai__r.Name;
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
                       lastID = sett.seisaku_siharai__r.last_id__c;
                       list<Account> account = [select user_id__c from Account where user_id__c = :name_5keta];
                       if(account.size()==0){
                            //親オブジェクトの ID を取得できない場合
                            return;
                        }else{
                            //親オブジェクトの ID を取得できる場合
                            if(lastID == null){
                                lastID = 1;
                                lastIDResult = '01';
                            }else{
                                lastID = lastID +1;
                                lastIDResult = String.valueOf((lastID).intValue()).leftPad(2, '0');
                            }
                            sett.Name = name + '_' + lastIDResult;
                            sett.seisaku_siharai__r.last_id__c = lastID;
                            updateListSet.add(sett);
                            updateListSiharai.add(sett.seisaku_siharai__r);
                        }
                    }
                }
                //日報オブジェクトの採番処理
                when Task t{
                    Task task2 = [select nippou_id__c,WhatId from Task where Id= :t.Id];
                    type = String.valueOf(task2.WhatId.getSObjectType());
                    //商談からの新規
                    if (type == 'CustomOpportunity__c'){
                        CustomOpportunity__c oppo = [select Name,last_act_id__c from CustomOpportunity__c where ID = :task2.WhatId];
                        name = oppo.Name;
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
                            lastID = oppo.last_act_id__c;
                            list<Account> account = [select user_id__c from Account where user_id__c = :name_5keta];
                            if(account.size()==0){
                                //親オブジェクトの ID を取得できない場合
                                return;
                            }else{   
                                //親オブジェクトの ID を取得できる場合
                                if(lastID == null){
                                    lastID = 1;
                                    lastIDResult = '001';
                                }else{
                                    lastID = lastID +1;
                                    lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                                }
                                task2.nippou_id__c = name + '_' + lastIDResult;
                                oppo.last_act_id__c = lastID;
                                updateListTask.add(task2);
                                updateListOppo.add(oppo);
                            }
                        }
                    }
                   //取引先からの新規
                   if (type == 'Account'){
                        Account account = [select user_id__c,last_act_id__c from Account where ID = :task2.WhatId];
                        name = account.user_id__c;
                        if(name == null){
                            //親オブジェクトの IDを取得できない場合
                            return;
                        }else{
                            //親オブジェクトの IDを取得出来た場合 
                            lastID = account.last_act_id__c;
                            //親オブジェクトの ID を取得できる場合
                            if(lastID == null){
                               lastID = 1;
                               lastIDResult = '001';
                            }else{
                               lastID = lastID +1;
                               lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                            }
                            task2.nippou_id__c = name + '_00_' + lastIDResult;
                            account.last_act_id__c = lastID;
                            updateListTask.add(task2);
                            updateListAccount.add(account);
                        }
                    }
                }
                //行動オブジェクトの採番処理
                when else{
                    Event event = [select nippou_id__c,WhatId from Event where Id= :sj.Id];
                    type = String.valueOf(event.WhatId.getSObjectType());
                    //商談からの新規
                    if (type == 'CustomOpportunity__c'){
                        CustomOpportunity__c oppo = [select Name,last_act_id__c from CustomOpportunity__c where ID = :event.WhatId];
                        name = oppo.Name;
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
                            lastID = oppo.last_act_id__c;
                            list<Account> account = [select user_id__c from Account where user_id__c = :name_5keta];
                            if(account.size()==0){
                                //親オブジェクトの ID を取得できない場合
                                return;
                            }else{
                                //親オブジェクトの ID を取得できる場合
                                if(lastID == null){
                                    lastID = 1;
                                    lastIDResult = '001';
                                }else{
                                    lastID = lastID +1;
                                    lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                                }
                                event.nippou_id__c = name + '_' + lastIDResult;
                                oppo.last_act_id__c = lastID;
                                updateListEvent.add(event);
                                updateListOppo.add(oppo);
                            }
                        }
                    }
                    //取引先からの新規
                    if (type == 'Account'){
                        Account account = [select user_id__c,last_act_id__c from Account where ID = :event.WhatId];
                        name = account.user_id__c;
                        if(name == null){
                            //親オブジェクトの IDを取得できない場合
                            return;
                        }else{
                            //親オブジェクトの IDを取得出来た場合 
                            lastID = account.last_act_id__c;
                            //親オブジェクトの ID を取得できる場合
                            if(lastID == null){
                                lastID = 1;
                                lastIDResult = '001';
                            }else{
                                lastID = lastID +1;
                                lastIDResult = String.valueOf((lastID).intValue()).leftPad(3, '0');
                            }
                            event.nippou_id__c = name + '_00_' + lastIDResult;
                            account.last_act_id__c = lastID;
                            updateListEvent.add(event);
                            updateListAccount.add(account);
                        }
                    }
                }
               }
        }
                //採番したIDでオブジェクトのIDを更新
                //親オブジェクトの最終IDを更新
                if(updateListAccount.size() > 0){
                update updateListAccount;
                }
                if(updateListOppo.size() > 0){
                update updateListOppo;
                }
                if(updateListMenu.size() > 0){
                update updateListMenu;
                }
                if(updateListSiharai.size() > 0){
                update updateListSiharai;
                }
                if(updateListSet.size() > 0){
                update updateListSet;
                }
                if(updateListTask.size() > 0){
                update updateListTask;
                }
                if(updateListEvent.size() > 0){
                update updateListEvent;
                }
                //カスタム設定の最終IDを更新
                if(idNum != null){
                update idNum;
                }
        }catch(Exception e){
            // 例外が発生した場合、ロールバック
            Database.rollback(sp);
            System.debug('DEBUG*****CommonIdInsertHandler INSERT ERROR：' + e.getMessage());
    }
    }

    }
