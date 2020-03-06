/************************************************************************************
Name            : MCFD_PrimaryApplicantIncomeInfo_Test.cls  
Description     : test class for MCFD_PrimaryApplicantIncomeInformation.cls
Modification Log :
------------------------------------------------------------------------------------
* Developer                   Date                   Description
------------------------------------------------------------------------------------                 
* Abhishek                16 May 2017             Original Version
* PDAVE                   16 Oct 2017             Refactoring all test methods 
* Gabriela                16 May 2018             Add getincomeId_testfail and getSpouseIncomeId_testfail methods
* Liliana                 21 Jun 2018             Refactoring test methods
*************************************************************************************/

@isTest(seeAllData=false)
public class MCFD_PrimaryApplicantIncomeInfo_Test {
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        system.debug(':::::+++objContact'+objContact);
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest =TestDataFactory.createRequest(objUser, objRecordType, 'Intervention Services'); //this line is breaking during compile. check again
        insert objRequest;
        Id idPrimApp = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Income__c objIncome = TestDataFactory.createIncome(objRequest.Id, objContact.Id);
        Insert objIncome;
       
    }
    
    public static testMethod void getIncomeId_test() {  
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Id idPrimApp = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Income__c objIncome = [SELECT Id, name, Contact__c FROM Income__c WHERE MCFD_BC_Income_Assistance_Freq__c='Every two weeks'];
        Test.startTest();
        	Income__Share objIncShr = new Income__Share();
            objIncShr.ParentId = objIncome.Id;
            objIncShr.UserOrGroupId = objUser.Id;
            objIncShr.AccessLevel = 'Edit';
            objIncShr.RowCause = Schema.Income__Share.RowCause.Manual;
            Insert objIncShr;
            ContactShare objConShare = new ContactShare();
            objConShare.ContactId = idPrimApp;
            objConShare.UserOrGroupId = objUser.Id;
            objConShare.ContactAccessLevel = 'Read';
            objConShare.RowCause = Schema.ContactShare.RowCause.Manual;
            Insert objConShare;
        	System.RunAs(objUser) {
                List<Income__c> listIncList = new List<Income__c>([SELECT id FROM Income__c where Contact__c =: idPrimApp  limit 1]);
                System.assertNotEquals(0, listIncList.size());
                
                List<Contact> listContc = new List<Contact>([SELECT id FROM Contact where Id =: idPrimApp  limit 1]);
                System.assertNotEquals(0, listContc.size());
                
                Income__c objInc = MCFD_PrimaryApplicantIncomeInformation.getIncomeId();
                MCFD_PrimaryApplicantIncomeInformation.primaryApplicantIncomeSave(objInc);
                System.assertNotEquals(Null, objInc);
            }
        Test.StopTest();                                     
    }   
    
    public static testMethod void getIncomeId_testfail() {  
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Id idPrimApp = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Contact objPrimAppCon = [SELECT Id, AccountId FROM Contact WHERE Id =: idPrimApp LIMIT 1];
        
        ContactShare objConShare = new ContactShare();
        objConShare.ContactId = objPrimAppCon.Id;
        objConShare.UserOrGroupId = objUser.Id;
        objConShare.ContactAccessLevel = 'Read';
        objConShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert objConShare;
        
        Contact objSpouse = [SELECT id, name, birthdate,MCFD_SIN__c FROM Contact LIMIT 1];
        
        Test.startTest();
            System.RunAs(objUser) {
                Income__c objInc = MCFD_PrimaryApplicantIncomeInformation.getIncomeId();
            }
        Test.StopTest();                                     
    } 
    
    public static testMethod void getSpouseIncomeId_test() {  
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Id idPrimApp = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Contact objPrimAppCon = [SELECT Id, AccountId FROM Contact WHERE Id =: idPrimApp LIMIT 1];
        ContactShare objConShare = new ContactShare();
        objConShare.ContactId = objPrimAppCon.Id;
        objConShare.UserOrGroupId = objUser.Id;
        objConShare.ContactAccessLevel = 'Read';
        objConShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert objConShare;
       // Contact objSpouse =[SELECT id, name, birthdate FROM Contact WHERE LastName= 'Sumra CommunitySumra Community' LIMIT 1]; this line needs to be revisited. This breaks Contact.Name encryption
		//Contact objSpouse = null; //adding this temp. in place of above line.
		Contact objSpouse = [SELECT id, name, birthdate,MCFD_SIN__c FROM Contact LIMIT 1];
        ContactShare objSpouseconShare = new ContactShare();
        objSpouseconShare.ContactId = objSpouse.Id;
        objSpouseconShare.UserOrGroupId = objUser.Id;
        objSpouseconShare.ContactAccessLevel = 'Read';
        objSpouseconShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert objSpouseconShare;
        Test.startTest();
        System.RunAs(objUser) {
            Request__c objReq = new Request__c();
            insert objReq;
            Id idSpouse = objSpouse.Id;
            MCFD_Relationship__c objReltSpouse = TestDataFactory.createRelationship('Spouse', idPrimApp, idSpouse, objReq.id);
            insert objReltSpouse;
       
            Income__c objIncome = TestDataFactory.getIncome(idSpouse);
            Insert objIncome;
            
            List<Income__c> listIncome = new List<Income__c>([SELECT id FROM Income__c where Contact__c =: idSpouse  limit 1]);
            System.assertNotEquals(0, listIncome.size());
            
            List<Contact> listContact = new List<Contact>([SELECT id FROM Contact where Id =: idSpouse  limit 1]);
            System.assertNotEquals(0, listContact.size());
            
            List<MCFD_Relationship__C> listSpouseRelt = new List<MCFD_Relationship__C> ([SELECT id FROM MCFD_Relationship__C WHERE MCFD_Relationship_Type__c='Spouse' AND MCFD_Parent_Contact__c =: idPrimApp]);
            System.assertNotEquals(0, listSpouseRelt.size());
            
            Income__c objInco = MCFD_PrimaryApplicantIncomeInformation.getSpouseIncomeId();
            MCFD_PrimaryApplicantIncomeInformation.SpouseIncomeSave(objInco);
            System.assertNotEquals(Null, objInco);
        }
        Test.StopTest();                                     
    }   
    
    public static testMethod void getSpouseIncomeId_testfail() {
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Id idPrimApp = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        Contact objPrimAppCon = [SELECT Id, AccountId FROM Contact WHERE Id =: idPrimApp LIMIT 1];
        ContactShare objConShare = new ContactShare();
        objConShare.ContactId = objPrimAppCon.Id;
        objConShare.UserOrGroupId = objUser.Id;
        objConShare.ContactAccessLevel = 'Read';
        objConShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert objConShare;
      	Contact objSpouse = [SELECT id, name, birthdate,MCFD_SIN__c FROM Contact LIMIT 1];
        ContactShare objSpouseconShare = new ContactShare();
        objSpouseconShare.ContactId = objSpouse.Id;
        objSpouseconShare.UserOrGroupId = objUser.Id;
        objSpouseconShare.ContactAccessLevel = 'Read';
        objSpouseconShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert objSpouseconShare;
        test.startTest();
            System.RunAs(objUser) {
                Request__c objReq = new Request__c();
                insert objReq;
                Id idSpouse = objSpouse.Id;
                MCFD_Relationship__c objReltSpouse = TestDataFactory.createRelationship('Spouse', idPrimApp, idSpouse, objReq.id);
                insert objReltSpouse;
                
                List<Contact> listContact = new List<Contact>([SELECT id FROM Contact where Id =: idSpouse  limit 1]);
                System.assertNotEquals(0, listContact.size());
                
                List<MCFD_Relationship__C> listSpouseRelt = new List<MCFD_Relationship__C> ([SELECT id FROM MCFD_Relationship__C WHERE MCFD_Relationship_Type__c='Spouse' AND MCFD_Parent_Contact__c =: idPrimApp]);
                System.assertNotEquals(0, listSpouseRelt.size());
                
                Income__c inc = MCFD_PrimaryApplicantIncomeInformation.getSpouseIncomeId();
                Income__c objInco = MCFD_PrimaryApplicantIncomeInformation.getSpouseIncomeId();
            }
        Test.StopTest();          
    }
}