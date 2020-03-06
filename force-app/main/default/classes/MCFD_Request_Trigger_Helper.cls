/**************************************************************************************
Created Date    : 28 SEP 2017
Function        : Helper methods for Request object

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                28 SEP 2017        Original Version
*************************************************************************************/

public without sharing class MCFD_Request_Trigger_Helper{
    /*
    * Description : This method re-trigger the submission of request 
    * Parameter   : List<Request__c>
    * Return Type : void
    */ 
    
    @future(callout=true)
    public static void reSubmitRequest(List<Id> reqIdList){
                           
        List<Request__c> resubmissionReq = new List<Request__c>([SELECT id, RecordType.Name FROM Request__c WHERE Id IN : reqIdList]);
        if(!resubmissionReq.isEmpty()){
            List<Request__c> firstMaxAllowedReq = new List<Request__c>();
            Request__c reSubReq;
            //String reSubReq_recrdTypeName;
            for(Integer i = 0; i<resubmissionReq.size(); i++){
                if(i < Integer.valueOf(System.Label.MCFD_Re_Submission_Max_Allowed_Request)){
                    reSubReq = resubmissionReq[i];
                    //reSubReq_recrdTypeName = Schema.SObjectType.Request__c.getRecordTypeInfosById().get(reSubReq.recordtypeid).getname();
                    
                    System.debug('---------- Re-triggering the submission request --------- Request Id:'+reSubReq.Id);
                    System.debug('---------- reSubReq.RecordType.Name --------- :'+reSubReq.RecordType.Name);
                    
                    
                    /* ------------------------------------------------------ 
                    ------- Exception Handling is done individual method -----
                    ------------------------------------------------------*/
                    if(reSubReq.RecordType.Name == 'Application' || reSubReq.RecordType.Name == 'Renewal'){
                        MCFD_SubmitApplicationXMLGenerator.SubmitCSSApplication(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'RTP'){
                        MCFD_CallICMForAutismDetails.sendRequestToICM(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'RTP - Travel, Training, and Equipment'){
                        MCFD_CallICMForAutismDetails.sendRequestToICM(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'RTA'){
                        MCFD_RTAXMLGenerator.SubmitRTA(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'Reimbursement'){
                        MCFD_CallICMForAutismDetails.sendReimburesementToICM(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'Autism case request'){
                        MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(reSubReq.Id);
                    }else if(reSubReq.RecordType.Name == 'CCS case request'){
                        MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(reSubReq.Id);
                    }                  
                }else{
                    reSubReq.addError(System.Label.MCFD_Re_Submission_Error_Max_Req + '' + System.Label.MCFD_Re_Submission_Max_Allowed_Request);
                }
            }
        }                      
    }    
}