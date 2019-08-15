/**--------------------------------------------------------------------------
 * プログラム名 ：制作設定IDの採番
 * 作成日        ：2019/8/8
 * 作成者        ：Sou
 * コピーライト   ：株式会社東洋経済新報社　TOYO KEIZAI INC. Limited Copyright (c) 2017 
 *----------------------------------------------------------------------------
 * 修正履歴（修正日：担当者：修正内容）
 * 2019/8/8:Sou:新規作成
 *----------------------------------------------------------------------------
 */
trigger CustomOpportunityInsert on CustomOpportunity__c (after insert) {
CommonIdInsertHandler handler = new CommonIdInsertHandler(Trigger.isExecuting, Trigger.size);

if(Trigger.isInsert && Trigger.isAfter){

      //採番処理を呼出す
     handler.onAfterInsert(Trigger.new);

  }
}