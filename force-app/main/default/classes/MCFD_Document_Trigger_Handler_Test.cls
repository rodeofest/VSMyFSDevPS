/*********************************************************************************************************
Name            : MCFD_Document_Trigger_Handler_Test.cls  
Description     : This class is to test MCFD_Document_Trigger_Handler.cls functions.
Created By      : Deloitte ARDC
Created Date    : 10/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      11/May/2018	Standards applied
***************************************************************************************************************/  
@isTest(seeAllData=false)
public class MCFD_Document_Trigger_Handler_Test {
	@testSetup
    static void setup(){
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
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;
        Attachment objStandarAttachment2 =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment2;
        MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Error','Upload', 'SpouseID1.txt' );
        insert objDocumentIntegrationEngine;        
       
    }
    
    static testMethod void validate_ResubmitDocument(){
        Test.startTest();{
        	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        	List<MCFD_Document_Integration_Engine__c> ListDocIntegration = [Select Id, Name, Integration_Status__c from MCFD_Document_Integration_Engine__c  limit 1];
        	ListDocIntegration[0].Integration_Status__c = 'Pending Submission';
       		update ListDocIntegration;
            }
        Test.stopTest();
    }
}