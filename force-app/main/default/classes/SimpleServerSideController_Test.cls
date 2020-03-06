/**************************************************************************************
Apex Class Name     : SimpleServerSideController_Test.cls
Version             : 1.0 
Created Date        : 03/20/2017
Function            : This is a test class for SimpleServerSideController (used to get the user information).
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek              05/22/2017                Original Version
* ----------------------------------------------------------------------------                 
* Rosario               May/11/2018               Standard Applied
*************************************************************************************/

@isTest
public class SimpleServerSideController_Test {
    
    private static testMethod void SimpleServerSideControllerTest()	{
        Test.startTest();
        	// calling method
        	SimpleServerSideController.getCurrentUser();
        Test.stopTest();
       }
}