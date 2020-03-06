/*********************************************************************************************************
Name            : SiteLoginController.cls  
Description     : An apex page controller that exposes the site login functionality
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura      07/Feb/2017   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************
 * 
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    // Commented by Abhishek to fix CRD
    /*
    global SiteLoginController () {}
    */
}