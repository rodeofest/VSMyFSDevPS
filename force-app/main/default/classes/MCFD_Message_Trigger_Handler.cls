/**************************************************************************************
Created Date   : 4 MAY 2018
Function  : This handler class validates the criteria on Messages Engine record 
*           and futher pass the records to Helper class.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                4 May 2018         	Original Version
*************************************************************************************/

public without sharing class MCFD_Message_Trigger_Handler {
    
    
    public static boolean has_update_run = false;
    
    
    /*
    * Description : On updation of Messages record, this method will check the criteria for Resubmission of messages
    * Parameter   : List<MCFD_Message__c>
    * Return Type : void
    */ 
    public static void validate_ResubmitMessage (List<MCFD_Message__c> messageList){
        // Further methods cannot call future method hense the trigger execution should not start from Batch job or Future mehtod 
        if(has_update_run != true && System.isBatch() != true && System.isFuture() != true){
            has_update_run = true;  
            
            if(!messageList.isEmpty()){
                MCFD_Message__c oldMessageRecord; 
                MCFD_Message__c newMessageRecord; 
                List<Id> validMessageIdForResubmission = new List<Id>(); 
                
                for(MCFD_Message__c item : messageList){
                    newMessageRecord = item;
                    oldMessageRecord = (MCFD_Message__c) Trigger.oldMap.get(item.Id);
         
                    if(newMessageRecord.Message_Integration_Status__c == 'Pending submission'
                        && oldMessageRecord.Message_Integration_Status__c == 'Submission error'){
                        validMessageIdForResubmission.add(item.Id);
                    }

                }
                
                if(!validMessageIdForResubmission.isEmpty()){
                    MCFD_Message_Trigger_Helper.reSubmitMessage(validMessageIdForResubmission);
                }
                    
            }
        
        }
    }

}