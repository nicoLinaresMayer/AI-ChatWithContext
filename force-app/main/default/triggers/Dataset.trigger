trigger Dataset on Dataset__c (after delete) {
    DatasetTrigger.onAfterDelete(Trigger.old);
}