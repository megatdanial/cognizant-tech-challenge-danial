/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ContactControllerTest {

    @IsTest
    static void testCheckPhone() {
        // Create a test contact with a phone number
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Phone = '6512345678',
            MailingPostalCode = '123456',
            Support_Option__c = 'Option 1'
        );
        insert testContact;

        Test.startTest();
        // Call the checkPhone method
        String contactId = ContactController.checkPhone('6512345678');
        Test.stopTest();

        // Verify the contact ID is returned
        System.assertNotEquals(null, contactId, 'Contact ID should be returned');
        System.assertEquals(testContact.Id, contactId, 'Returned Contact ID should match the inserted contact');
    }

    @IsTest
    static void testCreateContact() {
        Contact newContact = new Contact(
            FirstName = 'New',
            LastName = 'User',
            Phone = '6512345678',
            MailingPostalCode = '123456',
            Support_Option__c = 'Option 1'
        );

        Test.startTest();
        ContactController.createContact(newContact);
        Test.stopTest();

        // Verify the contact was created
        Contact createdContact = [SELECT Id, FirstName, LastName, Phone FROM Contact WHERE Id = :newContact.Id];
        System.assertEquals('New', createdContact.FirstName, 'First Name should be New');
        System.assertEquals('User', createdContact.LastName, 'Last Name should be User');
        System.assertEquals('6512345678', createdContact.Phone, 'Phone should be 6512345678');
    }

    @IsTest
    static void testUpdateContact() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Phone = '6512345678',
            MailingPostalCode = '123456',
            Support_Option__c = 'Option 1'
        );
        insert testContact;

        testContact.MailingPostalCode = '654321';

        Test.startTest();
        ContactController.updateContact(testContact);
        Test.stopTest();

        // Verify the contact was updated
        Contact updatedContact = [SELECT Id, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('654321', updatedContact.MailingPostalCode, 'MailingPostalCode should be updated');
    }

    @IsTest
    static void testCheckSupportOption() {

        // Create and insert a test contact with a support option
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Phone = '6512345678',
            MailingPostalCode = '123456',
            Support_Option__c = 'Option 1'
        );
        insert testContact;

        // Create and insert Grant_Disbursed__c records
        Grant_Disbursed__c grant1 = new Grant_Disbursed__c(
            Grant_Applicant__c = testContact.Id,
            Disbursed_Amount__c = 300,
            Grant_is_disbursed__c = true
        );
        Grant_Disbursed__c grant2 = new Grant_Disbursed__c(
            Grant_Applicant__c = testContact.Id,
            Disbursed_Amount__c = 300,
            Grant_is_disbursed__c = false
        );
        insert grant1;
        insert grant2;

        Test.startTest();
        // Call the checkSupportOption method
        Boolean isSuccess = ContactController.checkSupportOption(testContact.Id, 'Option 2');
        Test.stopTest();

        // Verify the result
        System.assertEquals(true, isSuccess, 'checkSupportOption should return true');
    }

    @IsTest
    static void testCheckSupportOptionFailure() {

        // Create and insert a test contact with a support option
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Phone = '6512345678',
            MailingPostalCode = '123456',
            Support_Option__c = 'Option 1'
        );
        insert testContact;

        // Create and insert Grant_Disbursed__c records
        Grant_Disbursed__c grant1 = new Grant_Disbursed__c(
            Grant_Applicant__c = testContact.Id,
            Disbursed_Amount__c = 2000,
            Grant_is_disbursed__c = true
        );
        Grant_Disbursed__c grant2 = new Grant_Disbursed__c(
            Grant_Applicant__c = testContact.Id,
            Disbursed_Amount__c = 300,
            Grant_is_disbursed__c = false
        );
        insert grant1;
        insert grant2;

        Test.startTest();
        // Call the checkSupportOption method
        Boolean isSuccess = ContactController.checkSupportOption(testContact.Id, 'Option 2');
        Test.stopTest();

        // Verify the result
        System.assertEquals(false, isSuccess, 'checkSupportOption should return false');
    }
}
