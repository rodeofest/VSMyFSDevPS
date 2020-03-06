/************************************************************************************
Function        : test class for MCFD_LoggedInUser

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                16 OCT 2017             Original Version
* ----------------------------------------------------------------------------
* Rosario Lopez				08/06/2018				Standards applied
*************************************************************************************/
@isTest
public class MCFD_LoggedInUser_Test {
        
    @testSetup 
     static void setup() {
        Account objAccount=TestDataFactory.createAccount('BCAccount');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
     }
    
    public static testMethod void getCurrentUser() {
        Test.startTest();
        User objUser = [SELECT id, Email FROM User where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];
        System.RunAs(objUser) {
            MCFD_LoggedInUser obj = new MCFD_LoggedInUser();
            User loggedInUser = MCFD_LoggedInUser.getCurrentUser();
            System.assertNotEquals(Null, loggedInUser);    
        }
        Test.stopTest();
    }
}