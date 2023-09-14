public with sharing class ModelService {
    class HttpException extends Exception{}
    static final String ACCESS_TOKEN = Utils.getApiKey();

    public static String createFineTune(String datasetId, String baseModel, String suffixName){
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs';
        String method = 'POST';
        suffixName = suffixName.substring(0, Math.min(suffixName.length(), 18));
        String body = '{"training_file":"'+datasetId+'" , "model":"'+baseModel+'" , "suffix":"'+suffixName+'"}';
        system.debug(body);
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);
        
        String result = '';

        if(res.getStatusCode() == 200){
            Map<String,Object> fineTunePropsByName = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            result = String.valueOf(fineTunePropsByName.get('id')); 
        }
        else{
            result= 'Error: ' + res.getStatus() + '  -  Code: '+res.getStatusCode();
        }

        return result;
    }

    @future(callout=true)
    public static void deleteModelsFromServer(List<String> modelsIds){
        String apiKey = Utils.getApiKey();
        for(String modelId : modelsIds){
            HttpRequest req = new HttpRequest();
            //ft:gpt-3.5-turbo-0613:personal:newmoedl:7yjxUF5U
            req.setEndpoint('https://api.openai.com/v1/models/'+modelId);
            req.setMethod('DELETE');
            req.setHeader('Authorization','Bearer '+apiKey );
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setTimeout(120000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Model deleted');
            } else {
                throw new HttpException('Error code : '+res.getStatusCode());
            }
        }
    }
    public static void createModelRecord(Dataset__c dataset,String baseModel,String suffixName, String result){
        system.debug('FINE TUNE ID FOR CREATE MODEL RECORD: ' + result);
        Model__c parentModel = new Model__c();
        try{
            parentModel = [SELECT Id FROM Model__c WHERE Name=:baseModel]; 
        }
        catch(Exception e){
            parentModel = null;
        }
        if(result !='' && !result.contains('Error')){
           Database.insert(new Model__c(Name= suffixName,Model_Id__c = result,parentModel__c = parentModel?.Id,Dataset__c = dataset.Id));
        }
    }
    public static String getFineTuneId(String fineTuneName){
        String endpoint = 'https://api.openai.com/v1/fine-tunes';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);
    
        String fineTuneId = '';
        if(res.getStatusCode() == 200){
            Map<String,Object> fineTuneProps = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> fineTuneData = (List<Object>) fineTuneProps.get('data');
            
            for(Object obj  : fineTuneData){
                Map<String,Object> objMap = (Map<String,Object>) obj;
                if( (String)objMap.get('fine_tuned_model') == fineTuneName){
                    fineTuneId = (String) objMap.get('id');
                    break;
                }
            }
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }
        return fineTuneId;
    }

    public static List<String> listFineTunes (){
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);
    
        List<String> fineTunes = new List<String>();
        if(res.getStatusCode() == 200){
            Map<String,Object> fineTuneProps = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> fineTuneData = (List<Object>) fineTuneProps.get('data');
            
            for(Object obj  : fineTuneData){
                Map<String,Object> objMap = (Map<String,Object>) obj;
                fineTunes.add((String)objMap.get('fine_tuned_model'));   
                
            }
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }
        return fineTunes;
    }

    public static List<Model__c> getModels(){
        return [SELECT Id,Name,Model_Id__c FROM Model__c];
    }

    public static String getModelNameById(String fineTuneId){
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs/'+fineTuneId;
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);
    
        String modelNameId = '';
        if(res.getStatusCode() == 200){
            Map<String,Object> fineTuneProps = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            modelNameId = String.valueOf(fineTuneProps.get('fine_tuned_model'));
            
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }
        return modelNameId;
    }
    
    //Here we get job status messages to view if model's training is finished.
    public static List<String> getFineTuneJobEventMessages(String fineTuneId){
        
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs/'+fineTuneId+'/events';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);

        List<String> eventsMessages = new List<String>();
        if(res.getStatusCode() == 200){
            Map<String,Object> jobStatusPropsByName = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            List<Object> jobEventsData = (List<Object>) jobStatusPropsByName.get('data');
          
            for(Object obj: jobEventsData){
                Map<String, Object> objmap = ( Map<String, Object>) obj;
                eventsMessages.add((String)objmap.get('message'));
            }
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }

        return eventsMessages;
    }
}