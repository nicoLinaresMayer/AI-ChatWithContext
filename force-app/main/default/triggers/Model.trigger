trigger Model on Model__c (after delete) {
    ModelTrigger.onAfterDelete(Trigger.old);
}