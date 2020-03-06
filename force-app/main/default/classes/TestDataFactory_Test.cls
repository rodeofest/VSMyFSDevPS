/*********************************************************************************************************
Name            : TestDataFactory_Test.cls  
Description     : TBA  
Created By      : Deloitte ARDC
Created Date    : 04/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Team Mex ARDC  04/May/2018  
--------------------------------------------------------------------------------------------------------------            
***************************************************************************************************************/

public class TestDataFactory_Test {
     public static final Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User'];
    //ChangePasswordControllerTest.apxc
    public static ChangePasswordController testChangePasswordController(String oldPassword, String newPassword, String verifyNewPassword) {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = oldPassword;
        controller.newPassword = newPassword; 
        controller.verifyNewPassword = verifyNewPassword; 
        
        return controller;
    }
   
    //CommunitiesSelfRegController.apxc
    public static CommunitiesSelfRegController testCommunitiesSelfRegController(String firstName, String lastName, String email, String communityNickname, String password, String confirmPassword) {
    // Instantiate a new controller with all parameters in the page
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = firstName;
        controller.lastName = lastName;
        controller.email = email;
        controller.communityNickname = communityNickname;
        controller.password = password;
        controller.confirmPassword = confirmPassword;
        
        return controller;
    }
    
    
    //MCFD_Attachment_XML
    //This method is for fill docEngine
     public static MCFD_Document_Integration_Engine__c getDocIE(Id attachId, Id fileId, Id requestId, String IntStatus){
        MCFD_Document_Integration_Engine__c docEngine = new MCFD_Document_Integration_Engine__c(
            Parent_Custom_Attachment__c = attachId,
            Child_Standard_Attachment__c = fileId,
            Integration_Status__c = IntStatus,
            Parent_Request__c =   requestId,
            Integration_Operation__c ='Upload');
        return docEngine;
    }
    
    public static Attachment getFile(Id parentId){
        Attachment file = new Attachment();
        file.parentId = parentId;
        file.Body = EncodingUtil.base64Decode('xyz123abcUVW');
        file.Name = 'testFileName';
        file.ContentType = 'contentType';
        
        return file;
    }
    
    public static Request__c getCCSRequest(User contactId){
        Request__c request = new Request__c();
        RecordType rt = new RecordType();
        rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Application'];
        request.RecordTypeId = rt.Id;
        request.ICM_SR_Number__c = '1-12345678';
        return request;
    }
    public static MCFD_Attachment__c customAttachment(Request__c objRequest){
        MCFD_Attachment__c custmAttch = new  MCFD_Attachment__c();
        custmAttch.MCFD_Last_Modified_Date__c = System.Now();
        custmAttch.MCFD_Attachment_Name__c = 'Document Checklist';
        custmAttch.MCFD_Type__c = 'Document Checklist';
        custmAttch.MCFD_Category__c = 'Others';
        custmAttch.MCFD_Attachment_Name__c = 'TestFileName';
        custmAttch.ICM_Attachment_Id__c = '1-10987';
        custmAttch.MCFD_Status__c = 'Document Uploaded';
        custmAttch.MCFD_Request_Id__c = objRequest.Id;
        return custmAttch;
    }
    public static Account getAccount(String accountName){
      Account accountObj = new Account();
      accountObj.Name = accountName;
      accountObj.AccountNumber = '1000001';
      accountObj.OwnerId = UserInfo.getUserId();
      return accountObj;
    }
    
    public static Contact getContact(String lastName, Id accountId){
        return new Contact(lastName = lastName, FirstName ='TestFN1',Birthdate = Date.parse('10/10/1980'), AccountId = accountId, MCFD_BCeId__c = '1234567890');
    }
    
    public static User getUser(Contact objCont){
        return new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, ContactId = objCont.Id,
			  FederationIdentifier = '7C01518C8CBD48ED93C10918BD554322');
    }
    public static String getUniqueTestUsername(){
        return 'User' + Datetime.now().getTime() + Math.random()*100 + '@testMCFDPortal.com';
    }
    
    // use below method to get create community test user
     public static User getCommunityUser(String ICMContactId){
       Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
       Account acct = getAccount('BCAccount');
       acct.OwnerId = UserInfo.getUserId();
       insert acct; 
        
       Contact con = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = System.Today(),AccountId = acct.id, MCFD_BCeId__c = '1234567890', ICM_Contact_Id__c = ICMContactId );
       insert con;
       
       User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, ContactId = con.Id, FederationIdentifier = '7C01518C8CBD48ED93C10918BD554321');
              insert objuser;
       return objUser;       
    }
     public static MCFD_Portal_Settings__c getMCFD_Portal_Settings(String commProf, String portalAccName){
        MCFD_Portal_Settings__c setting = new MCFD_Portal_Settings__c();        
        setting.Name = 'test data';
        setting.MCFD_Community_Profile_Name__c = commProf;
        setting.MCFD_Portal_Account_Name__c = portalAccName;    
        setting.MCFD_Portal_Nickname_Format__c = 'mcfdportaluserX';
        setting.MCFD_Portal_Username_Format__c = 'mcfdportaluserX@mcfdportal.com';
        setting.MCFD_Community_URL__c = 'https://dev-mcfd-portal.cs71.force.com';
        setting.Portal_Error_Page_URL__c = 'https://dev-mcfd-portal.cs71.force.com/s/message';
        setting.Portal_Landing_Page_url__c = 'https://dev-mcfd-portal.cs71.force.com/s/portal-landing-page';
        setting.Portal_Registration_Page_URL__c = 'https://dev-mcfd-portal.cs71.force.com/s/registration';
        setting.MCFD_Portal_Account_Owner_ID__c = '12345';
       	setting.System_Maintenance_URL__c ='192.168.10.2';
        return setting;
    }

    public static MCFD_Portal_SSO_Redirection__c getMCFD_Portal_SSO_Redirection(){
        MCFD_Portal_SSO_Redirection__c setting = new MCFD_Portal_SSO_Redirection__c();        
        setting.Name = 'test data';
        setting.Internal_User_URL__c = 'https://login.salesforce.com';
        setting.External_User_URL__c = 'https://dev-mcfd-portal.cs71.force.com';    
        setting.SiteMinder_Login_URL__c = 'http://axiomsso.herokuapp.com/RequestSamlResponse.action';
        setting.BCeID_Attribute_Name__c = 'BCEID';
        setting.Email_Attribute_Name__c = 'EMAIL';
        setting.Federation_Identifier_Attribute_Name__c = 'useridentifier'; 
        setting.First_Name_Attribute_Name__c = 'GIVENNAME';
        setting.Middle_Name_Attribute_Name__c = 'SECONDNAME';
        setting.Last_Name_Attribute_Name__c = 'SURNAME';
        setting.IsIDIR_Attribute_Name__c = 'ISIDIR';
        setting.BCeID_Type_Attribute_Name__c = 'TestAttr';
        return setting;
    }
    // use below method to get create community test user 
     public static User getCommunityUser(Profile objProf){
       Profile prof = [SELECT Id FROM Profile WHERE Name =:objProf.Name]; 
       Account acct = getAccount('BCAccount');
       acct.OwnerId = UserInfo.getUserId();
       insert acct; 
        
       Contact con = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = System.Today(),AccountId = acct.id, MCFD_BCeId__c = '1234567890' );
       insert con;
       
       User objUser = new User(Alias = 'standt', Email=getUniqueTestUsername(), 
              EmailEncodingKey='UTF-8', FirstName='Testing', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, ContactId = con.Id, FederationIdentifier = '7C01518C8CBD48ED93C10918BD554321');
              insert objuser;
       return objUser ;       
    }
    
    public static Request__c getRequest(String recordType){
        Request__c request = new Request__c();
        RecordType rt = new RecordType();
        if(recordType != ''){
            rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = :recordType];
            request.RecordTypeId = rt.Id;
        }
        insert request;
        return request;
    }
    public static Account getAccount(){
      Account accountObj = new Account();
      accountObj.Name = 'Test Account';
      accountObj.AccountNumber = '1000001';
      return accountObj;
    }
    public static Contact getUniqueContact(){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.Birthdate = Date.parse('10/10/1990');
        contactObj.Email = getUniqueTestUsername();
        Account acc = getAccount();
        insert acc;
        contactObj.AccountId = acc.id;
        return contactObj;
    }  
    
    public static Request__c getCCSRequest(Id ContactId){
        Request__c request = new Request__c();
        RecordType rt = new RecordType();
        rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Application'];
        request.RecordTypeId = rt.Id;
        request.ICM_SR_Number__c = '1-12345678';
        insert request;
        return request;
    }
    public static MCFD_Relationship__c getRelationship(String ReltnType, Id PrimContId, Id DependantID, Id requestId){
        MCFD_Relationship__c relt =  new MCFD_Relationship__c();   
        relt.MCFD_Parent_Contact__c = PrimContId;
        relt.MCFD_Relationship_Type__c = ReltnType ;
        relt.MCFD_Request__c = requestId;
        relt.MCFD_Child_Contact__c = DependantID;
        return relt;
    } 
   public static Contact getCCSSpouse(){
        Contact spouse = new Contact();
        spouse.FirstName = 'spouse-fn';
        spouse.LastName = 'spouse-ln';
        spouse.Birthdate = Date.parse('10/10/1982');
        spouse.MCFD_Gender__c = 'Male';
        spouse.MCFD_SIN__c = '363533225';
        spouse.MCFD_Govt_Disability_Benefit__c = 'No';
        insert spouse;
        return spouse;
    }
    public static Contact getCCSChild(){
        Contact child = new Contact();
        child.FirstName = 'child-fn';
        child.LastName = 'child-ln';
        child.Birthdate = Date.parse('10/10/2012');
        child.MCFD_Gender__c = 'Male';
        child.MCFD_Special_needs__c = 'Yes';
        child.MCFD_Childcare_Require__c = 'Yes';
        child.MCFD_Licensed_Group_CC__c = true;
        child.MCFD_Child_Placement__c = 'Yes';
        insert child;
        return child;
    }
    
     public static Request__c getCCSRequest2(){
        // Creation of user context
        Profile profileRec = [SELECT Id, Name  FROM Profile WHERE Name='System Administrator'];
        User runAsUser = TestDataFactory_Test.getCommunityUser(profileRec);
                // Creation of a ccs request
        Request__c request = new Request__c(); 
        RecordType rt = new RecordType();
        rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Application'];
        request.RecordTypeId = rt.Id;
        request.ICM_SR_Number__c = '1-12345678';
        request.Primary_Applicant__c = runAsUser.ContactId;
        request.MCFD_consent_to_share_info_with_spouse__c = true;
        request.MCFD_consent_share_info_with_sp_signed__c = 'Consent signed';
        request.MCFD_spousal_consent_signed_date__c = '11/11/2017';
        request.MCFD_spousal_consent_check1__c = true;
        request.MCFD_spousal_consent_check2__c = true;
        request.MCFD_DeclarationAndConsent__c = true;
        request.MCFD_declaration_and_consent_signed_date__c = 'Consent signed';
        insert request;
        request = [Select id, CreatedBy.Id, CreatedBy.Name, Name, MCFD_Service_Provider_Name__c, MCFD_declaration_and_consent_signed_date__c, MCFD_Type__c, 
                   MCFD_DeclarationAndConsent__c, MCFD_spousal_consent_signed_date__c, MCFD_consent_share_info_with_sp_signed__c,
                   MCFD_consent_to_share_info_with_spouse__c, MCFD_Contact__c, ICM_SR_Number__c, MCFD_spousal_consent_check1__c, MCFD_spousal_consent_check2__c, 
                   Primary_Applicant__c, Primary_Applicant__r.Name from Request__c where Id =: request.id];

        // Adding Contact information - updating applicant
        Contact applicant = [Select Id, MCFD_BCeID__c, FirstName, MiddleName, LastName, Birthdate, MCFD_Gender__c, MCFD_SIN__c, MCFD_Marital_Status__c, 
                             MCFD_Reason_for_no_SIN__c, MCFD_Is_SW_Referred__c, MCFD_SIN_Expiry_Date__c, MCFD_Govt_Disability_Benefit__c, 
                             Phone, MobilePhone,Email, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c ,MCFD_Address_Check__c, Send_ICM_Contact_ID__c, ICM_Contact_Id__c
                             from Contact where id =:request.Primary_Applicant__c]; 
        applicant.MCFD_Gender__c = 'Female';
        applicant.MCFD_SIN__c = '451066831';
        applicant.MCFD_Marital_Status__c = 'Married, or living in a marriage-like relationship';
        applicant.MCFD_Is_SW_Referred__c = 'No';
        applicant.MCFD_Govt_Disability_Benefit__c = 'No';
        applicant.Phone = '2508009999';
        applicant.MobilePhone = '2501112222';
        applicant.Email = 'standarduser@testorg.com';
        applicant.MCFD_Primary_Phone_Number_Type__c = 'Home';
        applicant.MCFD_Secondary_Phone_Number_Type__c = 'Cell';
        applicant.MCFD_Address_Check__c = 'No';
        upsert applicant;
        
        // Spouse information
        Contact spouse =  MCFD_TestDataHelper_Test.getCCSSpouse();   
        Contact child = MCFD_TestDataHelper_Test.getCCSChild(); 
        
        // Creating the relationships between family members
        List<MCFD_Relationship__c > reltList = new List<MCFD_Relationship__c >();
        MCFD_Relationship__c reltSpouse =  MCFD_TestDataHelper_Test.getRelationship('Spouse' , applicant.id, spouse.id, request.id);
        MCFD_Relationship__c reltDependant =  MCFD_TestDataHelper_Test.getRelationship('Dependant' , applicant.id, child.id, request.id);
        reltList.add(reltSpouse);
        reltList.add(reltDependant);
        insert reltList;
        
        // Creating the mailing and home address
        List<MCFD_Contact_Address__c> conAddList = new List<MCFD_Contact_Address__c>();
        MCFD_Contact_Address__c conaddHome = MCFD_TestDataHelper_Test.getContactAddressRelt(request.id, applicant.id, 'Home Address');
        conAddList.add(conaddHome);
        MCFD_Contact_Address__c conaddMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(request.id, applicant.id, 'Mailing Address');
        conAddList.add(conaddMailing);
        MCFD_Contact_Address__c conaddHomeNMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(request.id, applicant.id, 'Home and Mailing Address');
        conAddList.add(conaddHomeNMailing);
        insert conAddList;  
        
        // Creating the RFCs for applicant and spouse
        List<Reason_For_Care__c> listRFC = new List<Reason_For_Care__c>();
        Reason_For_Care__c applicantEmployment = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, request.Id, 'Employment');
        Reason_For_Care__c applicantEmployer = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, request.Id, 'Employer');
        Reason_For_Care__c applicantSelfEmployment = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, request.Id, 'Self Employment');
        Reason_For_Care__c applicantBusiness = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, request.Id, 'Business');
        Reason_For_Care__c spouseMedicalInfo = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, request.Id, 'Medical Condition');
        Reason_For_Care__c spouseLookingforWork = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, request.Id, 'Looking for Work');
        Reason_For_Care__c spouseEmpProg = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, request.Id, 'Employment Program');
        Reason_For_Care__c spouseSchool = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, request.Id, 'Attending School');
        listRFC.add(applicantEmployment);
        listRFC.add(applicantEmployer);
        listRFC.add(applicantSelfEmployment);
        listRFC.add(applicantBusiness);
        listRFC.add(spouseMedicalInfo);
        listRFC.add(spouseLookingforWork);
        listRFC.add(spouseEmpProg);
        listRFC.add(spouseSchool);
        insert listRFC; 
        
        List<Income__c> listIncomes = new List<Income__c>();
        Income__c applicantIncome = MCFD_TestDataHelper_Test.getCCSIncome(request.Id, applicant.Id);
        Income__c spouseIncome = MCFD_TestDataHelper_Test.getCCSIncome(request.Id, spouse.Id);
        listIncomes.add(applicantIncome);
        listIncomes.add(spouseIncome);
        insert listIncomes;
        
        List<MCFD_Employment_Income__c> listEmpIncomes = new List<MCFD_Employment_Income__c>();
        MCFD_Employment_Income__c applicantEmpIncome = MCFD_TestDataHelper_Test.getEmploymentIncome(applicantIncome.Id);
        MCFD_Employment_Income__c spouseEmpIncome = MCFD_TestDataHelper_Test.getEmploymentIncome(spouseIncome.Id);
        listEmpIncomes.add(applicantEmpIncome);
        listEmpIncomes.add(spouseEmpIncome);
        insert listEmpIncomes;
        
        List<MCFD_Self_Employment_Income__c> listSelfEmpIncomes = new List<MCFD_Self_Employment_Income__c>();
        MCFD_Self_Employment_Income__c applicantSelfEmpIncome = MCFD_TestDataHelper_Test.getSelfEmploymentIncome(applicantIncome.Id);
        MCFD_Self_Employment_Income__c spouseSelfEmpIncome = MCFD_TestDataHelper_Test.getSelfEmploymentIncome(spouseIncome.Id);
        listSelfEmpIncomes.add(applicantSelfEmpIncome);
        listSelfEmpIncomes.add(spouseSelfEmpIncome);
        insert listSelfEmpIncomes;
        return request;
    }
    
    public static List<MCFD_Message__c> messageCreator (Integer howManyMessages){
        //Create a list of messages
        List<MCFD_Message__c> messageList = New List<MCFD_Message__c>();
		for(Integer i=0; i<howManyMessages; i++){
		MCFD_Message__c message = new MCFD_Message__c();
        message.ICM_Case_Id__c = 'AF510'+i;
		message.Message_Status__c = 'Sent to ICM'; //'Reply to ICM'
        message.ICM_Contact_Id__c =  'IdCont'+i;
		message.ICM_SR_Id__c= 'IdSR Test'+i;
        message.Message_Subject__c = 'Subject Test'+i;
        message.ICM_Program_Type__c = 'Autism Funding'; //Child Care Subsidy
		messageList.add(message);	
	}
	return messageList;
    }
    
}