/************************************************************************************
Function        : test class for MCFD_BatchCallForICMMessages

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavan Dave                10 OCT 2017             Original Version
--------------------------------------------------------------------------------------------------------------                       
*Liliana Trejo               03/07/2018               Updated all methods
***************************************************************************************************************/

@isTest
public class MCFD_BatchCallForICMMessages_Test{
    
     static testMethod void MCFD_BatchCallForICMMessages(){
        Test.setMock(HttpCalloutMock.class, new MCFD_BatchCallForICMMessagesMock());
       	Database.executeBatch(new MCFD_BatchCallForICMMessages());
    }
    
     static testMethod void MCFD_BatchCallForICMMessages2(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MCFD_BatchCallForICMMessagesMock());
            Database.executeBatch(new MCFD_BatchCallForICMMessages());
        Test.stopTest();
    }
    
     static testMethod void MCFD_BatchCallForICMMessages3(){
        Test.startTest();
             Contact objContact =TestDataFactory.createSpouse();
             objContact.MCFD_GUID__c='1V3LMP313UJN145XM68KM25MJ25TF067';
             objContact.ICM_Contact_Id__c='1-4D5AG6K';
             insert objContact;
             Test.setMock(HttpCalloutMock.class, new MCFD_BatchCallForICMMessagesMockParam());
       	Database.executeBatch(new MCFD_BatchCallForICMMessages());
        Test.stopTest();
    }
}