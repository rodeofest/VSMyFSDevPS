/*********************************************************************************************************
Name            : MCFD_EnterFamilyComposition_Test.cls  
Description     : This class is to test MCFD_EnterFamilyCompositionController.cls functions.
Modified By      : Deloitte ARDC
Modified Date    : 15/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Gabriela      15/May/2018
----------------------------------------------------------------------------     
Liliana       21 Jun 2018   Refactoring test methods
***************************************************************************************************************/
@isTest(seeAllData=false)
public class MCFD_EnterFamilyComposition_Test {
	@testSetup
    static void setup(){
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Contact objContact2 = TestDataFactory.createContact('CommunitySumra Community', objAccount.Id, '', 'Gabriela');
        insert objContact2;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        MCFD_Address__c objAddress=TestDataFactory.createMCFDAddress('Test');
        insert objAddress;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Intervention Services'); 
        insert objRequest;
        MCFD_Relationship__c objRelationship = testDataFactory.createRelationship('Dependant', objContact.Id, objContact2.Id, objRequest.Id);
        insert objRelationship;
         
    }
    
    static testMethod void GetSRfromICMTest() {
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Request__c objRequestName = [select Id, ICM_SR_Number__c, name from Request__c WHERE MCFD_declaration_and_consent_signed_date__c='Consent signed'];
        String requestName = objRequestName.Name;
        String JSONString = '{'+
                                    '"Operation": "Insert",'+
                                    '"SRType" : "Child Care Subsidy",'+
                                    '"SRSubType" : "Application",'+
                                    '"Priority" : "3-Standard",'+
                                    '"Status" : "Open",'+
                                    '"AssignedTeam" : "Admin Support",'+
                                    '"ContMethod" : "Client Portal",'+
                                    '"SvcOff" : "XWB - Child Care Programs and Services Branch",'+
                                    '"Organization" : "MCFD",'+
                                    '"CreatedBy" : "CFDGENUSR",'+
                                    '"Created" : "",'+
                                    '"Memo" : "",'+
                                    '}';
        Test.startTest();
            System.runAs(objUser) {            
                Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
                String returnVal = MCFD_EnterFamilyCompositionController.GetSRfromICM(JSONString, requestName);
                System.assertNotEquals(Null, returnVal);
                returnVal = MCFD_EnterFamilyCompositionController.GetSRfromICM(JSONString, requestName);
                System.assertNotEquals(Null, returnVal);
            }
        Test.stoptest(); 
    }
    
    static testMethod void changeToSpouseDOBTest() {
        Contact objContact = [SELECT id, name, birthdate FROM Contact  LIMIT 1];
        User objUser = [SELECT Id FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {  
                Boolean retVal = MCFD_EnterFamilyCompositionController.changeToSpouseDOB(objContact);
                System.assertEquals(retVal, false);
                objContact.Birthdate = Date.parse('10/11/1990');
                retVal = MCFD_EnterFamilyCompositionController.changeToSpouseDOB(objContact);
                System.assertEquals(retVal, true);
            }
        Test.stopTest();
    }
    
    static testMethod void updateDependantsTest() {
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
        User objUser = [SELECT Id FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            system.runAs(objUser) {  
                MCFD_EnterFamilyCompositionController.updateDependants(objContact);
                System.assertNotEquals(objContact, null);
            }
        Test.stopTest();
    }
    
    static testMethod void updateFamilyCompContactsTest() {
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
        Map<String, Contact> mapContact = new Map<String, Contact>();
        mapContact.put('Primary', objContact);
        mapContact.put('Spouse', objContact);
        User objUser = [SELECT Id FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {  
                MCFD_EnterFamilyCompositionController.updateFamilyCompContacts(mapContact);
                MCFD_EnterFamilyCompositionController.getBasicInfo();
                MCFD_EnterFamilyCompositionController.utilityMethod2();
                MCFD_EnterFamilyCompositionController.utilityMethod3();
                MCFD_Relationship__c objRelContact = [select id from MCFD_Relationship__c where MCFD_Parent_Contact__c =: objContact.Id 
                                                      and MCFD_Child_Contact__c =: objContact.Id Limit 1];
                System.assertNotEquals(objRelContact, null);
            }
        Test.stopTest();
    }
    
    static testMethod void getBasicInfoTest() {
        User objUser = [Select Id from User where email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {  
                Contact objContact = MCFD_EnterFamilyCompositionController.getBasicInfo();
                System.assertNotEquals(objContact, null);
            }
        Test.stopTest();
    }
    
    static testMethod void updtPrimaryAndSpouseInfoTest() {
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
        User objUser = [SELECT Id FROM User WHERE email='standarduser@testorg.com'LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {  
                MCFD_EnterFamilyCompositionController.updtPrimaryAndSpouseInfo(objContact, 'Primary');
                System.assertNotEquals(objContact, null);
                MCFD_EnterFamilyCompositionController.updtPrimaryAndSpouseInfo(objContact, 'Spouse');
                System.assertNotEquals(objContact, null);
            }
        Test.stopTest();
    }
    
    static testMethod void InsertDocumentChecklistMessageTest() {
        User objUser = [SELECT Id fROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {  
                MCFD_EnterFamilyCompositionController.InsertDocumentChecklistMessage
                    ('Access denied', 'doc', 'Access denied', 'Child Care Subsidy');
                MCFD_Message__c objNewMsg = [SELECT id FROM MCFD_Message__c WHERE Message_Subject__c = 'Access denied'];
                System.assertNotEquals(objNewMsg, null);
            }
        Test.stopTest();
    }
    
    static testMethod void dependantsInfoTest() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Request__c objRequest = [select Id, ICM_SR_Number__c, name from Request__c WHERE MCFD_declaration_and_consent_signed_date__c='Consent signed'];
        MCFD_Relationship__c objRelationship = [SELECT id, MCFD_Relationship_Type__c FROM MCFD_Relationship__c WHERE MCFD_Relationship_Type__c ='Dependant' LIMIT 1];
        Contact objContact = [SELECT id, name, birthdate, MCFD_Age__c FROM Contact  LIMIT 1];  
        objContact.Birthdate= Date.parse('10/10/2010');
        update objContact;
        Contact objContact3 = [SELECT id, name, birthdate, MCFD_Age__c,LastName FROM Contact  LIMIT 1];
        Test.startTest();    
            system.runAs(objUser) {
                    
                    MCFD_EnterFamilyCOmpositionController.dependantsInfo();
                    MCFD_EnterFamilyCompositionController.utilityMethod1();
                    MCFD_EnterFamilyCompositionController.utilityMethod2();  
                    MCFD_EnterFamilyCompositionController.individualDependantInfo(99888234,'Child');
                    
                    
                }
        Test.stopTest();  
    }
    
    static testMethod void dependantsInfoTestfail() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Request__c objRequest = [select Id, ICM_SR_Number__c, name from Request__c WHERE MCFD_declaration_and_consent_signed_date__c='Consent signed'];
        MCFD_Relationship__c objRelationship = [SELECT id, MCFD_Relationship_Type__c FROM MCFD_Relationship__c WHERE MCFD_Relationship_Type__c ='Dependant' LIMIT 1];
        objRelationship.MCFD_Relationship_Type__c ='Spouse';
        update objRelationship;
        MCFD_Relationship__c objRelationship2 = [SELECT id, MCFD_Relationship_Type__c FROM MCFD_Relationship__c WHERE MCFD_Relationship_Type__c ='Spouse' LIMIT 1];
        Test.startTest();
            System.runAs(objUser){
                    MCFD_EnterFamilyCOmpositionController.dependantsInfo();
                    MCFD_EnterFamilyCompositionController.utilityMethod1();
                    MCFD_EnterFamilyCompositionController.utilityMethod2(); 
                }
        Test.stopTest();  
    }
    
    static testMethod void primaryApplicantSaveTest() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
        MCFD_Address__c objAddress = TestDataFactory.createMCFDAddress('Test');
        MCFD_Address__c objAddress2 = TestDataFactory.createMCFDAddress('Test');
        
        Test.startTest();
            System.runAs(objUser){ 
                MCFD_EnterFamilyCompositionController.primaryApplicantSave(objContact, objAddress, objAddress2); 
                MCFD_EnterFamilyCompositionController.updtPrimaryAndSpouseInfo(objContact, 'Primary');
            }
        Test.stopTest();
    }
    
    static testMethod void loggedInUserInfoTest() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Test.startTest();
            System.runAs(objUser) {
                MCFD_EnterFamilyCompositionController.loggedInUserInfo();
            }
        Test.stopTest();
        
    }
    
    static testMethod void saveContactInfoTest() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
        Test.startTest();
            System.runAs(objUser) { 
                 MCFD_EnterFamilyCompositionController.saveContactInfo(objContact);
                MCFD_EnterFamilyCompositionController.updtPrimaryAndSpouseInfo(objContact, 'Primary');
            }
        Test.stopTest(); 
    }
    
     static testMethod void preFillAddressMail() {
        User objUser = [SELECT Id,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Contact objContact = [SELECT id, name, birthdate FROM Contact LIMIT 1];
         MCFD_Address__c objAddress = TestDataFactory.createMCFDAddress('Test');
         insert objAddress;
         Request__c objRequest = [select Id, ICM_SR_Number__c, name from Request__c WHERE MCFD_declaration_and_consent_signed_date__c='Consent signed'];
         MCFD_Contact_Address__c objContactAddress=TestDataFactory.createContactAddress(objRequest.id, objUser.ContactId, 'Home and Mailing Address',objAddress);
         insert objContactAddress;
         
        Test.startTest();
            System.runAs(objUser) { 
                MCFD_EnterFamilyCompositionController.preFillAddressMail();
            }
        Test.stopTest(); 
    }
    
    static testMethod void changeToSpouseInfo(){
        Test.startTest();
        Contact spouse=TestDataFactory.createSpouse();
        insert spouse;
        MCFD_EnterFamilyCompositionController.changeToSpouseInfo(spouse);
        test.stopTest();
              }
}