/*
Description     : This class is a test class for MCFD_SubmitRequestXMLGenerator  
Created By      : Deloitte
Created Date    : 01 NOV 2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
PDAVE      	01 NOV 2017			Created   
-------------------------------------------------------------------------------------------------------------- 
Rosario		16 JUN 2018		Standards Applied
*/
@isTest(seeAllData=false)
public class MCFD_SubmitRequestXMLGeneratorTest {
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Contact objContact2 = TestDataFactory.createContact('CommunitySumra Community', objAccount.Id, '', 'Gabriela');
        insert objContact2;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        MCFD_Address__c objAddress=TestDataFactory.createMCFDAddress('Test');
        insert objAddress;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'CCS case request');
        Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Intervention Services'); 
        insert objRequest;
        MCFD_Attachment__c attachment = TestDataFactory.createCustomAttachment(objRequest);
        insert attachment;
        attachment.MCFD_Request_Id__c = objRequest.Id;
        update attachment;
        Attachment file = TestDataFactory.createStandardAttachment(attachment.id);
        insert file;
        Attachment file2 = TestDataFactory.createStandardAttachment(attachment.id);
        insert file2;
         
    }
    
    static testMethod void testmethod_SubmitAutismRequest() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
        
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request  
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) { 
            MCFD_SubmitRequest.updateAutismRequest(objReq , conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
                MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(objReq.Id);
            Test.StopTest();
        }
          
    }
    
    static testMethod void testmethod_SubmitAutismRequest_error() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
        
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
        
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;         
        System.runAs(objUser){ 
            MCFD_SubmitRequest.updateAutismRequest(objReq , conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_Error());  
                MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitAutismRequest_notFoundError() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
            
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser){ 
            MCFD_SubmitRequest.updateAutismRequest(objReq , conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_NotFound());  
                MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitAutismRequest_invalidResp() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
            
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) { 
            MCFD_SubmitRequest.updateAutismRequest(objReq, conlist, contactObj );
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_InvalidResp());  
                MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitCSSRequest() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
            
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                          
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) { 
            MCFD_SubmitRequest.updateAutismRequest(objReq, conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());  
                MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitCSSRequest_error() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
            
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) {
            MCFD_SubmitRequest.updateAutismRequest(objReq, conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_Error());
                MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitCSSRequest_notFoundError() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant
        List<Contact> conlist = new List<Contact>();
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
        
        conlist.add(AutismChildone );
        conlist.add(AutismChildtwo );
        conlist.add(AutismChildthree );
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) { 
            MCFD_SubmitRequest.updateAutismRequest(objReq , conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_NotFound());  
                MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(objReq.Id);
            Test.StopTest();
        }   
    }
    
    static testMethod void testmethod_SubmitCSSRequest_invalidResp() {
        Request__c objReq = MCFD_SubmitRequest.insertAutismRequest();
        // creating a list of contact which user fills as dependant             
        List<Contact> conlist = new List<Contact>();
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
            
        conlist.add(AutismChildone);
        conlist.add(AutismChildtwo);
        conlist.add(AutismChildthree);
            
        // create an attachment and relate it with Request      
        MCFD_Attachment__c custAtt = [SELECT id, MCFD_Request_Id__c FROM MCFD_Attachment__c  LIMIT 1];                         
        custAtt.MCFD_Request_Id__c = objReq.Id ;
        update custAtt;
        User objUser = [SELECT id,ContactId, email from user where isActive = true AND Email = 'standarduser@testorg.com' Limit 1];   
        Contact primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =:objUser.ContactId];
        primecon.BirthDate=system.today();
        update primecon;
        System.runAs(objUser) { 
            MCFD_SubmitRequest.updateAutismRequest(objReq, conlist, contactObj);
            Test.StartTest();
                Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_InvalidResp());  
                MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(objReq.Id);
            Test.StopTest();
        }   
    } 
}