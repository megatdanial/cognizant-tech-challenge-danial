public with sharing class ContactTriggerHelper {

    public static void createGrantDisbursed(List<Contact> newCons) {
    
        List<Support_Option__mdt> metadataRecords = [SELECT MasterLabel, Fund__c, Period__c FROM Support_Option__mdt];
        Map<String, List<Decimal>> supportOptionsMap = new Map<String, List<Decimal>>();
        List<Grant_Disbursed__c> grantRecordList = new List<Grant_Disbursed__c>();
        Map<String,String> consWithOption = new Map<String,String>();
        Map<String,Decimal> consWithSalary = new Map<String,Decimal>();

        for(Support_Option__mdt option: metadataRecords){
            List<Decimal> num = new List<Decimal>();
            num.add(option.Fund__c);
            num.add(option.Period__c);
            supportOptionsMap.put(option.MasterLabel,num);
        }

        for (Contact con: newCons){
            consWithOption.put(con.Id,con.Support_Option__c);
            consWithSalary.put(con.Id,con.Monthly_Income__c);
        }

        for (String key : consWithOption.keySet()) {
            Date today = Date.today();
            String val = consWithOption.get(key);

            if(consWithSalary.get(key) < 2000){
                for (Integer i=0; i<supportOptionsMap.get(val)[1]; i++){
                
                    Integer plusOne = i+1;
                    Integer nextMonth = today.month() + plusOne == 13 ? 1 : today.month() + plusOne;
                    Integer year = today.month() + plusOne == 13 ? today.year() + 1 : today.year();
    
                    Grant_Disbursed__c gd = new Grant_Disbursed__c(
                        Grant_Applicant__c=key,
                        Disbursed_Amount__c=supportOptionsMap.get(val)[0],
                        Disbursed_Date__c=Date.newInstance(year, nextMonth, 1)
                    );
    
                    grantRecordList.add(gd);
                }
            }
            
        }

        if(!grantRecordList.isEmpty()){
            try{
                insert grantRecordList;
            } catch (DmlException e) {
                System.debug('Error inserting grant disbursements: ' + e.getMessage());
            }
        }
    }
}