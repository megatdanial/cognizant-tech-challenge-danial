public without sharing class ComboboxOptionsController {
    @AuraEnabled(cacheable=true)
    public static List<String> getComboboxOptions() {
        List<Support_Option__mdt> metadataRecords = [SELECT MasterLabel, Fund__c, Period__c FROM Support_Option__mdt];
        List<String> options = new List<String>();
        for (Support_Option__mdt record : metadataRecords) {
            options.add(record.MasterLabel + ': SGD ' + record.Fund__c + ' per month for ' + record.Period__c + ' months');
        }
        return options;
    }

}
