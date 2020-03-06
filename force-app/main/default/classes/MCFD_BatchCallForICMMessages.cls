/**************************************************************************************
Version         : 1.0 
Created Date    : 23 May 2017
Function        : Batchable class calls WM to retreive queued messages

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                23 May 2017         Original Version
* Pavan Dave                  19 Jul 2017         Added contact lookup on MCFD Messages (US 110)
* Pavan Dave                  21 Jul 2017         Handled ICM error response 
* Laura Perry                 22 Sept 2017        Related messages to salesforce contact
* PDAVE                       06 OCT 2017         Optmized SOQL for Attachment in execute method (written outside of for loop), 
                                                  Optimized DML on Message (populating Batch ID in Start method itself),
                                                  Optimized SOQL on MCFD_Message__c (in execute method)
                                                  Apex sharing for attachments,
                                                  Error logging in start and execute method
* PDAVE                       13 NOV 2017         Bug fix 5849                  
* PDAVE                       22 NOV 2017         Bug fix 5903 
* Vivek Mishra                01 Jun 2018		  Updated for US-4262             
*************************************************************************************/

global without sharing class MCFD_BatchCallForICMMessages implements Database.Batchable<Map<String, List<sObject>>>, Database.AllowsCallouts{
    
    List<Map<String, List<sObject>>> ReturnList = new List<Map<String, List<sObject>>>();
    Map<String, List<sObject>> ReturnMap = new Map<String, List<sObject>>();
    List<MCFD_Message__c> MessageList = new List<MCFD_Message__c>();
    List<MCFD_Attachment__c> AttachmentList = new List<MCFD_Attachment__c>();
    
	global Iterable<Map<String, List<sObject>>> start(Database.BatchableContext BC){
	    String  ICM_Counter  = System.Label.BatchCallForICMMessages_Counter;
	    System.debug('ICM_Counter: '+ICM_Counter);
        String JSONString = '{'+
            '"Count": "'+ICM_Counter+'",'+
            '"BatchId" : "'+BC.getJobId()+'",'+
            //'"BatchId" : "7074D000004weFnQAI",'+
            '"State" : "New"'+
            '}';
        //  String JSONString = '1';
        
        System.debug('Calling message fetch');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMToGetMessage');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000); 
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('Name', JSONString);
        gen.writeEndObject();
        
        req.setBody(gen.getAsString());
        System.debug(req.getBody()); 
        System.debug(req);
        
        Http http = new Http();
        try 
        {
            HTTPResponse res = http.send(req);
            returnJSON = res.getBody();
            System.debug('Response'+res.toString());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            System.debug(returnJSON);
            
		//	MCFD_Logger.log_integration_error('Send Messages To ICM', MCFD_Logger.Info, 'MCFD_BatchCallForICMMessages request' ,req.getBody());
		//	MCFD_Logger.log_integration_error('Send Messages To ICM', MCFD_Logger.Info, 'MCFD_BatchCallForICMMessages Response' ,returnJSON);			
      
              
      
            /*String TempJSON = '<?xml version="1.0"?><payload><outboundMessages><OutboundMessage><ICMCaseWorkerLastName>Rath</ICMCaseWorkerLastName>'+
                '<ICMCaseName>TESTKPNEW, TESTKPNEW</ICMCaseName><SRSubType>Application</SRSubType><AppointmentLocation/><MessageStatus>Sent</MessageStatus>'+
                '<Subject>test_123</Subject><Body>test12345</Body><ProgramType>CCS</ProgramType><ClientUnreadFlag>Y</ClientUnreadFlag>'+
                '<DateMessageSent>06/06/2017 00:00:55</DateMessageSent><ICMCaseID>1-4D5AIZQ</ICMCaseID><ICMCaseWorkerFirstName>Ruksmrutee</ICMCaseWorkerFirstName>'+
                '<ICMCaseWorkerIDIR>PS_RRATH</ICMCaseWorkerIDIR><ICMSrID>1-9502011109</ICMSrID><ICMMessageID>1-4DHQ3A6</ICMMessageID>'+
                '<ICMParentMessageID>1-4DHQ3A4</ICMParentMessageID><ImportanceFlag>3-Standard</ImportanceFlag><DisableReply>N</DisableReply>'+
                '<MessageDueDate/><MessageType>General Message</MessageType><OutboundMessageRecipients><OutboundMessageRecipient>'+
                '<ICMContactID>1-4D5AG6K</ICMContactID><ClientEmailAddress/></OutboundMessageRecipient></OutboundMessageRecipients>'+
                '<OutboundMessageAttachments><OutboundMessageAttachment><ICMAttachmentName>Adobe_CF2900</ICMAttachmentName>'+
                '<ICMAttachmentID>1-4D57XSO</ICMAttachmentID></OutboundMessageAttachment></OutboundMessageAttachments></OutboundMessage></outboundMessages>'+
                '<remainingMsgs>12</remainingMsgs></payload>';
            */

            Dom.Document doc = new Dom.Document();
            doc.load(returnJSON);
            
            //Retrieve the root element for this document.
            Dom.XMLNode payload = doc.getRootElement();
            //System.debug('root');
            //List<MCFD_Message__c> MessageList = new List<MCFD_Message__c>();
            
            
            
            Dom.XMLNode outboundMessagesList = payload.getChildElement('outboundMessages',null);
            if(outboundMessagesList != Null){
                List<Dom.XMLNode> ICMMessages = outboundMessagesList.getChildElements();
                Integer MessageLength = ICMMessages.size();
                //System.debug('MessageLength:'+MessageLength);
                if(MessageLength != null && MessageLength > 0)
                {
                    for(Dom.XMLNode Msgchild : outboundMessagesList.getChildElements()) 
                    {
                        MCFD_Message__c Message = new MCFD_Message__c();
						Message.Portal_Batch_Id__c = BC.getJobId();
                        Message.ICM_Case_Worker_Last_Name__c = Msgchild.getChildElement('ICMCaseWorkerLastName',null).getText();
                        Message.ICM_Case_Name__c = Msgchild.getChildElement('ICMCaseName',null).getText();
                        Message.ICM_SR_Sub_Type__c = Msgchild.getChildElement('SRSubType',null).getText();
                        
                        Message.ICM_Appointment_Location__c = Msgchild.getChildElement('AppointmentLocation',null).getText();
                        
                        if(Msgchild.getChildElement('MessageStatus',null).getText() == 'Sent')
                        {
                            Message.Message_Status__c = 'Sent from ICM';
                        }
                        
                        //Message.Message_Status__c = Msgchild.getChildElement('MessageStatus',null).getText();
                        
                        Message.Message_Subject__c = Msgchild.getChildElement('Subject',null).getText();
                        Message.Message_Body__c = Msgchild.getChildElement('Body',null).getText();
                        
                        if(Msgchild.getChildElement('ProgramType',null).getText() == 'CCS')
                        {
                            Message.ICM_Program_Type__c = 'Child Care Subsidy';
                        }
                        else if(Msgchild.getChildElement('ProgramType',null).getText() == 'Autism')
                        {
                            Message.ICM_Program_Type__c = 'Autism Funding';
                        }
                        //   Message.ICM_Program_Type__c = Msgchild.getChildElement('ProgramType',null).getText();
                        
                        if(Msgchild.getChildElement('ClientUnreadFlag',null).getText() == 'Y')
                        {
                            Message.ICM_Client_Unread_Flag__c = true;
                        }
                        else
                        {
                            Message.ICM_Client_Unread_Flag__c = false;
                        }
                        // Message.ICM_Client_Unread_Flag__c = Msgchild.getChildElement('ClientUnreadFlag',null).getText();

                        if(Msgchild.getChildElement('DateMessageSent',null).getText() != null && Msgchild.getChildElement('DateMessageSent',null).getText() != '')
                        {
                            String MessageSentDateString = Msgchild.getChildElement('DateMessageSent',null).getText();
                            String MessageSentDateStringConv = MessageSentDateString.SubString(6,10) + '-' + MessageSentDateString.SubString(0,2) + '-'
                                + MessageSentDateString.SubString(3,5) + MessageSentDateString.SubString(10,19);
                            Datetime MessageSentDateAsDateTime = datetime.valueOf(MessageSentDateStringConv);
                            
                            Message.ICM_Date_Message_Sent__c = MessageSentDateAsDateTime;
                            //Message.ICM_Date_Message_Sent__c = Msgchild.getChildElement('DateMessageSent',null).getText();
                        }
                        
                        Message.ICM_Case_Id__c = Msgchild.getChildElement('ICMCaseID',null).getText();
                        Message.ICM_Case_Worker_First_Name__c = Msgchild.getChildElement('ICMCaseWorkerFirstName',null).getText();
                        Message.ICM_Case_Worker_IDIR__c = Msgchild.getChildElement('ICMCaseWorkerIDIR',null).getText();
                        Message.ICM_SR_Id__c = Msgchild.getChildElement('ICMSrID',null).getText();
                        Message.ICM_Message_Id__c = Msgchild.getChildElement('ICMMessageID',null).getText();
                        Message.ICM_Conversation_Id__c = Msgchild.getChildElement('ICMParentMessageID',null).getText();
                        // Message.ICM_Importance_Flag__c = Msgchild.getChildElement('ImportanceFlag',null).getText();
                        if(Msgchild.getChildElement('DisableReply',null).getText() == 'Y')
                        {
                            Message.ICM_Disable_Reply__c = true;
                        }
                        else
                        {
                            Message.ICM_Disable_Reply__c = false;
                        }
                        
                        
                        if(Msgchild.getChildElement('MessageDueDate',null).getText()!= null && Msgchild.getChildElement('MessageDueDate',null).getText() != '')
                        {
                     /*       String MessageDueDateString = Msgchild.getChildElement('MessageDueDate',null).getText();
                            String MessageDueDateStringConv = MessageDueDateString.SubString(6,10) + '-' + MessageDueDateString.SubString(0,2) + '-'
                                + MessageDueDateString.SubString(3,5) + MessageDueDateString.SubString(10,19);
                            Datetime MessageDueDateAsDateTime = datetime.valueOf(MessageDueDateStringConv);
                            Message.ICM_Date_Message_Sent__c = MessageDueDateAsDateTime;*/
                            // Message.ICM_Message_Due_Date__c = Msgchild.getChildElement('MessageDueDate',null).getText();
                        }
                        
                        if(Msgchild.getChildElement('MessageType',null).getText() == 'General Message')
                        {
                            Message.Message_Type__c = 'General Message';
                        }else if(Msgchild.getChildElement('MessageType',null).getText() == 'Welcome Message'){        // PDAVE - Bug fix 3735
                            Message.Message_Type__c = 'Welcome Message';
                        }
                        
                        Dom.XmlNode OutboundRecipientList = Msgchild.getChildElement('OutboundMessageRecipients',null);
                        String icmContId;
                        for(Dom.XMLNode RecipientChild : OutboundRecipientList.getChildElements()) 
                        {  
                          icmContId = RecipientChild.getChildElement('ICMContactID',null).getText();
                                    if(icmContId != Null){          
                            Message.ICM_Contact_Id__c = icmContId;
                            //                  Message.ICM_Message_Id__c = RecipientChild.getChildElement('ClientEmailAddress',null).getText();          
                            //System.debug('map_contact_ICMId_SFDCId size ---'+map_contact_ICMId_SFDCId.size());
                            //if(!map_contact_ICMId_SFDCId.isEmpty() && map_contact_ICMId_SFDCId.containsKey(icmContId) && map_contact_ICMId_SFDCId.get(icmContId) != Null ){
                                //commented out by Laura, because it looks like there is nothing being populated here most of the time
                                // uncommented by Pavan, for bug fix 5849
                                //Message.Contact__c = map_contact_ICMId_SFDCId.get(icmContId);  
                                
                                //System.debug('map_contact_ICMId_SFDCId containsKey ---'+ icmContId + '--->' + map_contact_ICMId_SFDCId.get(icmContId));
                                
                                // commmented by Pavan. If no records found it throws an exception System.QueryException: List has no rows for assignment to SObject
                                //Contact matchingContact = [SELECT Id, MCFD_Status__c, ICM_Contact_Id__c FROM Contact WHERE 
                                //                        MCFD_Status__c <> 'Deactivated' AND ICM_Contact_Id__c =: icmContId LIMIT 1];
                                
                                //System.debug('matchingContact.id-->'+matchingContact.Id);
                                //Message.Contact__c = matchingContact.Id;
                           //}                                
                                
                          }          
                        }
                        
                        Dom.XmlNode OutboundAttachmentList = Msgchild.getChildElement('OutboundMessageAttachments',null);
                        if(OutboundAttachmentList!=null)
                        {
                        	/* Start:Added as Part of US-4262 by Vivek Mishra*/
                        	String ICMTemplateNumber;
                        	String ConvertedAttName;
                        	String AttFileName;
                        	String AttDescription;
                        	String cCaseType;
                        	Integer intIndex;
                        	Map<String,String> icmAttachmentMapping = new Map<String,String>(); 
                            List<Attachment_Setting__mdt> attSettingList = [select Label,ConvertedAttachmentName__c from Attachment_Setting__mdt ];
                            for(Attachment_setting__mdt a:attSettingList){
                            	icmAttachmentMapping.put(a.label, a.ConvertedAttachmentName__c);
                            }
                             
                            for(Dom.XMLNode AttachmentChild : OutboundAttachmentList.getChildElements()) 
                            {
                                MCFD_Attachment__c ICMAttachment = new MCFD_Attachment__c();
                                ICMTemplateNumber = AttachmentChild.getChildElement('ICMTemplate',null).getText();
                                AttFileName    = AttachmentChild.getChildElement('ICMAttachmentName',null).getText();
                                intIndex = AttFileName.lastindexOf('.');
                                if(String.isNotBlank(ICMTemplateNumber))
                                {
                                	ConvertedAttName   = icmAttachmentMapping.get(ICMTemplateNumber);
                                	if (ConvertedAttName != Null)
                                	{
                                	
                                	system.debug('### intIndex'+intIndex);
                     	            System.debug('### extension'+ AttFileName.right(AttFileName.length()-intIndex));
                                	ConvertedAttName = ConvertedAttName + AttFileName.right(AttFileName.length()-intIndex);             
                                	ICMAttachment.MCFD_Attachment_Name__c = ConvertedAttName;
                                	}
                                	else
                                	{
                                		cCaseType = Message.ICM_Program_Type__c;
                                		if (cCaseType == 'Child Care Subsidy')
                                		{
                                
                                	        ConvertedAttName = 'Information Letter' + AttFileName.right(AttFileName.length()-intIndex);
                                	        ICMAttachment.MCFD_Attachment_Name__c = ConvertedAttName;
                                		}
                                		else
                                		{
                          
                                	        ConvertedAttName = 'Autism Information' + AttFileName.right(AttFileName.length()-intIndex);
                                	        ICMAttachment.MCFD_Attachment_Name__c = ConvertedAttName;
                                		}
                                		
                                		
                                	}
                                	
                                }
                                else
                                {
                                	ICMAttachment.MCFD_Attachment_Name__c = AttachmentChild.getChildElement('ICMAttachmentName',null).getText();
                                	
                                }
                                
                                
                                
                                //ICMAttachment.MCFD_Attachment_Name__c
                                ICMAttachment.ICM_Attachment_Id__c = AttachmentChild.getChildElement('ICMAttachmentID',null).getText();
                                ICMAttachment.ICM_Template__c = AttachmentChild.getChildElement('ICMTemplate',null).getText();
                                ICMAttachment.ICM_Category__c = AttachmentChild.getChildElement('ICMCategory',null).getText();
                                ICMAttachment.ICMSubCategory__c = AttachmentChild.getChildElement('ICMSubCategory',null).getText();
                                ICMAttachment.ICM_Description__c = AttachmentChild.getChildElement('ICMDescription',null).getText();
                                ICMAttachment.ICM_Message_Id__c = Msgchild.getChildElement('ICMMessageID',null).getText();
                                AttachmentList.add(ICMAttachment);
                                /* End:Added as Part of US-4262 by Vivek Mishra*/
                            }
            
                        }
                        
                        
                                        
                        //System.debug('OrderDtlID: ' + Message);
                        MessageList.add(Message);
                        
                        //ReturnMap.put('MessageList',MessageList);
                        ReturnMap.put('AttachmentList',AttachmentList);
                        //ReturnList.add(ReturnMap);
                    }
                    //----------------- PDAVE: Bug fix : 5903 Change Summary : Start-----------------//             
                    // Find SFDC Contact Id using ICM Contact ID (in XML) and populate Contact Lookup //
                    // Find SFDC Contact Id using SR Number (in XML)                                // 
                    //-----------------------------------------------------------------------//
                    
                    // First find SFDC Contact Id using ICM Contact ID (in XML) and populate Contact Lookup //
                    
                    List<String> lstICMContactId = new List<String>();
                    for(MCFD_Message__c item: MessageList){
                        if(item.ICM_Contact_Id__c != Null && item.ICM_Contact_Id__c != ''){
                            lstICMContactId.add(item.ICM_Contact_Id__c);
                        }
                    }
                    System.debug('lstICMContactId.size()--'+lstICMContactId.size());
                    if(!lstICMContactId.isEmpty()){
                        Map<String, Id> map_contact_ICMId_SFDCId = new Map<String, Id>();
                        String ICMContIDonMsg;
                        // This query can handle upto 50 million contact in one go
                        // BC population in 2017 is 2.5 million :)
                        Database.QueryLocator contacts = Database.getQueryLocator([SELECT Id, ICM_Contact_Id__c 
                                              FROM Contact 
                                              WHERE MCFD_GUID__c <> Null //Removed MCFD_BCEID__c and replaced with gUID to allow SHIELD encryption of BCEID
                                              AND ICM_Contact_Id__c IN : lstICMContactId]);
                      
                        Database.QueryLocatorIterator it = contacts.iterator();
                        Contact cont;
                        while(it.hasNext()){
                            cont = (Contact)it.next();
                            map_contact_ICMId_SFDCId.put(cont.ICM_Contact_Id__c, cont.Id);
                        }
                
                       System.debug('map_contact_ICMId_SFDCId.size()--'+map_contact_ICMId_SFDCId.size());
                       for(MCFD_Message__c item: MessageList){
                           ICMContIDonMsg = item.ICM_Contact_Id__c;
                           if(!map_contact_ICMId_SFDCId.isEmpty() 
                               && map_contact_ICMId_SFDCId.containsKey(ICMContIDonMsg) 
                               && map_contact_ICMId_SFDCId.get(ICMContIDonMsg) != Null ){
                               System.debug('map_contact_ICMId_SFDCId containsKey ---'+ ICMContIDonMsg + '--->' + map_contact_ICMId_SFDCId.get(ICMContIDonMsg));
                               item.Contact__c = map_contact_ICMId_SFDCId.get(ICMContIDonMsg);  
                           }
                           
                       }
                    }
                    
                    // Find SFDC Contact Id using SR Number (in XML)                                // 
                    
                    List<String> lstICMSRId = new List<String>();
                    for(MCFD_Message__c item: MessageList){
                        if(item.ICM_SR_Id__c != Null && item.ICM_SR_Id__c != ''){
                            lstICMSRId.add(item.ICM_SR_Id__c);
                        }
                    }
                    System.debug('lstICMSRId.size()--'+lstICMSRId.size());
                    if(!lstICMSRId.isEmpty()){
                        Map<String, Id> map_ICMSRId_SFDCPriAppContId = new Map<String, Id>();
                        String ICM_SR_Id;
                        // This query can handle upto 50 million contact in one go
                        Database.QueryLocator requests = Database.getQueryLocator([SELECT Id, Primary_Applicant__c, ICM_SR_Number__c 
                                              FROM Request__c 
                                              WHERE (Primary_Applicant__c <> Null OR
                                              (Primary_Applicant__c = Null AND (MCFD_Type__c = 'Case Access Request - Autism Funding' 
                                                                                OR MCFD_Type__c = 'Case Access Request - Child Care Subsidy')))
                                              AND ICM_SR_Number__c IN : lstICMSRId]);
                      
                        Database.QueryLocatorIterator it_req = requests.iterator();
                        Request__c requt;
                        while(it_req.hasNext()){
                            requt = (Request__c)it_req.next();
                            map_ICMSRId_SFDCPriAppContId.put(requt.ICM_SR_Number__c, requt.Primary_Applicant__c);
                        }
                
                       System.debug('map_ICMSRId_SFDCPriAppContId.size()--'+map_ICMSRId_SFDCPriAppContId.size());
                       for(MCFD_Message__c item: MessageList){
                           ICM_SR_Id = item.ICM_SR_Id__c;
                           // use this map only if Contact__c is still blank
                           if(!(item.Contact__c != null)    //PDAVE: Task 5987- Broken Null Check
                               &&!map_ICMSRId_SFDCPriAppContId.isEmpty() 
                               && map_ICMSRId_SFDCPriAppContId.containsKey(ICM_SR_Id) 
                               && map_ICMSRId_SFDCPriAppContId.get(ICM_SR_Id) != Null ){
                               System.debug('map_ICMSRId_SFDCPriAppContId containsKey ---'+ ICM_SR_Id + '--->' + map_ICMSRId_SFDCPriAppContId.get(ICM_SR_Id));
                               item.Contact__c = map_ICMSRId_SFDCPriAppContId.get(ICM_SR_Id);  
                           }
                           
                       }
                    }
                    
                  ReturnMap.put('MessageList',MessageList);
                  ReturnList.add(ReturnMap);
                    //----------------- PDAVE: Bug fix : 5903 Change Summary : End -----------------//              
                }
            }else{              
                //MCFD_Logger.log(MCFD_Logger.INFO, 'MCFD_BatchCallForICMMessages', 'Message: no outboundMessages tag found in ICM response'+'\n'+'Detail: No Valid documents to be sent');
            }
            
            Dom.XMLNode remMsgList = payload.getChildElement('remainingMsgs', null);
            if(remMsgList != Null){
                String RemainingMessages = remMsgList.getText();
            }           
            
            //return ReturnList; // PDAVE: Commenting return as this will not allow catch block to handle the exceptions.
            
        }
        catch(System.CalloutException e) 
        {
			MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_BatchCallForICMMessages' , 'Start Method:-> Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }     
        
        
        
        return ReturnList;
        //return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Map<String, List<sObject>>> scope){
        try{		
			
			List<Database.Saveresult> insertResults= Database.insert(scope[0].get('MessageList'));
			List<Id> listOfIds = new List<Id>();
			for (Database.SaveResult sr : insertResults) {
				if (sr.isSuccess()) {
					listOfIds.add(sr.getId());
				}
			}
			// PDAVE - Commenting SOQL and DML. Portal_Batch_Id__c has been populated in start method itself now. SOQL and DML can be saved.
			/*List<MCFD_Message__c> InsertedMessageList = [Select Id,Portal_Batch_Id__c from MCFD_Message__c where Id in :listOfIds];
			for (MCFD_Message__c m: InsertedMessageList)
			{
				m.Portal_Batch_Id__c = BC.getJobId();
			}
			update InsertedMessageList;
			*/
			
			List<Database.Saveresult> insertAttachmentsResults= Database.insert(scope[0].get('AttachmentList'));
			List<Id> listOfAttachIds = new List<Id>();
			for (Database.SaveResult sr : insertAttachmentsResults) {
				if (sr.isSuccess()) {
					listOfAttachIds.add(sr.getId());
				}
			}
			
			// --------------------------------------------------------------------------------------- //
			// ----------- PDAVE : Optimized SOQL on MCFD_Message__c (taken out from for loop)-------- //
			// --------------------------------------------------------------------------------------- //
			
			List<MCFD_Attachment__c> InsertedAttachmentList = [Select Id,ICM_Message_Id__c from MCFD_Attachment__c where Id in :listOfAttachIds];
			List<String> lstICMMsgId = new List<String>();
			
			for(MCFD_Attachment__c item: InsertedAttachmentList){
				lstICMMsgId.add(item.ICM_Message_Id__c);
			}
			
			List<MCFD_Message__c> relatedMessages = new List<MCFD_Message__c>([SELECT Id, ICM_Message_Id__c, Contact__c 
																				   FROM MCFD_Message__c 
																				   WHERE ICM_Message_Id__c IN: lstICMMsgId]);
			Map<String, Id> map_ICMMsgId_SFDCMsgId = new Map<String, Id>();
			Map<String, Id> map_ICMMsgId_SFDCContId = new Map<String, Id>();	
			Map<String, Id> map_SFDCContId_SFDCPortalUsrId = new Map<String, Id>();
			List<Id> listSFDCContId = new List<Id>();
			
			for(MCFD_Message__c item: relatedMessages){
				map_ICMMsgId_SFDCContId.put(item.ICM_Message_Id__c, item.Contact__c);
				map_ICMMsgId_SFDCMsgId.put(item.ICM_Message_Id__c, item.Id);
				listSFDCContId.add(item.Contact__c);
			}
			
			List<User> lstUser = new List<User>([SELECT Id, ContactId FROM User WHERE ContactId IN: listSFDCContId]);
			for(User item: lstUser){
				map_SFDCContId_SFDCPortalUsrId.put(item.ContactId, item.Id);
			}
			system.debug('map_ICMMsgId_SFDCContId size--->'+map_ICMMsgId_SFDCContId.size());
			system.debug('map_ICMMsgId_SFDCMsgId size--->'+map_ICMMsgId_SFDCMsgId.size());
			system.debug('map_SFDCContId_SFDCPortalUsrId size--->'+map_SFDCContId_SFDCPortalUsrId.size());
			system.debug('listSFDCContId size--->'+listSFDCContId.size());
			
            
			List<MCFD_Attachment__Share> lstAttchShr = new List<MCFD_Attachment__Share>();
			MCFD_Attachment__Share attchShr;
			Id portalUserId;
			for (MCFD_Attachment__c a: InsertedAttachmentList)
			{
				//MCFD_Message__c msg = [Select Id, ICM_Message_Id__c, Contact__c from MCFD_Message__c where ICM_Message_Id__c =: a.ICM_Message_Id__c limit 1];
				//a.Linked_Message_Id__c = msg.Id;
				if(map_ICMMsgId_SFDCMsgId.containsKey(a.ICM_Message_Id__c)){
					a.Linked_Message_Id__c = map_ICMMsgId_SFDCMsgId.get(a.ICM_Message_Id__c);
					
					// ------------------------------------------------------------------------------------ //
					// ----------- PDAVE: Apex sharing - Share Attachment records with Portal User -------- //
					// ----------------------------------------------------------------------------------- //
					
					if(map_SFDCContId_SFDCPortalUsrId.containsKey(map_ICMMsgId_SFDCContId.get(a.ICM_Message_Id__c))){			
						portalUserId = map_SFDCContId_SFDCPortalUsrId.get(map_ICMMsgId_SFDCContId.get(a.ICM_Message_Id__c));
						system.debug('Atttachment Id---'+a.Id+'----'+'Share with Portal User---'+portalUserId);
						attchShr = new MCFD_Attachment__Share();
						attchShr.ParentId = a.Id;
						attchShr.UserOrGroupId = portalUserId;
						attchShr.AccessLevel = 'Read';
						attchShr.RowCause = Schema.MCFD_Attachment__Share.RowCause.Manual;
						lstAttchShr.add(attchShr);

					}else{
						system.debug('Not found --> map_SFDCContId_SFDCPortalUsrId.containsKey(map_ICMMsgId_SFDCContId.get(a.ICM_Message_Id__c))-->'+map_ICMMsgId_SFDCContId.get(a.ICM_Message_Id__c));
					}
				}else{
					system.debug('Not found --> (map_ICMMsgId_SFDCMsgId.containsKey(a.ICM_Message_Id__c)-->'+a.ICM_Message_Id__c);
				}
				
			}
			if(!map_ICMMsgId_SFDCMsgId.isEmpty()){
				update InsertedAttachmentList;
			}
			if(!lstAttchShr.isEmpty()){
				List<Database.SaveResult> lstSr = Database.insert(lstAttchShr,false);
				
				for(Database.SaveResult sr: lstSr){
					// Process the save results.
					if(sr.isSuccess()){
						// Indicates success
						//return true;
					}
					else {
						// Get first save result error.
						Database.Error err = sr.getErrors()[0];

						// Check if the error is related to trival access level.
						// Access level must be more permissive than the object's default.
						// These sharing records are not required and thus an insert exception is acceptable. 
						if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
							err.getMessage().contains('AccessLevel')){
							// Indicates success.
							//return true;
						}
						else{
							// Indicates failure.
							MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_BatchCallForICMMessages' , 'Execute method. Error StatusCode: '+err.getStatusCode()+'\n'+'Error Message: '+ err.getMessage());
							//return false;
						}
					}
				}
			}
		}catch(Exception e){
			MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_BatchCallForICMMessages' , 'Execute Method:-> Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
		}        
    }
   
    global void finish(Database.BatchableContext BC){
        MCFD_Message_Integration_Engine__c MessageIntegrationEngine = new MCFD_Message_Integration_Engine__c();
        MessageIntegrationEngine.Batch_Status__c = 'Synced';
        MessageIntegrationEngine.Portal_Batch_Id__c = BC.getJobId();
        insert MessageIntegrationEngine;
    }
    
    
}