/**************************************************************************************
Function        : helper class for all test class in creating test data

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                17 APR 2017             Original Version
*************************************************************************************/

@isTest
public class MCFD_TestDataHelper_Test{

    
    // Use below method to get unique username for any test user
    public static String getUniqueTestUsername(){
        return 'User' + Datetime.now().getTime() + Math.random()*100 + '@testMCFDPortal.com';
    }
    
    
    // use below method to get create community test user
     public static User getCommunityUser(){
       Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
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
    public static User getCommunityUser2(String ICMContactId){
       Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
       Account acct = getAccount('BCAccount');
       acct.OwnerId = UserInfo.getUserId();
       insert acct; 
        
       Contact con = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = System.Today(),AccountId = acct.id, MCFD_BCeId__c = '1234567890', ICM_Contact_Id__c = ICMContactId );
       insert con;
       
       User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, ContactId = con.Id, FederationIdentifier = '7C01518C8CBD48ED93C10918BD554312');
              insert objuser;
       return objUser;       
    }
    
    // use below method to get create community test user with userRole
    public static User getCommunityUser(Id userRoleID){
       Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
       Account acct = getAccount('BCAccount');
       acct.OwnerId = UserInfo.getUserId();
       insert acct; 
        
       Contact con = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = Date.parse('10/10/1980'),AccountId = acct.id, MCFD_BCeId__c = '1234567890' );
       insert con;
       
       User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, ContactId = con.Id, UserRoleID = userRoleId,FederationIdentifier = '7C01518C8CBD48ED93C10918BD554321');
              insert objuser;
       return objUser ;       
    }
    
    // use this method to create an inactive user
    public static User getinActiveUser(){
       Profile prof = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
       Account acct = getAccount('BCAccount');
       acct.OwnerId = UserInfo.getUserId();
       insert acct; 
        
       Contact con = new Contact(LastName = 'TestLN2', FirstName ='TestFN1' ,Birthdate = System.Today(),AccountId = acct.id, MCFD_BCeId__c = '123456890' );
       insert con;
       
       User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =false, ContactId = con.Id,  FederationIdentifier = '7C01518C8CBD48ED93C10918BD554321');
              insert objuser;
       return objUser ;       
    }
    
    public static User getAdminUser(){
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', ProfileId = prof.Id, TimeZoneSidKey='America/Los_Angeles',
              UserName=getUniqueTestUsername(), IsActive =true, UserRoleID = r.Id);
             
       insert objuser;
              
        return objUser ;       
    }
    
    // use this method to create an account
    public static Account getAccount(){
      Account accountObj = new Account();
      accountObj.Name = 'Test Account';
      accountObj.AccountNumber = '1000001';
      return accountObj;
    }
    // use this method to create an account and pass account name as a parameter
    public static Account getAccount(String accountName){
      Account accountObj = new Account();
      accountObj.Name = accountName;
      accountObj.AccountNumber = '1000001';
      return accountObj;
    }
    
    // use this method to create contact  
    public static Contact getContact(){
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
    
    public static Contact getContact(Id accId){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.Email = getUniqueTestUsername();
        contactObj.AccountId = accId;
        return contactObj;
    }  
    
   public static MCFD_Relationship__c getRelationship(String ReltnType, Id PrimContId, Id DependantID, Id requestId){
        MCFD_Relationship__c relt =  new MCFD_Relationship__c();   
        relt.MCFD_Parent_Contact__c = PrimContId;
        relt.MCFD_Relationship_Type__c = ReltnType ;
        relt.MCFD_Request__c = requestId;
        relt.MCFD_Child_Contact__c = DependantID;
        return relt;
    } 
    
    public static MCFD_Address__c getMCFD_Address(){
        MCFD_Address__c mcfdAddress = new MCFD_Address__c();
        mcfdAddress.MCFD_Address_Line_1__c = 'Test';
        mcfdAddress.MCFD_Address_Line_2__c = 'Name';
        mcfdAddress.MCFD_Address_Line_3__c = 'Name';
        mcfdAddress.MCFD_City__c = 'Test';
        mcfdAddress.MCFD_Country__c = 'Test';
        mcfdAddress.MCFD_Postal_Code__c = 'Q1Q1Q1';
        return mcfdAddress;
    } 
    
    public static MCFD_Contact_Address__c getContactAddressRelt(Id RequestId, Id primContactId, String AddressType) {
    
        MCFD_Contact_Address__c conadd = new MCFD_Contact_Address__c();
        if(RequestId != null ){
        conadd.MCFD_Request__c = RequestId;
        }
        if(primContactId !=null){
        conadd.MCFD_Contact__c = primContactId;
        }
        conadd.MCFD_Address_Type__c = AddressType;
        MCFD_Address__c addr = new MCFD_Address__c();
        if(AddressType == 'Mailing Address'){
            addr = getMCFD_Address('Test - Address greater than 24 characters');
        }
        else{
            addr = getMCFD_Address();   
        }
        insert addr;
        conadd.MCFD_Address__c = addr.id;
        return conadd;
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
    
    public static MCFD_Attachment__c customAttachment(){
        MCFD_Attachment__c custmAttch = new  MCFD_Attachment__c();
        custmAttch.MCFD_Category__c = 'Others';
        custmAttch.MCFD_Attachment_Name__c = 'TestFileName';
        custmAttch.ICM_Attachment_Id__c = '1-10987';
        custmAttch.MCFD_Status__c = 'Document Uploaded';
        
        insert custmAttch ; 
        return custmAttch;
    }
    
    public static Attachment getFile(Id parentId){
        Attachment file = new Attachment();
        file.parentId = parentId;
        file.Body = EncodingUtil.base64Decode('xyz123abcUVW');
        file.Name = 'testFileName';
        file.ContentType = 'contentType';
        insert file;
        return file;
    }
    
    public static MCFD_Document_Integration_Engine__c getDocIE(Id attachId, Id fileId, Id requestId){
        MCFD_Document_Integration_Engine__c docEngine = new MCFD_Document_Integration_Engine__c();
        docEngine.Parent_Custom_Attachment__c = attachId;
        docEngine.Child_Standard_Attachment__c = fileId;
        docEngine.Integration_Status__c = 'Pending';
        docEngine.Parent_Request__c =   requestId;
        insert docEngine;
        return docEngine;
    }
        
    public static Reason_For_Care__c getrsnFcare(Id primContactId,Id RequestId, String RsnFcareType){
        Reason_For_Care__c rsn = new Reason_For_Care__c();
        if(primContactId != null){
            rsn.Contact__c = primContactId;
        }
        if(RequestId != null){
            rsn.MCFD_Request__c = RequestId ;
        }
        rsn.MCFD_Rsn_For_Care_Type__c = RsnFcareType;
        rsn.MCFD_Name__c = RequestId + RsnFcareType;
        if(RsnFcareType == 'Employment Program'){
            rsn.You_Participating_in_the_SPEI_del__c = true;
            rsn.MCFD_When_do_you_work__c = 'Only weekdays, Monday to Friday';
            rsn.MCFD_Travel_hours__c = '30 minutes to 1 hour per day';
        }
        else if(RsnFcareType == 'Medical Condition' || RsnFcareType == 'Business'){
            rsn.MCFD_When_do_you_work__c = 'Only weekends, Saturdays or Sundays';
        }
        else if(RsnFcareType == 'Employment'){
            rsn.MCFD_Travel_hours__c = 'Less than 30 minutes per day';
        }
        else if(RsnFcareType == 'Self Employment'){
            rsn.MCFD_Travel_hours__c = 'More than 1 hour per day';
        }
        else{
            rsn.MCFD_When_do_you_work__c = 'Both weekdays and weekends';
            rsn.MCFD_Travel_hours__c = 'No travel time';
        }
        rsn.MCFD_Start_Date__c = Date.parse('1/1/2017');
        rsn.MCFD_End_Date__c = Date.parse('31/12/2017');
        
        return rsn;
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
    
    public static Income__c getIncome(){
        Income__c incPrim = new Income__c();
        incPrim.Name='Employment Income';
        return incPrim;
    }
    
    public static Income__c getIncome(Id contactId){
        Income__c incPrim = new Income__c();
        incPrim.Name='Employment Income';
        incPrim.Contact__c = contactId;
        return incPrim;
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

    public static MCFD_Employment_Income__c  getEmploymentIncome(Id parentIncomeId){
        MCFD_Employment_Income__c empInc = new MCFD_Employment_Income__c();
        empInc.Name = 'Self';
        empInc.MCFD_Employer_Name__c = 'Emp Name';
        empInc.Parent_Income_Id__c = parentIncomeId;
        empInc.MCFD_Amount_Pay_Stub_1__c = 20;
        empInc.MCFD_Amount_Pay_Stub_2__c= 20;
        empInc.MCFD_End_Date__c = System.Today() + 10;
        empInc.MCFD_Hourly_Wage__c = 2;
        empInc.MCFD_No_Two_Pay_Stubs__c = False; 
        empInc.MCFD_Non_Deduct_Amount_Pay_Stub_1__c = 10;
        empInc.MCFD_Non_Deduct_Amount_Pay_Stub_2__c = 10;
        empInc.MCFD_Pay_Frequency__c = 'Every month';
        empInc.MCFD_Start_Date__c = System.Today() - 10;

        return empInc;
    }
    
    public static Attachment addAttachmentToParent(Id parentId) {
        Blob b = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        
        insert(attachment);
        return attachment;
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
    public static MCFD_Address__c getMCFD_Address(String addressLine1){
        MCFD_Address__c mcfdAddress = new MCFD_Address__c();
        mcfdAddress.MCFD_Address_Line_1__c = addressLine1;
        mcfdAddress.MCFD_Address_Line_2__c = 'Name';
        mcfdAddress.MCFD_Address_Line_3__c = 'Name';
        mcfdAddress.MCFD_City__c = 'Test';
        mcfdAddress.MCFD_Country__c = 'Test';
        mcfdAddress.MCFD_Postal_Code__c = 'Q1Q1Q1';
        return mcfdAddress;
    } 
    public static Income__c getCCSIncome(Id requestId, Id contactId){
        Income__c income = new Income__c();
        income.MCFD_Employment_Income__c = 'Yes';
        income.MCFD_Self_Employment_Income__c = 'Yes';
        income.MCFD_Band_Assistance__c = 'Yes';
        income.MCFD_Band_Assistance_Amount__c = 100;
        income.MCFD_Band_Assistance_Freq__c = 'Every month';
        
        income.MCFD_BC_Disability_Assistance__c = 'Yes';
        income.MCFD_BC_Disability_Assistance_Amount__c = 200;
        income.MCFD_BC_Disability_Assistance_Freq__c = 'Every week';
        
        income.MCFD_BC_Income_Assistance__c = 'Yes';
        income.MCFD_BC_Income_Assistance_Amount__c = 200;
        income.MCFD_BC_Income_Assistance_Freq__c = 'Every two weeks';
        
        income.MCFD_Federal_Benefits__c = 'Yes';
        income.MCFD_Federal_Benefits_Amount__c = 100;
        income.MCFD_Federal_Benefits_Freq__c = 'Twice a month';
        
        income.MCFD_Federal_Employment_Insurance__c = 'Yes';
        income.MCFD_Federal_Employment_Insurance_Amount__c = 140;
        income.MCFD_Federal_Employment_Insurance_Freq__c = 'Every year';
        income.MCFD_Federal_Employment_Insurance_Start__c = Date.parse('1/1/2017');
        
        income.MCFD_Grants__c = 'Yes';
        income.MCFD_Grants_Amount__c = 250;
        income.MCFD_Grants_Freq__c = '4 Months';
        
        income.MCFD_Dep_Adult_Income__c = 'Yes';
        income.MCFD_Dep_Adult_Income_Amount__c = 120;
        income.MCFD_Dep_Adult_Income_Freq__c = '5 Months';
        
        income.MCFD_Rental_Income__c = 'Yes';
        income.MCFD_Rental_Income_Amount__c = 130;
        income.MCFD_Rental_Income_Freq__c = 'Semi-Annually';
        
        income.MCFD_Interest_Amount__c = 127;
        income.MCFD_Interest_Freq__c = '7 Months';
        income.MCFD_Interest__c = 'Yes';
        
        income.MCFD_Other_Income__c = 'Yes';
        income.MCFD_Other_Income_Amount__c = 298;
        income.MCFD_Other_Income_Freq__c = '8 Months';
        
        income.MCFD_Spousal_Support__c = 'Yes';
        income.MCFD_Spousal_Support_Amount__c = 256;
        income.MCFD_Spousal_Support_Freq__c = '9 Months';
        
        income.MCFD_Tips__c = 'Yes';
        income.MCFD_Tips_Amount__c = 187;
        income.MCFD_Tips_Freq__c = '10 Months';
        
        income.MCFD_Training_Living_Allowance__c = 'Yes';
        income.MCFD_Training_Living_Allowance_Amount__c = 240;
        income.MCFD_Training_Living_Allowance_Freq__c = '11 Months';
        
        income.MCFD_WorkSafeBC__c = 'Yes';
        income.MCFD_WorkSafeBC_Amount__c = 220;
        income.MCFD_WorkSafeBC_Freq__c = 'Annually';
        income.MCFD_WorkSafeBC_Start__c = Date.parse('2/2/2017');

        income.MCFD_Related_Request__c = requestId;
        income.Contact__c = contactId;
        return income;
    }
    public static MCFD_Self_Employment_Income__c  getSelfEmploymentIncome(Id parentIncomeId){
        MCFD_Self_Employment_Income__c empInc = new MCFD_Self_Employment_Income__c();
        empInc.Name = 'Self';
        empInc.MCFD_Business_Name__c = 'Business Name';
        empInc.Parent_Income_Id__c = parentIncomeId;
        empInc.MCFD_Limited_Company__c = 'Yes';
        empInc.MCFD_Net_Income__c = 200;
        empInc.MCFD_New_Business__c = 'Yes';
        empInc.MCFD_Pay_Frequency__c = 'Monthly';

        return empInc;
    }
    public static Request__c getCCSRequest(){
        // Creation of user context
        User runAsUser = MCFD_TestDataHelper_Test.getCommunityUser();
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
    public static Request__c getAccessRequest(String recordType, Id contID){
        // Creation of user context
        //User runAsUser = getCommunityUser();
        // Creation of a ccs request
        Request__c request = new Request__c(); 
        RecordType rt = new RecordType();
        rt = [select Id from RecordType where sObjectType = 'Request__c' and Name =: recordType];
        request.RecordTypeId = rt.Id;
        request.ICM_SR_Number__c = '1-12345678';
        request.Primary_Applicant__c = contID;
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
        return request;
    }
}