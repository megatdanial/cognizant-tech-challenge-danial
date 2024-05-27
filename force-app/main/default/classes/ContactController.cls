public without sharing class ContactController {
    @AuraEnabled
    public static String checkPhone(String phone) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Phone = :phone LIMIT 1];
        return contacts[0].Id;
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
}