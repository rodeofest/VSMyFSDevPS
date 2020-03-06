/*********************************************************************************************************
Name            : MCFD_ReasonForCareController_Test.cls  
Description     : This class is to test MCFD_ReasonForCareController.cls functions.
Created By      : ARDC ICM
Created Date    : 
Modification Log: Updated
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------                          
Rosario      08/Jun/2018	Standards applied
--------------------------------------------------------------------------------------------------------------
Liliana      20 Jun 2018    Refactoring test methods 
*************************************************************************************************************/
@isTest (SeeAllData=false)
public class MCFD_ReasonForCareController_Test {
 	
    static void setup() { 
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;     
    }

    static testMethod void testmethod1() {
       Test.startTest();
       setup();
       Contact objCon = [SELECT Id, FirstName, MiddleName,MCFD_Age__c , LastName, MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, 
                      MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone, 
                      MCFD_Attending_School__c,MCFD_Currently_Employed__c,MCFD_Looking_For_Work__c,MCFD_Self_Employed__c,MCFD_Employment_Prog__c,MCFD_Medical_Condition__c 
                      FROM Contact LIMIT 1]; 
      
       Reason_For_Care__c objReasonFcare = new Reason_For_Care__c();
       objReasonFcare.MCFD_Rsn_For_Care_Type__c = 'Employment';
       insert objReasonFcare;
      
       MCFD_ReasonForCareController.upsertRsnFCare(objCon.id, objReasonFcare);
       
       List<Reason_For_Care__c> listReasonFcare = new List<Reason_for_care__c>();
       listReasonFcare = MCFD_ReasonForCareController.RsnFCare(objCon.id,'Employment');
       Test.stopTest();
       }
}