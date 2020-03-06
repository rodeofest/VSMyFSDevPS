@isTest
global class MCFD_ExampleCalloutMockCancelSR implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"SRNumber" : "1-9667613379","Result" : "SUCCESS"}');
        return res;
    }

}