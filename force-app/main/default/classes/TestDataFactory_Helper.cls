@IsTest(SeeAllData=false) 
public class TestDataFactory_Helper {

    // Method is reference of MCFD_Attachment_XML_Helper Case Retry Upload class-----------------------------------------------
   public static testMethod void prepare_Attachment_XML_TestCaseRetryUpload(){
       String returnXML = '';
       Account objAcc = TestDataFactory_Test.getAccount('Test Account');
       insert objAcc;
       Contact objCont = TestDataFactory_Test.getContact('Test lastname',objAcc.Id );
       insert objCont;
       User objUser = TestDataFactory_Test.getUser(objCont);
       insert objUser;
       
       User runAsUser = MCFD_TestDataHelper_Test.getCommunityUser();
       System.RunAs(objUser){
           Request__c ccsRequest = TestDataFactory_Test.getCCSRequest(objUser);
           insert ccsRequest;
           MCFD_Attachment__c attachment = TestDataFactory_Test.customAttachment(ccsRequest);
           insert attachment ;
           Attachment file = TestDataFactory_Test.getFile(attachment.Id);
           insert file;
           attachment.MCFD_Request_Id__c = ccsRequest.Id;
           update attachment;
           String strStdAttchId = String.valueOf(file.Id);
           MCFD_Document_Integration_Engine__c docEngine= TestDataFactory_Test.getDocIE(attachment.Id,strStdAttchId,ccsRequest.Id, '');
           insert docEngine;
            
			Test.startTest();            
           
            returnXML = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(file.Id, 'Retry');
           
            Test.stopTest();
        }
    }  
    
    //End bloque of MCFD_Attachment_XML_Helper Case Retry Upload class class--------------------------------------------------------------
    
    // Method is reference of MCFD_Attachment_XML_Helper Case Retry Delete class-----------------------------------------------
   public static testMethod void prepare_Attachment_XML_TestCaseRetryDelete(){
       String returnXML = '';
       Account objAcc = TestDataFactory_Test.getAccount('Test Account');
       insert objAcc;
       Contact objCont = TestDataFactory_Test.getContact('Test lastname',objAcc.Id );
       insert objCont;
       User objUser = TestDataFactory_Test.getUser(objCont);
       insert objUser;
        
        
        User runAsUser = MCFD_TestDataHelper_Test.getCommunityUser();
        System.RunAs(objUser){
            Request__c ccsRequest = TestDataFactory_Test.getCCSRequest(objUser);
            insert ccsRequest;
            MCFD_Attachment__c attachment = TestDataFactory_Test.customAttachment(ccsRequest);
            insert attachment ;
            Attachment file = TestDataFactory_Test.getFile(attachment.Id);
            insert file;
            attachment.MCFD_Request_Id__c = ccsRequest.Id;
            update attachment;
            String strStdAttchId = String.valueOf(file.Id);
            MCFD_Document_Integration_Engine__c docEngine= TestDataFactory_Test.getDocIE(attachment.Id,strStdAttchId,ccsRequest.Id, '');
            docEngine.Integration_Operation__c = 'Delete';
            insert docEngine;
            
			Test.startTest();            
            
        //    returnXML = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(file.Id, 'Retry');
           
            Test.stopTest();
        }
    }
    //End bloque of MCFD_Attachment_XML_Helper Case Retry Delete class--------------------------------------------------------------
    
    // Method is reference of MCFD_Attachment_XML_Helper Case Insert and Delete class-----------------------------------------------
   public static testMethod void prepare_Attachment_XML_TestCaseInsertAndDelete(){
       String returnXML = '';
       Account objAcc = TestDataFactory_Test.getAccount('Test Account');
       insert objAcc;
       Contact objCont = TestDataFactory_Test.getContact('Test lastname',objAcc.Id );
       insert objCont;
       User objUser = TestDataFactory_Test.getUser(objCont);
       insert objUser;
        
        
       User runAsUser = MCFD_TestDataHelper_Test.getCommunityUser();
       System.RunAs(objUser){
            Request__c ccsRequest = TestDataFactory_Test.getCCSRequest(objUser);
            insert ccsRequest;
            MCFD_Attachment__c attachment = TestDataFactory_Test.customAttachment(ccsRequest);
            insert attachment ;
            Attachment file = TestDataFactory_Test.getFile(attachment.Id);
            insert file;
            attachment.MCFD_Request_Id__c = ccsRequest.Id;
            update attachment;
            String strStdAttchId = String.valueOf(file.Id);
			Test.startTest();            
            returnXML = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(file.Id, 'Insert');
            System.assertNotEquals(Null, returnXML);
            returnXML = MCFD_Attachment_XML_Helper.prepare_Attachment_XML(file.Id, 'Delete');
            System.assertNotEquals(Null, returnXML);
           
            Test.stopTest();
        }
    }
    
    
}