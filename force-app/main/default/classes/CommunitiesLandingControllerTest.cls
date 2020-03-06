/*********************************************************************************************************
Name            : CommunitiesLandingControllerTest.cls  
Description     : This class is to test CommunitiesLandingController.cls functions,that takes the user to the right start page based on credentials or lack thereof. 
Created By      : Areeb Shaikh
Created Date    : 08/05/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                
* Liliana                 08/06/2018            Refactoring all test methods
*************************************************************************************************************/
 @IsTest(SeeAllData=false)
public class CommunitiesLandingControllerTest {
    
    static testMethod void CommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        Test.startTest();
            CommunitiesLandingController objcontroller = new CommunitiesLandingController();
            PageReference pageRef = objcontroller.forwardToStartPage();
            //PageRef is either null or an empty object in test context
            if(pageRef != null){
                String url = pageRef.getUrl();
                if(url != null){
                    System.assertEquals(true, String.isEmpty(url),'ERROR');
                    //show up in perforce
                }
            }
        Test.stopTest();
    }
}