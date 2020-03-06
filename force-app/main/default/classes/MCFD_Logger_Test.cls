/*********************************************************************************************************
Name            : MCFD_Logger_Test.cls
Description     : This class is to test MCFD_LoggeR.cls functions.
Created By      : Pavan Dave
Created Date    : 19/APR/2017
Modification Log:
--------------------------------------------------------------------------------------------------------------
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                 
Pavan Dave    19/APR/2017   Original Version
Rosario		  16/May/2018	Updated: New method were created to cover 100% of the class
--------------------------------------------------------------------------------------------------------------     
Liliana 	  20/06/2018   Update Methods 
***************************************************************************************/    
@isTest (SeeAllData=false)
public class MCFD_Logger_Test { 
        
        @testSetup 
        static void setup() {
            Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
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
            MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        	insert objCustomAttachment;
        	Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        	insert objStandarAttachment; 
            objCustomAttachment.MCFD_Request_Id__c = objRequest.Id;
        	update objCustomAttachment;
        	String strAttchmentId = String.valueOf(objStandarAttachment.Id);
        	MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine = TestDataFactory.createDocumentIntegrationEngine(objCustomAttachment.Id,strAttchmentId,objRequest.Id, 'Error','Upload', 'SpouseID1.txt');
        	insert objDocumentIntegrationEngine;
        }
        
        static testMethod void logger_inteInfo() {        
            User objUser = [SELECT id FROM User WHERE isActive = TRUE LIMIT 1];                
            Test.startTest();
                System.runAs(objUser) { 
                    MCFD_Logger.log(MCFD_Logger.INFO, 'TestclassTriggerName', 'My Test Message');
                }
            Test.stopTest();
            System.assertEquals(1,[SELECT count() FROM MCFD_Log__c WHERE Class_Trigger_Name__c = 'TestclassTriggerName']);   
            MCFD_Log__c log = [select Priority__c, Class_Trigger_Name__c, Message__c  FROM MCFD_Log__c WHERE Class_Trigger_Name__c = 'TestclassTriggerName'];
            System.assertEquals(MCFD_Logger.INFO,log.Priority__c,'Error');
            System.assertEquals('TestclassTriggerName',log.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',log.Message__c,'Error');                                                
        }  
        
        static testMethod void log_integration_error() {
            User objUser = [SELECT id, Name FROM User WHERE isActive = TRUE LIMIT 1];            
            Test.startTest();
                System.runAs(objUser){
                    MCFD_Logger.log_integration_error('Portal Hub Page', MCFD_Logger.INFO, 'testlogintegrationerror', 'My Test Message');
                }
            Test.stopTest();           
            System.assertEquals(1,[SELECT count() FROM MCFD_Log__c WHERE Class_Trigger_Name__c = 'testlogintegrationerror']);  
            MCFD_Log__c log = [SELECT Priority__c, Class_Trigger_Name__c, Message__c, Interface_Name__c  FROM MCFD_Log__c WHERE Class_Trigger_Name__c = 'testlogintegrationerror'];
            System.assertEquals(MCFD_Logger.INFO,log.Priority__c,'Error');
            System.assertEquals('testlogintegrationerror',log.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',log.Message__c,'Error');   
            System.assertEquals('Portal Hub Page',log.Interface_Name__c,'Error'); 
        }
        
        static testMethod void log_integ_err_for_message() {
            User objUser = [SELECT id, ProfileId FROM User where isActive = true Limit 1];
            Test.startTest();
                System.runAs(objUser) {
                    List<MCFD_Message__c> ListMessages = TestDataFactory.createMessages(2);
                    insert ListMessages;
                    MCFD_Message__c objmessage= [SELECT Id FROM MCFD_Message__c LIMIT 1];
                    MCFD_Logger.log_integ_err_for_message('Portal Hub Page', MCFD_Logger.INFO, 'testlogintegrationerror_message', 'My Test Message', objMessage.id);
                }
            Test.stopTest();            
            System.assertEquals(1,[select count() from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_message']);
            MCFD_Log__c objLog = [select Priority__c, Class_Trigger_Name__c, Message__c, Interface_Name__c  from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_message'];
            System.assertEquals(MCFD_Logger.INFO,objLog.Priority__c,'Error');
            System.assertEquals('testlogintegrationerror_message',objLog.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',objLog.Message__c,'Error');   
            System.assertEquals('Portal Hub Page',objLog.Interface_Name__c,'Error'); 
        }
        
        static testMethod void log_integ_err_for_document() {
            User objUser = [SELECT id, Alias FROM User WHERE isActive = true Limit 1];
            Attachment objStandarAttachment = [SELECT id FROM Attachment LIMIT 1];
            MCFD_Document_Integration_Engine__c objDocumentIntegrationEngine = [SELECT id from MCFD_Document_Integration_Engine__c LIMIT 1];
            Test.startTest();         
                String strAttchmentId = String.valueOf(objStandarAttachment.Id);                
                MCFD_Logger.log_integ_err_for_document('Portal Hub Page', MCFD_Logger.INFO, 'testlogintegrationerror_document', 'My Test Document', objDocumentIntegrationEngine.Id);           
            Test.stopTest();    
            System.assertEquals(1,[select count() from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_document']);
            MCFD_Log__c objLog = [select Priority__c, Class_Trigger_Name__c, Message__c, Interface_Name__c  from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_document'];
            System.assertEquals(MCFD_Logger.INFO,objLog.Priority__c,'Error');
            System.assertEquals('testlogintegrationerror_document',objLog.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Document',objLog.Message__c,'Error');   
            System.assertEquals('Portal Hub Page',objLog.Interface_Name__c,'Error'); 
        }
        
        static testMethod void log_integ_err_for_request() {
            User objUser = [SELECT id, title FROM User where isActive = true Limit 1];
            Request__c objRequest = [SELECT id FROM Request__c LIMIT 1];
            Test.startTest();
                MCFD_Logger.log_integ_err_for_request('Portal Hub Page', MCFD_Logger.INFO, 'testlogintegrationerror_request', 'My Test Message', objRequest.Id);
            Test.stopTest();
            System.assertEquals(1,[select count() from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_request']);
            MCFD_Log__c log = [select Priority__c, Class_Trigger_Name__c, Message__c, Interface_Name__c  from MCFD_Log__c where Class_Trigger_Name__c = 'testlogintegrationerror_request'];
            System.assertEquals(MCFD_Logger.INFO,log.Priority__c,'Error');
            System.assertEquals('testlogintegrationerror_request',log.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',log.Message__c,'Error');   
            System.assertEquals('Portal Hub Page',log.Interface_Name__c,'Error'); 
        }
        
        static testMethod void log_Exception() {        
            User objUser = [SELECT id, Username FROM User where isActive = true Limit 1];    
            Test.startTest();
            System.runAs(objUser) { 
                MCFD_Logger.log_Exception(MCFD_Logger.INFO, 'testlogexceptionclass', 'My Test Message');
            }
            Test.stopTest();            
            System.assertEquals(1,[select count() from MCFD_Log__c where Class_Trigger_Name__c = 'testlogexceptionclass']);
            MCFD_Log__c log = [select Priority__c, Class_Trigger_Name__c, Message__c  from MCFD_Log__c where Class_Trigger_Name__c = 'testlogexceptionclass'];
            System.assertEquals(MCFD_Logger.INFO,log.Priority__c,'Error');
            System.assertEquals('testlogexceptionclass',log.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',log.Message__c,'Error');                                                
        } 
        
        static testMethod void log_for_batch_retry() {
            User objUser = [SELECT id, IsActive FROM User where isActive = true Limit 1];
            Request__c objRequest = [SELECT id, Name FROM Request__c LIMIT 1];
            Test.startTest(); 
                MCFD_Logger.log_for_batch_retry(MCFD_Logger.INFO, 'testlogbatcherror_request', 'My Test Message', 'Document Upload', objRequest.Id);
            Test.stopTest();
            System.assertEquals(1,[select count() from MCFD_Log__c where Class_Trigger_Name__c = 'testlogbatcherror_request']);
            MCFD_Log__c log = [select Priority__c, Class_Trigger_Name__c, Message__c, Interface_Name__c  from MCFD_Log__c where Class_Trigger_Name__c = 'testlogbatcherror_request'];
            System.assertEquals(MCFD_Logger.INFO,log.Priority__c,'Error');
            System.assertEquals('testlogbatcherror_request',log.Class_Trigger_Name__c,'Error');
            System.assertEquals('My Test Message',log.Message__c,'Error');   
        }
    }