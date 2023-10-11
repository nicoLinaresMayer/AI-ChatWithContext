public with sharing class SessionService {
    public static List<Prompt__c> retrieveSessionPrompts(Id sessionId){

        List<Prompt__c> prompts = [SELECT Id, Content__c, Response__c, Order__c,Type__c FROM Prompt__c WHERE Session__c =:sessionId AND Type__c = 'Default' ORDER BY Order__c ASC];
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
                prompt.Type__c,
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
        public String Type {get;set;}
        @auraEnabled
        public Integer Order {get;set;}

        public PromptWrapper(Id Id, String Content, String Response, String Type, Integer Order){
            this.Id = Id;
            this.Content = Content;
            this.Response = Response;
            this.Type = Type;
            this.Order = Order; 
        }
    }

    public static List<Prompt__c> retrieveContextPrompts(Id sessionId){
        List<Prompt__c> prompts = [SELECT Id, Content__c, Response__c, Order__c,Type__c FROM Prompt__c WHERE Session__c =:sessionId AND Type__c = 'Context'];
        return prompts;
    }

    public static void saveContextPrompts(Id sessionId,List<String> contextPrompts){
        List<Prompt__c> oldContextPrompts = [SELECT ID FROM Prompt__c WHERE Session__c =:sessionId AND Type__c= 'Context'];
        if(!oldContextPrompts.isEmpty()){
            Database.delete(oldContextPrompts) ;
        }
        List<Prompt__c> contextPromptsToInsert = new List<Prompt__c>();
        for(String prompt : contextPrompts){
            if(prompt!=''){
                contextPromptsToInsert.add(new Prompt__c(Content__c = prompt , Response__c = '', Session__c = sessionId, Type__c = 'Context')); 
            }
              
        }
        if(!contextPromptsToInsert.isEmpty()){
            try{
                Database.insert(contextPromptsToInsert);
            }
            catch(Exception e){
                system.debug('error->'+e.getMessage());
            }
        }
    }

    public static List<PromptWrapper> retrieveContextMessages(Id sessionId){
        List<Prompt__c> prompts = retrieveContextPrompts(sessionId);
        List<PromptWrapper> wrappedPrompts  = new List<PromptWrapper>();
        
        for (Prompt__c prompt : prompts) {
            wrappedPrompts.add(new PromptWrapper(
                prompt.Id,
                prompt.Content__c,
                prompt.Response__c,
                prompt.Type__c,
                Integer.valueOf(prompt.Order__c) 
            ));
        }
        

        return wrappedPrompts;
    }
    public static Session__c getSession(Id sessionId){
        Session__c session = [SELECT Id,LastPromptIndex__c FROM Session__c WHERE Id =:sessionId];
        return session;
    } 

    public static void registerNewPromptWithReponse(String prompt, String promptResponse, Id sessionId){
        //If condition meets, Create Prompt record and increase last index
        if(promptResponse != ''){
            Session__c session= SessionService.getSession(sessionId);
            insert new Prompt__c(Content__c = prompt , Response__c = promptResponse, Session__c = session.Id , Order__c = session.LastPromptIndex__c);
            session.LastPromptIndex__c++;
            update session;
        }
    }
            
}