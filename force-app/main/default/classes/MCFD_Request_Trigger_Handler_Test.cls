/**************************************************************************************
Function        : Test Class for covering the code for - MCFD_Request_Trigger_Handler

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                20 OCT 2017             Original Version
* ----------------------------------------------------------------------------
* Rosario Lopez				08/06/2018				Standards Applied
*************************************************************************************/
@isTest(SeeAllData=false)
public class MCFD_Request_Trigger_Handler_Test {
    
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
    }
    
    public static testMethod void test_validate_ResubmitRequest() {  
        
        Test.startTest();
        User objUser = [SELECT id FROM User where isActive = true Limit 1];
        System.RunAs(objUser) {
            Contact objContact = [SELECT id FROM Contact Limit 1];
            
            Request__c objRequest = new Request__c();
            objRequest.MCFD_Status__c = 'Submission Error';
            objRequest.Primary_Applicant__c = objContact.Id;
            
          //  insert objRequest;
            
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            objRequest.MCFD_Status__c = 'Pending Submission';
          //  update objRequest;
        }
        Test.StopTest();
    }  
}