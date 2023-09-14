public with sharing class ModelTrigger {
    public static void onAfterDelete(List<Model__c> models){
        List<String> modelsIds = new List<String>();
        system.debug('models->'+models);
        for(Model__c model: models){
            if(model.Model_Id__c != null){
                modelsIds.add(model.Model_Id__c);
            }
            
        }
        Modelservice.deleteModelsFromServer(modelsIds);
    }
}