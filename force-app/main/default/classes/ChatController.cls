public with sharing class ChatController {
    @AuraEnabled
    public static String sendPrompt(String prompt, Id sessionId){
        return PromptService.addToCallPrompt(prompt,sessionId);
    }
}