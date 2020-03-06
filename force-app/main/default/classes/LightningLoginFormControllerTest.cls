/*********************************************************************************************************
Name            : LightningLoginFormControllerTest.cls  
Description     : This class is to test LightningLoginFormController.cls functions.
Modified By     : ARDC ICM
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                       
Gabriela      16/May/2018   Updated
***************************************************************************************************************/

@IsTest(SeeAllData = false)
public with sharing class LightningLoginFormControllerTest {
    
    //this method covers the functions of the login invalid credentials method
    static testMethod void testLoginWithInvalidCredentials() {
        test.startTest();
        	System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
        test.stopTest();
    }
    
    //this method covers the functions of the login Instantiation method
    static testMethod void LightningLoginFormControllerInstantiation() {
        
        test.startTest();
        	LightningLoginFormController objController = new LightningLoginFormController();
        	System.assertNotEquals(objController, null);
        test.stopTest();
    }
    
    //this method covers the functions of the getIsUsernamePasswordEnabled method
    static testMethod void testIsUsernamePasswordEnabled() {
        test.startTest();
        	System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled(),'ERROR');
        test.stopTest();
    }
    
    //this method covers the functions of the getIsSelfRegistrationEnabled method
    static testMethod void testIsSelfRegistrationEnabled() {
        test.startTest();
        //	System.assertEquals(true, LightningLoginFormController.getIsSelfRegistrationEnabled(),'ERROR');
        test.stopTest();
    }
    
    //this method covers the functions of the getSelfRegistrationUrl method
    static testMethod void testGetSelfRegistrationURL() {
        test.startTest();
        //	System.assertNotEquals(null, LightningLoginFormController.getSelfRegistrationUrl(),'ERROR');
        test.stopTest();
    }
    
    //this method covers the functions of the getAuthConfig method
    static testMethod void testAuthConfig() {
        test.startTest();
            Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
            System.assertNotEquals(null, authConfig);
        test.stopTest();
    }
    
    //add this method for coverage getForgotPasswordUrl method 
    static testMethod void getForgotPasswordUrlTest() {
        test.startTest();
        	LightningLoginFormController.getForgotPasswordUrl();
        test.stopTest();
    }
}