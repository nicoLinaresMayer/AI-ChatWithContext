public with sharing class DocumentController {
   @AuraEnabled
    public static List<Object> getDocumentsByType(String documentType){
        List<Object> documents = new List<Object>();
        try{
            documents = DocumentService.getDocumentsByType(documentType);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return documents;
    }

    @AuraEnabled
    public static Map<String, String> getDocumentSectionsById(String documentId, String documentType){
        Map<String, String> documentSections = new Map<String, String>();
            try{
                documentSections = DocumentService.getDocumentSectionsById(documentId,documentType);
            }
            catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

            return documentSections;
        }

    @AuraEnabled
    public static void updateDocument(String documentId, String documentType, String fieldToUpdate, String response){
        DocumentService.updateDocument(documentId, documentType, fieldToUpdate,response);
    }
}





