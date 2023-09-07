public with sharing class Utils {
    public static String getApiKey(){
       return Open_Ai__c.getInstance().Api_Key__c;
    }
}