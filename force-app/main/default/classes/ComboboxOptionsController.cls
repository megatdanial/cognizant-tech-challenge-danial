public without sharing class ComboboxOptionsController {
    @AuraEnabled(cacheable=true)
    public static List<Support_Option__mdt> getComboboxOptions() {
        List<Support_Option__mdt> metadataRecords = [SELECT MasterLabel, Fund__c, Period__c FROM Support_Option__mdt];
        List<Map<String,String>> options = new List<Map<String,String>>();
        for (Support_Option__mdt record : metadataRecords) {
            Map<String,String> option = new Map<String,String>();
            option.put(record.MasterLabel,record.MasterLabel + ': SGD ' + record.Fund__c + ' per month for ' + record.Period__c + ' months');
            options.add(option);
        }
        return metadataRecords;
    }

}
