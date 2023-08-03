public with sharing class SessionService {
    public static List<String> retrieveChatMessages(Id sessionId){

        List<Prompt__c> prompts = [SELECT Id, Content__c, Response__c, Order__c FROM Prompt__c WHERE Session__c =:sessionId ORDER BY Order__c ASC];
        List<String> messagesList = new List<String>();


        for(Prompt__c prompt : prompts){
            messagesList.add( '{"role": "user", "content": "'+prompt.Content__c+'"}');
            messagesList.add( '{"role": "system", "content": "'+prompt.Response__c+'"}');

        }
        return messagesList;

        
   //messagesList.add( '{"role": "user", "content": "puedes decirmelo ahora en italiano"}');
    }

    /*public static void incrementSessionLastIndex(Session__c session){
        session.LastPromptIndex__c++;
        update session;
    }*/

    public static Session__c getSession(Id sessionId){
        Session__c session = [SELECT Id,LastPromptIndex__c FROM Session__c];
        return session;
    } 
}