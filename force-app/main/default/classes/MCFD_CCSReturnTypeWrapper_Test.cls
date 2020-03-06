/*********************************************************************************************************
Name            : MCFD_CCSReturnTypeWrapper_Test.cls  
Description     : This class is to test MCFD_CCSReturnTypeWrapper.cls functions. 
Created By      : Deloitte
Created Date    : 
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Gabriela   08/06/2018     Code Standards applyed 
--------------------------------------------------------------------------------------------------------------            
***************************************************************************************************************/
@isTest
public class MCFD_CCSReturnTypeWrapper_Test {
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
        
    }
    
    static testMethod void MCFD_CCSReturnTypeWrapper_Test() {
        Test.startTest();
            User objUser = [SELECT Id, Name,email FROM User WHERE email='standarduser@testorg.com'];
            MCFD_Attachment__c objAttachment = [SELECT id FROM MCFD_Attachment__c];   
                List<MCFD_Attachment__c> listAttachment = new List<MCFD_Attachment__c>();
                listAttachment.add(objAttachment);
                Map<String, sobject> mapObj = new Map<String, sobject>();
                Map<String, List<sobject>> mapListObj = new Map<String, List<sobject>>();
                mapObj.put('AttachmentList', objAttachment);
                mapListObj.put('FileList', listAttachment);
                MCFD_CCSReturnTypeWrapper returnVal = new MCFD_CCSReturnTypeWrapper(mapObj, mapListObj);
                System.assertNotEquals(null, returnVal);
                returnVal.mapObj = mapObj;
                returnVal.mapListObj = mapListObj;
        Test.stopTest();
    }
}