/**************************************************************************************
Function        : Test Class for covering the code for - MCFD_Request_Trigger_Helper

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                20 OCT 2017             Original Version
* ----------------------------------------------------------------------------
* Gabriela  				08/06/2018				Standards Applied
------------------------------------------------------------------------------
*Liliana                    21 Jun 2018             Refactoring test methods
*************************************************************************************/
@isTest
public class MCFD_Request_Trigger_Helper_Test {
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
        RecordType objRecordType2 = TestDataFactory.getRecordType('Request__c', 'RTP');
        Request__c objRequest2 = TestDataFactory.createRequest(objUser, objRecordType2,'Travel, Training, Equipment, and Supplies');
        insert objRequest2;
        RecordType objRecordType3 = TestDataFactory.getRecordType('Request__c', 'RTP - Travel, Training, and Equipment');
        Request__c objRequest3 = TestDataFactory.createRequest(objUser, objRecordType3,'Travel, Training, Equipment, and Supplies');
        insert objRequest3;
        RecordType objRecordType4 = TestDataFactory.getRecordType('Request__c', 'RTA');
        Request__c objRequest4 = TestDataFactory.createRequest(objUser, objRecordType4,'Travel, Training, Equipment, and Supplies');
        insert objRequest4;
      	RecordType objRecordType5 = TestDataFactory.getRecordType('Request__c', 'Reimbursement');
      	Request__c objRequest5 = TestDataFactory.createRequest(objUser, objRecordType5,'Travel, Training, Equipment, and Supplies');
      	insert objRequest5;
    }
    
    public static testMethod void reSubmitRequest() {	 
       	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());
        List<Id> listId = new List<Id>();
        for(Request__c objRequestIterator:[SELECT id,RecordTypeId FROM Request__c]) {
            listId.add(objRequestIterator.Id);
        }         
        Test.startTest();
        	MCFD_Request_Trigger_Helper.reSubmitRequest(listId);
        Test.stopTest();
    }
    
    public static testMethod void reSubmitRequestCCS() {
        User objUser = [Select id, Name,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'CCS case request');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;
        Contact objContact=[SELECT id,Name from Contact LIMIT 1]; 
        MCFD_Relationship__c objRelationship=TestDataFactory.createRelationship('Spouse', objContact.id, objContact.id, objRequest.Id);
        insert objRelationship;
       	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());
        List<Id> listId = new List<Id>();
        Request__c objRequestType = [SELECT id,RecordTypeId FROM Request__c where id=:objRequest.Id];
        listId.add(objRequestType.Id);     
        Test.startTest();
        	MCFD_Request_Trigger_Helper.reSubmitRequest(listId);
        Test.stopTest();
    }
    
    public static testMethod void reSubmitRequestAutismCase() {
        User objUser = [Select id, Name,ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Autism case request');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;
        Contact objContact=[SELECT id,Name from Contact LIMIT 1]; 
        MCFD_Relationship__c objRelationship=TestDataFactory.createRelationship('Spouse', objContact.id, objContact.id, objRequest.Id);
        insert objRelationship;
       	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());
        List<Id> listId = new List<Id>();
        Request__c objRequestType = [SELECT id,RecordTypeId FROM Request__c where id=:objRequest.Id];
        listId.add(objRequestType.Id);       
        Test.startTest();
        	MCFD_Request_Trigger_Helper.reSubmitRequest(listId);
        Test.stopTest();
    }
}