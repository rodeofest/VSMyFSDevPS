/*********************************************************************************************************
Name            : MCFD_ReasonForCareController.cls  
Description     : This class is used to insert and update the Reason for Care information for spouse and Primary Applicant
Created By      : Deloitte
Created Date    : 21/Mar/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      21/Mar/2017   
--------------------------------------------------------------------------------------------------------------                      

***************************************************************************************************************/

public class MCFD_ReasonForCareController {


    
    // Create and Update Reason for Care Information
    @AuraEnabled
    public static void upsertRsnFCare(Id contid, Reason_For_Care__c rsnFcareRec ){
        System.debug('Inside');
        
        System.debug(rsnFcareRec ); 
        
           // if(rsnFcareRec != Null)   {
            rsnFcareRec.contact__C = contid;
               
            upsert rsnFcareRec;
           // }
            
     }
    
    // Query and show data for Reason for Care
   @AuraEnabled
     public static list<Reason_For_Care__c>  RsnFCare(ID contId, String ReasonFcareType){
     System.debug('check');
     System.debug(contid);
     System.debug(ReasonFcareType);
         list<Reason_For_Care__c> rsnFCareList = new list<Reason_For_Care__c>();
         rsnFCareList = [select Id, MCFD_Additional_Info__c, Contact__c,MCFD_When_do_you_work__c, MCFD_End_Date__c, MCFD_Travel_hours__c, MCFD_Name__c, MCFD_Number_of_hours_per_day_week__c, MCFD_Number_of_hours_per_day_weekend__c, MCFD_Number_of_days_week__c, MCFD_Number_of_days_weekend__c, MCFD_Rsn_For_Care_Type__c, MCFD_Request__c, MCFD_Schedule_Info__c, MCFD_Start_Date__c, You_Participating_in_the_SPEI_del__c from Reason_For_Care__c where contact__c =:contId AND MCFD_Rsn_For_Care_Type__c =: ReasonFcareType];
 
         return rsnFcareList ;
    }
    
    //added below method for remedy 675909 / vsts 7123 
    @AuraEnabled
    public static void deleteRsnFCare(Reason_For_Care__c rsnFcareRec){
        try
        {
            delete rsnFcareRec;
        }
        catch(Exception e)
        {
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_ReasonForCareController' ,'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString()+'\n'+'Reference RFC Id for deletion: '+rsnFcareRec.Id);
        }   
        
    }

    
}