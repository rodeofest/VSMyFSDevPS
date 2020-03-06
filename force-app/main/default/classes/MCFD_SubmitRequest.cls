/*********************************************************************************************************
Name            : MCFD_SubmitRequest.cls  
Description     : This class is used to insert and update the CCS and Autism request to access case.  
Created By      : Deloitte
Created Date    : 5/May/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Vinanthi       27/Feb/2017   
Hemanth        13/June/2017  Added new method to update welcome page preferences of logged in user
PDAVE          17/Aug/2017   US 515 : Integration error handling logic
PDAVE          27 SEP 2017   Added error handling logic (CSS & AF Case Access Request) as part of US 4589
--------------------------------------------------------------------------------------------------------------                      

***************************************************************************************************************/

public without sharing class  MCFD_SubmitRequest{
    
    @AuraEnabled
    public static void updateCCSRequest(Request__c objRequest, Contact objCon, String primarySin, Contact primCon){
        
        update objRequest;
        
        List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
        //System.debug('ContactId--'+PrimCon.Birthdate);
        // update primary contact record
        List<Contact> primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =: ContactDetails[0].ContactId Limit 1];
        primecon[0].Birthdate = PrimCon.Birthdate;
        primecon[0].MCFD_SIN__c = primarySin;
        update primecon[0];
        //System.debug(primecon[0].Birthdate);
        MCFD_Relationship__c objRelation = new MCFD_Relationship__c();
        try{
            insert objCon;  
		   
			objRelation.MCFD_Child_Contact__c = objCon.Id;
			objRelation.MCFD_Request__c = objRequest.Id;
			objRelation.MCFD_Parent_Contact__c = primecon[0].Id;
			objRelation.MCFD_Relationship_Type__c = 'Dependant';
		   
			// insert the child record
            insert objRelation;
        }catch(Exception e){
           // system.debug('failed to insert record');
           MCFD_Logger.log_integ_err_for_request('Submission - Access existing CCS Cases', 
                                                                   MCFD_Logger.error, 
                                                                   'MCFD_SubmitRequest', 
                                                                   'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                                   objRequest.Id);
                                                                   
        }
        // add code here
        //system.debug('calling future method');
        //generateXML(objRequest.id, 'CCS');
    } 
    
    
    @AuraEnabled
    public static Request__c insertCCSRequest(){
        
        String returnString = 'SUCCESS';
        //get RTP record type ID
        List<RecordType> rtpRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='CCS case request']; 
        
        
        
        //create new request
        Request__c objRequest= new Request__c();
        //set the record type to be a RTP Request
        objRequest.RecordTypeId = rtpRecordTypeId[0].Id;
        objRequest.MCFD_First_Name__c = '';
        objRequest.MCFD_Last_Name__c = '';
        objRequest.MCFD_Middle_Name__c = '';
        objRequest.MCFD_Service_Provider_Name__c = '';
        insert objRequest;
        return objRequest;
        
    } 
    
    @AuraEnabled
    public static Request__c insertAutismRequest(){
        
        String returnString = 'SUCCESS';
        //get RTP record type ID
        List<RecordType> rtpRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='Autism case request']; 
        
        
        
        //create new request
        Request__c objRequest= new Request__c();
        //set the record type to be a RTP Request
        objRequest.RecordTypeId = rtpRecordTypeId[0].Id;
        objRequest.MCFD_First_Name__c = '';
        objRequest.MCFD_Last_Name__c = '';
        objRequest.MCFD_Middle_Name__c = '';
        objRequest.MCFD_Service_Provider_Name__c = '';
        
        insert objRequest;
        
        
        return objRequest;
        
    } 
    
    @AuraEnabled
    public static void updateAutismRequest(Request__c objRequest, List<Contact> listCon, Contact PrimaryContact){
        
        
        List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
        
        List<Contact> primecon = [Select Id, BirthDate, MCFD_SIN__c from Contact where id =: ContactDetails[0].ContactId Limit 1];
        primecon[0].Birthdate = PrimaryContact.Birthdate;
        update primecon[0];
        //System.debug(primecon[0].Birthdate);
        
        MCFD_Relationship__c objRelation ;
        List<MCFD_Relationship__c> listRelation = new  List<MCFD_Relationship__c>();
        try{
            // insert contact records
            insert listCon;
        
			for(Contact objContact: listCon){
				// create relationship records for all dependants
				objRelation = new MCFD_Relationship__c();
				objRelation.MCFD_Child_Contact__c = objContact.Id;
				objRelation.MCFD_Request__c = objRequest.Id;
				
				objRelation.MCFD_Parent_Contact__c = primecon[0].Id;
				objRelation.MCFD_Relationship_Type__c = 'Dependant';
				
				listRelation.add(objRelation);
			}
			
			if(listRelation.size() > 0)
			{
			   
					insert listRelation;
				
			}
			
			// update request object and generate XMl for Autism
            update objRequest;
            //generateXML(objRequest.id, 'Autism');
        
        }catch(Exception e){
          //  system.debug('failed to insert record');
           MCFD_Logger.log_integ_err_for_request('Submission - Access existing Autism Cases', 
                                                   MCFD_Logger.error, 
                                                   'MCFD_SubmitRequest', 
                                                   'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                   objRequest.Id);
                                                                   
        }
    } 
    
    //@Future(callout=true)
    @AuraEnabled
    public static String generateXML(String objRequestId, String ApplicationName)
    {   
        //system.debug('>> calling XML Generator function');
        // call function to generate XML based on Application Type
        String responseString;
        if(ApplicationName == 'Autism'){
            responseString = MCFD_SubmitRequestXMLGenerator.SubmitAutismRequest(objRequestid);
        }
        if(ApplicationName == 'CCS')     {
            responseString = MCFD_SubmitRequestXMLGenerator.SubmitCSSRequest(objRequestid);
        }
        return responseString;
    }
    
    //Hemanth changes starts here 
    
     @AuraEnabled
    public static void upsertContactPref(boolean flag){
        system.debug('eneterd into UpsertContactPref method');
        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
       Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c,MCFD_Do_Not_Load_Autism_Welcome_Page__c from Contact where id = :UserDetails[0].ContactId limit 1];
      // Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c,MCFD_Do_Not_Load_Autism_Welcome_Page__c from Contact where id ='0034D000004OgVv'];
       
        system.debug(UserContact );        
        UserContact.MCFD_Do_Not_Load_Autism_Welcome_Page__c= flag;
        update  UserContact ;
        system.debug(UserContact );
    }
    
    @AuraEnabled
    public static Boolean fetchUserWelcomePagePreferenceAgain() {
    return MCFD_CallICMForContactDetails.fetchUserWelcomePagePreference();
    
    }
    //Hemanth changes ends here
    
    @AuraEnabled 
    public static void updateAccess_ERROR(Request__c accessReq, String status){

        accessReq.MCFD_Status__c = status;

        update accessReq;

    }
    
}