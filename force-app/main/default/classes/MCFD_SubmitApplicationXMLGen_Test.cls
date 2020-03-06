/************************************************************************************
Function        : test class for MCFD_SubmitApplicationXMLGenerator

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Rosario Lopez				25/06/2018				Standards applied
*************************************************************************************/
@isTest(SeeAllData=False)
public class MCFD_SubmitApplicationXMLGen_Test {
    
     @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('BCAccount');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        System.assertEquals(objUser.isActive, true);
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Intervention Services');
        insert objRequest;
    }
    
    public static testMethod void createSubmitXML_Test() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_CalloutCCSApplicationSubmit());
        	// Creation of user context
        	User objUser = [SELECT id, ContactId, ProfileId FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];

        	// Creation of a ccs request
        	Request__c objRequest= new Request__c();  
        	RecordType objRecordType = [select Id from RecordType where sObjectType = 'Request__c' and Name = 'Application'];
        	objRequest.RecordTypeId = objRecordType.Id;
        	objRequest.ICM_SR_Number__c = '1-12345678';
        	objRequest.Primary_Applicant__c = objUser.ContactId;
        	objRequest.MCFD_consent_to_share_info_with_spouse__c = true;
        	objRequest.MCFD_consent_share_info_with_sp_signed__c = 'Consent signed';
        	objRequest.MCFD_spousal_consent_signed_date__c = String.valueOf(System.today());
        	objRequest.MCFD_spousal_consent_check1__c = true;
        	objRequest.MCFD_spousal_consent_check2__c = true;
        	objRequest.MCFD_DeclarationAndConsent__c = true;
        	objRequest.MCFD_declaration_and_consent_signed_date__c = 'Consent signed';
        	insert objRequest;
            objRequest = [Select id, CreatedBy.Id, CreatedBy.Name, Name, MCFD_Service_Provider_Name__c, MCFD_declaration_and_consent_signed_date__c, MCFD_Type__c, 
                   MCFD_DeclarationAndConsent__c, MCFD_spousal_consent_signed_date__c, MCFD_consent_share_info_with_sp_signed__c,
                   MCFD_consent_to_share_info_with_spouse__c, MCFD_Contact__c, ICM_SR_Number__c, MCFD_spousal_consent_check1__c, MCFD_spousal_consent_check2__c, 
                   Primary_Applicant__c, Primary_Applicant__r.Name from Request__c where Id =: objRequest.id];

        	// Adding Contact information - updating applicant
        	Contact applicant = [Select Id, MCFD_BCeID__c, FirstName, MiddleName, LastName, Birthdate, MCFD_Gender__c, MCFD_SIN__c, MCFD_Marital_Status__c, 
                             MCFD_Reason_for_no_SIN__c, MCFD_Is_SW_Referred__c, MCFD_SIN_Expiry_Date__c, MCFD_Govt_Disability_Benefit__c, 
                             Phone, MobilePhone,Email, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c ,MCFD_Address_Check__c, Send_ICM_Contact_ID__c, ICM_Contact_Id__c
                             from Contact where id =:objRequest.Primary_Applicant__c]; 
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
        	MCFD_Relationship__c reltSpouse =  MCFD_TestDataHelper_Test.getRelationship('Spouse' , applicant.id, spouse.id, objRequest.id);
        	MCFD_Relationship__c reltDependant =  MCFD_TestDataHelper_Test.getRelationship('Dependant' , applicant.id, child.id, objRequest.id);
        	reltList.add(reltSpouse);
        	reltList.add(reltDependant);
        	insert reltList;
		
        	// Creating the mailing and home address
        	List<MCFD_Contact_Address__c> conAddList = new List<MCFD_Contact_Address__c>();
        	MCFD_Contact_Address__c conaddHome = MCFD_TestDataHelper_Test.getContactAddressRelt(objRequest.id, applicant.id, 'Home Address');
        	conAddList.add(conaddHome);
        	MCFD_Contact_Address__c conaddMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(objRequest.id, applicant.id, 'Mailing Address');
        	conAddList.add(conaddMailing);
        	MCFD_Contact_Address__c conaddHomeNMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(objRequest.id, applicant.id, 'Home and Mailing Address');
        	conAddList.add(conaddHomeNMailing);
        	insert conAddList;  
        
        	// Creating the RFCs for applicant and spouse
        	List<Reason_For_Care__c> listRFC = new List<Reason_For_Care__c>();
        	Reason_For_Care__c applicantEmployment = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, objRequest.Id, 'Employment');
        	Reason_For_Care__c applicantEmployer = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, objRequest.Id, 'Employer');
        	Reason_For_Care__c applicantSelfEmployment = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, objRequest.Id, 'Self Employment');
        	Reason_For_Care__c applicantBusiness = MCFD_TestDataHelper_Test.getrsnFcare(applicant.Id, objRequest.Id, 'Business');
        	Reason_For_Care__c spouseMedicalInfo = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, objRequest.Id, 'Medical Condition');
        	Reason_For_Care__c spouseLookingforWork = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, objRequest.Id, 'Looking for Work');
        	Reason_For_Care__c spouseEmpProg = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, objRequest.Id, 'Employment Program');
        	Reason_For_Care__c spouseSchool = MCFD_TestDataHelper_Test.getrsnFcare(spouse.Id, objRequest.Id, 'Attending School');
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
        	Income__c applicantIncome = MCFD_TestDataHelper_Test.getCCSIncome(objRequest.Id, applicant.Id);
        	Income__c spouseIncome = MCFD_TestDataHelper_Test.getCCSIncome(objRequest.Id, spouse.Id);
        	Income__c applicantIncome1 = MCFD_TestDataHelper_Test.getCCSIncome(objRequest.Id, applicant.Id);
        	applicantIncome1.MCFD_DisabilityBenefits__c = 'Yes';
        	applicantIncome1.MCFD_RRSPIncome__c = 'Yes';
        	applicantIncome1.MCFD_PensionIncome__c = 'Yes';
        	applicantIncome1.MCFD_No_Income_Description__c = 'Test Description';
        	listIncomes.add(applicantIncome);
        	listIncomes.add(spouseIncome);
        	listIncomes.add(applicantIncome1);
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
        
        	// With different home and mailing address
        	System.RunAs(objUser) {
            	String xml = MCFD_SubmitApplicationXMLGenerator.createSubmitXML(objRequest);
            	System.assertNotEquals(xml, null);
        	} 
        	// Same home and mailing address
        	applicant.MCFD_Address_Check__c = 'Yes';
        	upsert applicant;
        	System.RunAs(objUser) {
            	String xml = MCFD_SubmitApplicationXMLGenerator.createSubmitXML(objRequest);
            	System.assertNotEquals(xml, null);
        	}
        Test.stopTest();
    }
    /*static testMethod void MCFD_SubmitApplicationXMLGenerator() {
        Request__c objRequest = [SELECT ID, Name FROM Request__c LIMIT 1];
        Test.startTest();
        MCFD_SubmitApplicationXMLGenerator.createSubmitXML(objRequest);
        Test.stopTest();
    }*/
    
    public static testMethod void SubmitCSSApplication_Test() {
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_CalloutCCSApplicationSubmit());
			User objUser = [SELECT id, ContactId FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
        	Request__c objRequest=[SELECT id, Name FROM Request__c LIMIT 1]; 
        	String strRequestId = objRequest.Id;
        	System.RunAs(objUser) {
        		MCFD_SubmitApplicationXMLGenerator.SubmitCSSApplication(strRequestId);            
        } 
        Test.stopTest();
    }

}