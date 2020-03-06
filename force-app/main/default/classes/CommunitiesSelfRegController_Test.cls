/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
@IsTest(SeeAllData=false) 
public  class CommunitiesSelfRegController_Test {
    
    static testMethod void testCommunitiesSelfRegController() {
        Test.startTest();
            CommunitiesSelfRegController objcontroller = new CommunitiesSelfRegController();
            objcontroller.firstName = 'FirstName';
            objcontroller.lastName = 'LastName';
            objcontroller.email = 'test@force.com';
            objcontroller.communityNickname = 'test';
            System.assert(objcontroller.registerUser() == null);    
            objcontroller.password = 'abcd1234';
            objcontroller.confirmPassword = 'abcd123';
            System.assert(objcontroller.registerUser() == null);  
        Test.stopTest();
        
        
    }  
    
}