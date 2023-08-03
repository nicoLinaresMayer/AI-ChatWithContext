public with sharing class ChatController {
    @AuraEnabled
    public static String sendPrompt(String prompt, Id sessionId){
        return PromptService.addToCallPrompt(prompt,sessionId);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> retrieveChatMessages(Id sessionId){
        return SessionService.retrieveChatMessages(sessionId);
    }


}