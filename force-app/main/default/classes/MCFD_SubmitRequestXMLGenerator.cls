/*********************************************************************************************************
Name            : MCFD_SubmitRequestXMLGenerator.cls  
Description     : This class is to generate XML when Autism or CCS Request is submitted.
Created By      : Deloitte
Created Date    : 09/May/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      09/May/2017   
--------------------------------------------------------------------------------------------------------------              
PDAVE         17/Aug/2017   US 515 : Integration error handling logic
PDAVE         27 SEP 2017   Added error handling logic (CSS & AF Case Access Request) as part of US 4589
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/


public without sharing class MCFD_SubmitRequestXMLGenerator {


    public static String createAutismSubmitXML(Request__c request)
    {
        Request__c oCurrReq = new Request__c();
        
        oCurrReq = [Select id, CreatedById, MCFD_First_Name__c, MCFD_Middle_Name__c, MCFD_no_recent_benefit_plan__c, MCFD_Last_Name__c,MCFD_is_autism_finding_agreement_signed__c, MCFD_confirm_application__c, MCFD_Service_Provider_Name__c from Request__c where Id =: request.id];
        
        Id userID = oCurrReq.CreatedById; //changing this to request.createdbyId from loggedinuser as this fetches wrong info on re-submission
        
        List<MCFD_Relationship__c> reltnshipList = new List<MCFD_Relationship__c> ();
        reltnshipList  = [select id, MCFD_Request__c, MCFD_Child_Contact__c from MCFD_Relationship__c where MCFD_Request__c=: oCurrReq.id ];
        
        List<id> contactIdlist = new List<Id> ();
        for(MCFD_Relationship__c rel : reltnshipList  ){
        contactIdList.add(rel.MCFD_Child_Contact__c );
        }
        
        List<User> contactDetails = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c,Contact.MCFD_GUID__c from user where id =: userID limit 1];
        //System.debug('ContactId--'+ContactDetails[0].ContactId);
    
        String BCeId = ContactDetails[0].Contact.MCFD_GUID__c;
        
        Contact primecon = new Contact();
        primecon = [Select FirstName,LastName,MCFD_BCeID__c,Birthdate,MCFD_SIN__c,MCFD_GUID__c from Contact where MCFD_GUID__c =: BCeId Limit 1];
        system.debug('>>>>BCeID '+ primecon.MCFD_GUID__c);
        
        List<Contact> conList = new List<Contact> ();
        conList = [Select id, FirstName, LastName, MiddleName, BirthDate from Contact where id in:contactIdList ];
        
        
        
        User uinfo = [select FirstName,MiddleName, LastName from user where id =: userID  Limit 1];
        
        //---------------------------------------
            
          system.debug('>>>> RequestId is '+ oCurrReq.Id);
            MCFD_Attachment__c custmAttch = [SELECT id, Name,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: oCurrReq.Id];        
            //system.debug('>>>> customAcctachmentList is '+ custmAttch );
            List<Attachment> stdAttchmntList = [SELECT id, Name, Body, ParentId FROM Attachment WHERE ParentId =: custmAttch.Id];

            
            
        
        //----------------------------------------------
        
        
    
                      
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null,'1.0');
            w.writeStartElement(null,'Document',null);
            
             w.writeStartElement(null,'Header',null);
                w.writeStartElement(null,'TransactionName',null);
                w.writeCharacters('Autism Request Submit');
                w.writeEndElement();
                w.writeStartElement(null,'CreatedDate',null);
                w.writeCharacters(String.ValueOf(System.Today()));
                w.writeEndElement();
                w.writeStartElement(null,'CreatedBy',null);
                w.writeCharacters(UserInfo.getName());
                w.writeEndElement();
            w.writeEndElement();
            
            
             w.writeStartElement(null,'Payload',null);
                w.writeStartElement(null,'Operation',null);
                w.writeCharacters('Insert');
                w.writeEndElement();
               
                w.writeStartElement(null,'SRType',null);
                w.writeCharacters('Autism Funding Unit');
                w.writeEndElement();
                
                w.writeStartElement(null,'SRSubType',null);
                w.writeCharacters('Portal Registration');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Priority',null);
                w.writeCharacters('3-Standard');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Status',null);
                w.writeCharacters('Ready'); //changed value to Ready from Open for US3897
                w.writeEndElement();
                 
                w.writeStartElement(null,'AssignedTeam',null);
                w.writeCharacters('Admin Support');
                w.writeEndElement();
                 
                w.writeStartElement(null,'ContMethod',null);
                w.writeCharacters('Client Portal');
                w.writeEndElement();
                 
                w.writeStartElement(null,'SvcOff',null);
                w.writeCharacters('XWB - Child Care Programs and Services Branch');
                w.writeEndElement();
                
                 w.writeStartElement(null,'Organization',null);
                w.writeCharacters('MCFD');
                w.writeEndElement();
                
                 w.writeStartElement(null,'CreatedBy',null);
                w.writeCharacters(getString(uinfo.FirstName));
                w.writeEndElement();
                
                 w.writeStartElement(null,'Created',null);
                w.writeCharacters(String.ValueOf(System.Today()));
                w.writeEndElement();
                
                w.writeStartElement(null,'Memo',null);
                w.writeCharacters(getString(primecon.LastName)+ ', ' + getString(primecon.FirstName) + ', ' + getString(primecon.MCFD_BCeID__c));
                w.writeEndElement();
                
                       
            
                w.writeStartElement(null,'PrimaryFirstName',null);
                w.writeCharacters(getString(primecon.FirstName));
                w.writeEndElement();
                
                
                w.writeStartElement(null,'PrimaryLastName',null);
                w.writeCharacters(getString(primecon.LastName));
                w.writeEndElement();
               
        
                w.writeStartElement(null,'PrimaryDOB',null);
                w.writeCharacters(getString(String.ValueOf(primecon.Birthdate)));
                w.writeEndElement();
               
                w.writeStartElement(null,'PrimarySIN',null);
                w.writeCharacters(getString(String.ValueOf(primecon.MCFD_SIN__c)));
                w.writeEndElement();
               
                
                w.writeStartElement(null,'GUID',null);
                w.writeCharacters(getString(primecon.MCFD_GUID__c));
                w.writeEndElement();
        
                w.writeStartElement(null,'BCeID',null);
                w.writeCharacters(getString(primecon.MCFD_BCeID__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'ParentSignatory',null);
                w.writeCharacters(oCurrReq.MCFD_is_autism_finding_agreement_signed__c==true?'Yes':'No');
                w.writeEndElement();
                
                
                
                
                for(Contact c : conList ){
                
                w.writeStartElement(null,'Child',null);
                
                w.writeStartElement(null,'ChildFirstName',null);
                w.writeCharacters(getString(c.FirstName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildMiddleName',null);
                w.writeCharacters(getString(c.MiddleName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildLastName',null);
                w.writeCharacters(getString(c.LastName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildDateofBirth',null);
                w.writeCharacters(getString(String.ValueOf(c.BirthDate)));
                w.writeEndElement();
                
                w.writeEndElement();
              }
              
            
              
            
                w.writeStartElement(null,'ServiceProvider',null);
                w.writeCharacters(getString(oCurrReq.MCFD_Service_Provider_Name__c) );
                w.writeEndElement();
                
                w.writeStartElement(null,'NotUsedSPRecently',null);
                w.writeCharacters(oCurrReq.MCFD_no_recent_benefit_plan__c?'true':'false');
                w.writeEndElement();
                
                w.writeStartElement(null,'Declaration',null);
                w.writeCharacters(oCurrReq.MCFD_confirm_application__c?'true':'false');
                w.writeEndElement();
                
                w.writeStartElement(null,'ListOfAttachment',null);
                for(Attachment a : stdAttchmntList ){
                    
                w.writeStartElement(null,'Attachment',null);
                w.writeStartElement(null,'fileName',null);
                w.writeCharacters(a.Name);
                w.writeEndElement();
                
                w.writeStartElement(null,'sfdcAttachmentId',null);
                w.writeCharacters(String.valueOf(a.Id));
                w.writeEndElement();     
                
                w.writeStartElement(null,'base64String',null);
                w.writeCharacters(EncodingUtil.base64Encode(a.body));
                w.writeEndElement();
            
                w.writeEndElement();
                }
                w.writeEndElement();
        
             w.writeEndElement();
            w.writeEndDocument();
            string xml = w.getXmlString();
            System.debug('xml'+xml);
            w.close();
            return xml;
            
        
    }
    
    
    public static String createCCSSubmitXML(Request__c request)
    {
        Request__c oCurrReq = new Request__c();
        
        oCurrReq = [Select id, CreatedById, MCFD_Start_Date__c,MCFD_First_Name__c, MCFD_Middle_Name__c, MCFD_no_recent_benefit_plan__c, MCFD_Last_Name__c,MCFD_is_autism_finding_agreement_signed__c, MCFD_confirm_application__c, MCFD_Service_Provider_Name__c from Request__c where Id =: request.id];
        
        //Id userID = UserInfo.getUserId();
        Id userID = oCurrReq.CreatedById; //changing this to request.createdbyId from loggedinuser as this fetches wrong info on re-submission
        
        
        List<MCFD_Relationship__c> reltnshipList = new List<MCFD_Relationship__c> ();
        reltnshipList  = [select id, MCFD_Request__c, MCFD_Child_Contact__c from MCFD_Relationship__c where MCFD_Request__c=: oCurrReq.id ];
        
        List<id> contactIdlist = new List<Id> ();
        for(MCFD_Relationship__c rel : reltnshipList  ){
        contactIdList.add(rel.MCFD_Child_Contact__c );
        }
        
        List<Contact> conList = new List<Contact> ();
        conList = [Select id, FirstName, LastName, MiddleName, Birthdate from Contact where id in:contactIdList];
        
        List<User> ContactDetails = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c,Contact.MCFD_GUID__c from user where id =: userID limit 1];
        //System.debug('ContactId--'+ContactDetails[0].ContactId);
    
        String BCeId = ContactDetails[0].Contact.MCFD_GUID__c;
        
        //System.debug(BCeId);
        
        Contact primecon = new Contact();
        primecon = [Select FirstName,LastName,MCFD_BCeID__c,Birthdate,MCFD_SIN__c,MCFD_GUID__c from Contact where MCFD_GUID__c =: BCeId Limit 1];
        system.debug('>>>>BCeID '+ primecon.MCFD_GUID__c);
        
        User uinfo = [select FirstName,MiddleName, LastName from user where id =: userID  Limit 1];
        
        
        //---------------------------------------
        
       // system.debug('>>>> RequestId is '+ oCurrReq.Id);
            MCFD_Attachment__c custmAttch = [SELECT id, Name,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: oCurrReq.Id];        
       // system.debug('>>>> customAcctachmentList is '+ custmAttch );
            List<Attachment> stdAttchmntList = [SELECT id, Name, Body, ParentId FROM Attachment WHERE ParentId =: custmAttch.Id];

        //----------------------------------------------
        
    
                      
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null,'1.0');
            w.writeStartElement(null,'Document',null);
            
             w.writeStartElement(null,'Header',null);
                w.writeStartElement(null,'TransactionName',null);
                w.writeCharacters('CCS Request Submit');
                w.writeEndElement();
                w.writeStartElement(null,'CreatedDate',null);
                w.writeCharacters(String.ValueOf(System.Today()));
                w.writeEndElement();
                w.writeStartElement(null,'CreatedBy',null);
                w.writeCharacters(UserInfo.getName());
                w.writeEndElement();
            w.writeEndElement();
            
            
            w.writeStartElement(null,'Payload',null);
                w.writeStartElement(null,'Operation',null);
                w.writeCharacters('Insert');
                w.writeEndElement();
               
                w.writeStartElement(null,'SRType',null);
                w.writeCharacters('Child Care Subsidy');
                w.writeEndElement();
                
                w.writeStartElement(null,'SRSubType',null);
                w.writeCharacters('Portal Registration');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Priority',null);
                w.writeCharacters('3-Standard');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Status',null);
                w.writeCharacters('Ready'); //changed value to Ready from Open for US3897
                w.writeEndElement();
                 
                w.writeStartElement(null,'AssignedTeam',null);
                w.writeCharacters('Admin Support');
                w.writeEndElement();
                 
                w.writeStartElement(null,'ContMethod',null);
                w.writeCharacters('Client Portal');
                w.writeEndElement();
                 
                w.writeStartElement(null,'SvcOff',null);
                w.writeCharacters('XWB - Child Care Programs and Services Branch');
                w.writeEndElement();
                
                 w.writeStartElement(null,'Organization',null);
                w.writeCharacters('MCFD');
                w.writeEndElement();
                
                 w.writeStartElement(null,'CreatedBy',null);
                w.writeCharacters(getString(uinfo.FirstName));
                w.writeEndElement();
                
                 w.writeStartElement(null,'Created',null);
                w.writeCharacters(String.ValueOf(System.Today()));
                w.writeEndElement();
                
                w.writeStartElement(null,'Memo',null);
                w.writeCharacters(getString(primecon.LastName)+ ', ' + getString(primecon.FirstName) + ', ' + getString(primecon.MCFD_BCeID__c));
                w.writeEndElement();
                
               
                
           
            
            
                w.writeStartElement(null,'PrimaryFirstName',null);
                w.writeCharacters(getString(primecon.FirstName));
                w.writeEndElement();
                
                
                w.writeStartElement(null,'PrimaryLastName',null);
                w.writeCharacters(getString(primecon.LastName));
                w.writeEndElement();
               
                w.writeStartElement(null,'PrimaryDOB',null);
                w.writeCharacters(getString(String.ValueOf(primecon.Birthdate)));
                w.writeEndElement();
               
                w.writeStartElement(null,'PrimarySIN',null);
                w.writeCharacters(getString(String.ValueOf(primecon.MCFD_SIN__c)));
                w.writeEndElement();
               
                
                w.writeStartElement(null,'GUID',null);
                w.writeCharacters(getString(primecon.MCFD_GUID__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'BCeID',null);
                w.writeCharacters(getString(primecon.MCFD_BCeID__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'Child',null);
             
                w.writeStartElement(null,'ChildFirstName',null);
                w.writeCharacters(getString(conList[0].FirstName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildMiddleName',null);
                w.writeCharacters(getString(conList[0].MiddleName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildLastName',null);
                w.writeCharacters(getString(conList[0].LastName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildDateofBirth',null);
                //String DateString =  getString(String.ValueOf(oCurrReq.MCFD_Start_Date__c));
                w.writeCharacters(getString(String.ValueOf(conList[0].Birthdate)));
                w.writeEndElement();
                
                 w.writeEndElement();        
            
                w.writeStartElement(null,'CareProvider',null);
                w.writeCharacters(getString(oCurrReq.MCFD_Service_Provider_Name__c) );
                w.writeEndElement();
                
                w.writeStartElement(null,'NoRecentBenefitPlan',null);
                w.writeCharacters(oCurrReq.MCFD_no_recent_benefit_plan__c?'true':'false');
                w.writeEndElement();
                
                w.writeStartElement(null,'Declaration',null);
                w.writeCharacters(oCurrReq.MCFD_confirm_application__c?'true':'false');
                w.writeEndElement();

                w.writeStartElement(null,'ListOfAttachment',null);
                    for(Attachment a : stdAttchmntList ){
                    w.writeStartElement(null,'Attachment',null);
                    
                    w.writeStartElement(null,'fileName',null);
                    w.writeCharacters(a.Name);
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'sfdcAttachmentId',null);
                    w.writeCharacters(String.valueOf(a.Id));
                    w.writeEndElement();     
                    
                    w.writeStartElement(null,'base64String',null);
                    w.writeCharacters(EncodingUtil.base64Encode(a.body));
                    w.writeEndElement();
                
                    w.writeEndElement();
                    }
                w.writeEndElement();
                
        
            w.writeEndElement();
            w.writeEndDocument();
            
            string xml = w.getXmlString();
            w.close();
            return xml;
         }
    
    
    
    
    @AuraEnabled
    public static String SubmitAutismRequest(String sRequestId) 
    {
        String xmlResponse = '';
        Request__c oReq = [Select Id, RecordType.Name, ICM_SR_Number__c from Request__c where id=: sRequestId];
        if(oReq != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMtoSubmitPortalAccessReq');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(Integer.valueOf(Label.Timeout_Access_Autism_Case));
            String xmlString = MCFD_SubmitRequestXMLGenerator.createAutismSubmitXML(oReq); 
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('Name', xmlString);
            gen.writeEndObject();
            req.setBody(gen.getAsString());
                    
          //  System.debug('>>>> req.getBody(): ' + req.getBody()); 
          //  System.debug('>>>> req: ' + req); 
            Http http = new Http();
            String returnJSON = '';
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                System.debug('>>>> Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                System.debug('>>>> returnJSON:'+ returnJSON);
                //String jsonString  = "[" + returnJSON + "]";
                //system.debug('>>>responseList ' + responseList);
                
                /*if(res.getStatusCode()==200)
                {
                    JSONParser parser = JSON.createParser(res.getBody());
                    
                    while (parser.nextToken() != null) 
                    {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                        {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            SRNumber = parser.getText();
                        }
                    }
                    system.debug('SRNumber=' + SRNumber);
                    oReq.ICM_SR_Number__c = SRNumber;
                    oReq.MCFD_Status__c = 'Submitted';  //PDAVE: TASK 5186 
                    update oReq;                
                }
                if(SRNumber == ''){
                    MCFD_Logger.log_integration_error('Access existing Autism Cases', 
                                                   MCFD_Logger.error, 
                                                   'MCFD_SubmitRequestXMLGenerator', 
                                                   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());
                }*/
				
				if(res.getStatusCode()==200){
                     
                        String responseBody;
                        if(System.Label.ICM_Dummy_Error_Response_Mode_AF_Case_Access.toUpperCase() == 'ON'){
                            responseBody = System.Label.ICM_Dummy_Error_Response;
                        }else{
                            responseBody = res.getBody();
                        }                        
						xmlResponse = responseBody;
                        
						Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        system.debug('ICM_Response-->'+ICM_Response);
                        
                        // ----------------------------------------------- //
                        // ------- Handle error response (if any) -------- //
                        // ----------------------------------------------- //
                        if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
                            String strErrorStatus;
                            String strErrorMsg;
                        
                            List<Object> errorDetailsList = (List<Object>)ICM_Response.get(System.Label.ICM_Error_Response_Parent_Tag);
                            system.debug('errorDetail-->'+errorDetailsList[0]);
                            Map<String, Object> errorDetail = (Map<String, Object>)errorDetailsList[0];
                            if(errorDetail.containsKey(System.Label.ICM_Error_Response_Error_Message_Tag)){
                                strErrorMsg = (String)errorDetail.get(System.Label.ICM_Error_Response_Error_Message_Tag);        
                            }
                             if(errorDetail.containsKey(System.Label.ICM_Error_Response_Status_Tag)){
                                strErrorStatus = (String)errorDetail.get(System.Label.ICM_Error_Response_Status_Tag);        
                            }
                            system.debug('strErrorStatus=' + strErrorStatus);
                            system.debug('strErrorMsg=' + strErrorMsg);
                            system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                            
                            if(oReq.RecordType.Name == 'Autism case request'){
                                MCFD_Logger.log_integ_err_for_request('Submission - Access existing Autism Cases', 
                                                                   MCFD_Logger.error, 
                                                                   'MCFD_SubmitRequestXMLGenerator', 
                                                                   'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                                   oReq.Id);
                            }
                            
                            oReq.MCFD_Status__c='Submission Error'; 
                            update oReq;
                        }else if(ICM_Response.containsKey('SRNumber')){
                        // ----------------------------------------------- //
                        // ------- Handle success response --------------- //
                        // ----------------------------------------------- //
                            String SRNumber;
							if(ICM_Response.containsKey('SRNumber')){
								SRNumber = (String)ICM_Response.get('SRNumber');
							}
							system.debug('SRNumber-->'+SRNumber);

							oReq.ICM_SR_Number__c = SRNumber;
							oReq.MCFD_Status__c='Submitted'; 
                            update oReq;
						}else{
							oReq.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
							update oReq;   
							system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
								
							if(oReq.RecordType.Name == 'Autism case request'){
								MCFD_Logger.log_integ_err_for_request('Submission - Access existing Autism Cases', 
																   MCFD_Logger.error, 
																   'MCFD_SubmitRequestXMLGenerator', 
																   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
																   oReq.Id);
							}
							
							oReq.MCFD_Status__c='Submission Error'; 
							update oReq;
						}       
				}else{
					oReq.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
					update oReq;   
					system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
						
					if(oReq.RecordType.Name == 'Autism case request'){
						MCFD_Logger.log_integ_err_for_request('Submission - Access existing Autism Cases', 
														   MCFD_Logger.error, 
														   'MCFD_SubmitRequestXMLGenerator', 
														   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
														   oReq.Id);
					}
					
					oReq.MCFD_Status__c='Submission Error'; 
					update oReq;
				} 
			}
            catch(System.CalloutException e) {
               system.debug('Came to Exception');
                							   
			   if(oReq.RecordType.Name == 'Autism case request'){
                    MCFD_Logger.log_integ_err_for_request('Submission - Access existing Autism Cases', 
                                                       MCFD_Logger.error, 
                                                       'MCFD_SubmitRequestXMLGenerator', 
                                                       'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                       oReq.Id);
                }
                
                oReq.MCFD_Status__c='Submission Error'; 
                update oReq;
            }     
            
        }
    
        return xmlResponse;
    }
    
    
     @AuraEnabled
    public static String SubmitCSSRequest(String sRequestId) 
    {
        String xmlResponse = '';        
        Request__c oReq = [Select Id, RecordType.Name, ICM_SR_Number__c from Request__c where id=: sRequestId];
        if(oReq != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMtoSubmitPortalAccessReq');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(Integer.valueOf(Label.Timeout_Access_CCS_Case));  
              
            String xmlString = MCFD_SubmitRequestXMLGenerator.createCCSSubmitXML(oReq); 
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('Name', xmlString);
            gen.writeEndObject();
            req.setBody(gen.getAsString());
                    
            System.debug('>>>> req.getBody(): ' + req.getBody()); 
            System.debug('>>>> req: ' + req); 
            Http http = new Http();
            String returnJSON = '';
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                System.debug('>>>> Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                System.debug('>>>> returnJSON:'+ returnJSON);
              //  List<String> responseList = (List<String>)System.JSON.deserialize(returnJSON, List<String>.class);
              //  system.debug('>>>responseList ' + responseList);
               
				/*if(res.getStatusCode()==200)
                {
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) 
                    {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                        {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            SRNumber = parser.getText();
                        }
                    }
                    system.debug('SRNumber=' + SRNumber);
                    oReq.ICM_SR_Number__c = SRNumber;
                    oReq.MCFD_Status__c = 'Submitted';    //PDAVE: TASK 5186 
                    update oReq;  
						
                }
                
                if(SRNumber == ''){
                    MCFD_Logger.log_integration_error('Access existing CCS Cases', 
                                                   MCFD_Logger.error, 
                                                   'MCFD_SubmitRequestXMLGenerator', 
                                                   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());
                }
				*/
				 if(res.getStatusCode()==200){
                     
                        String responseBody;
						if(System.Label.ICM_Dummy_Error_Response_Mode_CCS_Access.toUpperCase() == 'ON'){
                            responseBody = System.Label.ICM_Dummy_Error_Response;
                        }else{
                            responseBody = res.getBody();
                        }
                        xmlResponse = responseBody;
                        
                        Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        system.debug('ICM_Response-->'+ICM_Response);
                        
                        // ----------------------------------------------- //
                        // ------- Handle error response (if any) -------- //
                        // ----------------------------------------------- //
                        if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
                            String strErrorStatus;
                            String strErrorMsg;
                        
                            List<Object> errorDetailsList = (List<Object>)ICM_Response.get(System.Label.ICM_Error_Response_Parent_Tag);
                            system.debug('errorDetail-->'+errorDetailsList[0]);
                            Map<String, Object> errorDetail = (Map<String, Object>)errorDetailsList[0];
                            if(errorDetail.containsKey(System.Label.ICM_Error_Response_Error_Message_Tag)){
                                strErrorMsg = (String)errorDetail.get(System.Label.ICM_Error_Response_Error_Message_Tag);        
                            }
                             if(errorDetail.containsKey(System.Label.ICM_Error_Response_Status_Tag)){
                                strErrorStatus = (String)errorDetail.get(System.Label.ICM_Error_Response_Status_Tag);        
                            }
                            system.debug('strErrorStatus=' + strErrorStatus);
                            system.debug('strErrorMsg=' + strErrorMsg);
                            system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                            
                            if(oReq.RecordType.Name == 'CCS case request'){
                                MCFD_Logger.log_integ_err_for_request('Submission - Access existing CCS Cases', 
                                                                   MCFD_Logger.error, 
                                                                   'MCFD_SubmitRequestXMLGenerator', 
                                                                   'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                                   oReq.Id);
                            }
                            
                            oReq.MCFD_Status__c='Submission Error'; 
                            update oReq;
                        }else if(ICM_Response.containsKey('SRNumber')){
                        // ----------------------------------------------- //
                        // ------- Handle success response --------------- //
                        // ----------------------------------------------- //
                            String SRNumber;
							if(ICM_Response.containsKey('SRNumber')){
								SRNumber = (String)ICM_Response.get('SRNumber');
							}
							system.debug('SRNumber-->'+SRNumber);

							oReq.ICM_SR_Number__c = SRNumber;
							oReq.MCFD_Status__c='Submitted'; 
                            update oReq;
                        }else{
							oReq.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
							update oReq;   
							system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
								
							if(oReq.RecordType.Name == 'CCS case request'){
								MCFD_Logger.log_integ_err_for_request('Submission - Access existing CCS Cases', 
																   MCFD_Logger.error, 
																   'MCFD_SubmitRequestXMLGenerator', 
																   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
																   oReq.Id);
							}
							
							oReq.MCFD_Status__c='Submission Error'; 
							update oReq;
						}       
                                  
                    }else{
                        oReq.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
                        update oReq;   
                        system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                            
                        if(oReq.RecordType.Name == 'CCS case request'){
                            MCFD_Logger.log_integ_err_for_request('Submission - Access existing CCS Cases', 
                                                               MCFD_Logger.error, 
                                                               'MCFD_SubmitRequestXMLGenerator', 
                                                               'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
                                                               oReq.Id);
                        }
                        
                        oReq.MCFD_Status__c='Submission Error'; 
                        update oReq;
                    }       
        
                
            } 
            catch(System.CalloutException e) {
               system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                
                if(oReq.RecordType.Name == 'CCS case request'){
                    MCFD_Logger.log_integ_err_for_request('Submission - Access existing CCS Cases', 
                                                       MCFD_Logger.error, 
                                                       'MCFD_SubmitRequestXMLGenerator', 
                                                       'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                       oReq.Id);
                }
                
                oReq.MCFD_Status__c='Submission Error'; 
                update oReq;
            }  
        }
        return xmlResponse;
    }
    
     public static String getString(String val)
    {    
        String masterReturn = '';
        if(val == null)
        {
            masterReturn = '';
           // return '';
        }
        else
        {
            masterReturn = String.ValueOf(val);
            //return String.ValueOf(val);
        }
        return masterReturn;
    }
    
       
}