/**************************************************************************************
Created Date   : 24 APR 2018
Function  : Triggers on various events on Document Integration engine record and calls handler class to validate the criteria.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                24 APR 2018            Original Version
*************************************************************************************/
trigger MCFD_Message_Trigger on MCFD_Message__c (after update) {
    
     if(System.Label.MCFD_Master_Trigger_Disable_Mode.toUpperCase() != 'ON'){    
       
        if(Trigger.isAfter){
                
                if(Trigger.isUpdate){
                    MCFD_Message_Trigger_Handler.validate_ResubmitMessage(Trigger.New);
                }           
        }    
     }
}