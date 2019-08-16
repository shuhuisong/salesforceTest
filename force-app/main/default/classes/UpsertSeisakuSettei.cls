@RestResource(urlMapping='/ups_ss')
global with sharing class UpsertSeisakuSettei {
    @HttpPost
    Webservice static void upsertSeisakuSettei(){
        RestRequest req = RestContext.request;
        BacklogParameter params = (BacklogParameter)JSON.deserialize(req.requestBody.toString(),BacklogParameter.class);

        String issue_Id =params.content.id;

        List<SeisakuSettei__c> setteiList = [SELECT Id, Backlog_Id__c
                                                                   FROM SeisakuSettei__c 
                                                                   WHERE Backlog_Id__c = : issue_Id LIMIT 1];
        if(setteiList.size() == 0){
            // Backlog課題Idが一致する制作設定が存在しない場合、新規作成
            SeisakuSettei__c newSettei = new SeisakuSettei__c();
            setParams(newSettei, params);
            try{
                insert newSettei;
            }catch(Exception e){
System.debug('DEBUG*****UpsertSeisakuSettei INSERT ERROR：' + e.getMessage());
            }
        }else{
            // Backlog課題が一致する制作設定が存在する場合、更新する
            SeisakuSettei__c settei = setteiList[0];
            setParams(settei, params);
            try{
                update settei;
            }catch(Exception e){
System.debug('DEBUG*****UpsertSeisakuSettei UPDATE ERROR：'+e.getMessage());
            }
        }
    }

    /**
     *    YYYY-MM-DD形式の文字列を日付に変換する
     */
    public static Date formatDate(String date_string){
        if(String.isBlank(date_string)) return null;
        return Date.newInstance(Integer.valueOf(date_string.left(4)), Integer.valueOf(date_string.mid(5,2)), Integer.valueOf(date_string.right(2)));
    }

    /**
     *    BacklogParameterクラスを制作設定に値をセットする
     */
    public static SeisakuSettei__c setParams(SeisakuSettei__c settei, BacklogParameter params){
        // Backlog課題Id
        settei.Backlog_Id__c = params.content.id;
        // Backlogプロジェクト名
        settei.BacklogProjectName__c = params.project.name;
        // 制作ID,新規の場合：Backlog課題Idを設定する
        if(String.isEmpty(settei)){
        settei.Name = params.content.id;
        } 
        // 件名
        settei.backlog_title__c = params.content.summary;
        // 種別
        settei.kind__c = params.content.issueType.name;
        //カテゴリー
        if(params.content.category.size() > 0){
            settei.adcms_category__c = params.content.category[0].name;
        }
        // チェックリスト → チェックリストが何かをお客様に確認してから修正する
        int count = 0;
        if(params.content.customFields.size() > 0){
            for (String name: params.content.customFields[0].items) {
                 settei.backlog_check__c = settei.backlog_check__c + name + ',';
                 count = count + 1;
                 if(params.content.customFields[0].items.size() == count){
                    settei.backlog_check__c = settei.backlog_check__c + name;
                 }
            }
        }
        // ステータス
        settei.backlog_status__c = params.content.status.name;
        // 開始日
        if(params.content.startDate != null){
            String sDate_string = params.content.startDate;
            settei.start_date__c = formatDate(sDate_string);
        }
        // 期限日
        if(params.content.dueDate != null){
            String dDate_string = params.content.dueDate;
            settei.admail_by_date__c = formatDate(dDate_string);
        }

        return settei;

    }
}