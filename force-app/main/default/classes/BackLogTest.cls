@RestResource(urlMapping='/ups_test')
global with sharing class BackLogTest {
    @HttpPost
    webservice static void doPost(){
        RestRequest req = RestContext.request;
        BacklogParameter params = (BacklogParameter)JSON.deserialize(req.requestBody.toString(),BacklogParameter.class);

SeisakuSettei__c updateListSet = new SeisakuSettei__c();

updateListSet.Name = params.content.summary;

insert updateListSet;
    
    }
}