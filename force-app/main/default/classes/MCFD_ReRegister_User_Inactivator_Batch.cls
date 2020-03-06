/**************************************************************************************
Version         : 1.0 
Function        : US 2012: CFD Community user who are found as re-registered, should be marked inactive. 

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                24 AUG 2017         Original Version
* PDAVE 					24 OCT 2017		    Bug Fix 5599 : Do not deactivate Admin user's 
*************************************************************************************/

global without sharing class MCFD_ReRegister_User_Inactivator_Batch implements Database.Batchable<sObject>{
     String query = 'SELECT Id, IsActive, MCFD_Ready_to_be_Inactivated__c '+
                    'FROM User '+
                    'WHERE IsActive = true '+
                    'AND MCFD_Deactivation_Reason__c = \'Re-Registration\' '+
                    'AND MCFD_Old_FederationIdentifier__c <> Null ' +
                    'AND FederationIdentifier = Null ' +
                    'AND MCFD_Ready_to_be_Inactivated__c = true ' +
                    'AND ContactId <> Null';
                    
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject obj: scope){
            obj.put('IsActive', false);
            obj.put('MCFD_Ready_to_be_Inactivated__c', false);
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('----- MCFD_ReRegister_User_Inactivator_Batch ------ Batch Completed ----');
    }
   
  
}