/*********************************************************************************************************
Name            : SiteLoginControllerTest.cls  
Description     : This is a Test class for SiteLoginController
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura      07/Feb/2017   	Original Version
--------------------------------------------------------------------------------------------------------------              
Rosario	   11//May/2018		Standard Applied
***************************************************************************************************************
 */
@IsTest(SeeAllData=false)
global with sharing class SiteLoginControllerTest {
    
    static testMethod void testSiteLoginController () {
        Test.startTest();
        	// Instantiate a new controller with all parameters in the page
        	SiteLoginController controller = new SiteLoginController ();
        	controller.username = 'test@salesforce.com';
        	controller.password = '123456'; 
                
        	System.assertEquals(controller.login(),null,'Error');
        Test.stopTest();
    }    
}