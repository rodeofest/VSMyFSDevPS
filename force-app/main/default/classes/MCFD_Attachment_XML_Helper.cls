/**************************************************************************************
Apex Class Name : MCFD_Attachment_XML_Helper
Version         : 1.0 
Function        : Prepare XML for Attachment object for upload/delete operations.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                20 APR 2017             Original Version
* Areeb Shaikh               24 APR 2017             Modified code for integration
*************************************************************************************/

public without sharing class MCFD_Attachment_XML_Helper{
    
    public static String UPLOAD = 'Insert';
    public static String REMOVE = 'Delete';
    public static String RETRY = 'Retry';
    
    /*
    * Method name : prepare_Attachment_XML
    * Description : query various object and prepares the XML for ICM integration 
    * Parameter   :  Id, strOperationType (Required, use either MCFD_Attachment_XML_Helper.INSERT, MCFD_Attachment_XML_Helper.DELETE)
    * Return Type : void
    */ 
    public static String prepare_Attachment_XML(Id stdAttchId, String strOperationType){
    	return prepare_Attachment_XML(stdAttchId, strOperationType, '');
    }
    public static String prepare_Attachment_XML(Id stdAttchId, String strOperationType, string ICMFileName){
        
        Attachment stdAttchmnt = [SELECT id, Name, Body, ParentId FROM Attachment WHERE id =: stdAttchId];
        MCFD_Attachment__c custmAttch = [SELECT id, Name,MCFD_Request_Id__c, MCFD_Request_Id__r.ICM_SR_Number__c FROM MCFD_Attachment__c WHERE id =: stdAttchmnt.parentId];        
        String masterXmlRet;
        if(strOperationType == MCFD_Attachment_XML_Helper.UPLOAD)
        {
            String strFileName;     // required for Upload/delete
            String strStdAttchId;   // required for Upload/Delete
            String strRequestId;    // required for Upload/delete
            String strBase64String; // required for Upload
            String sr_num;          // required for Upload  
            String strICMAttchId;   // required for Delete
            
            strStdAttchId = String.valueOf(stdAttchId);
           
            //Adding below code to fix duplicate attachment names issue when there is a deletion involved.
            
            if (ICMFileName!='' && ICMFileName!=null)
            {
                List<Attachment> stdAttchmntList = [SELECT id FROM Attachment 
                                                    WHERE parentId =: stdAttchmnt.parentId 
                                                    and Id <>: stdAttchId
                                                    order by createdDate desc];
                
                
                if(!stdAttchmntList.isEmpty())
                {
                    String strStdAttchIdTemp = String.valueOf(stdAttchmntList[0].Id);
                    
                    Integer AttachCount =  stdAttchmntList.size();
                    
                    MCFD_Document_Integration_Engine__c docEngineTemp = [select ICM_FileName__c from MCFD_Document_Integration_Engine__c 
                                                                         where Child_Standard_Attachment__c =: strStdAttchIdTemp limit 1];
                    //  ID1.jpg add code when docEnginetemp is empty
                    String ICMFileNameTemp = docEngineTemp.ICM_FileName__c;
                    Integer oldincrLastFile = integer.valueOf(ICMFileNameTemp.substring(ICMFileNameTemp.lastIndexOf('.') - 1, ICMFileNameTemp.lastIndexOf('.')));
                    
                    if (AttachCount > oldincrLastFile)
                    {
                        oldincrLastFile = AttachCount;
                    }
                    Integer newincrLastFile = oldincrLastFile + 1;
                    String oldStringLastFile = oldincrLastFile + '.';
                    String newStringLastFile = newincrLastFile + '.';
                    
                    Integer oldincrNewFile = integer.valueOf(ICMFileName.substring(ICMFileName.lastIndexOf('.') - 1, ICMFileName.lastIndexOf('.')));
                    String oldStringNewFile = oldincrNewFile + '.';
                    
                    if(oldincrNewFile <= oldincrLastFile)
                    {
                        ICMFileName = ICMFileName.replace(oldStringNewFile, newStringLastFile);
                    }
                    else
                    {
                        ICMFileName = ICMFileName; 
                    }
                }
                else
                {
                    ICMFileName = ICMFileName;
                }
            }
            
            
            if (ICMFileName!='' && ICMFileName!=null)
            	strFileName = ICMFileName;
            else
            	strFileName = stdAttchmnt.Name;	
            strRequestId = String.valueOf(custmAttch.MCFD_Request_Id__c);
                //Label.Dummy_Application;
                //'a014D000000qTa6';
              //custmAttch.MCFD_Request_Id__c;
            //'1-9386072770';
            strBase64String = EncodingUtil.base64Encode(stdAttchmnt.body);
            SR_num = custmAttch.MCFD_Request_Id__r.ICM_SR_Number__c;
                //Label.Dummy_SR;
                //'1-9398359585';
                //custmAttch.MCFD_Request_Id__r.ICM_SR_Number__c;
            
            MCFD_Document_Integration_Engine__c docEngine = new MCFD_Document_Integration_Engine__c();
            docEngine.Parent_Custom_Attachment__c = custmAttch.Id;
            docEngine.Child_Standard_Attachment__c = strStdAttchId;
            docEngine.Integration_Status__c = 'Pending Submission';
            docEngine.Parent_Request__c =   strRequestId;
            docEngine.ICM_FileName__c = ICMFileName;
                //custmAttch.MCFD_Request_Id__c;
            
            insert DocEngine;   
            
            //strICMAttchId                     // This field is ICM Raw Attachment Id, which is the response or Upload webserivce from ICM. 
            // This needs to be pulled from wherever this is being stored.
            
            String xmlRequest;
            system.debug('######strOperationType:'+strOperationType);
            system.debug('######strFileName:'+strFileName);
            system.debug('######sfdcAttachmentId:'+strStdAttchId);
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null, '1.0'); //Start the XML document
            w.writeStartElement(null, 'mcfdAttachment', null);
            
            w.writeStartElement(null,'operationType',null);w.writeCharacters(strOperationType);w.writeEndElement(); 
            w.writeStartElement(null,'fileName',null);w.writeCharacters(strFileName);w.writeEndElement();
            w.writeStartElement(null,'sfdcAttachmentId',null);w.writeCharacters(strStdAttchId);w.writeEndElement();     
            
            if(strRequestId != Null)
            {
                w.writeStartElement(null,'requestId',null);w.writeCharacters(strRequestId);w.writeEndElement();         
            }
         /*   else
            {
           //     w.writeStartElement(null,'requestId',null);w.writeAttribute(null, null, 'xsi:nil', 'true');w.writeEndElement();  
            }
           */ 
            if(strOperationType == MCFD_Attachment_XML_Helper.UPLOAD)
            {
                w.writeStartElement(null,'base64String',null);w.writeCharacters(strBase64String);w.writeEndElement();
            }
          /*  else
            {
            //    w.writeStartElement(null,'base64String',null);w.writeAttribute(null, null, 'xsi:nil', 'true');w.writeEndElement();   
            }
            */
            if(SR_num != Null)
            {
                w.writeStartElement(null,'icm-SR-Number',null);w.writeCharacters(SR_num);w.writeEndElement();   
            }
          /*  else
            {
           //     w.writeStartElement(null,'icm-SR-Number',null);w.writeAttribute(null, null, 'xsi:nil', 'true');w.writeEndElement();  
            }
            */
            if(strICMAttchId != Null){
                w.writeStartElement(null,'icmAttachmentId',null);w.writeCharacters(strICMAttchId);w.writeEndElement();          
            }
            /*else{
             //   w.writeStartElement(null,'icmAttachmentId',null);w.writeAttribute(null, null, 'xsi:nil', 'true');w.writeEndElement();           
            }
            */
            w.writeEndElement();    
            
            xmlRequest = w.getXmlString();
            masterXmlRet = xmlRequest;
            w.close();
            // Modified by Abhishek to fix CRD 
            // return xmlRequest;
        }
        
        else if(strOperationType == MCFD_Attachment_XML_Helper.REMOVE)
        {
            String strFileName;     // required for Upload/delete
            String strStdAttchId;   // required for Upload/Delete
            String strRequestId;    // required for Upload/delete
            String strICMAttchId;   // required for Delete
            String sr_num;
            
            // Commented by Abhishek to fix CRD
            /*
            Attachment stdAttchmnt = [SELECT id, Name, Body, ParentId FROM Attachment WHERE id =: stdAttchId];
            MCFD_Attachment__c custmAttch = [SELECT id, Name, MCFD_Request_Id__r.ICM_SR_Number__c FROM MCFD_Attachment__c WHERE id =: stdAttchmnt.parentId];        
            */
            if (ICMFileName!='')
            	strFileName = ICMFileName;
            else
            	strFileName = stdAttchmnt.Name;	
            strRequestId = String.valueOf(custmAttch.MCFD_Request_Id__c);
                
            strStdAttchId = String.valueOf(stdAttchId);
            SR_num = custmAttch.MCFD_Request_Id__r.ICM_SR_Number__c;
                
            MCFD_Document_Integration_Engine__c docEngine = [select id, ICM_Attachment_Id__c from MCFD_Document_Integration_Engine__c
                                                            where Child_Standard_Attachment__c =: strStdAttchId limit 1];
            
            strICMAttchId = DocEngine.ICM_Attachment_Id__c;
            //insert DocEngine;   
            
            //strICMAttchId                     // This field is ICM Raw Attachment Id, which is the response or Upload webserivce from ICM. 
            // This needs to be pulled from wherever this is being stored.
            
            String xmlRequest;
            
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null, '1.0'); //Start the XML document
            w.writeStartElement(null, 'mcfdAttachment', null);
            
            w.writeStartElement(null,'operationType',null);w.writeCharacters(strOperationType);w.writeEndElement(); 
            w.writeStartElement(null,'sfdcfileName',null);w.writeCharacters(strFileName);w.writeEndElement();
            w.writeStartElement(null,'sfdcAttachmentId',null);w.writeCharacters(strStdAttchId);w.writeEndElement();     
            
            if(strRequestId != Null){
                w.writeStartElement(null,'requestId',null);w.writeCharacters(strRequestId);w.writeEndElement();         
            }
            
                        
            if(SR_num != Null){
              w.writeStartElement(null,'icm-SR-Number',null);w.writeCharacters(SR_num);w.writeEndElement();   
            }
            
            
            if(strICMAttchId != Null){
                w.writeStartElement(null,'icmAttachmentId',null);w.writeCharacters(strICMAttchId);w.writeEndElement();          
            }
            
            w.writeEndElement();    
            
            xmlRequest = w.getXmlString();
           
            w.close();
            // Modified by Abhishek to fix CRD 
            masterXmlRet = xmlRequest;
            //return xmlRequest;
        }
        
        /*code starts for Retry */
        else if(strOperationType == MCFD_Attachment_XML_Helper.RETRY)
        {
            String strStdAttchId;   // required for Upload/Delete
            strStdAttchId = String.valueOf(stdAttchId);
            MCFD_Document_Integration_Engine__c docEngine = [select id, ICM_FileName__c,ICM_Attachment_Id__c, Integration_Operation__c from MCFD_Document_Integration_Engine__c
                                                             where Child_Standard_Attachment__c =: strStdAttchId limit 1];
            String ICMFileNameRetry = docEngine.ICM_FileName__c;
            if(docEngine.Integration_Operation__c == 'Upload')
            {
                String strFileName;     // required for Upload/delete
                String strRequestId;    // required for Upload/delete
                String strBase64String; // required for Upload
                String sr_num;          // required for Upload  
                String strICMAttchId;   // required for Delete
                
                //Adding below code to fix duplicate attachment names issue when there is a deletion involved.
                
                if (docEngine.ICM_FileName__c!='' && docEngine.ICM_FileName__c!=null)
                {
                    List<Attachment> stdAttchmntList = [SELECT id FROM Attachment 
                                                        WHERE parentId =: stdAttchmnt.parentId 
                                                        // and Id <>: stdAttchId
                                                        order by createdDate desc];
                    
                    if(!stdAttchmntList.isEmpty())
                    {
                        String strStdAttchIdTemp = String.valueOf(stdAttchmntList[0].Id);
                        
                        Integer AttachCount =  stdAttchmntList.size();
                        
                        MCFD_Document_Integration_Engine__c docEngineTemp = [select ICM_FileName__c from MCFD_Document_Integration_Engine__c 
                                                                             where Child_Standard_Attachment__c =: strStdAttchIdTemp limit 1];
                        //  ID1.jpg add code when docEnginetemp is empty and update new file name onto doc engine on retry
                        String ICMFileNameTemp = docEngineTemp.ICM_FileName__c;
                        System.debug('ICMFileNameTemp  '+ICMFileNameTemp);
                        Integer oldincrLastFile = integer.valueOf(ICMFileNameTemp.substring(ICMFileNameTemp.lastIndexOf('.') - 1, ICMFileNameTemp.lastIndexOf('.')));
                        
                        if (AttachCount > oldincrLastFile)
                        {
                            oldincrLastFile = AttachCount;
                        }
                        
                        Integer newincrLastFile = oldincrLastFile + 1;
                        String oldStringLastFile = oldincrLastFile + '.';
                        String newStringLastFile = newincrLastFile + '.';
                        
                        Integer oldincrNewFile = integer.valueOf(ICMFileNameRetry.substring(ICMFileNameRetry.lastIndexOf('.') - 1, ICMFileNameRetry.lastIndexOf('.')));
                        String oldStringNewFile = oldincrNewFile + '.';
                        
                        if(oldincrNewFile <= oldincrLastFile)
                        {
                            ICMFileNameRetry = ICMFileNameRetry.replace(oldStringNewFile, newStringLastFile);
                        }
                        else
                        {
                            ICMFileNameRetry = ICMFileNameRetry; 
                        }
                        
                    }
                    else
                    {
                        ICMFileNameRetry = docEngine.ICM_FileName__c;
                    }
                }
                
                
                if (docEngine.ICM_FileName__c!=''&& docEngine.ICM_FileName__c!=null)
                {
                    //docEngine.ICM_FileName__c = ICMFileNameRetry;
                    //update docEngine;
            		strFileName = ICMFileNameRetry; //docEngine.ICM_FileName__c;
                }
                else	
                {	
                    strFileName = stdAttchmnt.Name;	
                }
                strRequestId = String.valueOf(custmAttch.MCFD_Request_Id__c);
                strBase64String = EncodingUtil.base64Encode(stdAttchmnt.body);
            	SR_num = custmAttch.MCFD_Request_Id__r.ICM_SR_Number__c;
                
                String xmlRequest;
            
                XmlStreamWriter w = new XmlStreamWriter();
                w.writeStartDocument(null, '1.0'); //Start the XML document
                w.writeStartElement(null, 'mcfdAttachment', null);
                
                w.writeStartElement(null,'operationType',null);w.writeCharacters('Insert');w.writeEndElement(); 
                w.writeStartElement(null,'fileName',null);w.writeCharacters(strFileName);w.writeEndElement();
                w.writeStartElement(null,'sfdcAttachmentId',null);w.writeCharacters(strStdAttchId);w.writeEndElement();     
                
                if(strRequestId != Null)
                {
                    w.writeStartElement(null,'requestId',null);w.writeCharacters(strRequestId);w.writeEndElement();         
                }
                w.writeStartElement(null,'base64String',null);w.writeCharacters(strBase64String);w.writeEndElement();
                if(SR_num != Null)
                {
                    w.writeStartElement(null,'icm-SR-Number',null);w.writeCharacters(SR_num);w.writeEndElement();   
                }
                if(strICMAttchId != Null){
                    w.writeStartElement(null,'icmAttachmentId',null);w.writeCharacters(strICMAttchId);w.writeEndElement();          
                }
                w.writeEndElement();    
                
                xmlRequest = w.getXmlString();
                masterXmlRet = xmlRequest;
                w.close();
             }
        
            else if(docEngine.Integration_Operation__c == 'Delete')
            {
                
                String strFileName;     // required for Upload/delete
                String strRequestId;    // required for Upload/delete
                String strICMAttchId;   // required for Delete
                String sr_num;
                
                if (ICMFileNameRetry!='')
            		strFileName = ICMFileNameRetry;
            	else	
            		strFileName = stdAttchmnt.Name;	
                strRequestId = String.valueOf(custmAttch.MCFD_Request_Id__c);
                SR_num = custmAttch.MCFD_Request_Id__r.ICM_SR_Number__c;
                strICMAttchId = DocEngine.ICM_Attachment_Id__c;

                String xmlRequest;
                
                XmlStreamWriter w = new XmlStreamWriter();
                w.writeStartDocument(null, '1.0'); //Start the XML document
                w.writeStartElement(null, 'mcfdAttachment', null);
                
                w.writeStartElement(null,'operationType',null);w.writeCharacters('Delete');w.writeEndElement(); 
                w.writeStartElement(null,'sfdcfileName',null);w.writeCharacters(strFileName);w.writeEndElement();
                w.writeStartElement(null,'sfdcAttachmentId',null);w.writeCharacters(strStdAttchId);w.writeEndElement();     
                
                if(strRequestId != Null){
                    w.writeStartElement(null,'requestId',null);w.writeCharacters(strRequestId);w.writeEndElement();         
                }
                
                
                if(SR_num != Null){
                  w.writeStartElement(null,'icm-SR-Number',null);w.writeCharacters(SR_num);w.writeEndElement();   
                }
                if(strICMAttchId != Null){
                    w.writeStartElement(null,'icmAttachmentId',null);w.writeCharacters(strICMAttchId);w.writeEndElement();          
                }
                
                w.writeEndElement();    
                
                xmlRequest = w.getXmlString();
               
                w.close();
                masterXmlRet = xmlRequest;
            }
            
        }
        /*code ends for Retry.*/
        
        
        else
        {
            // Modified by Abhishek to fix CRD 
            masterXmlRet = 'invalid operation';
            // return 'invalid operation';
        }
        return masterXmlRet;
    }
}