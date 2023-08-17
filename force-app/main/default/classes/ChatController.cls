public with sharing class ChatController {
    @AuraEnabled
    public static String getChatCompletion(String prompt, Id sessionId,Decimal temperature){
        return PromptService.getChatCompletion(prompt,sessionId,temperature);
    }

    @AuraEnabled(cacheable=true)
    public static List<SessionService.PromptWrapper> retrieveChat(Id sessionId){
        return SessionService.retrieveChat(sessionId);
    }


}