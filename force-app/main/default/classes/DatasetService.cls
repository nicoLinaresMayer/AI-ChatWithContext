public with sharing class DatasetService {
    class HttpException extends Exception{}
    static final String ACCESS_TOKEN = Utils.getApiKey();

    public static String getDatasetNameById(Id datasetId){
        Dataset__c dataset = [SELECT Name FROM Dataset__c WHERE ID=:datasetId LIMIT 1];
        return dataset.Name;
    }
    public static void uploadDatasetFile(Id datasetId){
        List<String> proccessedRows = formatDataset(datasetId);
        String datasetFile = getDatasetTextFile(proccessedRows);
        String response = uploadFileToOpenAi(getDatasetNameById(datasetId)+ '.jsonl',datasetFile);

        Dataset__c dataset = [SELECT Id,Status__c,filename__c,Id__c FROM Dataset__c WHERE Id=:datasetId];
        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response);
        dataset.Status__c = (String) responseMap.get('status');
        dataset.filename__c = (String) responseMap.get('filename');
        dataset.Id__c = (String) responseMap.get('id');
        update dataset;
    }

    public static string uploadFileToOpenAi(String fileName,String datasetFile){
        String accessToken = ACCESS_TOKEN;
        String endpoint = ' https://api.openai.com/v1/files';
        String message ='';
        String response = '';

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
        body += datasetFile;
        body += '\r\n';

        body += '--' + boundary + '--';

        req.setBody(body);
        system.debug('body->'+body);
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            response = res.getBody();
        } else {
            throw new HttpException('Error code : '+res.getStatusCode());
        }
        return response;
    }
    public static List<String> formatDataset(Id datasetId){
        List<String> rows = new List<String>();
        for(Example__c ex : [SELECT Id,Content__c FROM Example__c WHERE Dataset__c=:datasetId]){
            rows.add(ex.Content__c);
        }
 
        List<String> proccessedRows = new List<String>();
        for(String row : rows){
        
            Map<String, Object> rowMapped = (Map<String, Object>) JSON.deserializeUntyped(row);
            List<String> systemLine = new List<String>();
            for(String line : String.valueOf(rowMapped.get('SystemMsg')).split('__-__')){
            systemLine.add('{"role": "system", "content": "'+PromptService.parsePrompt(line)+'"}'); 
            }
            systemLine.add('{"role": "user", "content": "'+PromptService.parsePrompt(String.valueOf(rowMapped.get('UserMsg')))+'"}');
            systemLine.add('{"role": "assistant", "content": "'+PromptService.parsePrompt(String.valueOf(rowMapped.get('AssistantMsg')))+'"}');
            String joinedString = String.join(systemLine,',');
            String rowJson = '{"messages": ['+joinedString+']}';
            proccessedRows.add(rowJson);
        }
        return proccessedRows;

    }

    public static String getDatasetTextFile(List<String> proccessedRows){
        String proccessedJson = String.join(proccessedRows,'\n');
        proccessedJson+= '\n';
        return proccessedJson;
    }
   
    /*public static String getDatasetIdByName(String fileName){
        String endpoint = 'https://api.openai.com/v1/files';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);

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
    public static List<String> listDatasetFiles (){
        String endpoint = 'https://api.openai.com/v1/files';
        String method = 'GET';
        String body = '';
        Http http = new Http();
        HttpResponse res = Utils.apiCaller(endpoint,body,method);
    
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
    }*/

    public static List<Dataset__c> getDatasets(){
        return [SELECT Id,Name,Id__c FROM Dataset__c];
    }
    public static List<ExampleWrapper> retrieveExamples(Id datasetId){
        List<ExampleWrapper> examplesWrapped = new List<ExampleWrapper>();
        for(Example__c example : [SELECT Id,Content__c FROM Example__c WHERE Dataset__c =:datasetId ORDER BY CreatedDate asc ]){
            system.debug(example.Content__c);
            Map<String,Object> exampleMap = (Map<String,Object>)JSON.deserializeUntyped(example.Content__c);
            examplesWrapped.add(new ExampleWrapper(example.Id,String.valueOf(exampleMap.get('SystemMsg')),String.valueOf(exampleMap.get('UserMsg')),String.valueOf(exampleMap.get('AssistantMsg'))));
        }
        system.debug(examplesWrapped);
        return examplesWrapped; 
    }

    public static void saveExamples(String examplesJson, Id datasetId){
        Map<Id,Example__c> examplesMap = new Map<Id,Example__c>([SELECT Id FROM Example__c]);
        List<Object> objectList = (List<Object>)JSON.deserializeUntyped(examplesJson);
        List<Example__c> examplesToInsert = new List<Example__c>();
        List<Example__c> examplesToUpdate = new List<Example__c>();
        
        for(Object obj : objectList){
            Map<String,Object> objectMap = (Map<String,Object>) obj;
            String exampleId = (String) objectMap.get('Id');
            if(!exampleId.contains('row_') && examplesMap.containsKey(exampleId)){
                Example__c record = examplesMap.get(exampleId);
                record.Content__c = JSON.serialize(obj);
                examplesToUpdate.add(record);
            }
            else{
                system.debug('contains _row');
                examplesToInsert.add(new Example__c(Dataset__c = datasetId, Content__c = JSON.serialize(obj)));
            }
            
        }

        insert examplesToInsert;
        update examplesToUpdate;
        
    }
    @future(callout=true)
    public static void deleteDatasetsFromServer(List<String> datasetsIds){
        String apiKey = Utils.getApiKey();
        for(String datasetId : datasetsIds){
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.openai.com/v1/files/'+datasetId);
            req.setMethod('DELETE');
            req.setHeader('Authorization','Bearer '+apiKey );
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setTimeout(120000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('File deleted');
            } else {
                throw new HttpException('Error code : '+res.getStatusCode());
            }
        }
    }
    
    public class ExampleWrapper{
        @auraEnabled
        public String Id{get;set;}
        @auraEnabled
        public String SystemMsg{get;set;}
        @auraEnabled
        public String UserMsg{get;set;}
        @auraEnabled
        public String AssistantMsg{get;set;}

        public ExampleWrapper(Id Id,String SystemMsg, String UserMsg , String AssistantMsg){
            this.Id = Id;
            this.SystemMsg = SystemMsg;
            this.UserMsg = UserMsg;
            this.AssistantMsg = AssistantMsg;

        }
    }
    
}