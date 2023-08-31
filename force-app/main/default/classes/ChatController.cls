public with sharing class ChatController {
    @AuraEnabled
    public static String getChatCompletion(String prompt, String model, Id sessionId,Decimal temperature){
        return PromptService.getChatCompletion(prompt,model,sessionId,temperature);
    }

    @AuraEnabled(cacheable=true)
    public static List<SessionService.PromptWrapper> retrieveChat(Id sessionId){
        return SessionService.retrieveChat(sessionId);
    }

    @AuraEnabled(cacheable=true)
    public static List<SessionService.PromptWrapper> retrieveContext(Id sessionId){
        return SessionService.retrieveContextMessages(sessionId);
    }

    @AuraEnabled  
    public static void saveContextPrompts(Id sessionId,List<String> contextPrompts){
        SessionService.saveContextPrompts(sessionId,contextPrompts);
    }
    @AuraEnabled
    public static void uploadDatasetFile(List<String> rows, String fileName){
        String datasetFile = ModelService.formatDatasetFile(rows);
        ModelService.uploadDatasetFile(filename, datasetFile);
        
    }

    @AuraEnabled(cacheable=true)
    public static List<String> listFineTunes (){
        return ModelService.listFineTunes();
    }

    @AuraEnabled
    public static List<String> listDatasetFiles (){
        return ModelService.listDatasetFiles();
    }
    @AuraEnabled
    public static List<Model__c> getModels (){
        return ModelService.getModels();
    }

    @AuraEnabled
    public static String createFineTune(String datasetName,String baseModel,String suffixName){
        String datasetId = ModelService.getDatasetIdByName(datasetName);
        
        String fineTuneId  = ModelService.createFineTune(datasetId,baseModel,suffixName);
        ModelService.createModelRecord(datasetId,baseModel,suffixName,fineTuneId);
        return fineTuneId;
        
    }
    @AuraEnabled
    public static List<String> getFineTuneJobEventMessages(String fineTuneId){
       return ModelService.getFineTuneJobEventMessages(fineTuneId);
    }
    @AuraEnabled
    public static String getModelNameById(String fineTuneId){
        return ModelService.getModelNameById(fineTuneId);
    }

    //Single completion -- Deprecated by 3.5gpt-turbo fine-tuning
    /*@AuraEnabled
    public static String getSingleCompletion(String prompt,Decimal temperature, String model){
        return PromptService.getSingleCompletion(prompt,temperature,model);
    }*/
}