/*********************************************************************************************************
Name            : MCFD_SubmitRequest_Test.cls  
Description     : This class is a test class for MCFD_SubmitRequest.cls  
Created By      : Deloitte
Created Date    : 15/May/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      15/May/2017   Original Version
--------------------------------------------------------------------------------------------------------------              
Rosario      15/May/2017   Standards Applied
--------------------------------------------------------------------------------------------------------------
Liliana      21 Jun 2018   Refactoring test methods
***************************************************************************************************************/

@isTest(seeAllData=false)
public class MCFD_SubmitRequest_Test {
    
    @testSetup 
    public static void setup() {
        Account objAccount=TestDataFactory.createAccount('BCAccount');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Intervention Services');
        insert objRequest;
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment; 
        objCustomAttachment.MCFD_Request_Id__c = objRequest.Id;
        update objCustomAttachment;
        
        String strAttchmentId = String.valueOf(objStandarAttachment.Id);
    } 
    
   static testMethod void testAutism() {
        
        // create a request
        Request__c objRequest=[SELECT id, Name FROM Request__c LIMIT 1];  
        objRequest = MCFD_SubmitRequest.insertAutismRequest();
        Id reqId = objRequest.id;
        
        // creating a list of contact which user fills as dependant             
        List<Contact> listContact = new List<Contact>();
        List<Contact> errConlist = new List<Contact>();        
        Contact autismChildone = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = System.Today());
        Contact autismChildtwo = new Contact(LastName = 'TestLN2', FirstName ='TestFN2' ,Birthdate = System.Today());
        Contact autismChildthree = new Contact(LastName = 'TestLN3', FirstName ='TestFN3' ,Birthdate = System.Today());
        
        // creating primary contact
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.BirthDate = System.Today();
        
        listContact.add(AutismChildone );
        listContact.add(AutismChildtwo );
        listContact.add(AutismChildthree );
        
        // create an attachment and relate it with Request      
        MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE 
                                                MCFD_Type__c = 'Document Checklist' LIMIT 1];
        //System.debug('******ATACHMENT**** '+objCustomAttachment);
        objCustomAttachment.MCFD_Request_Id__c = reqId ;
        update objCustomAttachment;
        User objUser = [SELECT id,ContactId, email FROM user WHERE isActive = TRUE AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c FROM Contact WHERE id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.RunAs(objuser) { 
            Test.StartTest();
            // setting up mock webservice response 
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
            
            // calling function
            MCFD_SubmitRequest.updateAutismRequest(objRequest , listContact, contactObj );
            MCFD_SubmitRequest.generateXML(objRequest.Id , 'CCS');
            MCFD_SubmitRequest.generateXML(objRequest.Id, 'Autism');
            MCFD_SubmitRequest.fetchUserWelcomePagePreferenceAgain();
            MCFD_SubmitRequest.upsertContactPref(true);
            MCFD_SubmitRequest.updateAccess_ERROR(objRequest, 'Submitted');
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            Test.StopTest();
            
            List<MCFD_Relationship__c> reltnshpList = new List<MCFD_Relationship__c>();
            reltnshpList = [select id from MCFD_Relationship__c where MCFD_Request__c =:reqId ];
            System.AssertEquals(reltnshpList.size(),3);
            
        }
        
    }
    static testMethod void testAutismFail() {
        
        // create a request
        Request__c objRequest=[SELECT id, Name FROM Request__c LIMIT 1];  
        objRequest = MCFD_SubmitRequest.insertAutismRequest();
        Id reqId = objRequest.id;
        
        // creating a list of contact which user fills as dependant             
        List<Contact> listContact = new List<Contact>();
        List<Contact> errConlist = new List<Contact>();        
        Contact autismChildone = new Contact(LastName = 'TestLN1', FirstName ='TestFN1' ,Birthdate = System.Today());
        Contact autismChildtwo = new Contact(LastName = 'TestLN2', FirstName ='TestFN2' ,Birthdate = System.Today());
        Contact autismChildthree = new Contact(LastName = 'TestLN3', FirstName ='TestFN3' ,Birthdate = System.Today());
        
        // creating primary contact
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.BirthDate = System.Today();
        
        listContact.add(AutismChildone );
        listContact.add(AutismChildtwo );
        listContact.add(AutismChildthree );
        
        // create an attachment and relate it with Request      
        MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE 
                                                MCFD_Type__c = 'Document Checklist' LIMIT 1];
        //System.debug('******ATACHMENT**** '+objCustomAttachment);
        objCustomAttachment.MCFD_Request_Id__c = reqId ;
        update objCustomAttachment;
        User objUser = [SELECT id,ContactId, email FROM user WHERE isActive = TRUE AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c FROM Contact WHERE id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        Account objAccount2=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount2;
        Contact objContact2 = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount2.Id, '', 'Deepak');
        insert objContact2;
         Profile objProfile2=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser2 = TestDataFactory.createUser(objContact2, objProfile2, 'standarduser4@testorg.com', '');
        insert objUser2;
        RecordType objRecordType2 = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest2 = TestDataFactory.createRequest(objUser2, objRecordType2,'Intervention Services');
        System.RunAs(objuser) { 
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            MCFD_SubmitRequest.updateAutismRequest(objRequest2 , listContact, contactObj );
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            
        }
        
    }
    
    
    public static testMethod void insertAndUpdateCCSRequest() {
        
        Request__c objRequest=[SELECT id FROM Request__c LIMIT 1];  
        objRequest = MCFD_SubmitRequest.insertAutismRequest();
        Id reqId = objRequest.id;
        
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.BirthDate = System.Today();
        
        Contact childObj = new Contact();
        childObj.FirstName = 'CFTest';
        childObj.MiddleName = 'CMTest';
        childObj.LastName = 'CLName';
        childObj.BirthDate = System.Today();
        
        String PrimarySin = '123456789';
        
        MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE 
                                                MCFD_Type__c = 'Document Checklist' LIMIT 1];     
        objCustomAttachment.MCFD_Request_Id__c =objRequest.id;
        update objCustomAttachment ;
        
        Attachment objStandarAttachment =[Select id from Attachment WHERE name= 'testFileName'];
        
        User objUser = [SELECT id, ContactId, email FROM user WHERE isActive = TRUE AND Email = 'standarduser@testorg.com' Limit 1];          
        System.RunAs(objuser) { 
            Test.startTest();      
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            MCFD_SubmitRequest.insertCCSRequest();
            MCFD_SubmitRequest.updateCCSRequest(objRequest, contactObj, PrimarySin , childObj);
            Test.stopTest();
            
        }
    }
    
     public static testMethod void insertAndUpdateCCSRequestFail() {
        
        Request__c objRequest=[SELECT id FROM Request__c LIMIT 1];  
        objRequest = MCFD_SubmitRequest.insertAutismRequest();
        Id reqId = objRequest.id;
        
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Test';
        contactObj.MiddleName = 'Test';
        contactObj.LastName = 'Name';
        contactObj.BirthDate = System.Today();
        
        Contact childObj = new Contact();
        childObj.FirstName = 'CFTest';
        childObj.MiddleName = 'CMTest';
        childObj.LastName = 'CLName';
        childObj.BirthDate = System.Today();
        
        String PrimarySin = '123456789';
        
        MCFD_Attachment__c objCustomAttachment=[SELECT id,MCFD_Type__c,MCFD_Contact_Id__c ,MCFD_Attachment_Name__c FROM MCFD_Attachment__c WHERE 
                                                MCFD_Type__c = 'Document Checklist' LIMIT 1];     
        objCustomAttachment.MCFD_Request_Id__c =objRequest.id;
        update objCustomAttachment ;
        
        Attachment objStandarAttachment =[Select id from Attachment WHERE name= 'testFileName'];
        Account objAccount2=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount2;
        Contact objContact2 = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount2.Id, '', 'Deepak');
        insert objContact2;
        User objUser = [SELECT id, ContactId, email FROM user WHERE isActive = TRUE AND Email = 'standarduser@testorg.com' Limit 1];          
        System.RunAs(objuser) {    
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            MCFD_SubmitRequest.insertCCSRequest();
            MCFD_SubmitRequest.updateCCSRequest(objRequest, objContact2, PrimarySin , childObj);
            
        }
    }
    
}