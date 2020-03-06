/*********************************************************************************************************
Name            : CommunitiesLoginControllerTest 
Description     :This is a test class for CommunitiesLoginController- An apex page controller that exposes the site login functionality
Created By      : Areeb Shaikh
Created Date    : 08/05/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                
* Liliana    08/06/2018    Refactoring all test methods
*************************************************************************************************************/
 
@IsTest(SeeAllData=false) 
public class CommunitiesLoginControllerTest {
    
 	static testMethod void CommunitiesLoginController () {
        Test.startTest();
        	CommunitiesLoginController controller = new CommunitiesLoginController();
        	System.assertEquals(null, controller.forwardToAuthPage(),'ERROR');       
        Test.stopTest();
    }    
}