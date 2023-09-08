public with sharing class FineTuningController {
    
    // Fine tunes creation
    @AuraEnabled
    public static String createFineTune(String datasetName,String baseModel,String suffixName){
        String datasetId = ModelService.getDatasetIdByName(datasetName);
        String fineTuneId  = ModelService.createFineTune(datasetId,baseModel,suffixName);
        ModelService.createModelRecord(datasetId,baseModel,suffixName,fineTuneId);
        return fineTuneId;
        
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
    public static void uploadDatasetFile(List<String> rows, Id datasetId){
        List<String> proccessedRows = ModelService.formatRows(rows);
        String datasetFile = ModelService.getDatasetTextFile(proccessedRows);
        String filename = ModelService.getDatasetNameById(datasetId)+ '.jsonl';
        ModelService.uploadDatasetFile(filename, datasetFile);
        //ModelService.registerDatasetExamples(proccessedRows);
    }

    @AuraEnabled
    public static List<String> listDatasetFiles (){
        return ModelService.listDatasetFiles();
    }
    @AuraEnabled
    public static List<ModelService.ExampleWrapper> retrieveExamples(Id datasetId){
       return ModelService.retrieveExamples(datasetId);
    }

    @AuraEnabled
    public static void saveExamples(String examplesJson, Id datasetId){
        ModelService.saveExamples(examplesJson, datasetId);
    }

    @AuraEnabled
    public static List<Dataset__c> getDatasets(){
       return ModelService.getDatasets();
    }
    
}