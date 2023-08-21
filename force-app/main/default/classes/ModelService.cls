public with sharing class ModelService {
    static final String ACCESS_TOKEN = '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';


    //POST https://api.openai.com/v1/files
    public static void uploadDatasetFile(){
    }
    
     //GET https://api.openai.com/v1/files
    public static String getDatasetIdByName(String fileName){
        String endpoint = 'https://api.openai.com/v1/files';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);

        String datasetFileId = '';
        if(res.getStatusCode()== 200){
            Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> data = ( List<Object>) response.get('data');
            for(Object obj : data ){
                Map<String,Object> file =  (Map<String,Object>) obj;
                if(file.get('filename') == filename){
                    datasetFileId = String.valueOf(file.get('id'));
                }
            }   
        }

        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }

        return datasetFileId;
    }
    

    //POST https://api.openai.com/v1/fine-tunes
    public static String createFineTune(String datasetId, String baseModel){
        String endpoint = 'https://api.openai.com/v1/fine-tunes';
        String method = 'POST';
        String body = '{"training_file:"'+datasetId+'" , "model":"'+baseModel+'"}';
        system.debug(body);
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);

        String fineTuneId = '';

        if(res.getStatusCode() == 200){
            Map<String,Object> fineTunePropsByName = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            system.debug(fineTunePropsByName);
            fineTuneId = String.valueOf(fineTunePropsByName.get('id')); 
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }

        return fineTuneId;
    }

    public static String getFineTuneId(String fineTuneName){
        String endpoint = 'https://api.openai.com/v1/fine-tunes';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);
    
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
        String endpoint = 'https://api.openai.com/v1/fine-tunes';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);
    
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
    
    //GET https://api.openai.com/v1/fine-tunes/{fine_tune_id}/events
    //Here we get job status messages to view if model's training finished.
    public static List<String> getFineTuneJobEventMessages(String fineTuneId){
        String endpoint = 'https://api.openai.com/v1/fine-tunes/'+fineTuneId+'/events';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);

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