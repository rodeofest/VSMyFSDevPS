/*********************************************************************************************************
Name            : ForgotPasswordController.cls  
Description     : An apex page controller that exposes the site forgot password functionality
Created By      : Deloitte
Created Date    : 07/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura        07/Feb/2017   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/


public with sharing class ForgotPasswordController {
    public String username {get; set;}   
    
    // Commented by Abhishek to fix CRD
    /*   
    public ForgotPasswordController() {}
    */
    
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pageR = Page.ForgotPasswordConfirm;
        PageReference returnPr;
        pageR.setRedirect(true);
        
        if (success) { 
            returnPr = pageR;             
            //return pr;
        }
        else{
        returnPr = null;
        //return null;
        }
        return returnPr;
    }
}