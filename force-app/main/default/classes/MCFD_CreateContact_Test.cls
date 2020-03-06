/*********************************************************************************************************
Name            : MCFD_CreateContact_Test.cls  
Description     : This class is to test MCFD_CreateContact.cls functions. 
Created By      : Deloitte
Created Date    : 17/April/2017
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date             Description
--------------------------------------------------------------------------------------------------------------            
Pavan Dave    17 APR 2017      Original Version
--------------------------------------------------------------------------------------------------------------
Pavan Dave    17 OCT 2017      Refactoring test methods
--------------------------------------------------------------------------------------------------------------
Liliana Trejo   22/05/2018     Refactoring Test class and Code standards applied
--------------------------------------------------------------------------------------------------------------
***************************************************************************************************************/              
@isTest(seeAllData=false)
public class MCFD_CreateContact_Test {
    
   	@testSetup
    static void setup() {
        Account objAccount=TestDataFactory.createAccount('Deepak Community Account');
        insert objAccount;
        Account objAccount2=TestDataFactory.createAccount('Deepak Community Account2');
        insert objAccount2;
        Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra Community', objAccount.Id, '', 'Deepak');
        insert objContact;
        MCFD_Address__c objAddress=TestDataFactory.createMCFDAddress('Test');
        insert objAddress;
        Profile objProfile=TestDataFactory.getProfile('Customer Community Plus Login User');
        User objUser = TestDataFactory.createUser(objContact, objProfile, 'standarduser@testorg.com', '7C01518C8CBD48ED93C10918BD554321');
        insert objUser;
        User objUser2=[Select Id from User where email='standarduser@testorg.com'];
        MCFD_Portal_Settings__c  objPortalSettings =TestDataFactory.createPortalSettings('Customer Community Plus Login User', 'Test',objUser2);
        insert objPortalSettings;
        MCFD_Portal_SSO_Redirection__c objPortalSSORedirection = TestDataFactory.createPortalSSORedirection();
        insert objPortalSSORedirection;        
    }
    
    static testMethod void create_Portal_User(){ 
        Test.startTest();
            Account objAccount =[Select id,Name from Account where Name='Deepak Community Account2'];
            Contact objContact = TestDataFactory.createContact('Sumra CommunitySumra', objAccount.Id, '', 'Test');
            MCFD_Address__c objAddress=TestDataFactory.createMCFDAddress('Test'); 
            MCFD_CreateContact.create_Portal_User(objContact, objAddress);
        Test.stopTest();
    }  
    
    static testMethod void create_Portal_UserFail(){
        Test.startTest();
            Contact objContact2=[Select id,MCFD_BCeID__c,MCFD_GUID__c,FirstName,MiddleName,LastName from Contact ];
            MCFD_Address__c objAddress=[Select id,MCFD_Address_Line_2__c,MCFD_Address_Line_1__c,MCFD_Province__c,MCFD_Postal_Code__c ,MCFD_City__c from MCFD_Address__c ];
            MCFD_Portal_Settings__c mcfdSetting = MCFD_Portal_Settings__c.getAll().values().get(0);
            MCFD_CreateContact.create_Portal_User(objContact2, objAddress);
        Test.stopTest();
    } 
    
    static testMethod void apex_decrpt_url(){
        Test.startTest();
        //    MCFD_CreateContact.apex_decrpt_url('dGVzdCBiYXNlIDY0IHN0cmluZw==');
        Test.stopTest();
     } 
    
    static testMethod void portal_Account_Manual_Share(){
        Test.startTest();
          Account objAccount =[Select id,Name from Account where Name='Deepak Community Account2'];
          User objUser=[Select Id from User where email='standarduser@testorg.com'];          
          MCFD_CreateContact.portal_Account_Manual_Share(objAccount.id, objUser.Id,objUser.Id );
        Test.stopTest();
     } 
    
    static testMethod void portal_Account_Manual_ShareFail(){
        Test.startTest();
          Id idUser='005410000025ns8AAA';
          Id idAccount='005410000025ns8AAA';
          MCFD_CreateContact.portal_Account_Manual_Share(idAccount, idUser,idAccount );
        Test.stopTest();
     }
    
    }