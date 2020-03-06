public without sharing class MCFD_ContentController {
    
    @future(callout=true)
    public static void CallICMforAttachmentUpload (Id attachId, String XMLrequest, String Operation){
    system.debug('#######CallICMforAttachmentUpload');
    String strStdAttchId = String.valueOf(attachId);
        
    MCFD_Document_Integration_Engine__c DocEngine = [select id from MCFD_Document_Integration_Engine__c
                                                     where Child_Standard_Attachment__c =: strStdAttchId limit 1];
        
    if(Operation == 'Upload')
    {
       // System.debug('Calling submit for document upload');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMforAttachments');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('Name', XMLrequest);
        gen.writeEndObject();
        
        req.setBody(gen.getAsString());
        Http http = new Http();
        try 
        {
            HTTPResponse res = http.send(req);
            returnJSON = res.getBody();
            if(res.getStatusCode()==200)
            {
                JSONParser parser = JSON.createParser(res.getBody());
                String ICMAttachId = '';
                while (parser.nextToken() != null) 
                {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'AttachmentId') 
                    {
                        // Get the value.
                        parser.nextToken();
                        // Compute the grand total price for all invoices.
                        ICMAttachId = parser.getText();
                    }
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'ErrorMessage')
                    {
						DocEngine.Integration_Status__c = 'Error';
                		DocEngine.Integration_Operation__c = 'Upload';
						update DocEngine;
		                MCFD_Logger.log_integration_error('Document Submission to ICM', MCFD_Logger.Info, 'MCFD_ContentController' ,returnJSON );						
						return;                    	
                    }                    
                }
                DocEngine.ICM_Attachment_Id__c = ICMAttachId;
                DocEngine.Integration_Status__c = 'Synced';
                DocEngine.Integration_Operation__c = 'Upload';
                update DocEngine;   
               // MCFD_Logger.log_integration_error('Document Submission to ICM', MCFD_Logger.Info, 'MCFD_ContentController' ,returnJSON );
            	//above line is not needed as sync operation should not have error logging.
            }
            else
            {
            	DocEngine.Integration_Status__c = 'Error';
                DocEngine.Integration_Operation__c = 'Upload';
                update DocEngine;                
                MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Integration error with ICM', DocEngine.Id);
            }
        } 
        catch(System.CalloutException e) 
        {    
            DocEngine.Integration_Status__c = 'Error';
            DocEngine.Integration_Operation__c = 'Upload';
            update DocEngine;                
            MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString(), DocEngine.Id);
        }     
        //return returnJSON;
    }
    else if(Operation == 'Delete')
    {
        // System.debug('Calling submit for document delete');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMforAttachments');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('Name', XMLrequest);
        gen.writeEndObject();
        
        req.setBody(gen.getAsString());
        Http http = new Http();
        try 
        {
            HTTPResponse res = http.send(req);
            returnJSON = res.getBody();
            if(res.getStatusCode()==200)
            {
                delete DocEngine;     
            }
            else
            {
                DocEngine.Integration_Status__c = 'Error';
                DocEngine.Integration_Operation__c = 'Delete';
                update DocEngine;
				MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Integration error with ICM', DocEngine.Id);
                               
            }
                
        } 
        catch(System.CalloutException e) 
        {
            DocEngine.Integration_Status__c = 'Error';
            DocEngine.Integration_Operation__c = 'Upload';
            update DocEngine;                
            MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString(), DocEngine.Id);
        }  
    }
    
    }
        
    //Added Method to be called from Upload Attachment Lightning controller for attachment integrations
    @AuraEnabled
    public static String SendAttachmentToICM(String attachId, String Operation){
    
    //function call to create integration XML
    if(Operation == 'Upload')
    {    
       // System.debug('Upload call');
        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(attachId, MCFD_Attachment_XML_Helper.UPLOAD ,'');    
        CallICMforAttachmentUpload(attachId, XMLrequest, Operation);
        return 'Success';
    }
    else if (Operation == 'Delete')
    {
        // LPERRY when writing test classes
        // there was a attachId hardcoded into both these functions ('00P4D000000H56R')
        // I have removed this and replaced it with the attachId that is sent
        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(attachId,MCFD_Attachment_XML_Helper.REMOVE,'');    
        CallICMforAttachmentUpload(attachId,XMLrequest, Operation);
        return 'Success';
    }
    else
    {
        return 'Success';        
    }
    
    }
    
    /* Retry code added*/
    public static void ReSendAttachmentToICM(String attachId, String Operation){
    
        // Added code for resubmission of document
        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(attachId,MCFD_Attachment_XML_Helper.RETRY,'');    
        ReCallICMforAttachmentUpload(attachId,XMLrequest, Operation);
        
    
    }
    
    
    public static void ReCallICMforAttachmentUpload (Id attachId, String XMLrequest, String Operation){
    
    String strStdAttchId = String.valueOf(attachId);
        
    MCFD_Document_Integration_Engine__c DocEngine = [select id from MCFD_Document_Integration_Engine__c
                                                     where Child_Standard_Attachment__c =: strStdAttchId limit 1];
        
        
    if(Operation == 'Upload')
    {
        
        System.debug('Calling submit for document upload===');
        String returnJSON = '';
        //String temp = 'Name';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMforAttachments');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('Name', XMLrequest);
        gen.writeEndObject();
        
        req.setBody(gen.getAsString());
       // System.debug(req.getBody()); 
       // System.debug(req);
        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            returnJSON = res.getBody();
          //  System.debug('Response'+res.toString());
          //  System.debug('STATUS:'+res.getStatus());
          //  System.debug('STATUS_CODE:'+res.getStatusCode());
          //  System.debug(returnJSON);
            if(res.getStatusCode()==200)
            {
                JSONParser parser = JSON.createParser(res.getBody());
                String ICMAttachId = '';
                while (parser.nextToken() != null) 
                {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'AttachmentId') 
                    {
                        // Get the value.
                        parser.nextToken();
                        // Compute the grand total price for all invoices.
                        ICMAttachId = parser.getText();
                    }
                }
                
                Dom.Document doc = new Dom.Document();
                doc.load(XMLrequest);
                
                //Retrieve the root element for this document.
                Dom.XMLNode payload = doc.getRootElement();
                String ICMFileNameRetry = payload.getChildElement('fileName',null).getText();
                            
                
             system.debug('ICMAttachId===' + ICMAttachId);
                DocEngine.ICM_Attachment_Id__c = ICMAttachId;
                DocEngine.Integration_Status__c = 'Synced';
                DocEngine.Integration_Operation__c = 'Upload';
                DocEngine.ICM_FileName__c = ICMFileNameRetry;
                update DocEngine;                
            }
            else
            {
            	DocEngine.Integration_Status__c = 'Error';
                DocEngine.Integration_Operation__c = 'Upload';
                update DocEngine;                
                MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Integration error with ICM', DocEngine.Id);
                
            }
        } 
        catch(System.CalloutException e) 
        {
        	DocEngine.Integration_Status__c = 'Error';
            DocEngine.Integration_Operation__c = 'Upload';
            update DocEngine;                
            MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString(), DocEngine.Id);
        }     
        //return returnJSON;
    }
        else if(Operation == 'Delete')
        {
           System.debug('Calling submit for document delete===');
            String returnJSON = '';
            //String temp = 'Name';
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMforAttachments');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('Name', XMLrequest);
            gen.writeEndObject();
            
            req.setBody(gen.getAsString());
           // System.debug(req.getBody()); 
           // System.debug(req);
            Http http = new Http();
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                
                if(res.getStatusCode()==200)
                {
                    delete DocEngine;     
                }
                else
                {
                	DocEngine.Integration_Status__c = 'Error';
                	DocEngine.Integration_Operation__c = 'Delete';
                	update DocEngine; 
                    MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Integration error with ICM', DocEngine.Id);
                }
                
            } 
            catch(System.CalloutException e) 
            {
            	DocEngine.Integration_Status__c = 'Error';
                DocEngine.Integration_Operation__c = 'Delete';
                update DocEngine;                
                MCFD_Logger.log_integ_err_for_document('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString(), DocEngine.Id);
            
            }  
        }
    
    }

    
    /*Retry code ends*/
    
    @AuraEnabled
    public static Attachment upsertFile(Attachment fileInfo){
        if(fileInfo != null){
        upsert fileInfo;
        }
        return fileInfo;
    }
    @AuraEnabled
    public static MCFD_Attachment__c upsertAttachment(MCFD_Attachment__c attachmentInfo){
       System.debug('attachmentInfo===' +attachmentInfo);
       if(attachmentinfo !=null){
        upsert attachmentInfo;}
        // System.debug(attachmentInfo);
        return attachmentInfo;
    }
    @AuraEnabled 
    public static List<Attachment> getFileList(String attachmentId){
     List<Attachment> fileList = [SELECT Id, Name, BodyLength FROM Attachment where ParentId =: attachmentId ORDER BY CreatedDate];
     return fileList;
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper uploadFile(String fileString, Attachment uploadedFile, MCFD_Attachment__c attachmentInfo, Double Filelength, Request__c request){
		return uploadFile(fileString, uploadedFile, attachmentInfo, Filelength,  request,  '');
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper uploadFile(String fileString, Attachment uploadedFile, MCFD_Attachment__c attachmentInfo, Double Filelength, Request__c request, string ICMFileName){
    	system.debug('###### Entering uploadFile:==='+ICMFileName);
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        Attachment returnFile = new Attachment();
        List<MCFD_Attachment__c> listRequestAttachments = new List<MCFD_Attachment__c>();
        List<Attachment> listRequestFiles = new List<Attachment>();
        try{
            // upsert the attachment information and the files
            attachmentInfo.MCFD_Status__c = 'Document Uploaded';
            attachmentInfo.MCFD_Request_Id__c = request.Id;
            attachmentInfo = upsertAttachment(attachmentInfo);
            
            // get the base 64 data decoded
            if(attachmentInfo.Id != null){
                if(uploadedFile.Id == null){
                    
                    // Add validation logic for US# 2290 - check if file name is same as any other existing files on the request
                    // Updating below code for user story 4443
                    listRequestAttachments = [select Id from MCFD_Attachment__c where MCFD_Request_Id__c = :request.Id];
                    listRequestFiles = [select Id, Name, BodyLength from Attachment where ParentId IN :listRequestAttachments
                                       and Name = :uploadedFile.Name];
                    if(listRequestFiles.size() > 0){
                    /*    mapListObj.put('ExistingFileList', listRequestFiles);
                        returnVal.mapObj = mapObj;
                        returnVal.mapListObj = mapListObj;
                        return returnVal;	*/
                        uploadedFile.Name = addTimeStamp(uploadedFile.Name);
                    }	
                    
					uploadedFile.Name = uploadedFile.Name;
                    uploadedFile.Body = EncodingUtil.base64Decode(fileString);
                    uploadedFile.ParentId = attachmentInfo.Id;
                    uploadedFile = upsertFile(uploadedFile);
                    
                    String tempString = EncodingUtil.base64Encode(uploadedFile.Body);
                    System.debug('tempString.length==='+tempString.length());
                   System.debug('filelength==='+Filelength);
                    if(tempString.length() == Filelength)
                    {
               //         System.debug('Upload call');
               			system.debug('###### before upload call:==='+ICMFileName);
               			
                        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(uploadedFile.Id, 'Insert',ICMFileName);
                        System.debug('####Upload call XMLrequest:==='+XMLrequest);    
                        CallICMforAttachmentUpload(uploadedFile.Id, XMLrequest, 'Upload');
                    }    
                    /*else
                    {
                 //       System.debug('lenght mismatch');
                  //      System.debug(tempString.length());
                  //      System.debug(Filelength);
                    }
                    */
                    returnFile.Id = uploadedFile.Id;
                    returnFile.Name = uploadedFile.Name;
                }
                else{
                    uploadedFile = [select Id, Name, Body from Attachment where Id = : uploadedFile.Id];
                    String existingBody = EncodingUtil.base64Encode(uploadedFile.Body);
                    uploadedFile.Body = EncodingUtil.base64Decode(existingBody + fileString); 
                    uploadedFile = upsertFile(uploadedFile);
                   
                    String tempString = EncodingUtil.base64Encode(uploadedFile.Body);
                    
                //     System.debug('>>>tempString '+ tempString.length());
                //    System.debug('>>>Filelength '+ Filelength);
                    if(tempString.length() == Filelength)
                    {
                       // System.debug('Upload call');
                        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(uploadedFile.Id, 'Insert',ICMFileName);
                        System.debug('####Upload call XMLrequest:==='+XMLrequest); 
                        CallICMforAttachmentUpload(uploadedFile.Id, XMLrequest, 'Upload');
                    }    
                  /*  else
                    {
                        System.debug('lenght mismatch');
                        System.debug(tempString.length());
                        System.debug(Filelength);
                    }
                    */
                    
                    returnFile.Id = uploadedFile.Id;
                    returnFile.Name = uploadedFile.Name;
                }
            }
            
            mapObj.put('Attachment', returnFile);
            mapObj.put('MCFD_Attachment__c', attachmentInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            //System.debug(returnVal);
            
            
            
            
            
            return returnVal;
        }
        catch(Exception e){
                   	MCFD_Logger.log_integration_error('Document Submission to ICM', MCFD_Logger.ERROR, 'MCFD_ContentController' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
           
          return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
	@AuraEnabled
    public static String addTimeStamp(String stdAttchName){
        String extn;
        System.debug('stdAttchName--->==='+stdAttchName);
        if(stdAttchName != Null){
            extn = stdAttchName.mid(stdAttchName.lastIndexOf('.'), stdAttchName.length());  
            stdAttchName = stdAttchName.subString(0, stdAttchName.lastIndexOf('.'));
            stdAttchName = stdAttchName + '_' + system.now().format('hhmmssSSS'); 
            stdAttchName = stdAttchName + extn;
            System.debug('stdAttchName--->==='+stdAttchName);
        }
        
        return stdAttchName;
    }
	
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, Map<String,String> aMap) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        
        MCFD_Attachment__c attach = new MCFD_Attachment__c();
     //   attach.MCFD_Contact_Id__c = aMap.get('MCFD_Contact_Id__c');
     //   attach.MCFD_Income_Id__c = aMap.get('MCFD_Income_Id__c');
     
          attach.MCFD_Last_Modified_Date__c = System.Now();
          attach.MCFD_Contact_Id__c = parentId; 
          attach.MCFD_Type__c = aMap.get('Type'); // Added by Abhishek
        //  System.Debug('>>>> attach.MCFD_Type__c: ' + attach.MCFD_Type__c);
          attach.MCFD_Attachment_Name__c= fileName; // Added by Abhishek
          INSERT attach;
        //  System.debug('attachment master:'+attach.Id);
        
        Attachment a = new Attachment();
        a.parentId = attach.Id;

        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
       // System.debug('attachment: '+a.Id);        
        return a.Id;
    }
    
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, Map<String,String> aMap, String Type) { 
       // System.debug('in function');
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, aMap);
         //   system.debug('within if');
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
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
    
    // Added by Abhishek -> Query Attachment record based on Type of Attachment and ContactId
    @AuraEnabled 
    public static List<MCFD_Attachment__c> getAttachment(Id parentId, String Type){
     List<MCFD_Attachment__c> attachList = [SELECT Id, MCFD_Attachment_Name__c, Name, MCFD_Type__c, MCFD_Contact_Id__c FROM MCFD_Attachment__c where MCFD_Type__c =: Type AND MCFD_Contact_Id__c =:parentId ORDER BY MCFD_Last_Modified_Date__c DESC NULLS LAST];
     return attachList;
    }
    
    // Added by Abhishek -> To delete the attachment record
    @AuraEnabled
    public static String deleteAttach(String fileName, String parentId){
    
        Attachment attach = new Attachment();

        attach = [select id from Attachment where Name =: fileName AND ParentId = :parentId];
        if(attach.id != Null){
        Id attachId = attach.Id;
            
            
        System.debug('Delete call===');
        String XMLrequest = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(attachId, 'Delete',''); 
        delete attach;    
        CallICMforAttachmentUpload(attachId, XMLrequest, 'Delete');
        }
        
        
        return attach.Id;
        
    }
    
    
}