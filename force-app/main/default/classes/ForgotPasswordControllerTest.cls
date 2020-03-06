/*********************************************************************************************************
Name            : ForgotPasswordControllerTest.cls  
Description     : This is a text class for ForgotPasswordController 
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura        07/Feb/2017   
--------------------------------------------------------------------------------------------------------------              
Liliana 	 07/June/2018   Code standards applied
***************************************************************************************************************/
   
@IsTest(SeeAllData=false)
public with sharing class ForgotPasswordControllerTest {
    
      static TestMethod void testForgotPasswordController() {
        Test.startTest();
            ForgotPasswordController controller = new ForgotPasswordController();
            controller.username = 'test@salesforce.com';      
            controller.forgotPassword();
        Test.stopTest();
    }
}