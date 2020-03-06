/*********************************************************************************************************
Name            : Controller_EstimatorFrom_Test.cls  
Description     : This class is to test Controller_EstimatorForm.cls functions. 
Created By      : ARDC ICM
Created Date    : 15/06/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   15/06/2018   Original version 
--------------------------------------------------------------------------------------------------------------
Gabriela       27/06/2018    Updated methods
***************************************************************************************************************/
@isTest(seeAllData=false)
public class Controller_EstimatorForm_Test {
    @testSetup 
    static void setup() {
        /*Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
insert objAccount;
Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
insert objContact;
Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
insert objUser;
RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
Request__c objRequest = TestDataFactory.createRequest(objUser, objRecordType,'Travel, Training, Equipment, and Supplies');
insert objRequest;*/
    }
    static testMethod void test_Controller_EstimatorForm() {
        Test.startTest();
        Controller_EstimatorForm ControllerTest = new Controller_EstimatorForm();
        ControllerTest.Controller_EstimatorForm();
        Test.stopTest();
    }
    
    static testMethod void test_CreateChildren() {
        Test.startTest();
        Controller_EstimatorForm.createChildren(5);
        Test.stopTest();
    }
    static testMethod void test_EstimateSubsidy() {
        Test.startTest();
        //example 1
        String JsonExample1 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"1","age":"2"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"2","age":"2"}]';
        //example 2
        String JsonExample2 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":1,"age":1},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"2","age":"1"}]';
        //example 3
        String JsonExample3 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":4.5,"saturdayCare":null,"requiresCare":true,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":0,"age":4},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":false,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"1","age":"1"}]';
        //example 4
        String JsonExample4 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":0,"age":4},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"1"}]';
        //code 1
        Controller_EstimatorForm.estimateSubsidy('4.5', 4, 8, 9,JsonExample1);
        //code 2
        Controller_EstimatorForm.estimateSubsidy('4.5', 4, 8, 9,JsonExample2);
        //code 3
        Controller_EstimatorForm.estimateSubsidy('4.5', 4, 8, 9,JsonExample3);
        //code 4
        Controller_EstimatorForm.estimateSubsidy('150000', 4, 8, 9,JsonExample4);
        Test.stopTest();
    }
    static testmethod void test_LicensedIncomeLevel1() {
        String JsonExample5 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"4","age":"3"}]';
        String JsonExample6 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"5","age":"5"}]';
        Controller_EstimatorForm.estimateSubsidy('56000', 4, 8, 9,JsonExample5);  
        Controller_EstimatorForm.estimateSubsidy('70000', 4, 8, 9,JsonExample6);  
    }
    static testmethod void test_LicensedIncomeLeve2() {
        String JsonExample7 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":0,"age":"3"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"3"}]';
        String JsonExample8 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":0,"age":"4"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('56000', 4, 8, 9,JsonExample7);  
        Controller_EstimatorForm.estimateSubsidy('79999', 4, 8, 9,JsonExample8);  
    }
    
    static testmethod void test_LicensedIncomeLevel3() {
        String JsonExample9 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":0,"age":"3"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"3"}]'; 
        String JsonExample10 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":0,"age":4},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('90000', 4, 8, 9,JsonExample9);
        Controller_EstimatorForm.estimateSubsidy('90000', 4, 8, 9,JsonExample10);   
        
    } static testmethod void test_LicensedIncomeLevel4() {
        String JsonExample11 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":"2","age":"3"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"3"}]'; 
        String JsonExample12 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":false,"schoolAmount":"4.5","saturdayCare":null,"requiresCare":true,"registeredAmount":"6.4","preschoolAmount":"4.6","name":null,"mondayCare":null,"LNRAmount":"4.6","inHomeAmount":"3.0","groupAmount":"4.5","fridayCare":null,"familyAmount":"3.0","childCount":"3","age":4},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":"3.5","saturdayCare":null,"requiresCare":false,"registeredAmount":"4.5","preschoolAmount":"4.3","name":null,"mondayCare":null,"LNRAmount":"3.0","inHomeAmount":"3.2","groupAmount":"4.2","fridayCare":null,"familyAmount":"0.5","childCount":"1","age":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('120000', 4, 8, 9,JsonExample11);
        Controller_EstimatorForm.estimateSubsidy('120999', 4, 8, 9,JsonExample12);        
    }  
    static testmethod void test_UnlicensedIncomeLevel1() {
        String JsonExample9 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"4","age":"3"}]';
        String JsonExample10 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"5","age":"5"}]';
        Controller_EstimatorForm.estimateSubsidy('79999.99', 3, 8, 9,JsonExample9);
        Controller_EstimatorForm.estimateSubsidy('39000.99', 3, 3, 9,JsonExample10);        
    }
    static testmethod void test_UnlicensedIncomeLevel2() {
        Test.startTest();
        //example 2
        String JsonExample2 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":1,"age":1},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"2","age":"1"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"3","age":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('55000', 4, 8, 9,JsonExample2);
        String JsonExample3 ='[{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":true,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":1,"age":1},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"2","age":"1"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"3","age":"1"},{"wednesdayCare":null,"tuesdayCare":null,"thursdayCare":null,"sundayCare":null,"specialNeeds":null,"schoolAmount":null,"saturdayCare":null,"requiresCare":null,"registeredAmount":null,"preschoolAmount":null,"name":null,"mondayCare":null,"LNRAmount":null,"inHomeAmount":null,"groupAmount":null,"fridayCare":null,"familyAmount":null,"childCount":"3","age":"2"}]';
        Controller_EstimatorForm.estimateSubsidy('39000', 4, 8, 9,JsonExample3);
        Test.stopTest();
    }
    
    static testmethod void test_HomeIncomeLevel2() {
        Test.startTest();
        //example 2
        String JsonExample1 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('55000', 4, 8, 9,JsonExample1);
        
        String JsonExample2 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"2","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('55000', 4, 8, 9,JsonExample2);
        
        String JsonExample3 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"3","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('55000', 4, 8, 9,JsonExample3);
        
        String JsonExample4 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"4","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('55000', 4, 8, 9,JsonExample4);
        
        
        String JsonExample5 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"5","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('105000', 4, 8, 9,JsonExample5);
        
        String JsonExample6 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"2","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('105000', 4, 8, 9,JsonExample6);
        
        String JsonExample7 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"3","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('105000', 4, 8, 9,JsonExample7);
        
        String JsonExample8 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"4","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('105000', 4, 8, 9,JsonExample8);
        
        String JsonExample9 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('75000', 4, 8, 9,JsonExample9);
        
        String JsonExample10 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"2","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('75000', 4, 8, 9,JsonExample10);
        
        String JsonExample11 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"3","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('75000', 4, 8, 9,JsonExample11);
        
        String JsonExample12 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('75000', 4, 8, 9,JsonExample12);
        
        String JsonExample13 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('0', 4, 8, 9,JsonExample13);
        
        String JsonExample14 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"2","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('0', 4, 8, 9,JsonExample14);
        
        String JsonExample15 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"3","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('0', 4, 8, 9,JsonExample15);
        
        String JsonExample16 ='[{"childCount":1,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1","wednesdayCare":"1","sundayCare":"0","saturdayCare":"0","fridayCare":"0","mondayCare":"1","tuesdayCare":"0","thursdayCare":"1"}]';
        Controller_EstimatorForm.estimateSubsidy('0', 4, 8, 9,JsonExample16);
        
        String JsonExampleLarge = '[{"childCount":1,"noCare":false,"selectedTypeOfCare":"1","age":"2","scheduleType":"1"},{"childCount":2,"noCare":false,"selectedTypeOfCare":"6","age":"3","scheduleType":"1"},{"childCount":3,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":4,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":5,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":6,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":7,"noCare":false,"selectedTypeOfCare":"6","age":"2","scheduleType":"1"},{"childCount":8,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":9,"noCare":false,"selectedTypeOfCare":"2","age":"2","scheduleType":"1"},{"childCount":10,"noCare":false,"selectedTypeOfCare":"5","age":"2","scheduleType":"1"},{"childCount":11,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":12,"noCare":false,"selectedTypeOfCare":"4","age":"2","scheduleType":"1"},{"childCount":13,"noCare":false,"selectedTypeOfCare":"5","age":"2","scheduleType":"1"},{"childCount":14,"noCare":false,"selectedTypeOfCare":"5","age":"1","scheduleType":"1"},{"childCount":15,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":16,"noCare":false,"selectedTypeOfCare":"4","age":"1","scheduleType":"1"},{"childCount":17,"noCare":false,"selectedTypeOfCare":"6","age":"2","scheduleType":"1"},{"childCount":18,"noCare":false,"selectedTypeOfCare":"4","age":"2","scheduleType":"1"},{"childCount":19,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1"},{"childCount":20,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":21,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":22,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":23,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1"},{"childCount":24,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":25,"noCare":false,"selectedTypeOfCare":"4","age":"2","scheduleType":"1"},{"childCount":26,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":27,"noCare":false,"selectedTypeOfCare":"2","age":"2","scheduleType":"1"},{"childCount":28,"noCare":false,"selectedTypeOfCare":"1","age":"2","scheduleType":"1"},{"childCount":29,"noCare":false,"selectedTypeOfCare":"5","age":"2","scheduleType":"1"},{"childCount":30,"noCare":false,"selectedTypeOfCare":"1","age":"3","scheduleType":"1"},{"childCount":31,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":32,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":33,"noCare":false,"selectedTypeOfCare":"1","age":"2","scheduleType":"1"},{"childCount":34,"noCare":false,"selectedTypeOfCare":"2","age":"1","scheduleType":"1"},{"childCount":35,"noCare":false,"selectedTypeOfCare":"2","age":"2","scheduleType":"1"},{"childCount":36,"noCare":false,"selectedTypeOfCare":"6","age":"2","scheduleType":"1"},{"childCount":37,"noCare":false,"selectedTypeOfCare":"1","age":"3","scheduleType":"1"},{"childCount":38,"noCare":false,"selectedTypeOfCare":"1","age":"1","scheduleType":"1"},{"childCount":39,"noCare":false,"selectedTypeOfCare":"4","age":"2","scheduleType":"1"},{"childCount":40,"noCare":false,"selectedTypeOfCare":"4","age":"1","scheduleType":"1"},{"childCount":41,"noCare":false,"selectedTypeOfCare":"5","age":"1","scheduleType":"1"},{"childCount":42,"noCare":false,"selectedTypeOfCare":"6","age":"1","scheduleType":"1"},{"childCount":43,"noCare":false,"selectedTypeOfCare":"1","age":"2","scheduleType":"1"},{"childCount":44,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":45,"noCare":false,"selectedTypeOfCare":"4","age":"1","scheduleType":"1"},{"childCount":46,"noCare":false,"selectedTypeOfCare":"6","age":"2","scheduleType":"1"},{"childCount":47,"noCare":false,"selectedTypeOfCare":"2","age":"3","scheduleType":"1"},{"childCount":48,"noCare":false,"selectedTypeOfCare":"4","age":"3","scheduleType":"1"},{"childCount":49,"noCare":false,"selectedTypeOfCare":"6","age":"2","scheduleType":"2","saturdayCare":"2","sundayCare":"0","mondayCare":"2","tuesdayCare":"0","wednesdayCare":"1","thursdayCare":"2","fridayCare":"1"},{"childCount":50,"noCare":false,"selectedTypeOfCare":"4","age":"2","scheduleType":"2","mondayCare":"1","tuesdayCare":"2","wednesdayCare":"1","thursdayCare":"0","fridayCare":"2","saturdayCare":"2","sundayCare":"1"}]'  ;  
        
        Controller_EstimatorForm.estimateSubsidy('3', 4, 8, 9,JsonExampleLarge);
        Controller_EstimatorForm.estimateSubsidy('20000', 4, 8, 9,JsonExampleLarge);
        Controller_EstimatorForm.estimateSubsidy('50000', 4, 8, 9,JsonExampleLarge);       
        Controller_EstimatorForm.estimateSubsidy('100000', 4, 8, 9,JsonExampleLarge);
        Controller_EstimatorForm.estimateSubsidy('1000000', 4, 8, 9,JsonExampleLarge);
        
        
        
        Test.stopTest();
    }
    
}