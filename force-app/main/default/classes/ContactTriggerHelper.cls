public without sharing class ContactTriggerHelper {

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

    public static void updateNewOption(Map<Id, Contact> newMapCons) {
        Set<Id> conIds = new Set<Id>(newMapCons.keySet());
        List<Support_Option__mdt> metadataRecords = [SELECT MasterLabel, Fund__c, Period__c FROM Support_Option__mdt];
        List<Grant_Disbursed__c> gdList = [SELECT Id, Disbursed_Amount__c, Grant_is_disbursed__c, Grant_Applicant__c FROM Grant_Disbursed__c WHERE Grant_Applicant__c=:conIds ];
        Map<Id,List<Grant_Disbursed__c>> gdMapToDelete = new Map<Id,List<Grant_Disbursed__c>>();
        Map<Id,List<Grant_Disbursed__c>> gdMapToCreate = new Map<Id,List<Grant_Disbursed__c>>();
        Map<Id,Decimal> newAmtMap = new Map<Id,Decimal>();
        Map<Id,Decimal> newPeriodMap = new Map<Id,Decimal>();
        Map<Id,Decimal> disbursedAmtMap = new Map<Id,Decimal>();
        Map<Id,Decimal> disbursedCountMap = new Map<Id,Decimal>();
        

        for(Id id: conIds){
            Decimal newAmt = 0;
            Decimal disbursedAmt = 0;
            Decimal disbursedCount = 0;
            List<Grant_Disbursed__c> gdListToDelete = new List<Grant_Disbursed__c>();
            for (Support_Option__mdt record : metadataRecords) {
                if(record.MasterLabel==newMapCons.get(id).Support_Option__c){
                    newAmt = record.Fund__c * record.Period__c;
                    newAmtMap.put(id,newAmt);
                    newPeriodMap.put(id,record.Period__c);
                }
            }
            system.debug('gdlist: ' + gdList);
            for(Grant_Disbursed__c gd : gdList){
                if(gd.Grant_Applicant__c==id){
                    if(gd.Grant_is_disbursed__c==true){
                        disbursedAmt += gd.Disbursed_Amount__c;
                        disbursedCount++;
                    }
                    else if(gd.Grant_is_disbursed__c==false){
                        gdListToDelete.add(gd);
                    }
                }
            }
            system.debug('to delete: ' + gdListToDelete);
            if(!gdListToDelete.isEmpty()){
                gdMapToDelete.put(id,gdListToDelete);
            }
            disbursedAmtMap.put(id,disbursedAmt);
            disbursedCountMap.put(id,disbursedCount);

        }
        system.debug('newamt: ' + newAmtMap);
        system.debug('disamt: ' + disbursedAmtMap);
        if(!newAmtMap.isEmpty() && !disbursedAmtMap.isEmpty()){
            for(Id id: conIds){
                Decimal newAmt = newAmtMap.get(id);
                Decimal newPeriod = newPeriodMap.get(id);
                Decimal disbursedAmt = disbursedAmtMap.get(id);
                Decimal disbursedCount = disbursedCountMap.get(id);

                Decimal remainingAmt = 0;
                Decimal remainingPeriod = 0;
                Decimal newDisbursedAmt = 0;

                if(disbursedAmt<newAmt && disbursedCount<newPeriod){
                    remainingAmt = newAmt-disbursedAmt;
                    remainingPeriod = newPeriod-disbursedCount;
                    newDisbursedAmt = remainingAmt/remainingPeriod;
                }

                if(remainingPeriod != 0){
                    List<Grant_Disbursed__c> grantRecordList = new List<Grant_Disbursed__c>();
                    Date today = Date.today();
                    for (Integer i=0; i<remainingPeriod; i++){
                
                        Integer plusOne = i+1;
                        Integer nextMonth = today.month() + plusOne == 13 ? 1 : today.month() + plusOne;
                        Integer year = today.month() + plusOne == 13 ? today.year() + 1 : today.year();
        
                        Grant_Disbursed__c gd = new Grant_Disbursed__c(
                            Grant_Applicant__c=id,
                            Disbursed_Amount__c=newDisbursedAmt,
                            Disbursed_Date__c=Date.newInstance(year, nextMonth, 1)
                        );
        
                        grantRecordList.add(gd);
                    }
                    if(!grantRecordList.isEmpty()){
                        gdMapToCreate.put(id,grantRecordList);
                    }

                }

            }
        }
        system.debug(gdMapToDelete);
        system.debug(gdMapToCreate);
        if(!gdMapToDelete.isEmpty() && !gdMapToCreate.isEmpty()){
            system.debug('in to delete create');
            Boolean deleteDone=false;
            for(Id id: gdMapToDelete.keySet()){
                try{
                    delete gdMapToDelete.get(id);
                    deleteDone=true;
                } catch (DmlException e) {
                    System.debug('Error deleting grant disbursements: ' + e.getMessage());
                }

                if(deleteDone){
                    try{
                        insert gdMapToCreate.get(id);
                    } catch (DmlException e) {
                        System.debug('Error inserting grant disbursements: ' + e.getMessage());
                    }
                }
            }
        }
        

    }


}