public without sharing class MCFD_SendMessagesToICM {
    
    @AuraEnabled @future(callout = true)
    public static void SendMessage(Id MessageObjectId)
    {
        
        String JSONString = CreateMessageXML(MessageObjectId);
        System.debug('Calling submit');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMToSendMessage');
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
//			MCFD_Logger.log_integ_err_for_message('Send Messages To ICM', MCFD_Logger.Info, 'MCFD_SendMessagesToICM request' ,JSONString, MessageObjectId);
//			MCFD_Logger.log_integ_err_for_message('Send Messages To ICM', MCFD_Logger.Info, 'MCFD_SendMessagesToICM Response' ,returnJSON, MessageObjectId);			
            if(res.getStatusCode()== 200) //for success response from ICM
            {
                JSONParser parser = JSON.createParser(returnJSON);
                String ICMParentID;
                while (parser.nextToken() != null) 
                {   
                    
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'parentID')) 
                    {
                        parser.nextToken();
                        ICMParentID = parser.getText();
                     }
                }
                //PDAVE: Task 5777 - Broken Null Check
                if(ICMParentID != Null && ICMParentID != '')
                {
                    MCFD_Message__c msg = [SELECT id, ICM_Conversation_Id__c, Message_Integration_Status__c
                                           FROM  MCFD_Message__c 
                                           WHERE id =: MessageObjectId];
                    msg.ICM_Conversation_Id__c = ICMParentID;
                    msg.Message_Integration_Status__c = 'Synced';
                    update msg;                
                }
                else //checking if there is integration error due to bad input request
                {
                    MCFD_Message__c msg = [SELECT id, Message_Integration_Status__c
                                           FROM  MCFD_Message__c 
                                           WHERE id =: MessageObjectId];
                    msg.Message_Integration_Status__c = 'Submission error';
                    update msg;
                    MCFD_Logger.log_integ_err_for_message('Send Messages To ICM', MCFD_Logger.ERROR, 'MCFD_SendMessagesToICM' ,'Integration error with ICM', MessageObjectId);
                }
            }
            else // if integration timeouts or other integration status code from ICM
            {
                MCFD_Message__c msg = [SELECT id, Message_Integration_Status__c
                                           FROM  MCFD_Message__c 
                                           WHERE id =: MessageObjectId];
                msg.Message_Integration_Status__c = 'Submission error';
                update msg;
                MCFD_Logger.log_integ_err_for_message('Send Messages To ICM', MCFD_Logger.ERROR, 'MCFD_SendMessagesToICM' ,'Integration error with ICM', MessageObjectId);
            }
                
            
        } 
        catch(System.CalloutException e) //for any other exception
        {	
            MCFD_Message__c msg = [SELECT id, Message_Integration_Status__c
                                           FROM  MCFD_Message__c 
                                           WHERE id =: MessageObjectId];
            msg.Message_Integration_Status__c = 'Submission error';
            update msg;
			MCFD_Logger.log_integ_err_for_message('Send Messages To ICM', MCFD_Logger.ERROR, 'MCFD_SendMessagesToICM' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString(), MessageObjectId);
        }     
        
        
    }
    
    @AuraEnabled
    public static Contact fetchUserDetails() {
        List<User> UserDetails = [select Id, ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c from Contact where id =:UserDetails[0].ContactId limit 1];
        return UserContact;
    }
    
    @AuraEnabled
    public static void SetMessageToRead(Id MessageId){
        System.debug(MessageId);
        MCFD_Message__c msg = [select Id, Portal_Message_Read__c from MCFD_Message__c where Id =: MessageId limit 1];
        System.debug(msg);
        msg.Portal_Message_Read__c = true;
        update msg;
    }
    
    //VINANTHI - added code to fetch all Messages
    @AuraEnabled
    public static Map<String, List<MCFD_Message__c>> fetchMessage() {
        
        String returnString = 'SUCCESS';
        
        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        
        List<MCFD_Message__c> InboxMessageList = [select Id,Message_Subject__c,Message_Body__c,Message_Status__c,Message_Type__c,
                                                  ICM_Case_Id__c,ICM_Case_Name__c,ICM_Case_Worker_First_Name__c,ICM_Case_Worker_IDIR__c,
                                                  ICM_Case_Worker_Last_Name__c, ICM_Client_Unread_Flag__c, ICM_Contact_Id__c,
                                                  ICM_Conversation_Id__c,ICM_Date_Message_Sent__c,ICM_Disable_Reply__c,ICM_Importance_Flag__c,
                                                  ICM_Message_Due_Date__c,ICM_Message_Id__c,ICM_Program_Type__c,ICM_SR_Id__c,ICM_SR_Sub_Type__c,
                                                  Message_Received_From__c,Portal_Message_Read__c,
                                                  (Select ID, ICM_Attachment_Id__c,MCFD_Attachment_Name__c from Attachments__r)
                                                  from MCFD_Message__c where (ICM_Contact_Id__c =: UserDetails[0].Contact.ICM_Contact_Id__c
                                                  and ICM_Contact_Id__c != null //added for bug 6134
                                                  and Message_Status__c = 'Sent from ICM')
                                                  or (ICM_Program_Type__c = 'Child Care Subsidy' 
                                                      AND (Message_Subject__c = 'Document Checklist' or Message_Subject__c = 'Access Denied' or
                                                      Message_Subject__c =: Label.CCS_Checklist_Spouse_Message_Subject) //added for 6012 and 6082 
                                                   	  //AND CreatedById  =: UserDetails[0].Id
                                                      AND Contact__c =: UserDetails[0].ContactId
                                                        )
                                                  order by ICM_Date_Message_Sent__c desc];
        system.debug('InboxMessageList===' +InboxMessageList);

        List<MCFD_Message__c> SentMessageList = [select Id,Message_Subject__c,Message_Body__c,Message_Status__c,Message_Type__c,
                                                 ICM_Case_Id__c,ICM_Case_Name__c,ICM_Case_Worker_First_Name__c,ICM_Case_Worker_IDIR__c,
                                                 ICM_Case_Worker_Last_Name__c, ICM_Client_Unread_Flag__c, ICM_Contact_Id__c,
                                                 ICM_Conversation_Id__c,ICM_Date_Message_Sent__c,ICM_Disable_Reply__c,ICM_Importance_Flag__c,
                                                 ICM_Message_Due_Date__c,ICM_Message_Id__c,ICM_Program_Type__c,ICM_SR_Id__c,ICM_SR_Sub_Type__c,
                                                 Message_Received_From__c,Portal_Message_Read__c, (Select ID, ICM_Attachment_Id__c,MCFD_Attachment_Name__c from Attachments__r)
                                                 from MCFD_Message__c where ICM_Contact_Id__c =: UserDetails[0].Contact.ICM_Contact_Id__c
                                                 and ICM_Contact_Id__c != null //added for bug 6134
                                                 and (Message_Status__c = 'Sent to ICM' or Message_Status__c = 'Reply to ICM')
                                                 order by ICM_Date_Message_Sent__c desc];
        
        Map<String, List<MCFD_Message__c>> MessageListMap = new Map<String, List<MCFD_Message__c>>();
        MessageListMap.put('Inbox',InboxMessageList);
        MessageListMap.put('Sent',SentMessageList);
        return MessageListMap;
        
    }
    
    @AuraEnabled
    public static Map<String, List<MCFD_Message__c>> fetchMessageRead(Boolean ReadValue) {
        
        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];

        List<MCFD_Message__c> InboxMessageList = [select Id,Message_Subject__c,Message_Body__c,Message_Status__c,Message_Type__c,
                                                  ICM_Case_Id__c,ICM_Case_Name__c,ICM_Case_Worker_First_Name__c,ICM_Case_Worker_IDIR__c,
                                                  ICM_Case_Worker_Last_Name__c, ICM_Client_Unread_Flag__c, ICM_Contact_Id__c,
                                                  ICM_Conversation_Id__c,ICM_Date_Message_Sent__c,ICM_Disable_Reply__c,ICM_Importance_Flag__c,
                                                  ICM_Message_Due_Date__c,ICM_Message_Id__c,ICM_Program_Type__c,ICM_SR_Id__c,ICM_SR_Sub_Type__c,
                                                  Message_Received_From__c,Portal_Message_Read__c, 
                                                  (Select ID, ICM_Attachment_Id__c,MCFD_Attachment_Name__c from Attachments__r)
                                                  from MCFD_Message__c where (ICM_Contact_Id__c =: UserDetails[0].Contact.ICM_Contact_Id__c
                                                  and ICM_Contact_Id__c != null //added for bug 6134
                                                  and Message_Status__c = 'Sent from ICM'
                                                  and Portal_Message_Read__c =: ReadValue)
                                                  or (ICM_Program_Type__c = 'Child Care Subsidy' 
                                                      AND (Message_Subject__c = 'Document Checklist' or Message_Subject__c = 'Access Denied') //added for 6012 and 6082
                                                   AND  CreatedById =: UserDetails[0].Id 
                                                   and Portal_Message_Read__c =: ReadValue)
                                                  order by ICM_Date_Message_Sent__c desc];
        
        
        Map<String, List<MCFD_Message__c>> MessageListMap = new Map<String, List<MCFD_Message__c>>();
        if(ReadValue == true)
        {    
        MessageListMap.put('Read',InboxMessageList);
        }
        else if(ReadValue == false)
        {
            MessageListMap.put('UnRead',InboxMessageList);
        }
        return MessageListMap;
        
    }
    
    //AASHAIKH - added code to create new Message
    @AuraEnabled
    public static void InsertNewMessage(MCFD_Message__c MessageObject, String MessageProgramType, String ICMCaseId, String ICMCaseName, String ReplyMessage, List<Id> AttachmentIdList) {
        String returnString = 'SUCCESS';

        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        try{
            if(ReplyMessage == 'No')
            {
                MCFD_Message__c newMessage = new MCFD_Message__c();
                newMessage.Message_Status__c = 'Sent to ICM';
                newMessage.ICM_Contact_Id__c = UserDetails[0].Contact.ICM_Contact_Id__c;
                newMessage.Contact__c = UserDetails[0].Contact.Id;
                newMessage.ICM_Date_Message_Sent__c = System.Now();
                newMessage.Message_Type__c = 'General Message';
                newMessage.ICM_Program_Type__c = MessageProgramType;
                newMessage.ICM_Case_Id__c = ICMCaseId;
				newMessage.ICM_Case_Name__c	 = ICMCaseName;
                newMessage.Message_Body__c =MessageObject.Message_Body__c;
                newMessage.Message_Subject__c=MessageObject.Message_Subject__c;
                // PDAVE : Bug fix - 5664 -  In partial access scenario, grab the SR from the Application Request in SF and sent with the message 
                if(MessageObject.ICM_SR_Id__c != Null){
                    newMessage.ICM_SR_Id__c = MessageObject.ICM_SR_Id__c;
                }
                insert newMessage;
                
                List<Attachment> StdAttachments = [Select ParentId from Attachment where Id in: AttachmentIdList];
                List<MCFD_Attachment__c> CustAttachList = new List<MCFD_Attachment__c>();
                if(StdAttachments.size()>0)
                {
                    List<Id> ParentCustId = new List<Id>();
                	for(Attachment a : StdAttachments)
            		{
                    	ParentCustId.add(a.ParentId);
                	}
                
                CustAttachList = [select Id,Linked_Message_Id__c from MCFD_Attachment__c where Id in: ParentCustId];
                for(MCFD_Attachment__c c : CustAttachList)
                {
                    c.Linked_Message_Id__c = newMessage.Id;
                }
                    update CustAttachList;
                }
                SendMessage(newMessage.Id);
                System.debug(newMessage.Id);
            }
            
        }
        
        catch(System.Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_SendMessagesToICM', 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString());
        }
        
        
    }
    
    //AASHAIKH - added code to create reply Message
    @AuraEnabled
    public static void InsertReplyMessage(String MessageProgramType, String ICMCaseId, String ICMCaseName, String ReplyMessage, 
                                          String ICM_Case_Worker_First_Name, String ICM_Case_Worker_IDIR, 
                                          String ICM_Case_Worker_Last_Name, Boolean ICM_Client_Unread_Flag, 
                                          String ICM_Contact_Id, String ICM_Conversation_Id, //DateTime ICM_Date_Message_Sent, 
                                          Boolean ICM_Disable_Reply, String ICM_Message_Id, Id MessageId, 
                                          String Message_Body, String Message_Status, String Message_Subject, 
                                          String Message_Type, Boolean Portal_Message_Read, String ICM_SR_Num, List<Id> AttachmentIdList) {
        String returnString = 'SUCCESS';
        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        try{
            if(ReplyMessage == 'Yes')
            {
                MCFD_Message__c RepliedMessage = new MCFD_Message__c();  
                RepliedMessage.Message_Status__c = 'Reply to ICM';
                RepliedMessage.ICM_Contact_Id__c = UserDetails[0].Contact.ICM_Contact_Id__c;
                RepliedMessage.Contact__c = UserDetails[0].Contact.Id;
                RepliedMessage.ICM_Date_Message_Sent__c = System.Now();
                RepliedMessage.Message_Type__c = 'General Message';
                RepliedMessage.ICM_Program_Type__c = MessageProgramType;
                RepliedMessage.ICM_Case_Id__c = ICMCaseId;
				RepliedMessage.ICM_Case_Name__c	 = ICMCaseName;
                RepliedMessage.Message_Body__c =Message_Body;
                RepliedMessage.Message_Subject__c=Message_Subject;
                
                // Bug 4803 fix - adding SR number to the replied message if the inbox message is associated
               
                RepliedMessage.ICM_SR_Id__c = ICM_SR_Num;
                RepliedMessage.ICM_Case_Worker_First_Name__c= ICM_Case_Worker_First_Name;
                RepliedMessage.ICM_Case_Worker_IDIR__c= ICM_Case_Worker_IDIR;
                RepliedMessage.ICM_Case_Worker_Last_Name__c= ICM_Case_Worker_Last_Name;
                RepliedMessage.ICM_Client_Unread_Flag__c= ICM_Client_Unread_Flag;
                RepliedMessage.ICM_Conversation_Id__c= ICM_Conversation_Id;
                RepliedMessage.ICM_Disable_Reply__c= ICM_Disable_Reply;
                RepliedMessage.ICM_Message_Id__c= ICM_Message_Id;
                RepliedMessage.Portal_Message_Read__c= Portal_Message_Read;
                
                insert RepliedMessage;
                
                List<Attachment> StdAttachments = [Select ParentId from Attachment where Id in: AttachmentIdList];
                List<MCFD_Attachment__c> CustAttachList = new List<MCFD_Attachment__c>();
                if(StdAttachments.size()>0)
                {
                    List<Id> ParentCustId = new List<Id>();
                	for(Attachment a : StdAttachments)
            		{
                    	ParentCustId.add(a.ParentId);
                	}
                
                CustAttachList = [select Id,Linked_Message_Id__c from MCFD_Attachment__c where Id in: ParentCustId];
                for(MCFD_Attachment__c c : CustAttachList)
                {
                    c.Linked_Message_Id__c = RepliedMessage.Id;
                }
                    update CustAttachList;
                }
                
                SendMessage(RepliedMessage.Id);
                System.debug(RepliedMessage.Id);  
            }
        }
        
        catch(System.Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_SendMessagesToICM', 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString());
        }
        
        
    }
    
    
    //AASHAIKH - added code to delete Message
    @AuraEnabled
    public static void DeleteMessageApex(Id DeleteMessageObjectId) {
        
        try{
            System.debug(DeleteMessageObjectId);
            
            MCFD_Message__c deleteobject = [select Id from MCFD_Message__c where Id =: DeleteMessageObjectId limit 1];
            System.debug(deleteobject.Id);
            delete deleteobject;
        }
        catch(System.Exception e)
        {
            System.debug(e.getMessage());
        }
    }
    
    public static String CreateMessageXML(Id MessageId)
    {
        
        List<User> ContactDetails = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =: UserInfo.getUserId() limit 1];
        System.debug('UserId--'+UserInfo.getUserId());
        System.debug('ContactId--'+ContactDetails[0].ContactId);
        
        String xmlRequest;
        
        MCFD_Message__c Message = [select Id,Message_Subject__c,Message_Body__c,Message_Status__c,Message_Type__c,
                                   ICM_Case_Id__c,ICM_Case_Name__c,ICM_Case_Worker_First_Name__c,ICM_Case_Worker_IDIR__c,
                                   ICM_Case_Worker_Last_Name__c, ICM_Client_Unread_Flag__c, ICM_Contact_Id__c,
                                   ICM_Conversation_Id__c,ICM_Date_Message_Sent__c,ICM_Disable_Reply__c,ICM_Importance_Flag__c,
                                   ICM_Message_Due_Date__c,ICM_Message_Id__c,ICM_Program_Type__c,ICM_SR_Id__c,ICM_SR_Sub_Type__c,
                                   Message_Received_From__c,Portal_Message_Read__c, ICM_SR_Number__c, Assigned_Team__c
                                   from MCFD_Message__c where Id =: MessageId Limit 1];       
        
        String ICM_Generic_User;
        
        if(Message.ICM_Program_Type__c == 'Autism Funding'){
            ICM_Generic_User = Label.Messaging_Autism_ICM_Generic_User;
        }else if(Message.ICM_Program_Type__c == 'Child Care Subsidy'){
            ICM_Generic_User = Label.Messaging_CCS_ICM_Generic_User;
        }else if(Message.ICM_Program_Type__c == 'Affordable Child Care Benefit'){
            ICM_Generic_User = Label.Messaging_CCS_ICM_Generic_User;//Updated by VM
        }
        else{
            ICM_Generic_User = '';
        }
        
        List<MCFD_Attachment__c> custmAttch = new List<MCFD_Attachment__c>([SELECT id, Name,Linked_Message_Id__c FROM MCFD_Attachment__c WHERE Linked_Message_Id__c =: Message.Id]);
        List<Attachment> stdAttchmntList = new List<Attachment>();
        if(custmAttch.size()>0)
        {
        	List<Id> AttachIdList = new List<Id>();
            for(MCFD_Attachment__c c : custmAttch)
            {
                System.debug(c.Id);
                AttachIdList.add(c.Id);
            }
                
        stdAttchmntList = [SELECT id, Name, Body, ParentId FROM Attachment WHERE ParentId in: AttachIdList];
        }
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null,'1.0');
        w.writeStartElement(null,'Document',null);
        w.writeStartElement(null,'Header',null);
        w.writeStartElement(null,'TransactionName',null);
        w.writeCharacters('Send Message to ICM');
        w.writeEndElement();
        w.writeStartElement(null,'CreatedDate',null);
        w.writeCharacters(String.ValueOf(System.Now()));
        w.writeEndElement();
        w.writeStartElement(null,'CreatedBy',null);
        w.writeCharacters(ContactDetails[0].Contact.Name == null?'':ContactDetails[0].Contact.Name);
        w.writeEndElement();
        w.writeEndElement();
        w.writeStartElement(null,'Payload',null);
        w.writeStartElement(null, 'Message', null);
        w.writeStartElement(null,'Operation',null);
        w.writeCharacters('Insert');
        w.writeEndElement();
        w.writeStartElement(null,'ImportanceFlag',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'TaskStatus',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'MessageStatus',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'MessageBody',null);
        // PDAVE : Bug fix 5677 - As Message_Body__c is Rich text area Salesforce was already escaping apostrophe and other symbols
        String msgBodyUnescape = '';
        if(Message.Message_Body__c != Null){
            msgBodyUnescape = Message.Message_Body__c.unescapeHtml4();
        }
        w.writeCharacters(msgBodyUnescape);
        w.writeEndElement();
        w.writeStartElement(null,'ClientUnreadFlag',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'DateMessageSent',null);
        w.writeCharacters(String.ValueOf(System.Now()));
        w.writeEndElement();
        w.writeStartElement(null,'ICMCaseId',null);
        w.writeCharacters(Message.ICM_Case_Id__c);
        //1-4D5AIZQ');
        w.writeEndElement();
        w.writeStartElement(null,'ICMContactId',null);
        w.writeCharacters(Message.ICM_Contact_Id__c);
        w.writeEndElement();
        w.writeStartElement(null,'ICMMessageId',null);
        // Bug fix 3919 - setting message id to blank always. in all scenarios will need to create a new message. 
        w.writeCharacters('');
        //oCurrCon.MCFD_Gender__c==null?'':oCurrCon.MCFD_Gender__c1-4D5GO3O');
        w.writeEndElement();
        w.writeStartElement(null,'ICMParentMessageId',null);
        if(Message.Message_Status__c == 'Sent to ICM')
        {
            w.writeCharacters('');
        }
        else if(Message.Message_Status__c == 'Reply to ICM')
        {
            w.writeCharacters(Message.ICM_Conversation_Id__c==null?'':Message.ICM_Conversation_Id__c);
        }
        w.writeEndElement();
        
        w.writeStartElement(null,'ICMSrId',null);
        w.writeCharacters(Message.ICM_SR_Id__c==null?'':Message.ICM_SR_Id__c);
        w.writeEndElement();
        w.writeStartElement(null,'MessageDueDate',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'MessageType',null);
        w.writeCharacters('General Message');
        w.writeEndElement();
        w.writeStartElement(null,'PortalMessageId',null);
        w.writeCharacters(String.valueOf(Message.Id));
        //String.valueOf(Message.Id));
        w.writeEndElement();
        w.writeStartElement(null,'IntegrationStatus',null);
        w.writeCharacters('New');
        w.writeEndElement();
        w.writeStartElement(null,'MessageSubject',null);
        w.writeCharacters(Message.Message_Subject__c);
        w.writeEndElement();
        w.writeStartElement(null,'AssignedTeam',null);
        w.writeCharacters(Message.Assigned_Team__c);
        w.writeEndElement();
        w.writeStartElement(null,'ToCaseWorkerId',null);
        //w.writeCharacters('SIEBEL_EAI_CFD');
        w.writeCharacters(ICM_Generic_User);
        w.writeEndElement();
        w.writeStartElement(null,'KPeSign',null);
        w.writeCharacters('');
        w.writeEndElement();
        w.writeStartElement(null,'SPeSign',null);
        w.writeCharacters('');
        w.writeEndElement();
        
        w.writeStartElement(null,'ListOfAttachment',null);              
        if(!stdAttchmntList.isEmpty())
        {
            for(Attachment a : stdAttchmntList )
            {
                w.writeStartElement(null,'Attachment',null);
                w.writeStartElement(null,'AttachmentId',null);
                w.writeCharacters(String.valueOf(a.Id));
                w.writeEndElement();
                w.writeStartElement(null,'AttachmentName',null);
                w.writeCharacters(a.Name);
                w.writeEndElement();
				w.writeStartElement(null,'FileExt',null);
                w.writeCharacters(a.Name.subString(a.Name.lastIndexOf('.') + 1));
                w.writeEndElement();  
                w.writeStartElement(null,'AttachmentBody',null);
                w.writeCharacters(EncodingUtil.base64Encode(a.body));
                w.writeEndElement();
                w.writeEndElement();    
            }
        }
        w.writeEndElement();
        
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndDocument();
        
        xmlRequest = w.getXmlString();
        System.debug('XML Request---->'+xmlRequest);
        w.close();
        
        return xmlRequest;
        
    }
    
    //code to get attachment from ICM
    @AuraEnabled
    public static String getAttachment(String CustomAttachId, String ViewedMessageType)
    {
        if(ViewedMessageType == 'Received')
        {
        MCFD_Attachment__c custAttach = [select Id, MCFD_Attachment_Name__c, ICM_Attachment_Id__c from MCFD_Attachment__c where Id=: CustomAttachId limit 1];
        
        List<User> ContactDetails = [select ContactId, Contact.Name from user where id =: UserInfo.getUserId() limit 1];
        
        
        XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null,'1.0');
            w.writeStartElement(null,'Document',null);
                w.writeStartElement(null,'Header',null);
                    w.writeStartElement(null,'TransactionName',null);
                    w.writeCharacters('Get Message Attachment from ICM');
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedDate',null);
                    w.writeCharacters(String.ValueOf(System.Now()));
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedBy',null);
                    w.writeCharacters(ContactDetails[0].Contact.Name);
                    w.writeEndElement();
                w.writeEndElement();
                w.writeStartElement(null,'Payload',null);
                    w.writeStartElement(null, 'Message', null);
                        w.writeStartElement(null,'Operation',null);
                        w.writeCharacters('Query');
                        w.writeEndElement();
                        w.writeStartElement(null,'ICMAttachmentId',null);
                        w.writeCharacters(custAttach.ICM_Attachment_Id__c);
                        w.writeEndElement();
                    w.writeEndElement();
                w.writeEndElement();
            w.writeEndDocument();
        
        String xmlRequest = w.getXmlString();
        System.debug('XML Request---->'+xmlRequest);
        w.close();
        
        String CreatedAttachmentId = SendAttachmentRequestToICM(xmlRequest, custAttach.Id, custAttach.MCFD_Attachment_Name__c);
        return CreatedAttachmentId;
        }
        else if(ViewedMessageType == 'Sent')
        {
            
            Attachment stdAttach = [select Id from Attachment where parentId=: CustomAttachId limit 1];
            return String.valueOf(stdAttach.Id);
        }
        return '';
    }
    
    // PDAVE: Bug Fix 5416 - Use custom attachment name as this contains file exentions as well.
    @AuraEnabled
    public static String SendAttachmentRequestToICM(String xmlRequest, Id CustAttachId, String custAttachName)
    {
        //MCFD_Message__c Message = [select Id from MCFD_Message__c where Id =: MessageObjectId Limit 1];       
        
        
        //        if(Message.Id != null)
        //      {
        
        String JSONString = XMLRequest;
        //String JSONString = '';
        System.debug('Calling submit');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMToSendMessage');
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
            
            if(res.getStatusCode()==200)
            {
                JSONParser parser = JSON.createParser(res.getBody());
                
                Blob AttachBody;
                //String fileName;
                while (parser.nextToken() != null) 
                {   
                    
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'base64FileContents')) 
                    {
                        parser.nextToken();
                        AttachBody = EncodingUtil.base64Decode(parser.getText());
                     }
                    /*if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'fileName')) 
                    {
                        parser.nextToken();
                        fileName = parser.getText();
                     }*/
                }
                system.debug('AttachBody=' + AttachBody);
                
                Attachment StdAttachment = new Attachment();
                StdAttachment.ParentId = CustAttachId;
                //StdAttachment.Name = fileName;
                StdAttachment.Name = custAttachName;
                StdAttachment.Body = AttachBody;
                insert StdAttachment;
                
                // below code will check if the attachment record has been shared with the portal user. If not, then 
                // create sharing record for the custom attachment record for the portal user. this is due to remedy 0000669899
                MCFD_Attachment__c Attachforsharing = [select Id, Linked_Message_Id__c from MCFD_Attachment__c
                                             		   where Id =: CustAttachId limit 1];
                
                MCFD_Message__c Messageforsharing = [select Id, ICM_Contact_Id__c from MCFD_Message__c 
                                                     where Id =: Attachforsharing.Linked_Message_Id__c limit 1];
                
                List<MCFD_Attachment__Share> lstAttchShr = [select Id, parentId from MCFD_Attachment__Share where parentId =: CustAttachId];
                
                if(lstAttchShr.isEmpty() && Messageforsharing.ICM_Contact_Id__c == fetchUserDetails().ICM_Contact_Id__c)
                {
                    MCFD_Attachment__Share attchShr = new MCFD_Attachment__Share();
                    attchShr.ParentId = CustAttachId;
                    attchShr.UserOrGroupId = userInfo.getUserId();
                    attchShr.AccessLevel = 'Read';
                    attchShr.RowCause = Schema.MCFD_Attachment__Share.RowCause.Manual;
                    insert attchShr;
                }
                //attachment sharing code ends
                
                return String.valueOf(StdAttachment.Id);
            }
            
        }
            
         
        catch(System.CalloutException e) 
        {
            return '';
        }     
        
        return '';
        /*else
{
//return '{"ErrorMessage":"SR exists"}';        
System.debug('SR Exists');
}*/
        
        
        
        
    }
    @AuraEnabled
    public static Id saveTheFile(String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        MCFD_Attachment__c attach = new MCFD_Attachment__c();
        attach.MCFD_Last_Modified_Date__c = System.Now();
        //attach.MCFD_Contact_Id__c = parentId; 
        attach.MCFD_Attachment_Name__c= fileName; 
        INSERT attach;
        
        System.debug(attach);
        
        Attachment att = new Attachment();
        att.parentId = attach.Id;

        att.Body = EncodingUtil.base64Decode(base64Data);
        att.Name = fileName;
        att.ContentType = contentType;
        
        insert att;
        System.debug(att.Id);
        return att.Id;
        
        
    }
    
    @AuraEnabled
    public static List<String> saveTheChunk(String fileName, String base64Data, String contentType, String fileId) { 
		if (fileId == '') {
            fileId = saveTheFile(fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        List<String> returnList = new List<String>();
        returnList.add(fileId);
        returnList.add(fileName);
        return returnList;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
     	String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }
    

    
    
    
}