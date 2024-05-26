public without sharing class ContactController {
    @AuraEnabled
    public static Boolean checkPhone(String phone) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Phone = :phone LIMIT 1];
        return contacts.size() > 0;
    }

    @AuraEnabled
    public static void createContact(Contact contact) {
        insert contact;
    }
}