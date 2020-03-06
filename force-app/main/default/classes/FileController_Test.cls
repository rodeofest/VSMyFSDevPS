/*********************************************************************************************************
Name            : FileController_Test.cls  
Description     : This class is to test FileController.cls functions. 
Created By      : ARDC ICM
Created Date    : 28/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   28/05/2018   Original version 
--------------------------------------------------------------------------------------------------------------     
Liliana Trejo   20/06/2018   Update Methods 
***************************************************************************************************************/
@isTest(seeAllData=false)

public class FileController_Test {
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
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;       
    }
    
	static testMethod void saveTheFile() {
		User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];
        MCFD_Attachment__c objStandarAttachment=[SELECT id FROM MCFD_Attachment__c limit 1];  
        Test.startTest();
			FileController.saveTheFile(objStandarAttachment.Id, 'test data','abcdefghijklmnopqrstuv =','test data');
        Test.stopTest();
	}
    
    static testMethod void saveTheChunk(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
          	Id parentId=objCustomAttachment.MCFD_Contact_Id__c;
            String fileName=objCustomAttachment.MCFD_Attachment_Name__c;
            String base64Data='abcdefghijklmnopqrstuv ='; 
            String contentType=objStandarAttachment.ContentType;
            String fileId=objStandarAttachment.Id;
			FileController.saveTheChunk(parentId, fileName, base64Data, contentType, fileId);
         Test.stopTest();
    }
}