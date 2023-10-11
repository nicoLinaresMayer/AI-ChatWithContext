public with sharing class PromptService {
    static final String ACCESS_TOKEN = Utils.getApiKey();
    
    public static String handleChatCompletionResponse(HttpResponse res){
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

    public static String getRequestBodyWithNewPrompt(String incomingPrompt,Id sessionId, String model,Decimal temperature){
        incomingPrompt = parsePrompt(incomingPrompt);
        List<Prompt__c> sessionPromptsList = SessionService.retrieveSessionPrompts(sessionId);
        List<Prompt__c> contextPromptsList = SessionService.retrieveContextPrompts(sessionId);

        List<String> messagesList = new List<String>();
        for (Prompt__c prompt : contextPromptsList) {
            messagesList.add('{"role": "system", "content": "'+parsePrompt(prompt.Content__c)+'"}');
        }
        for (Prompt__c prompt : sessionPromptsList) {
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
        String endpoint = 'https://api.openai.com/v1/chat/completions';
        String method = 'POST';
        String accessToken = ACCESS_TOKEN;
        //Get body with added new prompt
        String body = getRequestBodyWithNewPrompt(prompt,sessionId,model,temperature);
        //Make the call
        system.debug('REQUEST BODY');
        system.debug(body);
        HttpResponse res = Utils.apiCaller(endpoint, body, method);
        String completion = handleChatCompletionResponse(res);
       
        return completion;
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
            parsedPrompt= prompt.replaceAll('\n', '\\\\n');
            parsedPrompt= parsedPrompt.replaceAll('"', '\\\\"');       
        }
        return parsedPrompt;
    }

    class CustomException extends Exception{}
}