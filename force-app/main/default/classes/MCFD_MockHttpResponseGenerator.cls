/*********************************************************************************************************
Name            : MCFD_MockHttpResponseGenerator.cls  
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
global class MCFD_MockHttpResponseGenerator implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"AttachmentId": "AttachmentId","parentID":"bar","base64FileContents":"xyz123abcUVW","SRNumber":"123456","ErrorMessage":"Test"}');
    return res;
  }
}