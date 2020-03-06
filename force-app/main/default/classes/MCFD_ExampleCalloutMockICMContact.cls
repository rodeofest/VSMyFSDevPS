@isTest
global class MCFD_ExampleCalloutMockICMContact implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"SRInformation" : [ {"SRNumber" : "1234fgf56789", "Status" : "Closed","SubStatus" : "","Resolution" : "", "Type" : "Child Care Subsidy", "SubType" : "Application","SubSubType" : "","ClosedDate" : "", "CreatedDate" : "10/01/2019"}, {"SRNumber" : "1-9650235919", "Status" : "Open","SubStatus" : "","Resolution" : "","Type" : "Child Care Subsidy", "SubType" : "Renewal", "SubSubType" : "", "ClosedDate" : "","CreatedDate" : "10/11/2018"},{"SRNumber" : "1-9658691297","Status" : "Open","SubStatus" : "","Resolution" : "","Type" : "Child Care Subsidy", "SubType" : "Portal Registration","SubSubType" : "", "ClosedDate" : "","CreatedDate" : "10/01/2019"}, {"SRNumber" : "1-9639340135","Status" : "Open","SubStatus" : "", "Resolution" : "", "Type" : "Autism Funding Unit", "SubType" : "Portal Registration", "SubSubType" : "","ClosedDate" : "","CreatedDate" : "10/06/2018"}], "Result" : "SUCCESS","errorDetails" : [ {"status" : "SUCCESS"} ]}');
        return res;
    }

}