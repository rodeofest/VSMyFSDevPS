/**************************************************************************************
Function        : Test Class for covering the code for - MCFD_ReRegister_User_Inactivate_Schedule

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rosario Lopez				08/06/2018				Standard applied
*************************************************************************************/
@isTest(SeeAllData=false)
private class MCFD_ReRegister_User_Inactivate_Sch_Test {
	
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('BCAccount');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objcommUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objcommUser;       
    }
    
	public static testMethod void unitTest(){

    	User objcommUser = [SELECT id FROM User where email = 'standarduser@testorg.com' Limit 1];
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleTwoCalloutMock());
    	MCFD_ReRegister_User_Inactivate_Schedule objReRegisterUserInacSch = new MCFD_ReRegister_User_Inactivate_Schedule();
    	String sch = '0 0 2 * * ?'; 
    	System.schedule('Test', sch, objReRegisterUserInacSch); 
    	Test.stopTest();
    
  }
	
}