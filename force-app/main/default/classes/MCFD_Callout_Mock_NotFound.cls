/*
Description     : This class is to setup a mock error response  
Created By      : Deloitte
Created Date    : 01 NOV 2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      01 NOV 2017   
--------------------------------------------------------------------------------------------------------------              
*/

@isTest
global class MCFD_Callout_Mock_NotFound implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('NotFound');
    res.setStatusCode(400);
    res.setBody(System.Label.ICM_Dummy_Error_Response);
    return res;
  }
}