/*********************************************************************************************************
Name            : MCFD_ScheduledCallForICMMessages_Test.cls
Description     : This class is to test MCFD_ScheduledCallForICMMessages.cls functions.
Created By      : Mangala MG
Created Date    : 01/12/2017
Modification Log:
--------------------------------------------------------------------------------------------------------------
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                 
Mangala MG    01/12/2017    Original Version
Gabriela	  14/06/2018	Standards applied
Rosario 	  04/07/2018	Methods updated
***************************************************************************************/ 

@isTest(SeeAllData=false)
public class MCFD_ScheduledCallForICMMessages_Test {
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser; 
        
    }

    static testMethod void unitTest() {
    User objUser = [SELECT id FROM User WHERE Email='standarduser@testorg.com'  LIMIT 1];
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCFD_BatchCallForICMMessagesMock());
        MCFD_ScheduledCallForICMMessages sh1 = new MCFD_ScheduledCallForICMMessages();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test', sch, sh1); 
    Test.stopTest();
    }
}