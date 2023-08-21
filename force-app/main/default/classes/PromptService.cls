public with sharing class PromptService {
    static final string ACCESS_TOKEN = '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';
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
            system.debug(responseContent);
            
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());   
            }
        
       return responseContent;     
    }
    public static String handleSingleCompletionResponse(HttpResponse res){
        String responseContent = '';
        if (res.getStatusCode() == 200) {
            system.debug(res.getBody());
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> choicesList = (List<Object>) responseBody.get('choices');
            Map<String, Object> firstChoice = (Map<String, Object>) choicesList[0];
            Object responseContent2 = firstChoice.get('text');
            system.debug(responseContent2);
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());  
            }
        
       return responseContent;     
    }

    public static String getRequestBodyWithNewPrompt(String incomingPrompt,Id sessionId, String model,Decimal temperature){
        incomingPrompt = parsePrompt(incomingPrompt);
        List<Prompt__c> promptList = SessionService.retrieveSessionPrompts(sessionId);
        List<String> messagesList = new List<String>();
        for (Prompt__c prompt : promptList) {
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

    public static String getChatCompletion(String prompt,String sessionId,Decimal temperature){
        //Prepare api call
        String model = 'gpt-3.5-turbo';
        String endpoint = 'https://api.openai.com/v1/chat/completions';
        String method = 'POST';
        String accessToken = ACCESS_TOKEN;
        //Get body with added new prompt
        String body = getRequestBodyWithNewPrompt(prompt,sessionId,model,temperature);
        //Make the call
        HttpResponse res = apiCaller(endpoint, body, method, accessToken);
        String chatCompletion = handleChatCompletionResponse(res,sessionId);
     
        //If condition meets, Create Prompt record and increase last index
        if(chatCompletion != ''){
            Session__c session= SessionService.getSession(sessionId);
            createPromptRecord(prompt, chatCompletion, sessionId, Integer.valueOf(session.LastPromptIndex__c));
            session.LastPromptIndex__c++;
            update session;
        }

        
        return chatCompletion;
    }

    public static String getSingleCompletion(String prompt,Decimal temperature,String model){
        String endpoint = 'https://api.openai.com/v1/completions';
        String method = 'POST';
        String accessToken = ACCESS_TOKEN;

        String body = '{"model": "'+model+'","prompt": "'+parsePrompt(prompt)+'","max_tokens": 2000,"temperature": '+temperature+'}';
        HttpResponse res = apiCaller(endpoint, body, method, accessToken);
        String singleCompletion = handleSingleCompletionResponse(res);

        return singleCompletion;
    }
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
    public static void createPromptRecord(String prompt, String response, Id sessionId, Integer LastPromptIndex){
        insert new Prompt__c(Content__c = prompt, Response__c = response, Session__c = sessionId, Order__c = LastPromptIndex);
    }

    class CustomException extends Exception{}
}