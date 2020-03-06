/*********************************************************************************************************
Name            : MCFD_ExampleFailureCalloutMock.cls  
Description     : This class is to setup a mock response  
Created By      : Deloitte
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
PDAVE          10 OCT 2017    Original Version   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/

@isTest
global class MCFD_ExampleFailureCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody(System.Label.ICM_Dummy_Error_Response);
    return res;
  }
}