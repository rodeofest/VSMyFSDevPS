/**************************************************************************************
Created Date   : 24 APR 2018
Function  : This handler class validates the criteria on Document Integration Engine record 
*           and futher pass the records to Helper class.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                24 APR 2018         	Original Version
*************************************************************************************/

public without sharing class MCFD_Document_Trigger_Handler {

    public static boolean has_update_run = false;
    
    
    /*
    * Description : On updation of Document Integration record, this method will check the criteria for Resubmission of document
    * Parameter   : List<MCFD_Document_Integration_Engine__c>
    * Return Type : void
    */ 
    public static void validate_ResubmitDocument (List<MCFD_Document_Integration_Engine__c> docList){
        // Further methods cannot call future method hense the trigger execution should not start from Batch job or Future mehtod 
        if(has_update_run != true && System.isBatch() != true && System.isFuture() != true){
            has_update_run = true;  
            
            if(!docList.isEmpty()){
                MCFD_Document_Integration_Engine__c oldDocRecord; 
                MCFD_Document_Integration_Engine__c newDocRecord; 
                List<Id> validDocIdForResubmission = new List<Id>(); 
                
                for(MCFD_Document_Integration_Engine__c item : docList){
                    newDocRecord = item;
                    oldDocRecord = (MCFD_Document_Integration_Engine__c) Trigger.oldMap.get(item.Id);
         
                    if(newDocRecord.Integration_Status__c == 'Pending Submission'
                        && oldDocRecord.Integration_Status__c == 'Error'){
                            System.debug(newDocRecord.Integration_Status__c);
                        validDocIdForResubmission.add(item.Id);
                    }

                }
                
                if(!validDocIdForResubmission.isEmpty()){
                    MCFD_Document_Trigger_Helper.reSubmitDocument(validDocIdForResubmission);
                }
                    
            }
        
        }
    }
}