/*********************************************************************************************************
Name            : MCFD_CallICMForAutismDetails_Test  
Description     : This class is to test MCFD_CallICMForAutismDetails.cls functions.
Modified By     : ARDC ICM
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                       
Liliana Trejo      16/May/2018   Updated
***************************************************************************************************************/
@isTest(seeAllData=false)
public class MCFD_CallICMForAutismDetails_Test {
    @testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContactUser = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContactUser;
        Profile objProfileUser=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContactUser, objProfileUser, 'standarduser4@testorg.com', '');
        insert objUser;
        Contact objContact= new Contact();
        Profile objProfile=TestDataFactory.getProfile('System Administrator');
        User objUserSystem = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUserSystem;
        RecordType objRecordType = TestDataFactory.getRecordType('Request__c', 'Application');
        Request__c objRequest = TestDataFactory.createRequest(objUserSystem, objRecordType,'Travel, Training, Equipment, and Supplies');
        insert objRequest;
        MCFD_Attachment__c objCustomAttachment =TestDataFactory.createCustomAttachment(objRequest);
        insert objCustomAttachment;
        Attachment objStandarAttachment =TestDataFactory.createStandardAttachment(objCustomAttachment.Id);
        insert objStandarAttachment;       
    }

    static testMethod void CreateRTASR(){ 
            String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}'; 
        	Request__c objrequest = [select Id, ICM_SR_Number__c, MCFD_Status__c from Request__c]; 
            Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());
            MCFD_CallICMForAutismDetails.CreateRTASR(objrequest.Id ,jsonString);
    }
    
    static testMethod void createShellRTA(){
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}'; 
      MCFD_CallICMForAutismDetails.createShellRTA(jsonString, 'fname','lname');
    }

    static testMethod void CreateRTASR2(){
        Test.startTest();
            User objUser =[select Id, Name from User where email='standarduser@testorg.com' LIMIT 1];   
            system.runAs(objUser){
                Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());  
                String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}'; 
                Request__c objrequest = [select Id, ICM_SR_Number__c, MCFD_Status__c from Request__c]; 
                MCFD_CallICMForAutismDetails.CreateRTASR(objrequest.Id ,'a0F5B000001gGo1UAE');
            }
       Test.stopTest();
    }
    
    static testMethod void CreateRTASRError(){
        Test.startTest();
            User objUser =[select Id, Name from User where email='standarduser@testorg.com' LIMIT 1];   
            system.runAs(objUser){
                Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGeneratorFail());  
                String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}'; 
                Request__c objrequest = [select Id, ICM_SR_Number__c, MCFD_Status__c from Request__c]; 
                MCFD_CallICMForAutismDetails.CreateRTASR(objrequest.Id ,'a0F5B000001gGo1UAE');
            }
       Test.stopTest();
    }
    
    static testMethod void CreateRTASRFail(){
            User objUser =[select Id, Name from User where email='standarduser@testorg.com' LIMIT 1];   
            system.runAs(objUser){
                Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator());  
                String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}'; 
                Request__c objrequest = [select Id, ICM_SR_Number__c, MCFD_Status__c from Request__c]; 
                MCFD_CallICMForAutismDetails.CreateRTASR(objrequest.Id ,'a0F5B000001gGo1UAE');
            }
    }
    
    static testMethod void createRTA(){
        User objUser =[select Id, Name from User where email='standarduser@testorg.com' LIMIT 1];   
        system.runAs(objUser){
            Request__c objrequest= new Request__c();
            Request__c RTAreq=MCFD_CallICMForAutismDetails.createRTA(objrequest);
            Sub_Request__c objsubreq= new Sub_Request__c();
            objsubreq.MCFD_Request__c = RTAreq.id;
            objsubreq.Name = 'SubRTA';
            RecordType rt = [select Id from RecordType where Name = 'RTA Service Order' and SobjectType = 'Sub_Request__c' limit 1];
            objsubreq.RecordTypeId  = rt.id;
            objsubreq.MCFD_New_Authorization__c = 123;
            objsubreq.MCFD_Order_Number__c = '21';
            objsubreq.MCFD_RASP__c = 'RASPDetails';
            objsubreq.MCFD_Rate_Unit__c = 'Hour';
            objsubreq.MCFD_Revised_End_Date__c = Date.valueOf('2019-01-01');
            objsubreq.MCFD_Revised_Start_Date__c = Date.valueOf('2018-01-01');
            objsubreq.MCFD_Service_Provider_Name__c = 'SPName';
            objsubreq.MCFD_Service_Type__c = 'STName';
            objsubreq.MCFD_Start_Date__c = Date.valueOf('2012-01-01');
            objsubreq.MCFD_Current_Authorization__c = 1234;
            objsubreq.MCFD_Rate__c = 12312;
            objsubreq.MCFD_Contact__c = 'ContactDetail';
            objsubreq.MCFD_Amount_Changed__c = 12;
            Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
    		Id subreqId = MCFD_CallICMForAutismDetails.SaveRTAServiceOrder(objsubreq);
            Sub_Sub_Request__c subsubtestreq = new Sub_Sub_Request__c();
    		subsubtestreq.Sub_Request__c = subreqId;
            MCFD_CallICMForAutismDetails.SaveOrderLineItem(subsubtestreq);
	 		Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
    		String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}';    
    		MCFD_CallICMForAutismDetails.CreateRTASR(RTAreq.id, jsonString  );
        	MCFD_CallICMForAutismDetails.apexLogError('TEST');
        }
    }
    
    static testMethod void createReimbursement(){
        Request__c reqReimbursmnt = MCFD_CallICMForAutismDetails.createReimbursement();
     	MCFD_CallICMForAutismDetails.updateStatus(reqReimbursmnt);
        List<Sub_Request__c> interventionlist = new List<Sub_Request__c>();
        Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
  		Request__c rtpsubmission = MCFD_CallICMForAutismDetails.createRTP();
        MCFD_CallICMForAutismDetails.saveRTP(rtpsubmission , interventionlist);
        
    }
    
    static testMethod void sendReimburesementToICM(){
        Request__c reqReimbursmnt = MCFD_CallICMForAutismDetails.createReimbursement();
     	reqReimbursmnt.ICM_SR_Number__c = '1-923234234';
     	update reqReimbursmnt;
     	MCFD_CallICMForAutismDetails.updateStatus(reqReimbursmnt);
     	Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
     	MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
    }
    
    static testMethod void testsendRequestToICM(){
         Test.startTest();
             RecordType rtype = [select Id from RecordType where Name = 'RTA Service Order' and SobjectType = 'Sub_Request__c' limit 1];
             Request__c reqReimbursmnt = MCFD_CallICMForAutismDetails.createReimbursement();
             reqReimbursmnt.ICM_SR_Number__c = '1-90923243';
             reqReimbursmnt.MCFD_End_Date__c = System.Today();
             update reqReimbursmnt;
             Request__c reqReimbursmnt2 = MCFD_CallICMForAutismDetails.createReimbursement();
             reqReimbursmnt2.ICM_SR_Number__c = '1-90923243';
             reqReimbursmnt2.MCFD_End_Date__c = System.Today();
             update reqReimbursmnt2;
             MCFD_CallICMForAutismDetails.updateStatus(reqReimbursmnt);             
             Sub_Request__c travel = new Sub_Request__c ();
             travel.MCFD_Request__c = reqReimbursmnt.id;
             travel.Name = 'Travel';
             travel.RecordTypeId  = rtype.id;
             travel.MCFD_Service_Type__c = 'Travel';
             travel.MCFD_Service_Provider_Name__c = 'Test';
             insert travel;             
             Sub_Request__c travel1 = new Sub_Request__c ();
             travel1.MCFD_Request__c = reqReimbursmnt.id;
             travel1.Name = 'Travel';
             travel1.RecordTypeId  = rtype.id;
             travel1.MCFD_Service_Type__c = 'Travel';
             travel1.MCFD_Service_Provider_Name__c = 'Test';
             insert travel1;             
             Sub_Request__c intervention = new Sub_Request__c ();
             intervention.MCFD_Request__c = reqReimbursmnt2.id;
             intervention.Name = 'Travel';
             intervention.RecordTypeId  = rtype.id;
             intervention.MCFD_Service_Type__c = 'Intervention';
             intervention.MCFD_Service_Provider_Name__c = 'Test';
             insert intervention ;
             Sub_Sub_Request__c SubReq = new Sub_Sub_Request__c();
             Sub_Sub_Request__c travelCost = SubReq;
             travelCost.Sub_Request__c = travel.id;
             Sub_Sub_Request__c travelCost1 = SubReq;
             travelCost1.Sub_Request__c = travel1.id;
             Sub_Request__c Equipment = new Sub_Request__c ();
             Equipment.MCFD_Request__c  = reqReimbursmnt.id;
             Equipment.Name = 'Equipment';
             Equipment.RecordTypeId  = rtype.id;
             Equipment.MCFD_Service_Type__c = 'Equipment';
             Sub_Request__c Equipment1 = new Sub_Request__c ();
             Equipment1.MCFD_Request__c  = reqReimbursmnt.id;
             Equipment1.Name = 'Equipment';
             Equipment1.RecordTypeId  = rtype.id;
             Equipment.MCFD_Service_Type__c = 'Equipment';                      
             Sub_Request__c training= new Sub_Request__c ();
             training.MCFD_Request__c= reqReimbursmnt.id;
             training.Name = 'Training';
             training.RecordTypeId  = rtype.id;
             List<Sub_Request__c> travelList = new List<Sub_Request__c>();
             List<Sub_Request__c> travelList1 = new List<Sub_Request__c>();
             List<Sub_Sub_Request__c> travelCosts = new List<Sub_Sub_Request__c>();
             List<Sub_Sub_Request__c> travelCosts1 = new List<Sub_Sub_Request__c>();
             List<Sub_Request__c> Equipmnt= new List<Sub_Request__c>();
             List<Sub_Request__c> Equipmnt1= new List<Sub_Request__c>();
             List<Sub_Request__c> traning= new List<Sub_Request__c>();
             travelList.add(travel);
             travelList1.add(travel1); 
             travelCosts.add(travelCost );
             travelCosts1.add(travelCost1 );
             Equipmnt.add(Equipment );
             Equipmnt1.add(Equipment1 );
             traning.add(training); 
             Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
             MCFD_CallICMForAutismDetails.sendRequestToICM(reqReimbursmnt.id);
             reqReimbursmnt.MCFD_Address_Update__c = 'Yes';
             reqReimbursmnt.MCFD_Service_Auth_Type__c = 'Travel, Training, Equipment, and Supplies';
             reqReimbursmnt.MCFD_Service_Provider_Type__c = '';
             update reqReimbursmnt;
             MCFD_CallICMForAutismDetails.sendRequestToICM(reqReimbursmnt2.id);
          Test.StopTest();
 }
    
    static testMethod void SaveRTPPartB(){
        Test.startTest();
         RecordType rtype = [select Id from RecordType where Name = 'RTA Service Order' and SobjectType = 'Sub_Request__c' limit 1];
         Request__c reqReimbursmnt = MCFD_CallICMForAutismDetails.createReimbursement();
         MCFD_CallICMForAutismDetails.updateStatus(reqReimbursmnt);
         
         
         Sub_Request__c travel = new Sub_Request__c ();
         travel.MCFD_Request__c = reqReimbursmnt.id;
         travel.Name = 'Travel';
         travel.RecordTypeId  = rtype.id;
         travel.MCFD_Service_Type__c = 'Travel';
         travel.MCFD_Service_Provider_Name__c = 'Test';
         insert travel;
         
          Sub_Request__c travel1 = new Sub_Request__c ();
         travel1.MCFD_Request__c = reqReimbursmnt.id;
         travel1.Name = 'Travel';
         travel1.RecordTypeId  = rtype.id;
         travel1.MCFD_Service_Type__c = 'Travel';
         travel1.MCFD_Service_Provider_Name__c = 'Test';
         insert travel1;
         
          Sub_Sub_Request__c SubReq = new Sub_Sub_Request__c();
         Sub_Sub_Request__c travelCost = SubReq;
         travelCost.Sub_Request__c = travel.id;
         
         Sub_Sub_Request__c travelCost1 =SubReq;
         travelCost1.Sub_Request__c = travel1.id;
        
         Sub_Request__c Equipment = new Sub_Request__c ();
         Equipment.MCFD_Request__c  = reqReimbursmnt.id;
         Equipment.Name = 'Equipment';
         Equipment.RecordTypeId  = rtype.id;
         Equipment.MCFD_Service_Type__c = 'Equipment';
         Equipment.MCFD_Service_Provider_Name__c = 'Test';
        
         
         Sub_Request__c Equipment1 = new Sub_Request__c ();
         Equipment1.MCFD_Request__c  = reqReimbursmnt.id;
         Equipment1.Name = 'Equipment';
         Equipment1.RecordTypeId  = rtype.id;
         Equipment1.MCFD_Service_Type__c = 'Equipment';
         Equipment1.MCFD_Service_Provider_Name__c = 'Test';
         
         
                  
         Sub_Request__c training= new Sub_Request__c ();
         training.MCFD_Request__c= reqReimbursmnt.id;
         training.Name = 'Training';
         training.RecordTypeId  = rtype.id;
         training.MCFD_Service_Provider_Name__c = 'Test';
               
         
         List<Sub_Request__c> travelList = new List<Sub_Request__c>();
         List<Sub_Request__c> travelList1 = new List<Sub_Request__c>();
         
         List<Sub_Sub_Request__c> travelCosts = new List<Sub_Sub_Request__c>();
         List<Sub_Sub_Request__c> travelCosts1 = new List<Sub_Sub_Request__c>();
         
         List<Sub_Request__c> Equipmnt= new List<Sub_Request__c>();
         List<Sub_Request__c> Equipmnt1= new List<Sub_Request__c>();
         
         
          
         List<Sub_Request__c> traning= new List<Sub_Request__c>();
 
         travelList.add(travel);
         travelList1.add(travel1); 
         
         travelCosts.add(travelCost );
         travelCosts1.add(travelCost1 );
         
         Equipmnt.add(Equipment );
         Equipmnt1.add(Equipment1 );
           
         traning.add(training); 
          MCFD_CallICMForAutismDetails.SaveRTPPartB(reqReimbursmnt,travelList,travelCosts,Equipmnt,traning);
          travelList[0].MCFD_Name_of_Travelers__c = '';
          update travelList[0];
          MCFD_CallICMForAutismDetails.SaveRTPPartB(reqReimbursmnt,travelList,travelCosts,Equipmnt,traning);
          // Now travelList[0] record has been deleted
          travelCosts1[0].MCFD_Rate__c = 34;
          Equipmnt[0].MCFD_Rate__c = 34;
          traning[0].MCFD_Rate__c = 34;
         MCFD_CallICMForAutismDetails.SaveRTPPartB(reqReimbursmnt,travelList1,travelCosts1,Equipmnt,traning);
          Test.StopTest();
    }
    
    static testMethod void testRTP(){
    Request__c req = new Request__c();     
    Request__c testreqIntervention = req;
    testreqIntervention.MCFD_In_Canada__c = true;
    testreqIntervention.MCFD_End_Date__c = System.Today();
    testreqIntervention.MCFD_Service_Auth_Type__c = 'Intervention Services';
    insert testreqIntervention ;
     
    RecordType rtype = [select Id from RecordType where Name = 'RTA Service Order' and SobjectType = 'Sub_Request__c' limit 1];
  
    Sub_Request__c sr1 = new Sub_Request__c ();
    sr1.MCFD_Request__c = testreqIntervention.id;
    sr1.RecordTypeId  = rtype.id;
    sr1.Name = 'InterventionService1';
    
    Sub_Request__c sr2 = new Sub_Request__c ();
    sr2.MCFD_Request__c = testreqIntervention.id;
    sr2.Name = 'InterventionService2';
    sr2.RecordTypeId  = rtype.id;
    
   Sub_Request__c sr3 = new Sub_Request__c ();
   sr3.MCFD_Request__c = testreqIntervention.id;
   sr3.Name = 'InterventionService3';
   sr3.MCFD_Service_Type__c = 'Travel';
   sr3.RecordTypeId  = rtype.id;
  List<Sub_Request__c> interventionlist = new List<Sub_Request__c>(); 
  Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
  Request__c rtpsubmission = MCFD_CallICMForAutismDetails.createRTP();
  
  rtpsubmission.ICM_SR_Number__c = '1-989829382';  
  MCFD_CallICMForAutismDetails.saveRTP(rtpsubmission , interventionlist);
  
   MCFD_CallICMForAutismDetails.updateRTP_SRNUM(testreqIntervention , '1234');
   MCFD_CallICMForAutismDetails.createEquipmentReimbursement (testreqIntervention.id);
   Sub_Request__c rtpTravel = MCFD_CallICMForAutismDetails.createTravelRTP(testreqIntervention.id);
   MCFD_CallICMForAutismDetails.updateRTP_ERROR(testreqIntervention,'Creation Error');
   MCFD_CallICMForAutismDetails.deleteTravelRTP(rtpTravel.id);  
   MCFD_CallICMForContactDetails.CallICM();
  
  
 }
    
    static testMethod void TestSubmitRTP(){
      Test.StartTest();
          String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}';
          Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
          MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Intervention');
          MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Reimbursement');
          MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Travel, Training, or Equipment');
      Test.StopTest();
      } 
    
    static testMethod void TestSubmitRTP2(){
      Test.StartTest();
      String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}';
      Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
      MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Intervention');
      Test.StopTest();
      }
    
    static testMethod void TestSubmitRTP3(){
      String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}';
      Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGenerator()); 
      MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Intervention');
      }
    
    static testMethod void TestSubmitRTP4(){
      Test.startTest();
      String jsonString =  '{"method": "POST","url": "types","body": {"name": "ABC121212","description":"ABC34443333"}';
      Test.setMock(HttpCalloutMock.class, new MCFD_MockHttpResponseGeneratorFail()); 
      MCFD_CallICMForAutismDetails.SubmitRTP(jsonString, 'Intervention');
      Test.stopTest();
      }
    
    static testMethod void getCalloutResponseContents(){
      contact objContact =[SELECT id from Contact limit 1];
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
      MCFD_CallICMForAutismDetails.getCalloutResponseContents(objContact.id);
      }
    
    static testMethod void getCalloutResponseContents2(){
      Test.startTest();
      contact objContact =[SELECT id from Contact limit 1];
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock()); 
      MCFD_CallICMForAutismDetails.getCalloutResponseContents(objContact.id);
      Test.stopTest();
      }
    
    static testMethod void testReimbursement(){
     Test.startTest();
     Sub_Sub_Request__c SubReq = new Sub_Sub_Request__c();
     RecordType rtype = [select Id from RecordType where Name = 'RTA Service Order' and SobjectType = 'Sub_Request__c' limit 1];
     
     
     // create a Request 
     Request__c reqReimbursmnt = MCFD_CallICMForAutismDetails.createReimbursement();
     reqReimbursmnt.ICM_SR_Number__c = '1-923234234';
     update reqReimbursmnt;
     
     MCFD_CallICMForAutismDetails.updateStatus(reqReimbursmnt);
     Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
     MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
     
     Sub_Request__c travel = new Sub_Request__c ();
     travel.MCFD_Request__c = reqReimbursmnt.id;
     travel.Name = 'Travel';
     travel.RecordTypeId  = rtype.id;
     travel.MCFD_Service_Type__c = 'Travel';
     travel.MCFD_Service_Provider_Name__c = 'Test';
     insert travel;
     
      Sub_Request__c travel1 = new Sub_Request__c ();
     travel1.MCFD_Request__c = reqReimbursmnt.id;
     travel1.Name = 'Travel';
     travel1.RecordTypeId  = rtype.id;
     travel1.MCFD_Service_Type__c = 'Travel';
     travel1.MCFD_Service_Provider_Name__c = 'Test';
     insert travel1;
     
     
     Sub_Sub_Request__c travelCost = SubReq;
     travelCost.Sub_Request__c = travel.id;
     
     Sub_Sub_Request__c travelCost1 = SubReq;
     travelCost1.Sub_Request__c = travel1.id;
    
     Sub_Request__c Equipment = new Sub_Request__c ();
     Equipment.MCFD_Request__c  = reqReimbursmnt.id;
     Equipment.Name = 'Equipment';
     Equipment.RecordTypeId  = rtype.id;
     Equipment.MCFD_Service_Provider_Name__c = 'Test';
     Equipment.MCFD_Service_Type__c = 'Equipment';
     insert Equipment;
     
     Sub_Request__c Equipment1 = new Sub_Request__c ();
     Equipment1.MCFD_Request__c  = reqReimbursmnt.id;
     Equipment1.Name = 'Equipment';
     Equipment1.RecordTypeId  = rtype.id;
     Equipment1.MCFD_Service_Provider_Name__c = 'Test';
     Equipment.MCFD_Service_Type__c = 'Equipment';
     insert Equipment1;
     
     Sub_Sub_Request__c EquipmentCost = SubReq;
     EquipmentCost.Sub_Request__c = Equipment.id;
     
     Sub_Sub_Request__c EquipmentCost1 = SubReq;
     EquipmentCost1.Sub_Request__c = Equipment1.id;
     
     Sub_Request__c training= new Sub_Request__c ();
     training.MCFD_Request__c= reqReimbursmnt.id;
     training.Name = 'Training';
     training.MCFD_Service_Type__c = 'Training';
     training.RecordTypeId  = rtype.id;
     training.MCFD_Service_Provider_Name__c = 'Test';
     
     
      
     Sub_Request__c employerCost= new Sub_Request__c ();
     employerCost.MCFD_Request__c= reqReimbursmnt.id;
     employerCost.Name= 'EmployerCost';
     employerCost.RecordTypeId  = rtype.id;
     employerCost.MCFD_Service_Provider_Name__c = 'Test';
     employerCost.MCFD_Service_Type__c = 'Employer Costs';
     
     List<Sub_Request__c> travelList = new List<Sub_Request__c>();
     List<Sub_Request__c> travelList1 = new List<Sub_Request__c>();
     
     
     List<Sub_Sub_Request__c> travelCosts = new List<Sub_Sub_Request__c>();
     List<Sub_Sub_Request__c> travelCosts1 = new List<Sub_Sub_Request__c>();
     /*
     List<Sub_Sub_Request__c> travelCosts2 = new List<Sub_Sub_Request__c>();
     List<Sub_Sub_Request__c> travelCosts3 = new List<Sub_Sub_Request__c>();
     */
     List<Sub_Request__c> Equipmnt= new List<Sub_Request__c>();
     List<Sub_Request__c> Equipmnt1= new List<Sub_Request__c>();
     
     List<Sub_Sub_Request__c> EquipmntCost= new List<Sub_Sub_Request__c>();
     List<Sub_Sub_Request__c> EquipmntCost1= new List<Sub_Sub_Request__c>();
      
     List<Sub_Request__c> traning= new List<Sub_Request__c>();
     List<Sub_Request__c> EmployerCst= new List<Sub_Request__c>();
     
     
     travelList.add(travel);
     travelList1.add(travel1); 
     travelCosts.add(travelCost );
     travelCosts1.add(travelCost1 );
     
     Equipmnt.add(Equipment );
     Equipmnt1.add(Equipment1 );
      
     EquipmntCost.add(EquipmentCost );
     EquipmntCost1.add(EquipmentCost1 );
      
     traning.add(training); 
     EmployerCst.add(employerCost);
     
     
      MCFD_CallICMForAutismDetails.SaveReimbursement(reqReimbursmnt,travelList,travelCosts,Equipmnt,EquipmntCost,traning,EmployerCst);
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      travelList[0].MCFD_Name_of_Travelers__c = '';
      update travelList[0];
      
      MCFD_CallICMForAutismDetails.SaveReimbursement(reqReimbursmnt,travelList,travelCosts,Equipmnt,EquipmntCost,traning,EmployerCst);
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      // Now travelList[0] record has been deleted
      travelCosts1[0].MCFD_Rate__c = 34;
      MCFD_CallICMForAutismDetails.SaveReimbursement(reqReimbursmnt,travelList1,travelCosts1,Equipmnt,EquipmntCost,traning,EmployerCst);
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      Equipmnt[0].MCFD_Service_Provider_Name__c = '';
      travelCosts1[0].MCFD_Rate__c = 0;
      MCFD_CallICMForAutismDetails.SaveReimbursement(reqReimbursmnt,travelList1,travelCosts1,Equipmnt,EquipmntCost,traning,EmployerCst);
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      //Equipmnt[0] has been deleted
      EquipmntCost1[0].MCFD_Rate__c = 34;
      EmployerCst[0].MCFD_Rate__c = 34;
      traning[0].MCFD_Rate__c = 34;
      MCFD_CallICMForAutismDetails.SaveReimbursement(reqReimbursmnt,travelList1,travelCosts1,Equipmnt1,EquipmntCost1,traning,EmployerCst);
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      reqReimbursmnt.ICM_SR_Number__c = '1-989428329';
      update reqReimbursmnt;
      
      Equipmnt1[0].MCFD_Service_Type__c = 'Equipment';
    
      update Equipmnt1[0];  
      Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
      MCFD_CallICMForAutismDetails.sendReimburesementToICM(reqReimbursmnt.id);
      
     Test.StopTest();
 }
    
  }