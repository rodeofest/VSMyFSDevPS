/*********************************************************************************************************
Name            : MCFD_ExampleTwoCalloutMockError.cls  
Description     : This class is to setup a mock error response when there are messages in DB to process
Created By      : Deloitte
Created Date    : 12/June/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Rosario      28/June/2018   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/
@isTest
global class MCFD_ExampleTwoCalloutMockError implements HttpCalloutMock {
    global HttpResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
    	res.setStatus('OK');
    	res.setStatusCode(200);
    	//res.setBody('{"method": "POST","SRNumber":"bar"}');
    	//res.setBody('{"payload": {"outboundMessages": { "OutboundMessage": { "ICMCaseWorkerLastName": "Rath", "ICMCaseName": "TESTKPNEW, TESTKPNEW", "SRSubType": "Application", "MessageStatus": "Sent", "Subject": "test_123", "Body": "test12345", "ProgramType": "CCS", "ClientUnreadFlag": "Y", "DateMessageSent": "06/06/2017 00:00:55", "ICMCaseID": "1-4D5AIZQ", "ICMCaseWorkerFirstName": "Ruksmrutee", "ICMCaseWorkerIDIR": "PS_RRATH", "ICMSrID": "1-9502011109", "ICMMessageID": "1-4DHQ3A6", "ICMParentMessageID": "1-4DHQ3A4", "ImportanceFlag": "3-Standard", "DisableReply": "N", "MessageType": "General Message", "OutboundMessageRecipients": { "OutboundMessageRecipient": { "ICMContactID": "1-4D5AG6K" } }, "OutboundMessageAttachments": { "OutboundMessageAttachment": { "ICMAttachmentName": "Adobe_CF2900", "ICMAttachmentID": "1-4D57XSO" } } } }, "remainingMsgs": "12" } }');
    	res.setBody('<?xml version="1.0"?><docWMResponse><payload><errorDetails><errorMessage>No Valid documents to be sent</errorMessage><errorCode>01</errorCode></errorDetails></payload></docWMResponse>');
    	return res;
    }
}