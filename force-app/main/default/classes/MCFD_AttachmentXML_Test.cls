/*********************************************************************************************************
Name            : MCFD_AttachmentXML_Test.cls  
Description     : This class is to test MCFD_Attachment_XML_Helper.cls functions.
Created By      : Deloitte 
Created Date    : 16/May/2017
Modification Log: 10/May/2018
Modified By     : ARDC ICM
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      16/May/2017   
--------------------------------------------------------------------------------------------------------------              
Gabriela      10/May/2018
***************************************************************************************************************/
@isTest(seeAllData=false)
public class MCFD_AttachmentXML_Test {
    @testSetup
    static void setup() {
       Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Contact objContact2 = TestDataFactory.createContact('CommunitySumra Community', objAccount.Id, '', 'Gabriela');
        insert objContact2;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        MCFD_Attachment__c attachment = TestDataFactory.createCustomAttachment(objRequest);
        insert attachment;
        Attachment file = TestDataFactory.createStandardAttachment(attachment.id);
        insert file;
        attachment.MCFD_Request_Id__c = objRequest.Id;
        update attachment;
        String strStdAttchId = String.valueOf(file.Id);
    }
    
    static testMethod void prepare_Attachment_XMLOperations() {  
        User objUser = [SELECT Id, ContactId FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        Attachment objFile =[Select id from Attachment where name= 'testFileName'];
        Test.startTest();  
            System.RunAs(objUser) {  
                MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objFile.Id, 'Insert');
                MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objFile.Id, 'Delete');
                MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objFile.Id, 'Retry');
                MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objFile.Id, 'Fail');
            }
        Test.stopTest();
    }  
    
    static testMethod void prepare_Attachment_XMLUpload() {
        
            MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
            Request__c objRequest=[SELECT id from Request__c LIMIT 1];  
            MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Pending Submission','Upload','SpouseID1.txt');
            insert objDocumentIntegrationEngine;
        	Test.startTest();
            MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objStandarAttachment.Id, 'Retry'); 
        	Test.stopTest();       
    }
    
    static testMethod void prepare_Attachment_XMLDelete() {
        Test.startTest();
            MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
            Request__c objRequest=[SELECT id from Request__c LIMIT 1];  
        	MCFD_Attachment__c custmAttch = [SELECT id, Name,MCFD_Request_Id__c, MCFD_Request_Id__r.ICM_SR_Number__c FROM MCFD_Attachment__c WHERE id =: objStandarAttachment.parentId];
            MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Synced','Delete','SpouseID1.txt');
           	insert objDocumentIntegrationEngine;
            MCFD_Attachment_XML_Helper.prepare_Attachment_XML(objStandarAttachment.Id, 'Retry');       
        Test.stopTest();       
    }    
}