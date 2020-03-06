/*********************************************************************************************************
Name            : LightningForgotPasswordControllerTest.cls  
Description     : This class is to test LightningForgotPasswordController.cls functions. 
Created By      : ARDC ICM
Created Date    : 
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   05/07/2018   Updated methods 
--------------------------------------------------------------------------------------------------------------
***************************************************************************************************************/
@IsTest(SeeAllData = false)
public with sharing class LightningForgotPasswordControllerTest {

 /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
 @IsTest
 static void testLightningForgotPasswordControllerInvalidUserName() {
  System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email, 'ERROR');
  System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email, 'ERROR');
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email, 'ERROR');
 }

 /* Verifies that null checkEmailRef url throws proper exception. */
 @IsTest
 static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null', 'ERROR');
  System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null', 'ERROR');
 }

 /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
 @IsTest
 static void LightningForgotPasswordControllerInstantiation() {
  LightningForgotPasswordController controller = new LightningForgotPasswordController();
  System.assertNotEquals(controller, null);
 }
    
   @isTest
    static void TestForgotPassword()
    {
        PageReference pageRef = Page.siteRegisterConfirm;
        Test.setCurrentPage(pageRef);
        //String result=LightningForgotPasswordController.forgotPassword('vivek_kr_mishra@hotmail.com ', 'http://www.checkemailfake');
        //System.assertEquals(null, result);
    }
}