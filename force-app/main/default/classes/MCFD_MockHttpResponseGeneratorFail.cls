/*********************************************************************************************************
Name            : MCFD_MockHttpResponseGeneratorFail.cls  
Description     : This class is to simulate response of web services.
Created By      : ARDC ICM
Created Date    : 23/May/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   23/05/2018   Original version 
--------------------------------------------------------------------------------------------------------------            
***************************************************************************************************************/
@isTest
global class MCFD_MockHttpResponseGeneratorFail implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('Error');
    res.setStatusCode(400);
    res.setBody('{"AttachmentId": "AttachmentId","parentID":"parentID","SRNumber":""}');
    return res;
  }
}