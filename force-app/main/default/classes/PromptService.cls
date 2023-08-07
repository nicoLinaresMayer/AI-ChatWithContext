public with sharing class PromptService {
    public static String addPromptToChat(String prompt,Id sessionId){
        final string ENDPOINT = 'https://api.openai.com/v1/chat/completions';
        final string ACCESS_TOKEN = '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';
        Session__c session= SessionService.getSession(sessionId);
        String body = addNewPromptToRequestBody(prompt,sessionId);
    

        // Set HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT); 
        req.setMethod('POST');
        req.setHeader('Authorization','Bearer '+ ACCESS_TOKEN);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        String responseContent = '';


        //  handle response
        if (res.getStatusCode() == 200) {
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> choicesList = (List<Object>) responseBody.get('choices');
            Map<String, Object> firstChoice = (Map<String, Object>) choicesList[0];
            Map<String, Object> messageMap = (Map<String, Object>) firstChoice.get('message');
            responseContent = (String) messageMap.get('content');

            //Create Prompt record
            if(responseContent != ''){
                createPromptRecord(prompt, responseContent, sessionId, Integer.valueOf(session.LastPromptIndex__c));
            }
            
            //Increase last index for the next prompt record
            session.LastPromptIndex__c++;
            update session;
            
        } 
        else {
                System.debug('Callout fail. Error code : ' + res.getStatusCode());
                System.debug('Error message: ' + res.getStatus());
            }

        return responseContent;
    }

    public static String addNewPromptToRequestBody(String prompt,Id sessionId){
        prompt = parsePrompt(prompt);
        List<String> messagesList = SessionService.retrieveChatMessages(sessionId);
        messagesList.add('{"role": "user", "content": "'+prompt+'"}');
        String messages = String.join(messagesList, ',');
        Integer index = 0;
        
        String body = '{"model": "gpt-3.5-turbo","messages": ['+messages+'],"temperature": 1.2}';
        //Mando el prompt
        return body;

    }

    public static String parsePrompt(String prompt){
        prompt= prompt.replaceAll('\n', ' ');
        prompt= prompt.replaceAll('"', '\'');
        prompt= prompt.replaceAll('\'', '');
        return prompt;
    }
    public static void createPromptRecord(String prompt, String response, Id sessionId, Integer LastPromptIndex){
        insert new Prompt__c(Content__c = prompt, Response__c = response, Session__c = sessionId, Order__c = LastPromptIndex);
    }

}