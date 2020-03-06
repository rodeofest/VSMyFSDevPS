/*********************************************************************************************************
Name            : MCFD_GetSetContactDetails_Test.cls  
Description     : This class is to test MCFD_GetSetContactDetails.cls functions.
Created By      : Deloitte ARDC
Created Date    : 10/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      11/May/2018	Standards applied
***************************************************************************************************************/  
@isTest (seeAllData=false)
public class MCFD_GetSetContactDetails_Test {
    @testSetup static void setup(){
		Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        System.assertEquals(objUser.isActive, true);
        
    }
     
    static testmethod void testGetContactDetails(){
        User objUser = [SELECT id FROM User WHERE Email='standarduser@testorg.com' LIMIT 1];
        System.runAs(objUser){
            test.startTest();
        		MCFD_GetSetContactDetails.getContactDetails();
            test.stopTest();
        }
    }
    
    static testmethod void testSetContactEmail(){
        User objUser = [SELECT id FROM User WHERE Email='standarduser@testorg.com' LIMIT 1];
        System.runAs(objUser){
            test.startTest();
            	String Email='sstandarduser2@testorg.com';
        		MCFD_GetSetContactDetails.SetContactEmail(Email);
            test.stopTest();
        }
    }
    
    static testmethod void testSetContactPhone(){
        User objUser = [SELECT id FROM User WHERE Email='standarduser@testorg.com' LIMIT 1];
        System.runAs(objUser){
            test.startTest();
            	String Phone = '9999999999';
        		MCFD_GetSetContactDetails.SetContactPhone(Phone);
            test.stopTest();
        }
    }


}