/** * File Name: Milestone1_Security_Utility_Test.apxc
* Description : Test Class for Milestone1_Security_Utility.apxc
* Copyright : salesforce.com, Inc. (c) 2016
* * @author : Shae Selix
* Modification Log =============================================================== 
Ver Date Author Modification --- ---- ------ -------------
* */ 

@isTest
public class Milestone1_Security_Utility_Test {
    
    @isTest
    static void testAdminUser()
    {
        User u = Milestone1_Security_Utility.getTestAdmin();
		Profile p = 
    		[SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];
		System.assertEquals('System Administrator', p.Name);
    }
    
    @isTest
    static void testReadUser()
    {
        User u = Milestone1_Security_Utility.getTestReadUser();
		Profile p = 
    		[SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];
		System.assertEquals('Read Only', p.Name);
    }
    
    @isTest
    static void testChatterUser()
    {
        User u = Milestone1_Security_Utility.getTestChatterUser();
		Profile p = 
    		[SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];
		System.assertEquals('Chatter External User', p.Name);
    }
    
    @isTest
    static void testCanCreateAndUpdateFields()
    {
        User u = Milestone1_Security_Utility.getTestAdmin();
        Account a = new Account(Name = 'Test Account', Description = 'Test Description');
        System.runAs(u) {
            // Test FLS Createable
            Boolean fieldsCreateable = True;
            try {
                Milestone1_Security_Utility.oneRecordFieldCreateable(
                    a, Account.SObjectType.getDescribe());
            } catch(Milestone1_Exception e) {
                fieldsCreateable = False;
            }
            System.assert(fieldsCreateable);
            // Test FLS Updateable
            Boolean fieldsUpdateable = True;
            try {
                Milestone1_Security_Utility.fieldUpdateable(
                    Account.Description.getDescribe());
            } catch(Milestone1_Exception e) {
                fieldsUpdateable = False;
            }
            System.assert(fieldsUpdateable);
        }
    }
    
    @isTest
    static void testCannotCreateOrUpdateFields()
    {
        User u = Milestone1_Security_Utility.getTestReadUser();
        Account a = new Account(Name = 'Test Account', Description = 'Test Description');
        System.runAs(u) {
            // Test FLS Createable
            Boolean fieldsCreateable = True;
            try {
                Milestone1_Security_Utility.oneRecordFieldCreateable(
                    a, Account.SObjectType.getDescribe());
            } catch(Milestone1_Exception e) {
                fieldsCreateable = False;
            }
            System.assert(!fieldsCreateable);
            // Test FLS Updateable
            Boolean fieldsUpdateable = True;
            try {
                Milestone1_Security_Utility.fieldUpdateable(
                    Account.Description.getDescribe());
            } catch(Milestone1_Exception e) {
                fieldsUpdateable = False;
            }
            System.assert(!fieldsUpdateable);
        }
    }
    
    @isTest
    static void testCanReadFields()
    {
        User u = Milestone1_Security_Utility.getTestAdmin();
        System.runAs(u) {
            Boolean canAccess = Milestone1_Security_Utility.fieldsAllAccess(
                Case.SObjectType.getDescribe(),
                new Set<String>{'account', 'description'});
        	System.assert(canAccess);
        }
    }
    
    @isTest
    static void testCannotReadFields()
    {
        User u = Milestone1_Security_Utility.getTestReadUser();
        System.runAs(u) {
            Boolean canAccess = Milestone1_Security_Utility.fieldsAllAccess(
                Case.SObjectType.getDescribe(),
                new Set<String>{'account', 'businesshoursid'});
        	System.assert(!canAccess);
        }
	}
    
}