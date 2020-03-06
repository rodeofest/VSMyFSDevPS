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
global class MCFD_Callout_Mock_InvalidResp implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"method": "POST","test":"bar"}');
    return res;
  }
}