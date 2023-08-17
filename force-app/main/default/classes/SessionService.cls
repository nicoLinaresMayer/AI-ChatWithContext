public with sharing class SessionService {
    public static List<Prompt__c> retrieveSessionPrompts(Id sessionId){

        List<Prompt__c> prompts = [SELECT Id, Content__c, Response__c, Order__c FROM Prompt__c WHERE Session__c =:sessionId ORDER BY Order__c ASC];
        return prompts;

    }

    public static List<PromptWrapper> retrieveChat(Id sessionId){
        List<Prompt__c> prompts = retrieveSessionPrompts(sessionId);
        List<PromptWrapper> wrappedPrompts  = new List<PromptWrapper>();
        
        for (Prompt__c prompt : prompts) {
            wrappedPrompts.add(new PromptWrapper(
                prompt.Id,
                prompt.Content__c,
                prompt.Response__c,
                Integer.valueOf(prompt.Order__c) 
            ));
        }
        
        return wrappedPrompts;
    }

    public class PromptWrapper{
        @auraEnabled
        public Id Id {get;set;}
        @auraEnabled
        public String Content {get;set;}
        @auraEnabled
        public String Response {get;set;}
        @auraEnabled
        public Integer Order {get;set;}

        public PromptWrapper(Id Id, String Content, String Response, Integer Order){
            this.Id = Id;
            this.Content = Content;
            this.Response = Response;
            this.Order = Order; 
        }
    }

    public static void addPromptToSession(String prompt, String sessionId){

    }

    public static Session__c getSession(Id sessionId){
        Session__c session = [SELECT Id,LastPromptIndex__c FROM Session__c];
        return session;
    } 
}