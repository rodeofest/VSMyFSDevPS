/*********************************************************************************************************
Name            : MCFD_Message_Trigger_Helper_Test.cls  
Description     : This class is to test MCFD_Message_Trigger_Helper.cls functions.
Created By      : Deloitte ARDC
Created Date    : 10/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      11/May/2018	Standards applied
***************************************************************************************************************/  
@isTest(seeAllData=false)
public class MCFD_Message_Trigger_Helper_Test {
	@testSetup
    static void setup(){
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;   
        System.assertEquals(objUser.isActive, true);
           
        }    
    
    static testMethod void reSubmitMessage(){
         List<id> Listid = new List<id>();
        for(MCFD_Message__c message:[SELECT Id , Name, Message_Status__c, ICM_Case_Id__c FROM MCFD_Message__c LIMIT 5]){
            Listid.add(message.Id); 
        }
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        MCFD_Message_Trigger_Helper.reSubmitMessage(Listid);
        Test.stopTest();
    }
    
    static testMethod void reSubmitMessageError(){
         List<id> Listid = new List<id>();
        for(MCFD_Message__c message:[SELECT Id , Name, Message_Status__c, ICM_Case_Id__c FROM MCFD_Message__c ]){
            Listid.add(message.Id); 
        }
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        MCFD_Message_Trigger_Helper.reSubmitMessage(Listid);
        Test.stopTest();
    }
}