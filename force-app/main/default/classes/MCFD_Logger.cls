/**************************************************************************************
Function        : Logging helper class for custom logging
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                19 APR 2017             Original Version
***************************************************************************************/

public class MCFD_Logger {

    public static String info = 'INFO';
    public static String debug = 'DEBUG';
    public static String warning = 'WARNING';
    public static String error = 'ERROR';
    public static String fatal = 'FATAL';

    // insert a generic log entry 
    public static void log(String priority, String classTriggerName, String message) { 
        insert new MCFD_Log__c(priority__c=priority,
                               Class_Trigger_Name__c=classTriggerName, 
                               message__c=message);
    }
    
    // insert a generic log entry 
    public static void log_integration_error(String interfaceName, String priority, String classTriggerName, String message) { 
        insert new MCFD_Log__c(Interface_Name__c = interfaceName, 
                               priority__c = priority, 
                               Class_Trigger_Name__c = classTriggerName, 
                               message__c = message);
    }
    
    // insert a generic log entry for request object
    public static void log_integ_err_for_request(String interfaceName, String priority, String classTriggerName, String message, Id reqId) { 
        insert new MCFD_Log__c(Interface_Name__c = interfaceName, 
                                priority__c = priority, 
                                Class_Trigger_Name__c = classTriggerName, 
                                message__c = message,
                                Request__c = reqId);
    }
    
    // insert a log entry for message integration failure
    public static void log_integ_err_for_message(String interfaceName, String priority, String classTriggerName, String message, Id msgId) { 
        insert new MCFD_Log__c(Interface_Name__c = interfaceName, 
                                priority__c = priority, 
                                Class_Trigger_Name__c = classTriggerName, 
                                message__c = message,
                                Linked_MCFD_Message__c = msgId);
    }
    
    // insert a log entry for document integration failure
    public static void log_integ_err_for_document(String interfaceName, String priority, String classTriggerName, String message, Id docId) { 
        insert new MCFD_Log__c(Interface_Name__c = interfaceName, 
                                priority__c = priority, 
                                Class_Trigger_Name__c = classTriggerName, 
                                message__c = message,
                                Attachment_ICM_Integration__c = docId);
    }
    
    // insert a generic log entry in a future method
    @future
    public static void log_Exception(String priority, String classTriggerName, String message) { 
        MCFD_Log__c log = new MCFD_Log__c(priority__c=priority,
                                          Class_Trigger_Name__c=classTriggerName, 
                                          message__c=message);
        Database.insert(log, false);
        //insert new MCFD_Log__c(priority__c=priority,Class_Trigger_Name__c=classTriggerName, message__c=message);
    }

    // insert a generic log entry 
    public static void log_for_batch_retry(String priority, String classTriggerName, String message, String eligibleArea, Id requestId) { 
        insert new MCFD_Log__c(priority__c = priority,
                               Class_Trigger_Name__c = classTriggerName, 
                               message__c = message, 
                               Batch_Retry_Eligible_Area__c = eligibleArea, 
                               Batch_Retry_Request__c = requestId);
    }   
}