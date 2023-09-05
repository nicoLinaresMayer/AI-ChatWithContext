public with sharing class ChatController {

    // Retrieve chat & get new chat completion
    @AuraEnabled
    public static String getChatCompletion(String prompt, String model, Id sessionId,Decimal temperature){
        return PromptService.getChatCompletion(prompt,model,sessionId,temperature);
    }

    @AuraEnabled(cacheable=true)
    public static List<SessionService.PromptWrapper> retrieveChat(Id sessionId){
        return SessionService.retrieveChat(sessionId);
    }

    // Context info
    @AuraEnabled  
    public static void saveContextPrompts(Id sessionId,List<String> contextPrompts){
        SessionService.saveContextPrompts(sessionId,contextPrompts);
    }
    @AuraEnabled(cacheable=true)
    public static List<SessionService.PromptWrapper> retrieveContext(Id sessionId){
        return SessionService.retrieveContextMessages(sessionId);
    }

   
}