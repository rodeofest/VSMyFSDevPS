/**************************************************************************************
Function            : Controller class for Portal Hub Page

Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* PDAVE                       26 SEP 2017            Updating logic as per "Ticket #36864: R4.3.2 - DSS - Updates to Contact Authentication"
* PDAVE                       13 NOV 2017            Bug fix 5849   
* PDAVE                       16 NOV 2017            Bug Fix 5541: Error handling for Start Renewal
*************************************************************************************/
public without sharing class MCFD_CallICMForContactDetails {
    
    static List<User> LoggedInUser = [SELECT isActive, LastName, MiddleName, FirstName, ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c,
                                      MCFD_Deactivation_Reason__c, FederationIdentifier, MCFD_Old_FederationIdentifier__c    
                                      FROM User 
                                      WHERE id =:UserInfo.getUserId() 
                                      LIMIT 1];
    static List<Contact> UserContact = [SELECT Id, LastName, MiddleName, FirstName, Birthdate, ICM_Home_Phone__c, MCFD_Do_Not_Load_Autism_Welcome_Page__c, ICM_Message_Phone__c, MCFD_Status__c, MCFD_Deactivation_Reason__c,
                                        ICM_Work_Phone__c, ICM_Cell_Phone__c, ICM_Contact_Id__c,MCFD_HasActiveCRAConsent__c, ICM_Autism_Linked__c, ICM_CCS_Linked__c,MCFD_SIN__c, MCFD_BCeID__c, MCFD_GUID__c
                                        FROM Contact 
                                        WHERE id =:LoggedInUser[0].ContactId limit 1];

    public static Id spouseId = null;
    
    @AuraEnabled
    public static integer getCountUnreadMessages() {
        
               
         return [select count() from MCFD_message__C where portal_message_read__C=false and Message_Status__c = 'Sent from ICM'  and contact__C=:LoggedInUser[0].ContactId];        
    }
    
    

    //Split this method into 2 as it was causing "pending commit before callout error - bug# 6113"
    @AuraEnabled
    public static List<Request__c> getPortalApplicationDetails(String XMLString) {
        List<Request__c> getRequestStatusList = new List<Request__c>();
        List<Request__c> Requests = new List<Request__c>();
        List<Request__c> autismRequests = new List<Request__c>();
        
        
        try{
            Requests = [select Id, MCFD_Type__c,MCFD_Case_Name__c,MCFD_Submitted_Date__c,LastModifiedDate,MCFD_Status_Formula__c, CCS_Application_Resume_Page__c, ICM_SR_Number__c 
                        , MCFD_Status__c, Resolution_Status__c,MCFD_Request_Status_Display_Message__c,createdDate
                        from Request__c where CreatedBy.Id =: UserInfo.getUserId()
                        and ((MCFD_Type__c IN ('Child Care Subsidy Application', 'Child Care Subsidy Renewal')
                              and MCFD_Status__c in( 'In Progress','Submitted','Pending Spouse Consent'))
                            ) ORDER BY LastModifiedDate DESC];
            autismRequests = [select Id, MCFD_Type__c,MCFD_Case_Name__c,MCFD_Submitted_Date__c,LastModifiedDate,MCFD_Status_Formula__c, CCS_Application_Resume_Page__c, ICM_SR_Number__c 
                              , MCFD_Status__c, Resolution_Status__c,MCFD_Request_Status_Display_Message__c,createdDate
                              from Request__c where CreatedBy.Id =: UserInfo.getUserId()
                              and (( MCFD_Type__c in ( 'Request to Amend' , 'Request to Pay', 'Reimbursement', 'Case Access Request - Autism Funding', 'Case Access Request - Child Care Subsidy')
                                    and MCFD_Status__c = 'Submitted')) ORDER BY MCFD_Submitted_Date__c DESC];
            
            Requests.addAll(autismRequests);
            
            // Changes for user story 4996
            // LPERRY: removed the status != 'submitted' check for ccs as per bug 5360
            for(Request__c request:Requests){
                if(((request.MCFD_Type__c == 'Child Care Subsidy Application' || 
                      request.MCFD_Type__c == 'Child Care Subsidy Renewal') || 
                    request.MCFD_Type__c == 'Case Access Request - Child Care Subsidy' || 
                    request.MCFD_Type__c == 'Case Access Request - Autism Funding') &&
                   request.ICM_SR_Number__c != null
                  ){
                      // create a list of requests
                      getRequestStatusList.add(request);
                  }
            }
            
            // Call the XML creation function
            
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Call_WM_for_SR_Status');
                req.setTimeout(Integer.valueOf(Label.Timeout_Portal_Hub_Page));
                req.setMethod('POST');
                req.setHeader('Connection','keep-alive');
                req.setHeader('Content-Type', 'application/json');
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject(); 
                gen.writeStringField('StatusRequest', XMLString);
                gen.writeEndObject();
                req.setBody(gen.getAsString());
                
                Http http = new Http();
                String returnJSON = '';
                try {
                    HTTPResponse res = http.send(req);
                    System.debug(res);
                    returnJSON = res.getBody();
                    System.debug('Response getPortalApplicationDetails '+returnJSON);
                } 
                catch(System.CalloutException e) {
                    MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForContactDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
                } 
                // Process the response from INT 513 ICM call 
                JSONParser parser = JSON.createParser(returnJSON);
                
                while (parser.nextToken() != null) {
                    if (parser.getText() == 'SRInformation')
                    {
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                RequestJSON icmRequest = (RequestJSON)parser.readValueAs(RequestJSON.class);
                                system.debug('icmRequest: '+icmRequest);
                                for(Request__c portalRequest:Requests){
                                    if(portalRequest.ICM_SR_Number__c == icmRequest.SRNumber && 
                                       (icmRequest.Status == 'Closed' || icmRequest.Status == 'Cancelled')){
                                           portalRequest.MCFD_Status__c = icmRequest.Status;
                                           portalRequest.Resolution_Status__c = icmRequest.Resolution;
                                       }
                                       ////per US-7164 to calculateStatusMessage
                                       if(portalRequest.ICM_SR_Number__c == icmRequest.SRNumber){
                                           
                                        portalRequest = calculateStatusMessage(portalRequest,icmRequest);
                                        system.debug('portalRequest: '+portalRequest); 
                                       }
                                       portalRequest = MCFD_CCSApplication.upsertRequest(portalRequest);
                                }
                                parser.skipChildren();
                            }
                        }
                        break;
                    }
                }
                
        }
		catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForContactDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }
        return Requests;
    }
    
     
    //per US-7164 to calculate Status Message shown on Portalhub page
    public static Request__c calculateStatusMessage(Request__c portalRequest,RequestJSON icmRequest){
        	system.debug('Inside calculateStatusMessage');
        	 portalRequest.MCFD_Request_Status_Display_Message__c ='';
          if(portalRequest.MCFD_Type__c == 'Child Care Subsidy Application' || portalRequest.MCFD_Type__c =='Child Care Subsidy Renewal'){
                     if(portalRequest.MCFD_Status__c == 'Submitted')
                     {
                         if(icmRequest.Status=='Ready' || icmRequest.Status =='In Progress' || (icmRequest.Status=='Pending' && icmRequest.SubStatus == 'External'))
                         {
                            system.debug('IF1');
                             
                            Date submittedDate = portalRequest.MCFD_Submitted_Date__c;
                         	system.debug('before SubmittedDate: '+submittedDate);
                          
                            
                            Date calcMsgDate;
                            calcMsgDate = submittedDate.addDays(Integer.valueOf(System.Label.StatusMessage_Days_Scenario_1));
                         	system.debug('After SubmittedDate: '+calcMsgDate);
                         
                         	Datetime dt= Datetime.newInstance(calcMsgDate.year(),calcMsgDate.month(),calcMsgDate.day());
                         	
                         	String strStatusMsgDate = dt.format('MMMM dd, YYYY');
                            portalRequest.MCFD_Request_Status_Display_Message__c = System.Label.Status_Display_Text_Scenario_1+' '+strStatusMsgDate+' '+System.Label.Status_Display_Text_Scenario_1b;
                            
                         }
                         else
                         {
                            if(icmRequest.Status=='Pending' && icmRequest.SubStatus=='Client')
                            {
                                system.debug('IF2');
                                portalRequest.MCFD_Request_Status_Display_Message__c =System.Label.Status_Display_Text_Scenario_1c;
                            }
                            system.debug('MCFD_Request_Status_Display_Message__c: '+portalRequest.MCFD_Request_Status_Display_Message__c);
                         }
                             
                     }
                     else if(portalRequest.MCFD_Status__c == 'In Progress' || portalRequest.MCFD_Status__c =='Pending Spouse Consent' )
                     {
                         
                            system.debug('IF3');
                            DateTime dT = portalRequest.createdDate;
                            Date createdDatetype =Date.newinstance(dT.year(), dT.month(), dT.day());
                         	system.debug('before createdDate: '+createdDatetype);
                          
                            
                            Date calcMsgDate;
                            calcMsgDate = createdDatetype.addDays(Integer.valueOf(System.Label.StatusMessage_Days_Scenario2a));
                         	system.debug('After createdDate: '+calcMsgDate);
                         
                         	Datetime statusDT= Datetime.newInstance(calcMsgDate.year(),calcMsgDate.month(),calcMsgDate.day());
                         	
                         	String strStatusMsgDate = statusDT.format('MMMM dd, YYYY');
                         	system.debug('strStatusMsgDate: '+strStatusMsgDate);
                         	Date formulaDate = createdDatetype.addDays(Integer.valueOf(System.Label.StatusMessage_Days_Scenario2b));
                         	system.debug('formulaDate: '+formulaDate);
                        	if(Date.today() > formulaDate)
                            
                                portalRequest.MCFD_Request_Status_Display_Message__c = System.Label.Status_Display_Text_Scenario_2+' '+strStatusMsgDate+' '+System.Label.Status_Display_Text_Scenario_2b;
                            
                            system.debug('MCFD_Request_Status_Display_Message__c: '+portalRequest.MCFD_Request_Status_Display_Message__c);
                      }
            
                }
            else if(portalRequest.MCFD_Type__c =='Case Access Request - Child Care Subsidy' || portalRequest.MCFD_Type__c =='Case Access Request - Autism Funding')
            {
                if(portalRequest.MCFD_Status__c == 'Submitted'){
                         	system.debug('IF4');
                         	
                         	Date submittedDate = portalRequest.MCFD_Submitted_Date__c;
                         	
                         	system.debug('before SubmittedDate: '+submittedDate);
                      
                            
                            Date calcMsgDate;
                            calcMsgDate = submittedDate.addDays(Integer.valueOf(System.Label.StatusMessage_Days_Scenario_3));
                         	system.debug('After SubmittedDate: '+calcMsgDate);
                         	Datetime dt= Datetime.newInstance(calcMsgDate.year(),calcMsgDate.month(),calcMsgDate.day());
                         	String strStatusMsgDate = dt.format('MMMM dd, YYYY');
                            
                            if(Date.today() > calcMsgDate)
                                portalRequest.MCFD_Request_Status_Display_Message__c = system.Label.Status_Display_Text_Scenario_3;               
                                else
                                portalRequest.MCFD_Request_Status_Display_Message__c = System.Label.Status_Display_Text_Scenario_3a +' '+strStatusMsgDate;
                           
                            system.debug('MCFD_Request_Status_Display_Message__c: '+portalRequest.MCFD_Request_Status_Display_Message__c);
                 }
                
            }
        
        //portalRequest.MCFD_Request_Status_Display_Message__c ='This is Sparta!';
        return portalRequest;
    }
    
    
    
    
    //second part of split portalApplicationDetails method for bug 6113
    @AuraEnabled
    public static String getPortalApplicationDetails_PreMethod() {
        List<Request__c> getRequestStatusList = new List<Request__c>();
        List<Request__c> Requests = new List<Request__c>();
        List<Request__c> autismRequests = new List<Request__c>();
        String xmlString = '';
        
            Requests = [select Id, MCFD_Type__c,MCFD_Case_Name__c,MCFD_Submitted_Date__c,LastModifiedDate,MCFD_Status_Formula__c, CCS_Application_Resume_Page__c, ICM_SR_Number__c 
                        , MCFD_Status__c, Resolution_Status__c,MCFD_Request_Status_Display_Message__c,createdDate
                        from Request__c where CreatedBy.Id =: UserInfo.getUserId()
                        and ((MCFD_Type__c IN ('Child Care Subsidy Application', 'Child Care Subsidy Renewal')
                              and MCFD_Status__c in( 'In Progress','Submitted','Pending Spouse Consent' ))
                            ) ORDER BY LastModifiedDate DESC];
            autismRequests = [select Id, MCFD_Type__c,MCFD_Case_Name__c,MCFD_Submitted_Date__c,LastModifiedDate,MCFD_Status_Formula__c, CCS_Application_Resume_Page__c, ICM_SR_Number__c 
                              , MCFD_Status__c, Resolution_Status__c,MCFD_Request_Status_Display_Message__c,createdDate
                              from Request__c where CreatedBy.Id =: UserInfo.getUserId()
                              and (( MCFD_Type__c in ( 'Request to Amend' , 'Request to Pay', 'Reimbursement', 'Case Access Request - Autism Funding', 'Case Access Request - Child Care Subsidy')
                                    and MCFD_Status__c = 'Submitted')) ORDER BY MCFD_Submitted_Date__c DESC];
            
            Requests.addAll(autismRequests);
            
            // Changes for user story 4996
            // LPERRY: removed the status != 'submitted' check for ccs as per bug 5360
            for(Request__c request:Requests){
                if(((request.MCFD_Type__c == 'Child Care Subsidy Application' || 
                      request.MCFD_Type__c == 'Child Care Subsidy Renewal') || 
                    request.MCFD_Type__c == 'Case Access Request - Child Care Subsidy' || 
                    request.MCFD_Type__c == 'Case Access Request - Autism Funding') &&
                   request.ICM_SR_Number__c != null
                  ){
                      // create a list of requests
                      getRequestStatusList.add(request);
                  }
            }
            
            // Call the XML creation function
            if(getRequestStatusList.size() > 0){
                xmlString = createRequestStatusXML(getRequestStatusList); 
                System.debug(xmlString);
            }
        return xmlString;
    }
    
    
    //future code ends
    
        
    // Hemanth added this method to fetch contat details of the logged in user to understand whether to take the user on to welcome page or not
    
    @AuraEnabled
    public static Boolean fetchUserWelcomePagePreference() {
        //    List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        //    Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c,MCFD_Do_Not_Load_Autism_Welcome_Page__c from Contact where id =:UserDetails[0].ContactId limit 1];
        return UserContact[0].MCFD_Do_Not_Load_Autism_Welcome_Page__c ;
    }
    
    @AuraEnabled
    public static Contact fetchLoggedInUserContact() {
        //    List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        //    Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c,MCFD_Do_Not_Load_Autism_Welcome_Page__c from Contact where id =:UserDetails[0].ContactId limit 1];
        return UserContact[0];
    }
    
    @AuraEnabled
    public static String CallICM() {
        System.debug('Calling for contact details');
        //List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c from user where id =:UserInfo.getUserId() limit 1];
        System.debug('ContactId--'+LoggedInUser[0].Contact.MCFD_GUID__c);
        String returnJSON = '';
        
        //below if for remedy 673894
        String ContactGUID = '';
        if(LoggedInUser[0].Contact.MCFD_GUID__c != Null && LoggedInUser[0].Contact.MCFD_GUID__c != '')
        {
            ContactGUID = LoggedInUser[0].Contact.MCFD_GUID__c;
        }
        else
        {
            ContactGUID = '';
        }
        
        String JSONString = '{\"GUID\":\"'+ContactGUID+'\"}';
        //String JSONString = '{\"BCEID\":\"C0E79BED48DD48B3B4CD71AB921FD183\"}';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMforContactDetails');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(Integer.valueOf(System.Label.Timeout_Portal_Hub_Page));
        //req.setTimeout(60000);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('Name', JSONString);
        gen.writeEndObject();
        
        req.setBody(gen.getAsString());
        System.debug(req.getBody()); 
        System.debug(req);
        Http http = new Http();
        try{             
            HTTPResponse res = http.send(req);
            returnJSON = res.getBody();
            System.debug('Response'+res.toString());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            System.debug(returnJSON);
            
            //if(res.getStatusCode()==200)
            // {
            
            // }   
        }catch(System.CalloutException e) {
            System.debug(e.getmessage());
            MCFD_Logger.log_integration_error('Portal Hub Page', 
                                              MCFD_Logger.error, 
                                              'MCFD_CallICMForContactDetails', 
                                              'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }
        
        
        return returnJSON;
    }
    
    //PDAVE: US 2012 - Check for Re-registration 
    @AuraEnabled
    public static boolean apexupdateReqAndChkForReregister(String JSONString){
        //System.debug('JSONString-->'+JSONString);
        Boolean hasReregisterContact = false;
        //List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c from user where id =:UserInfo.getUserId() limit 1];
        System.debug(JSONString);


        if(JSONString != Null && JSONString != ''){
            
            JSONParser parser = JSON.createParser(JSONString);
            
            String ICMContactId;
            String AutismPortalAccess;//" : "Access Granted",
            String BirthDate;//" : "07/01/1980",
            String CCSPortalAccess;//" : "Access Granted",
            String CellularPhone;//
            String FirstName;
            String HomePhone;
            String LastName;
            String MessagePhone;
            String SIN;
            String WorkPhone;
            
            // Getting the CRA Consent from the ICM 
            //Boolean hasCRAConsent = false; 
            //Boolean hasCRAConsent = MCFD_ICMResponseUtility.hasActiveCRAConsent(JSONString);
            
            Map<String , String> SRStatusMap = new Map<String, String>();
            
            while (parser.nextToken() != null) 
            {   
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'Id')) 
                {
                    parser.nextToken();
                    if(ICMContactId== null || ICMContactId=='')
                    {
                        ICMContactId = parser.getText();
                    }
                    
                }
                
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'AutismPortalAccess')) 
                {
                    parser.nextToken();
                    AutismPortalAccess = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'BirthDate')) 
                {
                    parser.nextToken();
                    BirthDate = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CCSPortalAccess')) 
                {
                    parser.nextToken();
                    CCSPortalAccess = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'CellularPhone')) 
                {
                    parser.nextToken();
                    CellularPhone = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'FirstName')) 
                {        
                    parser.nextToken();
                    FirstName = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'HomePhone')) 
                {
                    parser.nextToken();
                    HomePhone = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'LastName')) 
                {
                    parser.nextToken();
                    LastName = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'MessagePhone')) 
                {
                    parser.nextToken();
                    MessagePhone = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SIN')) 
                {
                    parser.nextToken();
                    SIN = parser.getText();
                }
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'WorkPhone')) 
                {
                    parser.nextToken();
                    WorkPhone = parser.getText();
                }  
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                {
                    parser.nextToken();
                    String SRNumber = parser.getText();
                    system.debug('sr number'+parser.getText());
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    parser.nextToken();
                    String SRStatus = parser.getText();
                    SRStatusMap.put(SRNumber,SRStatus);
                    system.debug('sr number and status'+SRNumber+SRStatus);
                    
                }
                
            }
            //ICMContactId
            system.debug('ICMContactId-->' + ICMContactId);
            if(ICMContactId != Null && ICMContactId != ''){
                hasReregisterContact = isSimilarICMContactIdExists(ICMContactId, JSONString);  
                if(hasReregisterContact == false){
                    
                    // PDAVE: Updating logic as per "Ticket #36864: R4.3.2 - DSS - Updates to Contact Authentication"
                    
                    /* ---------- Change Summary : ---------------
                        IF no corresponding SR received back from ICM
                        AND SF request’s status is “Submitted”
                        AND SF request’s type is NOT “Case Access Request - Autism Funding” or “Case Access Request - Child Care Subsidy”
                        THEN set SF request’s status to “closed”
                    ----------------------------------------------- */

                    // LPERRY: Updating logic as per "Bug 5360: Regression - CCS Renewal/Application status changing to closed in Portal when Key Player is Partial Match in ICM"
                    
                    /* ---------- Change Summary : ---------------
                        IF no corresponding SR received back from ICM
                        AND SF request’s status is “submitted”
                        AND Submission date is not within last 365 days
                        THEN set SF request's status to "closed"
                    ----------------------------------------------- */

                    Date todaysDate = Date.today();
                    Date oneYearAgo = todaysDate.addYears(-1);

                    List<Request__c> reqList_NoRespective_ICM_SR =[SELECT MCFD_Status__c, ICM_SR_Number__c, MCFD_Submitted_Date__c 
                                                      FROM Request__c 
                                                      WHERE CreatedBy.Id =: UserInfo.getUserId() 
                                                        AND ICM_SR_Number__c NOT IN :SRStatusMap.keySet() 
                                                        AND MCFD_Submitted_Date__c <: oneYearAgo
                                                       // AND todaysDate.monthsBetween(MCFD_Submitted_Date__c) > 12
                                                        AND MCFD_Status__c = 'Submitted']; 
                    
                    for(Request__c objRequest : reqList_NoRespective_ICM_SR){
                        objRequest.MCFD_Status__c = 'Closed';
                    }
                    if(!reqList_NoRespective_ICM_SR.isEmpty()){
                        update reqList_NoRespective_ICM_SR;
                    }
                    
                    
                    /* ----------------- Change Summary : ------------
                        IF status received from ICM is closed or cancelled
                        THEN overwrite SF request’s status with ICM status regardless of the SF request’s status.
                        IF status received from ICM is NOT closed or cancelled, do not overwrite status.
                    ----------------------------------------------- */
                    List<Request__c> requestList = new List<Request__c>([SELECT MCFD_Status__c,ICM_SR_Number__c, MCFD_Type__c from Request__c where ICM_SR_Number__c IN :SRStatusMap.keySet()]);
                    List<Request__c> update_ReqList_with_ICM_Status = new List<Request__c>();
                    String ICM_SR_Status;
                    for(Request__c objRequest : requestList){
                        ICM_SR_Status = SRStatusMap.get(objRequest.ICM_SR_Number__c);
                        if((ICM_SR_Status == 'Closed' || ICM_SR_Status == 'Cancelled') &&
                          objRequest.MCFD_Type__c != 'Case Access Request - Autism Funding' && 
                          objRequest.MCFD_Type__c != 'Case Access Request - Child Care Subsidy'){
                            objRequest.MCFD_Status__c = ICM_SR_Status;  
                            update_ReqList_with_ICM_Status.add(objRequest);
                        }                         
                    }
                    system.debug('requestList size--->'+requestList.size());
                    system.debug('update_ReqList_with_ICM_Status size--->'+update_ReqList_with_ICM_Status.size());
                    
                    if(!update_ReqList_with_ICM_Status.isEmpty()){
                        update update_ReqList_with_ICM_Status;                        
                    }
                    
                    if(LastName!=null && LastName != '')
                    {
                
                if(!UserContact.isEmpty()){                     
                  UserContact[0].LastName = LastName;
                  UserContact[0].FirstName = FirstName;
                  UserContact[0].ICM_Autism_Linked__c = AutismPortalAccess;
                  UserContact[0].ICM_CCS_Linked__c = CCSPortalAccess;
                  UserContact[0].ICM_Cell_Phone__c = CellularPhone;
                  UserContact[0].ICM_Home_Phone__c = HomePhone;
                  UserContact[0].ICM_Work_Phone__c = WorkPhone;
                  UserContact[0].ICM_Message_Phone__c = MessagePhone;
				  //Laura commented this out because
                  //there should be no update of the SIN on the contact integration.
                  //this was causing BUG 5644
                  //UserContact[0].MCFD_SIN__c = SIN;
                  UserContact[0].ICM_Contact_Id__c = ICMContactId;
                  
                  UserContact[0].Birthdate = Date.valueOf(BirthDate.substring(6,10)+'-'+BirthDate.substring(0,2)+'-'+BirthDate.substring(3,5));
                  System.debug(UserContact[0].Birthdate);
                  
                  update UserContact[0];

                  LoggedInUser[0].FirstName = FirstName;
                  LoggedInUser[0].LastName = LastName;
                  update LoggedInUser[0];
                  //populateContactOnMessages(ICMContactId);
                }
                
            }
                    
                }        
            }else{
                System.debug('Invalid response--->'+JSONString);
            }
        }else{
            System.debug('Invalid response--->'+JSONString);
        }
        //return hasReregisterContact;
        return false; // Added by Abhi temporarily to rmove the duplicate contact Id issue
    }
    
    // PDAVE : US 2012 - To identify if Reregistration scenario  
    @AuraEnabled
    public static boolean isSimilarICMContactIdExists(String ICMContId, String currentUser_jsonString){
        Boolean isSimilarExists = false;
        //List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c from user where id =:UserInfo.getUserId() limit 1];
        
        Map<Id, Contact> similarContactMap = new Map<Id, Contact>([SELECT Id, ICM_Contact_Id__c, MCFD_Is_Portal_User__c, CreatedDate
                                                                   FROM Contact 
                                                                   WHERE ICM_Contact_Id__c =: ICMContId 
                                                                   AND MCFD_Is_Portal_User__c = true
                                                                   AND (MCFD_Status__c = 'Active' OR MCFD_Status__c = '' OR MCFD_Status__c = Null) 
                                                                   ORDER BY CreatedDate Asc]);
        System.debug('Inside isSimilarICMContactIdExists---> similarContactMap count - '+similarContactMap.size());
        // remove logged in user's Contact if exists
        if(similarContactMap.containsKey(LoggedInUser[0].ContactId)){
            similarContactMap.remove(LoggedInUser[0].ContactId);
            System.debug('logged in user\"s contact removed from map');
        }
        
        if(similarContactMap.size() > 0){    
            
            isSimilarExists = true;
             /* ----------------- Change Summary : ------------
                PDAVE : Bug Fix 5599 : Do not deactivate re-registered user, 
                					   when Admin users using community builder. 
            ----------------------------------------------- */
            if(LoggedInUser[0].ContactId != Null){					
            	deactiveCurrentAndActiveOldUser(similarContactMap, currentUser_jsonString);
            }
        }
        
        return isSimilarExists;
    }
    
    // PDAVE : US 2012 - Reregistration action items
    @AuraEnabled
    public static void deactiveCurrentAndActiveOldUser(Map<Id, Contact> similarContactMap, String currentUser_jsonString){
        
        JSONParser currentUser_jsonParser = JSON.createParser(currentUser_jsonString);
        
        String currentUserFederationId; 
        String currentUserBCeID;
        String ICMContactId;
        String AutismPortalAccess;//\" : \"Access Granted\",
        String BirthDate;//\" : \"07/01/1980\",
        String CCSPortalAccess;//\" : \"Access Granted\",
        String CellularPhone;//
        String FirstName;
        String HomePhone;
        String LastName;
        String MessagePhone;
        String SIN;
        String WorkPhone;
        
        while (currentUser_jsonParser.nextToken() != null) 
        {   
            if ((currentUser_jsonParser.getCurrentToken() == JSONToken.FIELD_NAME) && (currentUser_jsonParser.getText() == 'Id')) 
            {
                currentUser_jsonParser.nextToken();
                if(ICMContactId== null || ICMContactId=='')
                {
                    ICMContactId = currentUser_jsonParser.getText();
                }
                
            }
            
        }
        //----------------------------------------------------------//
        // Update the details from JSON to current user's contact record 
        // The logged in user's contact should be set to deactivated.
        // Deactivation Reason fields should be created on the user and contact records. In this scenario, the Deactivation Reason should be \"Re-Registration\"
        //----------------------------------------------------------//
        
        if(!UserContact.isEmpty()){                          
            
            UserContact[0].ICM_Contact_Id__c = ICMContactId;
            UserContact[0].MCFD_Status__c = 'Deactivated';
            UserContact[0].MCFD_Deactivation_Reason__c = 'Re-Registration';
            UserContact[0].MCFD_GUID__c = '';
            currentUserBCeID = UserContact[0].MCFD_BCeID__c;
            System.debug(UserContact[0].Birthdate);
            
            update UserContact[0];  
        }
        
        
        //----------------------------------------------------------//
        // The logged in user user record should be inactived.
        // The logged in user's Federation ID should be deleted from their user record, but temporarily stored.
        //----------------------------------------------------------//
        
        //LoggedInUser[0].isActive = false;                          // This has to be taken care by a batch class
        LoggedInUser[0].MCFD_Ready_to_be_Inactivated__c = true;
        LoggedInUser[0].MCFD_Deactivation_Reason__c = 'Re-Registration';
        currentUserFederationId = LoggedInUser[0].FederationIdentifier;
        LoggedInUser[0].MCFD_Old_FederationIdentifier__c = currentUserFederationId;
        LoggedInUser[0].FederationIdentifier = '';
        update LoggedInUser[0];
        
        //----------------------------------------------------------//
        // The federation ID field on the previously existing user record should be updated with the logged in users federation ID
        // The previously existing user record should be set to active
        //----------------------------------------------------------//
        
        if(!similarContactMap.isEmpty()){           
            Map<Id, User> similarUsers = new Map<Id, User>([SELECT id, ContactId, isActive, FederationIdentifier, 
                                                            MCFD_Old_FederationIdentifier__c, MCFD_Deactivation_Reason__c
                                                            FROM User
                                                            WHERE ContactId IN: similarContactMap.keySet()]);
            Map<Id, User> similarContactUserMap = new Map<Id, User>();
            
            if(!similarUsers.isEmpty()){
                for(Id userId: similarUsers.keySet()){
                    similarContactUserMap.put(similarUsers.get(userId).ContactId, similarUsers.get(userId));
                }
                
                // Now idetify the oldest contact amoung multiple contacts
                List<Contact> similarContacts = similarContactMap.values();
                List<ContactWrapper> sortedContact = new List<ContactWrapper>();
                Contact oldestContact; 
                for(Contact item: similarContacts){
                    sortedContact.add(new ContactWrapper(item));
                }
                System.debug('Oldeest Contact--> '+ sortedContact[0].cont.CreatedDate);             
                oldestContact = sortedContact[0].cont;
                
                // ----------------- Now update the federation id of oldest similar contact's user and other user records -----------------//
                for(Id cId: similarContactUserMap.keySet()){
                    if(cId == oldestContact.Id){
                        similarContactUserMap.get(cId).isActive = true;         
                        similarContactUserMap.get(cId).MCFD_Old_FederationIdentifier__c = similarContactUserMap.get(cId).FederationIdentifier;
                        similarContactUserMap.get(cId).FederationIdentifier = currentUserFederationId;
                    }else{
                        similarContactUserMap.get(cId).isActive = false;
                        similarContactUserMap.get(cId).MCFD_Old_FederationIdentifier__c = similarContactUserMap.get(cId).FederationIdentifier;
                        similarContactUserMap.get(cId).FederationIdentifier = '';
                        
                    }
                }
                update similarContactUserMap.values();
                
                // ----------------- Now update the oldest similar contact and other contact records ----------------- //
                for(Id contId: similarContactMap.keySet()){
                    if(contId == oldestContact.Id){
                        similarContactMap.get(contId).MCFD_Status__c = 'Active';
                        similarContactMap.get(contId).MCFD_Deactivation_Reason__c = '';
                        similarContactMap.get(contId).MCFD_GUID__c = currentUserFederationId;
                        similarContactMap.get(contId).MCFD_BCeID__c = currentUserBCeID;
                    }else{
                        similarContactMap.get(contId).MCFD_Status__c = 'Deactivated';
                        similarContactMap.get(contId).MCFD_Deactivation_Reason__c = 'Re-Registration';            
                        similarContactMap.get(contId).MCFD_GUID__c = '';
                        
                    }
                }
                update similarContactMap.values();
                
                
            }else{
                System.debug('similarUsers is empty');
            }   
        }else{
            System.debug('similarContactMap is empty');
        }
        
    }
    
    @AuraEnabled
    public static void apexLogError_PortalHubPage(String apexJsonResponse){
        System.debug('apexLogError() --> Logging error for invalid JSON');
        MCFD_Logger.log_integration_error('Portal Hub Page', 
                                          MCFD_Logger.error, 
                                          'MCFD_CallICMForContactDetails', 
                                          'Invalid/Error Response - ' + apexJsonResponse);
    }
    
    
    public class ContactWrapper implements Comparable {
        
        public Contact cont;
        
        // Constructor
        public ContactWrapper(Contact con) {
            cont = con;
        }
        
        // Compare Contact based on the Contact CreatedDate.
        public Integer compareTo(Object compareTo) {
            // Cast argument to ContactWrapper
            ContactWrapper compareToCont = (ContactWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (cont.CreatedDate > compareToCont.cont.CreatedDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (cont.CreatedDate < compareToCont.cont.CreatedDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    // Owner        : PDAVE
    // Description  : Bug fix 5849 -> 1st Message sent from SR not received in Salesforce  
    // No more required after bug fix 5903
    /*@AuraEnabled
    public static void populateContactOnMessages(String ICM_Cont_Id){
        List<MCFD_Message__c> listMsg = new List<MCFD_Message__c>([SELECT id, ICM_Contact_Id__c, Contact__c FROM MCFD_Message__c WHERE ICM_Contact_Id__c =: ICM_Cont_Id AND Contact__c = Null]);
        if(!listMsg.isEmpty()){
            List<Contact> matchingContact = new List<Contact>([SELECT Id, MCFD_Status__c, ICM_Contact_Id__c FROM Contact 
                                                                WHERE MCFD_Status__c <> 'Deactivated' 
                                                                AND ICM_Contact_Id__c =: ICM_Cont_Id]);
            if(!matchingContact.isEmpty()){
                System.debug('Number of matching contact records -->'+matchingContact.size());
                for(MCFD_Message__c item: listMsg){
                    item.Contact__c = matchingContact[0].Id;
                }
                update listMsg;
            }else{
                System.debug('populateContactOnMessages---> No contact found for contact Id->'+ICM_Cont_Id);
            }                                                       
        }else{
            System.debug('populateContactOnMessages---> No messages (without related contact) found for contact Id->'+ICM_Cont_Id);
        }
    }
    */
    
    /*-------------- Change Summary --------------
    PDAVE: Bug Fix 5541: Error handling for Start Renewal
    ----------------------------------------------*/
    @AuraEnabled
    public static Request__c getCCSCaseInfofromICM(String CaseNum) {
    
        Request__c request;
        String returnJSON = '', IsCCSRenewalStub = Label.Is_CCS_Renewal_Stub;
        System.debug('DLS--In getCCSCaesInfofromICM');
        //Create HTTP request and call ICM
        if(IsCCSRenewalStub == 'Yes'){
            MCFD_Integration_Stub__mdt stubData = [select JSONString__c from MCFD_Integration_Stub__mdt
                                                   where MasterLabel = 'CCS_Renewals_Stub' Limit 1];
            returnJSON = stubData.JSONString__c;
        }
        else{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMforCCSDetails?CaseNum='+CaseNum+'&CaseType=Child%20Care%20Subsidy');
            req.setMethod('GET');
            req.setHeader('Connection','keep-alive');
            req.setTimeout(Integer.valueOf(Label.Timeout_CCS_Renewal));
            
            Http http = new Http();
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();             
                System.debug('>>>> getCCSCaseInfofromICM Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                // Process JSON response and get the application prepopulation information
                System.debug('>>>>getCCSCaseInfofromICM: returnJSON:'+ returnJSON);
                if(res.getStatusCode()==200){
                 
                    String responseBody;
                    if(System.Label.ICM_Dummy_Error_Response_Mode_Renewal_Creation.toUpperCase() == 'ON'){
                        responseBody = System.Label.ICM_Dummy_Error_Response;
                    }else{
                        responseBody = res.getBody();
                    }
                    
                    ICMResponseParser parsedResponse = ICMResponseParser.parse(responseBody);
                    Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    system.debug('ICM_Response-->'+ICM_Response);
                    
                    // ----------------------------------------------- //
                    // ------- Handle error response (if any) -------- //
                    // ----------------------------------------------- //
	                if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
	                    // no handling in this case as request will not be created
	                    
	                }else{
	                // ----------------------------------------------- //
	                // ------- Handle success response --------------- //
	                // ----------------------------------------------- //
                    // Create CCS renewal request - better to create a separate function for processing response and creation of request
                    request = new Request__c();
                    RecordType rt = new RecordType();
                    if(request.Id == null){
                        request.Primary_Applicant__c = LoggedInUser[0].ContactId;
                        rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Renewal']; 
                        request.RecordTypeId = rt == null? '' : rt.Id;
				        if(parsedResponse != null ) {
				             
				            if(parsedResponse.docPortalResponse != null ) {
				                if(parsedResponse.docPortalResponse.HlsCase != null ) {
				                    
				                    // checkin if the HLS List has some cases 
				                    if(parsedResponse.docPortalResponse.HlsCase.size() > 0 ) {
				                        
				                        // Parsing the HLS Cases 
				                        for(ICMResponseParser.hlsCase thisCase :  parsedResponse.docPortalResponse.HlsCase) {
				                            //Update Request
				                            request.ICM_IncomePath__c = thisCase.Contact[0].IncomePath;
				                            request.MCFD_Status__c = 'Pending'; 
				                                         
				                            
				                            request = MCFD_CCSApplication.upsertRequest(request);
				                            System.debug('DLS--updating attachment');
        									System.debug(thisCase);
				                            //Now update FormDescription on request's attachment
                                            if(thisCase.Attachment != null) //adding this if for remedy 679109
                                            {
                                                String attID = thisCase.Attachment[0].RowID;
                                                List<MCFD_Attachment__c> attachmentList  = [SELECT ID FROM MCFD_Attachment__c WHERE ICM_Attachment_Id__c = :attID LIMIT 1];
                                                if (attachmentList.size()>0){
                                                    System.debug('DLS-- have attachment: '+attachmentList[0]);
                                                    MCFD_Attachment__c currentAttachment=attachmentList[0];
                                                    System.debug('DLS--attachment form description: '+thisCase.Attachment[0].FormDescription);
                                                    
                                                    currentAttachment.ICM_Description__c = thisCase.Attachment[0].FormDescription;
                                                    update currentAttachment;
                                                }
                                            }
				                            System.debug(request);
				                        }
				                        
				                        updateRenewalRequest(returnJSON,request);
				                    }
				                }
				            }
				        }
                    }
	              } 
                              
                }else{                      
                    MCFD_Logger.log_integration_error('Creation - CCS Renewal', 
                                                           MCFD_Logger.error, 
                                                           'MCFD_CallICMForContactDetails', 
                                                           'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());                 
                }                 
            }catch(Exception e) {
                //system.debug('Came to Exception');
                //System.debug(e.getmessage());
                System.debug(e.getmessage());
                MCFD_Logger.log_integration_error('Creation - CCS Renewal', 
                                                  MCFD_Logger.error, 
                                                  'MCFD_CallICMForContactDetails', 
                                                  'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());              
            }     
        }        
        // this would be null if any exeception occurred
        return request; 
    }
    @AuraEnabled 
    public static Request__c createCCSRenewal (String caseInfoJSON){
        // Create CCS renewal request - better to create a separate function for processing response and creation of request
        System.debug('DLS-- in createCCSRenewal');
        Request__c request = new Request__c();
        RecordType rt = new RecordType();
        if(request.Id == null){
            request.Primary_Applicant__c = LoggedInUser[0].ContactId;
            rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Renewal']; 
            request.RecordTypeId = rt == null? '' : rt.Id;
            request.MCFD_Status__c = 'Pending';              
            
            request = MCFD_CCSApplication.upsertRequest(request);
            System.debug(request);
        }
        
       // updateRenewalRequest(caseInfoJSON,request);
        
        return request; 
    }

    /*-------------- Change Summary --------------
    PDAVE: Bug Fix 5541: Error handling for Start Renewal
    ----------------------------------------------*/
     @AuraEnabled
    public static String getCalloutResponseContents(String CaseNum) {
        String returnJSON = '', IsCCSRenewalStub = Label.Is_CCS_Renewal_Stub;
        
        //Create HTTP request and call ICM
        if(IsCCSRenewalStub == 'Yes'){
            MCFD_Integration_Stub__mdt stubData = [select JSONString__c from MCFD_Integration_Stub__mdt
                                                   where MasterLabel = 'CCS_Renewals_Stub' Limit 1];
            returnJSON = stubData.JSONString__c;
        }
        else{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMforCCSDetails?CaseNum='+CaseNum+'&CaseType=Child%20Care%20Subsidy');
            req.setMethod('GET');
            req.setHeader('Connection','keep-alive');
            req.setTimeout(Integer.valueOf(Label.Timeout_CCS_Renewal));
            Http http = new Http();     
             try {
                
                HTTPResponse res = http.send(req);
                System.debug('>>>>getCalloutResponseContents Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                // Process JSON response and get the application prepopulation information
                System.debug('>>>> res.getBody():'+ res.getBody());
                if(res.getStatusCode()==200){
                 
                    String responseBody;
                    if(System.Label.ICM_Dummy_Error_Response_Mode_Renewal_Creation.toUpperCase() == 'ON'){
                        responseBody = System.Label.ICM_Dummy_Error_Response;
                    }else{
                        responseBody = res.getBody();
                    }
                    
                    Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    system.debug('ICM_Response-->'+ICM_Response);
                    
                    // ----------------------------------------------- //
                    // ------- Handle error response (if any) -------- //
                    // ----------------------------------------------- //
                    if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
                        // no handling in this case as request will not be created
                    }else{
                    // ----------------------------------------------- //
                    // ------- Handle success response --------------- //
                    // ----------------------------------------------- //
                        returnJSON = responseBody;
                        
                        // updating the spouse contact -- Added by Abhi 
                        MCFD_ICMResponseUtility.updateSpouseContactFromRenewal(returnJSON);
                    }
                              
                }else{                      
                    MCFD_Logger.log_integration_error('Creation - CCS Renewal', 
                                                           MCFD_Logger.error, 
                                                           'MCFD_CallICMForContactDetails', 
                                                           'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());                 
                }                 
            }catch(Exception e) {
                System.debug(e.getmessage());
                MCFD_Logger.log_integration_error('Creation - CCS Renewal', 
                                                  MCFD_Logger.error, 
                                                  'MCFD_CallICMForContactDetails', 
                                                  'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }     
        }
        // Process JSON response and get the application prepopulation information
        System.debug(returnJSON);
        return returnJSON;
            
      }

    @AuraEnabled
    public static void InsertAccessDeniedMessage(String MessageToUser, String Subject, String CaseType, String ICMContact, String SRnum)
    {
        System.debug('Insert access denied message');
        //create an access denied message if there is no other access denied message for this CaseType
        //get all messages for the logged in user and check if they have an access denied message already
        List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
        
        List<MCFD_Message__c> accessDeniedMessages = [SELECT Id, ICM_Program_Type__c, Message_Subject__c , Contact__c, ICM_SR_Number__c 
                                                        FROM MCFD_Message__c 
                                                        WHERE ICM_SR_Number__c =: SRnum AND
                                                             Contact__c =: LoggedInUser[0].ContactId];

        System.debug(accessDeniedMessages);                                               
        if (accessDeniedMessages.size() == 0)
        {
            MCFD_Message__c newMessage = new MCFD_Message__c();

            //newMessage.Message_Received_From__c = 'My Family Services';
            newMessage.ICM_Date_Message_Sent__c = datetime.now();

            //newMessage.ICM_Contact_Id__c = '1-407SJCD';

            newMessage.Contact__c = LoggedInUser[0].ContactId;

            newMessage.Message_Status__c = 'Sent from ICM';
            newMessage.Message_Body__c = MessageToUser;
            newMessage.Message_Subject__c = Subject;
            newMessage.ICM_Program_Type__c = CaseType;
            newMessage.ICM_SR_Number__c = SRnum;
            newMessage.ICM_Disable_Reply__c = true;
            newMessage.Message_Recipient__c = LoggedInUser[0].Contact.Name;
            newMessage.Message_Type__c = 'General Message';
            newMessage.Do_not_notify__c = true; // PDAVE: Bug fix 5316

            try{
                insert newMessage;

                newMessage.ICM_Conversation_Id__c = newMessage.Id;

                update newMessage;
            }
            catch (DMLException e){
                System.debug('failed to create access denied message');
                System.debug(e);
            }
        }

    }
    
    @AuraEnabled
    public static void updateRenewalRequest (String returnJSON, Request__c renewalRequest){
        //the integration stub json was giving errors in JSON parsing
        //using this test JSON for now
        //String testJSON = '{\"docPortalResponse\" : {\"HlsCase\" : [ {\"CaseNum\" : \"1-9361280450\",\"Status\" : \"Open\",\"Type\" : \"Child Care Subsidy\",\"CaseAddress\" : [ {\"UnitNum\" : \"701\",\"Line1\" : \"708 Burdett Ave.\",\"Line2\" : \"\",                                  \"City\" : \"Victoria\",                                  \"PostalCode\" : \"V8W 0A8\",                                  \"Province\" : \"BC\"                                } ],                \"PubCaseBenefitPlan\" : [ {                              \"AllocationAmount\" : \"0\",                              \"ApprovedBy\" : \"CGWRK33\",                              \"ApprovedDate\" : \"07/25/2017 08:54:55\",                              \"ApprovedOrders\" : \"\",                              \"BenefitPlanNum\" : \"\",                              \"BenefitPlanType\" : \"Benefit Plan\",                              \"CloseReason\" : \"\",                              \"Comments\" : \"\",                              \"Commitment\" : \"0\",                              \"CreatedByOffice\" : \"XWB - CHILD CARE SUBSIDY SERV\",                              \"EndPeriod\" : \"Jun 2017\",                              \"FamilyIncome\" : \"290\",                              \"FamilyType\" : \"Two Parents\",                              \"InCycleAllocationCalc\" : \"0\",                              \"InCycleRemainderCalc\" : \"0\",                              \"LockedFlag\" : \"N\",                              \"Name2\" : \"Pass port\",                              \"OutofCycleAllocationCalc\" : \"0\",                              \"OutofCycleRemainderCalc\" : \"0\",                              \"PlanExpiryDate\" : \"06/30/2017\",                              \"PlanName\" : \"\",                              \"PlanStartDate\" : \"06/01/2017\",                              \"ProgramArea\" : \"\",                              \"ProgramLength\" : \"\",                              \"ProgramName\" : \"CCS Benefit Plan\",                              \"RemainderAmount\" : \"750\",                              \"ServicePlan\" : \"\",                              \"StartPeriod\" : \"Jun 2017\",                              \"Status\" : \"Approved\",                              \"SystemComments\" : \"Assessed as eligible\",                              \"TotalAmount\" : \"750\",                              \"TotalInCycleAmountCalc\" : \"\",                              \"TotalOutofCycleAmountCalc\" : \"750\",                              \"TransitArea\" : \"\",                              \"TransitRate\" : \"\",                              \"VSFTotalAmount\" : \"0\",                                        \"PubCaseBenefitPlanLineItem\" : [ {                                          \"ActualAmount\" : \"\",                                          \"BenefitAmount\" : \"750\",                                          \"BenefitId\" : \"1-4ATHV4B\",                                          \"BenefitName2\" : \"Licensed Group\",                                          \"CFCSAmount\" : \"\",                                          \"CancellationDate\" : \"\",                                          \"CaseOfficeName\" : \"XWB - CHILD CARE SUBSIDY SERV\",                                          \"Comments\" : \"\",                                          \"CostCare\" : \"1000\",                                          \"CreatedByOffice\" : \"XWB - CHILD CARE SUBSIDY SERV\",                                          \"EffectiveDate\" : \"06/01/2017\",                                          \"EstimatedAmount\" : \"\",                                          \"ExpirationDate\" : \"06/30/2017\",                                          \"FamilyUnitFlag\" : \"N\",                                          \"FirstPaymentDate\" : \"\",                                          \"Frequency\" : \"Monthly\",                                          \"FullDayRate\" : \"37.50\",                                          \"FullDays\" : \"20\",                                          \"Funder\" : \"\",                                          \"HalfDayRate\" : \"18.75\",                                          \"HalfDays\" : \"0\",                                          \"InCycleFlag\" : \"N\",                                          \"LockedFlag\" : \"N\",                                          \"OPAAmountPaid\" : \"\",                                          \"OPABenefitMonth\" : \"\",                                          \"OPADeterminedAmount\" : \"\",                                          \"OPAMaritalStatus\" : \"\",                                          \"OverriddenBy\" : \"\",                                          \"OverrideDate\" : \"\",                                          \"OverrideFlag\" : \"N\",                                          \"ParentPortionAmount\" : \"0\",                                          \"Period\" : \"\",                                          \"PeriodAdjusted\" : \"\",                                          \"Product\" : \"G1\",                                          \"ProductSTOB\" : \"7916\",                                          \"ProductServiceId\" : \"\",                                          \"ProviderName\" : \"\",                                          \"Quantity\" : \"\",                                          \"ReasonCare\" : \"Employed\",                                          \"RecipientContactFirstName\" : \"Kyle\",                                          \"RecipientContactLastName\" : \"Garcia\",                                      \"RecipientContactId\" : \"1-4ATGQ2T\",                                          \"RecipientContactMiddleName\" : \"\",                                          \"RecurringPaymentAmount\" : \"\",                                          \"ServiceLocationType\" : \"\",                                          \"ServiceRequestId\" : \"\",                                          \"Status\" : \"Approved\",                                          \"SupervisorApprovalFlag\" : \"N\",                                          \"SystemComments2\" : \"Assessed as eligible\",                                          \"Type\" : \"\",                                          \"UnitofMeasure\" : \"\",                                          \"YPPAmount\" : \"\"                                        } ]                  } ],                  \"Contact\" : [ {                                \"SIN\" : \"\",                                \"Gender\" : \"Female\",                                \"MiddleName\" : \"\",                                \"ICMContactId\" : \"1-4AW043K\",                                \"BirthDate\" : \"03/15/1990\",                                \"FirstName\" : \"Claire\",                                \"LastName\" : \"Winter\",                                \"Relationship\" : \"Key player\",                                \"SpecialNeedsStatus\" : \"\",                                \"ChildCareRequired\" : \"N\",                                \"MinistryPlacementStatus\" : \"\",                                \"SharedCustodyStatus\" : \"\",                                \"CustodyDetail\" : \"\",                                \"DisabilityStatus\" : \"\",                                \"Email\" : \"claire.winter@mcfdportal.ca\",                                \"CellPhone\" : \"7676870999\",                                \"HomePhone\" : \"2345678655\",                                \"WorkPhone\" : \"\"                                  },                              {                                \"SIN\" : \"\",                                \"Gender\" : \"Male\",                                \"MiddleName\" : \"\",                                \"ICMContactId\" : \"1-4ATGPZV\",                                \"BirthDate\" : \"02/15/1990\",                                \"FirstName\" : \"Juan\",                                \"LastName\" : \"Garcia\",                                \"Relationship\" : \"Spouse\",                                \"SpecialNeedsStatus\" : \"\",                                \"ChildCareRequired\" : \"\",                                \"MinistryPlacementStatus\" : \"\",                                \"SharedCustodyStatus\" : \"\",                                \"CustodyDetail\" : \"\",                                \"DisabilityStatus\" : \"Confirmed\",                                \"Email\" : \"\",                                \"CellPhone\" : \"\",                                \"HomePhone\" : \"\",                                \"WorkPhone\" : \"\"                                  },                              {                                \"SIN\" : \"\",                                \"Gender\" : \"Male\",                                \"MiddleName\" : \"\",                                \"ICMContactId\" : \"1-4ATGQ2T\",                                \"BirthDate\" : \"03/19/2014\",                                \"FirstName\" : \"Kyle\",                                \"LastName\" : \"Garcia\",                                \"Relationship\" : \"Son\",                                \"SpecialNeedsStatus\" : \"Temporary\",                                \"ChildCareRequired\" : \"Y\",                                \"MinistryPlacementStatus\" : \"N\",                                \"SharedCustodyStatus\" : \"N\",                                \"CustodyDetail\" : \"\",                                \"DisabilityStatus\" : \"\",                                \"Email\" : \"\",                                \"CellPhone\" : \"\",                                \"HomePhone\" : \"\",                                \"WorkPhone\" : \"\"                                  },                              {                                \"SIN\" : \"\",                                \"Gender\" : \"Female\",                                \"MiddleName\" : \"\",                                \"ICMContactId\" : \"1-4ATGQ56\",                                \"BirthDate\" : \"03/15/1951\",                                \"FirstName\" : \"Deborah\",                                \"LastName\" : \"Swanson\",                                \"Relationship\" : \"Grand Mother\",                                \"SpecialNeedsStatus\" : \"\",                                \"ChildCareRequired\" : \"N\",                                \"MinistryPlacementStatus\" : \"N\",                                \"SharedCustodyStatus\" : \"N\",                                \"CustodyDetail\" : \"\",                                \"DisabilityStatus\" : \"Reported\",                                \"Email\" : \"\",                                \"CellPhone\" : \"\",                                \"HomePhone\" : \"\",                                \"WorkPhone\" : \"\"                                  }                          ]                  } ]              }            }';
        
        
        //deserialize the JSON data
        JSONParser parser = JSON.createParser(returnJSON);
        System.debug(parser);
        List<ContactJSON> contactList = new List<ContactJSON>();
        List<BenefitPlanJSON> benefitPlanList = new List<BenefitPlanJSON>();
        List<BenefitJSON> benefitList = new List<BenefitJSON>();
        AddressJSON newAddress;
        // Boolean hasCRAConsent = MCFD_ICMResponseUtility.hasActiveCRAConsent(returnJSON);
        Map<string,boolean> consentContactMap = new Map<string,boolean>();
        Map<string,ICMResponseParser.Consent>  contactConsentmap = new Map<string,ICMResponseParser.Consent>();
        
        consentContactMap = MCFD_ICMResponseUtility.contactActiveCRAConsent(returnJSON);
        system.debug('consentContactMap: '+consentContactMap);
        // This map is to store the Contact ID with the Consents
        contactConsentmap = MCFD_ICMResponseUtility.updateContactFromRenewal(returnJSON);
	     //System.Debug('------Abhi--1111-----'+MCFD_ICMResponseUtility.contactActiveCRAConsent(returnJSON));
        System.Debug('------Abhi--1111-----'+consentContactMap);  
         System.Debug('------Abhi--1111-----consentContactMap'+contactConsentmap);  
        while (parser.nextToken() != null) {
            //System.debug('getCurrentToken ==>> '+parser.getCurrentToken());
            if (parser.getText() == 'Contact')
            {
                System.Debug('Got to contact part of JSON');
		while (parser.nextToken() != JSONToken.END_ARRAY) {
                    // Advance to the start object marker to
                    //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        ContactJSON newContact = (ContactJSON)parser.readValueAs(ContactJSON.class);
                        System.debug(newContact);
                        //newContact.hasCraConsent = hasCRAConsent;    
                        contactList.add(newContact);
                        System.debug(contactList);
                        parser.skipChildren();
                    }
                }
                //without this break after the contact parsing, the parser fails with the following error:
                //System.JSONException: Unexpected close marker ']': expected '}'
                break;
            }
            if (parser.getText() == 'PubCaseBenefitPlan')
            {
                while (parser.nextToken() != JSONToken.END_ARRAY) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        BenefitPlanJSON newBenefitPlan = (BenefitPlanJSON)parser.readValueAs(BenefitPlanJSON.class);
                        System.debug(newBenefitPlan);
                        benefitPlanList.add(newBenefitPlan);
                        System.debug(benefitPlanList);
                    }
                }
            }
            if (parser.getText() == 'CaseAddress')
            {
                while (parser.nextToken() != JSONToken.END_ARRAY) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        newAddress = (AddressJSON)parser.readValueAs(AddressJSON.class);
                        System.debug(newAddress);
                        parser.skipChildren();
                    }
                }
            }
        }
        System.debug('Contact list ==>>>'+contactList);
        
        spouseId = null;

        string thisSpouseContactID;
      	for( MCFD_Relationship__c relatnship : [SELECT MCFD_Child_Contact__c,MCFD_Child_Contact__r.ICM_Contact_Id__c FROM MCFD_Relationship__c where MCFD_Parent_Contact__c =: renewalRequest.Primary_Applicant__c and MCFD_Relationship_Type__c = 'Spouse' order by createdDate DESC limit 1] ) {
				system.debug('-----Abhi--111---'+relatnship);
				if(string.isBlank(relatnship.MCFD_Child_Contact__r.ICM_Contact_Id__c)) {
					thisSpouseContactID = relatnship.MCFD_Child_Contact__c;
					system.debug('-----Abhi--2222---'+thisSpouseContactID);
				
				}

		}
        
        
        for (ContactJSON newContact : contactList){
            system.debug(newContact);
            if(string.isNotBlank(thisSpouseContactID)) {
            	newContact.spouseId = thisSpouseContactID;
            
            }
            addContactToRequest(newContact, renewalRequest, benefitPlanList, newAddress,consentContactMap,contactConsentmap);            	
             
        }
    }
    
    @AuraEnabled
    public static void addContactToRequest(ContactJSON contactToAdd, Request__c renewal, List<BenefitPlanJSON> benefitPlanList, AddressJSON address,Map<string,Boolean> consentContactMap,Map<string,ICMResponseParser.Consent> contactConsentmap ){
        
        
        //create the new contact based on the contact JSON
        Contact newContact = new Contact();
        newContact.ICM_Contact_Id__c = contactToAdd.ICMContactId;
        newContact.FirstName = contactToAdd.FirstName;
        newContact.MiddleName = contactToAdd.MiddleName;
        newContact.LastName = contactToAdd.LastName;
        
        newContact.MCFD_SIN__c = contactToAdd.SIN;
        newContact.MCFD_Gender__c = contactToAdd.Gender;
        newContact.Email = contactToAdd.Email;
        newContact.MCFD_Provide_SIN__c = false;
	    newContact.Send_ICM_Contact_ID__c = true;
        system.debug('--------contactConsentmap----'+contactConsentmap+'---ICM Contact ID'+contactToAdd.ICMContactId);
        
        // Renewal Integration Active CRA Consent 
        if(consentContactMap.get(contactToAdd.ICMContactId) != null ) {
        	if(consentContactMap.get(contactToAdd.ICMContactId)) {
        	   
	        	newContact.MCFD_HasActiveCRAConsent__c = true;
	        } else {
	        	newContact.MCFD_HasActiveCRAConsent__c = false;
	        }
            system.debug('newContact.ICM_Contact_Id__c: 1'+newContact.ICM_Contact_Id__c);
             system.debug('newContact.MCFD_HasActiveCRAConsent__c: 1'+newContact.MCFD_HasActiveCRAConsent__c);
        }
        
        
	newContact.MCFD_Address_Check__c = '';

        System.Debug(contactToAdd.SIN);

        if (contactToAdd.SIN != '' && contactToAdd.SIN != null)
            newContact.SIN_Read_Only__c = true;
        // Removing phone number mappings here - Bug 4775
    /*    newContact.ICM_Cell_Phone__c = contactToAdd.CellPhone;
        newContact.ICM_Home_Phone__c = contactToAdd.HomePhone;
        newContact.ICM_Work_Phone__c = contactToAdd.WorkPhone;  */
        
        
        //new to format the date in YYYY-MM-DD for Date.ValueOf to work properly
        String[] dateArray = contactToAdd.Birthdate.split('/');
        //String birthdateString = dateArray[2] + '-' + dateArray[1] + '-' + dateArray[0];
        // System.debug(birthdateString);
        //newContact.Birthdate = date.parse(birthdateString);
        Date birthdate = Date.newInstance(Integer.valueOf(dateArray[2]),Integer.valueOf(dateArray[0]),Integer.valueOf(dateArray[1]));
        newContact.Birthdate = birthdate;
        
        
        
        if (contactToAdd.DisabilityStatus == 'Reported' || contactToAdd.DisabilityStatus == 'Confirmed')
            newContact.MCFD_Govt_Disability_Benefit__c = 'Yes';
        else
            newContact.MCFD_Govt_Disability_Benefit__c = 'No';
        
        system.debug('=============00============'+renewal);
        
        if (contactToAdd.Relationship == 'Key player')
        {
            newContact.Id = LoggedInUser[0].ContactId;  // PDAVE: Bug fix : 5235
			//create an account to link all the family members to
            //this was added by laura to allow access to the spouse contact record
            /*----------------------------------------------------------------------
            Bug fix - 5425 -  Summary of changes
			Use the account associated to the applicant (logged in user) and 
			associate it to the other dependent contacts
            ----------------------------------------------------------------------*/
       /*   Account newAccount = new Account();
            newAccount.Name = newContact.LastName + ', ' + newContact.FirstName;

            insert newAccount; 

            System.debug('New account ID == > ' + newAccount.Id);	

            newContact.AccountId = newAccount.Id;	*/

            //LPERRY: bug fix 5922
            String relationshipType = 'Spouse';
            if (spouseId != null)
            {
                newContact.MCFD_Marital_Status__c = 'Married, or living in a marriage-like relationship';
            }
            else{
                newContact.MCFD_Marital_Status__c = 'Single, separated, divorced or widowed';
            }

            newContact = MCFD_CCSApplication.upsertContact(newContact);
             system.debug('newContact.ICM_Contact_Id__c: 2'+newContact.ICM_Contact_Id__c);
             system.debug('newContact.MCFD_HasActiveCRAConsent__c: 2'+newContact.MCFD_HasActiveCRAConsent__c);
            //add the contact to the request as the main applicant
            renewal.Primary_Applicant__c = newContact.Id;
            renewal = MCFD_CCSApplication.upsertRequest(renewal);
            
            // Bug 4775 - Phone number mapping logic
            if(contactToAdd.CellPhone != null && contactToAdd.CellPhone != ''){
                newContact.Phone = contactToAdd.CellPhone;
                newContact.MCFD_Primary_Phone_Number_Type__c = 'Cell';
                if(contactToAdd.HomePhone != null && contactToAdd.HomePhone != ''){
                    newContact.MobilePhone = contactToAdd.HomePhone;
                    newContact.MCFD_Secondary_Phone_Number_Type__c = 'Home';
                }
                else if(contactToAdd.WorkPhone != null && contactToAdd.WorkPhone != ''){
                    newContact.MobilePhone = contactToAdd.WorkPhone;
                    newContact.MCFD_Secondary_Phone_Number_Type__c = 'Work';
                }
            }
            else if(contactToAdd.HomePhone != null && contactToAdd.HomePhone != ''){
                newContact.Phone = contactToAdd.HomePhone;
                newContact.MCFD_Primary_Phone_Number_Type__c = 'Home';
                if(contactToAdd.WorkPhone != null && contactToAdd.WorkPhone != ''){
                    newContact.MobilePhone = contactToAdd.WorkPhone;
                    newContact.MCFD_Secondary_Phone_Number_Type__c = 'Work';
                }
            }
            else if(contactToAdd.WorkPhone != null && contactToAdd.WorkPhone != ''){
                newContact.Phone = contactToAdd.WorkPhone;
                newContact.MCFD_Primary_Phone_Number_Type__c = 'Work';
            }

            newContact.MCFD_Attending_School__c = false;
            newContact.MCFD_Currently_Employed__c = false;
            newContact.MCFD_Looking_For_Work__c = false;
            newContact.MCFD_Self_Employed__c = false;
            newContact.MCFD_Medical_Condition__c = false;
            newContact.MCFD_Employment_Prog__c = false;
            newContact.MCFD_Is_SW_Referred__c = '';

             // 6052 Added Abhi 
           if(contactConsentmap.get(contactToAdd.ICMContactId) != null ) {
    	        
    	        system.debug('-------5555 Abhi ------'+contactConsentmap.get(contactToAdd.ICMContactId)+'********'+contactToAdd.ICMContactId);
    	        ICMResponseParser.Consent thisConsent = contactConsentmap.get(contactToAdd.ICMContactId);
	        	newContact.ICM_CreatedByName__c = thisConsent.CreatedByName;
                newContact.ICM_Created__c = thisConsent.Created;
                newContact.ICM_Consent_CaseNumber__c = thisConsent.CaseNumber;
                newContact.ICM_ConsentStatus__c = thisConsent.Status;
                newContact.ICM_StartDate__c = thisConsent.StartDate;
                newContact.ICM_EndDate__c = thisConsent.EndDate;
                newContact.ICM_DueDate__c = thisConsent.DueDate;
                newContact.ICM_Description__c = thisConsent.Description;
                newContact.ICM_FromContact__c = thisConsent.FromContact;
                newContact.ICM_ToContact__c = thisConsent.ToContact;
                newContact.ICM_SubType__c = thisConsent.SubType;
	        	
	        
	        }

            newContact = MCFD_CCSApplication.upsertContact(newContact);
             system.debug('newContact.ICM_Contact_Id__c: 3'+newContact.ICM_Contact_Id__c);
             system.debug('newContact.MCFD_HasActiveCRAConsent__c: 3'+newContact.MCFD_HasActiveCRAConsent__c);
            
            //create a new address to add to the contact
            MCFD_Address__c tempAddress = new MCFD_Address__c();

            if (address != null)
            {
                if(address.UnitNum != null && address.UnitNum != '')
                tempAddress.UnitNum__c = address.UnitNum;  // Bug fix 4765
                
                if(address.Line2 != null && address.Line2 != '')
                    tempAddress.MCFD_Address_Line_1__c = address.Line1 + ' ' + address.Line2;
                
                else
                  tempAddress.MCFD_Address_Line_1__c = address.Line1;
               // tempAddress.MCFD_Address_Line_2__c = address.Line2;

                tempAddress.MCFD_City__c = address.City;
                tempAddress.MCFD_Postal_Code__c = address.PostalCode;
                tempAddress.MCFD_Province__c = address.Province;
                tempAddress.MAKId__c = address.MAKId;
                tempAddress = MCFD_CCSApplication.upsertAddress(tempAddress);

                MCFD_Contact_Address__c conAddress = new MCFD_Contact_Address__c();
                conAddress.MCFD_Address_Type__c = 'Mailing Address';
                conAddress.MCFD_Address__c = tempAddress.Id;
                conAddress.MCFD_Request__c = renewal.Id;
                conAddress.MCFD_Contact__c = newContact.Id;
                MCFD_CCSApplication.upsertConAddress(conAddress);
            }
        }
        else if (contactToAdd.Relationship == 'Spouse')
        {
            //update the primary contact to have a spouse
            Contact primaryApp = [SELECT MCFD_Marital_Status__c, Id, AccountId From Contact Where Id =: renewal.Primary_Applicant__c];
            primaryApp.MCFD_Marital_Status__c = 'Married, or living in a marriage-like relationship';
            system.debug('***11111*ICM_Contact_Id__c****'+primaryApp.ICM_Contact_Id__c);
            primaryApp = MCFD_CCSApplication.upsertContact(primaryApp);

			string newContactId;
			
			if(string.isNotBlank(contactToAdd.spouseId)) {
                newContactId = contactToAdd.spouseId;
            }
            
            newContact.AccountId = primaryApp.AccountId;

            newContact.MCFD_Attending_School__c = false;
            newContact.MCFD_Currently_Employed__c = false;
            newContact.MCFD_Looking_For_Work__c = false;
            newContact.MCFD_Self_Employed__c = false;
            newContact.MCFD_Medical_Condition__c = false;
            newContact.MCFD_Employment_Prog__c = false;
            newContact.MCFD_Is_SW_Referred__c = '';

            
            
           // 6052 Added Abhi 
           if(contactConsentmap.get(contactToAdd.ICMContactId) != null ) {
    	        
    	        
    	        ICMResponseParser.Consent thisConsent = contactConsentmap.get(contactToAdd.ICMContactId);
	        	newContact.ICM_CreatedByName__c = thisConsent.CreatedByName;
                newContact.ICM_Created__c = thisConsent.Created;
                newContact.ICM_Consent_CaseNumber__c = thisConsent.CaseNumber;
                newContact.ICM_ConsentStatus__c = thisConsent.Status;
                newContact.ICM_StartDate__c = thisConsent.StartDate;
                newContact.ICM_EndDate__c = thisConsent.EndDate;
                newContact.ICM_DueDate__c = thisConsent.DueDate;
                newContact.ICM_Description__c = thisConsent.Description;
                newContact.ICM_FromContact__c = thisConsent.FromContact;
                newContact.ICM_ToContact__c = thisConsent.ToContact;
                newContact.ICM_SubType__c = thisConsent.SubType;
	        	
	        
	        }
            
            
            system.debug('***22222*****ICM_Contact_Id__c****'+newContact.ICM_Contact_Id__c);
            // Added by Abhi to stop the Duplicate Contact from Renewal Integration
            if(string.isNotBlank(newContact.ICM_Contact_Id__c)) {
            	for(Contact spouseContact : [SELECT Id,Email From Contact Where ICM_Contact_Id__c =: newContact.ICM_Contact_Id__c order by createdDate ASC limit 1]) {
            		newContactId = spouseContact.Id;
        			system.debug('***44444*****ICM_Contact_Id__c****'+newContactId+'--------'+spouseContact);
            	
            	}
            	
            } 
              
            // checking if the new contact id is blank - When the user clicks on Renewal from Dashboard and Click Start renewal
            if(string.isBlank(newContactId)) {
                if(string.isNotBlank(contactToAdd.spouseId)) {
                	newContactId = contactToAdd.spouseId;
                }
            }
            
        	system.debug('**555555***ICM_Contact_Id__c****'+newContactId);
           
            // if the new contact ID is not blank 
            if(string.isNotBlank(newContactId)) {
            	newContact.id = newContactId;
            	system.debug('***55555*****ICM_Contact_Id__c****'+newContact.Id);
			
            }
			
            newContact = MCFD_CCSApplication.upsertContact(newContact);
             system.debug('newContact.ICM_Contact_Id__c: 4'+newContact.ICM_Contact_Id__c);
             system.debug('newContact.MCFD_HasActiveCRAConsent__c: 4'+newContact.MCFD_HasActiveCRAConsent__c);
            
            
            //add the spouse to the request and create a relationship
            renewal.Spouse__c = newContact.Id;

            //added to fix bug 5922 
            spouseId = newContact.Id;

            renewal = MCFD_CCSApplication.upsertRequest(renewal);
            
            MCFD_Relationship__c relationship = new MCFD_Relationship__c();
            relationship.MCFD_Parent_Contact__c = renewal.Primary_Applicant__c;
            relationship.MCFD_Child_Contact__c = newContact.Id;
            relationship.MCFD_Request__c = renewal.Id;
            relationship.MCFD_Relationship_Type__c = 'Spouse';
            MCFD_CCSApplication.upsertRelationship(relationship);
        }
        else{
            if (contactToAdd.ChildCareRequired == 'Y')
                newContact.MCFD_Childcare_Require__c = 'Yes';
            else
                newContact.MCFD_Childcare_Require__c = 'No';
            
            if (newContact.MCFD_Childcare_Require__c == 'Yes' && contactToAdd.MinistryPlacementStatus == 'Y')
                newContact.MCFD_Child_Placement__c = 'Yes';
            else
                newContact.MCFD_Child_Placement__c = 'No';
            
            if(newContact.MCFD_Childcare_Require__c == 'Yes' && contactToAdd.SharedCustodyStatus == 'Y') {
                newContact.MCFD_Is_Custody_Shared__c = 'Yes';
	    } else {
	    	newContact.MCFD_Is_Custody_Shared__c = 'No';
	    }
            if(newContact.MCFD_Is_Custody_Shared__c == 'Yes') {
                newContact.MCFD_Custody_Details__c = '';
	    }	    
            //else
               // newContact.MCFD_Custody_Details__c = '';
            
            if(string.isNotBlank(contactToAdd.SpecialNeedsStatus)) {
            	newContact.ICM_SpecialNeedsStatus__c  = contactToAdd.SpecialNeedsStatus;
            
            }
            
            if (contactToAdd.SpecialNeedsStatus == 'Reported' || contactToAdd.SpecialNeedsStatus == 'Temporary'|| contactToAdd.SpecialNeedsStatus == 'Permanent')
                newContact.MCFD_Special_needs__c = 'Yes';
            else
                newContact.MCFD_Special_needs__c = 'No';
            
            // Care types logic 
            for(BenefitPlanJSON benefitPlan: benefitPlanList){
        List<BenefitJSON> benefitList = benefitPlan.PubCaseBenefitPlanLineItem;
                for(BenefitJSON benefit: benefitList){
                    if(newContact.ICM_Contact_Id__c == benefit.RecipientContactId && benefit.Status == 'Approved'){
                        if(benefit.BenefitName2 == 'Licensed Group' || benefit.BenefitName2 == 'Licensed OOS Care/Licensed Grp'){
                            newContact.MCFD_Licensed_Group_CC__c = true;
                        }
                        if(benefit.BenefitName2 == 'Licensed Family'){
                            newContact.MCFD_Licensed_Family_CC__c = true;
                        }
                        if(benefit.BenefitName2 == 'Preschool'){
                            newContact.MCFD_Licensed_Preschool__c = true;
                        }
                        if(benefit.BenefitName2 == 'Registered Licence Not Rquired'){
                            newContact.MCFD_Reg_Lic_Not_Req__c = true;
                        }
                        if(benefit.BenefitName2 == 'Licence Not Required'){
                            newContact.MCFD_Lic_Not_Reqrd__c = true;
                        }
                        if(benefit.BenefitName2 == 'In Childs Own Home'){
                            newContact.MCFD_In_Childs_Own_Home__c = true;
                        }
                    }
                }
            }

            //get primary app account
            Contact primaryApp = [SELECT MCFD_Marital_Status__c, Id, AccountId From Contact Where Id =: renewal.Primary_Applicant__c];
            newContact.AccountId = primaryApp.AccountId;				 // PDAVE: Bug fix 5235 // // You cannot assign a Portal Account or Contact to a Portal user

            newContact = MCFD_CCSApplication.upsertContact(newContact);
             system.debug('newContact.ICM_Contact_Id__c: 5'+newContact.ICM_Contact_Id__c);
             system.debug('newContact.MCFD_HasActiveCRAConsent__c: 5'+newContact.MCFD_HasActiveCRAConsent__c);

            MCFD_Relationship__c relationship = new MCFD_Relationship__c();
            relationship.MCFD_Parent_Contact__c = renewal.Primary_Applicant__c;
            relationship.MCFD_Child_Contact__c = newContact.Id;
            relationship.MCFD_Request__c = renewal.Id;
            relationship.MCFD_Relationship_Type__c = 'Dependant';
            MCFD_CCSApplication.upsertRelationship(relationship);
        }
        
        
    }
    
    
    
    
    public class ContactJSON {
        public String SIN;
        public String Gender;
        public String MiddleName;
        public String ICMContactId;
        public String BirthDate;
        public String FirstName;
        public String LastName;
        public String Relationship;
        public String SpecialNeedsStatus;
        public String ChildCareRequired;
        public String MinistryPlacementStatus;
        public String SharedCustodyStatus;
        public String CustodyDetail;
        public String DisabilityStatus;
        public String Email;
        public String CellPhone;
        public String HomePhone;
        public String WorkPhone;
	    public boolean hasCraConsent;
	    public string spouseId ;
        
        public ContactJSON(String sin, String gender, String middleName, String iCMContactId, String birthDate, 
                           String firstName, String lastName, String relationship, String specialNeedsStatus, 
                           String childCareRequired, String ministryPlacementStatus, String sharedCustodyStatus, String custodyDetail,
                           String disabilityStatus, String email, String cellPhone, String homePhone, String workPhone){
                               
                               SIN = sin;
                               Gender = gender;
                               MiddleName = middleName;
                               ICMContactId = iCMContactId;
                               BirthDate = birthDate;
                               FirstName = firstName;
                               LastName = lastName;
                               Relationship = relationship;
                               SpecialNeedsStatus = specialNeedsStatus;
                               ChildCareRequired = childCareRequired;
                               MinistryPlacementStatus = ministryPlacementStatus;
                               SharedCustodyStatus = sharedCustodyStatus;
                               CustodyDetail = custodyDetail;
                               DisabilityStatus = disabilityStatus;
                               Email = email;
                               CellPhone = cellPhone;
                               HomePhone = homePhone;
                               WorkPhone = workPhone;
                           }
    } 
    
    public class AddressJSON {
        public String UnitNum;
        public String Line1;
        public String Line2;
        public String City;
        public String PostalCode;
        public String Province;
        public String MAKId;

        public String ProgramName;
        public String Status;
        public List<BenefitJSON> PubCaseBenefitPlanLineItem;
        
        public AddressJSON(String unitNum, String line1, String line2, String city, String postalCode, String province, String makId){
            
            UnitNum = unitNum;
            Line1 = line1;
            Line2 = line2;
            City = city;
            PostalCode = postalCode;
            Province = province;
            MAKId = makId;
        }
    }

    public class BenefitPlanJSON {
        public String ProgramName;
        public String Status;
        public List<BenefitJSON> PubCaseBenefitPlanLineItem;
        
        public BenefitPlanJSON(String programName, String status, List<BenefitJSON> benefitList){
            
            ProgramName = programName;
            Status = status;
            PubCaseBenefitPlanLineItem = benefitList;
        }
    }
    public class BenefitJSON {
        public String RecipientContactId;
        public String Status;
        public String BenefitName2;
        
        public BenefitJSON(String recipientContactId, String status, String benefitName2){
            
            RecipientContactId = recipientContactId;
            Status = status;
            BenefitName2 = benefitName2;
        }
    }
    public class RequestJSON{
        public String SRNumber;
        public String Status;
        public String SubStatus;
        public String Resolution;
        public String SRType;
        public String SubType;
        public String SubSubType;
        public String ClosedDate;
        public String CreatedDate;
        
        public RequestJSON(String srNumber, String status, String subStatus, String resolution, String srType,
                          String subType, String subSubType, String closedDate, String createdDate){
            SRNumber = srNumber;
            Status = status;
            SubStatus = subStatus;
            Resolution = resolution;                  
            SRType = srType;                 
            SubType = subType;                  
            SubSubType = subSubType;
            ClosedDate = closedDate;                  
            CreatedDate = createdDate;               
        }
    }
    public static String createRequestStatusXML(List<Request__c> getRequestStatusList){
        String xmlString = '';
        try{ 
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null,'1.0');
            w.writeStartElement(null,'Document',null);
            w.writeStartElement(null,'Header',null);
            w.writeStartElement(null,'TransactionName',null);
            w.writeCharacters('AccessToSRStatusFromMYSS–INT513');
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
            w.writeCharacters('Status');
            w.writeEndElement();
            
            w.writeStartElement(null,'ListOfSRNumbers',null);
            for(Request__c request:getRequestStatusList){
                w.writeStartElement(null,'SRNumbers',null);   
                w.writeStartElement(null, 'SRNumber', null);
                w.writeCharacters(request.ICM_SR_Number__c != null?request.ICM_SR_Number__c:'');
                w.writeEndElement();
                w.writeEndElement();
            }
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            
            xmlString = w.getXmlString();
            w.close();
            
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForContactDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }
        return xmlString;
    }
    @AuraEnabled
    public static void cancelICMSR(String requestId){
        // Query for the request and get SR number
        Request__c requestInfo = new Request__c();
        
        try{
            requestInfo = [select ICM_SR_Number__c, MCFD_Status__c, MCFD_Type__c, Resolution_Status__c, Name
                          from Request__c where id = :requestId];
            // if SR number found, then create a HTTP request and invoke INT 512 update operation
                if(requestInfo.ICM_SR_Number__c != null){
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:CallWMToSubmitRTP');
                    req.setTimeout(Integer.valueOf(System.Label.CCS_Shell_SR_Timeout));
                    req.setMethod('POST');
                    req.setHeader('Connection', 'keep-alive');
                    req.setHeader('Content-Type', 'application/json');
                    
                    String returnJSON = '';
                    String JSONString = '{'+
                                    '"Operation": "Delete",'+
                                    '"SRNumber" : "' + requestInfo.ICM_SR_Number__c + '"' +
                                    '}';
                    
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('Name', JSONString);
                    gen.writeEndObject();
                    
                    req.setBody(gen.getAsString());
                    
                    try{
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        returnJSON = res.getBody();
                        System.debug(returnJSON);
                        
                        // Parse the return JSON and check status
                        JSONParser parser = JSON.createParser(returnJSON);
                        String icmResponseStatus = '';
                        while(parser.nextToken() != null){
                            System.debug(parser.getCurrentToken());
                            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'Result'){
                                // Get the value - that will be the next token
                                parser.nextToken();
                                icmResponseStatus = parser.getText();
                                System.debug(icmResponseStatus);
                                
                            }
                        }
                        
                        if(res.getStatusCode()==200 && (icmResponseStatus == 'SUCCESS' || icmResponseStatus == 'Success'))
                        {
                            // update the request resolution status and status 
                            requestInfo.MCFD_Status__c = 'Closed';
                            requestInfo.Resolution_Status__c = 'Withdrawn';
                            requestInfo = MCFD_CCSApplication.upsertRequest(requestInfo);
                        }
                    } 
                    catch(System.CalloutException e){
                        MCFD_Logger.log_integration_error('Withdraw application update to ICM', MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
                    } 
                }
            else{
                // update the request resolution status and status 
                requestInfo.MCFD_Status__c = 'Closed';
                requestInfo.Resolution_Status__c = 'Withdrawn';
                requestInfo = MCFD_CCSApplication.upsertRequest(requestInfo);
            }
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForContactDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }
    }
}