/*********************************************************************************************************
Name            : MCFD_ExampleTwoCalloutMock2.cls  
Description     : This class is to setup a mock response when there are messages in DB to process
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
global class MCFD_ExampleTwoCalloutMock2 implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
    	res.setStatus('OK');
    	res.setStatusCode(200);
        String JsonDoc='{"docWMResponse": {"payload": { "outboundMessages": {"OutboundMessage": [{"ICMCaseWorkerLastName":'+
        '"Administrator","ICMCaseName": "SUN, EARTH","MessageStatus": "Sent","Subject": "Request to Amend an Authorization has been processed",'+
        '"Body": "Your Request to Amend an Authorization for your service provider(s) has been processed. Please review the change(s) made in '+
        'the View Authorizations link, located on your dashboard.'+ 
		'Autism Funding","ProgramType": "Autism","ClientUnreadFlag": "Y","DateMessageSent": "06/27/2018 14:40:36",'+
        '"ICMCaseID": "1-4PJ4802","ICMCaseWorkerFirstName": "Siebel","ICMCaseWorkerIDIR": "SADMIN","ICMMessageID": "1-4PJNQNY",'+
        '"ICMParentMessageID": "1-4PJNQNW","ImportanceFlag": "3-Standard","DisableReply": "N","MessageType": "General Message",'+
        ' "OutboundMessageRecipients": {"OutboundMessageRecipient": { "ICMContactID": "1-4PJ486S" } }},{'+
        '"ICMCaseWorkerLastName": "Administrator","ICMCaseName": "JACOBSON, JACOB","MessageStatus": "Sent","Subject":'+
        '"Request to Amend an Authorization has been processed","Body": "Your Request to Amend an Authorization for your'+
        'service provider(s) has been processed. Please review the change(s) made in the View Authorizations link, located on'+
        'your dashboard. Autism Funding","ProgramType": "Autism","ClientUnreadFlag": "Y","DateMessageSent": "06/27/2018 14:40:48",'+
        '"ICMCaseID": "1-4PALSTR","ICMCaseWorkerFirstName": "Siebel","ICMCaseWorkerIDIR": "SADMIN","ICMMessageID": "1-4PJNQPS",'+
        '"ICMParentMessageID": "1-4PJNQPQ","ImportanceFlag": "3-Standard","DisableReply": "N","MessageType": "General Message",'+
        '"OutboundMessageRecipients": {"OutboundMessageRecipient": { "ICMContactID": "1-4PALVWE" } } }]}, "remainingMsgs": "0"}}}';
        //res.setBody(JsonDoc);
       // res.setBody('<?xml version="1.0" encoding="UTF-8"?><payload><OutboundMessage><ICMCaseWorkerLastName>Administrator</ICMCaseWorkerLastName><ICMCaseName>SUN, EARTH</ICMCaseName></OutboundMessage></payload>');
       res.setBody('<payload><OutboundMessage><ICMCaseWorkerLastName>Administrator</ICMCaseWorkerLastName><ICMCaseName>SUN, EARTH</ICMCaseName><SRSubType/><AppointmentLocation/><MessageStatus>Sent</MessageStatus><Subject>Request to Amend an Authorization has been processed</Subject><Body>Your Request to Amend an Authorization for your service provider(s) has been processed. Please review the change(s) made in the View Authorizations link, located on your dashboard. Autism Funding</Body><ProgramType>Autism</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/27/2018 14:40:36</DateMessageSent><ICMCaseID>1-4PJ4802</ICMCaseID><ICMCaseWorkerFirstName>Siebel</ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>SADMIN</ICMCaseWorkerIDIR><ICMSrID/><ICMMessageID>1-4PJNQNY</ICMMessageID><ICMParentMessageID>1-4PJNQNW</ICMParentMessageID><ImportanceFlag>3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4PJ486S</ICMContactID><ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients></OutboundMessage><OutboundMessage><ICMCaseWorkerLastName>Administrator</ICMCaseWorkerLastName><ICMCaseName>JACOBSON, JACOB</ICMCaseName><SRSubType/><AppointmentLocation/><MessageStatus>Sent</MessageStatus><Subject>Request to Amend an Authorization has been processed</Subject><Body>Your Request to Amend an Authorization for your service provider(s) has been processed. Please review the change(s) made in the View Authorizations link, located on your dashboard. Autism Funding</Body><ProgramType>Autism</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag><DateMessageSent>06/27/2018 14:40:48</DateMessageSent><ICMCaseID>1-4PALSTR</ICMCaseID><ICMCaseWorkerFirstName>Siebel</ICMCaseWorkerFirstName><ICMCaseWorkerIDIR>SADMIN</ICMCaseWorkerIDIR><ICMSrID/><ICMMessageID>1-4PJNQPS</ICMMessageID><ICMParentMessageID>1-4PJNQPQ</ICMParentMessageID><ImportanceFlag>3-Standard</ImportanceFlag><DisableReply>N</DisableReply><MessageDueDate/><MessageType>General Message</MessageType><OutboundMessageRecipients><OutboundMessageRecipient><ICMContactID>1-4PALVWE</ICMContactID><ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients></OutboundMessage><remainingMsgs>0</remainingMsgs></payload>');
    return res;
  }

}