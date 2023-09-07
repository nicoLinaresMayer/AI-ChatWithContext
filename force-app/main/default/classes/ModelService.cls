public with sharing class ModelService {
    static final String ACCESS_TOKEN = Utils.getApiKey();

    //POST https://api.openai.com/v1/files
    public static void uploadDatasetFile(String fileName,String jsonContent){
        String accessToken = ACCESS_TOKEN;
        String endpoint = ' https://api.openai.com/v1/files';
        String message ='';

        //{"messages": [{"role": "system", "content": "asd1"},{"role": "system", "content": "asd2"},{"role": "system", "content": "asd3"},{"role": "system", "content": "us"},{"role": "system", "content": "as"}]}


        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'multipart/form-data; boundary=boundary');

        String boundary = 'boundary';
        String body = '';
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="purpose"\r\n\r\n';
        body += 'fine-tune';
        body += '\r\n';

        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="file"; filename="'+fileName+'"\r\n';
        body += 'Content-Type: application/json\r\n\r\n';
        //Acá contenido Jsonl
        body += jsonContent;
        body += '\r\n';

        body += '--' + boundary + '--';

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
        } else {
            System.debug(res.getStatus());
        }
    }
    public static String formatDatasetFile(List<String> rows){
        //rows = new List<String>{'{"User":"Usercontent","System":"Context2\\nContext1","Assistant":"AssitantContent","Id":"row_wzwww"}'};
        //rows.add('{"User":"userContent2","System":"Context3\\nContext4","Assistant":"assistantcontent2","Id":"row_wzwww"}');
        

        List<String> proccessedRows = new List<String>();
        for(String row : rows){
            //cada row es : {User: 'asdasd', System: 'Contexto linea 1\nContexto linea 2\ncontexto linea 3', Assistant: 'dasdas', Id: 'row_wzwww'}

            Map<String, Object> rowMapped = (Map<String, Object>) JSON.deserializeUntyped(row);
            List<String> systemLine = new List<String>();
            for(String line : String.valueOf(rowMapped.get('System')).split('\n')){
            systemLine.add('{"role": "system", "content": "'+line+'"}'); 
            }
            systemLine.add('{"role": "user", "content": "'+PromptService.parsePrompt(String.valueOf(rowMapped.get('User')))+'"}');
            systemLine.add('{"role": "assistant", "content": "'+PromptService.parsePrompt(String.valueOf(rowMapped.get('Assistant')))+'"}');
            String joinedString = String.join(systemLine,',');
            String rowJson = '{"messages": ['+joinedString+']}';
            proccessedRows.add(rowJson);
        }
       
        String proccessedJson = String.join(proccessedRows,'\n');
        proccessedJson+= '\n';
        system.debug(proccessedJson);
        return proccessedJson;
        /*'{"messages": [{"role": "system", "content": "La empresa es Cloudgaia, tiene 400 empleados, mas de 600 certificaciones. Radica en San Isidro, EEUU y Reino Unido"},{"role":"user","content":"Cual es la empresa?"},{"role":"assistant","content":"Cloudgaia"}]}'*/

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
    
    //old POST https://api.openai.com/v1/fine-tunes
    //new POST https://api.openai.com/v1/fine_tuning/jobs
    public static String createFineTune(String datasetId, String baseModel, String suffixName){
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs';
        String method = 'POST';
        String body = '{"training_file":"'+datasetId+'" , "model":"'+baseModel+'" , "suffix":"'+suffixName+'"}';
        system.debug(body);
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);
        
        String fineTuneId = '';

        if(res.getStatusCode() == 200){
            Map<String,Object> fineTunePropsByName = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            fineTuneId = String.valueOf(fineTunePropsByName.get('id')); 
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }

        return fineTuneId;
    }

    public static void createModelRecord(String datasetId,String baseModel,String suffixName, String fineTuneId){
        system.debug('FINE TUNE ID FOR CREATE MODEL RECORD: ' + fineTuneId);
        Model__c parentModel = new Model__c();
        try{
            parentModel = [SELECT Id FROM Model__c WHERE Name=:baseModel]; 
        }
        catch(Exception e){
            parentModel = null;
        }
        if(fineTuneId !=''){
           Database.insert(new Model__c(Name= suffixName,Model_Id__c = fineTuneId,parentModel__c = parentModel?.Id,Dataset_Id__c = datasetId));
        }
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
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs';
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

    public static List<Model__c> getModels(){
        return [SELECT Id,Name,Model_Id__c,Dataset_id__c FROM Model__c];
    }
    public static List<String> listDatasetFiles (){
        String endpoint = 'https://api.openai.com/v1/files';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);
    
        List<String> datasetFiles = new List<String>();
        if(res.getStatusCode() == 200){
            Map<String,Object> datasetProps = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> datasetData= (List<Object>) datasetProps.get('data');
            
            for(Object obj  : datasetData){
                Map<String,Object> objMap = (Map<String,Object>) obj;
                datasetFiles.add((String)objMap.get('filename'));   
                
            }
        }
        else{
            system.debug('Error: ' + res.getStatus() + ' --- Code: '+res.getStatusCode());
        }
        return datasetFiles;
    }
//GET https://api.openai.com/v1/fine_tuning/jobs/{fine_tuning_job_id}
    public static String getModelNameById(String fineTuneId){
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs/'+fineTuneId;
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = PromptService.apiCaller(endpoint,body,method, ACCESS_TOKEN);
    
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
    
    //GET https://api.openai.com/v1/fine-tunes/{fine_tune_id}/events
    //Here we get job status messages to view if model's training is finished.
    public static List<String> getFineTuneJobEventMessages(String fineTuneId){
        
        String endpoint = 'https://api.openai.com/v1/fine_tuning/jobs/'+fineTuneId+'/events';
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