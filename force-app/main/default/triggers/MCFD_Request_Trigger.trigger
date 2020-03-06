/**************************************************************************************
Created Date   : 28 SEP 2017
Function  : Triggers on various evnets on Request record and calls handler class to validate the criteria.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                28 SEP 2017         Original Version
*************************************************************************************/

trigger MCFD_Request_Trigger on Request__c (after update) {
    
     if(System.Label.MCFD_Master_Trigger_Disable_Mode.toUpperCase() != 'ON'){    
        /*
        if(Trigger.isBefore){
            
        }
        */
        
        if(Trigger.isAfter){
                /*if(Trigger.isInsert){
                   
               }*/
                
                if(Trigger.isUpdate){
                    MCFD_Request_Trigger_Handler.validate_ResubmitRequest(Trigger.New);
                }           
        }    
     }
}