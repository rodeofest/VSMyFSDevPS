/*********************************************************************************************************
Name            : TestDataFactory.cls  
Description     : This is an utility class to create objects and call diferents methods.  
Created By      : ARDC ICM
Created Date    : 04/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   18/05/2018   Original version 
--------------------------------------------------------------------------------------------------------------            
***************************************************************************************************************/
public class TestDataFactory {
    
    public static ChangePasswordController initializeChangePasswordController(String OldPassw, String NewPass, String VerifyNewPass) {
        ChangePasswordController objChangePasswordController = new ChangePasswordController();
        objChangePasswordController.oldPassword = OldPassw;
        objChangePasswordController.newPassword = NewPass; 
        objChangePasswordController.verifyNewPassword = VerifyNewPass; 
        return objChangePasswordController;
    }
    
    public static CommunitiesSelfRegController initializeCommunitiesSelfRegController(String strFirstName, String strLastName, String strEmail, String strCommunityNickname, String strPassword, String strConfirmPassword) {
        CommunitiesSelfRegController objCommunitiesSelfRegController = new CommunitiesSelfRegController();
        objCommunitiesSelfRegController.firstName = strFirstName;
        objCommunitiesSelfRegController.lastName = strLastName;
        objCommunitiesSelfRegController.email = strEmail;
        objCommunitiesSelfRegController.communityNickname = strCommunityNickname;
        objCommunitiesSelfRegController.password = strPassword;
        objCommunitiesSelfRegController.confirmPassword = strConfirmPassword;
        return objCommunitiesSelfRegController;
    }
    
    public static MCFD_Document_Integration_Engine__c createDocumentIntegrationEngine(Id idCustomAttachment, Id idStandardAttachment, Id idRequest, String strIntegrationStatus, String strIntegrationOperation,String strICMFileName) {
        MCFD_Document_Integration_Engine__c objDocumentIntegration = new MCFD_Document_Integration_Engine__c();
        objDocumentIntegration.Parent_Custom_Attachment__c = idCustomAttachment;
        objDocumentIntegration.Child_Standard_Attachment__c = idStandardAttachment;
        objDocumentIntegration.Integration_Status__c = strIntegrationStatus;
        objDocumentIntegration.Parent_Request__c =   idRequest;
        objDocumentIntegration.Integration_Operation__c = strIntegrationOperation;
        objDocumentIntegration.ICM_FileName__c=strICMFileName;
        return objDocumentIntegration;
    }
    
    public static Attachment createStandardAttachment(Id idParentCustomAttachment) {
        Attachment objFile = new Attachment();
        objFile.parentId = idParentCustomAttachment;
        objFile.Body = EncodingUtil.base64Decode('xyz123abcUVW');
        objFile.Name = 'testFileName';
        objFile.ContentType = 'contentType';
        return objFile;
    }
    /*
public static Request__c createRequestContact(User objUser,RecordType objRecordType,String strServiceAuthType, String strSpouse, String strLinking, String strStatus) {
Request__c objRequest = new Request__c();
ObjRequest.RecordTypeId = objRecordType.Id;
ObjRequest.ICM_SR_Number__c = ' ';
ObjRequest.Primary_Applicant__c = objUser.ContactId;
ObjRequest.MCFD_consent_to_share_info_with_spouse__c = true;
ObjRequest.MCFD_consent_share_info_with_sp_signed__c = 'Consent signed';
ObjRequest.MCFD_spousal_consent_signed_date__c = '11/11/2017';
ObjRequest.MCFD_spousal_consent_check1__c = true;
ObjRequest.MCFD_spousal_consent_check2__c = true;
ObjRequest.MCFD_DeclarationAndConsent__c = true;
ObjRequest.MCFD_declaration_and_consent_signed_date__c = 'Consent signed';
objRequest.MCFD_Service_Auth_Type__c = strServiceAuthType;
objRequest.Spouse__c = strSpouse;
objRequest.Linking_One_Time_Password__c = strLinking;
objRequest.MCFD_Status__c = strStatus;
return objRequest;  
}*/
    
    public static Request__c createRequest(User objUser,RecordType objRecordType,String strServiceAuthType) {
        Request__c objRequest = new Request__c();
        ObjRequest.RecordTypeId = objRecordType.Id;
        ObjRequest.ICM_SR_Number__c = ' ';
        ObjRequest.Primary_Applicant__c = objUser.ContactId;
        ObjRequest.MCFD_consent_to_share_info_with_spouse__c = true;
        ObjRequest.MCFD_consent_share_info_with_sp_signed__c = 'Consent signed';
        ObjRequest.MCFD_spousal_consent_signed_date__c = '11/11/2017';
        ObjRequest.MCFD_spousal_consent_check1__c = true;
        ObjRequest.MCFD_spousal_consent_check2__c = true;
        ObjRequest.MCFD_DeclarationAndConsent__c = true;
        ObjRequest.MCFD_declaration_and_consent_signed_date__c = 'Consent signed';
        objRequest.MCFD_Service_Auth_Type__c = strServiceAuthType;
        objRequest.Linking_One_Time_Password__c='89141556';
        objRequest.MCFD_Status__c='';
        return objRequest;  
    }
    
    public static Request__c createRequestContact(String IdContact,RecordType objRecordType,String strServiceAuthType) {
        Request__c objRequest = new Request__c();
        ObjRequest.RecordTypeId = objRecordType.Id;
        ObjRequest.ICM_SR_Number__c = ' ';
        ObjRequest.Primary_Applicant__c = IdContact;
        ObjRequest.MCFD_consent_to_share_info_with_spouse__c = true;
        ObjRequest.MCFD_consent_share_info_with_sp_signed__c = 'Consent signed';
        ObjRequest.MCFD_spousal_consent_signed_date__c = '11/11/2017';
        ObjRequest.MCFD_spousal_consent_check1__c = true;
        ObjRequest.MCFD_spousal_consent_check2__c = true;
        ObjRequest.MCFD_DeclarationAndConsent__c = true;
        ObjRequest.MCFD_declaration_and_consent_signed_date__c = 'Consent signed';
        objRequest.MCFD_Service_Auth_Type__c = strServiceAuthType;
        return objRequest;  
    }
    
    public static MCFD_Attachment__c createCustomAttachment(Request__c objRequest) {
        MCFD_Attachment__c objCustomAttachment = new  MCFD_Attachment__c();
        objCustomAttachment.MCFD_Last_Modified_Date__c = System.Now();
        objCustomAttachment.MCFD_Type__c = 'Document Checklist';
        objCustomAttachment.MCFD_Category__c = 'Others';
        objCustomAttachment.MCFD_Attachment_Name__c = 'TestFileName';
        objCustomAttachment.ICM_Attachment_Id__c = '1-10987';
        objCustomAttachment.MCFD_Status__c = 'Document Uploaded';
        objCustomAttachment.MCFD_Request_Id__c = objRequest.Id;
        return objCustomAttachment;
    }  
    
    public static Account createAccount(String strAccountName) {
        Account objAccount = new Account();
        objAccount.Name = strAccountName;
        objAccount.AccountNumber = '1000001';
        return objAccount;
    }
    
    public static Contact createContact(String strLastName, Id idAccount,String strICMContactId,String strFirstName) {
        Contact objContact = new Contact();
        objContact.lastName = strLastName; 
        objContact.FirstName =strFirstName;
        objContact.MiddleName = 'Test';
        objContact.Email = getUniqueUsername();
        objContact.Birthdate = Date.parse('10/10/1980');
        objContact.AccountId = idAccount; 
        objContact.MCFD_BCeId__c = '1234567890';
        objContact.ICM_Contact_Id__c = strICMContactId;
        objContact.MCFD_Gender__c = 'Male';
        objContact.MCFD_SIN__c = '363533225';
        objContact.MCFD_Govt_Disability_Benefit__c = 'No';
        objContact.MCFD_Special_needs__c = 'Yes';
        objContact.MCFD_Marital_Status__c = '';
        objContact.MCFD_Childcare_Require__c = 'Yes';
        objContact.MCFD_Is_SW_Referred__c = 'No';
        objContact.Phone = '2508009999';
        objContact.MobilePhone = '2501112222';
        objContact.MCFD_Licensed_Group_CC__c = true;
        objContact.MCFD_Child_Placement__c = 'Yes';
        objContact.MCFD_Primary_Phone_Number_Type__c = 'Home';
        objContact.MCFD_Secondary_Phone_Number_Type__c = 'Cell';
        objContact.MCFD_Address_Check__c = 'No';
        objContact.Linking_Retry_Time__c=Datetime.Now().AddDays(-1);
        objContact.Linking_Number_Of_Retries__c=null;
        objContact.Linking_Retry_Time__c=(Datetime.Now().AddHours(-2*integer.valueof(system.label.Spouse_LinkingBlockingHours)));
        objContact.MCFD_HasActiveCRAConsent__c =false;
        return objContact;	
    }
    public static Contact createContact2(String strLastName, Id idAccount,String strICMContactId,String strFirstName) {
        Contact objContact = new Contact();
        objContact.lastName = strLastName; 
        objContact.FirstName =strFirstName;
        objContact.MiddleName = 'Test';
        objContact.Email = getUniqueUsername();
        objContact.Birthdate = Date.parse('10/10/1980');
        objContact.AccountId = idAccount; 
        objContact.MCFD_BCeId__c = '1234567890';
        objContact.ICM_Contact_Id__c = strICMContactId;
        objContact.MCFD_Gender__c = 'Male';
        objContact.MCFD_SIN__c = '363533225';
        objContact.MCFD_Govt_Disability_Benefit__c = 'No';
        objContact.MCFD_Special_needs__c = 'Yes';
        objContact.MCFD_Marital_Status__c = '';
        objContact.MCFD_Childcare_Require__c = 'Yes';
        objContact.MCFD_Is_SW_Referred__c = 'No';
        objContact.Phone = '2508009999';
        objContact.MobilePhone = '2501112222';
        objContact.MCFD_Licensed_Group_CC__c = true;
        objContact.MCFD_Child_Placement__c = 'Yes';
        objContact.MCFD_Primary_Phone_Number_Type__c = 'Home';
        objContact.MCFD_Secondary_Phone_Number_Type__c = 'Work';
        objContact.MCFD_Address_Check__c = 'No';
        objContact.Linking_Retry_Time__c=Datetime.Now().AddDays(1);
        objContact.Linking_Number_Of_Retries__c=5;
        objContact.ICM_Cell_Phone__c='01phone';
        objContact.MCFD_HasActiveCRAConsent__c =false;
        
        return objContact;	
    }
    
    public static User createUser(Contact objContact,Profile objProfile,String strEmail,String strFederationIdentifier) {
        User objUser = new User();
        objUser.Alias = 'standt'; 
        objUser.Email=strEmail; 
        objUser.EmailEncodingKey='UTF-8';
        objUser.LastName='Testing'; 
        objUser.LanguageLocaleKey='en_US'; 
        objUser.LocaleSidKey='en_US'; 
        objUser.ProfileId = objProfile.Id; 
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.UserName=getUniqueUsername(); 
        objUser.IsActive =true;
        objUser.ContactId = objContact.Id;
        objUser.FederationIdentifier = strFederationIdentifier;
        return objUser;
    }
    
    public static String getUniqueUsername() {
        return 'User' + Datetime.now().getTime() + Math.random()*100 + '@testMCFDPortal.com';
    }
    
    public static Profile getProfile(String strNameProfile){
        Profile ObjProfile = [SELECT Id FROM Profile WHERE Name =:strNameProfile]; 
        return ObjProfile;
    }
    
    public static RecordType getRecordType(String strsObjectType,String strNameRecordType){
        RecordType objRecordType = [SELECT Id FROM RecordType WHERE sObjectType =:strsObjectType AND Name =:strNameRecordType];
        return objRecordType;
    }
    
    public static MCFD_Portal_Settings__c createPortalSettings(String strCommProf, String strPortalAccName,User ObjUser) {
        MCFD_Portal_Settings__c objMCFDPortalSettings = new MCFD_Portal_Settings__c(); 
        objMCFDPortalSettings.MCFD_Portal_Account_Owner_ID__c=objUser.Id;
        objMCFDPortalSettings.Name = 'test data';
        objMCFDPortalSettings.System_Maintenance_URL__c='Test';
        objMCFDPortalSettings.MCFD_Community_Profile_Name__c = strCommProf;
        objMCFDPortalSettings.MCFD_Portal_Account_Name__c = strPortalAccName;    
        objMCFDPortalSettings.MCFD_Portal_Nickname_Format__c = 'mcfdportaluserX';
        objMCFDPortalSettings.MCFD_Portal_Username_Format__c = 'mcfdportaluserX@mcfdportal.com';
        objMCFDPortalSettings.MCFD_Community_URL__c = 'https://dev-mcfd-portal.cs71.force.com';
        objMCFDPortalSettings.Portal_Error_Page_URL__c = 'https://dev-mcfd-portal.cs71.force.com/s/message';
        objMCFDPortalSettings.Portal_Landing_Page_url__c = 'https://dev-mcfd-portal.cs71.force.com/s/portal-landing-page';
        objMCFDPortalSettings.Portal_Registration_Page_URL__c = 'https://dev-mcfd-portal.cs71.force.com/s/registration';
        return objMCFDPortalSettings;
    }
    
    public static MCFD_Portal_SSO_Redirection__c createPortalSSORedirection() {
        MCFD_Portal_SSO_Redirection__c objMCFDPortalSSORedirection = new MCFD_Portal_SSO_Redirection__c();        
        objMCFDPortalSSORedirection.Name = 'test data';
        objMCFDPortalSSORedirection.Internal_User_URL__c = 'https://login.salesforce.com';
        objMCFDPortalSSORedirection.External_User_URL__c = 'https://dev-mcfd-portal.cs71.force.com';    
        objMCFDPortalSSORedirection.SiteMinder_Login_URL__c = 'http://axiomsso.herokuapp.com/RequestSamlResponse.action';
        objMCFDPortalSSORedirection.BCeID_Attribute_Name__c = 'BCEID';
        objMCFDPortalSSORedirection.Email_Attribute_Name__c = 'EMAIL';
        objMCFDPortalSSORedirection.Federation_Identifier_Attribute_Name__c = 'useridentifier'; 
        objMCFDPortalSSORedirection.First_Name_Attribute_Name__c = 'GIVENNAME';
        objMCFDPortalSSORedirection.Middle_Name_Attribute_Name__c = 'SECONDNAME';
        objMCFDPortalSSORedirection.Last_Name_Attribute_Name__c = 'SURNAME';
        objMCFDPortalSSORedirection.IsIDIR_Attribute_Name__c = 'ISIDIR';
        objMCFDPortalSSORedirection.BCeID_Type_Attribute_Name__c = 'TestAttr';
        return objMCFDPortalSSORedirection;
    }
    
    public static MCFD_Relationship__c createRelationship(String strRelationshipType, Id idParentContact, Id idChildContact, Id idRequest) {
        MCFD_Relationship__c ObjRelationship =  new MCFD_Relationship__c();   
        ObjRelationship.MCFD_Parent_Contact__c = idParentContact;
        ObjRelationship.MCFD_Relationship_Type__c = strRelationshipType ;
        ObjRelationship.MCFD_Request__c = idRequest;
        ObjRelationship.MCFD_Child_Contact__c = idChildContact;
        return ObjRelationship;
    } 
    
    public static List<MCFD_Message__c> createMessages(Integer intHowManyMessages) {
        List<MCFD_Message__c> listMessages= New List<MCFD_Message__c>();
        for(Integer i=0; i<intHowManyMessages; i++) {
            MCFD_Message__c objMessage = new MCFD_Message__c();
            objMessage.Message_Body__c = Label.CCS_Checklist_Message_Body;
            objMessage.ICM_Case_Id__c = 'AF510'+i;
            objMessage.Message_Status__c = 'Sent to ICM'; //'Reply to ICM'
            objMessage.ICM_Contact_Id__c =  '1-4HH6USH';
            objMessage.ICM_SR_Id__c= 'IdSR Test'+i;
            objMessage.Message_Subject__c = 'Subject Test'+i;
            objMessage.ICM_Program_Type__c = 'Autism Funding'; //Child Care Subsidy
            objMessage.Message_Type__c = 'General Message'; //Welcome Message or New or Replay
            objMessage.ICM_Case_Name__c = 'Case Name Test';
            objMessage.ICM_Case_Worker_First_Name__c = 'Case Worker First Name Test';
            objMessage.ICM_Case_Worker_IDIR__c = 'Case Worker IDIR Test';
            objMessage.ICM_Case_Worker_Last_Name__c = 'Case Worker Last Name Test';
            objMessage.ICM_Client_Unread_Flag__c = false;
            objMessage.ICM_Conversation_Id__c = 'Conversation Test'+i;
            objMessage.ICM_Date_Message_Sent__c = datetime.now();
            objMessage.ICM_Disable_Reply__c = false;
            objMessage.ICM_Importance_Flag__c = '3-Standard'; // 1-Urgent or 2-High
            objMessage.ICM_Message_Due_Date__c = datetime.newInstance(date.today(), time.newInstance(i, 00, 00, 00));
            objMessage.ICM_Message_Id__c = 'Message ID'+i;
            objMessage.ICM_SR_Sub_Type__c = 'SR Subtype test';
            objMessage.Message_Received_From__c = 'Message Received from Test';
            objMessage.Message_Integration_Status__c = 'Submission error';
            objMessage.Portal_Message_Read__c = false;            
            listMessages.add(objMessage);	
        }
        return listMessages;
    }
    
    public static Income__c createIncome(Id idRequest, Id idContact){
        Income__c objIncome = new Income__c();
        objIncome.MCFD_Employment_Income__c = 'Yes';
        objIncome.Name ='Employment Income';
        objIncome.MCFD_Self_Employment_Income__c = 'Yes';
        objIncome.MCFD_Band_Assistance__c = 'Yes';
        objIncome.MCFD_Band_Assistance_Amount__c = 100;
        objIncome.MCFD_Band_Assistance_Freq__c = 'Every month';        
        objIncome.MCFD_BC_Disability_Assistance__c = 'Yes';
        objIncome.MCFD_BC_Disability_Assistance_Amount__c = 200;
        objIncome.MCFD_BC_Disability_Assistance_Freq__c = 'Every week';        
        objIncome.MCFD_BC_Income_Assistance__c = 'Yes';
        objIncome.MCFD_BC_Income_Assistance_Amount__c = 200;
        objIncome.MCFD_BC_Income_Assistance_Freq__c = 'Every two weeks';
        objIncome.MCFD_Federal_Benefits__c = 'Yes';
        objIncome.MCFD_Federal_Benefits_Amount__c = 100;
        objIncome.MCFD_Federal_Benefits_Freq__c = 'Twice a month';
        objIncome.MCFD_Federal_Employment_Insurance__c = 'Yes';
        objIncome.MCFD_Federal_Employment_Insurance_Amount__c = 140;
        objIncome.MCFD_Federal_Employment_Insurance_Freq__c = 'Every year';
        objIncome.MCFD_Federal_Employment_Insurance_Start__c = Date.parse('1/1/2017');
        objIncome.MCFD_Grants__c = 'Yes';
        objIncome.MCFD_Grants_Amount__c = 250;
        objIncome.MCFD_Grants_Freq__c = '4 Months';        
        objIncome.MCFD_Dep_Adult_Income__c = 'Yes';
        objIncome.MCFD_Dep_Adult_Income_Amount__c = 120;
        objIncome.MCFD_Dep_Adult_Income_Freq__c = '5 Months';
        objIncome.MCFD_Rental_Income__c = 'Yes';
        objIncome.MCFD_Rental_Income_Amount__c = 130;
        objIncome.MCFD_Rental_Income_Freq__c = 'Semi-Annually';
        objIncome.MCFD_Interest_Amount__c = 127;
        objIncome.MCFD_Interest_Freq__c = '7 Months';
        objIncome.MCFD_Interest__c = 'Yes';
        objIncome.MCFD_Other_Income__c = 'Yes';
        objIncome.MCFD_Other_Income_Amount__c = 298;
        objIncome.MCFD_Other_Income_Freq__c = '8 Months';
        objIncome.MCFD_Spousal_Support__c = 'Yes';
        objIncome.MCFD_Spousal_Support_Amount__c = 256;
        objIncome.MCFD_Spousal_Support_Freq__c = '9 Months';
        objIncome.MCFD_Tips__c = 'Yes';
        objIncome.MCFD_Tips_Amount__c = 187;
        objIncome.MCFD_Tips_Freq__c = '10 Months';
        objIncome.MCFD_Training_Living_Allowance__c = 'Yes';
        objIncome.MCFD_Training_Living_Allowance_Amount__c = 240;
        objIncome.MCFD_Training_Living_Allowance_Freq__c = '11 Months';
        objIncome.MCFD_WorkSafeBC__c = 'Yes';
        objIncome.MCFD_WorkSafeBC_Amount__c = 220;
        objIncome.MCFD_WorkSafeBC_Freq__c = 'Annually';
        objIncome.MCFD_WorkSafeBC_Start__c = Date.parse('2/2/2017');
        objIncome.MCFD_Related_Request__c = idRequest;
        objIncome.Contact__c = idContact;
        return objIncome;
    }
    
    public static MCFD_Address__c createMCFDAddress(String strAddressLine1){
        MCFD_Address__c objAddress = new MCFD_Address__c();
        objAddress.MCFD_Address_Line_1__c = strAddressLine1;
        objAddress.MCFD_Address_Line_2__c = 'Name';
        objAddress.MCFD_Address_Line_3__c = 'Name';
        objAddress.MCFD_City__c = 'Test';
        objAddress.MCFD_Country__c = 'Test';
        objAddress.MCFD_Postal_Code__c = 'Q1Q1Q1';
        objAddress.MCFD_Province__c='Test';
        return objAddress;
    } 
    
    public static MCFD_Contact_Address__c createContactAddress(Id idRequest, Id idprimaryContact, String strAddressType,MCFD_Address__c objAddress) {
        MCFD_Contact_Address__c objContactAddress = new MCFD_Contact_Address__c();
        objContactAddress.MCFD_Request__c = idRequest;
        objContactAddress.MCFD_Contact__c = idprimaryContact;
        objContactAddress.MCFD_Address_Type__c = strAddressType;//Home Address/Home Address/Home and Mailing Address
        objContactAddress.MCFD_Address__c = objAddress.id;
        return objContactAddress;
    }
    
    public static Reason_For_Care__c createReasonForCare(Id idprimaryContactId,Id idRequest, String strRsnForCareType){
        Reason_For_Care__c objReasonForCare = new Reason_For_Care__c();
        objReasonForCare.Contact__c = idprimaryContactId;
        objReasonForCare.MCFD_Request__c = idRequest ;
        objReasonForCare.MCFD_Rsn_For_Care_Type__c = strRsnForCareType;
        objReasonForCare.MCFD_Name__c = idRequest + strRsnForCareType;
        if(strRsnForCareType == 'Employment Program'){
            objReasonForCare.You_Participating_in_the_SPEI_del__c = true;
            objReasonForCare.MCFD_When_do_you_work__c = 'Only weekdays, Monday to Friday';
            objReasonForCare.MCFD_Travel_hours__c = '30 minutes to 1 hour per day';
        }
        else if(strRsnForCareType == 'Medical Condition' || strRsnForCareType == 'Business'){
            objReasonForCare.MCFD_When_do_you_work__c = 'Only weekends, Saturdays or Sundays';
        }
        else if(strRsnForCareType == 'Employment'){
            objReasonForCare.MCFD_Travel_hours__c = 'Less than 30 minutes per day';
        }
        else if(strRsnForCareType == 'Self Employment'){
            objReasonForCare.MCFD_Travel_hours__c = 'More than 1 hour per day';
        }
        else{
            objReasonForCare.MCFD_When_do_you_work__c = 'Both weekdays and weekends';
            objReasonForCare.MCFD_Travel_hours__c = 'No travel time';
        }
        objReasonForCare.MCFD_Start_Date__c = Date.parse('1/1/2017');
        objReasonForCare.MCFD_End_Date__c = Date.parse('31/12/2017');
        
        return objReasonForCare;
    }
    
    public static MCFD_Self_Employment_Income__c  createSelfEmploymentIncome(Id idparentIncome){
        MCFD_Self_Employment_Income__c objSelfEmploymentIncome = new MCFD_Self_Employment_Income__c();
        objSelfEmploymentIncome.Name = 'Self';
        objSelfEmploymentIncome.MCFD_Business_Name__c = 'Business Name';
        objSelfEmploymentIncome.Parent_Income_Id__c = idparentIncome;
        objSelfEmploymentIncome.MCFD_Limited_Company__c = 'Yes';
        objSelfEmploymentIncome.MCFD_Net_Income__c = 200;
        objSelfEmploymentIncome.MCFD_New_Business__c = 'Yes';
        objSelfEmploymentIncome.MCFD_Pay_Frequency__c = 'Monthly';
        return objSelfEmploymentIncome;
    }
    
    public static MCFD_Employment_Income__c  createEmploymentIncome(Id idparentIncome){
        MCFD_Employment_Income__c objEmploymentIncome = new MCFD_Employment_Income__c();
        objEmploymentIncome.Name = 'Self';
        objEmploymentIncome.MCFD_Employer_Name__c = 'Emp Name';
        objEmploymentIncome.Parent_Income_Id__c = idparentIncome;
        objEmploymentIncome.MCFD_Amount_Pay_Stub_1__c = 20;
        objEmploymentIncome.MCFD_Amount_Pay_Stub_2__c= 20;
        objEmploymentIncome.MCFD_End_Date__c = System.Today() + 10;
        objEmploymentIncome.MCFD_Hourly_Wage__c = 2;
        objEmploymentIncome.MCFD_No_Two_Pay_Stubs__c = False; 
        objEmploymentIncome.MCFD_Non_Deduct_Amount_Pay_Stub_1__c = 10;
        objEmploymentIncome.MCFD_Non_Deduct_Amount_Pay_Stub_2__c = 10;
        objEmploymentIncome.MCFD_Pay_Frequency__c = 'Every month';
        objEmploymentIncome.MCFD_Start_Date__c = System.Today() - 10;
        return objEmploymentIncome;
    }
    
    public static ContactShare createContactShare(Contact objContact,User objUser){
        ContactShare objContactShare = new ContactShare();
        objContactShare.ContactId=objContact.id;
        objContactShare.UserOrGroupId=objUser.Id;
        objContactShare.ContactAccessLevel='Edit';
        objContactShare.RowCause='PortalImplicit'; 
        ObjContactShare.RowCause = Schema.ContactShare.RowCause.Manual;
        return objContactShare;
    }
    
    public static Income__c getIncome(Id idContact) {
        Income__c obIncomeIncPrim = new Income__c();
        obIncomeIncPrim.Name='Employment Income';
        obIncomeIncPrim.Contact__c = idContact;
        return obIncomeIncPrim;
    }
    
    public static Sub_Request__c createSubReq_PositiveAmtChange(Id reqId){
        Sub_Request__c  subReq = new Sub_Request__c ();        
        subReq.MCFD_Request__c = reqId;
        subReq.Name = 'test';
        subReq.MCFD_Service_Provider_Name__c = 'test';
        subReq.RecordTypeId = [select id from recordtype where developername = 'RTA_Service_Order'].Id;
        subReq.MCFD_Order_Number__c = '1234';
        subReq.MCFD_Current_Authorization__c = 100.00;
        subReq.MCFD_New_Authorization__c = 120.00;
        subReq.MCFD_Amount_Changed__c = 20.00;
        subReq.MCFD_Start_Date__c = system.today();
        subReq.MCFD_Revised_Start_Date__c = system.today() + 1;
        subReq.MCFD_End_Date__c = system.today() + 30;
        subReq.MCFD_Revised_End_Date__c = system.today() + 31;
        subReq.MCFD_RASP__c = 'test';
        subReq.MCFD_Rate_Unit__c = 'Day';
        subReq.MCFD_Rate__c = 50.00;
        subReq.MCFD_Service_Type__c = 'test';    
        subReq.MCFD_Revised_Start_Date_Text__c = '01/01/2017';
        subReq.MCFD_Revised_End_Date_Text__c = '01/01/2017';
        return subReq;
    }
    
    public static Sub_Request__c createSubReq_NegativeAmtChange(Id reqId){
        Sub_Request__c  subReq = new Sub_Request__c ();
        subReq.MCFD_Request__c = reqId;
        subReq.Name = 'test';
        subReq.MCFD_Service_Provider_Name__c = 'test';
        subReq.RecordTypeId = [select id from recordtype where developername = 'RTA_Service_Order'].Id;
        subReq.MCFD_Order_Number__c = '1234';
        subReq.MCFD_Current_Authorization__c = 150.00;
        subReq.MCFD_New_Authorization__c = 100.00;
        subReq.MCFD_Amount_Changed__c = -50.00;
        subReq.MCFD_Start_Date__c = system.today();
        subReq.MCFD_Revised_Start_Date__c = system.today() + 1;
        subReq.MCFD_End_Date__c = system.today() + 30;
        subReq.MCFD_Revised_End_Date__c = system.today() + 31;
        subReq.MCFD_RASP__c = 'test';
        subReq.MCFD_Rate_Unit__c = 'Day';
        subReq.MCFD_Rate__c = 50.00;
        subReq.MCFD_Service_Type__c = 'test';    
        subReq.MCFD_Revised_Start_Date_Text__c = '01/01/2017';
        subReq.MCFD_Revised_End_Date_Text__c = '01/01/2017';
        return subReq;
    }
    
    public static Sub_Sub_Request__c createSubSubReq(Id subreqId, boolean isRevised, String orderNum){
        Sub_Sub_Request__c subsubreq = new Sub_Sub_Request__c ();
        subsubreq.MCFD_Is_Newly_Added__c = 'Yes';
        subsubreq.MCFD_Original_Order_Line__c = orderNum;
        subsubreq.MCFD_Original_Product__c = 'test';
        subsubreq.MCFD_Original_RASP__c = 'test';
        subsubreq.MCFD_Original_Rate__c = 10.00;
        subsubreq.MCFD_Original_Unit__c = '3';
        if(isRevised){
            subsubreq.MCFD_Is_Newly_Added__c = 'No';
            subsubreq.MCFD_Revised_Order_Line__c = orderNum + ' Revised';
            subsubreq.MCFD_Revised_Product__c = 'test 2';
            subsubreq.MCFD_Revised_RASP__c = 'test 2';
            subsubreq.MCFD_Revised_Rate__c = 20.00;
            subsubreq.MCFD_Revised_Unit__c = '2';
        }    
        subsubreq.Sub_Request__c = subreqId;
        return subsubreq;                                                
    }
    
    
    public static Contact createSpouse(){
        Contact spouse = new Contact();
        spouse.FirstName = 'spouse-fn';
        spouse.LastName = 'spouse-ln';
        spouse.Birthdate = Date.parse('10/10/1980');
        spouse.MCFD_Gender__c = 'Male';
        spouse.MCFD_SIN__c = '363533225';
        spouse.MCFD_Govt_Disability_Benefit__c = 'No';
        spouse.MCFD_Marital_Status__c = 'Married, or living in a marriage-like relationship';
        spouse.MCFD_HasActiveCRAConsent__c =false;
        return spouse;
    }
    public static Contact createChild(){
        Contact child = new Contact();
        child.FirstName = 'child-fn';
        child.LastName = 'child-ln';
        child.Birthdate = Date.parse('10/10/2012');
        child.MCFD_Gender__c = 'Male';
        child.MCFD_Special_needs__c = 'Yes';
        child.MCFD_Childcare_Require__c = 'Yes';
        child.MCFD_Licensed_Group_CC__c = true;
        child.MCFD_Child_Placement__c = 'Yes';
        child.MCFD_HasActiveCRAConsent__c =false;
        return child;
    }
}