/*
Description       :   Controller apex class for the CCS application
Created By        :   Deloitte
Modification Log  :
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Developer         Date                Description
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -          
Vai               Mar 28 2017        Created 
Pavan             May 24 2017        Adding save logic for multiple screens (Primary Applicant & Spouse related screens)
Pavan             May 25 2017        Bug Fix - 3510: A reason for care record is created with type = "Referral" 
Vai               June 12 2017       Implement the spouse / dependent deletion scenario along with child objects
Vai               June 13 2017       Implement the RFC / Income deletion along with child for placements + handling preschool scenario
Vai               June 14 2017       Implement the attachments / file deletion scenario and sync them with ICM
Pavan             Jul 14 2017        Bug fix : 2744 - Calling CreateSR before any DML so it can be non-future method
PDAVE             Sep 04, 2017       Bug Fix 4743 : Addding new method just to save (not submit) application on Submit Application page. 
PDAVE             Sep 21, 2017       Fix - Address not populating in request XML (Swapped the mailing address with home address in upsert_MCFD_PrimaryApplicantPI method)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -            
*/

public without sharing class MCFD_CCSApplication {
    
    
     public static Id userID;
     public static ID PrimID;
     public static List<sobject> sobjectList = new List<sobject>();
     public static Id RequestIdNo;
     public static Boolean itsSpouse = True;

    //ASHAIKH - April 2017 - adding code for US 1161 to update request created with ICM SR Number
   /* @future(callout=true)
    public static void CreateSR(Id RequestId)
    {
        Request__c request = [select Id, ICM_SR_Number__c from Request__c where Id =: RequestId Limit 1];       
        
        if(request.ICM_SR_Number__c == null || request.ICM_SR_Number__c == '')
            {
                
                List<User> ContactDetails = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c from user where id =:UserInfo.getUserId() limit 1];
                
                String JSONString = '{'+
                                    '"Operation": "Insert",'+
                                    '"SRType" : "Child Care Subsidy",'+
                                    '"SRSubType" : "Application",'+
                                    '"Priority" : "3-Standard",'+
                                    '"Status" : "Open",'+
                                    '"AssignedTeam" : "Admin Support",'+
                                    '"ContMethod" : "Client Portal",'+
                                    '"SvcOff" : "XWB - Child Care Programs and Services Branch",'+
                                    '"Organization" : "MCFD",'+
                                    '"CreatedBy" : "CFDGENUSR",'+
                                    '"Created" : "",'+
                                    '"Memo" : "",'+
                                    '"ICMBCeIDUserName" : "'+ContactDetails[0].Contact.MCFD_BCeID__c+'",'+
                                    '"ICMGUID" : "'+ContactDetails[0].Contact.MCFD_GUID__c+'"'+
                                    '}';

                
                System.debug('Calling submit');
                String returnJSON = '';
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:CallWMToSubmitRTP');
                req.setTimeout(60000);
                req.setMethod('POST');
                req.setHeader('Connection','keep-alive');
                req.setHeader('Content-Type', 'application/json');
                
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject(); 
                gen.writeStringField('Name', JSONString);
                gen.writeEndObject();
                
                req.setBody(gen.getAsString());
                System.debug(req.getBody()); 
                System.debug(req);
                
                Http http = new Http();
                try 
                {
                    HTTPResponse res = http.send(req);
                    returnJSON = res.getBody();
                    System.debug('Response'+res.toString());
                    System.debug('STATUS:'+res.getStatus());
                    System.debug('STATUS_CODE:'+res.getStatusCode());
                    System.debug(returnJSON);
                    
                    if(res.getStatusCode()==200)
                    {
                        JSONParser parser = JSON.createParser(res.getBody());
                        String SRNumber = '';
                        while (parser.nextToken() != null) 
                        {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                            {
                                // Get the value.
                                parser.nextToken();
                                // Compute the grand total price for all invoices.
                                SRNumber = parser.getText();
                            }
                        }
                        system.debug('SRNumber=' + SRNumber);
                        request.ICM_SR_Number__c = SRNumber;
                        request.MCFD_Status__c = 'In Progress';
                        update request;  
                    }
                } 
                catch(System.CalloutException e) 
                {
                MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
                }     
                
            }
            else
            {
                //return '{"ErrorMessage":"SR exists"}';        
                System.debug('SR Exists');
            }
            
            
            
        
    }*/
    
    // PDAVE - BUG 2744 - web service has to be synchronous in order to show spinner during the web service call
     @AuraEnabled
     public static String CreateSR(String recordType){
            String ICMSRNum = '';
            List<User> ContactDetails = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c from user where id =:UserInfo.getUserId() limit 1];
            
            if (recordType == 'Renewal')
                recordType = 'Renewal';
            else
                recordType = 'Application';

            String JSONString = '{'+
                                '"Operation": "Insert",'+
                                '"SRType" : "Child Care Subsidy",'+
                                '"SRSubType" : "'+ recordType +'",'+
                                '"Priority" : "3-Standard",'+
                                '"Status" : "Open",'+
                                '"AssignedTeam" : "Admin Support",'+
                                '"ContMethod" : "Client Portal",'+
                                '"SvcOff" : "XWB - Child Care Programs and Services Branch",'+
                                '"Organization" : "MCFD",'+
                                '"CreatedBy" : "CFDGENUSR",'+
                                '"Created" : "",'+
                                '"Memo" : "",'+
                                '"ICMBCeIDUserName" : "'+ContactDetails[0].Contact.MCFD_BCeID__c+'",'+
                                '"ICMGUID" : "'+ContactDetails[0].Contact.MCFD_GUID__c+'"'+
                                '}';
            
            System.debug('Calling submit');
            String returnJSON = '';
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMToSubmitRTP');
            //req.setTimeout(60000);
            req.setTimeout(Integer.valueOf(System.Label.CCS_Shell_SR_Timeout));
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('Name', JSONString);
            gen.writeEndObject();
            
            req.setBody(gen.getAsString());
            System.debug(req.getBody()); 
            System.debug(req);
            
            Http http = new Http();
            try{
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                System.debug('Response'+res.toString());
                System.debug('STATUS:'+res.getStatus());
                System.debug('STATUS_CODE:'+res.getStatusCode());
                System.debug(returnJSON);
                
                if(res.getStatusCode()==200)
                {
                    JSONParser parser = JSON.createParser(res.getBody());
                    
                    while (parser.nextToken() != null) 
                    {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                        {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            ICMSRNum = parser.getText();
                        }
                    }
                    system.debug('ICMSRNum=' + ICMSRNum);
                    
                }
                if(ICMSRNum == ''){
                    MCFD_Logger.log_integration_error('Shell SR Creation - CCS Application', 
                                                       MCFD_Logger.error, 
                                                       'MCFD_CallICMForAutismDetails', 
                                                       'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());
                }
            } 
            catch(System.CalloutException e){
                MCFD_Logger.log_integration_error('Shell SR Creation - CCS Application', MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }     
     
            return ICMSRNum;        
    }
    
     @AuraEnabled
     public static void utilityMethod1() {
     userID = UserInfo.getUserId();
     PrimID = [select Contactid, FirstName,MiddleName, LastName from user where id =: userID  Limit 1].ContactID;
     }
     
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper getCCSApplicationInfo(Id requestId){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        // List of SOQL attributes to fetch data
        Request__c request = new Request__c();
        List<MCFD_Relationship__c> relContactList = new List<MCFD_Relationship__c>();
        List<Contact> parentContactList = new List<Contact>();
        List<MCFD_Contact_Address__c> conAddressList = new List<MCFD_Contact_Address__c>();
        List<Reason_For_Care__c> rfcList = new List<Reason_For_Care__c>();
        List<Income__c> incomeList = new List<Income__c>();
        List<MCFD_Employment_Income__c> empIncomeList = new List<MCFD_Employment_Income__c>();
        List<MCFD_Self_Employment_Income__c> selfEmpIncomeList = new List<MCFD_Self_Employment_Income__c>();
        List<MCFD_Attachment__c> uploadList = new List<MCFD_Attachment__c>();
        Integer depIndex = 0;
        // List of attributes to map to UI elements
        Contact primaryApplicant = new Contact();
        Contact applicantSpouse = new Contact();
        // Applicant attributes
        List<Contact> depList = new List<Contact>();
        MCFD_Address__c addressHome = new MCFD_Address__c();
        MCFD_Address__c addressMail = new MCFD_Address__c();
        Reason_For_Care__c employmentInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> paRFCEmployerList = new List<Reason_For_Care__c>();
        Reason_For_Care__c selfEmploymentInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> paRFCBusinessList = new List<Reason_For_Care__c>();
        Reason_For_Care__c schoolSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c empProgSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c lookingWorkScrn1 = new Reason_For_Care__c();
        Reason_For_Care__c medicalCondInfo = new Reason_For_Care__c();
        Income__c paIncome = new Income__c();
        List<MCFD_Employment_Income__c> paEmpIncomeList = new List<MCFD_Employment_Income__c>();
        List<MCFD_Self_Employment_Income__c> paSelfEmpIncomeList = new List<MCFD_Self_Employment_Income__c>();
        // Spouse attributes
        Reason_For_Care__c spouseEmpInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> spouseRFCEmployerList = new List<Reason_For_Care__c>();
        Reason_For_Care__c spouseSelfEmpInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> spouseRFCBusinessList = new List<Reason_For_Care__c>();
        Reason_For_Care__c spouseSchoolSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c spouseRFCEmpPrgSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c spouseLookingWrkScrn1 = new Reason_For_Care__c();
        Reason_For_Care__c spouseMedclCondInfo = new Reason_For_Care__c();
        Income__c spouseIncome = new Income__c();
        List<MCFD_Employment_Income__c> spouseEmpIncomeList = new List<MCFD_Employment_Income__c>();
        List<MCFD_Self_Employment_Income__c> spouseSelfEmpIncomeList = new List<MCFD_Self_Employment_Income__c>();
        
        try{
            // Query for each object type and prepare the overall list
            request = [select Id,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c, MCFD_CCS_Spouse_NoTaxFilingReason__c, Primary_Applicant__c, Incomplete_Pages__c, MCFD_Status__c, MCFD_spousal_consent_signed_date__c, spouse__c,
                       MCFD_spousal_consent_check2__c, MCFD_spousal_consent_check1__c, ICM_SR_Number__c, MCFD_declaration_and_consent_signed_date__c,
                       MCFD_consent_share_info_with_sp_signed__c, MCFD_consent_to_share_info_with_spouse__c, MCFD_DeclarationAndConsent__c,
                       MCFD_confirm_application__c, MCFD_Navigation_JSON__c, Has_Ans_Consent_to_Share_Info_With_S__c, RecordType.Name,MCFD_CRA_Consent_Signed_Date__c,
                       MCFD_CRA_Consent__c,MCFD_Spouse_CRA_Consent_Signed_Date__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,MCFD_Spousal_CRA_Consent__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c,MCFD_CCS_IncomeChanged__c, MCFD_CCS_IncomeIncreasedOrDecreased__c, MCFD_CCS_SpouseIncomeChanged__c, MCFD_CCS_SpouseIncomeIncreasedDecreased__c,MCFD_hasRFC__C
                       from Request__c where Id = :requestId];
            primaryApplicant = [select Id, MCFD_HasActiveCRAConsent__c, Birthdate, Email, Phone, MobilePhone, LastName, FirstName, MiddleName, MCFD_Attending_School_Add_Instruction__c, 
                                MCFD_Currently_Employed_Additional_Info__c, MCFD_Currently_Self_Employed_Addtn_Info__c, MCFD_Custody_Details__c, MCFD_Childcare_Require__c, 
                                MCFD_Govt_Disability_Benefit__c,MCFD_Employment_Prog_Add_Instruction__c, MCFD_Gender__c, MCFD_Attending_School__c, MCFD_Currently_Employed__c, 
                                MCFD_Looking_For_Work__c, MCFD_Self_Employed__c, MCFD_Employment_Prog__c, MCFD_Medical_Condition__c, MCFD_In_Childs_Own_Home__c, MCFD_Special_needs__c,
                                MCFD_Child_Placement__c, MCFD_Is_Custody_Shared__c, MCFD_Address_Check__c, MCFD_Licensed_Family_CC__c, MCFD_Licensed_Group_CC__c, MCFD_Licensed_Preschool__c,
                                MCFD_Lic_Not_Reqrd__c, MCFD_Looking_For_Work_Add_Instruction__c, MCFD_Marital_Status__c, MCFD_Reason_for_no_SIN__c, MCFD_Medical_Condition_Add_Instruction__c,
                                MCFD_No_SIN_Reason__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Provide_SIN__c, MCFD_Reg_Lic_Not_Req__c, MCFD_Same_Custody_Details__c, 
                                MCFD_Secondary_Phone_Number_Type__c, MCFD_SIN_Expiry_Date__c, MCFD_SIN__c, MCFD_Is_SW_Referred__c, SIN_Read_Only__c
                                from Contact where Id = :request.Primary_Applicant__c];
            relContactList = [select MCFD_Child_Contact__r.ICM_SpecialNeedsStatus__c, MCFD_Child_Contact__r.MCFD_HasActiveCRAConsent__c,MCFD_Relationship_Type__c, MCFD_Child_Contact__r.Id, MCFD_Child_Contact__r.Birthdate, MCFD_Child_Contact__r.Email, MCFD_Child_Contact__r.NeedIDForRenewal__c, MCFD_Child_Contact__r.Phone, MCFD_Child_Contact__r.MobilePhone, MCFD_Child_Contact__r.LastName, MCFD_Child_Contact__r.FirstName, MCFD_Child_Contact__r.MiddleName, MCFD_Child_Contact__r.MCFD_Attending_School_Add_Instruction__c, 
                              MCFD_Child_Contact__r.MCFD_Currently_Employed_Additional_Info__c, MCFD_Child_Contact__r.MCFD_Currently_Self_Employed_Addtn_Info__c, MCFD_Child_Contact__r.MCFD_Custody_Details__c, MCFD_Child_Contact__r.MCFD_Childcare_Require__c, 
                              MCFD_Child_Contact__r.MCFD_Govt_Disability_Benefit__c,MCFD_Child_Contact__r.MCFD_Employment_Prog_Add_Instruction__c, MCFD_Child_Contact__r.MCFD_Gender__c, MCFD_Child_Contact__r.MCFD_Attending_School__c, MCFD_Child_Contact__r.MCFD_Currently_Employed__c, 
                              MCFD_Child_Contact__r.MCFD_Looking_For_Work__c, MCFD_Child_Contact__r.MCFD_Self_Employed__c, MCFD_Child_Contact__r.MCFD_Employment_Prog__c, MCFD_Child_Contact__r.MCFD_Medical_Condition__c, MCFD_Child_Contact__r.MCFD_In_Childs_Own_Home__c, MCFD_Child_Contact__r.MCFD_Special_needs__c,
                              MCFD_Child_Contact__r.MCFD_Child_Placement__c, MCFD_Child_Contact__r.MCFD_Is_Custody_Shared__c, MCFD_Child_Contact__r.MCFD_Address_Check__c, MCFD_Child_Contact__r.MCFD_Licensed_Family_CC__c, MCFD_Child_Contact__r.MCFD_Licensed_Group_CC__c, MCFD_Child_Contact__r.MCFD_Licensed_Preschool__c,
                              MCFD_Child_Contact__r.MCFD_Lic_Not_Reqrd__c, MCFD_Child_Contact__r.MCFD_Looking_For_Work_Add_Instruction__c, MCFD_Child_Contact__r.MCFD_Marital_Status__c, MCFD_Child_Contact__r.MCFD_Reason_for_no_SIN__c, MCFD_Child_Contact__r.MCFD_Medical_Condition_Add_Instruction__c,
                              MCFD_Child_Contact__r.MCFD_No_SIN_Reason__c, MCFD_Child_Contact__r.MCFD_Primary_Phone_Number_Type__c, MCFD_Child_Contact__r.MCFD_Provide_SIN__c, MCFD_Child_Contact__r.MCFD_Reg_Lic_Not_Req__c, MCFD_Child_Contact__r.MCFD_Same_Custody_Details__c, 
                              MCFD_Child_Contact__r.MCFD_Secondary_Phone_Number_Type__c, MCFD_Child_Contact__r.MCFD_SIN_Expiry_Date__c, MCFD_Child_Contact__r.MCFD_SIN__c, MCFD_Child_Contact__r.MCFD_Changed__c
                              from MCFD_Relationship__c 
                              where MCFD_Parent_Contact__c = :request.Primary_Applicant__c AND MCFD_Request__c = :requestId
                              ORDER BY Id];
                              //Fixing bug 5875
                              //ORDER BY MCFD_Dependant_Number__c ASC NULLS LAST];
            
            conAddressList = [select MCFD_Address_Type__c, MCFD_Request__c, MCFD_Address__r.Id, MCFD_Address__r.MCFD_Address_Line_1__c, MCFD_Address__r.MCFD_Address_Line_2__c, 
                              MCFD_Address__r.MCFD_Address_Line_3__c, MCFD_Address__r.MCFD_City__c, MCFD_Address__r.MCFD_Country__c, 
                              MCFD_Address__r.MCFD_Postal_Code__c, MCFD_Address__r.MCFD_Province__c, MCFD_Address__r.UnitNum__c
                              from MCFD_Contact_Address__c
                              where MCFD_Request__c = :requestId AND MCFD_Contact__c = :request.Primary_Applicant__c];
            for(MCFD_Relationship__c relContact: relContactList){
                if(relContact.MCFD_Relationship_Type__c == 'Spouse'){
                    applicantSpouse.Id= relContact.MCFD_Child_Contact__r.Id; applicantSpouse.Birthdate= relContact.MCFD_Child_Contact__r.Birthdate; 
                    applicantSpouse.Email= relContact.MCFD_Child_Contact__r.Email; applicantSpouse.Phone= relContact.MCFD_Child_Contact__r.Phone; 
                    applicantSpouse.MobilePhone= relContact.MCFD_Child_Contact__r.MobilePhone; applicantSpouse.LastName= relContact.MCFD_Child_Contact__r.LastName; 
                    applicantSpouse.FirstName= relContact.MCFD_Child_Contact__r.FirstName; applicantSpouse.MiddleName= relContact.MCFD_Child_Contact__r.MiddleName; 
                    applicantSpouse.MCFD_Attending_School_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Attending_School_Add_Instruction__c; 
                    applicantSpouse.MCFD_Currently_Employed_Additional_Info__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Employed_Additional_Info__c; 
                    applicantSpouse.MCFD_Currently_Self_Employed_Addtn_Info__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Self_Employed_Addtn_Info__c; 
                    applicantSpouse.MCFD_Custody_Details__c= relContact.MCFD_Child_Contact__r.MCFD_Custody_Details__c; 
                    applicantSpouse.MCFD_Childcare_Require__c= relContact.MCFD_Child_Contact__r.MCFD_Childcare_Require__c; 
                    applicantSpouse.MCFD_Govt_Disability_Benefit__c= relContact.MCFD_Child_Contact__r.MCFD_Govt_Disability_Benefit__c;
                    applicantSpouse.MCFD_Employment_Prog_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Employment_Prog_Add_Instruction__c; 
                    applicantSpouse.MCFD_Gender__c= relContact.MCFD_Child_Contact__r.MCFD_Gender__c; 
                    applicantSpouse.MCFD_Attending_School__c= relContact.MCFD_Child_Contact__r.MCFD_Attending_School__c; 
                    applicantSpouse.MCFD_Currently_Employed__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Employed__c;
                    applicantSpouse.MCFD_Looking_For_Work__c= relContact.MCFD_Child_Contact__r.MCFD_Looking_For_Work__c; 
                    applicantSpouse.MCFD_Self_Employed__c= relContact.MCFD_Child_Contact__r.MCFD_Self_Employed__c;
                    applicantSpouse.MCFD_Employment_Prog__c= relContact.MCFD_Child_Contact__r.MCFD_Employment_Prog__c; 
                    applicantSpouse.MCFD_Medical_Condition__c= relContact.MCFD_Child_Contact__r.MCFD_Medical_Condition__c;
                    applicantSpouse.MCFD_In_Childs_Own_Home__c= relContact.MCFD_Child_Contact__r.MCFD_In_Childs_Own_Home__c; 
                    applicantSpouse.MCFD_Special_needs__c= relContact.MCFD_Child_Contact__r.MCFD_Special_needs__c;
                    applicantSpouse.MCFD_Child_Placement__c= relContact.MCFD_Child_Contact__r.MCFD_Child_Placement__c; 
                    applicantSpouse.MCFD_Is_Custody_Shared__c= relContact.MCFD_Child_Contact__r.MCFD_Is_Custody_Shared__c;
                    applicantSpouse.MCFD_Address_Check__c= relContact.MCFD_Child_Contact__r.MCFD_Address_Check__c; 
                    applicantSpouse.MCFD_Licensed_Family_CC__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Family_CC__c;
                    applicantSpouse.MCFD_Licensed_Group_CC__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Group_CC__c; 
                    applicantSpouse.MCFD_Licensed_Preschool__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Preschool__c;
                    applicantSpouse.MCFD_Lic_Not_Reqrd__c= relContact.MCFD_Child_Contact__r.MCFD_Lic_Not_Reqrd__c; 
                    applicantSpouse.MCFD_Looking_For_Work_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Looking_For_Work_Add_Instruction__c;
                    applicantSpouse.MCFD_Marital_Status__c= relContact.MCFD_Child_Contact__r.MCFD_Marital_Status__c; 
                    applicantSpouse.MCFD_Reason_for_no_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_Reason_for_no_SIN__c; 
                    applicantSpouse.MCFD_Medical_Condition_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Medical_Condition_Add_Instruction__c;
                    applicantSpouse.MCFD_No_SIN_Reason__c= relContact.MCFD_Child_Contact__r.MCFD_No_SIN_Reason__c;
                    applicantSpouse.MCFD_Primary_Phone_Number_Type__c= relContact.MCFD_Child_Contact__r.MCFD_Primary_Phone_Number_Type__c; 
                    applicantSpouse.MCFD_Provide_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_Provide_SIN__c;
                    applicantSpouse.MCFD_Reg_Lic_Not_Req__c= relContact.MCFD_Child_Contact__r.MCFD_Reg_Lic_Not_Req__c; 
                    applicantSpouse.MCFD_Same_Custody_Details__c= relContact.MCFD_Child_Contact__r.MCFD_Same_Custody_Details__c; 
                    applicantSpouse.MCFD_Secondary_Phone_Number_Type__c= relContact.MCFD_Child_Contact__r.MCFD_Secondary_Phone_Number_Type__c; 
                    applicantSpouse.MCFD_SIN_Expiry_Date__c= relContact.MCFD_Child_Contact__r.MCFD_SIN_Expiry_Date__c;
                    applicantSpouse.MCFD_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_SIN__c;
                    applicantSpouse.MCFD_Changed__c = relContact.MCFD_Child_Contact__r.MCFD_Changed__c;
                    applicantSpouse.MCFD_HasActiveCRAConsent__c = relContact.MCFD_Child_Contact__r.MCFD_HasActiveCRAConsent__c;                    
                	applicantSpouse.NeedIDForRenewal__c = relContact.MCFD_Child_Contact__r.NeedIDForRenewal__c;
                }
                else if(relContact.MCFD_Relationship_Type__c == 'Dependant'){
                    Contact tempDep = new Contact();
                    tempDep.Id= relContact.MCFD_Child_Contact__r.Id; 
                    tempDep.Birthdate= relContact.MCFD_Child_Contact__r.Birthdate; 
                    tempDep.Email= relContact.MCFD_Child_Contact__r.Email; tempDep.Phone= relContact.MCFD_Child_Contact__r.Phone; 
                    tempDep.MobilePhone= relContact.MCFD_Child_Contact__r.MobilePhone; tempDep.LastName= relContact.MCFD_Child_Contact__r.LastName; 
                    tempDep.FirstName= relContact.MCFD_Child_Contact__r.FirstName; tempDep.MiddleName= relContact.MCFD_Child_Contact__r.MiddleName; 
                    tempDep.MCFD_Attending_School_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Attending_School_Add_Instruction__c; 
                    tempDep.MCFD_Currently_Employed_Additional_Info__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Employed_Additional_Info__c; 
                    tempDep.MCFD_Currently_Self_Employed_Addtn_Info__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Self_Employed_Addtn_Info__c; 
                    tempDep.MCFD_Custody_Details__c= relContact.MCFD_Child_Contact__r.MCFD_Custody_Details__c; 
                    tempDep.MCFD_Childcare_Require__c= relContact.MCFD_Child_Contact__r.MCFD_Childcare_Require__c; 
                    tempDep.MCFD_Govt_Disability_Benefit__c= relContact.MCFD_Child_Contact__r.MCFD_Govt_Disability_Benefit__c;
                    tempDep.MCFD_Employment_Prog_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Employment_Prog_Add_Instruction__c; 
                    tempDep.MCFD_Gender__c= relContact.MCFD_Child_Contact__r.MCFD_Gender__c; 
                    tempDep.MCFD_Attending_School__c= relContact.MCFD_Child_Contact__r.MCFD_Attending_School__c; 
                    tempDep.MCFD_Currently_Employed__c= relContact.MCFD_Child_Contact__r.MCFD_Currently_Employed__c;
                    tempDep.MCFD_Looking_For_Work__c= relContact.MCFD_Child_Contact__r.MCFD_Looking_For_Work__c; 
                    tempDep.MCFD_Self_Employed__c= relContact.MCFD_Child_Contact__r.MCFD_Self_Employed__c;
                    tempDep.MCFD_Employment_Prog__c= relContact.MCFD_Child_Contact__r.MCFD_Employment_Prog__c; 
                    tempDep.MCFD_Medical_Condition__c= relContact.MCFD_Child_Contact__r.MCFD_Medical_Condition__c;
                    tempDep.MCFD_In_Childs_Own_Home__c= relContact.MCFD_Child_Contact__r.MCFD_In_Childs_Own_Home__c; 
                    tempDep.MCFD_Special_needs__c= relContact.MCFD_Child_Contact__r.MCFD_Special_needs__c;
                    tempDep.MCFD_Child_Placement__c= relContact.MCFD_Child_Contact__r.MCFD_Child_Placement__c; 
                    tempDep.MCFD_Is_Custody_Shared__c= relContact.MCFD_Child_Contact__r.MCFD_Is_Custody_Shared__c;
                    tempDep.MCFD_Address_Check__c= relContact.MCFD_Child_Contact__r.MCFD_Address_Check__c; 
                    tempDep.MCFD_Licensed_Family_CC__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Family_CC__c;
                    tempDep.MCFD_Licensed_Group_CC__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Group_CC__c; 
                    tempDep.MCFD_Licensed_Preschool__c= relContact.MCFD_Child_Contact__r.MCFD_Licensed_Preschool__c;
                    tempDep.MCFD_Lic_Not_Reqrd__c= relContact.MCFD_Child_Contact__r.MCFD_Lic_Not_Reqrd__c; 
                    tempDep.MCFD_Looking_For_Work_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Looking_For_Work_Add_Instruction__c;
                    tempDep.MCFD_Marital_Status__c= relContact.MCFD_Child_Contact__r.MCFD_Marital_Status__c; 
                    tempDep.MCFD_Reason_for_no_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_Reason_for_no_SIN__c; 
                    tempDep.MCFD_Medical_Condition_Add_Instruction__c= relContact.MCFD_Child_Contact__r.MCFD_Medical_Condition_Add_Instruction__c;
                    tempDep.MCFD_No_SIN_Reason__c= relContact.MCFD_Child_Contact__r.MCFD_No_SIN_Reason__c;
                    tempDep.MCFD_Primary_Phone_Number_Type__c= relContact.MCFD_Child_Contact__r.MCFD_Primary_Phone_Number_Type__c; 
                    tempDep.MCFD_Provide_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_Provide_SIN__c;
                    tempDep.MCFD_Reg_Lic_Not_Req__c= relContact.MCFD_Child_Contact__r.MCFD_Reg_Lic_Not_Req__c; 
                    tempDep.MCFD_Same_Custody_Details__c= relContact.MCFD_Child_Contact__r.MCFD_Same_Custody_Details__c; 
                    tempDep.MCFD_Secondary_Phone_Number_Type__c= relContact.MCFD_Child_Contact__r.MCFD_Secondary_Phone_Number_Type__c; 
                    tempDep.MCFD_SIN_Expiry_Date__c= relContact.MCFD_Child_Contact__r.MCFD_SIN_Expiry_Date__c;
                    tempDep.MCFD_SIN__c= relContact.MCFD_Child_Contact__r.MCFD_SIN__c;
                    tempDep.NeedIDForRenewal__c = relContact.MCFD_Child_Contact__r.NeedIDForRenewal__c;
                    tempDep.ICM_SpecialNeedsStatus__c = relContact.MCFD_Child_Contact__r.ICM_SpecialNeedsStatus__c;
                    depList.add(tempDep);
                }
            }
            
            if(primaryApplicant.Id != null)
                parentContactList.add(primaryApplicant);
            if(applicantSpouse.Id != null)
                parentContactList.add(applicantSpouse);
            rfcList = [select Id, MCFD_Additional_Info__c, Contact__c, MCFD_End_Date__c, MCFD_End_Time__c,
                       MCFD_Travel_hours__c, MCFD_Name__c, MCFD_Number_of_hours_per_day_week__c, MCFD_Number_of_hours_per_day_weekend__c,
                       MCFD_Number_of_days_week__c, MCFD_Number_of_days_weekend__c, MCFD_Rsn_For_Care_Type__c, MCFD_Request__c,
                       MCFD_Schedule_Info__c, MCFD_Start_Date__c, MCFD_Start_Time__c, You_Participating_in_the_SPEI_del__c,
                       MCFD_When_do_you_work__c, No_change_in_ST_and_ET_on_M_to_F__c
                       from Reason_For_Care__c
                       where Contact__c IN :parentContactList AND MCFD_Request__c = :requestId];
            incomeList = [select Id, MCFD_Declaration__c , MCFD_Comments__c, MCFD_Band_Assistance__c,NoIncomeOnApplicantCheck__c, MCFD_Band_Assistance_Amount__c, MCFD_Band_Assistance_Freq__c,
                          MCFD_BC_Disability_Assistance__c, MCFD_BC_Disability_Assistance_Amount__c, MCFD_BC_Disability_Assistance_Freq__c,
                          MCFD_BC_Income_Assistance__c, MCFD_BC_Income_Assistance_Amount__c, MCFD_BC_Income_Assistance_Freq__c,
                          Contact__c, MCFD_Employment_Income__c, MCFD_Self_Employment_Income__c, MCFD_Federal_Benefits__c, 
                          MCFD_Federal_Benefits_Amount__c, MCFD_Federal_Benefits_Freq__c, MCFD_Federal_Employment_Insurance__c,
                          MCFD_Federal_Employment_Insurance_Amount__c, MCFD_Federal_Employment_Insurance_Freq__c, MCFD_Federal_Employment_Insurance_Start__c,
                          MCFD_Grants__c, MCFD_Grants_Amount__c, MCFD_Grants_Freq__c, MCFD_Dep_Adult_Income__c, MCFD_Dep_Adult_Income_Amount__c,
                          MCFD_Dep_Adult_Income_Freq__c, MCFD_Rental_Income__c, MCFD_Rental_Income_Amount__c, MCFD_Rental_Income_Freq__c,
                          MCFD_Interest_Amount__c, MCFD_Interest_Freq__c, MCFD_Interest__c, MCFD_No_Income_Description__c,
                          MCFD_Other_Income__c, MCFD_Other_Income_Amount__c, MCFD_Other_Income_Freq__c, MCFD_Related_Request__c,
                          MCFD_Spousal_Support__c, MCFD_Spousal_Support_Amount__c, MCFD_Spousal_Support_Freq__c, MCFD_Tips__c, 
                          MCFD_Tips_Amount__c, MCFD_Tips_Freq__c, MCFD_Training_Living_Allowance__c, MCFD_Training_Living_Allowance_Amount__c,
                          MCFD_Training_Living_Allowance_Freq__c, MCFD_WorkSafeBC__c, MCFD_WorkSafeBC_Amount__c, 
                          MCFD_WorkSafeBC_Freq__c, MCFD_WorkSafeBC_Start__c,MCFD_SocialAssistance__c,MCFD_SocialAssistanceAmount__c,MCFD_SocialAssistanceFrequency__c,MCFD_DisabilityBenefits__c,
                          MCFD_DisabilityBenefitsAmount__c,MCFD_DisabilityBenefitsFrequency__c,MCFD_PensionIncome__c,MCFD_PensionIncomeAmount__c,MCFD_PensionIncomeFrequency__c,MCFD_RRSPIncome__c,MCFD_RRSPIncomeAmount__c,MCFD_RRSPIncomeFreqency__c
                          from Income__c
                          where Contact__c IN :parentContactList AND MCFD_Related_Request__c = :requestId];
            empIncomeList = [select Id, MCFD_Amount_Pay_Stub_1__c, MCFD_Amount_Pay_Stub_2__c, 
                             MCFD_Employer_Name__c, MCFD_End_Date__c, MCFD_Hourly_Wage__c, Parent_Income_Id__c, 
                             MCFD_No_Two_Pay_Stubs__c, MCFD_Net_Income__c, MCFD_Non_Deduct_Amount_Pay_Stub_1__c, 
                             MCFD_Non_Deduct_Amount_Pay_Stub_2__c, MCFD_Pay_Frequency__c, MCFD_Start_Date__c
                             from MCFD_Employment_Income__c
                             where Parent_Income_Id__c = :incomeList];
            selfEmpIncomeList = [select Id, MCFD_Business_Name__c, MCFD_Net_Income__c,MCFD_Pay_Frequency__c,
                                 MCFD_Limited_Company__c,MCFD_New_Business__c,Parent_Income_Id__c
                                 from MCFD_Self_Employment_Income__c
                                 where Parent_Income_Id__c = :incomeList];
            uploadList = [select Id,Name, MCFD_Page_Name__c, MCFD_Attachment_Name__c, MCFD_Category__c, MCFD_Category_Description__c,
                          MCFD_Status__c, MCFD_Mandatory__c ,MCFD_Type__c, MCFD_Contact_Id__c, MCFD_Income_Id__c, 
                          MCFD_RsnFCare_Id__c, MCFD_Send_Later__c, MCFD_Request_Id__c
                          from MCFD_Attachment__c
                          where MCFD_Request_Id__c = :requestId];
            // Parse through the result and assign to individual entries
            for(MCFD_Contact_Address__c conAddress: conAddressList){
                MCFD_Address__c tempAddress = new MCFD_Address__c();
                tempAddress.Id = conAddress.MCFD_Address__r.Id;
                tempAddress.MCFD_Address_Line_1__c = conAddress.MCFD_Address__r.MCFD_Address_Line_1__c;
                tempAddress.MCFD_Address_Line_2__c = conAddress.MCFD_Address__r.MCFD_Address_Line_2__c;
                tempAddress.MCFD_Address_Line_3__c = conAddress.MCFD_Address__r.MCFD_Address_Line_3__c;
                tempAddress.MCFD_City__c = conAddress.MCFD_Address__r.MCFD_City__c;
                tempAddress.MCFD_Country__c = conAddress.MCFD_Address__r.MCFD_Country__c;
                tempAddress.MCFD_Postal_Code__c = conAddress.MCFD_Address__r.MCFD_Postal_Code__c;
                tempAddress.MCFD_Province__c = conAddress.MCFD_Address__r.MCFD_Province__c;
                tempAddress.UnitNum__c = conAddress.MCFD_Address__r.UnitNum__c;
                if(conAddress.MCFD_Address_Type__c == 'Home and Mailing Address'){
                    addressHome = tempAddress;
                    addressMail = tempAddress;
                }
                else if(conAddress.MCFD_Address_Type__c == 'Home Address'){
                    addressHome = tempAddress;
                }
                else if(conAddress.MCFD_Address_Type__c == 'Mailing Address'){
                    addressMail = tempAddress;
                }
            }
            for(Reason_For_Care__c rfcInfo: rfcList){
                if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment' && rfcInfo.Contact__c == primaryApplicant.Id){
                    employmentInfo = rfcInfo;
                    paRFCEmployerList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseEmpInfo = rfcInfo;
                    spouseRFCEmployerList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Self Employment' && rfcInfo.Contact__c == primaryApplicant.Id){
                    selfEmploymentInfo = rfcInfo;
                    paRFCBusinessList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Self Employment' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseSelfEmpInfo = rfcInfo;
                    spouseRFCBusinessList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Medical Condition' && rfcInfo.Contact__c == primaryApplicant.Id){
                    medicalCondInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Medical Condition' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseMedclCondInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Attending School' && rfcInfo.Contact__c == primaryApplicant.Id){
                    schoolSchInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Attending School' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseSchoolSchInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Looking for Work' && rfcInfo.Contact__c == primaryApplicant.Id){
                    lookingWorkScrn1 = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Looking for Work' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseLookingWrkScrn1 = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment Program' && rfcInfo.Contact__c == primaryApplicant.Id){
                    empProgSchInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment Program' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseRFCEmpPrgSchInfo = rfcInfo;
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employer' && rfcInfo.Contact__c == primaryApplicant.Id){
                    paRFCEmployerList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employer' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseRFCEmployerList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Business' && rfcInfo.Contact__c == primaryApplicant.Id){
                    paRFCBusinessList.add(rfcInfo);
                }
                else if(rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Business' && rfcInfo.Contact__c == applicantSpouse.Id){
                    spouseRFCBusinessList.add(rfcInfo);
                }
            }
            for(Income__c incomeInfo: incomeList){
                if(incomeInfo.Contact__c == primaryApplicant.Id){
                    paIncome = incomeInfo; // creating new instance of Income__c
                    system.debug('empIncomeList===' +empIncomeList+'===+incomeInfo==='+incomeInfo);
                    for(MCFD_Employment_Income__c tempEmpInc: empIncomeList){
                        if(tempEmpInc.Parent_Income_Id__c == incomeInfo.Id){
                            paEmpIncomeList.add(tempEmpInc);
                            system.debug('paEmpIncomeList==='+paEmpIncomeList);
                        }
                    }
                    for(MCFD_Self_Employment_Income__c tempSelfEmpInc: selfEmpIncomeList){
                        if(tempSelfEmpInc.Parent_Income_Id__c == incomeInfo.Id){
                            paSelfEmpIncomeList.add(tempSelfEmpInc);
                        }
                    }
                }
                else if(incomeInfo.Contact__c == applicantSpouse.Id){
                    spouseIncome = incomeInfo;
                    for(MCFD_Employment_Income__c tempEmpInc: empIncomeList){
                        if(tempEmpInc.Parent_Income_Id__c == incomeInfo.Id){
                            spouseEmpIncomeList.add(tempEmpInc);
                        }
                    }
                    for(MCFD_Self_Employment_Income__c tempSelfEmpInc: selfEmpIncomeList){
                        if(tempSelfEmpInc.Parent_Income_Id__c == incomeInfo.Id){
                            spouseSelfEmpIncomeList.add(tempSelfEmpInc);
                        }
                    }
                }
            }
            // Build the return object
            mapObj.put('request', request);
            mapObj.put('primaryApplicant', primaryApplicant);
            mapObj.put('applicantSpouse', applicantSpouse);
            mapObj.put('addressHome', addressHome);
            mapObj.put('addressMail', addressMail);
            mapObj.put('employmentInfo', employmentInfo);
            mapObj.put('selfEmploymentInfo', selfEmploymentInfo);
            mapObj.put('schoolSchInfo', schoolSchInfo);
            mapObj.put('empProgSchInfo', empProgSchInfo);
            mapObj.put('lookingWorkScrn1', lookingWorkScrn1);
            mapObj.put('medicalCondInfo', medicalCondInfo);
            mapObj.put('paIncome', paIncome);
            mapObj.put('spouseEmpInfo', spouseEmpInfo);
            mapObj.put('spouseSelfEmpInfo', spouseSelfEmpInfo);
            mapObj.put('spouseSchoolSchInfo', spouseSchoolSchInfo);
            mapObj.put('spouseRFCEmpPrgSchInfo', spouseRFCEmpPrgSchInfo);
            mapObj.put('spouseLookingWrkScrn1', spouseLookingWrkScrn1);
            mapObj.put('spouseMedclCondInfo', spouseMedclCondInfo);
            mapObj.put('spouseIncome', spouseIncome);
            mapListObj.put('dependentList', depList);
            mapListObj.put('paRFCEmployerList', paRFCEmployerList);
            mapListObj.put('paRFCBusinessList', paRFCBusinessList);
            mapListObj.put('paEmpIncomeList', paEmpIncomeList);
            mapListObj.put('paSelfEmpIncomeList', paSelfEmpIncomeList);
            mapListObj.put('spouseRFCEmployerList', spouseRFCEmployerList);
            mapListObj.put('spouseRFCBusinessList', spouseRFCBusinessList);
            mapListObj.put('spouseEmpIncomeList', spouseEmpIncomeList);
            mapListObj.put('spouseSelfEmpIncomeList', spouseSelfEmpIncomeList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
  
    // Function list to be invoked for each component
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_EnterFamilyCompositionComponent(Request__c request, Contact applicant, Contact spouse, List<Contact> depList, String requestType){

        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_Relationship__c relationship = new MCFD_Relationship__c();
        RecordType rt = new RecordType();
        List<MCFD_Relationship__c> delSpouseRelList = new List<MCFD_Relationship__c>();
        List<MCFD_Relationship__c> delDepRelList = new List<MCFD_Relationship__c>();
        List<MCFD_Relationship__c> delContactRelList = new List<MCFD_Relationship__c>();
        Contact delCon = new Contact();
        List<Contact> delContactList = new List<Contact>();
        List<MCFD_Attachment__c> delContactAttachmentList = new List<MCFD_Attachment__c>();
        MCFD_CCSReturnTypeWrapper delContactReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        List<SObject> delUploadList = new List<SObject>();
        MCFD_CCSReturnTypeWrapper delApplicantRFCReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper delSpouseRFCReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<MCFD_Attachment__c> uploadList = new List<MCFD_Attachment__c>();
        String isPlacementCheck = '', placementVal = '';

        //From Laura to fix the duplicate primary applicant contact
        //applicant.Id = [SELECT Id Fr]
  /*      List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
        applicant.Id = ContactDetails[0].ContactId;*/

        try{
            String ICM_SR_Num;
            // Create a new request if it's not already created
            if(request.Id == null || request.ICM_SR_Number__c == null || request.ICM_SR_Number__c == ''){
                System.debug('request type ==>>>');
                System.debug(requestType);

                ICM_SR_Num = CreateSR(requestType);                                // Make web service very first time before any DML. Bug : 2744
                //Integer len = ICM_SR_Num.length();                    // Just to throw exception if no SR number from web service  // will be handled in US 515
                if(ICM_SR_Num != Null){                 
                    request.ICM_SR_Number__c = ICM_SR_Num;                
                    request.MCFD_Status__c = 'In Progress';                 
                }
            }
            
            // RFC removal criteria for applicant and spouse if they exist
            // check for placement information
            if(depList.size() > 0){
                for(Contact c: depList){
                    if(c.MCFD_Childcare_Require__c == 'Yes'){
                        if(placementVal != '' && placementVal != c.MCFD_Child_Placement__c){
                            isPlacementCheck = 'No';
                            break;
                        }
                        else{
                            isPlacementCheck = 'Yes';
                            placementVal = c.MCFD_Child_Placement__c;
                        } 
                    }
                }
            }
        //commented below code to fix RFC Missing issue, check Remedy #747565
          //if(isPlacementCheck == 'Yes' && applicant.MCFD_Is_SW_Referred__c == 'Yes'){
        if(!request.MCFD_hasRFC__C){ 
                applicant.MCFD_Currently_Employed__c = false; 
                applicant.MCFD_Self_Employed__c = false; 
                applicant.MCFD_Attending_School__c = false; 
                applicant.MCFD_Looking_For_Work__c = false; 
                applicant.MCFD_Medical_Condition__c = false; 
                applicant.MCFD_Employment_Prog__c = false; 
                if(spouse.LastName != null){
                    spouse.MCFD_Currently_Employed__c = false;
                    spouse.MCFD_Self_Employed__c = false;
                    spouse.MCFD_Self_Employed__c = false;
                    spouse.MCFD_Looking_For_Work__c = false;
                    spouse.MCFD_Medical_Condition__c = false;
                    spouse.MCFD_Employment_Prog__c = false;
                }
            }
                        
            // Upsert applicant and spouse information
            if(applicant.LastName != ''){
                applicant = upsertContact(applicant);
                //applicant = updateContact(applicant);
            }
            System.debug(request.Id);
            
            // Create a new request if it's not already created
            if(request.Id == null){
                request.Primary_Applicant__c = applicant.Id;
                rt = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Application'];
                
                request.RecordTypeId = rt.Id;
                if(request.MCFD_Status__c == Null || request.MCFD_Status__c == ''){
                    request.MCFD_Status__c = 'Pending';              
                }
                
                //request = upsertRequest(request);
            }
                        
            request = upsertRequest(request);
            
            // Specify the account of primary applicant on spouse and other dependents
            Contact primaryApplicant = [select Id, Name, AccountId, MCFD_HasActiveCRAConsent__c from Contact where Id = :applicant.Id];
            
            if(spouse.LastName != ''){
                if(applicant.MCFD_Marital_Status__c == 'Married, or living in a marriage-like relationship'){
                    
                    system.debug('--Abhi-11--'+spouse.Id);
                    
                    if(spouse.Id != null){

                        //LPERRY: fixing bug 5463
                        // make sure the spouse has been saved in salesforce
                        List<Contact> spouseOnFile = [select Id, Name, AccountId from Contact where Id = :spouse.Id];

                        if (spouseOnFile.size() > 0)
			{
                            spouse = upsertContact(spouse);
                            request.Spouse__c=spouse.Id;
                            upsertrequest(request);
                        }
                        else
                        {
                            spouse.AccountId = primaryApplicant.AccountId;
                            spouse.Id = null;
                            spouse = upsertContact(spouse);
                            relationship.MCFD_Parent_Contact__c = applicant.Id;
                            relationship.MCFD_Child_Contact__c = spouse.Id;
                            relationship.MCFD_Request__c = request.Id;
                            relationship.MCFD_Relationship_Type__c = 'Spouse';
                            upsertRelationship(relationship);
                            request.Spouse__c=spouse.Id;
                            upsertrequest(request);
                            relationship = new MCFD_Relationship__c();
                        }
                    }
                    else{
                        spouse.AccountId = primaryApplicant.AccountId;
                        spouse = upsertContact(spouse);
                        relationship.MCFD_Parent_Contact__c = applicant.Id;
                        relationship.MCFD_Child_Contact__c = spouse.Id;
                        relationship.MCFD_Request__c = request.Id;
                        relationship.MCFD_Relationship_Type__c = 'Spouse';
                        upsertRelationship(relationship);
                        request.Spouse__c=spouse.Id;
                        upsertrequest(request);
                        relationship = new MCFD_Relationship__c();
                    }
                }
                else{
                    system.debug('-----Abhi-22--'+spouse.Id);
                    system.debug('-----Abhi-33--'+relationship);
                    
                    //Updated by Sonam
                    if(spouse.Id != null){
                    request.Spouse__c= null;
                    }
                    upsertrequest(request);   
                    
                }
            }
                
            // Upsert dependent information
            Integer i = 1;
            for(Contact c:depList){
                if(c.LastName != ''){
                    if(c.Id != null){
                        c = upsertContact(c);
                    }
                    else{
                        c.AccountId = primaryApplicant.AccountId;
                        c = upsertContact(c);
                        relationship.MCFD_Parent_Contact__c = applicant.Id;
                        relationship.MCFD_Child_Contact__c = c.Id;
                        relationship.MCFD_Request__c = request.Id;
                        relationship.MCFD_Relationship_Type__c = 'Dependant';
                        relationship.MCFD_Dependant_Number__c = i;
                        upsertRelationship(relationship);
                        relationship = new MCFD_Relationship__c();
                    }
                    i = i + 1;
                }
            }
            
            // Delete the dependants that are present on the request in Salesforce but not on the depList. This logic will ensure that the 
            // contacts deleted on Family composition before save will be deleted from Salesforce.
            
            //using this temporary list of Ids extracted from depList (Contacts list) because the below SOQL fails due to Spring 19 upgrade due to
            //sciptrowfound error.
            List<Id> tempDepList = new List<Id>();
            for(Contact c:depList)
            {
                tempDepList.add(c.Id);
            }
            
            delDepRelList = [select MCFD_Child_Contact__c, Id from MCFD_Relationship__c WHERE 
                             MCFD_Relationship_Type__c = 'Dependant'
                             AND MCFD_Parent_Contact__c = :applicant.Id
                             AND MCFD_Request__c = :request.Id
                             AND MCFD_Child_Contact__c NOT IN :tempDepList];
            
            delContactRelList.addAll(delDepRelList);
            
            // Delete the relationships, contact and other child object records
            for(MCFD_Relationship__c d: delContactRelList){
                delCon.Id = d.MCFD_Child_Contact__c;
                delContactList.add(delCon);
                delCon = new Contact();
            }

            //Bug Fix - 3510: A reason for care record is created with type = "Referral" 
            if(applicant.Id != Null && request.Id != Null){
                List<Reason_For_Care__c> lstRFC_Referral = new List<Reason_For_Care__c>([SELECT id FROM Reason_For_Care__c 
                                                                                         WHERE MCFD_Rsn_For_Care_Type__c = 'Referral'
                                                                                         AND Contact__c =: applicant.Id
                                                                                         AND MCFD_Request__c =: request.Id]);
                
                if(applicant.MCFD_Is_SW_Referred__c == 'Yes'){
                    // Only insert RFC_Referral if none exists
                    if(lstRFC_Referral.size() == 0){
                        Insert new Reason_For_Care__c(MCFD_Rsn_For_Care_Type__c = 'Referral', Contact__c = applicant.Id, MCFD_Request__c = request.Id);
                    }
                }else{
                    if(lstRFC_Referral.size() > 0){
                        Delete lstRFC_Referral;
                    }
                }
            }
            
            // invoking RFC updates
           if(isPlacementCheck == 'Yes' && applicant.MCFD_Is_SW_Referred__c == 'Yes'){
          // if(!request.MCFD_hasRFC__C){ 
                delApplicantRFCReturnVal = delRFCList(applicant,request.Id);
                fileList.addAll(delApplicantRFCReturnVal.mapListObj.get('FileList'));
                delUploadList.addAll(delApplicantRFCReturnVal.mapListObj.get('AttachmentList'));
                if(spouse.LastName != '' && spouse.LastName != null && spouse.Id != null){
                    delSpouseRFCReturnVal = delRFCList(spouse,request.Id);
                    fileList.addAll(delSpouseRFCReturnVal.mapListObj.get('FileList'));
                    delUploadList.addAll(delSpouseRFCReturnVal.mapListObj.get('AttachmentList'));
                }
            }
            
             //returnVal = RefreshRFCList(applicant,spouse,request);
            
            // Vai - the deletion takes place as the last step. This code calls future method. Any new code please place it above this. 
            if(delContactList.size() > 0){
                Delete delContactRelList;
                delContactReturnVal = delContactListwithChild(delContactList);
                fileList.addAll(delContactReturnVal.mapListObj.get('FileList'));
                delUploadList.addAll(delContactReturnVal.mapListObj.get('AttachmentList'));
            }
            // Remove the attachments from upload list 
            uploadList = [select Id, MCFD_Category__c, MCFD_Category_Description__c, MCFD_Attachment_Name__c,
                          MCFD_Contact_Id__c, MCFD_Income_Id__c, MCFD_Mandatory__c, MCFD_Page_Name__c,
                          MCFD_Request_Id__c, MCFD_Send_Later__c, MCFD_Status__c, MCFD_Type__c, MCFD_RsnFCare_Id__c
                          from MCFD_Attachment__c where MCFD_Request_Id__c = :request.Id];
            if(delUploadList.size() > 0 && uploadList.size() > 0){
                for(i=0; i<delUploadList.size(); i++){
                    for(Integer j=0; j<uploadList.size(); j++){
                        if(delUploadList[i].Id == uploadList[j].Id){
                            uploadList.remove(j);
                        }
                    }
                }
            }
            syncFilestoICM(fileList);
            
            //mapObj = returnVal.mapObj;
            //mapListObj = returnVal.mapListObj;
           
            
            // Build return values
            mapObj.put('request', request);
            mapObj.put('primaryApplicant', applicant);
            mapObj.put('applicantSpouse', spouse);
            mapListObj.put('dependentList', depList);
            mapListObj.put('delContactAttachmentList', delContactAttachmentList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            System.debug(returnVal);
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_ChildDependantPersonalInformation(Request__c request, Contact applicant, Contact spouse, Contact contactInfo, List<MCFD_Attachment__c> uploadList, List<Contact> depList){
        system.debug('MCFD_hasRFC__c: '+request.MCFD_hasRFC__c);
       
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper delApplicantRFCReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper delSpouseRFCReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper delIncomeReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<Reason_For_Care__c> lstPreschoolRFC = new List<Reason_For_Care__c>();
        List<Contact> conProcessList = new List<Contact>();
        List<SObject> fileList = new List<SObject>();
        List<SObject> delUploadList = new List<SObject>();
        String isPlacementCheck = '', placementVal = '', isPreschoolCheck = '';
        Boolean preSchoolVal = false;
        Integer depListsize = depList.size();
        Integer uploadListSize = uploadList.size();
        
        try{
            if(contactInfo.LastName != ''){
                contactInfo = upsertContact(contactInfo);
            }
            request = upsertRequest(request); 
            // Build return values
            
              system.debug('MCFD_hasRFC__c: '+request.MCFD_hasRFC__c);
            
            /* check for preschool information
             *  Commented below code due missing RFC issue Refer to Remedy #747565
             */
             
            // check for placement information
      if(depListsize > 0 && depListsize != 1){
                for(Contact c: depList){
                    if(c.MCFD_Childcare_Require__c == 'Yes'){
                        if(placementVal != '' && placementVal != c.MCFD_Child_Placement__c){
                            isPlacementCheck = 'No';
                            break;
                        }
                        else{
                            isPlacementCheck = 'Yes';
                            placementVal = c.MCFD_Child_Placement__c;
                        } 
                    }
                }
            }
            else if(depListsize == 1){
                if(contactInfo.MCFD_Child_Placement__c == 'Yes' && contactInfo.MCFD_Childcare_Require__c == 'Yes'){
                    isPlacementCheck = 'Yes';
                    placementVal = 'Yes';
                }
            }  
           /*if(depListsize > 0 && depListsize != 1){
                for(Contact c: depList){
                    if(c.MCFD_Childcare_Require__c == 'Yes'){
                        if(preSchoolVal != false && preSchoolVal != c.MCFD_Licensed_Preschool__c){
                            isPreschoolCheck = 'No';
                            break;
                        }
                        else{
                            isPreschoolCheck = 'Yes';
                            preSchoolVal = c.MCFD_Licensed_Preschool__c;
                        } 
                    }
                }
            }
            else if(depListsize == 1){
                if(contactInfo.MCFD_Licensed_Preschool__c == true && contactInfo.MCFD_Childcare_Require__c == 'Yes'){
                    isPreschoolCheck = 'Yes';
                    preSchoolVal = true;
                }
            } */
            
            //below code added to fix missing RFC issue Refer to Remedy #747565
          /*   isPlacementCheck ='No' ;
            if(depListsize > 0){
                 for(Contact c: depList){
                    if(c.MCFD_Childcare_Require__c == 'Yes'){
                         if(c.MCFD_Child_Placement__c == 'Yes'){
                            isPlacementCheck ='Yes' ;
                            placementVal = c.MCFD_Child_Placement__c;
                            break;
                         }
                    }
                
                }
            
            }   */ 
            
            
            
            
             isPreschoolCheck ='No' ;
            if(depListsize > 0){
                 for(Contact c: depList){
                    if(c.MCFD_Childcare_Require__c == 'Yes'){
                         if(c.MCFD_Licensed_Preschool__c){
                            isPreschoolCheck ='Yes' ;
                            preSchoolVal = true;
                            break;
                         }
                    }
                
                }
            
            }    
                
              if(applicant.Id != null && request.Id != null){
                    lstPreschoolRFC = [SELECT id FROM Reason_For_Care__c 
                                       WHERE MCFD_Rsn_For_Care_Type__c = 'Preschool'
                                       AND Contact__c =: applicant.Id
                                       AND MCFD_Request__c =: request.Id];
                }
            
              if(isPreschoolCheck == 'Yes' && preSchoolVal == true){
                    // Only insert preschool if none exists
                    if(lstPreschoolRFC.size() == 0){
                        Insert new Reason_For_Care__c(MCFD_Rsn_For_Care_Type__c = 'Preschool', Contact__c = applicant.Id, MCFD_Request__c = request.Id);
                    }
                }
                else{
                    // delete the preschool rfc
                    if(lstPreschoolRFC.size() > 0){
                        Delete lstPreschoolRFC;
                    }
                }
            
            
            
            // RFC removal criteria for applicant and spouse if they exist and preschool addition
     //if((isPlacementCheck == 'Yes' && applicant.MCFD_Is_SW_Referred__c == 'Yes') || (isPreschoolCheck == 'Yes' && preSchoolVal == true)){
            system.debug('MCFD_hasRFC__C: '+request.MCFD_hasRFC__C);
           
            if(!request.MCFD_hasRFC__C){ 
                system.debug('Inside RFC removal logic');
               
                    //Commented below code due missing RFC issue Refer to Remedy #747565
                    applicant.MCFD_Currently_Employed__c = false; 
                    applicant.MCFD_Self_Employed__c = false; 
                    applicant.MCFD_Attending_School__c = false; 
                    applicant.MCFD_Looking_For_Work__c = false; 
                    applicant.MCFD_Medical_Condition__c = false; 
                    applicant.MCFD_Employment_Prog__c = false; 
                    if(spouse.Id != null){
                        spouse.MCFD_Currently_Employed__c = false;
                        spouse.MCFD_Self_Employed__c = false;
                        spouse.MCFD_Self_Employed__c = false;
                        spouse.MCFD_Looking_For_Work__c = false;
                        spouse.MCFD_Medical_Condition__c = false;
                        spouse.MCFD_Employment_Prog__c = false;
                    } 
                    // and preschool addition
                   
                  
                    // updating applicant and spouse
                    applicant = upsertContact(applicant);
                    if(spouse.LastName != '' && spouse.LastName != null){
                        spouse = upsertContact(spouse);
                    }
    
                    // invoking RFC updates
                     delApplicantRFCReturnVal = delRFCList(applicant,request.id);
                    fileList.addAll(delApplicantRFCReturnVal.mapListObj.get('FileList'));
                    delUploadList.addAll(delApplicantRFCReturnVal.mapListObj.get('AttachmentList'));
                    if(spouse.LastName != '' && spouse.LastName != null && spouse.Id != null){
                        delSpouseRFCReturnVal = delRFCList(spouse,request.Id);
                        fileList.addAll(delSpouseRFCReturnVal.mapListObj.get('FileList'));
                        delUploadList.addAll(delSpouseRFCReturnVal.mapListObj.get('AttachmentList'));
                    }
        
               
                 // returnVal = RefreshRFCList(applicant,spouse,request);
                 
             }
             //   system.debug('from method call returnVal: '+returnVal);
            
            // Income removal criteria for both applicant and spouse if they exist
            if(isPlacementCheck == 'Yes' && placementVal == 'Yes'){
                // Delete Income, employment income and self employment income for the applicant and spouse
                conProcessList.add(applicant);
                if(spouse.LastName != '' && spouse.LastName != null && spouse.Id != null){
                    conProcessList.add(spouse);
                }
                delIncomeReturnVal = delIncomeListwithChild(conProcessList);
                fileList.addAll(delIncomeReturnVal.mapListObj.get('FileList'));
                delUploadList.addAll(delIncomeReturnVal.mapListObj.get('AttachmentList'));
            }
            // Remove the attachments from upload list 
            if(delUploadList.size() > 0){
                for(Integer i=0; i<delUploadList.size(); i++){
                    for(Integer j=0; j<uploadList.size(); j++){
                        if(delUploadList[i].Id == uploadList[j].Id){
                            uploadList.remove(j);
                        }
                    }
                }
            }
            
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            //mapObj = returnVal.mapObj;
            //mapListObj = returnVal.mapListObj;
            
            
            mapObj.put('dependentDetail', contactInfo);
            mapObj.put('primaryApplicant', applicant);
            mapObj.put('applicantSpouse', spouse);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            
             system.debug('After returnVal: '+returnVal);
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_DependantPersonalInformation(Request__c request, Contact contactInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            if(contactInfo.LastName != ''){
                contactInfo = upsertContact(contactInfo);
            }
            
            request = upsertRequest(request);
            
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('dependentDetail', contactInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_PrimaryApplicantPI(Request__c requestInfo, Contact contactInfo, MCFD_Address__c addressHome, MCFD_Address__c addressMail, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_Contact_Address__c conAddress = new MCFD_Contact_Address__c();
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();

        try{
            System.debug('addressHome---'+addressHome);
                System.debug('addressMail---'+addressMail);
                System.debug('contactInfo---'+contactInfo.id);
                
            if(contactInfo.LastName != ''){
                    contactInfo = upsertContact(contactInfo);
                    if(addressMail.MCFD_Address_Line_1__c != ''){
                        if(addressMail.Id != null){
                            addressMail = upsertAddress(addressMail);
                            List<MCFD_Contact_Address__c> conMailAddress = new List<MCFD_Contact_Address__c>([select id, MCFD_Address_Type__c from
                                                                                                              MCFD_Contact_Address__c where
                                                                                                              MCFD_Request__c = :requestInfo.Id AND
                                                                                                              MCFD_Contact__c = :contactInfo.Id AND
                                                                                                              MCFD_Address__c = :addressMail.Id]);
                            if(!conMailAddress.isEmpty()){      
                                if(contactInfo.MCFD_Address_Check__c == 'Yes'){
                                    conMailAddress[0].MCFD_Address_Type__c = 'Home and Mailing Address';
                                }
                                else{
                                    conMailAddress[0].MCFD_Address_Type__c = 'Mailing Address';
                                }
                                upsertConAddress(conMailAddress[0]);    
                            }else{
                                //Create new Contact Address record and link with pre-populated mailing address (whihc was created during the registration)
                                MCFD_Contact_Address__c conMailAddressNew = new MCFD_Contact_Address__c();
                            
                                // Add request Id in pre-populated mailing address (mailing address created during registration do not have request id)
                                conMailAddressNew.MCFD_Request__c = requestInfo.Id; 
                                conMailAddressNew.MCFD_Contact__c = contactInfo.Id;
                                conMailAddressNew.MCFD_Address__c = addressMail.Id;
                                
                                if(contactInfo.MCFD_Address_Check__c == 'Yes'){
                                    conMailAddressNew.MCFD_Address_Type__c = 'Home and Mailing Address';
                                }
                                else{
                                    conMailAddressNew.MCFD_Address_Type__c = 'Mailing Address';
                                }
                                upsertConAddress(conMailAddressNew);    
                            }
                        }
                        else{
                            addressMail = upsertAddress(addressMail);
                            conAddress = new MCFD_Contact_Address__c();
                            if(contactInfo.MCFD_Address_Check__c == 'Yes'){
                                conAddress.MCFD_Address_Type__c = 'Home and Mailing Address';
                                conAddress.MCFD_Address__c = addressMail.Id;
                                conAddress.MCFD_Request__c = requestInfo.Id;
                                conAddress.MCFD_Contact__c = contactInfo.Id;
                                upsertConAddress(conAddress);
                            }
                            else{
                                conAddress.MCFD_Address_Type__c = 'Mailing Address';
                                conAddress.MCFD_Address__c = addressMail.Id;
                                conAddress.MCFD_Request__c = requestInfo.Id;
                                conAddress.MCFD_Contact__c = contactInfo.Id;
                                upsertConAddress(conAddress);
                            }
                        }
                    }
                    if(addressHome.MCFD_Address_Line_1__c != ''){
                        if(addressHome.Id != null){
                            addressHome = upsertAddress(addressHome);
                        }
                        else{
                            addressHome = upsertAddress(addressHome);
                            conAddress = new MCFD_Contact_Address__c();
                            conAddress.MCFD_Address_Type__c = 'Home Address';
                            conAddress.MCFD_Address__c = addressHome.Id;
                            conAddress.MCFD_Request__c = requestInfo.Id;
                            conAddress.MCFD_Contact__c = contactInfo.Id;
                            upsertConAddress(conAddress);
                        }
                    }    
            }
            requestInfo = upsertRequest(requestInfo); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
      //      mapObj.put('request', requestInfo);
            mapObj.put('primaryApplicant', contactInfo);
            mapObj.put('addressHome', addressHome);
            mapObj.put('addressMail', addressMail);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_PrimaryApplicantIndicateReasonsForCare(Request__c request, Contact contactInfo){
        system.debug('Inside upsert_MCFD_PrimaryApplicantIndicateReasonsForCare');
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        Contact spouse = new Contact();
        try{
            if(contactInfo.LastName != ''){
                contactInfo = upsertContact(contactInfo);
            }
            request = upsertRequest(request);
            delRFCList(contactInfo,request.Id);
            // Build return values
            
       // returnVal = RefreshRFCList(contactInfo,spouse,request);
            mapObj.put('primaryApplicant', contactInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj; 
           
            
            
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpouseIndicateReasonsForCare(Request__c request, Contact contactInfo){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        contact primaryApplicant = new contact();
        try{
            if(contactInfo.LastName != ''){
                contactInfo = upsertContact(contactInfo);
            }
            request = upsertRequest(request); 
            delRFCList(contactInfo,request.Id);
            // Build return values
           // returnVal = RefreshRFCList(primaryApplicant,contactInfo,request);  
            
            
            mapObj.put('applicantSpouse', contactInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpousePersonalInformation(Request__c request, Contact contactInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            if(contactInfo.LastName != ''){
                contactInfo = upsertContact(contactInfo);
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapListObj.put('uploadList', uploadList);
            mapObj.put('applicantSpouse', contactInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_PrimaryApplicantIncomeInformation(Request__c request, Income__c incomeInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            incomeInfo = upsertIncome(incomeInfo);
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            //List<MCFD_Employment_Income__c> emplIncomeLst = new List<MCFD_Employment_Income__c>();
        
            //MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantsEmploymentIncome(request, emplIncomeLst, uploadList);
        
            // Build return values
            mapListObj.put('uploadList', uploadList);
            mapObj.put('paIncome', incomeInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            system.debug('incomeInfo---zzz'+incomeInfo);
            system.debug('returnVal---zzz' +returnVal);
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpouseIncomeInformation(Request__c request, Income__c incomeInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            incomeInfo = upsertIncome(incomeInfo);
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapListObj.put('uploadList', uploadList);
            mapObj.put('spouseIncome', incomeInfo);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RSFNCARE_Employment_Schedule(Request__c request, Reason_For_Care__c empSchInfo, List<Reason_For_Care__c> employerList, List<MCFD_Attachment__c> uploadList){
       system.debug('Inside upsert_MCFD_RSFNCARE_Employment_Schedule');
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            system.debug('empSchInfo: '+empSchInfo);
             system.debug('employerList: '+employerList);
            //empSchInfo = upsertRFC(empSchInfo);
            for(Reason_For_Care__c emp: employerList){
                emp = upsertRFC(emp);
            }
             for(MCFD_Attachment__c item: uploadList){
                system.debug('MCFD_RSFNCARE_Employment_Schedule.MCFD_Page_Name__c--'+item.MCFD_Page_Name__c);
                system.debug('MCFD_RSFNCARE_Employment_Schedule.Id--'+item.Id);
            }
            system.debug('About to upsert RFC');
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('employmentInfo', empSchInfo);
            mapListObj.put('paRFCEmployerList', employerList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RSNFCARE_Self_Employment_Schedule(Request__c request, Reason_For_Care__c apexSelfEmpInfo, List<Reason_For_Care__c> apexBusinessList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
           // apexSelfEmpInfo = upsertRFC(apexSelfEmpInfo);
            for(Reason_For_Care__c emp: apexBusinessList){
                emp = upsertRFC(emp);
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('selfEmploymentInfo', apexSelfEmpInfo);
            mapListObj.put('paRFCBusinessList', apexBusinessList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RSNFCARE_Self_Employment_Schedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_SchoolSchedule(Request__c request, Reason_For_Care__c apexSchoolSchInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            apexSchoolSchInfo = upsertRFC(apexSchoolSchInfo);
                        
            for(MCFD_Attachment__c item: uploadList){
                system.debug('MCFD_RFC_SchoolSchedule.MCFD_Page_Name__c--'+item.MCFD_Page_Name__c);
                system.debug('MCFD_RFC_SchoolSchedule.Id--'+item.Id);
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('schoolSchInfo', apexSchoolSchInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RFC_SchoolSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_EmploymentProgramSchedule(Request__c request, Reason_For_Care__c apexEmpProgSchInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            
            apexEmpProgSchInfo = upsertRFC(apexEmpProgSchInfo);
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('empProgSchInfo', apexEmpProgSchInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            // uncommeting below line as part of bug fix 5909
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RFC_EmploymentProgramSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_Primary_LookingFWorkScreen1(Request__c request){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            system.debug('upsert_MCFD_RFC_Primary_LookingFWorkScreen1: request: '+request);
           
            request = upsertRequest(request);      
             system.debug('After Upsert: request: '+request);
            // Build return values
            mapObj.put('request', request);
            returnVal.mapObj = mapObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_Primary_LookingFWorkScreen2(Request__c request, Reason_For_Care__c apexLookingWorkScrn1){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            system.debug('upsert_MCFD_RFC_Primary_LookingFWorkScreen2: apexLookingWorkScrn1: '+apexLookingWorkScrn1);
            apexLookingWorkScrn1 = upsertRFC(apexLookingWorkScrn1);
            
             system.debug('After : apexLookingWorkScrn1: '+apexLookingWorkScrn1);
            
            request = upsertRequest(request);     
            
            system.debug('After : request: '+request);
            //uploadList = upsertAttachmentList(uploadList);
            
            // Build return values
            
            mapObj.put('lookingWorkScrn1', apexLookingWorkScrn1);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            //returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RFC_Primary_LookingFWorkScreen2()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper usert_MCFD_RFC_MedicalConditions(Request__c request, Reason_For_Care__c apexMedicalCondInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            apexMedicalCondInfo = upsertRFC(apexMedicalCondInfo);
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapObj.put('medicalCondInfo', apexMedicalCondInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.usert_MCFD_RFC_MedicalConditions()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    public static void removeEmploymentIncome(Map<Id,MCFD_Employment_Income__c> empIncomeMap, String incomeId) {
    
    	List<sObject> removedEmpIncome = new List<sObject>();
    	
    	if(string.isNotBlank(incomeId)) {
            	
	            for(MCFD_Employment_Income__c empIncome : [select id from MCFD_Employment_Income__c where Parent_Income_Id__c =: incomeId]) {
            
        			if(empIncomeMap.get(empIncome.Id) == null) {
        				removedEmpIncome.add(empIncome);
        			}
	            
	            }
	            	
        }
            
            // Deletion The employment income 
            if(removedEmpIncome.size()> 0 ) {
            	delete removedEmpIncome;
            }
    
    }
    
    
    
    public static void removeSelfEmploymentIncome(Map<Id,MCFD_Self_Employment_Income__c> empIncomeMap, String incomeId) {
    
    	List<sObject> removedEmpIncome = new List<sObject>();
    	
    	if(string.isNotBlank(incomeId)) {
            	
	            for(MCFD_Self_Employment_Income__c empIncome : [select id from MCFD_Self_Employment_Income__c where Parent_Income_Id__c =: incomeId]) {
            
        			if(empIncomeMap.get(empIncome.Id) == null) {
        				removedEmpIncome.add(empIncome);
        			}
	            
	            }
	            	
        }
            
        // Deletion The employment income 
        if(removedEmpIncome.size()> 0 ) {
        	delete removedEmpIncome;
        }
    
    }
    
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_PrimaryApplicantsEmploymentIncome(Request__c request, List<MCFD_Employment_Income__c> empIncomeList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        Map<Id,MCFD_Employment_Income__c> empIncomeMap = new Map<Id,MCFD_Employment_Income__c>();
        List<MCFD_Employment_Income__c> emplIncomeLst = new List<MCFD_Employment_Income__c>();
        
        string incomeId = [select id from Income__c where MCFD_Related_Request__c =: request.Id AND Income__c.Contact__c =: request.Primary_Applicant__c ].id;
        try{
            // upsert the employment income values
            for(MCFD_Employment_Income__c empInc: empIncomeList){
                if(string.isBlank(empInc.Parent_Income_Id__c)){
                    empInc.Parent_Income_Id__c = incomeId;
                }
                empIncomeMap.put(empInc.Id,empInc);
                emplIncomeLst.add(empInc);
       // empInc = upsertEmploymentIncome(empInc);
            }
            
            if(empIncomeMap.size()>0) {
            	removeEmploymentIncome(empIncomeMap,incomeId);
            
            }
            
            if(emplIncomeLst.size()>0) {
            	upsert emplIncomeLst;
            
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            mapListObj.put('uploadList', uploadList);
            mapListObj.put('paEmpIncomeList', empIncomeList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_PrimaryApplicantSelfEmploymentIncome(Request__c request, List<MCFD_Self_Employment_Income__c> apexPASelfEmpIncomeList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        Map<Id,MCFD_Self_Employment_Income__c> selfEmpIncomeMap = new Map<Id,MCFD_Self_Employment_Income__c>();
        List<MCFD_Self_Employment_Income__c> selfEmplIncomeLst = new List<MCFD_Self_Employment_Income__c>();
        
        
        string incomeId = [select id from Income__c where MCFD_Related_Request__c =: request.Id AND Income__c.Contact__c =: request.Primary_Applicant__c ].id;
        try{
            system.debug('--apexPASelfEmpIncomeList--'+apexPASelfEmpIncomeList);
            for(MCFD_Self_Employment_Income__c inc: apexPASelfEmpIncomeList){
		    if(string.isBlank(inc.Parent_Income_Id__c)){
                    inc.Parent_Income_Id__c = incomeId;
                }
                selfEmpIncomeMap.put(inc.id,inc);
                selfEmplIncomeLst.add(inc);
                
                //inc = upsertSelfEmploymentIncome(inc);
            }
            
            if(selfEmpIncomeMap.size()>0) {
            	removeSelfEmploymentIncome(selfEmpIncomeMap,incomeId);
            
            }
            
            if(selfEmplIncomeLst.size()>0) {
            	upsert selfEmplIncomeLst;
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            
            //mapObj.put('', apexPASelfEmpIncomeList);            
            mapListObj.put('paSelfEmpIncomeList', apexPASelfEmpIncomeList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantSelfEmploymentIncome()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpouseEmploymentIncome(Request__c request, List<MCFD_Employment_Income__c> empIncomeList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        Map<Id,MCFD_Employment_Income__c> empIncomeMap = new Map<Id,MCFD_Employment_Income__c>();
        List<MCFD_Employment_Income__c> emplIncomeLst = new List<MCFD_Employment_Income__c>();
        
        
        string incomeId = [select id from Income__c where MCFD_Related_Request__c =: request.Id AND Income__c.Contact__c =: request.Spouse__c].id;

        try{
            // upsert the employment income values
            for(MCFD_Employment_Income__c empInc: empIncomeList){
                if(string.isBlank(empInc.Parent_Income_Id__c)){
                    empInc.Parent_Income_Id__c = incomeId;
                }
                
                empIncomeMap.put(empInc.Id,empInc);
                emplIncomeLst.add(empInc);
                //empInc = upsertEmploymentIncome(empInc);
            }
            
            // This will work when the user clicks on Remove and Save and Continue for Employment Income Page 
            if(empIncomeMap.size()>0) {
            	removeEmploymentIncome(empIncomeMap,incomeId);
            
            }
            
            if(emplIncomeLst.size()>0) {
            	upsert emplIncomeLst;
            
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapListObj.put('uploadList', uploadList);
            mapListObj.put('spouseEmpIncomeList', empIncomeList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
        
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpouseEmpSchedule(Request__c request, Reason_For_Care__c apexSpouseEmpInfo, List<Reason_For_Care__c> apexSpouseRFCEmployerList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            //apexSpouseEmpInfo = upsertRFC(apexSpouseEmpInfo);
            for(Reason_For_Care__c emp: apexSpouseRFCEmployerList){
                emp = upsertRFC(emp);
            }
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapObj.put('spouseEmpInfo', apexSpouseEmpInfo);
            mapListObj.put('spouseRFCEmployerList', apexSpouseRFCEmployerList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_SpouseEmpSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_spouseSelfEmploymentSchedule(Request__c request, Reason_For_Care__c apexSpouseSelfEmpInfo, List<Reason_For_Care__c> apexSpouseRFCBusinessList, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            //apexSpouseSelfEmpInfo = upsertRFC(apexSpouseSelfEmpInfo);
            for(Reason_For_Care__c emp: apexSpouseRFCBusinessList){
                emp = upsertRFC(emp);
            }
            //request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapObj.put('spouseSelfEmpInfo', apexSpouseSelfEmpInfo);
            mapListObj.put('spouseRFCBusinessList', apexSpouseRFCBusinessList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_spouseSelfEmploymentSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_SpouseSchoolSchedule(Request__c request, Reason_For_Care__c apexSpouseSchoolSchInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            apexSpouseSchoolSchInfo = upsertRFC(apexSpouseSchoolSchInfo);
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapObj.put('spouseSchoolSchInfo', apexSpouseSchoolSchInfo);
            //mapListObj.put('spouseRFCBusinessList', apexSpouseRFCBusinessList);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RFC_SpouseSchoolSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_SpouseSelfEmploymentIncome(Request__c request, List<MCFD_Self_Employment_Income__c> apexSpouseSelfEmpIncInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
         Map<Id,MCFD_Self_Employment_Income__c> selfEmpIncomeMap = new Map<Id,MCFD_Self_Employment_Income__c>();
        List<MCFD_Self_Employment_Income__c> selfEmplIncomeLst = new List<MCFD_Self_Employment_Income__c>();
        
        
        string incomeId = [select id from Income__c where MCFD_Related_Request__c =: request.Id AND Income__c.Contact__c =: request.Spouse__c].id;
	    
        try{
            for(MCFD_Self_Employment_Income__c inc: apexSpouseSelfEmpIncInfo){
		    if(string.isBlank(inc.Parent_Income_Id__c)){
                    inc.Parent_Income_Id__c = incomeId;
                    }
                selfEmpIncomeMap.put(inc.id,inc);
                selfEmplIncomeLst.add(inc);
                
                //inc = upsertSelfEmploymentIncome(inc);
            } 
            
            if(selfEmpIncomeMap.size()>0) {
            	removeSelfEmploymentIncome(selfEmpIncomeMap,incomeId);
            
            }           
            
            if(selfEmplIncomeLst.size()>0) {
            	upsert selfEmplIncomeLst;
            }
                      
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            //mapObj.put('spouseSelfEmpIncomeList', apexSpouseSelfEmpIncInfo);
            mapListObj.put('spouseSelfEmpIncomeList',apexSpouseSelfEmpIncInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_SpouseSelfEmploymentIncome()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_SpouseEmploymentProgramSchedule(Request__c request, Reason_For_Care__c apexSpouseRFCEmpPrgSchInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            apexSpouseRFCEmpPrgSchInfo = upsertRFC(apexSpouseRFCEmpPrgSchInfo);      
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapObj.put('spouseRFCEmpPrgSchInfo', apexSpouseRFCEmpPrgSchInfo);
            //mapListObj.put('spouseRFCEmpPrgSchInfo',apexSpouseRFCEmpPrgSchInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_RFC_SpouseEmploymentProgramSchedule()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_RFC_Spouse_LookingFWorkScreen1(Request__c request){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            request = upsertRequest(request);      
            //uploadList = upsertAttachmentList(uploadList);
            
            // Build return values
            mapObj.put('request', request);
            //mapListObj.put('intAttachmentList',apexRequest);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            //returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_DeclarationandConsent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_Spouse_LookingFWorkScreen2(Request__c request, Reason_For_Care__c apexSpouseLookingWrkScrn1){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexSpouseLookingWrkScrn1 = upsertRFC(apexSpouseLookingWrkScrn1);      
            //uploadList = upsertAttachmentList(uploadList);
            request = upsertRequest(request); 
            // Build return values
            mapObj.put('spouseLookingWrkScrn1', apexSpouseLookingWrkScrn1);
            //mapListObj.put('spouseRFCEmpPrgSchInfo',apexSpouseRFCEmpPrgSchInfo);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_Spouse_LookingFWorkScreen2()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_Spouse_Medical_Conditions(Request__c request, Reason_For_Care__c apexSpouseMedclCondInfo, List<MCFD_Attachment__c> uploadList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{
            apexSpouseMedclCondInfo = upsertRFC(apexSpouseMedclCondInfo);      
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
            uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            mapObj.put('spouseMedclCondInfo', apexSpouseMedclCondInfo);
            //mapListObj.put('spouseRFCEmpPrgSchInfo',apexSpouseRFCEmpPrgSchInfo);
            mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_Spouse_Medical_Conditions()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_Document_Submission(Request__c request, List<MCFD_Attachment__c> apexIntAttachmentList){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        List<SObject> fileList = new List<SObject>();
        
        try{    
            request = upsertRequest(request); 
            upsertAttachmentReturnVal = upsertAttachmentList(apexIntAttachmentList);
            apexIntAttachmentList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            syncFilestoICM(fileList);
            
            // Build return values
            //mapObj.put('intAttachmentList', apexIntAttachmentList);
            mapListObj.put('intAttachmentList',apexIntAttachmentList);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_Document_Submission()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_DeclarationandConsent(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            //uploadList = upsertAttachmentList(uploadList);
            
            // Build return values
            mapObj.put('request', apexRequest);
            //mapListObj.put('intAttachmentList',apexRequest);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            //returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_DeclarationandConsent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_ConsentToShareInfoWithSpouse(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            //uploadList = upsertAttachmentList(uploadList);
            
            // Build return values
            mapObj.put('request', apexRequest);
            //mapListObj.put('intAttachmentList',apexRequest);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            //returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_ConsentToShareInfoWithSpouse()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_CCSSpousalConsent(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            //uploadList = upsertAttachmentList(uploadList);
            
            // Build return values
            mapObj.put('request', apexRequest);
            //mapListObj.put('intAttachmentList',apexRequest);
            //mapListObj.put('uploadList', uploadList);
            returnVal.mapObj = mapObj;
            //returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_CCSSpousalConsent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    
    
    
    // Added by Abhi to insert Income Info  
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_CCS_IncomeInformation(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            
            // Build return values
            mapObj.put('request', apexRequest);
            returnVal.mapObj = mapObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCS_IncomeInformation' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_CCS_CRA_Consent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_CCS_SpouseIncomeInformation(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            
            // Build return values
            mapObj.put('request', apexRequest);
            returnVal.mapObj = mapObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCS_SpouseIncomeInformation' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_CCS_CRA_Consent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    
    /*public static MCFD_CCSReturnTypeWrapper upsert_MCFD_CCS_SpouseIncomeInformation(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            
            // Build return values
            mapObj.put('request', apexRequest);
            returnVal.mapObj = mapObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_CCS_CRA_Consent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }*/
    
    
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsert_MCFD_CCS_CRA_Consent(Request__c apexRequest){
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            apexRequest = upsertRequest(apexRequest);      
            
            // Build return values
            mapObj.put('request', apexRequest);
            returnVal.mapObj = mapObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            System.debug('---MCFD_CCSApplication.upsert_MCFD_CCS_CRA_Consent()---'+e.getMessage()+'  '+e.getStackTraceString());
            return returnVal;
        }
        finally{
            return returnVal;
        }
    }
    
    // Function list to create the standard / custom object upserts
     
    @AuraEnabled
    public static Contact updateContact(Contact contactInfo){
        update contactInfo;
        return contactInfo;
    }
    @AuraEnabled
    public static Contact upsertContact(Contact contactInfo){
        upsert contactInfo;
        return contactInfo;
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper delContactListwithChild(List<SObject> delContactList){
        // List all the child object details
        List<SObject> delContactRFCList = new List<SObject>();
        List<SObject> delContactSEIncomeList = new List<SObject>();
        List<SObject> delContactIncomeList = new List<SObject>();
        List<SObject> delContactEmpIncomeList = new List<SObject>();
        List<SObject> delContactAttachmentList = new List<SObject>();
        List<SObject> delContactFileList = new List<SObject>();
        List<SObject> delContactChildList = new List<SObject>();
        
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        // Query for child objects with all the contacts being deleted
        delContactRFCList = [select Id from Reason_For_Care__c where Contact__c IN :delContactList];
        delContactAttachmentList = [select Id from MCFD_Attachment__c where MCFD_Contact_Id__c IN :delContactList];
        delContactFileList = [select Id, Name from Attachment where ParentId IN :delContactAttachmentList];
        delContactIncomeList = [select Id from Income__c where Contact__c IN :delContactList];
        delContactEmpIncomeList = [select Id from MCFD_Employment_Income__c where Parent_Income_Id__c IN :delContactIncomeList];
        delContactSEIncomeList = [select Id from MCFD_Self_Employment_Income__c where Parent_Income_Id__c IN :delContactIncomeList];
        
        delContactChildList.addAll(delContactRFCList);
        delContactChildList.addAll(delContactFileList);
        delContactChildList.addAll(delContactAttachmentList);
        delContactChildList.addAll(delContactSEIncomeList);
        delContactChildList.addAll(delContactEmpIncomeList);
        delContactChildList.addAll(delContactIncomeList);
        delContactChildList.addAll(delContactList);
        
        Delete delContactChildList;
        
        // Build return values
        mapListObj.put('AttachmentList',delContactAttachmentList);
        mapListObj.put('FileList', delContactFileList);
        returnVal.mapObj = mapObj;
        returnVal.mapListObj = mapListObj;
        return returnVal;
        
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper delIncomeListwithChild(List<SObject> delContactList){
        // List all the child object details
        List<SObject> delContactSEIncomeList = new List<SObject>();
        List<SObject> delContactIncomeList = new List<SObject>();
        List<SObject> delContactEmpIncomeList = new List<SObject>();
        List<SObject> delContactAttachmentList = new List<SObject>();
        List<SObject> delContactFileList = new List<SObject>();
        List<SObject> delIncomeChildList = new List<SObject>();
        List<SObject> delContactChildList = new List<SObject>();
        
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        // Query for child objects with all the contacts being deleted
        delContactIncomeList = [select Id from Income__c where Contact__c IN :delContactList];
        delContactEmpIncomeList = [select Id from MCFD_Employment_Income__c where Parent_Income_Id__c IN :delContactIncomeList];
        delContactSEIncomeList = [select Id from MCFD_Self_Employment_Income__c where Parent_Income_Id__c IN :delContactIncomeList];
        delContactAttachmentList = [select Id from MCFD_Attachment__c where MCFD_Contact_Id__c IN :delContactList AND MCFD_Category__c = 'Proof of Family Income'];
        delContactFileList = [select Id, Name from Attachment where ParentId IN :delContactAttachmentList];
        
        delContactChildList.addAll(delContactFileList);
        delContactChildList.addAll(delContactAttachmentList);
        delContactChildList.addAll(delContactSEIncomeList);
        delContactChildList.addAll(delContactEmpIncomeList);
        delContactChildList.addAll(delContactIncomeList);
        
        Delete delContactChildList;
        
        // Build return values
        mapListObj.put('FileList', delContactFileList);
        mapListObj.put('AttachmentList', delContactAttachmentList);
        returnVal.mapObj = mapObj;
        returnVal.mapListObj = mapListObj;
        return returnVal;
        
    }
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper delRFCList(SObject delContact, ID requestID){
        System.debug('Inside delRFCList: requestID: '+requestID);
        
         System.debug('delContact: '+delContact);
        // List all the child object details
        List<SObject> delContactRFCList = new List<SObject>();
        List<SObject> delContactAttachmentList = new List<SObject>();
        List<SObject> delContactFileList = new List<SObject>();
        List<SObject> delContactChildList = new List<SObject>();
        
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        // Query for child objects with all the contacts being deleted
        delContactRFCList = [select Id from Reason_For_Care__c where Contact__c = :delContact.Id
                             AND (((Contact__r.MCFD_Currently_Employed__c = false) AND (MCFD_Rsn_For_Care_Type__c = 'Employer' OR MCFD_Rsn_For_Care_Type__c = 'Employment'))
                                  OR ((Contact__r.MCFD_Self_Employed__c = false) AND (MCFD_Rsn_For_Care_Type__c = 'Business' OR MCFD_Rsn_For_Care_Type__c = 'Self Employment'))
                                  OR (Contact__r.MCFD_Attending_School__c = false AND MCFD_Rsn_For_Care_Type__c = 'Attending School')
                                  OR (Contact__r.MCFD_Looking_For_Work__c = false AND MCFD_Rsn_For_Care_Type__c = 'Looking for Work')
                                  OR (Contact__r.MCFD_Medical_Condition__c = false AND MCFD_Rsn_For_Care_Type__c = 'Medical Condition')
                                  OR (Contact__r.MCFD_Employment_Prog__c = false AND MCFD_Rsn_For_Care_Type__c = 'Employment Program')
                                 ) AND MCFD_Request__c = :requestId];
                                 
        System.debug('delContactRFCList: '+delContactRFCList);                           
        delContactAttachmentList = [select Id from MCFD_Attachment__c where MCFD_Contact_Id__c = :delContact.Id
                                    AND (((MCFD_Contact_Id__r.MCFD_Currently_Employed__c = false) AND (MCFD_Page_Name__c = 'MCFD_SpouseEmpSchedule' OR MCFD_Page_Name__c = 'MCFD_RSNFCARE_Employment_Schedule'))
                                         OR ((MCFD_Contact_Id__r.MCFD_Self_Employed__c = false) AND (MCFD_Page_Name__c = 'MCFD_spouseSelfEmploymentSchedule' OR MCFD_Page_Name__c = 'MCFD_RSNFCARE_Self_Employment_Schedule'))
                                         OR (MCFD_Contact_Id__r.MCFD_Attending_School__c = false AND (MCFD_Page_Name__c = 'MCFD_RFC_SpouseSchoolSchedule' OR MCFD_Page_Name__c = 'MCFD_RFC_SchoolSchedule'))
                                         OR (MCFD_Contact_Id__r.MCFD_Looking_For_Work__c = false AND (MCFD_Page_Name__c = 'MCFD_Spouse_LookingFWorkScreen2' OR MCFD_Page_Name__c = 'MCFD_RFC_Primary_LookingFWorkScreen2'))
                                         OR (MCFD_Contact_Id__r.MCFD_Medical_Condition__c = false AND (MCFD_Page_Name__c = 'MCFD_Spouse_Medical_Conditions' OR MCFD_Page_Name__c = 'MCFD_RFC_MedicalConditions'))
                                         OR (MCFD_Contact_Id__r.MCFD_Employment_Prog__c = false AND (MCFD_Page_Name__c = 'MCFD_RFC_SpouseEmploymentProgramSchedule' OR MCFD_Page_Name__c = 'MCFD_RFC_EmploymentProgramSchedule'))
                                        ) AND MCFD_Request_Id__c=:requestId];
        delContactFileList = [select Id, Name from Attachment where ParentId IN :delContactAttachmentList];
        
        delContactChildList.addAll(delContactRFCList);
        delContactChildList.addAll(delContactFileList);
        delContactChildList.addAll(delContactAttachmentList);

        Delete delContactChildList;
        
        // Build return values
        mapListObj.put('AttachmentList', delContactAttachmentList);
        mapListObj.put('FileList', delContactFileList);
        returnVal.mapObj = mapObj;
        returnVal.mapListObj = mapListObj;
        return returnVal;
        
    }
    @AuraEnabled
    public static MCFD_Relationship__c upsertRelationship(MCFD_Relationship__c relationship){
        upsert relationship;
        return relationship;
    }
    @AuraEnabled
    public static MCFD_Contact_Address__c upsertConAddress(MCFD_Contact_Address__c conAddress){
        upsert conAddress;
        return conAddress;
    }
    @AuraEnabled
    public static MCFD_Address__c upsertAddress(MCFD_Address__c addressInfo){
        upsert addressInfo;
        return addressInfo;
    }
    @AuraEnabled
    public static Request__c upsertRequest(Request__c requestInfo){
        system.debug('>>>> upsertRequest getting called');
        //ASHAIKH - adding code to remove the pending commit error (you cannot have a callout in the same transaction where DML is invoked)
        if(requestInfo.Id == null)
        {
            insert requestInfo;
            //CreateSR(requestInfo.Id);
            // Bug 4157 - the request returned does not have the update
            Request__c request = [select Id,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c,  MCFD_CCS_Spouse_NoTaxFilingReason__c, Primary_Applicant__c, Incomplete_Pages__c, MCFD_Status__c, MCFD_spousal_consent_signed_date__c,
                       MCFD_spousal_consent_check2__c, MCFD_spousal_consent_check1__c, ICM_SR_Number__c, MCFD_declaration_and_consent_signed_date__c,
                       MCFD_consent_share_info_with_sp_signed__c, MCFD_consent_to_share_info_with_spouse__c, MCFD_DeclarationAndConsent__c,MCFD_CRA_Consent__c,
                       MCFD_CRA_Consent_Signed_Date__c,MCFD_confirm_application__c, MCFD_Navigation_JSON__c, Has_Ans_Consent_to_Share_Info_With_S__c, RecordType.Name,spouse__c,
                       MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,MCFD_hasRFC__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c,MCFD_CCS_IncomeChanged__c,MCFD_CCS_IncomeIncreasedOrDecreased__c, MCFD_CCS_SpouseIncomeChanged__c, MCFD_CCS_SpouseIncomeIncreasedDecreased__c,MCFD_Request_Status_Display_Message__c,createdDate
                       from Request__c where Id = :requestInfo.Id];
            requestInfo = request;
            return requestInfo; 
        }
        else
        {
            upsert requestInfo;
            // adding a request query to fetch the record type in all the pages post saving - for overall ccs renewals / us - 4537
            Request__c request = [select Id,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c, MCFD_CCS_Spouse_NoTaxFilingReason__c, Primary_Applicant__c, Incomplete_Pages__c, MCFD_Status__c, MCFD_spousal_consent_signed_date__c,
                       MCFD_spousal_consent_check2__c, MCFD_spousal_consent_check1__c, ICM_SR_Number__c, MCFD_declaration_and_consent_signed_date__c,
                       MCFD_consent_share_info_with_sp_signed__c, MCFD_consent_to_share_info_with_spouse__c, MCFD_DeclarationAndConsent__c,MCFD_CRA_Consent_Signed_Date__c,
                       MCFD_CRA_Consent__c,MCFD_confirm_application__c, MCFD_Navigation_JSON__c, Has_Ans_Consent_to_Share_Info_With_S__c, RecordType.Name,spouse__c,
                       MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,MCFD_hasRFC__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c,MCFD_CCS_IncomeChanged__c,MCFD_CCS_IncomeIncreasedOrDecreased__c, MCFD_CCS_SpouseIncomeChanged__c, MCFD_CCS_SpouseIncomeIncreasedDecreased__c,MCFD_Request_Status_Display_Message__c,createdDate
                       from Request__c where Id = :requestInfo.Id];
            requestInfo = request;
            return requestInfo;
        }
    }
                     
    @AuraEnabled
    public static Reason_For_Care__c upsertRFC(Reason_For_Care__c rfcInfo){
        upsert rfcInfo;
        return rfcInfo;
    }
    @AuraEnabled
    public static Income__c upsertIncome(Income__c incomeInfo){
        upsert incomeInfo;
        return incomeInfo;
    }
    @AuraEnabled
    public static MCFD_Employment_Income__c upsertEmploymentIncome(MCFD_Employment_Income__c empIncome){
        upsert empIncome;
        return empIncome;
    }
    @AuraEnabled
    public static MCFD_Self_Employment_Income__c upsertSelfEmploymentIncome(MCFD_Self_Employment_Income__c selfEmpIncome){
        upsert selfEmpIncome;
        return selfEmpIncome;
    }
    
    @AuraEnabled
    public static MCFD_CCSReturnTypeWrapper upsertAttachmentList(List<MCFD_Attachment__c> uploadList){
        List<MCFD_Attachment__c> updateUploadList = new List<MCFD_Attachment__c>();
        List<MCFD_Attachment__c> insertUploadList = new List<MCFD_Attachment__c>();
        List<MCFD_Attachment__c> delUploadList = new List<MCFD_Attachment__c>();
        List<Attachment> delFileList = new List<Attachment>();
        String requestId;
        
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        try{
            // Prepare the update and insert list and DML them
            for(MCFD_Attachment__c att: uploadList){
                if(att.Id != null){
                    updateUploadList.add(att);
                }
                else{
                    insertUploadList.add(att);
                }
            }
            update updateUploadList;
            insert insertUploadList;
            
            // Consolidate the insert and update list
            uploadList.clear();
            uploadList.addAll(updateUploadList);
            uploadList.addAll(insertUploadList);
            
            for(MCFD_Attachment__c att: uploadList){
                if(att.MCFD_Request_Id__c != null){
                    requestId = String.valueOf(att.MCFD_Request_Id__c);
                    if(requestId != ''){
                        break;
                    }
                }
            }
            
            //using this temporary list of Ids extracted from uploadList (MCFD_Attachment__c list) because the below SOQL fails due to Spring 19 upgrade due to
            //sciptrowfound error.
            List<Id> tempAttachmentList = new List<Id>();
            for(MCFD_Attachment__c a:uploadList)
            {
                tempAttachmentList.add(a.Id);
            }
            
            // Delete the attachments that are no longer valid
            if(requestId != null && requestId != ''){
                delUploadList = [select Id from MCFD_Attachment__c where MCFD_Request_Id__c = :requestId
                                 AND Id NOT IN :tempAttachmentList];
                delFileList = [select Id, Name from Attachment where ParentId IN :delUploadList];
                Delete delFileList;
                Delete delUploadList;
            }

            // Build return values
            mapListObj.put('AttachmentList', uploadList);
            mapListObj.put('FileList', delFileList);
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            return returnVal;
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return returnVal; 
        }
        finally{
            return returnVal; 
        }
    }
    @AuraEnabled
    public static void syncFilestoICM(List<Attachment> delFileList){
        String XMLrequest = '';
        // Make call to ICM to sync the attachment files
        for(Attachment f:delFileList){
            XMLrequest = getICMRequest(f, 'Delete');    
            MCFD_ContentController.CallICMforAttachmentUpload(f.Id, XMLrequest, 'Delete');
        }
    }
    @AuraEnabled
    public static String getICMRequest(Attachment fileInfo, String strOperationType){
        String masterXmlRet, strFileName, strStdAttchId, strRequestId, strICMAttchId, sr_num;
        MCFD_Document_Integration_Engine__c docEngine = [select Id, ICM_Attachment_Id__c, Parent_Custom_Attachment__c, Parent_Request__c, Parent_Request__r.ICM_SR_Number__c 
                                                         from MCFD_Document_Integration_Engine__c
                                                         where Child_Standard_Attachment__c =: fileInfo.Id limit 1];
        strFileName = fileInfo.Name;
        strRequestId = String.valueOf(docEngine.Parent_Request__c);
        strStdAttchId = String.valueOf(fileInfo.Id);
        SR_num = docEngine.Parent_Request__r.ICM_SR_Number__c;
        strICMAttchId = docEngine.ICM_Attachment_Id__c;
        
        String xmlRequest;
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null, '1.0'); //Start the XML document
        w.writeStartElement(null, 'mcfdAttachment', null);
        
        w.writeStartElement(null,'operationType',null);w.writeCharacters(strOperationType);w.writeEndElement(); 
        w.writeStartElement(null,'sfdcfileName',null);w.writeCharacters(strFileName);w.writeEndElement();
        w.writeStartElement(null,'sfdcAttachmentId',null);w.writeCharacters(strStdAttchId);w.writeEndElement();     
        
        if(strRequestId != Null){
            w.writeStartElement(null,'requestId',null);w.writeCharacters(strRequestId);w.writeEndElement();         
        }
        if(SR_num != Null){
            w.writeStartElement(null,'icm-SR-Number',null);w.writeCharacters(SR_num);w.writeEndElement();   
        }
        if(strICMAttchId != Null){
            w.writeStartElement(null,'icmAttachmentId',null);w.writeCharacters(strICMAttchId);w.writeEndElement();          
        }
        w.writeEndElement();    
        
        xmlRequest = w.getXmlString();
        
        w.close();
        masterXmlRet = xmlRequest;
        return masterXmlRet;
    }
    @AuraEnabled
    public static void submitApplicationSaveMethod(Request__c request){
        
        System.debug('submitApplicationSaveMethod');
        
        /*
        Please write the final Save logic here
        Update the method params as required but make sure "request" is there 
        Update return type as required
        Just make sure the below callout happens at the end in
        case there are no more validation failures.
        */ 
        System.Debug('>>>> Came to submitApplicationSaveMethod');
        // Pavan : Bug Fix 3544 : Only call web service if there is NO incomplete pages
        // Laura : Bug Fix 5358 : Incomplete pages are driven by side bar now, so this needs to be removed
      //  if(request.Incomplete_Pages__c != Null && request.Incomplete_Pages__c.length() > 0){
        //    system.debug('--- Application has incomplete screens -- Do not call ICM web service ---');
      //  }else{
            String reqID = request.id;
            //Get all contacts associated with the request, and reset the NeedIdentificationForRenewal__c boolean to false
            
            
            MCFD_SubmitApplicationXMLGenerator.SubmitCSSApplication(reqID);
            clearRenewalFlags(reqID); 
            
       // }
        
       
    }
     @AuraEnabled
    public static Boolean requestStatusIsSubmitted(ID reqID){
    	List<Request__c> reqList = [SELECT MCFD_Status__c FROM Request__c WHERE id = :reqID LIMIT 1];
    	if(reqList.size()>0){
    		if(reqList[0].MCFD_Status__c == 'Submitted'){
    			return true;
    		}
    	}
    	return false;
    }
       
    @AuraEnabled
    public static void onlySaveApplicationMethod(Request__c request){
        
        System.Debug('>>>> Came to onlySaveApplicationMethod');
        // PDAVE : Bug Fix 4743 
        upsertRequest(request);      
        
       
    }
    
    @AuraEnabled
    public static void saveSideBarJSON(String JSONObject, Id RequestId) {
        System.Debug('>>> Came to the saveSideBarJSON function');
    }
    
    //Spouse consent , Linking application by one time key
    @AuraEnabled
    public static List<String> getRequestIDByLinkingInformation(string oneTimeKey, string enteredDOB){
        system.debug('Inside getRequestIDByLinkingInformation');
        String oneTimeKeyWithoutSpaces = oneTimeKey.trim();
        try{
            List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:UserInfo.getUserId() limit 1];            
            List<Request__c> requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c, Spouse__r.NeedIDForRenewal__c,
                                            Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,
                                             MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
				   	                        MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c,MCFD_Spousal_CRA_Consent__c from Request__c where Linking_One_Time_Password__c=:oneTimeKeyWithoutSpaces];
            Contact userContact = ContactDetails[0].Contact;
            if (Datetime.Now().AddDays(-1)<userContact.Linking_Retry_Time__c && userContact.Linking_Number_Of_Retries__c==integer.valueof(system.label.CCS_Spouse_LinkingMaxNumberOfRetries)){
                List<string> returnValue = new List<string>{'Error', system.label.CCS_Spouse_NumberOFRetriesExceeded};
                return returnValue;                                                             
            }

	    	if (requestList.size()==0){
	    		if (userContact.Linking_Number_Of_Retries__c==null){
	    			userContact.Linking_Number_Of_Retries__c=1;
	    			userContact.Linking_Retry_Time__c=Datetime.now();
	    			update userContact; 
	    		}
	    		else
	    		{
	    			if (Datetime.Now().AddHours(-1*integer.valueof(system.label.Spouse_LinkingBlockingHours))>userContact.Linking_Retry_Time__c)
	    			{
	    				userContact.Linking_Retry_Time__c = Datetime.Now();
	    				userContact.Linking_Number_Of_Retries__c=1;
	    			}
	    			else
	    			{
	    				userContact.Linking_Number_Of_Retries__c+=1;
	    			}
	    			update userContact;
	    		}	    		

				List<string> returnValue = new List<string>{'Error',System.Label.CCS_Spouse_LinkingError_IncorrectKey};
				return returnValue;
	    	}
	    	else{
	    		if (requestList[0].MCFD_Status__c!='Pending Spouse Consent'){
	    			List<string> returnValue = new List<string>{'Error',System.Label.CCS_Spouse_LinkingError_IncorrectStatus};
					return returnValue;
	    		}
	    		if (string.valueOf(requestList[0].spouse__r.BirthDate).substring(0,10) == enteredDOB.substring(0,10)	  )  		 
	    		{ 
                    //commenting below line for remedy 674495 and adding the next line instead
                    //List<Request__c> currentUserRequestList = [Select Id from Request__c where Primary_Applicant__c=:ContactDetails[0].ContactId and MCFD_Status__c<>'Cancelled' and Resolution_Status__c<>'Withdrawn'];
                    
                    List<Request__c> currentUserRequestList = [Select Id from Request__c where 
                                                               (Primary_Applicant__c=:ContactDetails[0].ContactId) and 
                                                               (MCFD_Status__c<>'Closed' and  MCFD_Status__c<>'Cancelled' and Resolution_Status__c<>'Withdrawn')
                                                               and MCFD_Type__c in ('Child Care Subsidy Application', 'Child Care Subsidy Renewal') ];

                    
                    if (currentUserRequestList.size()>0){
                    	MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , System.Label.CCS_Spouse_LinkingError_SameBCeID);
                        List<string> returnValue = new List<string>{'Error',System.Label.CCS_Spouse_LinkingError_SameBCeID};
                        return returnValue; 
                    }
                    
                   //Check if already linked
                	if (requestList[0].Spouse__c == ContactDetails[0].Contact.Id)
                	{
                    	List<string> returnValue = new List<string>();
                    	returnValue.add('Success');
                    	returnValue.add(requestList[0].Id);
                    	return returnValue;                 
                	}                        
	    			//Linking starts here
	    			List<Income__c> incomeList = [Select Id,Contact__c from Income__c where MCFD_Related_Request__c=:requestList[0].Id];
	    			List<Reason_For_Care__c> reasonsforCareList = [Select Id,Contact__c from Reason_For_Care__c where MCFD_Request__c=:requestList[0].Id ];
	    			List<MCFD_Relationship__c> relatedcontacts = [Select Id,MCFD_Child_Contact__c from MCFD_Relationship__c where MCFD_Request__c=:requestList[0].Id AND MCFD_Relationship_Type__c='Spouse' ];
	    			if (relatedcontacts.size()==0)
	    			{	    			
	    				MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , System.Label.CCS_Spouse_LinkingError_NoSpouseInfo);
		    			List<string> returnValue = new List<string>{'Error',System.Label.CCS_Spouse_LinkingError_NoSpouseInfo};
		    			return returnValue; 	    				    				
	    			}
	    			else
	    			{
	    				//updating reason for care
	    				List<Reason_For_Care__c> reasonsforCareListtoUpdate = new List<Reason_For_Care__c> ();
	    				for(Reason_For_Care__c reasonForCare:reasonsforCareList){
	    					if (reasonForCare.Contact__c==requestList[0].Spouse__c){
	    						reasonForCare.Contact__c = ContactDetails[0].ContactId;
	    						reasonsforCareListtoUpdate.add(reasonForCare);
	    					}	    						
	    				}
	    				//updating income
	    				List<Income__c> incomeListtoUpdate = new List<Income__c>();
	    				for(Income__c income:incomeList){
	    					if (income.Contact__c==requestList[0].Spouse__c){
	    						income.Contact__c = ContactDetails[0].ContactId;
	    						incomeListtoUpdate.add(income);
	    					}	    						
	    				}	    				
	    				//updating related contact
	    				ContactDetails[0].Contact.Related_Contact__c = requestList[0].Spouse__c;
                        ContactDetails[0].Contact.Birthdate = requestList[0].Spouse__r.Birthdate;
                                                ContactDetails[0].Contact.NeedIDForRenewal__c = requestList[0].Spouse__r.NeedIDForRenewal__c;
                        ContactDetails[0].Contact.MCFD_Gender__c = requestList[0].Spouse__r.MCFD_Gender__c;   	    				
	    				update ContactDetails[0].Contact;
	    				//updating the relation (request.SpouSe__c and dependant)
	    				relatedcontacts[0].MCFD_Child_Contact__c =ContactDetails[0].ContactId; 
	    				requestList[0].Spouse__c = ContactDetails[0].ContactId;
		    			update relatedcontacts[0];
		    			update requestList[0];
		    			update reasonsforCareListtoUpdate;
		    			update incomeListtoUpdate;
		    			
		    			List<string> returnValue = new List<string>();
		    			returnValue.add('Success');
		    			returnValue.add(requestList[0].Id);
		    			return returnValue;
		    		}     			
    		}
		    	else
		   		{
		   			MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , System.Label.CCS_Spouse_LinkingError_NotMatching);
		   			List<string> returnValue = new List<string>{'Error',System.Label.CCS_Spouse_AppLinking_IncorrectDateOfBirth};
		   			return returnValue; 	    			
	    		}
    		}
    	}
    	catch (exception ex){
    			List<string> returnValue = new List<string>{'Error',Ex.getMessage()};
    			return returnValue;
    		
    	}
    	return null;
    	
    }
    @AuraEnabled    
    public static List<SObject> saveSpouseConsentDetails(Request__c request, Contact spouseContact,List<MCFD_Attachment__c> uploadList){
    	system.debug('Entering saveSpouseConsentDetails');
		try{		
			request = upsertRequest(request);
			spouseContact = upsertContact(spouseContact);
			//Saving attachments
	        Map<String, sobject> mapObj = new Map<String, sobject>();
    	    Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();    		
			MCFD_CCSReturnTypeWrapper upsertAttachmentReturnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
			List<SObject> fileList = new List<SObject>();
			upsertAttachmentReturnVal = upsertAttachmentList(uploadList);
			uploadList = upsertAttachmentReturnVal.mapListObj.get('AttachmentList');
            fileList.addAll(upsertAttachmentReturnVal.mapListObj.get('FileList'));
            return fileList;                       
        }
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            return null;
        }

    }
    @AuraEnabled    
    @future(callout=true)
    public static void submitSpouseConsent(Id requestId){
    	try{
    		System.debug('Inside submitSpouseConsent');
            MCFD_SubmitApplicationXMLGenerator.SubmitCSSApplication(requestId);
            clearRenewalFlags(requestId); 
            
            // Build return values                       
    	}
        catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CCSApplication' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());            
        }
    }
 
     @AuraEnabled
    public static void sendEmailToSpouseWithToken(ID requestID, String aToken, String spouseEmail, ID spouseID){
    	
    	//Is the request being saved prior to this running? The token and the spouse are blank.
    	System.debug('In sendEmailToSpouseWithToken');
    	Request__c req = [SELECT RecordType.Name, spouse__r.NeedIDForRenewal__c, spouse__r.MCFD_HasActiveCRAConsent__c, MCFD_Spousal_CRA_Consent__c, MCFD_Status__c, 
    	spouseEmailMatch__c, MCFD_CCS_SpouseHasFiledTax__c, Spouse__c,  MCFD_CCS_Spouse_NoTaxFilingReason__c, 
    	Linking_One_Time_Password__c,Primary_Applicant__c FROM Request__c WHERE ID = :requestID LIMIT 1]; 
        
        System.debug('spouse is now '+ req.Spouse__c);
    	
    	
    	if((req.spouse__c ==null)&&(spouseID != null))
    		{req.spouse__c = spouseID;
    		}
        
        // Checks if the request is for renewal. Added by Abhi as part of 6054. This will only send the spousal consent if the spouse has not provided any consent or a new spouse has been added and didn't give the consent 
    	if(req.RecordType.Name == 'Renewal') {
    		if((req.spouse__c !=null)) {
    			  if((req.spouse__r.MCFD_HasActiveCRAConsent__c != true)||(req.spouse__r.NeedIDForRenewal__c == true)) {
    	    		req.MCFD_status__c = 'Pending Spouse Consent';
    	    		req.Linking_One_Time_Password__c = aToken;
	    		}
	    		else
	    			return ;
    		} else {
    			return ;
    		}
    			
    	} else {
    	    if((req.spouse__c !=null)) {
    	    // works for the New Application
    		req.MCFD_status__c = 'Pending Spouse Consent';
    		req.Linking_One_Time_Password__c = aToken;
    	    }
    	}
    
        update req;
    	
         // Sending an email if the status is Pending spouse consent. Added by Abhi
        if(req.MCFD_status__c == 'Pending Spouse Consent') {
            List<EmailTemplate> templates = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'MCFD_SpouseConsentEmailTemplate'];
            ID templateID = templates[0].id;
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@gov.bc.ca'];
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			if ( owea.size() > 0 ) {
			    mail.setOrgWideEmailAddressId(owea.get(0).Id);
			}
			else{
				mail.setReplyTo('donotreply@gov.bc.ca');
			}
            //Send an email to the spouse, with the token
            System.debug('Token is '+ aToken+' and requestID is '+requestID);            
            mail.setSaveAsActivity(true);
            mail.setWhatId(requestID);
            mail.setTargetObjectId(spouseID);
            mail.setTemplateId(templateID);
            String[] toAddresses = new String[] {spouseEmail}; 
            mail.setToAddresses(toAddresses);
            
            //mail.setSenderDisplayName('My Family Services');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
        } 
    }
    @AuraEnabled
    public static string validateRequestForRegeneration(){    	
        List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];    	
    	List<Request__c> requestList =[Select Id from Request__c where MCFD_Status__c ='Pending Spouse Consent' and Primary_Applicant__c=:ContactDetails[0].ContactId];
    	if (requestList.size()==0)
    		return '';
    	else
    		return requestList[0].Id;
	        
    	} 

        //THIS METHOD COMPARES DOB AND NMES, AND RETURNS TRUE IF ANY OF THEM HAVE CHANGED
    @AuraEnabled
    public static Boolean hasChildInfoChanged(Contact childContact){
    	
        List<Contact> OldInfo = [SELECT Id, BirthDate, FirstName, MiddleName, LastName FROM Contact WHERE Id =: childContact.Id];

        Boolean returnVal;

        if (OldInfo.size() > 0)
        {	System.debug('Have a record. Old data:');
            System.debug(OldInfo[0].FirstName);
            System.debug(OldInfo[0].MiddleName);
            System.debug(OldInfo[0].LastName);
            System.debug(OldInfo[0].BirthDate);
			System.debug('New data:');
            System.debug(childContact.FirstName);
			System.debug(childContact.MiddleName);
            System.debug(childContact.LastName);
            System.debug(childContact.BirthDate);
            if ((childContact.LastName == OldInfo[0].LastName)&&(childContact.FirstName == OldInfo[0].FirstName)&&(childContact.MiddleName == OldInfo[0].MiddleName)&&(childContact.BirthDate == OldInfo[0].BirthDate))
            {	
                returnVal = false;
            }
            else
            {	
                returnVal = true;
                //update spouse;
            }

            System.debug('returnVal == '+returnVal);
        }
        else
        {	
            returnVal = true;
        }

        return returnVal;    	
    	
    }    

    @AuraEnabled
    public static void RegenerateAccessCode(ID requestID, String spouseEmail, string spouseDOB, string token){
    	system.debug('######spouseDOB'+spouseDOB);
    	List<Request__c> requestList =[Select Id,Spouse__c from Request__c where MCFD_Status__c ='Pending Spouse Consent' and Id=:requestID];
    	Contact spouseContact = new Contact(ID=requestList[0].Spouse__c);
    	spouseContact.Birthdate = Date.valueOf(spouseDOB);
    	spouseContact.Email = spouseEmail;
    	update spouseContact;    	
    	sendEmailToSpouseWithToken(requestID,Token, spouseEmail, requestList[0].Spouse__c);    	
    }
   @AuraEnabled
    public static void clearRenewalFlags(ID reqid){
        System.debug('Inside clearRenewalFlags ');
        List<MCFD_Relationship__c> relationships=[SELECT MCFD_Child_Contact__r.id FROM MCFD_Relationship__c WHERE MCFD_Request__c=:reqid];
			List<ID> contIDs = new List<ID>(); 
			for(MCFD_Relationship__c rel:relationships){
			    contIDs.add(rel.MCFD_Child_Contact__r.id);
			}
            List<Contact> conts = [SELECT NeedIDForRenewal__c,MCFD_SIN__c,MCFD_Reason_for_no_SIN__c FROM Contact WHERE id IN :contIDs];
			for (Contact c:conts){
			    System.debug('DLS--iterating through contacts to remove NeedID');
			    c.NeedIDForRenewal__c =false;
                if((c.MCFD_SIN__c != null) || (c.MCFD_SIN__c != ''))
                {
                	c.MCFD_Reason_for_no_SIN__c = '';
                	System.debug('deleting no sin reason');
                }
			}
			update conts;
    }   
   

//Remedy Bug - Missing RFC #747565
@AuraEnabled
public static MCFD_CCSReturnTypeWrapper RefreshRFCList( contact primaryApplicant,contact spouse,Request__c request) {
    
   
 system.debug('Inside RefreshRFCList');
        
        //Lists pertaining to primaryApplicant
        Reason_For_Care__c employmentInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> paRFCEmployerList = new List<Reason_For_Care__c>();
        Reason_For_Care__c selfEmploymentInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> paRFCBusinessList = new List<Reason_For_Care__c>();
        Reason_For_Care__c schoolSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c empProgSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c lookingWorkScrn1 = new Reason_For_Care__c();
        Reason_For_Care__c medicalCondInfo = new Reason_For_Care__c();
        
        //List pertaining to applicantSpouse
         Reason_For_Care__c spouseEmpInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> spouseRFCEmployerList = new List<Reason_For_Care__c>();
        Reason_For_Care__c spouseSelfEmpInfo = new Reason_For_Care__c();
        List<Reason_For_Care__c> spouseRFCBusinessList = new List<Reason_For_Care__c>();
        Reason_For_Care__c spouseSchoolSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c spouseRFCEmpPrgSchInfo = new Reason_For_Care__c();
        Reason_For_Care__c spouseLookingWrkScrn1 = new Reason_For_Care__c();
        Reason_For_Care__c spouseMedclCondInfo = new Reason_For_Care__c();
        
        List<MCFD_Attachment__c> uploadList = new List<MCFD_Attachment__c>();
        List<Reason_For_Care__c> rfcList = new List<Reason_For_Care__c>();
         
         
        Map<String, sobject> mapObj = new Map<String, sobject>();
        Map<String, list<sobject>> mapListObj = new Map<String, list<sobject>>();
        
        MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
        
        List<Contact> listContact = new List<Contact>();
        
       if(primaryApplicant!=null) listContact.add(primaryApplicant);
       if(spouse!=null) listContact.add(spouse);
      
 
    //reset the lists           
	paRFCEmployerList.clear();
	paRFCBusinessList.clear();
	spouseRFCEmployerList.clear();
	spouseRFCBusinessList.clear();
	uploadList.clear();
	
		
  uploadList = [select Id,Name, MCFD_Page_Name__c, MCFD_Attachment_Name__c, MCFD_Category__c, MCFD_Category_Description__c,
                          MCFD_Status__c, MCFD_Mandatory__c ,MCFD_Type__c, MCFD_Contact_Id__c, MCFD_Income_Id__c, 
                          MCFD_RsnFCare_Id__c, MCFD_Send_Later__c, MCFD_Request_Id__c
                          from MCFD_Attachment__c
                          where MCFD_Request_Id__c = :request.Id];
	
  rfcList = [select Id, MCFD_Additional_Info__c, Contact__c, MCFD_End_Date__c, MCFD_End_Time__c,
                       MCFD_Travel_hours__c, MCFD_Name__c, MCFD_Number_of_hours_per_day_week__c, MCFD_Number_of_hours_per_day_weekend__c,
                       MCFD_Number_of_days_week__c, MCFD_Number_of_days_weekend__c, MCFD_Rsn_For_Care_Type__c, MCFD_Request__c,
                       MCFD_Schedule_Info__c, MCFD_Start_Date__c, MCFD_Start_Time__c, You_Participating_in_the_SPEI_del__c,
                       MCFD_When_do_you_work__c, No_change_in_ST_and_ET_on_M_to_F__c
                       from Reason_For_Care__c
                       where Contact__c in: listContact AND MCFD_Request__c = :request.Id];
  system.debug('RefreshRFCList : rfcList:  '+rfcList);				   
					   
   for(Reason_For_Care__c rfcInfo: rfcList){
                if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    employmentInfo = rfcInfo;
                    paRFCEmployerList.add(rfcInfo);
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment' && rfcInfo.Contact__c == spouse.Id ){
                    spouseEmpInfo = rfcInfo;
                    spouseRFCEmployerList.add(rfcInfo);
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Self Employment' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    selfEmploymentInfo = rfcInfo;
                    paRFCBusinessList.add(rfcInfo);
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Self Employment' && rfcInfo.Contact__c == spouse.Id ){
                    spouseSelfEmpInfo = rfcInfo;
                    spouseRFCBusinessList.add(rfcInfo);
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Medical Condition' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    medicalCondInfo = rfcInfo;
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Medical Condition' && rfcInfo.Contact__c == spouse.Id ){
                    spouseMedclCondInfo = rfcInfo;
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Attending School' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    schoolSchInfo = rfcInfo;
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Attending School' && rfcInfo.Contact__c == spouse.Id ){
                    spouseSchoolSchInfo = rfcInfo;
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Looking for Work' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    lookingWorkScrn1 = rfcInfo;
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Looking for Work' && rfcInfo.Contact__c == spouse.Id ){
                    spouseLookingWrkScrn1 = rfcInfo;
                }
                else if(primaryApplicant!=null &&  rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment Program' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    empProgSchInfo = rfcInfo;
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employment Program' && rfcInfo.Contact__c == spouse.Id ){
                    spouseRFCEmpPrgSchInfo = rfcInfo;
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employer' && rfcInfo.Contact__c == primaryApplicant.Id){
                    paRFCEmployerList.add(rfcInfo);
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Employer' && rfcInfo.Contact__c == spouse.Id){
                    spouseRFCEmployerList.add(rfcInfo);
                }
                else if(primaryApplicant!=null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Business' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    paRFCBusinessList.add(rfcInfo);
                }
                else if(spouse != null && rfcInfo.MCFD_Rsn_For_Care_Type__c == 'Business' && rfcInfo.Contact__c == primaryApplicant.Id ){
                    spouseRFCBusinessList.add(rfcInfo);
                }
    }
		
		
             
             mapObj.put('employmentInfo', employmentInfo);
	         mapObj.put('selfEmploymentInfo', selfEmploymentInfo);
             mapListObj.put('paRFCEmployerList', paRFCEmployerList);
             mapListObj.put('paRFCBusinessList', paRFCBusinessList);
             mapObj.put('schoolSchInfo', schoolSchInfo);
             mapObj.put('empProgSchInfo', empProgSchInfo);
	         mapObj.put('lookingWorkScrn1', lookingWorkScrn1);
	         mapObj.put('medicalCondInfo', medicalCondInfo);
	         
	         
	         mapObj.put('spouseEmpInfo', spouseEmpInfo);
	         mapObj.put('spouseSelfEmpInfo', spouseSelfEmpInfo);
	         mapListObj.put('spouseRFCEmployerList', spouseRFCEmployerList);
             mapListObj.put('spouseRFCBusinessList', spouseRFCBusinessList);
             mapObj.put('spouseSchoolSchInfo', spouseSchoolSchInfo);
             mapObj.put('spouseRFCEmpPrgSchInfo', spouseRFCEmpPrgSchInfo);
	         mapObj.put('spouseLookingWrkScrn1', spouseLookingWrkScrn1);
	         mapObj.put('spouseMedclCondInfo', spouseMedclCondInfo);
	         
	         
	         mapObj.put('request', request);
	         mapListObj.put('uploadList', uploadList);
	         
	         if(primaryApplicant!=null) 
             mapObj.put('primaryApplicant', primaryApplicant);
             if(spouse!=null)
             mapObj.put('applicantSpouse',spouse);
           
            returnVal.mapObj = mapObj;
            returnVal.mapListObj = mapListObj;
            
              
            return returnVal;
			
    }
 
}