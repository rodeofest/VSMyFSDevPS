/************************************************************************************
Function        : test class for MCFD_SubmitAutismRequestXMLGenerator

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rosario Lopez				08/06/2018				Standards applied
* ----------------------------------------------------------------------------
* Rosario Lopez				03/07/2018				Methods updated
*************************************************************************************/
@isTest(SeeAllData=False)
public with sharing class MCFD_SubmitAutismRequestXMLGener_Test {
    
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
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        
        System.assertEquals(objUser.isActive, true);
    }
    static testMethod void testemptyRTPInterventionSubmission() {
        // Implement test code
        
        User objUser = [SELECT id FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;		
        
        ContactShare conShare = new ContactShare();
        conShare.ContactId = primAppId;
        conShare.UserOrGroupId = objUser.Id;
        conShare.ContactAccessLevel = 'Edit';
        conShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert conShare;
        
        Request__c objRequest = new Request__c();  
        //set it to record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'RTP'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        objRequest.MCFD_Service_Auth_Type__c = 'Intervention Services';
        insert objRequest;
        System.debug('Request__c '+objRequest.RecordTypeId);
        
        //add intervention
        Sub_Request__c intervention = new Sub_Request__c();
        List<RecordType> interRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Intervention Service'];
        intervention.RecordTypeId = interRecord[0].Id;
        intervention.Name = 'Test';
        intervention.MCFD_Request__c = objRequest.Id;
        insert intervention;
        
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        listIntervention.add(intervention);
        
        //empty lists
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        
        
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitRTP(objRequest, listIntervention, listTravel, listTraining, listEquip, listTravelExp);
        Test.StopTest();
        
    }
    static testMethod void testRTPInterventionSubmissionBusiness() {
        // Implement test code
        
        User objUser = [SELECT id FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        
        ContactShare conShare = new ContactShare();
        conShare.ContactId = primAppId;
        conShare.UserOrGroupId = objUser.Id;
        conShare.ContactAccessLevel = 'Edit';
        conShare.RowCause = Schema.ContactShare.RowCause.Manual;
        Insert conShare;
        
        /*Request__Share reqShr = new Request__Share();
reqShr.ParentId = request.Id;
reqShr.UserOrGroupId = objuser.Id;
reqShr.AccessLevel = 'Edit';
reqShr.RowCause = Schema.Request__Share.RowCause.Manual;
Insert reqShr;
*/
        Request__c objRequest = new Request__c();
        //set it to rtp record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'RTP'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        objRequest.MCFD_Service_Auth_Type__c = 'Intervention Services';
        objRequest.MCFD_Service_Provider_Type__c = 'Business';
        Date newDate = Date.newInstance(1960, 2, 17);
        objRequest.MCFD_End_Date__c = newDate;
        insert objRequest;
        
        //add intervention
        Sub_Request__c intervention = new Sub_Request__c();
        List<RecordType> interRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Intervention Service'];
        intervention.RecordTypeId = interRecord[0].Id;
        intervention.Name = 'Test';
        intervention.MCFD_Request__c = objRequest.Id;
        insert intervention;
        
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        listIntervention.add(intervention);
        
        //empty lists
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitRTP(objRequest, listIntervention, listTravel, listTraining, listEquip, listTravelExp);
        Test.StopTest();
        
    } 
    static testMethod void testRTPInterventionSubmissionBusinessInd() {
        // Implement test code
        
        User objUser = [SELECT id, Name FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        
        Request__c objRequest = new Request__c();
        //set it to rtp record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'RTP'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        objRequest.MCFD_Service_Auth_Type__c = 'Intervention Services';
        objRequest.MCFD_Service_Provider_Type__c = 'Individual';
        insert objRequest;
        
        //add intervention
        Sub_Request__c intervention = new Sub_Request__c();
        List<RecordType> interRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Intervention Service'];
        intervention.RecordTypeId = interRecord[0].Id;
        intervention.Name = 'Test';
        intervention.MCFD_Request__c = objRequest.Id;
        insert intervention;
        
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        listIntervention.add(intervention);
        
        //empty lists
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitRTP(objRequest, listIntervention, listTravel, listTraining, listEquip, listTravelExp);
        Test.StopTest();
    }
    static testMethod void testRTPTTESubmission() {
        // Implement test code
        User objUser = [SELECT id, Name FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        
        Request__c objRequest = new Request__c();
        //set it to rtp record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'RTP'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        objRequest.MCFD_Service_Auth_Type__c = 'Travel, Training, Equipment, and Supplies';
        
        insert objRequest;
        
        //add empty intervention
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        
        //add travel
        Sub_Request__c travel = new Sub_Request__c();
        List<RecordType> listTravelRecord = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Travel Request'];
        travel.RecordTypeId = listTravelRecord[0].Id;
        travel.Name = 'Test';
        travel.MCFD_Request__c = objRequest.Id;
        insert travel;
        
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        listTravel.add(travel);
        
        //add travel expenses
        Sub_Sub_Request__c travelExp = new Sub_Sub_Request__c();
        List<RecordType> travelExpRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Cost Record'];
        travelExp.RecordTypeId = travelExpRecord[0].Id;
        travelExp.Sub_Request__c = travel.Id;
        insert travelExp;
        
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        listTravelExp.add(travelExp);
        
        //add training
        Sub_Request__c training = new Sub_Request__c();
        List<RecordType> item = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items'];
        training.RecordTypeId = item[0].Id;
        training.Name = 'Test';
        training.MCFD_Request__c = objRequest.Id;
        insert training;
        
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        listTraining.add(training);
        
        //add equip
        Sub_Request__c equip = new Sub_Request__c();
        List<RecordType> item2 = [SELECT Id, Name from RecordType WHERE SObjectType = 'Sub_Request__c' AND Name='Items'];
        equip.RecordTypeId = item2[0].Id;
        equip.Name = 'Test';
        equip.MCFD_Request__c = objRequest.Id;
        insert equip;
        
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        listEquip.add(equip); 
        
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitRTP(objRequest, listIntervention, listTravel, listTraining, listEquip, listTravelExp);
        Test.StopTest();		
        
    }
    @isTest static void testReimbursementSubmission() {
        // Implement test code
        
        User objUser = [SELECT id, Name FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        
        Request__c objRequest = new Request__c();
        //set it to rtp record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'RTP'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        objRequest.MCFD_Service_Auth_Type__c = 'Travel, Training, Equipment, and Supplies';
        insert objRequest;
        
         //add intervention
        Sub_Request__c intervention = new Sub_Request__c();
        List<RecordType> interRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Intervention Service'];
        intervention.RecordTypeId = interRecord[0].Id;
        intervention.Name = 'Test';
        intervention.MCFD_Request__c = objRequest.Id;
        insert intervention;
        
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        listIntervention.add(intervention);
        
        //add travel
        Sub_Request__c travel = new Sub_Request__c();
        List<RecordType> travelRecord = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Sub_Request__c' and Name='Travel Request'];
        travel.RecordTypeId = travelRecord[0].Id;
        travel.Name = 'Test';
        travel.MCFD_Request__c = objRequest.Id;
        insert travel;
        
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        listTravel.add(travel);
        
        //add travel expenses
        Sub_Sub_Request__c travelExp = new Sub_Sub_Request__c();
        List<RecordType> travelExpRecord = [SELECT Id, Name FROM RecordType WHERE Name = 'Cost Record'];
        travelExp.RecordTypeId = travelExpRecord[0].Id;
        travelExp.Sub_Request__c = travel.Id;
        insert travelExp;
        
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        listTravelExp.add(travelExp);
        
        //add training
        Sub_Request__c training = new Sub_Request__c();
        List<RecordType> item = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Sub_Request__c' AND Name='Items'];
        training.RecordTypeId = item[0].Id;
        training.Name = 'Test';
        training.MCFD_Request__c = objRequest.Id;
        insert training;
        
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        listTraining.add(training);
        
        //add equip
        Sub_Request__c equip = new Sub_Request__c();
        List<RecordType> item2 = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Sub_Request__c' AND Name='Items'];
        equip.RecordTypeId = item2[0].Id;
        equip.Name = 'Test';
        equip.MCFD_Request__c = objRequest.Id;
        insert equip;
        
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        listEquip.add(equip);
        
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitReimbursement(objRequest, listTravel, listTravel, listTraining, listTravelExp, listTravelExp, listTraining);
        Test.StopTest();	
        
        
    }   
    static testMethod void testReimbursementSubmissionEmpty() {
        // Implement test code
        User objUser = [SELECT id, Name FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
        Id primAppId = [SELECT Id, ContactId FROM User WHERE Id =: objUser.Id LIMIT 1].ContactId;
        
        Request__c objRequest = new Request__c();
        //set it to rtp record type
        List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Reimbursement'];
        objRequest.RecordTypeId = listRecordType[0].Id;
        insert objRequest;
        
        //add empty lists
        List<Sub_Request__c> listIntervention = new List<Sub_Request__c>();
        List<Sub_Request__c> listTravel = new List<Sub_Request__c>();
        List<Sub_Sub_Request__c> listTravelExp = new List<Sub_Sub_Request__c>();
        List<Sub_Request__c> listTraining = new List<Sub_Request__c>();
        List<Sub_Request__c> listEquip = new List<Sub_Request__c>();
        Test.StartTest();
        // setting up mock webservice response 
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
        String returnString;
        returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitReimbursement(objRequest, listTravel, listTravel, listTraining, listTravelExp, listTravelExp, listTraining);
        Test.StopTest();	
    }
    static testMethod void exceptionTest() { 
        Test.startTest();        
        MCFD_SubmitAutismRequestXMLGenerator.RTP_Submission_Exception testError = new MCFD_SubmitAutismRequestXMLGenerator.RTP_Submission_Exception(new MCFD_SubmitAutismRequestXMLGenerator.RTP_Submission_Exception(),'test');     
        Test.stopTest();
    }
    
}