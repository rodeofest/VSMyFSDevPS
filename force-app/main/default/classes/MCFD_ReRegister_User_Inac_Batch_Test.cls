/**************************************************************************************
Function        : Test Class for covering the code for - MCFD_ReRegister_User_Inactivator_Batch

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                20 OCT 2017             Original Version
* ----------------------------------------------------------------------------                 
* Rosario Lopez				08/06/2018				Updated version
*************************************************************************************/
@isTest(SeeAllData=false)
public class MCFD_ReRegister_User_Inac_Batch_Test{
    
    @testSetup
    static void setup() {
        Account objAccount1=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount1;
        Contact objContact1 = new Contact();
        Profile objProfile1=TestDataFactory.getProfile('System Administrator');
        User objUserAdmin = TestDataFactory.createUser(objContact1, objProfile1, 'standarduser@testorg.com', '');
        insert objUserAdmin;
        
        Account objAccount2=TestDataFactory.createAccount('BCAccount');
        insert objAccount2;
        Contact objContact2 = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount2.Id, '', 'Deepak');
        insert objContact2;
        Profile objProfile2=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objcommUser = TestDataFactory.createUser(objContact2, objProfile2, 'standarduser2@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objcommUser;
    }
    
    
    public static testMethod void test_Reregistered_InactivateUsers() {  
        
        Test.startTest();  
         User objUserAdmin = [SELECT id FROM User where email = 'standarduser@testorg.com' Limit 1];
        System.RunAs(objUserAdmin) {
            User objcommUser = [SELECT id, MCFD_Deactivation_Reason__c, FederationIdentifier, MCFD_Old_FederationIdentifier__c, MCFD_Ready_to_be_Inactivated__c, 
                                IsActive FROM User Where email = 'standarduser2@testorg.com' LIMIT 1];
            
            objcommUser.MCFD_Deactivation_Reason__c = 'Re-Registration';
            objcommUser.MCFD_Old_FederationIdentifier__c = objcommUser.FederationIdentifier;
            objcommUser.FederationIdentifier = null;
            objcommUser.MCFD_Ready_to_be_Inactivated__c = true;
            objcommUser.IsActive = true;
            Update objcommUser;
            
            System.assertEquals(true, objcommUser.IsActive);
            System.assertEquals('Re-Registration', objcommUser.MCFD_Deactivation_Reason__c);
            System.assertNotEquals(null, objcommUser.MCFD_Old_FederationIdentifier__c);
            System.assertEquals(null, objcommUser.FederationIdentifier); 
            System.assertEquals(true, objcommUser.MCFD_Ready_to_be_Inactivated__c ); 
            Database.executeBatch(new MCFD_ReRegister_User_Inactivator_Batch());           
        }
        Test.StopTest();
    }  
    
}