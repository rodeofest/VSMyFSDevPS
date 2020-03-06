/**************************************************************************************
Created Date    : 4 MAY 2018
Function        : Helper methods for Message object

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                4 MAY 2018        	Original Version
*************************************************************************************/

public without sharing class MCFD_Message_Trigger_Helper {

    /*
    * Description : This method re-trigger the submission of Messages 
    * Parameter   : List<MCFD_Message__c>
    * Return Type : void
    */ 
    
    public static void reSubmitMessage(List<Id> messageIdList){
                           
        List<MCFD_Message__c> resubmissionMessage = new List<MCFD_Message__c>([SELECT id, Message_Status__c FROM MCFD_Message__c WHERE Id IN : messageIdList]);
        if(!resubmissionMessage.isEmpty()){
            List<MCFD_Message__c> firstMaxAllowedMessage = new List<MCFD_Message__c>();
            MCFD_Message__c reSubMessage;
            
            for(Integer i = 0; i<resubmissionMessage.size(); i++){
                if(i < Integer.valueOf(System.Label.MCFD_Re_Submission_Max_Allowed_Request)){
                    reSubMessage = resubmissionMessage[i];
                    
                    
                     MCFD_SendMessagesToICM.SendMessage(reSubMessage.Id);
                                      
                }
                else{
                    reSubMessage.addError(System.Label.MCFD_Re_Submission_Error_Max_Req + '' + System.Label.MCFD_Re_Submission_Max_Allowed_Request);
                }
            }
        }                      
    }
    
    
}