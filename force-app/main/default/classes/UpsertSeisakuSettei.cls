@RestResource(urlMapping='/ups_ss')
global with sharing class UpsertSeisakuSettei {
    @HttpPost
    Webservice static void upsertSeisakuSettei(){
        RestRequest req = RestContext.request;
        BacklogParameter params = (BacklogParameter)JSON.deserialize(req.requestBody.toString(),BacklogParameter.class);
        //課題ID
        String issue_Id = params.content.id;

        List<SeisakuSettei__c> setteiList = [SELECT Id, Name,Backlog_Id__c,BacklogProjectName__c,backlog_title__c,kind__c,adcms_category__c
                                                   ,backlog_check__c,backlog_status__c,start_date__c,admail_by_date__c,seisaku_siharai__c,bucklog_url__c
                                                                   FROM SeisakuSettei__c 
                                                                   WHERE Backlog_Id__c = : issue_Id LIMIT 1];
            if(setteiList.size() == 0){
            // Backlog課題Idが一致する制作設定が存在しない場合、新規作成
            SeisakuSettei__c newSettei = new SeisakuSettei__c();
            setParams(newSettei, params);
            try{
                insert newSettei;
                System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei06__：\n①__:' + newSettei + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
            }catch(Exception e){
System.debug('DEBUG*****UpsertSeisakuSettei INSERT ERROR：' + e.getMessage());
            }
        }else{
            // Backlog課題が一致する制作設定が存在する場合、更新する
            SeisakuSettei__c settei = setteiList[0];
            setParams(settei, params);
            try{
                update settei;  
                System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei07__：\n①__:' + settei + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
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
        if(settei.Backlog_Id__c == null){
        settei.Backlog_Id__c = params.content.id;
        }
        // Backlogプロジェクト名
        settei.BacklogProjectName__c = params.project.name;
        // 制作ID,新規の場合：Backlog課題Idを設定する
        System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei02__：\n①__:' + settei + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
        if(settei.Name == null){
        settei.Name = params.content.id;
       } 
        //制作・支払
        List<SeisakuSiharai__c> seiSiharai = [select Id from SeisakuSiharai__c where Name = :params.content.customFields[0].value limit 1];
        if(seiSiharai.size()>0){
        settei.seisaku_siharai__c = seiSiharai[0].Id;
        System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei08__：\n①__:' + settei.seisaku_siharai__c + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
        }
        // 件名
        settei.backlog_title__c = params.content.summary;
        // 種別
        settei.kind__c = params.content.issueType.name;
        //カテゴリー
        if(params.content.category.size() > 0){
            settei.adcms_category__c = '';
            for (integer count = 0; count < params.content.category.size(); count++) {
                 if(params.content.category.size() == (count+1)){
                    settei.adcms_category__c = settei.adcms_category__c + params.content.category[count].name;
                 }else{
                    settei.adcms_category__c = settei.adcms_category__c + params.content.category[count].name + ','; 
                 }
            }
        }
        //チェックリスト
        settei.backlog_check__c = params.content.description.replace('\n', '<br>');

        System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei04__：\n①__:' + settei.backlog_check__c + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
        // ステータス
        switch on params.content.status.name {
            when '処理中'{
            settei.backlog_status__c = '原稿制作中';
            }
            when '処理済み'{
            settei.backlog_status__c = '校了';
            }
            when '完了'{
            settei.backlog_status__c = '公開';
            }
            when else {
            settei.backlog_status__c = params.content.status.name;
            }
        }
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
        //BacklogURL
        if(settei.bucklog_url__c == null){ 
        settei.bucklog_url__c = 'https://tykz.backlog.jp/view/' + params.project.projectKey + '-' + params.content.key_id;
        }
    System.debug(LoggingLevel.DEBUG, '#UpsertSeisakuSettei05__：\n①__:' + settei + '\n②__:' + '' + '\n③__:' + +'\n④__:' + +'\n⑤:' + 88);
        return settei;

    }
}