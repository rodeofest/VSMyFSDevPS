/**
 * An apex class that creates a portal user
 */
public with sharing class SiteRegisterController {
    // PORTAL_ACCOUNT_ID is the account on which the contact will be created on and then enabled as a portal user.
    // you need to add the account owner into the role hierarchy before this will work - please see Customer Portal Setup help for more information.       
    //private static Id PORTAL_ACCOUNT_ID = '001x000xxx35tPN';
    private static Id portal_Account_Id = '0014D0000042yPh';

    
    public String username {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }

    
    // Commented by Abhishek to fix CRD
    /*
    public SiteRegisterController () {
    }
    */
          
    private boolean isValidPassword() {
        return password == confirmPassword;
    }
    
    public PageReference registerUser() {
        // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    
        /* Profile portalProfile = [SELECT name, id FROM Profile WHERE Name =: System.Label.MCFD_Community_Profile_Name LIMIT 1];
        User mcfdPortalUser = new User(// First, Middle, Last Names should be defaulted from the contact
                                  //firstName = mcfdContact.FirstName,
                                  //middleName = mcfdContact.MiddleName,
                                  lastname = username,
                                  
                                  // Alias should be the default combination of the persons name
                                  alias = username.left(3),  
                                  
                                  // Email should default to the user's entered email
                                  email = Email,
                                  
                                  // Username should follow the form 'mcfdportaluserX@mcfdportal.com' where X is an incrementing number for every new user added.
                                  // Nickname should follow the form mcfdportaluserX where X is an incrementing number for every new user added.            
                                  // username & communityNickname will be taken care in User Trigger
                                  username = username,
                                  communityNickname = username.left(4),
                                  
                                  // Federation ID should be the user's BCeID GUID          
                                  FederationIdentifier  = username,
                                  
                                  // User License should be Customer Community Plus Login
                                  // Profile should be MCFD Community Login         
                                  profileId = portalProfile.id,
                                  //contactId = mcfdContact.id,
                                  
                                  // User should be active, Time zone should be GMT-07:00, Locale should be English (Canada)                                         
                                  isActive = true,
                                  timezonesidkey = 'America/Los_Angeles',
                                  languagelocalekey = 'en_US',              //en_CA is not a valid languageLocalKey in Salesforce
                                  localesidkey = 'en_CA', 
                                  emailencodingkey = 'UTF-8' 
                                  
                                  // 'Generate new password and notify user immediately' should be unchecked 
                                  // by default no email will be send to users created using Apex
                        ); */
        User usr = new User();
        usr.Username = username;
        usr.Email = email;
        usr.CommunityNickname = communityNickname;
        
        String accountId = PORTAL_ACCOUNT_ID;

        // lastName is a required field on user, but if it isn't specified, we'll default it to the username
        //String userId = Site.createPortalUser(mcfdPortalUser, accountId, password);
        String userId = Site.createExternalUser(usr, accountId, password);
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                //system.debug('site login');
                return Site.login(username, password, null);
            }
            else {
                PageReference page = System.Page.SiteRegisterConfirm;
                //system.debug('site register confirm ');
                page.setRedirect(true);
                return page;
            }
        }else{
            //system.debug('site userid null');
        }
        return null;
    }
}