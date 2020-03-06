/*********************************************************************************************************
Name            : MCFD_BatchCallForICMMessagesMockParam.cls  
Description     : This class is to setup a mock response when there are messages in DB to process
Created By      : ARDC ICM
Created Date    : 03/07/2018
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer           Date              Description
--------------------------------------------------------------------------------------------------------------                        
Liliana Trejo     03/07/2018         Original Version 
***************************************************************************************************************/
@isTest
global class MCFD_BatchCallForICMMessagesMockParam implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
    	res.setStatus('OK');
    	res.setStatusCode(200);
		String TempJSON = '<?xml version="1.0"?><payload><outboundMessages><OutboundMessage><ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName>'+
                '<ICMCaseName>TESTKPNEW, TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/><MessageStatus>Sent</MessageStatus>'+
                '<Subject>test_123</Subject><Body>test12345</Body><ProgramType>Autism</ProgramType><ClientUnreadFlag>N</ClientUnreadFlag>'+
                '<DateMessageSent>06/06/2017 00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</ICMCaseWorkerFirstName>'+
                '<ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID><ICMMessageID>1-4DHQ3A6</ICMMessageID>'+
                '<ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>3-Standard</ImportanceFlag><DisableReply>Y</DisableReply>'+
                '<MessageDueDate/><MessageType>Welcome Message</MessageType><OutboundMessageRecipients><OutboundMessageRecipient>'+
                '<ICMContactID>1-4D5AG6K</ICMContactID><ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients>'+
                '<OutboundMessageAttachments><OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMTemplate>CFL00510</ICMTemplate><ICMCategory>ICMCategory</ICMCategory><ICMSubCategory>TICMSubCategory</ICMSubCategory><ICMDescription>ICMDescription</ICMDescription>'+
                '<ICMAttachmentID>1-4D57XSO</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
                '<remainingMsgs>12</remainingMsgs></payload>';
    	res.setBody(TempJSON);
        return res;
  }

}