/*********************************************************************************************************
Name            : MCFD_GetMetadata_Test.cls  
Description     : This class is to test MCFD_GetMetadata.cls functions. 
Created By      : Areeb Shaikh
Created Date    : 08/05/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date             Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   08/06/2018     Refactoring Test class and Code standards applied
--------------------------------------------------------------------------------------------------------------
***************************************************************************************************************/  
@isTest(seeAllData=false)
public class MCFD_GetMetadata_Test {
    
    static testMethod void test_method_one() {
        Test.startTest();
        	MCFD_GetMetadata.getListView('My_Submitted_Requests','Request__c');
        Test.stopTest();
	}
}