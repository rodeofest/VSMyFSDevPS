/*
***************************************************************************************
Version         : 1.0 
Function        : Scheduler class to schedule the MCFD_ReRegister_User_Inactivator_Batch
: Schedule this class by executing below code  -> 

String CRON_EXP = '0 0 21 ? * MON-SUN';
MCFD_ReRegister_User_Inactivator_Schedule sch = new MCFD_ReRegister_User_Inactivator_Schedule();
system.schedule('CFD -> Inactivate Re-Register Portal User Job', CRON_EXP, sch);


Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                24 Aug 2017         Original Version
************************************************************************************
*/

public without sharing class MCFD_ReRegister_User_Inactivate_Schedule implements Schedulable{
    
    public void execute(SchedulableContext sch) {
        MCFD_ReRegister_User_Inactivator_Batch inactiveUserBatch = new MCFD_ReRegister_User_Inactivator_Batch(); 
        
        database.executebatch(inactiveUserBatch, Integer.valueOf(System.Label.Inactivate_Re_Registered_Community_User_Batch_Size)); 
    }
    
    
}