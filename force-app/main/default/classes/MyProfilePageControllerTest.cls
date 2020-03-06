/*********************************************************************************************************
Name            : MyProfilePageController.cls  
Description     : This is a test class for MyProfilePageController.cls (An apex class that updates portal user details.Guest users are never able to access this page.)
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura         07/Feb/2017   
--------------------------------------------------------------------------------------------------------------              
Gabriela     21/06/2018     Standards Applied
***************************************************************************************************************/
@IsTest(SeeAllData=false)
public with sharing class MyProfilePageControllerTest {
    
    @testSetup 
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
    }
    
    static testMethod void testSave() {
        // Modify the test to query for a portal user that exists in your org
        List<User> lstPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];
        if (lstPortalUsers != null && lstPortalUsers.isEmpty()) {
        
            User objCurrentUser = [SELECT id FROM User WHERE Email ='standarduser@testorg.com' LIMIT 1];
            MyProfilePageController objController = new MyProfilePageController();
            //System.assertEquals(objCurrentUser.Id, objController.getUser().Id, 'Did not successfully load the current user');
            System.assert(objController.getIsEdit() == false, 'isEdit should default to false');
            objController.edit();
            //System.assert(objController.getIsEdit() == true);
            objController.cancel();
            //System.assert(objController.getIsEdit() == false);
            
            System.assert(Page.ChangePassword.getUrl().equals(objController.changePassword().getUrl()));
            
            String strRandFax = Math.rint(Math.random() * 1000) + '5551234';
            objController.getUser().Fax = strRandFax;
            objController.save();
            //System.assert(objController.getIsEdit() == false);
            
            objCurrentUser = [SELECT id, fax FROM User WHERE id =: objCurrentUser.Id];
            //System.assert(objCurrentUser.fax == strRandFax);
        } 
        else {
            User objuserPortalUser = lstPortalUsers[0];
            String strRandFax = Math.rint(Math.random() * 1000) + '5551234';
            
            System.runAs(objuserPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(objuserPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);
                
                controller.cancel();
                System.assert(controller.getIsEdit() == false);
                
                controller.getUser().Fax = strRandFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }
            
            // verify that the user was updated
            objuserPortalUser = [Select id, fax from User where id =: objuserPortalUser.Id];
            System.assert(objuserPortalUser.fax == strRandFax);
        }
    }
}