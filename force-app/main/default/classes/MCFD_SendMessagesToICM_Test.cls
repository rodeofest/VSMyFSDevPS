/************************************************************************************
Function        : test class for MCFD_SendMessagesToICM

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* PDAVE                   31/10/2017            Refactoring all test methods
* ----------------------------------------------------------------------------                 
* Liliana                 13/06/2018            Refactoring all test methods
* ---------------------------------------------------------------------------- 
* Liliana                21 Jun 2018           Refactoring test methods
*************************************************************************************/

@isTest(seeAllData=false)
public class MCFD_SendMessagesToICM_Test {
              
    @testSetup 
    static void setup() {
		List<MCFD_Message__c> objMessage = TestDataFactory.createMessages(5);
        insert objMessage;        
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
        MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Synced','Upload','SpouseID1.txt');
        insert objDocumentIntegrationEngine;
        
    }
    
    static testmethod void SendMessage() {
        Test.startTest();
        	MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());
            MCFD_SendMessagesToICM.SendMessage(objMessage.Id);
        Test.stopTest();
    }
    
    static testmethod void SendMessageFail() {
        Test.startTest();
        	MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGeneratorFail());
            MCFD_SendMessagesToICM.SendMessage(objMessage.Id);
        Test.stopTest();
    }
    
    static testmethod void SendMessageEmpty() {
        Test.startTest();
        	MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
        	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            MCFD_SendMessagesToICM.SendMessage(objMessage.Id);
        Test.stopTest();
    }
    
    static testmethod void fetchUserDetails() {
        User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];
        Test.startTest();
        	System.runAs(objUser) {
            	MCFD_SendMessagesToICM.fetchUserDetails();
        	}
        Test.stopTest();
    }
    
    static testmethod void SetMessageToRead() {
        Test.startTest();
        	MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
            MCFD_SendMessagesToICM.SetMessageToRead(objMessage.Id);
        Test.stopTest();
    }
    
    static testmethod void fetchMessage() {
        Test.startTest();
        	MCFD_SendMessagesToICM.fetchMessage();
        Test.stopTest();
    }
    
    static testmethod void DeleteMessageApex() {
        Test.startTest();
        	MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
            MCFD_SendMessagesToICM.DeleteMessageApex(objMessage.Id);
        Test.stopTest();
    }
    
   	static testmethod void DeleteMessageApexFail() {
        Test.startTest();
       		MCFD_Message__c objMessage = [SELECT id FROM MCFD_Message__c LIMIT 1];
            MCFD_SendMessagesToICM.DeleteMessageApex('a085B000001clbXQAQ');
        Test.stopTest();
    }
    
    static testMethod void saveTheChunk(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
            String fileName=objCustomAttachment.MCFD_Attachment_Name__c;
            String base64Data='abcdefghijklmnopqrstuv ='; 
            String contentType=objStandarAttachment.ContentType;
            String fileId=objStandarAttachment.Id;
			MCFD_SendMessagesToICM.saveTheChunk( fileName, base64Data, contentType, fileId);
        Test.stopTest();
    }
    
    static testMethod void saveTheChunkFail(){  
        Test.startTest();
        	MCFD_Attachment__c objCustomAttachment=[SELECT id,CreatedById,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	Attachment objStandarAttachment=[SELECT id,CreatedDate ,Name,ParentId,ContentType FROM Attachment WHERE Name = 'testFileName' LIMIT 1];
            String fileName=objCustomAttachment.MCFD_Attachment_Name__c;
            String base64Data='abcdefghijklmnopqrstuv ='; 
            String contentType=objStandarAttachment.ContentType;
            String fileId='';
			MCFD_SendMessagesToICM.saveTheChunk( fileName, base64Data, contentType, fileId);
        Test.stopTest();
    }
    
    static testMethod void SendAttachmentRequestToICM(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id,Name FROM Attachment WHERE Name = 'testFileName']; 
         	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	
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
        	//MCFD_SendMessagesToICM.SendAttachmentRequestToICM(XMLrequest,objCustomAttachment.id,objStandarAttachment.Name);
        Test.stopTest();
    }
    
    static testMethod void SendAttachmentRequestToICMfailMock(){  
        	Attachment objStandarAttachment=[SELECT id,Name FROM Attachment WHERE Name = 'testFileName']; 
         	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	
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
        	MCFD_SendMessagesToICM.SendAttachmentRequestToICM(XMLrequest,objCustomAttachment.id,objStandarAttachment.Name);
    }
    
    static testMethod void SendAttachmentRequestToICMFail(){  
        Test.startTest();
        	Attachment objStandarAttachment=[SELECT id,Name FROM Attachment WHERE Name = 'testFileName']; 
         	MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         	
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
        	MCFD_SendMessagesToICM.SendAttachmentRequestToICM(XMLrequest,objCustomAttachment.id,objStandarAttachment.Name);
        Test.stopTest();
    }
    
    static testMethod void getAttachment(){  
        MCFD_Attachment__c objCustomAttachment=[SELECT id,CreatedById,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];      
        User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];
        Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        Test.startTest(); 
        	System.runAs(objUser) {
        		string IdAttachment=objCustomAttachment.id;
          //  	MCFD_SendMessagesToICM.getAttachment(IdAttachment, 'Received');
        	}
        Test.stopTest();
    }

 	static testMethod void getAttachmentSent(){  
        MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
        User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];       
        Test.startTest(); 
        	System.runAs(objUser) {
                Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        		string IdAttachment=objCustomAttachment.id;
            	MCFD_SendMessagesToICM.getAttachment(IdAttachment, 'Sent');
                MCFD_SendMessagesToICM.getAttachment(IdAttachment, 'Test');                
        	}
        Test.stopTest();
    }
    
	static testmethod void InsertReplyMessage() {
        MCFD_Message__c objMessage = [SELECT id, ICM_Program_Type__c, ICM_Case_Id__c, ICM_Case_Name__c,ICM_Case_Worker_Last_Name__c,ICM_Date_Message_Sent__c,ICM_Contact_Id__c,ICM_Conversation_Id__c,ICM_Client_Unread_Flag__c,ICM_Case_Worker_First_Name__c, Message_Type__c,ICM_Case_Worker_IDIR__c,ICM_Disable_Reply__c,ICM_Message_Id__c,Message_Body__c,Message_Status__c,Message_Subject__c,Portal_Message_Read__c,ICM_SR_Id__c FROM MCFD_Message__c LIMIT 1];      
		Attachment objAttachment = [SELECT id, ParentId FROM Attachment LIMIT 1];
        List<Id> listIdAtt = new List<Id>();
        listIdAtt.add(objAttachment.Id);
        listIdAtt.add(objAttachment.Id);                                               
        User objUser = [SELECT Id, Name,email,ContactId FROM User WHERE email='standarduser@testorg.com'];
        Contact objContact =[SELECT id , ICM_Contact_Id__c FROM Contact WHERE id=:objUser.ContactId];
        objContact.ICM_Contact_Id__c='1-4D4KJC6';
        update objContact;
   		Test.startTest();
        	System.runAs(objUser)  {
                Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
                MCFD_SendMessagesToICM.CreateMessageXML(objMessage.Id);
                MCFD_SendMessagesToICM.fetchMessageRead(objMessage.Portal_Message_Read__c);
                MCFD_SendMessagesToICM.InsertReplyMessage(objMessage.ICM_Program_Type__c, objMessage.ICM_Case_Id__c, objMessage.ICM_Case_Name__c, 'Yes', 
                                                      objMessage.ICM_Case_Worker_First_Name__c, objMessage.ICM_Case_Worker_IDIR__c, objMessage.ICM_Case_Worker_Last_Name__c, 
                                                      objMessage.ICM_Client_Unread_Flag__c, objMessage.ICM_Contact_Id__c, objMessage.ICM_Conversation_Id__c, 
                                                      //objMessage.ICM_Date_Message_Sent__c, 
                                                      objMessage.ICM_Disable_Reply__c, objMessage.ICM_Message_Id__c, 
                                                      objMessage.Id, objMessage.Message_Body__c, objMessage.Message_Status__c, objMessage.Message_Subject__c, 
                                                 objMessage.Message_Type__c , objMessage.Portal_Message_Read__c, objMessage.ICM_SR_Id__c, listIdAtt);
               }
			Test.stopTest();
    }     
    
    static testmethod void InsertNewMessage() {       
        	MCFD_Message__c objMessage = [SELECT id, ICM_Program_Type__c, ICM_Case_Id__c, ICM_Case_Name__c, Message_Subject__c, Message_Body__c, ICM_SR_Id__c FROM MCFD_Message__c LIMIT 1];
          	Attachment objAttachment = [SELECT id, ParentId FROM Attachment LIMIT 1];
        	List<Id> listIdAttachment= new List<Id>();
        	listIdAttachment.add(objAttachment.Id);
        	listIdAttachment.add(objAttachment.Id);
			Test.startTest();                                        
        		User objUser = [SELECT Id, Name,email,ContactId FROM User WHERE email='standarduser@testorg.com'];
        		Contact objContact =[SELECT id , ICM_Contact_Id__c FROM Contact WHERE id=:objUser.ContactId];
        		objContact.ICM_Contact_Id__c='1-4D4KJC6';
        		update objContact;
        		System.runAs(objUser)  {
            		Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        			MCFD_SendMessagesToICM.InsertNewMessage(objMessage, objMessage.ICM_Program_Type__c, objMessage.ICM_Case_Id__c, objMessage.ICM_Case_Name__c, 'No', listIdAttachment);
        	 	}
        	Test.stopTest();  
    }       
}