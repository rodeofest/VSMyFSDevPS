/*********************************************************************************************************
Name            : MCFD_Document_Trigger_Helper_Test.cls  
Description     : This class is to test MCFD_Document_Trigger_Helper.cls functions.
Created By      : Deloitte ARDC
Created Date    : 11/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Gabriela      11/May/2018
***************************************************************************************************************/

@isTest(seeAllData=false)
public class MCFD_Document_Trigger_Helper_Test {
    @testSetup
    static void setup(){
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
        MCFD_Attachment__c attachment = TestDataFactory.createCustomAttachment(objRequest);
            insert attachment ;
        List<attachment> listFile= new List<attachment>();
        for(integer a=0;a<=6; a++){
            attachment file = TestDataFactory.createStandardAttachment(attachment.id); 
            listFile.add(file);
        }
        insert listFile;
        list<MCFD_Document_Integration_Engine__c> listDocument= new list<MCFD_Document_Integration_Engine__c> ();
        for(integer a=0; a<=5;a++){
            MCFD_Document_Integration_Engine__c docEngine= TestDataFactory.createDocumentIntegrationEngine(attachment.Id,listFile[a].id,objRequest.Id, 'Pending Submission','Upload','SpouseID1.txt');
            listDocument.add(docEngine);
       }
        insert listDocument;
    }
    static testMethod void reSubmitDocument(){
        test.startTest();
            List<Id> docIdList=new List<Id>();
        for (MCFD_Document_Integration_Engine__c doc:[select id from MCFD_Document_Integration_Engine__c limit 6]){
                docIdList.add(doc.Id); 
            } 
            
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
            MCFD_Document_Trigger_Helper.reSubmitDocument(docIdList);
        test.stopTest();
                
    }
    static testMethod void reSubmitDocument2(){
        test.startTest();
        List<Id> docIdList=new List<Id>();
        for (MCFD_Document_Integration_Engine__c doc:[select id from MCFD_Document_Integration_Engine__c limit 1]){
            docIdList.add(doc.Id); 
        }
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
        MCFD_Document_Trigger_Helper.reSubmitDocument(docIdList);
        test.stopTest();
    }
}