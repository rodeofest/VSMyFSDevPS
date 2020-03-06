/**************************************************************************************
Function        : Create Portal/Community Contact in Salesfoce. Further Contact Trigger will create MCFD Portal User (asynchronously)
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                12 APR 2017             Original Version
* Pavan Dave                31 AUG 2017             US 4727 - Hide GUID and other parameters from URL
* Pavan Dave                05 AUG 2017             Bug 5352 - Refactoring contact registration and adding apex sharing for account record 
* PDAVE                     27 OCT 2017             Bug fix 3080 - Trim contact First, Middle and Last Name fields 
*************************************************************************************/

public without sharing class MCFD_CreateContact {
    
    /*
    * Owner         :   Pavan Dave
    * Description   :   Insert MCFD Portal Contact after associating with MCFD Portal Account
    * Parameter     :   Contact 
    * Return Type   :   void
    */
        
    @AuraEnabled
    public static string create_Portal_User(Contact mcfdContact, MCFD_Address__c mcfdAddress){
        String redirectURL;     
        MCFD_Portal_Settings__c mcfdSetting = MCFD_Portal_Settings__c.getAll().values().get(0);
        MCFD_Portal_SSO_Redirection__c mcfdRedirectSetting = MCFD_Portal_SSO_Redirection__c.getAll().values().get(0);
        Account mcfdPortalAccount;
        Profile portalProfile;
        String mcfdPortalAccId;
        Id portalProfileId;
        
        try{
            portalProfile = [SELECT name, id FROM Profile WHERE Name =: mcfdSetting.MCFD_Community_Profile_Name__c LIMIT 1];                
            portalProfileId = portalProfile.id;
            
             // ---------------------------------------------------------------//
            // Creates MCFD Portal Contact, Address & Contact Address record  //
            // ---------------------------------------------------------------//
            
            List<Contact> existingContact = [SELECT id, Name, Email 
                                             FROM Contact 
                                             WHERE accountId <> Null 
                                             AND 
                                             (//MCFD_BCeID__c =: mcfdContact.MCFD_BCeID__c OR //commenting this for BCeID Encryption.
                                                 //Also, BCeiD check is not needed as every new BCeID will have new GuiD and one GUID will not have 2 BCeID
                                              MCFD_GUID__c =: mcfdContact.MCFD_GUID__c)
                                             //AND MCFD_BCeID__c <> Null
                                             AND MCFD_GUID__c <> Null
                                             LIMIT 1];
            
            if(!existingContact.isEmpty()){
                redirectURL = 'duplicateContact';
            }else{
                
                // ------------------------------------------------------------------//
                // --Bug fix 3080 - Trim contact First, Middle and Last Name fields -//
                // ------------------------------------------------------------------//
             
                if(mcfdContact.FirstName != null && mcfdContact.FirstName.length() > 40){
                    mcfdContact.FirstName = mcfdContact.FirstName.left(40);                         // sfdc limit 40
                }
                if(mcfdContact.MiddleName != null && mcfdContact.MiddleName.length() > 40){
                    mcfdContact.MiddleName = mcfdContact.MiddleName.left(40);                       // sfdc limit 40
                }
                if(mcfdContact.LastName != null && mcfdContact.LastName.length() > 50){
                    mcfdContact.LastName = mcfdContact.LastName.left(50);                           // sfdc limit 80    // ICM limit 50
                }
                
                // -----------------------------------------------------------------//
                // ---- MCFD Portal Account creation for Primary Applicant----------//
                // -----------------------------------------------------------------//
                mcfdPortalAccount = new Account();
                mcfdPortalAccount.Name = mcfdContact.LastName + ', ' + mcfdContact.FirstName;
                mcfdPortalAccount.OwnerId = mcfdSetting.MCFD_Portal_Account_Owner_ID__c;
                insert mcfdPortalAccount;
                mcfdPortalAccId = mcfdPortalAccount.Id;
                
                
                
                // -----------------------------------------------------------------//
                // ---- MCFD Portal Contact creation for Primary Applicant----------//
                // -----------------------------------------------------------------//
                mcfdContact.accountId = mcfdPortalAccId;
                mcfdContact.MCFD_Is_Portal_User__c = true;
                if(mcfdContact.phone == Null){
                    mcfdContact.MCFD_Primary_Phone_Number_Type__c = Null;
                }
                if(mcfdContact.mobilePhone == Null){
                    mcfdContact.MCFD_Secondary_Phone_Number_Type__c = Null;
                }
                mcfdContact.MailingStreet = mcfdAddress.MCFD_Address_Line_1__c;
                if(mcfdAddress.MCFD_Address_Line_2__c != Null){
                    mcfdContact.MailingStreet += '\n' + mcfdAddress.MCFD_Address_Line_2__c;
                }
                mcfdContact.MailingCity = mcfdAddress.MCFD_City__c;
                mcfdContact.MailingState = mcfdAddress.MCFD_Province__c;
                mcfdContact.MailingPostalCode = mcfdAddress.MCFD_Postal_Code__c;
                mcfdContact.MCFD_Status__c = 'Active';                                  // US 2012
                if(mcfdContact != null){
                insert mcfdContact;  }

                if(mcfdAddress != null){
                insert mcfdAddress;}
                    
                MCFD_Contact_Address__c conAddRec = new MCFD_Contact_Address__c();
                conAddRec.MCFD_Address__c = mcfdAddress.id;
                conAddRec.MCFD_Contact__c = mcfdContact.id;
                conAddRec.MCFD_Address_Type__c = 'Mailing Address';
                insert conAddRec;              

                // -----------------------------------------------------------------//
                // Now create MCFD Portal User where Contact is already associated  //
                // -----------------------------------------------------------------//
             //   Integer newMCFDPortalUserNum = MCFD_CreateContact.calculate_MCFD_Portal_User_Num();
                
                User mcfdPortalUser = new User(// First, Middle, Last Names should be defaulted from the contact
                                          firstName = mcfdContact.FirstName,
                                          middleName = mcfdContact.MiddleName,
                                          lastname = mcfdContact.lastName,
                                          
                                          // Alias should be the default combination of the persons name
                                          alias = mcfdContact.firstname.left(2)+mcfdContact.lastName.left(3),  
                                          
                                          // Email should default to the user's entered email
                                          email = mcfdContact.Email,
                                          
                                          // Username should follow the form 'mcfdportaluserX@mcfdportal.com' where X is an incrementing number for every new user added.
                                          // Nickname should follow the form mcfdportaluserX where X is an incrementing number for every new user added.            
                                          // IMPORTANT: username & communityNickname will be updated in before insert User Trigger
                                          username = mcfdSetting.MCFD_Portal_Username_Format__c.replace('X', mcfdContact.id),       
                                          communityNickname = mcfdSetting.MCFD_Portal_Nickname_Format__c+'.'+mcfdContact.id,
                                        //  MCFD_Portal_User_Number__c = newMCFDPortalUserNum, commenting this due to remedy 672666 and changing
                                        //  uniqueness from portal_user_number to contact Id
                                          
                                          // Federation ID should be the user's BCeID GUID                                            
                                          FederationIdentifier  = mcfdContact.MCFD_GUID__c,
                                          
                                          // User License should be Customer Community Plus Login
                                          // Profile should be MCFD Community Login         
                                          profileId = portalProfileId,
                                          
                                          // SET UP AND NON SET UP OBJECTS CAN BE INSERT TOGETHER ONLY WITH HELP OF Site.createExternalUser() METHOD
                                          contactId = mcfdContact.id,
                                          
                                          // User should be active, Time zone should be GMT-07:00, Locale should be English (Canada)                                         
                                          isActive = true,
                                          timezonesidkey = 'America/Los_Angeles',
                                          languagelocalekey = 'en_US',              //en_CA is not a valid languageLocalKey in Salesforce
                                          localesidkey = 'en_CA', 
                                          emailencodingkey = 'UTF-8' 
                                          
                                          // 'Generate new password and notify user immediately' should be unchecked 
                                          // by default no email will be send to users created using Apex
                                ); 
                
                String userId;
                
               
                System.debug('PortalUser Details '+ mcfdPortalUser);
                System.debug('AccountID '+mcfdPortalAccId);
           //   userId = Site.createExternalUser(mcfdPortalUser, mcfdPortalAccId); //commenting and adding below
           //   2 lines for bug fix 6192
                insert mcfdPortalUser;
                userId = mcfdPortalUser.Id;       

                if (userId != null) { 
                    system.debug('--MCFD_CreateContact.create_Portal_User() -- userId--'+userId);
                    //redirectURL = mcfdSetting.Portal_Landing_Page_url__c; 
                    redirectURL = mcfdRedirectSetting.External_User_URL__c;
                    portal_Account_Manual_Share(mcfdPortalAccId ,userId, mcfdPortalAccount.OwnerId);
                }else{
                    system.debug('-- MCFD_CreateContact.create_Portal_User() --  no userId returned');
                    redirectURL = 'exception';
                }   
            }
        }catch(Exception e){ 
            redirectURL = 'exception';  
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CreateContact', 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+e.getStackTraceString());
        }         
       
        System.debug('--- MCFD_CreateContact -- redirectURL ---');
        return redirectURL;
    }    
    
    public static Integer calculate_MCFD_Portal_User_Num(){
        Integer currentMCFDPortalUserNum;
        List<User> lasterMCFDPortalUser = [SELECT Id, MCFD_Portal_User_Number__c 
                                           FROM User 
                                           WHERE MCFD_Portal_User_Number__c <> Null
                                            ORDER BY MCFD_Portal_User_Number__c DESC 
                                            LIMIT 1];
        
        if(lasterMCFDPortalUser.isEmpty()){
            currentMCFDPortalUserNum = 1;       // This would execute only for the first MCFD Portal User getting created.
        }else{
            currentMCFDPortalUserNum = Integer.valueOf(lasterMCFDPortalUser.get(0).MCFD_Portal_User_Number__c) + 1;
        }
        System.debug('--- MCFD_CreateContact.calculate_MCFD_Portal_User_Num()---currentMCFDPortalUserNum--'+currentMCFDPortalUserNum);
        return currentMCFDPortalUserNum;
    }
    
    /*
    * Owner         :   PDAVE
    * Description   :   decrpt the url string
    */
        
    @AuraEnabled
    public static string apex_decrpt_url(String encrptedString){
        Blob cryptoKey = Blob.valueOf(System.Label.Crypto_Key_16_Digit);    //16 byte string. since characters used are ascii, each char is 1 byte.
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, EncodingUtil.base64Decode(encrptedString));
        String decryptedDataString = decryptedData.toString();
        return decryptedDataString;
    }
    
    /*
    * Owner         :   PDAVE
    * Description   :   Manually shares accout with portal users
    */
    @AuraEnabled
    public static boolean portal_Account_Manual_Share(Id accId, Id portalUserId, Id portalAccountOwnerId){
        // Create new sharing object for the custom object Account.
        AccountShare accShare  = new AccountShare();

        // Set the ID of record being shared.
        accShare.AccountId = accId;

        // Set the ID of user or group being granted access.
        accShare.UserOrGroupId = portalUserId;

        // Set the access level.
        accShare.AccountAccessLevel = 'Edit';
        accShare.ContactAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'None';
        accShare.CaseAccessLevel = 'None';
        
        // Set rowCause to 'manual' for manual sharing.
        // This line can be omitted as 'manual' is the default value for sharing objects.
        accShare.RowCause = Schema.AccountShare.RowCause.Manual;

        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        Database.SaveResult sr = Database.insert(accShare, false);

        // Process the save results.
        if(sr.isSuccess()){
         // Indicates success
         return true;
        }
        else {
         // Get first save result error.
         Database.Error err = sr.getErrors()[0];
         
         // Check if the error is related to trival access level.
         // Access level must be more permissive than the object's default.
         // These sharing records are not required and thus an insert exception is acceptable. 
         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                  err.getMessage().contains('AccessLevel')){
            // Indicates success.
            return true;
         }
         else{
            // Indicates failure.
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CreateContact', 'Account Share Error Status Code: '+err.getStatusCode()+'\n'+'Error Message: '+err.getMessage());
            return false;           
         }
        }   
    }
}