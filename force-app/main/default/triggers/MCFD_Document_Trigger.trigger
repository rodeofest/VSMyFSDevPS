/**************************************************************************************

Sandeep123

Created Date   : 24 APR 2018
Function  : Triggers on various events on Document Integration engine record and calls handler class to validate the criteria.

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                24 APR 2018            Original Version
*************************************************************************************/

trigger MCFD_Document_Trigger on MCFD_Document_Integration_Engine__c (after update) {
    
     if(System.Label.MCFD_Master_Trigger_Disable_Mode.toUpperCase() != 'ON'){    
       
        
        if(Trigger.isAfter){
                
                if(Trigger.isUpdate){
                    MCFD_Document_Trigger_Handler.validate_ResubmitDocument(Trigger.New);
                }           
        }    
     }
}