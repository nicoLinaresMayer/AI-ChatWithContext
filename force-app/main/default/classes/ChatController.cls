public with sharing class ChatController {
    @AuraEnabled
    public static String getChatCompletion(String prompt, Id sessionId,Decimal temperature){
        return PromptService.getChatCompletion(prompt,sessionId,temperature);
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



    //Single completion -- Deprecated by 3.5gpt-turbo fine-tuning
    /*@AuraEnabled
    public static String getSingleCompletion(String prompt,Decimal temperature, String model){
        return PromptService.getSingleCompletion(prompt,temperature,model);
    }*/
}