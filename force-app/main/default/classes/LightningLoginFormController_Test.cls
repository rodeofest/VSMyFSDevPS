/*********************************************************************************************************
Name            : LightningLoginFormController_Test.cls  
Description     : This class is to test LightningLoginFormController.cls functions.
Modified By      : Deloitte ARDC
Modified Date    : 15/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Gabriela      15/May/2018
***************************************************************************************************************/
@IsTest(SeeAllData = false)
public with sharing class LightningLoginFormController_Test {

 @IsTest
 static void testLoginWithInvalidCredentials() {
  System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
 }

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled(),'ERROR');
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
//  System.assertEquals(true, LightningLoginFormController.getIsSelfRegistrationEnabled(),'ERROR');
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
//  System.assertNotEquals(null, LightningLoginFormController.getSelfRegistrationUrl(),'ERROR');
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
 @IsTest
 static void getForgotPasswordUrlTest() {
  LightningLoginFormController.getForgotPasswordUrl();
  
 }
}