/**************************************************************************************
Created Date   : 28 SEP 2017
Function  : This handler class validates the criteria on Request record 
*           and futher pass the records to Helper class.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                28 SEP 2017         Original Version
*************************************************************************************/

public without sharing class MCFD_Request_Trigger_Handler{
    //public static boolean has_insert_run = false;
    public static boolean has_update_run = false;
    
    
    /*
    * Description : On updation of Request__c record, this method will check the criteria for Resubmission of request
    * Parameter   : List<Request__c>
    * Return Type : void
    */ 
    public static void validate_ResubmitRequest (List<Request__c> reqList){
        // Further methods cannot call future method hense the trigger execution should not start from Batch job or Future mehtod 
        if(has_update_run != true && System.isBatch() != true && System.isFuture() != true){
            has_update_run = true;  
            
            if(!reqList.isEmpty()){
                Request__c oldReqRecord; 
                Request__c newReqRecord; 
                List<Id> validReqIdForResubmission = new List<Id>(); 
                
                for(Request__c item : reqList){
                    newReqRecord = item;
                    oldReqRecord = (Request__c) Trigger.oldMap.get(item.Id);
         
                     /* US 4589
                        
                        B. The status' "Submission Error", and "Submitted" cannot be manually set by the Admin user.

                        C. If the request record's status is currently "Submission Error", admin user can manually 
                           change the status of a request to "Pending Submission" if they want to re-attempt a submission.

                        D. Admin user can not manually change a request's status to "Pending Submission" unless the request's 
                           status is "Submission Error".

                        E. After changing the status of a request to "Pending Submission", the integration for that request is 
                           retried by the system.  Suggested method is to use a trigger to call the Apex class for the submission.

                        F. If the re-submission is successful, it's status changes to "Submitted".

                        G. If the re-submission fails, it's status changes back to "Submission Error".
                    */

                    if(newReqRecord.MCFD_Status__c == 'Pending Submission'
                        && oldReqRecord.MCFD_Status__c == 'Submission Error'){
                        validReqIdForResubmission.add(item.Id);
                    }

                }
                
                if(!validReqIdForResubmission.isEmpty()){
                    MCFD_Request_Trigger_Helper.reSubmitRequest(validReqIdForResubmission);
                }
                    
            }
        
        }
    }
}