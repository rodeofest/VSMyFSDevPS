/*
***************************************************************************************
Version         : 1.0 
Created Date    : 23 May 2017
Function        : Scheduler class to schedule the MCFD_BatchCallForICMMessages
: Schedule this class by executing below code  -> 

String CRON_EXP = '0 0 21 ? * MON-SUN';
LACE_File_Purging_Scheduler sch = new LACE_File_Purging_Scheduler();
system.schedule('e-Licensing -> Custom Attachments\' Files Pruging Daily Job', CRON_EXP, sch);



string sch22='0 0 * * * ?';     
MCFD_ScheduledCallForICMMessages sch = new MCFD_ScheduledCallForICMMessages();
system.schedule('Scheduled Job to fetch messages from WM', sch22, sch);

string sch22='0 15 * * * ?';
MCFD_ScheduledCallForICMMessages sch = new MCFD_ScheduledCallForICMMessages();
system.schedule('Scheduled Job to fetch messages from WM', sch22, sch);

string sch22='0 30 * * * ?';
MCFD_ScheduledCallForICMMessages sch = new MCFD_ScheduledCallForICMMessages();
system.schedule('Scheduled Job to fetch messages from WM', sch22, sch);

string sch22='0 45 * * * ?';
MCFD_ScheduledCallForICMMessages sch = new MCFD_ScheduledCallForICMMessages();
system.schedule('Scheduled Job to fetch messages from WM', sch22, sch);

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Areeb Shaikh                23 May 2017         Original Version
************************************************************************************
*/

public without sharing class MCFD_ScheduledCallForICMMessages implements Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext sch) {
        
        MCFD_BatchCallForICMMessages batchICMMessage = new MCFD_BatchCallForICMMessages(); 

        // issue -718211 for implementing solution custimizable Batch size
       
        Integer  batchSize  =  Integer.valueOf(System.Label.ICM_Message_BatchSize);
        system.debug('batchSize from label-ICM_Message_BatchSize: '+batchSize);
    
        //Added on 5/31/2017 - Vai - to invoke messages from wM
        if(batchSize < 0 || batchSize > 2000)
                batchSize = 20;
            
         system.debug('batch_size: '+batchSize);
         database.executebatch(BatchICMMessage,batchSize);     
        
    }
}