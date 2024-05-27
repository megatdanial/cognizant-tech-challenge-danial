public without sharing class ContactController {

    @AuraEnabled
    public static String checkPhone(String phone) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Phone = :phone LIMIT 1];
        String cid;
        if(!contacts.isEmpty()){
            cid=contacts[0].Id;
        }
        return cid;
    }

    @AuraEnabled
    public static void createContact(Contact contact) {
        try{
            insert contact;
        } catch (DmlException e) {
            System.debug('Error inserting contact: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateContact(Contact contact) {
        try{
            update contact;
        } catch (DmlException e) {
            System.debug('Error updating contact: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkSupportOption(String cid, String newOpt) {
        List<Support_Option__mdt> metadataRecords = [SELECT MasterLabel, Fund__c, Period__c FROM Support_Option__mdt];
        Contact con = [SELECT Id, Support_Option__c FROM Contact WHERE Id= :cid LIMIT 1][0];
        List<Grant_Disbursed__c> gdList = [SELECT Disbursed_Amount__c, Grant_is_disbursed__c, Grant_Applicant__c FROM Grant_Disbursed__c WHERE Grant_Applicant__c=:cid ];
        List<Grant_Disbursed__c> gdListToDelete = new List<Grant_Disbursed__c>();
        Decimal currentAmt = 0;
        Decimal newAmt = 0;
        Decimal disbursedAmt = 0;
        Boolean isSuccess;


        for (Support_Option__mdt record : metadataRecords) {
            if(record.MasterLabel==con.Support_Option__c){
                currentAmt = record.Fund__c * record.Period__c;
            }
            if(record.MasterLabel==newOpt){
                newAmt = record.Fund__c * record.Period__c;
            }
        }

        for(Grant_Disbursed__c gd : gdList){

            if(gd.Grant_is_disbursed__c==true){
                disbursedAmt += gd.Disbursed_Amount__c;
            }
            else{
                gdListToDelete.add(gd);
            }
        }

        
        if(disbursedAmt!=0 && newAmt!=0){
            if(disbursedAmt>newAmt){
                isSuccess = false;
            }
            else{
                
                isSuccess = true;
            }
        }

        return isSuccess;

    }

}