public with sharing class DatasetTrigger {
    public static void onAfterDelete(List<Dataset__c> datasets){
        List<String> datasetsIds = new List<String>();
        for(Dataset__c dataset: datasets){
            if(dataset.Id__c != null){
                datasetsIds.add(dataset.Id__c);
            }
            
        }
        DatasetService.deleteDatasetsFromServer(datasetsIds);
    }
}