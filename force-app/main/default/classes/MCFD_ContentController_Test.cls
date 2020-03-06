/*********************************************************************************************************
Name            : MCFD_ContentController_Test.cls  
Description     : This test class is used for covering all the test scneario 
                  related to the MCFD_ContentController class   
Created By      : Deloitte
Created Date    : 6/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        	Description
--------------------------------------------------------------------------------------------------------------            
Hemanth Manne  	06/Feb/2017   	Original Version
--------------------------------------------------------------------------------------------------------------
Liliana Trejo   23/05/2018   	Version Updated
--------------------------------------------------------------------------------------------------------------
Gabriela        03/07/2018     Updated Methods
***************************************************************************************************************/
@isTest(seeAllData=false)
public class MCFD_ContentController_Test {
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
        MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Synced','Upload', 'SpouseID1.txt' );
        insert objDocumentIntegrationEngine;
        
    }
    
    static testMethod void CallICMforAttachmentUpload(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';         	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Upload');
        Test.stopTest();
    }
    
    static testMethod void CallICMforAttachmentUploadCatch(){  
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';         	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Upload');
    }
    
    static testMethod void CallICMforAttachmentUploadFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';          	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGeneratorFail()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Upload');
        	MCFD_ContentController.ReCallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Upload');
        Test.stopTest();
    }
    
    static testMethod void CallICMforAttachmentDelete(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';         	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Delete');
        Test.stopTest();
    }
    
    static testMethod void CallICMforAttachmentDeleteCatch(){  
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';         	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Delete');
    }
    
    static testMethod void CallICMforAttachmentDeleteFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
        	String XMLrequest='<?xml version="1.0"?><payload><outboundMessages><OutboundMessage>'+
          	'<ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW,'+
          	' TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/>'+
          	'<MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body>'+
          	'<ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017'+
          	'00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</'+
          	'ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID>'+
          	'<ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>'+
          	'3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message'+
          	'</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID>'+
          	'<ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments>'+
          	'<OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO'+
          	'</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
          	'<remainingMsgs>12</remainingMsgs></payload>';          	
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGeneratorFail()); 
        	MCFD_ContentController.CallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Delete');
       	    MCFD_ContentController.ReCallICMforAttachmentUpload(objStandarAttachment.id,XMLrequest,'Delete');
        Test.stopTest();
    }
    
    static testMethod void SendAttachmentToICMUpload(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
        	MCFD_ContentController.ReSendAttachmentToICM(objStandarAttachment.id,'Upload'); 
        Test.stopTest();
    }
    
    static testMethod void SendAttachmentToICMUploadFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMockError()); 
        	MCFD_ContentController.ReSendAttachmentToICM(objStandarAttachment.id,'Upload'); 
        Test.stopTest();
    }
    
     static testMethod void ReSendAttachmentToICMDelete(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
        	MCFD_ContentController.ReSendAttachmentToICM(objStandarAttachment.id,'Delete'); 
        Test.stopTest();
    }
    
    static testMethod void SReSendAttachmentToICMDeleteFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMockError()); 
        	MCFD_ContentController.ReSendAttachmentToICM(objStandarAttachment.id,'Delete'); 
        Test.stopTest();
    }
    
    static testMethod void SendAttachmentToICMDeleteAndFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];  
          	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());          
        	MCFD_ContentController.SendAttachmentToICM(objStandarAttachment.id,'Delete');
            MCFD_ContentController.SendAttachmentToICM(objStandarAttachment.Id, 'Fail');
        Test.stopTest();
    }
        
    static testMethod void upsertFile(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];
        	MCFD_ContentController.upsertFile(objStandarAttachment);
        Test.stopTest();
    }
    
    static testMethod void upsertAttachment(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1 ];
        	MCFD_ContentController.upsertAttachment(objCustomAttachment);
        Test.stopTest();
    }
    
    static testMethod void getFileList(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];
        	MCFD_ContentController.getFileList(objStandarAttachment.Id);
        Test.stopTest();
    }
    
    static testMethod void addTimeStamp(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id FROM Attachment WHERE Name = 'testFileName'];
        	MCFD_ContentController.addTimeStamp('Test.Test');
        Test.stopTest();
    }
    
    static testMethod void getAttachment(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
			MCFD_ContentController.getAttachment(objCustomAttachment.MCFD_Contact_Id__c,objCustomAttachment.MCFD_Type__c);
        Test.stopTest();
    }
    
    static testMethod void deleteAttach(){  
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
        	Attachment objStandarAttachment=[SELECT id,Name,ParentId FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
        	MCFD_ContentController.deleteAttach(objStandarAttachment.Name,objStandarAttachment.ParentId);
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
            Map<String,String> MapCustomAttachment = new Map<String,String>();
          	MapCustomAttachment.put('Type',objCustomAttachment.MCFD_Type__c);
            String Type='';
			MCFD_ContentController.saveTheChunk(parentId, fileName, base64Data, contentType, fileId, MapCustomAttachment, Type);
         Test.stopTest();
    }
    
    static testMethod void saveTheChunkFail(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
        	Id parentId=objCustomAttachment.MCFD_Contact_Id__c;
            String fileName=objCustomAttachment.MCFD_Attachment_Name__c;
            String base64Data='abcdefghijklmnopqrstuv ='; 
            String contentType=objStandarAttachment.ContentType;
            String fileId=objStandarAttachment.Id;
            Map<String,String> MapCustomAttachment = new Map<String,String>();
          	MapCustomAttachment.put('Type',objCustomAttachment.MCFD_Type__c);
            String Type='';
			MCFD_ContentController.saveTheChunk(parentId, fileName, base64Data, contentType, '', MapCustomAttachment, Type);
         Test.stopTest();
    }
    
    static testMethod void uploadFile() {  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
        	Request__c objRequest=[SELECT id from Request__c LIMIT 1];
        	String fileString=''; 
            Attachment uploadedFile=objStandarAttachment;
            MCFD_Attachment__c attachmentInfo=objCustomAttachment;
            Request__c request =objRequest; 
            MCFD_ContentController.uploadFile(fileString, uploadedFile, attachmentInfo, 2, request);
        	MCFD_ContentController.uploadFile(fileString, uploadedFile, attachmentInfo, 12, request);
        Test.stopTest();
    }
 }