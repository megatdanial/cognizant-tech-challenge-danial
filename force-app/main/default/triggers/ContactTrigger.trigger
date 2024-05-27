trigger ContactTrigger on Contact (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContactTriggerHandler.onAfterInsert(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUpdate){
            ContactTriggerHandler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    else if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ContactTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }

}