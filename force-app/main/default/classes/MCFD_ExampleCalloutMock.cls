/*********************************************************************************************************
Name            : MCFD_ExampleCalloutMock.cls  
Description     : This class is to setup a mock response  
Created By      : Deloitte
Created Date    : 12/June/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      12/June/2017   
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/

@isTest
global class MCFD_ExampleCalloutMock implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"method": "POST","SRNumber":"bar"}');
    return res;
  }
}