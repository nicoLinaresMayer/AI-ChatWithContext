public with sharing class PromptService {
    static final string ACCESS_TOKEN = Utils.getApiKey();
    public static HttpResponse apiCaller(String endpoint, String body, String method,String accessToken){
        // Set HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Authorization','Bearer '+ accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        if(body!=''){
            req.setBody(body);
        }
        
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }

    public static String handleChatCompletionResponse(HttpResponse res,Id sessionId){
        String responseContent = '';
        if (res.getStatusCode() == 200) {
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> choicesList = (List<Object>) responseBody.get('choices');
            Map<String, Object> firstChoice = (Map<String, Object>) choicesList[0];
            Map<String, Object> messageMap = (Map<String, Object>) firstChoice.get('message');
            responseContent = (String) messageMap.get('content');
            
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());   
            }
        
       return responseContent;     
    }
    //Deprecated by 3.5gpt-turbo fine-tuning 
    /*public static String handleSingleCompletionResponse(HttpResponse res){
        String responseContent = '';
        if (res.getStatusCode() == 200) {
            system.debug(res.getBody());
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> choicesList = (List<Object>) responseBody.get('choices');
            Map<String, Object> firstChoice = (Map<String, Object>) choicesList[0];
            responseContent = (String) firstChoice.get('text');
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());  
            }
        
       return responseContent;     
    }*/

    public static String getRequestBodyWithNewPrompt(String incomingPrompt,Id sessionId, String model,Decimal temperature){
        incomingPrompt = parsePrompt(incomingPrompt);
        List<Prompt__c> promptsList = SessionService.retrieveSessionPrompts(sessionId);
        List<Prompt__c> contextPromptsList = SessionService.retrieveContextPrompts(sessionId);
        system.debug('CONTEXT PROMPT LIST');
        system.debug(contextPromptsList);
        List<String> messagesList = new List<String>();
        for (Prompt__c prompt : contextPromptsList) {
            messagesList.add('{"role": "system", "content": "'+parsePrompt(prompt.Content__c)+'"}');
        }
        for (Prompt__c prompt : promptsList) {
            messagesList.add('{"role": "user", "content": "'+parsePrompt(prompt.Content__c)+'"}');
            messagesList.add('{"role": "system", "content": "'+parsePrompt(prompt.response__c)+'"}');
        }
        // add incoming prompt to the body
        messagesList.add('{"role": "user", "content": "'+incomingPrompt+'"}');
        String messages = String.join(messagesList, ',');
        
        String body = '{"model": "'+model+'","messages": ['+messages+'],"temperature": '+temperature+'}';
        //Mando el prompt
        return body;
    }

    public static String getChatCompletion(String prompt,String model, String sessionId,Decimal temperature){
        //Prepare api call
        //String model = 'gpt-3.5-turbo';
        system.debug('ESTOY USANDO EL MODELO:'+ model);
        String endpoint = 'https://api.openai.com/v1/chat/completions';
        String method = 'POST';
        String accessToken = ACCESS_TOKEN;
        //Get body with added new prompt
        String body = getRequestBodyWithNewPrompt(prompt,sessionId,model,temperature);
        //Make the call
        system.debug('REQUEST BODY');
        system.debug(body);
        HttpResponse res = apiCaller(endpoint, body, method, accessToken);
        String promptResponse = handleChatCompletionResponse(res,sessionId);
     
        //If condition meets, Create Prompt record and increase last index
        if(promptResponse != ''){
            Session__c session= SessionService.getSession(sessionId);
            insert new Prompt__c(Content__c = prompt , Response__c = promptResponse, Session__c = session.Id , Order__c = session.LastPromptIndex__c);
            session.LastPromptIndex__c++;
            update session;
        }

        
        return promptResponse;
    }

    //Deprecated by 3.5gpt-turbo fine-tuning
    /*public static String getSingleCompletion(String prompt,Decimal temperature,String model){
        String endpoint = 'https://api.openai.com/v1/completions';
        String method = 'POST';
        String accessToken = ACCESS_TOKEN;

        String body = '{"model": "'+model+'","prompt": "'+parsePrompt(prompt)+'","max_tokens": 1500,"temperature": '+temperature+', "stop":"###"}';
        HttpResponse res = apiCaller(endpoint, body, method, accessToken);
        String singleCompletion = handleSingleCompletionResponse(res);

        return singleCompletion;
    }*/

    public static String retrieveFineTunedModel(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.openai.com/v1/fine-tunes'); 
        req.setMethod('GET');
        req.setHeader('Authorization','Bearer '+ ACCESS_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> data = (List<Object>) responseBody.get('data');
            List<String> models = new List<String>();
            for(Object obj : data){
                Map<String,Object> fineTunedModelMap = (Map<String,Object>) obj;
                models.add((String)fineTunedModelMap.get('fine_tuned_model'));
            }
            Map<String,Object> data2 = (Map<String,Object>) data[0];
            system.debug(data2.get('fine_tuned_model'));
            system.debug(data);
            
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());
                throw new CustomException('Error->'+res.getStatus());   
            }
        return 'Ready';
    }
    public static String parsePrompt(String prompt){
        String parsedPrompt = '';
        if(prompt!= null){
            parsedPrompt= prompt.replaceAll('\n', ' ');
            parsedPrompt= parsedPrompt.replaceAll('"', '\'');
            parsedPrompt= parsedPrompt.replaceAll('\'', '');
            
        }
        return parsedPrompt;
    }
    /*public static void upsertContextPrompts(List<String> contextPrompts, Id sessionId){
        if(!contextPrompts.isEmpty()){
            List<Prompt__c> contextPromptsFromQuery = [SELECT Content__c FROM Prompt__c WHERE Type__c = 'Context' AND Session__c =: sessionId];
            List<String> contextPromptsContent = new List<String>();
            List<Prompt__c> promptsToInsert = new List<Prompt__c>();
            for(Prompt__c contextPrompt : contextPromptsFromQuery){
                contextPromptsContent.add(contextPrompt.Content__c);
            }
            for(String prompt : contextPrompts){
                if(!contextPromptsContent.contains(prompt)){
                    promptsToInsert.add(new Prompt__c(Content__c = prompt, Response__c = '', Type__c = 'Context', Session__c = sessionId));
                }
            }
            insert promptsToInsert;
        }
        
    }*/

    class CustomException extends Exception{}
}