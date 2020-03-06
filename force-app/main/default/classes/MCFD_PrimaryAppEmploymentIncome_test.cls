/************************************************************************************
Function        : test class for MCFD_PrimaryApplicantEmploymentIncome 

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek                16 May 2017             Original Version
* PDAVE                   31 Oct 2017             Refactoring all test methods 
* Gabriela                08 June 2018            Code standards applied
* Liliana 	 			  20/06/2018   			  Update Methods 
*************************************************************************************/
@isTest(seeAlldata=false)
public class MCFD_PrimaryAppEmploymentIncome_test {
    
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType, 'Intervention Services');
        insert objRequest;
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Income__c objIncome = TestDataFactory.createIncome(objRequest.Id, primAppId);
        MCFD_Employment_Income__c   objEmpIncome = TestDataFactory.createEmploymentIncome(objIncome.Id);
        
        ContactShare conShare = new ContactShare();
        conShare.ContactId = primAppId;
        conShare.UserOrGroupId = objUser.Id;
        conShare.ContactAccessLevel = 'Read';
        conShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert conShare;
        Insert objEmpIncome;
        Insert objIncome;
        
        MCFD_Employment_Income__Share empincShr = new MCFD_Employment_Income__Share();
            empincShr.ParentId = objEmpIncome.Id;
            empincShr.UserOrGroupId = objUser.Id;
            empincShr.AccessLevel = 'Edit';
            empincShr.RowCause = Schema.MCFD_Employment_Income__Share.RowCause.Manual;
            Insert empincShr;
        
        Income__Share incShr = new Income__Share();
            incShr.ParentId = objIncome.Id;
            incShr.UserOrGroupId = objUser.Id;
            incShr.AccessLevel = 'Edit';
            incShr.RowCause = Schema.Income__Share.RowCause.Manual;
            Insert incShr;
        
    }
    
    static testMethod void test_EmploymentIncome() {  
        Test.startTest();
            User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];
            MCFD_Employment_Income__c   objEmpIncome = [SELECT id FROM MCFD_Employment_Income__c LIMIT 1];
        
            System.RunAs(objUser) {
                
                MCFD_PrimaryApplicantEmploymentIncome.getIncome();
                MCFD_Employment_Income__c objEmpInc = MCFD_PrimaryApplicantEmploymentIncome.getIncome();
                List<MCFD_Employment_Income__c> listEmp = new List<MCFD_Employment_Income__c>();
                listEmp.add(objEmpIncome);
                MCFD_PrimaryApplicantEmploymentIncome.primaryApplicantEmpIncomeSave(listEmp);
    
            }
        Test.StopTest();                                             
    }   
}