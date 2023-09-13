public with sharing class FineTuningController {
    
    // Fine tunes creation
    @AuraEnabled
    public static String createFineTune(String datasetId,String baseModel,String suffixName){
        String result  = ModelService.createFineTune(datasetId,baseModel,suffixName);
        Dataset__c dataset = [SELECT Id,Id__c FROM Dataset__c WHERE Id__c=:datasetId LIMIT 1];
        ModelService.createModelRecord(dataset,baseModel,suffixName,result);
        return result;
        
    }
    // Get model's information
    @AuraEnabled
    public static List<String> getFineTuneJobEventMessages(String fineTuneId){
       return ModelService.getFineTuneJobEventMessages(fineTuneId);
    }
    @AuraEnabled
    public static String getModelNameById(String fineTuneId){
        return ModelService.getModelNameById(fineTuneId);
    }

    @AuraEnabled
    public static List<Model__c> getModels (){
        return ModelService.getModels();
    }

    // Dataset operations
    @AuraEnabled
    public static void uploadDatasetFile(Id datasetId){
        DatasetService.uploadDatasetFile(datasetId);
    }

    /*@AuraEnabled
    public static List<String> listDatasetFiles (){
        return ModelService.listDatasetFiles();
    }*/
    @AuraEnabled
    public static List<DatasetService.ExampleWrapper> retrieveExamples(Id datasetId){
       return DatasetService.retrieveExamples(datasetId);
    }

    @AuraEnabled
    public static void saveExamples(String examplesJson,String deletedRows, Id datasetId){
        DatasetService.saveExamples(examplesJson, deletedRows, datasetId);
    }

    @AuraEnabled
    public static List<Dataset__c> getDatasets(){
       return DatasetService.getDatasets();
    }
    
}