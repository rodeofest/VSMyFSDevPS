/*********************************************************************************************************
Name            : ChangePasswordControllerTest.cls  
Description     : This class is to test ChangePasswordController.cls functions. 
Created By      : Areeb Shaikh
Created Date    : 08/05/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                
Liliana      08/06/2018    Standard Applied
*************************************************************************************************************/

@IsTest(SeeAllData=false) 
public class ChangePasswordControllerTest {
   static  testMethod void testChangePasswordController() {
        Test.startTest();
            ChangePasswordController objcontroller = new ChangePasswordController();
            objcontroller.oldPassword = '123456';
            objcontroller.newPassword = 'qwerty1'; 
            objcontroller.verifyNewPassword = 'qwerty1'; 
            System.assertEquals(objcontroller.changePassword(),null, 'Error');     
       Test.stopTest();
    }    
}