/*********************************************************************************************************
Name            : MCFD_Message_Trigger_Handler_Test.cls  
Description     : This class is to test MCFD_Message_Trigger_Handler.cls functions.
Created By      : ARDC ICM
Created Date    : 22/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      22/May/2018	Original Version
***************************************************************************************************************/
@isTest (SeeAllData=false)
public class MCFD_Message_Trigger_Handler_Test {
    
    @testSetup
    static void setup() {
        List<MCFD_Message__c> objMessage = TestDataFactory.createMessages(5);
        insert objMessage;
    }
    
    static testMethod void validate_ResubmitMessage() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        	List<MCFD_Message__c> objMessage = [SELECT id, Name, Message_Integration_Status__c FROM MCFD_Message__c LIMIT 2];
			objMessage[0].Message_Integration_Status__c = 'Pending Submission';        	
        	update objMessage;
        	MCFD_Message_Trigger_Handler.validate_ResubmitMessage(objMessage);
        Test.stopTest();
    }
}