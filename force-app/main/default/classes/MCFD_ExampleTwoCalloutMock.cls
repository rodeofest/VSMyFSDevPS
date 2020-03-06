/*********************************************************************************************************
Name            : MCFD_ExampleTwoCalloutMock.cls  
Description     : This class is to setup a mock response  
Created By      : Deloitte
Created Date    : 12/June/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      19/June/2017   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/

@isTest
global class MCFD_ExampleTwoCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    //res.setBody('{"method": "POST","SRNumber":"bar"}');
    //res.setBody('{"payload": {"outboundMessages": { "OutboundMessage": { "ICMCaseWorkerLastName": "Rath", "ICMCaseName": "TESTKPNEW, TESTKPNEW", "SRSubType": "Application", "MessageStatus": "Sent", "Subject": "test_123", "Body": "test12345", "ProgramType": "CCS", "ClientUnreadFlag": "Y", "DateMessageSent": "06/06/2017 00:00:55", "ICMCaseID": "1-4D5AIZQ", "ICMCaseWorkerFirstName": "Ruksmrutee", "ICMCaseWorkerIDIR": "PS_RRATH", "ICMSrID": "1-9502011109", "ICMMessageID": "1-4DHQ3A6", "ICMParentMessageID": "1-4DHQ3A4", "ImportanceFlag": "3-Standard", "DisableReply": "N", "MessageType": "General Message", "OutboundMessageRecipients": { "OutboundMessageRecipient": { "ICMContactID": "1-4D5AG6K" } }, "OutboundMessageAttachments": { "OutboundMessageAttachment": { "ICMAttachmentName": "Adobe_CF2900", "ICMAttachmentID": "1-4D57XSO" } } } }, "remainingMsgs": "12" } }');
    res.setBody('<?xml version="1.0"?><payload><outboundMessages><OutboundMessage><ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName><ICMCaseName>TESTKPNEW, TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/><MessageStatus>Sent</MessageStatus><Subject>test_123</Subject><Body>test12345</Body><ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/06/2017 00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID><ICMMessageID>1-4DHQ3A6</ICMMessageID><ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4D5AG6K</ICMContactID><ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients><OutboundMessageAttachments><OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName><ICMAttachmentID>1-4D57XSO</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages><remainingMsgs>12</remainingMsgs></payload>');
    return res;
  }
}