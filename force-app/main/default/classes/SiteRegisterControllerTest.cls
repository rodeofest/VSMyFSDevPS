/********************************************************************************************************
Name            : SiteRegisterControllerTest.cls  
Description     : Class containing tests for SiteRegisterController
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura      07/Feb/2017   
--------------------------------------------------------------------------------------------------------------              

**************************************************************************************************************
 */
@IsTest (SeeAllData=false)
public with sharing class SiteRegisterControllerTest {
    
    static testMethod void testRegistration() {
    SiteRegisterController controller = new SiteRegisterController();
    controller.username = 'test@force.com';
    controller.email = 'test@force.com';
    controller.communityNickname = 'test';
    // registerUser always returns null when the page isn't accessed as a guest user 

    System.assert(controller.registerUser() == null);
    controller.password = 'abcd1234';
    controller.confirmPassword = 'abcd123';
    System.assert(controller.registerUser() == null);
	}
}