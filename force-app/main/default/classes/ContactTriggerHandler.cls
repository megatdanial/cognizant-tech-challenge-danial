public class ContactTriggerHandler {
    public static void onAfterInsert(List<Contact> newList,
                                      Map<Id, Contact> newMapItems,
                                      List<Contact> oldList,
                                      Map<Id, Contact> oldMapItems) { 
                                        ContactTriggerHelper.createGrantDisbursed(newList);

  }
  public static void onAfterUpdate(List<Contact> newList,
                                      Map<Id, Contact> newMapItems,
                                      List<Contact> oldList,
                                      Map<Id, Contact> oldMapItems) { 
                                        

  }
}