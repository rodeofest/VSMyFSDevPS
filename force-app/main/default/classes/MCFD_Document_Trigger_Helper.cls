/**************************************************************************************
Created Date    : 24 APR 2018
Function        : Helper methods for Document Engine object

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                24 APR 2018        	Original Version
*************************************************************************************/

public without sharing class MCFD_Document_Trigger_Helper{
    /*
    * Description : This method re-trigger the submission of Document Engine 
    * Parameter   : List<MCFD_Document_Integration_Engine__c>
    * Return Type : void
    */ 
    
    @future(callout=true)
    public static void reSubmitDocument(List<Id> docIdList){
                           
        List<MCFD_Document_Integration_Engine__c> resubmissionDoc = new List<MCFD_Document_Integration_Engine__c>([SELECT id, Integration_Operation__c, Parent_Custom_Attachment__r.Id, Child_Standard_Attachment__c FROM MCFD_Document_Integration_Engine__c WHERE Id IN : docIdList]);
        if(!resubmissionDoc.isEmpty()){
            List<MCFD_Document_Integration_Engine__c> firstMaxAllowedDoc = new List<MCFD_Document_Integration_Engine__c>();
            MCFD_Document_Integration_Engine__c reSubDoc;
            Attachment reAttach;
            MCFD_Attachment__c reCustAttach;
             //String reSubReq_recrdTypeName;
            for(Integer i = 0; i<resubmissionDoc.size(); i++){
                if(i < Integer.valueOf(System.Label.MCFD_Re_Submission_Max_Allowed_Request)){
                    reSubDoc = resubmissionDoc[i];
                    //reSubReq_recrdTypeName = Schema.SObjectType.Request__c.getRecordTypeInfosById().get(reSubReq.recordtypeid).getname();
                    
                    System.debug('---------- Re-triggering the document submission --------- Document Engine Id:'+reSubDoc.Id);
                    
                    /* ------------------------------------------------------ 
                    ------- Exception Handling is done individual method -----
                    ------------------------------------------------------*/
                    System.debug('checking child lookup'+ reSubDoc);
                    //System.debug(reSubDoc.Parent_Custom_Attachment__r.Id);
                    
                    //reCustAttach = [select Id  from MCFD_Attachment__c where Id =: reSubDoc.Parent_Custom_Attachment__r.Id limit 1];
                    //reAttach = [select id from Attachment where parentId =:  reCustAttach.Id limit 1];
                               // reCustAttach.get(0).Id limit 1]; 
                    //System.debug(reAttach.Id);
                    System.debug('Child_Standard_Attachment__c: '+reSubDoc.Child_Standard_Attachment__c);
                    MCFD_ContentController.ReSendAttachmentToICM(reSubDoc.Child_Standard_Attachment__c,reSubDoc.Integration_Operation__c);
                                      
                }
                else{
                    reSubDoc.addError(System.Label.MCFD_Re_Submission_Error_Max_Req + '' + System.Label.MCFD_Re_Submission_Max_Allowed_Request);
                }
            }
        }                      
    }    
}