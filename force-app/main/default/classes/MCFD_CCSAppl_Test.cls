@isTest(seeAlldata=false)
public class MCFD_CCSAppl_Test{

/*    
  
  

    static testMethod void getAllTest() {
    
       
    User u = MCFD_TestDataHelper_Test.getCommunityUser();
    System.runAs(u){
    
     MCFD_CCSApplication.utilityMethod1(); 
    }
       
    Request__c req = new Request__c();
    insert req;
    
    
    List<Contact> conList = new List<Contact>();
    Contact primCont = MCFD_TestDataHelper_Test.getContact();
    Contact SpouseCont = MCFD_TestDataHelper_Test.getContact();
    Contact dependantCont = MCFD_TestDataHelper_Test.getContact();
    conList.add(primCont );
    conList.add(dependantCont );
    conList.add(SpouseCont );
       
    
    insert conList;
    

    List<MCFD_Relationship__c > reltList = new List<MCFD_Relationship__c >();
    MCFD_Relationship__c reltSpouse =  MCFD_TestDataHelper_Test.getRelationship('Spouse' , primCont.id, SpouseCont.id, req.id);
    MCFD_Relationship__c reltDependant =  MCFD_TestDataHelper_Test.getRelationship('Dependant' , primCont.id, dependantCont.id, req.id);
    reltList.add(reltSpouse );
    reltList.add(reltDependant );
   
    insert reltList;
    
    List<MCFD_Relationship__c> reltnshplist = new List<MCFD_Relationship__c>();
    reltnshplist = [select id, MCFD_Request__c,MCFD_Relationship_Type__c,MCFD_Dependant_Number__c, MCFD_Parent_Contact__c, MCFD_Child_Contact__c from MCFD_Relationship__c where MCFD_Request__c =: req.id ORDER BY MCFD_Dependant_Number__c DESC]; 
    
    system.debug('?>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> '+ reltnshplist.size());    
    List<MCFD_Contact_Address__c> conAddList = new List<MCFD_Contact_Address__c>();
    
    MCFD_Contact_Address__c conaddHome = MCFD_TestDataHelper_Test.getContactAddressRelt(req.id, primCont.id, 'Home Address');
    conAddList.add(conaddHome);
    
    MCFD_Contact_Address__c conaddMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(req.id, primCont.id, 'Mailing Address');
    conAddList.add(conaddMailing);
    
    MCFD_Contact_Address__c conaddHomeNMailing = MCFD_TestDataHelper_Test.getContactAddressRelt(req.id, primCont.id, 'Home and Mailing Address');
    conAddList.add(conaddHomeNMailing);
    
    insert conAddList;
    
     List<MCFD_Contact_Address__c> contaddr = new List<MCFD_Contact_Address__c>();
        contaddr = [select id,MCFD_Address__c,MCFD_Address_Type__c,MCFD_Contact__c, MCFD_Request__c from MCFD_Contact_Address__c where  MCFD_Request__c =: req.id];
     system.debug('?>>>>>>>>>><>>>>>>>>>>>>><><><><><><>>>>>>>>>>>>>>>>>>>>>>>>>>> '+ contaddr.size());
     
    MCFD_CCSApplication.getCCSApplicationInfo(req.id);
    
    MCFD_Address__c addr1 = MCFD_TestDataHelper_Test.getMCFD_Address();
    MCFD_Address__c addr2 = MCFD_TestDataHelper_Test.getMCFD_Address();
    MCFD_Address__c addr3 = MCFD_TestDataHelper_Test.getMCFD_Address();
    MCFD_Address__c addr4 = MCFD_TestDataHelper_Test.getMCFD_Address();
    
    
    MCFD_Attachment__c attach1 = MCFD_TestDataHelper_Test.customAttachment();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c = primCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(req.id, primCont, addr1 , addr2 , attachList );
    primCont.LastName='UpdatedPLName';
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(req.id, primCont, addr1 , addr2 , attachList );
    primCont.MCFD_Address_Check__c = 'Yes';
    update primCont;
    
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(req.id, primCont, addr3 , addr4 , attachList );
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantPI(req.id, primCont, addr3 , addr4 , attachList );
    //insert conAddList;
    
     System.RunAs(u){
    // MCFD_CCSApplication.getAll(req.id);
    }
    }
    
    
    
     
    static testMethod void upsertFamilyDetails() {
   
   
    Request__c req = new Request__c();
    
    
    Contact primCont = MCFD_TestDataHelper_Test.getContact();
    Contact SpouseCont = MCFD_TestDataHelper_Test.getContact();
    Contact dependantCont = MCFD_TestDataHelper_Test.getContact();
    List<Contact> depconlist = new List<Contact>();
    depconlist.add(dependantCont );
    // insert details
    MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(req, primCont , SpouseCont , depconlist  );
    
    
    // update details
    primCont.LastName = 'UpdatePLName';
    SpouseCont.LastName = 'UpdateSLName';
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
    MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(req, primCont , SpouseCont , depconlist  );
    Test.stoptest();
     primCont.MCFD_Is_SW_Referred__c = true;
     MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(req, primCont , SpouseCont , depconlist  );
     MCFD_CCSApplication.upsert_MCFD_EnterFamilyCompositionComponent(req, primCont , SpouseCont , depconlist  );
   
     
     }
     
     
     static testMethod void upsertDependantInfo() {
     
    Test.startTest();
    Request__c req = new Request__c();
    insert req;
    
    Contact primCont = MCFD_TestDataHelper_Test.getContact();
    insert primCont;
    MCFD_Attachment__c attach1 = MCFD_TestDataHelper_Test.customAttachment();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c = primCont.id;
    upsert attach1;
    
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    // Child Dependant
    //deployment error, Laura commented
   // MCFD_CCSApplication.upsert_MCFD_ChildDependantPersonalInformation(primCont , attachList  );
    // Adult Dependant
    MCFD_CCSApplication.upsert_MCFD_DependantPersonalInformation(primCont , attachList  );
    
  
    Test.stoptest();
     
     }
     
     static testMethod void PrimaryAppRFC() {
     
    Test.startTest();

       
    Contact primCont = MCFD_TestDataHelper_Test.getContact();
    insert primCont ;
    
    primCont.MCFD_Attending_School__c = true;
      
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantIndicateReasonsForCare( primCont );
  
    Test.stoptest();
     
     }
     
      static testMethod void SpouseRFC() {
     
    Test.startTest();

       
    Contact spouseCont = MCFD_TestDataHelper_Test.getContact();
    insert spouseCont ;
    
    spouseCont.MCFD_Attending_School__c = true;
    
      
    MCFD_CCSApplication.upsert_MCFD_SpouseIndicateReasonsForCare( spouseCont );
  
    Test.stoptest();
     
     }
     
     
     
   
    
     
     static testMethod void upsertSpousePersonalInfo() {
     
    Test.startTest();

    Request__c req = new Request__c();
    insert req;
    
    Contact SpouseCont = MCFD_TestDataHelper_Test.getContact();
    insert SpouseCont;
   
    MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c = SpouseCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    MCFD_CCSApplication.upsert_MCFD_SpousePersonalInformation( SpouseCont, attachList );
   
   
    Test.stoptest();
     
     }
     
      
     static testMethod void upsertPrimAppIncomeInfo() {
     
    Test.startTest();

    Request__c req = new Request__c();
    insert req;
    
    Contact primCont = MCFD_TestDataHelper_Test.getContact();
    insert primCont;
    
    Income__c incPrim = new Income__c();
    incPrim.Name='Employment Income';
    incPrim.Contact__c = primcont.id;
    insert incPrim;
   
    MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c= primCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantIncomeInformation( incPrim, attachList );
   
   
    Test.stoptest();
     
     }
     
     static testMethod void upsertSpouseIncomeInfo() {
     
    Test.startTest();

    Request__c req = new Request__c();
    insert req;
    
    Contact spouseCont = MCFD_TestDataHelper_Test.getContact();
    insert spouseCont;
    
    Income__c incPrim = new Income__c();
    incPrim.Name='Employment Income';
    incPrim.Contact__c = spouseCont.id;
    insert incPrim;
   
    MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c= spouseCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    MCFD_CCSApplication.upsert_MCFD_SpouseIncomeInformation( incPrim, attachList );
   
   
    Test.stoptest();
     
     }
     
    static testMethod void testMethod10() {
     
    Test.startTest();
    
    Request__c req = new Request__c();
    insert req;
    
    Contact primeCont = MCFD_TestDataHelper_Test.getContact();
    insert primeCont;
        
    Reason_For_Care__c rsn1 = MCFD_TestDataHelper_Test.getrsnFcare(primeCont.Id,req.id, 'Employment');
    insert rsn1;
    
    Reason_For_Care__c rsn2 = MCFD_TestDataHelper_Test.getrsnFcare(primeCont.Id,req.id, 'Medical Condition');
    insert rsn2;
    
    Reason_For_Care__c rsn3 =MCFD_TestDataHelper_Test.getrsnFcare(primeCont.Id,req.id, 'Self Employment');
    insert rsn3;
    
    Reason_For_Care__c rsn4 = MCFD_TestDataHelper_Test.getrsnFcare(primeCont.Id,req.id, 'Looking for Work');
    insert rsn4;
    
    List<Reason_For_Care__c > rsnlist = new List<Reason_For_Care__c >();
    rsnlist.add(rsn2);
    rsnlist.add(rsn3);
    rsnlist.add(rsn4);

    
    Income__c incPrim = new Income__c();
    incPrim.Name='Employment Income';
    incPrim.Contact__c = primeCont.id;
    insert incPrim;
   
    MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c= primeCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    MCFD_CCSApplication.upsert_MCFD_RSFNCARE_Employment_Schedule( rsn1, rsnlist, attachList );
    MCFD_CCSApplication.upsert_MCFD_RSNFCARE_Self_Employment_Schedule( rsn1, rsnlist,attachList );
    MCFD_CCSApplication.upsert_MCFD_RFC_SchoolSchedule(rsn1, attachList );
    //deployment error, Laura commented
 //   MCFD_CCSApplication.upsert_MCFD_RFC_EmploymentProgramSchedule(rsn1);
    MCFD_CCSApplication.upsert_MCFD_RFC_Primary_LookingFWorkScreen2(rsn4);
    MCFD_CCSApplication.usert_MCFD_RFC_MedicalConditions(rsn1, attachList );
   
    Test.stoptest();
     
     }
     
      static testMethod void testMethod11() {
     
    Test.startTest();
    
     Request__c req = new Request__c();
    insert req;
    
    Contact spouseCont = MCFD_TestDataHelper_Test.getContact();
    insert spouseCont;
    
    
   Reason_For_Care__c rsn1 = MCFD_TestDataHelper_Test.getrsnFcare(spouseCont.Id,req.id, 'Employment');
    insert rsn1;
    
    Reason_For_Care__c rsn2 = MCFD_TestDataHelper_Test.getrsnFcare(spouseCont.Id,req.id, 'Medical Condition');
    insert rsn2;
    
    Reason_For_Care__c rsn3 =MCFD_TestDataHelper_Test.getrsnFcare(spouseCont.Id,req.id, 'Self Employment');
    insert rsn3;
    
    Reason_For_Care__c rsn4 = MCFD_TestDataHelper_Test.getrsnFcare(spouseCont.Id,req.id, 'Looking for Work');
    insert rsn4;
    
    List<Reason_For_Care__c > rsnlist = new List<Reason_For_Care__c >();
    rsnlist.add(rsn2);
    rsnlist.add(rsn3);
    rsnlist.add(rsn4);

   
    Income__c incPrim = new Income__c();
    incPrim.Name='Employment Income';
    incPrim.Contact__c = spouseCont.id;
    insert incPrim;
   
    MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
    attach1.MCFD_Request_Id__c = req.id;
    attach1.MCFD_Contact_Id__c= spouseCont.id;
    List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
    attachList.add(attach1);
    
    //deployment error, Laura commented
//    MCFD_CCSApplication.upsert_MCFD_SpouseEmpSchedule( rsn1, rsnlist);
 //   MCFD_CCSApplication.upsert_MCFD_spouseSelfEmploymentSchedule( rsn1, rsnlist);
  //  MCFD_CCSApplication.upsert_MCFD_RFC_SpouseSchoolSchedule(rsn1);
  //  MCFD_CCSApplication.upsert_MCFD_RFC_SpouseEmploymentProgramSchedule(rsn1);
    MCFD_CCSApplication.upsert_MCFD_Spouse_LookingFWorkScreen2(rsn1);
  //  MCFD_CCSApplication.upsert_MCFD_Spouse_Medical_Conditions(rsn1);
   
    Test.stoptest();
     
     }
     
     
     static testMethod void testPrimaryNSpouseSelfEmployIncome(){
     
         Test.StartTest();
         
         
        Request__c req = new Request__c();
        insert req;
        
        Contact primCont = MCFD_TestDataHelper_Test.getContact();
        insert primCont;
        
        Income__c incPrim = new Income__c();
        incPrim.Name='Employment Income';
        incPrim.Contact__c = primCont.id;
        insert incPrim;
       
        MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
        attach1.MCFD_Request_Id__c = req.id;
        attach1.MCFD_Contact_Id__c= primCont.id;
        List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
        attachList.add(attach1);
         
         MCFD_Self_Employment_Income__c empInc = new MCFD_Self_Employment_Income__c ();
         empInc.Name = 'Self';
         //insert empInc;
         
         List<MCFD_Self_Employment_Income__c> empIncList = new List<MCFD_Self_Employment_Income__c>();
         empIncList.add(empInc);
         MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantSelfEmploymentIncome(empIncList,attachList );
         //deployment error, Laura commented
        // MCFD_CCSApplication.upsert_MCFD_SpouseSelfEmploymentIncome(empIncList );
         
         Test.StopTest();
     }
     
     
     static testMethod void testupsert_MCFD_CCSSpousalConsent(){
     
         Test.StartTest();
         
         
        Request__c req = new Request__c();
        insert req;
        
        Contact primCont = MCFD_TestDataHelper_Test.getContact();
        insert primCont;
        
        Income__c incPrim = new Income__c();
        incPrim.Name='Employment Income';
        incPrim.Contact__c = primCont.id;
        insert incPrim;
       
        MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
        attach1.MCFD_Request_Id__c = req.id;
        attach1.MCFD_Contact_Id__c= primCont.id;
        List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
        attachList.add(attach1);
         
         MCFD_Self_Employment_Income__c empInc = new MCFD_Self_Employment_Income__c ();
         empInc.Name = 'Self';
         //insert empInc;
         
         List<MCFD_Self_Employment_Income__c> empIncList = new List<MCFD_Self_Employment_Income__c>();
         empIncList.add(empInc);
         MCFD_CCSApplication.upsert_MCFD_ConsentToShareInfoWithSpouse(req);
         MCFD_CCSApplication.upsert_MCFD_CCSSpousalConsent(req);
         
         Test.StopTest();
     }
     
      
     static testMethod void submitApplicationTest(){
     

        Contact primCont = MCFD_TestDataHelper_Test.getContact();
        primCont.MCFD_Address_Check__c = 'No';
        insert primCont;
         
        Request__c req = new Request__c();
        req.Primary_Applicant__c = primCont.id;
        insert req;
        
         
        Contact SpouseCont = MCFD_TestDataHelper_Test.getContact();
        Contact dependantCont = MCFD_TestDataHelper_Test.getContact();
       
        insert SpouseCont ;
        insert dependantCont ;
        
        MCFD_Relationship__c relt1 =  new MCFD_Relationship__c();
        MCFD_Relationship__c relt2 =  new MCFD_Relationship__c();
        
        relt1.MCFD_Parent_Contact__c = primCont.id;
        relt1.MCFD_Relationship_Type__c = 'Spouse' ;
        relt1.MCFD_Request__c = req.id;
        relt1.MCFD_Child_Contact__c = SpouseCont.id;
        
        relt2.MCFD_Parent_Contact__c = primCont.id;
        relt2.MCFD_Relationship_Type__c = 'Dependant' ;
        relt2.MCFD_Request__c = req.id;
        relt2.MCFD_Child_Contact__c = dependantCont.id;
        
        insert relt1;
        insert relt2;
        
         MCFD_Address__c addr = MCFD_TestDataHelper_Test.getMCFD_Address();
         
         MCFD_Address__c addr1 = MCFD_TestDataHelper_Test.getMCFD_Address();
         
         MCFD_Address__c addr2 = MCFD_TestDataHelper_Test.getMCFD_Address();
         
         
          insert addr;
          insert addr1;
          insert addr2;
          
        MCFD_Contact_Address__c conadd = new MCFD_Contact_Address__c();
        conadd.MCFD_Request__c = req.id;
        conadd.MCFD_Contact__c = primCont.id;
        conadd.MCFD_Address_Type__c = 'Home Address';
        conadd.MCFD_Address__c = addr.id;
        insert conadd;
        
        MCFD_Contact_Address__c conadd2 = new MCFD_Contact_Address__c();
        conadd2.MCFD_Request__c = req.id;
        conadd2.MCFD_Contact__c = primCont.id;
        conadd2.MCFD_Address_Type__c = 'Mailing Address';
        conadd2.MCFD_Address__c = addr1.id;
        insert conadd2;
        
         MCFD_Contact_Address__c conadd3 = new MCFD_Contact_Address__c();
        conadd3.MCFD_Request__c = req.id;
        conadd3.MCFD_Contact__c = primCont.id;
        conadd3.MCFD_Address_Type__c = 'Home and Mailing Address';
        conadd3.MCFD_Address__c = addr2.id;
        insert conadd3;
    
        
   
        MCFD_Attachment__c attach1 = new MCFD_Attachment__c();
        attach1.MCFD_Request_Id__c = req.id;
        attach1.MCFD_Contact_Id__c = primCont.id;
        List<MCFD_Attachment__c > attachList = new List<MCFD_Attachment__c>();
        attachList.add(attach1);
            
        Income__c incPrim = new Income__c();
        incPrim.Name='Employment Income';
        incPrim.Contact__c = primCont.id;
        incPrim.MCFD_Related_Request__c = req.id;
        incPrim.MCFD_Band_Assistance__c = true;
        incPrim.MCFD_BC_Disability_Assistance__c= true;
        incPrim.MCFD_Band_Assistance__c = true;
        incPrim.MCFD_BC_Income_Assistance__c = true;
        incPrim.MCFD_Employment_Income__c= true;
        incPrim.MCFD_Self_Employment_Income__c= true;
        incPrim.MCFD_Federal_Benefits__c= true;
        incPrim.MCFD_Federal_Employment_Insurance__c= true;
        incPrim.MCFD_Grants__c = true;
        incPrim.MCFD_Dep_Adult_Income__c= true;
        incPrim.MCFD_Rental_Income__c= true;
        incPrim.MCFD_Interest__c= true;
        incPrim.MCFD_Other_Income__c= true;
        incPrim.MCFD_Tips__c= true;
        incPrim.MCFD_Training_Living_Allowance__c= true;
        incPrim.MCFD_WorkSafeBC__c= true;
        incPrim.MCFD_Spousal_Support__c = true;
        
        insert incPrim;
       
                
         MCFD_Employment_Income__c empInc = new MCFD_Employment_Income__c();
         empInc.Name = 'Self';
         empInc.MCFD_Employer_Name__c = 'Emp Name';
         empInc.Parent_Income_Id__c = incPrim.id;
         empInc.MCFD_Amount_Pay_Stub_1__c = 20;
         empInc.MCFD_Amount_Pay_Stub_2__c= 20;
         empInc.MCFD_End_Date__c = System.Today() + 10;
         empInc.MCFD_Hourly_Wage__c = 2;
         empInc.MCFD_No_Two_Pay_Stubs__c = False; 
         empInc.MCFD_Non_Deduct_Amount_Pay_Stub_1__c = 10;
         empInc.MCFD_Non_Deduct_Amount_Pay_Stub_2__c = 10;
         empInc.MCFD_Pay_Frequency__c = 'Every month';
         empInc.MCFD_Start_Date__c = System.Today() - 10;
         
         insert empInc;
         
         MCFD_Self_Employment_Income__c sempInc = new MCFD_Self_Employment_Income__c();
         sempInc.Name = 'Self';
         sempInc.Parent_Income_Id__c = incPrim.id;
         sempInc.MCFD_Business_Name__c= 'Emp Name';
         sempInc.MCFD_Net_Income__c= 20;
         sempInc.MCFD_Limited_Company__c = False; 
         sempInc.MCFD_New_Business__c= False;
         sempInc.MCFD_Pay_Frequency__c = 'Every month';
         
         
         insert sempInc;
         
         Reason_For_Care__c rsn = new Reason_For_Care__c();
         rsn.Contact__c = primCont.id;
         rsn.MCFD_Request__c = req.id;
         rsn.MCFD_Rsn_For_Care_Type__c = 'Employment';
         insert rsn;
         
         Reason_For_Care__c rsnE = new Reason_For_Care__c();
         rsnE.Contact__c = primCont.id;
         rsnE.MCFD_Request__c = req.id;
         rsnE.MCFD_Rsn_For_Care_Type__c = 'Employer';
         insert rsnE;
         
         Reason_For_Care__c rsnSE = new Reason_For_Care__c();
         rsnSE.Contact__c = primCont.id;
         rsnSE.MCFD_Request__c = req.id;
         rsnSE.MCFD_Rsn_For_Care_Type__c = 'Self Employment';
         insert rsnSE;
         
         Reason_For_Care__c rsnB = new Reason_For_Care__c();
         rsnB.Contact__c = primCont.id;
         rsnB.MCFD_Request__c = req.id;
         rsnB.MCFD_Rsn_For_Care_Type__c = 'Business';
         insert rsnB;
         
     
         
         List<MCFD_Employment_Income__c> empIncList = new List<MCFD_Employment_Income__c>();
         empIncList.add(empInc);
         
         MCFD_CCSApplication.upsert_MCFD_PrimaryApplicantsEmploymentIncome(empIncList, attachList  );
         MCFD_CCSApplication.upsert_MCFD_SpouseEmploymentIncome(empIncList, attachList  );
         MCFD_CCSApplication.upsert_MCFD_Document_Submission(attachList);
         MCFD_CCSApplication.upsert_MCFD_DeclarationandConsent(req);
         Test.StartTest();
         Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
         MCFD_CCSApplication.submitApplicationSaveMethod(req);
        
         Test.StopTest();
        
         rsn.MCFD_Rsn_For_Care_Type__c = '';
         rsnE.MCFD_Rsn_For_Care_Type__c = '';
         update rsn;
         update rsnE; 
                 
         primCont.MCFD_Address_Check__c = 'Yes';
         update primCont;
        
         Test.setMock(HttpCalloutMock.class, new MCFD_ExampleCalloutMock());
         MCFD_CCSApplication.submitApplicationSaveMethod(req);
         
     }*/
    }