/**************************************************************************************
Function        : Test Class for covering the code for - MCFD_RTAXMLGenerator

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                14 NOV 2017             Original Version
* ----------------------------------------------------------------------------                 
* Rosario Lopez             19 JUN 2018             Standards applied
* ----------------------------------------------------------------------------     
*  Liliana                  21 Jun 2018             Refactoring test methods
*************************************************************************************/
@isTest(SeeAllData=false)
public class MCFD_RTAXMLGenerator_Test {
      
    @testSetup 
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('BCAccount');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554322');
        insert objUser;
        System.assertEquals(objUser.isActive, true);
        
        Contact objContactAdmin= new Contact();
        Profile objProfileAdmin=TestDataFactory.getProfile('System Administrator');
        User objUserAdmin = TestDataFactory.createUser(objContactAdmin, objProfileAdmin, 'standarduserAdmin@testorg.com', '');
        insert objUserAdmin;
         
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'RTA');
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
    
    public static testMethod void create_Portal_User_test1(){        
        
        User objUserAdmin = [SELECT id, Name FROM User WHERE email = 'standarduserAdmin@testorg.com' LIMIT 1];

        Request__c objRequest=[SELECT id, RecordType.Name, MCFD_Status__c FROM Request__c LIMIT 1];
        List<Sub_Request__c> subReqList = new List<Sub_Request__c>();
        Sub_Request__c subReq1 = TestDataFactory.createSubReq_PositiveAmtChange(objRequest.Id);
        Sub_Request__c subReq2 = TestDataFactory.createSubReq_NegativeAmtChange(objRequest.Id);
        subReqList.add(subReq1);
        subReqList.add(subReq2);        
        insert subReqList;
           
        List<Sub_Sub_Request__c> subsubReqList = new List<Sub_Sub_Request__c>();
        Sub_Sub_Request__c subsubReq1 = TestDataFactory.createSubSubReq(subReq1.Id, false, '1');
        Sub_Sub_Request__c subsubReq2 = TestDataFactory.createSubSubReq(subReq1.Id, true, '1');
        subsubReqList.add(subsubReq1);
        subsubReqList.add(subsubReq2);          
        insert subsubReqList;
        
        //User objUser = [SELECT id,ContactId, email FROM User WHERE email = 'standarduser@testorg.com' LIMIT 1]; 
        System.runAs(objUserAdmin) { 
           	test.startTest();      
           	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
           	String retStr = MCFD_RTAXMLGenerator.SubmitRTA(objRequest.Id);
           	System.assertNotEquals(null, retStr);
           	test.stopTest(); 
       	}           
                                        
    }   
    
     public static testMethod void create_Portal_User_test1_failure(){        
        User objUserAdmin = [SELECT id, Name FROM User WHERE email = 'standarduserAdmin@testorg.com' LIMIT 1];
                        
        Request__c objRequest=[SELECT id, RecordType.Name, MCFD_Status__c FROM Request__c LIMIT 1];
        List<Sub_Request__c> subReqList = new List<Sub_Request__c>();
        Sub_Request__c subReq1 = TestDataFactory.createSubReq_PositiveAmtChange(objRequest.Id);
        Sub_Request__c subReq2 = TestDataFactory.createSubReq_NegativeAmtChange(objRequest.Id);
        subReqList.add(subReq1);
        subReqList.add(subReq2);        
        insert subReqList;
           
        List<Sub_Sub_Request__c> subsubReqList = new List<Sub_Sub_Request__c>();
        Sub_Sub_Request__c subsubReq1 = TestDataFactory.createSubSubReq(subReq1.Id, false, '1');
        Sub_Sub_Request__c subsubReq2 = TestDataFactory.createSubSubReq(subReq1.Id, true, '1');
        subsubReqList.add(subsubReq1);
        subsubReqList.add(subsubReq2);          
        
        //User objUser = [SELECT id,ContactId, email FROM User WHERE email = 'standarduser@testorg.com' LIMIT 1];  
		System.runAs(objUserAdmin) {
           test.startTest();  
           insert subsubReqList;
               
           Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
           String retStr = MCFD_RTAXMLGenerator.SubmitRTA(objRequest.Id);
           System.assertNotEquals(null, retStr);
           test.stopTest(); 
        } 
                                               
    }   
    
    public static testMethod void create_Portal_User_test1_failureB(){        
        User objUserAdmin = [SELECT id, Name FROM User WHERE email = 'standarduserAdmin@testorg.com' LIMIT 1];
        
		Request__c objRequest=[SELECT id, RecordType.Name, MCFD_Status__c FROM Request__c LIMIT 1];
        List<Sub_Request__c> subReqList = new List<Sub_Request__c>();
        Sub_Request__c subReq1 = TestDataFactory.createSubReq_PositiveAmtChange(objRequest.Id);
        Sub_Request__c subReq2 = TestDataFactory.createSubReq_NegativeAmtChange(objRequest.Id);
        subReqList.add(subReq1);
        subReqList.add(subReq2);        
        insert subReqList;
           
        List<Sub_Sub_Request__c> subsubReqList = new List<Sub_Sub_Request__c>();
        Sub_Sub_Request__c subsubReq1 = TestDataFactory.createSubSubReq(subReq1.Id, false, '1');
        Sub_Sub_Request__c subsubReq2 = TestDataFactory.createSubSubReq(subReq1.Id, true, '1');
        subsubReqList.add(subsubReq1);
        subsubReqList.add(subsubReq2);          
        insert subsubReqList;

        System.runAs(objUserAdmin) {
           test.startTest();  
               
           Test.setMock(HttpCalloutMock.class, new MCFD_Callout_Mock_NotFound());
           String retStr = MCFD_RTAXMLGenerator.SubmitRTA(objRequest.Id);
           System.assertNotEquals(null, retStr);
           test.stopTest(); 
        } 
          
                                     
    }   
    
    public static testMethod void create_Portal_User_test2(){
        User objUserAdmin = [SELECT id, Name FROM User WHERE email = 'standarduserAdmin@testorg.com' LIMIT 1];                    
        
        Request__c objRequest=[SELECT id, RecordType.Name, MCFD_Status__c FROM Request__c LIMIT 1];
        List<Sub_Request__c> subReqList = new List<Sub_Request__c>();
        Sub_Request__c subReq1 = TestDataFactory.createSubReq_PositiveAmtChange(objRequest.Id);
        Sub_Request__c subReq2 = TestDataFactory.createSubReq_NegativeAmtChange(objRequest.Id);
        subReqList.add(subReq1);
        subReqList.add(subReq2);        
        System.runAs(objUserAdmin) {
           test.startTest(); 
           List<Sub_Request__c> returnSubReqList = MCFD_RTAXMLGenerator.createSubRequests_updateReq(subReqList, objRequest.Id, (double)100.00, (double)10.00, 'Yes', 'TestFName', 'TestMName','TestLName','01/06/2018');
           System.assertNotEquals(Null, returnSubReqList);                                                                          
           System.assertNotEquals(0, returnSubReqList.size());
    
        } 
        test.stopTest();   
        
    }
    
    public static testMethod void create_Portal_User_test4(){
        User objUserAdmin = [SELECT id, Name FROM User WHERE email = 'standarduserAdmin@testorg.com' LIMIT 1];
        test.starttest();             
        System.runAs(objUserAdmin) { 
           Request__c objRequest=[SELECT id, RecordType.Name, MCFD_Status__c FROM Request__c LIMIT 1];
           List<Sub_Request__c> subReqList = new List<Sub_Request__c>();
           Sub_Request__c subReq1 = TestDataFactory.createSubReq_PositiveAmtChange(objRequest.Id);
           Sub_Request__c subReq2 = TestDataFactory.createSubReq_NegativeAmtChange(objRequest.Id);
           subReqList.add(subReq1);
           subReqList.add(subReq2);        
           insert subReqList;
           
           List<Sub_Sub_Request__c> subsubReqList = new List<Sub_Sub_Request__c>();
           Sub_Sub_Request__c subsubReq1 = TestDataFactory.createSubSubReq(subReq1.Id, false, '1');
           Sub_Sub_Request__c subsubReq2 = TestDataFactory.createSubSubReq(subReq1.Id, true, '1');
           subsubReqList.add(subsubReq1);
           subsubReqList.add(subsubReq2);          
                       
           List<Sub_Sub_Request__c> retSubSubReqList = MCFD_RTAXMLGenerator.createSubSubRequests(subsubReqList, subReqList);
           
           System.assertNotEquals(Null, retSubSubReqList);                                                                          
           System.assertNotEquals(0, retSubSubReqList.size());         
        } 
        test.stoptest();   
        
    }
    
}