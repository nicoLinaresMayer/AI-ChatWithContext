public with sharing class Utils {
    public static String getApiKey(){
       return Open_Ai__c.getInstance().Api_Key__c;
    }

    public static HttpResponse apiCaller(String endpoint, String body, String method){
        // Set HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Authorization','Bearer '+ getApiKey());
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        if(body!=''){
            req.setBody(body);
        }
        
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }
}