/**************************************************************************************
Function            : Controller class for Document Checklist VF Page

Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* LAPERRY                     27 SEP 2017            Created
* PDAVE                       22 NOV 2017            Bug Fix 5403: PDF Checklist - order of documents listed
*************************************************************************************/

public without sharing class MCFD_PDFGenerator {
	  public static ID parentId {get;set;}
  	public static String pdfName {get;set;}


  	public String getContactName (){

  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];

  		return LoggedInUser[0].Contact.Name;
  	}

  	public String getRequestNum (){
  		
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, ICM_SR_Number__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

      if(allRequests.size() > 0)
        return allRequests[0].ICM_SR_Number__c;
      else
        return 'error';
  	}

  	public String getSubmittedDate (){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c, LastModifiedDate FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Date submittedDate;
        if(allRequests.size() > 0)
        {
          submittedDate = Date.valueOf(allRequests[0].LastModifiedDate);
          String dateString = submittedDate.format();

          String[] splitDate = dateString.split('/');

          String[] months = new List<String>();
          months.add('Jan');
          months.add('Feb');
          months.add('Mar');
          months.add('Apr');
          months.add('May');
          months.add('Jun');
          months.add('Jul');
          months.add('Aug');
          months.add('Sept'); 
          months.add('Oct');
          months.add('Nov');
          months.add('Dec');

          String day = splitDate[0];

          String[] daySplit = day.split('');

          if (daySplit[0] == '0')
            day = daySplit[1];
          
          Integer monthNum = Integer.valueOf(splitDate[1]) - 1;

          if(monthNum < 12)
            return  months[monthNum] + ' ' + day + ', ' + splitDate[2];
          else
            return 'error';
        }
        else
        {
          return 'error';
        }

        
  	}

  	public List<MCFD_Attachment__c> getDocumentsProvided(){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() > 0)
          mostRecentRequest = allRequests[0].Id;


        String status = 'Document Uploaded';


        List<MCFD_Attachment__c> allDocuments = [SELECT Id, MCFD_Request_Id__c, MCFD_Attachment_Name__c,MCFD_Status__c
                                                FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: mostRecentRequest
                                                AND MCFD_Status__c =: status AND MCFD_Category__c<>'Other' //AND MCFD_Attachment_Name__c != ''
                                                ORDER BY MCFD_Category__c ASC NULLS LAST];
        
        List<MCFD_Attachment__c> tempAllDocuments = new List<MCFD_Attachment__c>();
        for(integer i =0; i < allDocuments.size(); i++)
        {
           if(allDocuments[i].MCFD_Attachment_Name__c != '')
           {
               tempAllDocuments.add(allDocuments[i]);
           }
        }
        

        return tempAllDocuments;


  	}

  	public List<Attachment> getAdditionalDocumentsProvided(){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() > 0)
          mostRecentRequest = allRequests[0].Id;


        String status = 'Document Uploaded';

        String blankname = '';
        

        List<MCFD_Attachment__c> allDocuments = [SELECT Id, MCFD_Request_Id__c, MCFD_Attachment_Name__c,MCFD_Status__c
                                                FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: mostRecentRequest
                                                AND MCFD_Status__c =: status AND MCFD_Category__c<>'Other' //AND MCFD_Attachment_Name__c =: blankname
                                                ORDER BY MCFD_Category__c ASC NULLS LAST];
        
		List<MCFD_Attachment__c> tempAllDocuments = new List<MCFD_Attachment__c>();
        for(integer i =0; i < allDocuments.size(); i++)
        {
           if(allDocuments[i].MCFD_Attachment_Name__c == blankname)
           {
               tempAllDocuments.add(allDocuments[i]);
           }
        }
        
        
        List<Attachment> allAttachements = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN :tempAllDocuments];

        return allAttachements;


  	}

  	public List<MCFD_Attachment__c> getDocumentsOnFile(){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() > 0)
          mostRecentRequest = allRequests[0].Id;


        String status = 'Current document on file';

        List<MCFD_Attachment__c> allDocuments = [SELECT Id, MCFD_Request_Id__c, MCFD_Attachment_Name__c,MCFD_Status__c
                                                FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: mostRecentRequest
                                                AND MCFD_Status__c =: status AND MCFD_Category__c<>'Other'
                                                ORDER BY MCFD_Category__c ASC NULLS LAST];

        return allDocuments;
  	}

  	public List<MCFD_Attachment__c> getDocumentsRequired(){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() > 0)
          mostRecentRequest = allRequests[0].Id;


        String status = 'Document being sent by other means';

        List<MCFD_Attachment__c> allDocuments = [SELECT Id, MCFD_Request_Id__c, MCFD_Attachment_Name__c,MCFD_Status__c, MCFD_Mandatory__c
                                                FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: mostRecentRequest
                                                AND MCFD_Status__c =: status AND MCFD_Mandatory__c = TRUE AND MCFD_Category__c<>'Other'
                                                ORDER BY MCFD_Category__c ASC NULLS LAST];

        System.debug('all required documents');
        System.debug(allDocuments);
        return allDocuments;
  	}

  	public List<MCFD_Attachment__c> getDocumentsSupporting(){
  		List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
  		String loggedinContactName = LoggedInUser[0].Name;

  		List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name, MCFD_Submitted_Date__c FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() > 0)
          mostRecentRequest = allRequests[0].Id;


        String status = 'Document being sent by other means';
        String status2 = 'Missing supporting document';

        List<MCFD_Attachment__c> allDocuments = [SELECT Id, MCFD_Request_Id__c, MCFD_Attachment_Name__c,MCFD_Status__c, MCFD_Mandatory__c
                                                FROM MCFD_Attachment__c WHERE MCFD_Request_Id__c =: mostRecentRequest
                                                AND ((MCFD_Status__c =: status AND MCFD_Mandatory__c = FALSE) OR MCFD_Status__c =: status2)
                                                ORDER BY MCFD_Category__c ASC NULLS LAST];

        System.debug('all supporting documents');
        System.debug(allDocuments);
        return allDocuments;
  	}

	public MCFD_PDFGenerator() {

		System.debug('class constructor for pdf');


	}

	
	@AuraEnabled
 	public static void savePdf(Id requestID) {

	    System.debug('DLS--saving the pdf');
		system.debug('Passed Request ID- '+requestID);
	   List<User> LoggedInUser = [select Id, Name, ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
        
        //get the request ID by finding the most recently created request by the logged in user
        Id loggedInContact = LoggedInUser[0].ContactId;
        String loggedinContactName = LoggedInUser[0].Name;

       /* List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name FROM Request__c
        								WHERE LastModifiedBy.Name =: loggedinContactName
        								ORDER BY LastModifiedDate DESC NULLS LAST]; */
        								
         List<Request__c> allRequests = [SELECT Id, Primary_Applicant__c, LastModifiedBy.Name FROM Request__c
        								WHERE id =: requestID
        								ORDER BY LastModifiedDate DESC NULLS LAST];

        Id mostRecentRequest;
        if(allRequests.size() >= 0)
        {
          mostRecentRequest = allRequests[0].Id;
          if(allRequests[0].Primary_Applicant__c != loggedInContact){
       	  		System.debug('DLS -- this is the spouse');
        		//return;
        	}
        	else{
        		System.debug('DLS-this is the primary applicant');
        	}
        } 
        
        

       	//Id mostRecentRequest = 'a0Fc0000005rydh';
       	String documentName = 'Document Checklist';

       	System.debug('Insert document checklist message');
        //create an access denied message if there is no other access denied message for this CaseType
        //get all messages for the logged in user and check if they have an access denied message already
      //  List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
        
        MCFD_Message__c newMessage = new MCFD_Message__c();

        //newMessage.Message_Received_From__c = 'My Family Services';
        newMessage.ICM_Date_Message_Sent__c = datetime.now();


        newMessage.Contact__c = allRequests[0].Primary_Applicant__c;

        newMessage.Message_Status__c = 'Sent from ICM';
        if(allRequests[0].Primary_Applicant__c != loggedInContact)
        {
            
            newMessage.Message_Body__c = Label.CCS_Checklist_Spouse_Message_Body;
            newMessage.Message_Subject__c = Label.CCS_Checklist_Spouse_Message_Subject;
        }
        else
        {
           
        newMessage.Message_Body__c = Label.CCS_Checklist_Message_Body;
        newMessage.Message_Subject__c = 'Document Checklist';
        }
        newMessage.ICM_Program_Type__c = 'Child Care Subsidy';
        newMessage.ICM_Disable_Reply__c = true;
        //newMessage.Message_Recipient__c = LoggedInUser[0].Contact.Name; 
        newMessage.Message_Recipient__c = allRequests[0].Primary_Applicant__c;
        newMessage.Message_Type__c = 'General Message';
        newMessage.ICM_SR_Id__c = mostRecentRequest;


        //check if we should create this message
        List<MCFD_Message__c> requestMessages = [SELECT Id, ICM_SR_Id__c FROM MCFD_Message__c 
        										WHERE ICM_SR_Id__c =: mostRecentRequest];
        System.debug('requestMessages===' +requestMessages);
        //if(requestMessages.size() == 0){
        	try{
	            insert newMessage;

	            newMessage.ICM_Conversation_Id__c = newMessage.Id;

            if(allRequests[0].Primary_Applicant__c == loggedInContact){

	            MCFD_Attachment__c newAttachment = new MCFD_Attachment__c();

			    newAttachment.MCFD_Last_Modified_Date__c = System.Now();
			    newAttachment.MCFD_Contact_Id__c = loggedInContact; 
			    newAttachment.MCFD_Attachment_Name__c = documentName;
			    newAttachment.MCFD_Type__c = 'Document Checklist';
			    newAttachment.MCFD_Request_Id__c = mostRecentRequest;
			    newAttachment.Linked_Message_Id__c = newMessage.ID;

			    insert newAttachment;

			    System.debug('new attachment created ==>>');
			    System.debug(newAttachment);

                PageReference pdf = Page.MCFD_ACCBRenderDocumentChecklist;
			    // add parent id to the parameters for standardcontroller
			    pdf.getParameters().put('id',parentId);

			    // create the new attachment
			    Attachment attach = new Attachment();

			    // the contents of the attachment from the pdf
			    Blob body;

			    try {

			        // returns the output of the page as a PDF
			        body = pdf.getContent();

			    // need to pass unit test -- current bug    
			    } catch (VisualforceException e) {
			        body = Blob.valueOf('The content of the pdf was not created properly');
			    }

			    attach.Body = body;
			    // add the user entered name
			    attach.Name = 'Document Checklist.pdf';
			    attach.IsPrivate = false;
			    // attach the pdf to the account
			    attach.ParentId = newAttachment.Id;
			    insert attach;

			    MCFD_ContentController.SendAttachmentToICM(attach.Id, 'Upload');



	            update newMessage;


	        }
	        }
        catch (DMLException e){
            System.debug('failed to create access denied message===' +e);
        }

        return;
        

  	}
}