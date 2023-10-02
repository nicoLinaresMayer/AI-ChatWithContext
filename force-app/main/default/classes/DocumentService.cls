public with sharing class DocumentService {
    
    public static List<SObject> getDocumentsByType(String documentType){
    
        List<SObject> documents = new List<SObject>();
        String objectApiName = getObjectApiNameByType(documentType);
        

        for(SObject doc : Database.query('SELECT ID,Name FROM '+ objectApiName)){
            documents.add(doc);
        }
        return documents;
    }

    public static Map<String, String> getDocumentSectionsById(String documentId, String documentType){
        String objectApiName = getObjectApiNameByType(documentType);
        Map<String, String> customFieldLabels = new Map<String, String>();
        

            List<Schema.DescribeSObjectResult> objectDescribe = Schema.describeSObjects(new List<String>{objectApiName});
            Schema.DescribeSObjectResult objDesc = objectDescribe[0];
            
            for (Schema.SObjectField field : objDesc.fields.getMap().values()) {
                if (field.getDescribe().isCustom()) {
                    String fieldName = field.getDescribe().getName();
                    String fieldLabel = field.getDescribe().getLabel();
                    customFieldLabels.put(fieldName, fieldLabel);
                }
            }

        return customFieldLabels;
    }
    
    public static String getObjectApiNameByType(String documentType){
        String objectApiName = '';
        switch on documentType {
            when  'OnePager'{
                objectApiName = 'WhitePaper__c';
            }
            when  'Deck'{
                objectApiName = 'Deck__c';
            }
            when  'WhitePaper'{
                objectApiName = 'WhitePaper__c';
            }
        }
        return objectApiName;
    }

    public static void updateDocument(String documentId, String documentType, String fieldToUpdate, String response){
        String query = 'SELECT Id,'+fieldToUpdate+' FROM '+getObjectApiNameByType(documentType)+ ' WHERE ID=\''+documentId+'\'';

        SObject obj= Database.query(query) ;
        if (obj.getSObjectType().getDescribe().fields.getMap().containsKey(fieldToUpdate)) {

            obj.put(fieldToUpdate, response); 
            update obj;
        }


    }
}