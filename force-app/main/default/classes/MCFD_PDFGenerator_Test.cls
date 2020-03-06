/*********************************************************************************************************
Name            : MCFD_PDFGenerator_Test.cls  
Description     : This class is to test MCFD_PDFGenerator.cls functions.
Created By      : ARDC ICM
Created Date    : 24/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      24/May/2018	Updated Version
*************************************************************************************************************/
@isTest (SeeAllData=false)
public class MCFD_PDFGenerator_Test {
    
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Test Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Test lastname',objAccount.Id, '', 'Deepak');
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
	
	static testMethod void MCFD_PDFGeneratorCase1() {
        Test.startTest();
        	User objUser = [SELECT id, Name FROM User WHERE email='standarduser@testorg.com' LIMIT 1];   
        	System.RunAs(objUser) {
        		PageReference pageRef = Page.MCFD_CCSRenderDocumentChecklist;
	        	Test.setCurrentPage(pageRef);
	        	MCFD_PDFGenerator objPDFGenerator = new MCFD_PDFGenerator();
	        	String strReturn =  objPDFGenerator.getContactName();
	        	String strReturn2 = objPDFGenerator.getRequestNum();
	        	String strReturn3 = objPDFGenerator.getSubmittedDate();
	        	List<MCFD_Attachment__c> listNewAttachment = new List<MCFD_Attachment__c>();
	        	listNewAttachment = objPDFGenerator.getDocumentsProvided();
	        	listNewAttachment = objPDFGenerator.getDocumentsOnFile();
	        	listNewAttachment = objPDFGenerator.getDocumentsRequired();
	        	listNewAttachment = objPDFGenerator.getDocumentsSupporting();
	        	List<Attachment> newOOTBAttach = objPDFGenerator.getAdditionalDocumentsProvided();
				Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
				//MCFD_PDFGenerator.savePdf();
        	}
        Test.stopTest();
	}
	
	static testMethod void MCFD_PDFGeneratorCase2() {
		Test.startTest();
        	User objUser = [SELECT id, Name FROM User LIMIT 1];
        	Request__c objRequest = new Request__c();
			List<RecordType> listRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Application'];
			objRequest.RecordTypeId = listRecordType[0].Id;
			objRequest.MCFD_Status__c = 'Submitted';
			objRequest.ICM_SR_Number__c = '1234fgf56789';
			insert objRequest;
        	PageReference pageRef = Page.MCFD_CCSRenderDocumentChecklist;
	        Test.setCurrentPage(pageRef);
	        MCFD_PDFGenerator objPDFGenerator = new MCFD_PDFGenerator();
	        String strReturn =  objPDFGenerator.getContactName();
	        String strReturn2 = objPDFGenerator.getRequestNum();
	        String strReturn3 = objPDFGenerator.getSubmittedDate();
	        MCFD_Attachment__c objNewAttachment = new MCFD_Attachment__c();
            insert objNewAttachment;
            MCFD_PDFGenerator.parentId = objNewAttachment.id;
	        List<MCFD_Attachment__c> newAttachList = new List<MCFD_Attachment__c>();
	        newAttachList = objPDFGenerator.getDocumentsProvided();
	        newAttachList = objPDFGenerator.getDocumentsOnFile();
	        newAttachList = objPDFGenerator.getDocumentsRequired();
	        newAttachList = objPDFGenerator.getDocumentsSupporting();
	        List<Attachment> newOOTBAttach = objPDFGenerator.getAdditionalDocumentsProvided();
        	Attachment objStandarAttachment2=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        	
         	Test.stopTest();   
       	}	
    static testMethod void savePdf (){
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        contact objContact=new Contact();
        Profile objProfile=TestDataFactory.getProfile('MCFD Portal Profile');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser5@testorg.com', '7C01518C8CBD48ED93C10918BD554322');
        insert objUser;
        User objUserPortal=[Select id,name from User where email='standarduser5@testorg.com' limit 1];
        system.runAs(objUserPortal){
        contact objContact2=TestDataFactory.createChild();
        insert objContact2;  
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequestContact(objContact2.id, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
            MCFD_PDFGenerator.savePdf();
            }
    }
     
     static testMethod void savePdfFail (){
         MCFD_PDFGenerator.pdfName='';
        User objUserPortal=[Select id,ContactId,name from User where email='standarduser@testorg.com' limit 1];
        system.runAs(objUserPortal){
         User objUserPortal2=[Select id,ContactId,name from User where email='standarduser@testorg.com' limit 1];
        contact objContact2=TestDataFactory.createChild();
        insert objContact2;  
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequestContact(objContact2.Id, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
            MCFD_PDFGenerator.savePdf();
            } 
    }
    
}