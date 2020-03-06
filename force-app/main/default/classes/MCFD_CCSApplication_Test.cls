@isTest(seeAllData=false)
public class MCFD_CCSApplication_Test {
    @testSetup
    static void setup() { 
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;
        Attachment objStandarAttachment2 =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment2;
        MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment.id, objRequest.id, 'Synced','Upload', 'SpouseID1.txt' );
        insert objDocumentIntegrationEngine;
        MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine2=TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id, objStandarAttachment2.id, objRequest.id, 'Synced','Upload', 'SpouseID1.txt' );
        insert objDocumentIntegrationEngine2;
        MCFD_Address__c createMCFDAddress= TestDataFactory.createMCFDAddress('TestAddress');
        insert createMCFDAddress;
        Request__c objRequestIncome=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	objRequestIncome.Linking_One_Time_Password__c='89141556';
        update objRequestIncome;
        Income__c objIncome = TestDataFactory.createIncome(objRequestIncome.Id, objRequestIncome.Primary_Applicant__c);
        insert objIncome;
        Reason_For_Care__c objReasonForCare = TestDataFactory.createReasonForCare(objRequestIncome.Primary_Applicant__c,objRequestIncome.id, 'Employment');
        insert  objReasonForCare;
        Reason_For_Care__c objReasonForCare2 = TestDataFactory.createReasonForCare(objRequestIncome.Primary_Applicant__c,objRequestIncome.id, 'Self Employment' );
        insert  objReasonForCare2;
		Reason_For_Care__c objReasonForCare3 = TestDataFactory.createReasonForCare(objRequestIncome.Primary_Applicant__c,objRequestIncome.id, 'Attending School');
        insert  objReasonForCare3;
		MCFD_Employment_Income__c objEmploymentIncome =TestDataFactory.createEmploymentIncome(objIncome.id);  
        insert objEmploymentIncome;
        MCFD_Self_Employment_Income__c objSelfEmploymentIncome =TestDataFactory.createSelfEmploymentIncome(objIncome.id);  
        insert objSelfEmploymentIncome;
    } 
    
    static testMethod void syncFilestoICM(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
			List<Attachment> listAttachment = [SELECT ID, Name FROM Attachment]; 
          	User objUser=[Select id,name from User  where email='standarduser@testorg.com'];
       		MCFD_Employment_Income__c objEmploymentIncome =[Select id from MCFD_Employment_Income__c];
        	MCFD_Self_Employment_Income__c objSelfEmploymentIncome=[Select id from MCFD_Self_Employment_Income__c];
            MCFD_CCSApplication.upsertEmploymentIncome(objEmploymentIncome);
        	MCFD_CCSApplication.upsertSelfEmploymentIncome(objSelfEmploymentIncome);
        	MCFD_CCSApplication.syncFilestoICM(listAttachment);
            System.runAs(objUser){
        	MCFD_CCSApplication.validateRequestForRegeneration();
            }
        Test.stopTest();
    }
    
    static testMethod void utilityMethod1(){
        Test.startTest();
        	MCFD_CCSApplication.utilityMethod1();
        Test.stopTest();
    }
    
    static testMethod void getCCSApplicationInfo(){
        Request__c request = [SELECT ID, Name FROM Request__c LIMIT 1];
        Test.startTest();
        	User objUser = [Select id, Name FROM User LIMIT 1]; 
       		MCFD_CCSApplication.getCCSApplicationInfo(request.ID);
        Test.stopTest();
    }
    static testMethod void hasChildInfoChanged(){
        Test.startTest();
       	Contact objContact =TestDataFactory.createChild();
       	insert objContact;
        MCFD_CCSApplication.hasChildInfoChanged(objContact);
        Test.stopTest();
    }
    
    static testMethod void CreateSR(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        	MCFD_CCSApplication.CreateSR('Renewal');
        Test.stopTest();
    }
    
    static testMethod void CreateSRFailNum(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
        	MCFD_CCSApplication.CreateSR('Renewal');
        Test.stopTest();
    }
    
    static testMethod void CreateSRCatch(){
        Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        User objUser=[Select id,name from User  where email='standarduser@testorg.com'];
        System.runAs(objUser){
        MCFD_CCSApplication.CreateSR('Renewal');
    }
    }
    
	static testMethod void upsert_MCFD_SpouseIndicateReasonsForCare(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
            Request__c objRequest=[Select id,name from Request__c LIMIT 1];
            Contact objContact=[select id,name,LastName from Contact LIMIT 1];
            MCFD_CCSApplication.upsert_MCFD_SpouseIndicateReasonsForCare(objRequest, objContact);
        Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_SpouseIndicateReasonsForCareCatch(){
        Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        Request__c objRequest=[Select id,name from Request__c LIMIT 1];
        Contact objContact=[select id,name from Contact LIMIT 1];
        MCFD_CCSApplication.upsert_MCFD_SpouseIndicateReasonsForCare(objRequest, objContact);
    }
    
    static testMethod void upsert_MCFD_SpousePersonalInformation(){
        Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
        Request__c objRequest=[Select id,name from Request__c LIMIT 1];
        Contact objContact=[select id,name,LastName from Contact LIMIT 1];
        List<MCFD_Attachment__c> objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c FROM MCFD_Attachment__c Where MCFD_Type__c = 'Document Checklist'  LIMIT 1];
        MCFD_CCSApplication.upsert_MCFD_SpousePersonalInformation(objRequest, objContact, objCustomAttachment);
    }
    
    static testMethod void onlySaveApplicationMethod(){
        Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
          MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                    List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                    listAttachment.add(objAttachmentWrapper);
                    Map<String, sobject> mapObj = new Map<String, sobject>();
                    Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                    mapObj.put('AttachmentList', objAttachmentWrapper);
                    mapListObj.put('FileList', listAttachment);
                    MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                    returnVal.mapObj = mapObj;
                    returnVal.mapListObj = mapListObj;
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Spouse__c from Request__c LIMIT 1];
        Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c from Contact LIMIT 1];
         objContact.MCFD_Is_SW_Referred__c='Yes';
         update objContact;
        List<Contact> listContact=[select id,name,LastName,MCFD_Childcare_Require__c,MCFD_Is_SW_Referred__c from Contact ];   
        listContact[0].MCFD_Is_SW_Referred__c= 'yes';
         update listContact[0];
         List<Contact> listContact2=[select id,name,LastName,MCFD_Childcare_Require__c,MCFD_Is_SW_Referred__c from Contact ];
        List<MCFD_Attachment__c> objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
        //MCFD_CCSApplication.onlySaveApplicationMethod(objRequest);
        MCFD_CCSApplication.saveSideBarJSON('test',objRequest.Id);
        //MCFD_CCSApplication.submitApplicationSaveMethod(objRequest);
        MCFD_CCSApplication.getRequestIDByLinkingInformation('','');
        MCFD_CCSApplication.saveSpouseConsentDetails(objRequest,objContact,objCustomAttachment);
        MCFD_CCSApplication.submitSpouseConsent(objRequest.Id);
        MCFD_CCSApplication.submitSpouseConsent('0035B00000Jb5IsQAJ');
        MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(objRequest,objContact, objContact, listContact2, 'Test');
    }
    
    static testMethod void onlySaveApplicationMethod2(){  
       Test.startTest();
           Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c,NeedIDForRenewal__c from Contact LIMIT 1];
           Request__c objRequest=[Select id,name,ICM_SR_Number__c,Spouse__c from Request__c LIMIT 1];
           objRequest.Spouse__c=objContact.Id;
           update objRequest;
           MCFD_CCSApplication.onlySaveApplicationMethod(objRequest); 
       Test.stopTest();
    }
    static testMethod void Spouse(){
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
        MCFD_Relationship__c objRecreateRelationship =TestDataFactory.createRelationship('Spouse',objRequest.Primary_Applicant__c, objRequest.Primary_Applicant__c, objRequest.Id);
        insert objRecreateRelationship;
        MCFD_Address__c objAddress =[Select id,MCFD_Address_Line_1__c from MCFD_Address__c LIMIT 1];
        MCFD_Contact_Address__c objContactAddress= TestDataFactory.createContactAddress(objRequest.Id, objRequest.Primary_Applicant__c, 'Home Address', objAddress);
        insert objContactAddress;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
    }
    
    static testMethod void Dependant(){
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
        MCFD_Relationship__c objRecreateRelationship =TestDataFactory.createRelationship('Dependant',objRequest.Primary_Applicant__c, objRequest.Primary_Applicant__c, objRequest.Id);
        insert objRecreateRelationship;
        MCFD_Address__c objAddress =[Select id,MCFD_Address_Line_1__c from MCFD_Address__c LIMIT 1];
        MCFD_Contact_Address__c objContactAddress= TestDataFactory.createContactAddress(objRequest.Id, objRequest.Primary_Applicant__c, 'Home and Mailing Address', objAddress);
        insert objContactAddress;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
    }
    
    static testMethod void DependantAddress(){
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
        MCFD_Relationship__c objRecreateRelationship =TestDataFactory.createRelationship('Dependant',objRequest.Primary_Applicant__c, objRequest.Primary_Applicant__c, objRequest.Id);
        insert objRecreateRelationship;
        MCFD_Address__c objAddress =[Select id,MCFD_Address_Line_1__c from MCFD_Address__c LIMIT 1];
        MCFD_Contact_Address__c objContactAddress= TestDataFactory.createContactAddress(objRequest.Id, objRequest.Primary_Applicant__c, 'Mailing Address', objAddress);
        insert objContactAddress;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
    }
    
    static testMethod void ReasonForCareApplicant(){
        Test.startTest();
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
        MCFD_Relationship__c objRecreateRelationship =TestDataFactory.createRelationship('Dependant',objRequest.Primary_Applicant__c, objRequest.Primary_Applicant__c, objRequest.Id);
        insert objRecreateRelationship;
        MCFD_Address__c objAddress =[Select id,MCFD_Address_Line_1__c from MCFD_Address__c LIMIT 1];
        MCFD_Contact_Address__c objContactAddress= TestDataFactory.createContactAddress(objRequest.Id, objRequest.Primary_Applicant__c, 'Mailing Address', objAddress);
        insert objContactAddress;
        Income__c objIncome = TestDataFactory.createIncome(objRequest.Id, objRequest.Primary_Applicant__c);
        insert objIncome;
        List<Reason_For_Care__c> employerList = new List<Reason_For_Care__c>();
		Reason_For_Care__c objReasonForCare = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Employment');
        insert  objReasonForCare;
        employerList.add(objReasonForCare);
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare2 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Self Employment' );
        insert  objReasonForCare2;
        employerList.add(objReasonForCare2);
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare3 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Medical Condition');
        insert  objReasonForCare3;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare4 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Attending School');
        insert  objReasonForCare4;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare5 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Looking for Work');
        insert  objReasonForCare5;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare6 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Employment Program');
        insert  objReasonForCare6;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare7 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Employer');
        insert  objReasonForCare7;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
		Reason_For_Care__c objReasonForCare8 = TestDataFactory.createReasonForCare(objRequest.Primary_Applicant__c,objRequest.id, 'Business');
        insert  objReasonForCare8;
        MCFD_CCSApplication.getCCSApplicationInfo(objRequest.Id);
}
    
    static testMethod void upsert_MCFD_SpouseIncomeInformation(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		Income__c objIncome = TestDataFactory.createIncome(objRequest.Id, objRequest.Primary_Applicant__c);
        		insert objIncome;
          		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
           		Contact contactInfo =[Select id,LastName from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
         		MCFD_CCSApplication.upsert_MCFD_SpouseIncomeInformation(objRequest, objIncome, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantIncomeInformation(objRequest, objIncome, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_SpousePersonalInformation(objRequest, contactInfo, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_DependantPersonalInformation(objRequest, contactInfo, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_SpouseIndicateReasonsForCare(objRequest, contactInfo);
         		MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantIndicateReasonsForCare(objRequest, contactInfo);
				MCFD_CCSApplication.updateContact(contactInfo);         
         Test.stopTest();
          
    }
    
    static testMethod void upsert_MCFD_PrimaryApplicantPI(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];
         List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
           		Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
        		MCFD_Address__c addressHome=[Select id from MCFD_Address__c ];
        		MCFD_Address__c addressMail=[Select id ,MCFD_Address_Line_1__c  from MCFD_Address__c ];
       		    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(objRequest, contactInfo,  addressHome, addressMail, uploadList);
        		Test.stopTest();
    }
    
      static testMethod void upsert_MCFD_PrimaryApplicantPI2(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];
         List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
           		Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
         		contactInfo.MCFD_Address_Check__c= 'yes';
          		MCFD_Address__c addressHome=[Select id from MCFD_Address__c ];
        		MCFD_Address__c addressMail=[Select id ,MCFD_Address_Line_1__c  from MCFD_Address__c ];
          		addressMail.MCFD_Address_Line_1__c= '';
        		update addressMail;
        		MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(objRequest, contactInfo,  addressHome, addressMail, uploadList);
          		MCFD_Address__c addressMail2=TestDataFactory.createMCFDAddress('');
                MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(objRequest, contactInfo,  addressHome, addressMail2, uploadList);
        Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_PrimaryApplicantPI3(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];
         List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
           		Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
         		contactInfo.MCFD_Address_Check__c= 'yes';
          		MCFD_Address__c addressHome=[Select id,MCFD_Address_Line_1__c from MCFD_Address__c ];
        		MCFD_Address__c addressMail=[Select id ,MCFD_Address_Line_1__c  from MCFD_Address__c ];
          		addressMail.MCFD_Address_Line_1__c= '';
        		update addressMail;
          		MCFD_Address__c addressMail2=TestDataFactory.createMCFDAddress('Test');
                MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(objRequest, contactInfo,  addressHome, addressMail2, uploadList);
        Test.stopTest();
    }
    
       static testMethod void upsert_MCFD_PrimaryApplicantPI4(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];
         List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
           		Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
         		contactInfo.MCFD_Address_Check__c= 'yes';
          		MCFD_Address__c addressHome=[Select id,MCFD_Address_Line_1__c from MCFD_Address__c ];
        		MCFD_Address__c addressMail=[Select id ,MCFD_Address_Line_1__c  from MCFD_Address__c ];
          		addressMail.MCFD_Address_Line_1__c= '';
        		update addressMail;
          		MCFD_Address__c addressHome2=TestDataFactory.createMCFDAddress('Test');
                MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(objRequest, contactInfo,  addressHome2, addressMail, uploadList);
        Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_RSFNCARE_Employment_Schedule(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		Income__c objIncome = TestDataFactory.createIncome(objRequest.Id, objRequest.Primary_Applicant__c);
        		insert objIncome;
          		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
        		Reason_For_Care__c empSchInfo =[Select id from Reason_For_Care__c LIMIT 1 ];
        		List<Reason_For_Care__c> employerList =[Select id from Reason_For_Care__c LIMIT 3];
        		MCFD_CCSApplication.upsert_MCFD_RSFNCARE_Employment_Schedule(objRequest,empSchInfo,  employerList, uploadList);
        		MCFD_CCSApplication.upsert_MCFD_RSNFCARE_Self_Employment_Schedule(objRequest,empSchInfo,  employerList, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_SpouseEmpSchedule(objRequest, empSchInfo, employerList, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_spouseSelfEmploymentSchedule(objRequest, empSchInfo, employerList, uploadList);
         Test.stopTest();
          
    }
    
     static testMethod void upsert_MCFD_RFC_SchoolSchedule(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
        		Reason_For_Care__c objReasonCare =[Select id from Reason_For_Care__c LIMIT 1 ];
        		MCFD_CCSApplication.upsert_MCFD_RFC_SchoolSchedule(objRequest , objReasonCare, uploadList);
                MCFD_CCSApplication.upsert_MCFD_RFC_EmploymentProgramSchedule(objRequest , objReasonCare, uploadList);
         		MCFD_CCSApplication.usert_MCFD_RFC_MedicalConditions(objRequest , objReasonCare, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_RFC_SpouseSchoolSchedule(objRequest , objReasonCare, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_RFC_SpouseEmploymentProgramSchedule(objRequest , objReasonCare, uploadList);
         		MCFD_CCSApplication.upsert_MCFD_Spouse_Medical_Conditions(objRequest , objReasonCare, uploadList);
               Test.stopTest();
    }
     
     static testMethod void upsert_MCFD_RFC_Primary_LookingFWorkScreen1(){
        Test.startTest();
        MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		MCFD_CCSApplication.upsert_MCFD_RFC_Primary_LookingFWorkScreen1(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_RFC_Spouse_LookingFWorkScreen1(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_DeclarationandConsent(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_ConsentToShareInfoWithSpouse(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_CCSSpousalConsent(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_CCS_IncomeInformation(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_CCS_SpouseIncomeInformation(objRequest);
         		MCFD_CCSApplication.upsert_MCFD_CCS_CRA_Consent(objRequest);
               Test.stopTest();
    }
    
     static testMethod void upsert_MCFD_RFC_Primary_LookingFWorkScreen2(){
        Test.startTest();
        		MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                listAttachment.add(objAttachmentWrapper);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachmentWrapper);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
          		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
       	 		Reason_For_Care__c objReasonCare =[Select id from Reason_For_Care__c LIMIT 1 ];		
         		MCFD_CCSApplication.upsert_MCFD_RFC_Primary_LookingFWorkScreen2(objRequest,objReasonCare);
         		MCFD_CCSApplication.upsert_MCFD_Spouse_LookingFWorkScreen2(objRequest,objReasonCare);
         Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_PrimaryApplicantsEmploymentIncome(){
        Test.startTest();
            MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                    List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                    listAttachment.add(objAttachmentWrapper);
                    Map<String, sobject> mapObj = new Map<String, sobject>();
                    Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                    mapObj.put('AttachmentList', objAttachmentWrapper);
                    mapListObj.put('FileList', listAttachment);
                    MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                    returnVal.mapObj = mapObj;
                    returnVal.mapListObj = mapListObj;
            		Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,Spouse__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            		List<MCFD_Employment_Income__c> empIncomeList =[SELECT Id, Parent_Income_Id__c from MCFD_Employment_Income__c];
            		List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            		MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantsEmploymentIncome(objRequest, empIncomeList, uploadList);
        Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_PrimaryApplicantSelfEmploymentIncome(){
        Test.startTest();
            MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                    List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                    listAttachment.add(objAttachmentWrapper);
                    Map<String, sobject> mapObj = new Map<String, sobject>();
                    Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                    mapObj.put('AttachmentList', objAttachmentWrapper);
                    mapListObj.put('FileList', listAttachment);
                    MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                    returnVal.mapObj = mapObj;
                    returnVal.mapListObj = mapListObj;
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,Spouse__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
          	objRequest.Spouse__c =objRequest.Primary_Applicant__c;
            update objRequest;
        	List<SObject> delContactList=[Select id from Contact];
          	List<MCFD_Self_Employment_Income__c> apexPASelfEmpIncomeList =[SELECT Id,Parent_Income_Id__c from MCFD_Self_Employment_Income__c];
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantSelfEmploymentIncome(objRequest, apexPASelfEmpIncomeList, uploadList);
        	MCFD_CCSApplication.upsert_MCFD_SpouseSelfEmploymentIncome(objRequest, apexPASelfEmpIncomeList, uploadList);
        	
      Test.stopTest();
    }
    
    static testMethod void upsert_MCFD_SpouseEmploymentIncome(){
        Test.startTest();
            MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                    List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                    listAttachment.add(objAttachmentWrapper);
                    Map<String, sobject> mapObj = new Map<String, sobject>();
                    Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                    mapObj.put('AttachmentList', objAttachmentWrapper);
                    mapListObj.put('FileList', listAttachment);
                    MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                    returnVal.mapObj = mapObj;
                    returnVal.mapListObj = mapListObj;
 		 Income__c incomeId = [select id,MCFD_Related_Request__c ,Contact__c from Income__c];
         Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,Spouse__c from Request__c where id=: incomeId.MCFD_Related_Request__c];   
         objRequest.Spouse__c=incomeId.Contact__c;
         update objRequest;
         List<MCFD_Employment_Income__c> empIncomeList =[SELECT Id, Parent_Income_Id__c from MCFD_Employment_Income__c];
         List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
         MCFD_CCSApplication.upsert_MCFD_SpouseEmploymentIncome(objRequest, empIncomeList, uploadList);
        Test.stopTest();
    }
    
     static testMethod void upsert_MCFD_Document_Submission(){
        Test.startTest();
            MCFD_Attachment__c objAttachmentWrapper = [SELECT id FROM MCFD_Attachment__c LIMIT 1];   
                    List<MCFD_Attachment__c> listAttachment = [SELECT id FROM MCFD_Attachment__c]; 
                    listAttachment.add(objAttachmentWrapper);
                    Map<String, sobject> mapObj = new Map<String, sobject>();
                    Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                    mapObj.put('AttachmentList', objAttachmentWrapper);
                    mapListObj.put('FileList', listAttachment);
                    MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                    returnVal.mapObj = mapObj;
                    returnVal.mapListObj = mapListObj;
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,Spouse__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c,MCFD_Page_Name__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            MCFD_CCSApplication.upsert_MCFD_Document_Submission(objRequest,uploadList);
        Test.stopTest();
    }
    
    static testMethod void delIncomeListwithChild(){
        Test.startTest();
            Account objAccount=TestDataFactory.createAccount('Deepak Community Account2');
            insert objAccount;
            Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community2', objAccount.Id, '', 'Deepak2');
            insert objContact;
            RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
            Request__c objRequest = TestDataFactory.createRequestContact(objContact.Id, objRecordType,'Travel, Training, Equipment, and Supplies');
            insert objRequest;
            MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
            insert objCustomAttachment;
            Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
            insert objStandarAttachment;
            Request__c objRequestIncome=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            Income__c objIncome = TestDataFactory.createIncome(objRequestIncome.Id, objContact.Id);
            insert objIncome;
            Reason_For_Care__c objReasonForCare = TestDataFactory.createReasonForCare(objContact.Id,objRequestIncome.id, 'Employment');
            insert  objReasonForCare;
            MCFD_Employment_Income__c objEmploymentIncome =TestDataFactory.createEmploymentIncome(objIncome.id);  
            insert objEmploymentIncome;
            MCFD_Self_Employment_Income__c objSelfEmploymentIncome =TestDataFactory.createSelfEmploymentIncome(objIncome.id);  
            insert objSelfEmploymentIncome;
        	List<SObject> delContactList = new List<SObject>();
        	delContactList.add(objContact);
            MCFD_CCSApplication.delContactListwithChild(delContactList);
            MCFD_CCSApplication.delIncomeListwithChild(delContactList);
        Test.stopTest();
    }
    
    static testMethod void RegenerateAccessCode(){
        Contact objSpouse= TestDataFactory.createSpouse();
        insert objSpouse;
        Request__c objRequest =[Select Id,Spouse__c,MCFD_Status__c from Request__c LIMIT 1];
        objRequest.MCFD_Status__c ='Pending Spouse Consent';
        objRequest.Spouse__c =objSpouse.Id;
        update objRequest;
        string year = '2008';
        string month = '10';
        string day = '5';
        string hour = '12';
        string minute = '20';
        string second = '20';
        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' +minute + ':' + second;
       MCFD_CCSApplication.RegenerateAccessCode(objRequest.id, 'test@hotmail.com', stringDate, '1526');        
    }
    
    static testMethod void sendEmailToSpouseWithToken(){
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Renewal');
        Contact Spouse=TestDataFactory.createSpouse();
        insert Spouse;
        Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,Spouse__c ,MCFD_Status__c,RecordTypeId from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
          	objRequest.Spouse__c =objRequest.Primary_Applicant__c;
        	objRequest.MCFD_Status__c ='Pending Spouse Consent';
        	objRequest.RecordTypeId=objRecordType.id;
            update objRequest;
        MCFD_CCSApplication.sendEmailToSpouseWithToken(objRequest.Id, '2553','jsmith@salesforce.com', objRequest.Spouse__c);
    }
    ////////de aqui 2
    static testMethod void getRequestIDByLinkingInformationFail(){
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
        User ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
        Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c,Linking_One_Time_Password__c
                                         from Request__c Limit 1]; 
        string dateName= string.valueOf(ContactDetails.Contact.Birthdate);
        system.runAs(objUser){
         MCFD_CCSApplication.getRequestIDByLinkingInformation('TEST',dateName);
        }       
    }

    static testMethod void getRequestIDByLinkingInformationNull(){
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			 MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
       
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        }       
    }
    
    static testMethod void getRequestIDByLinkingInformation2(){
        Test.startTest();
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			 MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
		 requestList.MCFD_Status__c='Submission Error';	        
         requestList.Spouse__c=ContactDetails[0].Contact.Id; 
         update requestList;        
        system.debug('*****************ContactDetails'+ContactDetails[0].Contact.Id);
        system.debug('*****************Spouse__c'+requestList.Spouse__c);
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        } 
        Test.stopTest();
    }
    
    static testMethod void getRequestIDByLinkingInformation3(){
        Test.startTest();
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			 MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
		 requestList.MCFD_Status__c='Pending Spouse Consent';	        
         requestList.Spouse__c=ContactDetails[0].Contact.Id; 
         update requestList;        
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        } 
        Test.stopTest();
    }
    
    static testMethod void getRequestIDByLinkingInformation4(){
        Test.startTest();
                   system.debug('**::::::::::Metodooooooooooooooooooooo  4----');
		Account objAccount=TestDataFactory.createAccount('Deepak Community Account2');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community2', objAccount.Id, '', 'Deepak2');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser2 = TestDataFactory.createUser(objContact, objProfile, 'standarduser4@testorg.com', '7C01518C8CBD48ED93C10918BD554322');
        insert objUser2;       
    	User objUser=[SELECT Id from User where email='standarduser4@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 //ContactDetails[0].Contact.Birthdate=Date.parse('10/10/1980');
         //update ContactDetails[0];
        string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         system.debug('****************dateName---'+dateName);
         Contact objContactSpouce= TestDataFactory.createSpouse();
         insert objContactSpouce;
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
		 	requestList.MCFD_Status__c='Pending Spouse Consent';
        	requestList.Spouse__c=objContactSpouce.id;
        	requestList.Primary_Applicant__c=ContactDetails[0].Contact.id;
         	update requestList;     
        system.debug('*********************requestList.spouce++++***'+requestList.Spouse__c);
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        }   
        test.stopTest();
    }
    
       static testMethod void getRequestIDByLinkingInformation5(){
           Test.startTest();
           system.debug('**::::::::::Metodooooooooooooooooooooo  5----');
		Account objAccount=TestDataFactory.createAccount('Deepak Community Account2');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community2', objAccount.Id, '', 'Deepak2');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser2 = TestDataFactory.createUser(objContact, objProfile, 'standarduser4@testorg.com', '7C01518C8CBD48ED93C10918BD554322');
        insert objUser2;       
    	User objUser=[SELECT Id from User where email='standarduser4@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
        string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         system.debug('****************dateName---'+dateName);
         Contact objContactSpouce= TestDataFactory.createSpouse();
         insert objContactSpouce;
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
		 	requestList.MCFD_Status__c='Pending Spouse Consent';
        	requestList.Spouse__c=objContactSpouce.id;
         	update requestList;     
           List<MCFD_Relationship__c> relatedcontacts = [Select Id,MCFD_Child_Contact__c,MCFD_Request__c,MCFD_Relationship_Type__c from MCFD_Relationship__c ];
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        }      
           test.stopTest();
    }
    
     static testMethod void getRequestIDByLinkingInformation6(){
           Test.startTest();
           system.debug('**::::::::::Metodooooooooooooooooooooo  5----');
		Account objAccount=TestDataFactory.createAccount('Deepak Community Account2');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community2', objAccount.Id, '', 'Deepak2');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser2 = TestDataFactory.createUser(objContact, objProfile, 'standarduser4@testorg.com', '7C01518C8CBD48ED93C10918BD554322');
        insert objUser2;       
    	User objUser=[SELECT Id from User where email='standarduser4@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
        string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         system.debug('****************dateName---'+dateName);
         Contact objContactSpouce= TestDataFactory.createSpouse();
         insert objContactSpouce;
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
			MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c  where Linking_One_Time_Password__c='89141556'];
		 	requestList.MCFD_Status__c='Pending Spouse Consent';
        	requestList.Spouse__c=objContactSpouce.id;
         	update requestList;     
           //_Relationship__c relatedcontacts =TestData.
           //latedcontacts[0].MCFD_Request__c=requestList.Id ;
           //latedcontacts[0].MCFD_Relationship_Type__c='Spouse' ;
         //date relatedcontacts[0];
        system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        }      
           test.stopTest();
    }
    
    /*
      static testMethod void getRequestIDByLinkingInformation(){
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         Request__c requestList = [Select Id ,MCFD_CCS_SpouseHasFileTax__c,Linking_One_Time_Password__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c ];
         ContactDetails[0].Contact.Linking_Number_Of_Retries__c =5.2;
          update  ContactDetails[0];
         system.runAs(objUser){
              MCFD_CCSApplication.getRequestIDByLinkingInformation('89141557',dateName);
        }       
    }
    */
    /*
    static testMethod void getRequestIDByLinkingInformationFail2(){
    	User objUser=[SELECT Id from User where email='standarduser@testorg.com'];
         List<User> ContactDetails = [select ContactId,Contact.MCFD_BCeID__c, Contact.FirstName,Contact.LastName,Contact.Birthdate,Contact.Related_Contact__c,Contact.Linking_Number_Of_Retries__c,Contact.Linking_Retry_Time__c from user where id =:objUser.Id limit 1];
       	 string dateName= string.valueOf(ContactDetails[0].Contact.Birthdate);
         Request__c requestList = [Select Id ,Linking_One_Time_Password__c,MCFD_CCS_SpouseHasFileTax__c, spouseEmailMatch__c, Spouse__c,Spouse__r.FirstName,Spouse__r.LastName,Spouse__r.Birthdate,Spouse__r.MCFD_Gender__c,MCFD_Status__c,MCFD_CCS_HasFiledTax__c,MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Reason_NotFilingTax__c,
				   	   MCFD_CCS_SpouseHasFiledTax__c,MCFD_CCS_SpouseIncomeDecreased__c,MCFD_CCS_Spouse_DecreaseIncomeReason__c,MCFD_CCS_Spouse_Reason_NotFilingTax__c from Request__c ];
        
         system.runAs(objUser){
             MCFD_CCSApplication.getRequestIDByLinkingInformation('89141556',dateName);
        }       
    }
    */
    static testMethod void upsertRequest(){
        Contact objContact = new Contact();
        Profile objProfile=TestDataFactory.getProfile('System Administrator');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser4@testorg.com', '');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        MCFD_CCSApplication.upsertRequest(objRequest);
    }
    
    static testMethod void upsertRelationship(){
        Contact ParentContact =TestDataFactory.createSpouse();
        insert ParentContact;
        Contact  ChildContact =TestDataFactory.createChild();
        insert ChildContact;
         Request__c objRequest = [Select Id from Request__c ];
        MCFD_Relationship__c objRelashionship = TestDataFactory.createRelationship('Spouse', ParentContact.Id, ChildContact.Id, objRequest.Id);
        insert  objRelashionship;
        MCFD_CCSApplication.upsertRelationship(objRelashionship);
        MCFD_Address__c objAddress = TestDataFactory.createMCFDAddress('Test');
        insert objAddress; 
         MCFD_CCSApplication.upsertAddress(objAddress);
        MCFD_Contact_Address__c objContactAddress = TestDataFactory.createContactAddress(objRequest.Id,  ParentContact.Id, 'Home Address',objAddress);
        insert objContactAddress;
        MCFD_CCSApplication.upsertConAddress(objContactAddress);
    }
    /*
     static testMethod void testCatch(){
        Test.startTest();
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
            Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c from Contact LIMIT 1];
            List<Contact> depList=[select id,name,LastName,MCFD_Is_SW_Referred__c from Contact ];
            depList.add(objContact);
            Contact objSpouce =TestDataFactory.createSpouse();
            insert objSpouce;
            MCFD_CCSApplication.upsert_MCFD_ChildDependantPersonalInformation(objRequest, objContact, objSpouce,  contactInfo, uploadList, depList);
        Test.stopTest();
    } */
    /////////////////////////////////
    static testMethod void test(){
        Test.startTest();
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,MCFD_hasRFC__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
            Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c from Contact LIMIT 1];
            List<Contact> depList=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c from Contact ];
            depList.add(objContact);
            Contact objSpouce =TestDataFactory.createSpouse();
            insert objSpouce;
            MCFD_CCSApplication.upsert_MCFD_ChildDependantPersonalInformation(objRequest, objContact, objSpouce,  contactInfo, uploadList, depList);
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c,MCFD_hasRFC__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
   			Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c ,MCFD_Child_Placement__c,MCFD_Childcare_Require__c,MCFD_Licensed_Preschool__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
            contactInfo.MCFD_Child_Placement__c='Yes';
       		contactInfo.MCFD_Childcare_Require__c='Yes';
            contactInfo.MCFD_Licensed_Preschool__c =true ;
            Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c from Contact LIMIT 1];
            List<Contact> depList=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c from Contact LIMIT 1];
            Contact objSpouce =TestDataFactory.createSpouse();
            insert objSpouce;
            MCFD_CCSApplication.upsert_MCFD_ChildDependantPersonalInformation(objRequest, objContact, objSpouce,  contactInfo, uploadList, depList);
         	MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(objRequest, objContact, objSpouce, depList,'Test');
        Test.stopTest();
    }
    
    static testMethod void MCFD_EnterFamilyCompositionComponentFail(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
            Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
            Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c ,MCFD_Marital_Status__c from Contact LIMIT 1];
            List<Contact> depList=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c from Contact ];
            depList.add(objContact);
            Contact objSpouce =TestDataFactory.createSpouse();
            insert objSpouce;
            MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(objRequest, objContact, objSpouce, depList,'Test');
        Test.stopTest();
    }
    
    static testMethod void MCFD_EnterFamilyCompositionComponent(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
            Request__c objRequest=[Select id,name,ICM_SR_Number__c,Primary_Applicant__c from Request__c where MCFD_Service_Auth_Type__c='Travel, Training, Equipment, and Supplies'  LIMIT 1];     
            List<MCFD_Attachment__c> uploadList=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c,MCFD_Request_Id__c FROM MCFD_Attachment__c WHERE MCFD_Type__c = 'Document Checklist' LIMIT 1];
   			Contact contactInfo =[Select id,LastName,MCFD_Address_Check__c ,MCFD_Child_Placement__c,MCFD_Childcare_Require__c,MCFD_Licensed_Preschool__c from Contact where id=:objRequest.Primary_Applicant__c Limit 1 ];
            contactInfo.MCFD_Child_Placement__c='Yes';
       		contactInfo.MCFD_Childcare_Require__c='Yes';
            contactInfo.MCFD_Licensed_Preschool__c =true ;
            Contact objContact=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Marital_Status__c from Contact LIMIT 1];
            objContact.MCFD_Marital_Status__c='Married, or living in a marriage-like relationship';
            objContact.MCFD_Is_SW_Referred__c = 'Yes';
            List<Contact> depList=[select id,name,LastName,MCFD_Is_SW_Referred__c,MCFD_Childcare_Require__c,MCFD_Child_Placement__c,MCFD_Licensed_Preschool__c from Contact LIMIT 1];
            Contact objSpouce =TestDataFactory.createSpouse();
            insert objSpouce;
        	Contact contact2 = new Contact();
         	Profile objProfile=TestDataFactory.getProfile('System Administrator');
        	User objUser = TestDataFactory.createUser(contact2, objProfile, 'standarduser4@testorg.com', '');
        	insert objUser;
        	RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        	Request__c objRequest2 = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        	MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(objRequest2, objContact, objSpouce, depList,'Test');
        	Request__c objRequest3= TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
        	Contact objSpouce2 =TestDataFactory.createSpouse();
        	MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(objRequest3, objContact, objSpouce, depList,'Test');
        Test.stopTest();
    }
    
    static testMethod void syncFilestoICMElse(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
          	User objUser=[Select id,name from User  where email='standarduser@testorg.com'];
        	List<User> ContactDetails = [select ContactId from user where id =:objUser.Id limit 1]; 
        	List<Request__c> requestList =[Select Id,MCFD_Status__c,Primary_Applicant__c from Request__c];
        	requestList[0].MCFD_Status__c='Pending Spouse Consent';
        	update requestList[0];
            System.runAs(objUser){
        	MCFD_CCSApplication.validateRequestForRegeneration();
            }
        Test.stopTest();
    }
    
    static testMethod void requestStatusIsSubmitted(){
        List<Request__c> requestList =[Select Id,MCFD_Status__c,Primary_Applicant__c from Request__c];
        MCFD_CCSApplication.requestStatusIsSubmitted(requestList[0].Id);
        Request__c request =[Select Id,MCFD_Status__c,Primary_Applicant__c from Request__c];
        request.MCFD_Status__c='Submitted';
        update request;
        MCFD_CCSApplication.requestStatusIsSubmitted(request.Id);
     }
   
}