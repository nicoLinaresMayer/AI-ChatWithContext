public with sharing class SessionService {
    public static List<String> retrieveChatMessages(Id sessionId){

        List<Prompt__c> prompts = [SELECT Id, Content__c, Response__c, Order__c FROM Prompt__c WHERE Session__c =:sessionId ORDER BY Order__c ASC];
        List<String> messagesList = new List<String>();


        for(Prompt__c prompt : prompts){

            String content= PromptService.parsePrompt(prompt.Content__c);
            String response = PromptService.parsePrompt(prompt.Response__c);
            messagesList.add( '{"role": "user", "content": "'+content+'"}');
            messagesList.add( '{"role": "system", "content": "'+response+'"}');

        }
        return messagesList;

    }



    public static Session__c getSession(Id sessionId){
        Session__c session = [SELECT Id,LastPromptIndex__c FROM Session__c];
        return session;
    } 
}