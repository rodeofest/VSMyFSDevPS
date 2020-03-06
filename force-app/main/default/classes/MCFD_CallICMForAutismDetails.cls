/*
Description     : This class is to generate XML for Autism Request  
Created By      : Deloitte
Created Date    : 10/May/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
PDAVE        25 OCT 2017    Bug fix 5236 : Autism Requests are not associated with the Contact
--------------------------------------------------------------------------------------------------------------              
PDAVE        04 DEC 2017    Fixed code quality issues    
--------------------------------------------------------------------------------------------------------------              

*/

public class MCFD_CallICMForAutismDetails {
    
    static List<User> LoggedInUser = [SELECT isActive, LastName, MiddleName, FirstName, ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c,
                                      MCFD_Deactivation_Reason__c, FederationIdentifier, MCFD_Old_FederationIdentifier__c    
                                      FROM User 
                                      WHERE id =:UserInfo.getUserId() 
                                      LIMIT 1];
                                      
    // PDAVE - US 515 - Integration has to be Synchronous call and return shell SR number
    @AuraEnabled
    public static String CreateRTASR(Id RequestId, String JSONString)
    {
        //CreateRTASR_callout(RequestId, JSONString);
        String SRNumber = '';
                        
        Request__c request = [select Id, ICM_SR_Number__c, MCFD_Status__c from Request__c where Id =: RequestId Limit 1];       
        
        if(request.ICM_SR_Number__c == null || request.ICM_SR_Number__c == '')
		{
			
			System.debug('Calling submit');
			String returnJSON = '';
			HttpRequest req = new HttpRequest();
			req.setEndpoint('callout:CallWMToSubmitRTP');
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/json');
			req.setTimeout(Integer.valueOf(System.Label.Timeout_RTA_ShellSR_Create));
			//req.setTimeout(60000);
			
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject(); 
			gen.writeStringField('Name', JSONString);
			gen.writeEndObject();
			
			req.setBody(gen.getAsString());
			System.debug(req.getBody()); 
			System.debug(req);
			
			Http http = new Http();
			try 
			{
				HTTPResponse res = http.send(req);
				returnJSON = res.getBody();
				System.debug('Response'+res.toString());
				System.debug('STATUS:'+res.getStatus());
				System.debug('STATUS_CODE:'+res.getStatusCode());
				System.debug(returnJSON);
				
				if(res.getStatusCode()==200)
				{
					JSONParser parser = JSON.createParser(res.getBody());
					while (parser.nextToken() != null) 
					{
						if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
						{
							// Get the value.
							parser.nextToken();
							// Compute the grand total price for all invoices.
							SRNumber = parser.getText();
						}
					}
					system.debug('SRNumber=' + SRNumber);
					request.ICM_SR_Number__c = SRNumber;
					request.MCFD_Status__c = 'In Progress';
					update request;                
				}else{
					request.MCFD_Status__c = 'Creation Error';        // Pavan: Bug fix 3918
					update request;         
				}
				
				if(SRNumber == ''){
					MCFD_Logger.log_integration_error('Shell SR Creation - RTA', 
												   MCFD_Logger.error, 
												   'MCFD_CallICMForAutismDetails', 
												   'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());
				}
			  }catch(System.CalloutException e) {
				 MCFD_Logger.log_integration_error('Shell SR Creation - RTA', 
												   MCFD_Logger.error, 
												   'MCFD_CallICMForAutismDetails', 
												   'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
			 }                
		
		}
		else
		{
			//return '{"ErrorMessage":"SR exists"}';        
			System.debug('SR Exists');
		}
		return SRNumber;
    }
    
    //ASHAIKH - added code for calling icm for getting shell sr number
    /*@AuraEnabled @future(callout=true)    
    public static void CreateRTASR_callout(Id RequestId, String JSONString)
    {
        
            
            
            
        
    }*/
    
    //AASHAIKH - added code to create Request object for Shell RTA SR.
    @AuraEnabled
    public static Id createShellRTA(String JSONString, String childFN, String childLN) {
        system.debug('childFN'+childFN);
      String returnString = 'SUCCESS';

      //get RTP record type ID
      List<RecordType> rtaRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='RTA']; 
      //create new request
      Request__c rtaSubmission = new Request__c();

      //set the record type to be a RTP Request
      rtaSubmission.RecordTypeId = rtaRecordTypeId[0].Id;
      rtaSubmission.MCFD_Status__c = 'Pending';
      rtaSubmission.MCFD_ChildFirstName__c= childFN;
      rtaSubmission.MCFD_ChildLastName__c= childLN;
      rtaSubmission.Primary_Applicant__c = LoggedInUser[0].ContactId;
      
      try{
        insert rtaSubmission;
        //CreateRTASR(rtaSubmission.Id, JSONString);
        system.debug('rtaSubmissionId'+rtaSubmission.Id);
        return rtaSubmission.Id;
      }
      catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return rtaSubmission.Id;
          //return rtaSubmission;
      }
        
      
    }
    
    //PDAVE: Fixed code quality issues
    // "for" loop should not have DML statement.
    // removed unrequired try-catch blocks
    @AuraEnabled
    public static ID SaveReimbursement(Request__c request, List<Sub_Request__c> travelList, List<Sub_Sub_request__c> travelCosts,List<Sub_Request__c> equipmentList, 
                                      List<Sub_Sub_Request__c> equipmentCosts, List<Sub_Request__c> trainingList, List<Sub_Request__c> employerCosts) {
      System.debug('Saving Reimbursement');

      Request__c reimbursement = request;

      try{
        update reimbursement;
        if (travelList[0].MCFD_Name_of_Travelers__c != '')
        {           
          update travelList;            
          /*for (Sub_Request__c item : travelList){
            System.debug(item);
            try{
              update item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        else if (travelList[0] != null)
        {
          Sub_Request__c deleteTravel = travelList[0];
          delete deleteTravel;
          /*try{
            Sub_Request__c deleteTravel = travelList[0];
            delete deleteTravel;
          }
          catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          }*/
        }
        if (travelCosts[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            for (Sub_Sub_Request__c item : travelCosts){
                System.debug(item);
                item.RecordTypeId = recordTypeId[0].Id;
            }
            insert travelCosts;
              
          /*
          for (Sub_Sub_Request__c item : travelCosts){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
          
        }
        if (equipmentList[0].MCFD_Service_Provider_Name__c != '')
        {
            update equipmentList;
          /*for (Sub_Request__c item : equipmentList){
            System.debug(item);
            try{
              update item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        else if (equipmentList[0] != null)
        {
            Sub_Request__c deleteEquip = equipmentList[0];
            delete deleteEquip;         
          /*try{
            Sub_Request__c deleteEquip = equipmentList[0];
            delete deleteEquip;
          }
          catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          }*/
        }
        if (equipmentCosts[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            for (Sub_Sub_Request__c item : equipmentCosts){
                System.debug(item);
                  item.RecordTypeId = recordTypeId[0].Id;                
            } 
            insert equipmentCosts;
            /*for (Sub_Sub_Request__c item : equipmentCosts){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        if (trainingList[0].MCFD_Rate__c > 0)
        {
          List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
          for (Sub_Request__c item : trainingList){
            System.debug(item);
              item.RecordTypeId = recordTypeId[0].Id;              
          }
          insert trainingList;
            
          /*for (Sub_Request__c item : trainingList){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        if (employerCosts[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items'];             
            for (Sub_Request__c item : employerCosts){
                System.debug(item);
                item.RecordTypeId = recordTypeId[0].Id;               
            }
            insert employerCosts;
            
          /*for (Sub_Request__c item : employerCosts){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
      }
      catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
      }
        
      return reimbursement.Id;
    }
    @AuraEnabled
    public static Request__c createReimbursement() {
      String returnString = 'SUCCESS';


      //get RTP record type ID
      List<RecordType> rtpRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='Reimbursement']; 



      //create new request
      Request__c rtpSubmission = new Request__c();

	  rtpSubmission.Primary_Applicant__c = LoggedInUser[0].ContactId;	
      //set the record type to be a RTP Request
      rtpSubmission.RecordTypeId = rtpRecordTypeId[0].Id;
      rtpSubmission.MCFD_Status__c = 'Pending';


      //Intervention Services Specific Fields

      rtpSubmission.MCFD_Street_Address__c = '';
      rtpSubmission.MCFD_Total_Amount__c = 0;
      rtpSubmission.MCFD_Travel_Sub_Total__c = 0;
      rtpSubmission.MCFD_Training_Sub_Total__c = 0;
      rtpSubmission.MCFD_Equipment_Sub_Total__c = 0;
      rtpSubmission.MCFD_Employer_Costs_Sub_Total__c = 0;
      rtpSubmission.MCFD_Unit_Number__c = '';
    //  rtpSubmission.MCFD_In_Canada__c = '';
      rtpSubmission.MCFD_USA_Services_Detail__c = '';

      //Travel,Training Equipment specific fields
      rtpSubmission.MCFD_Contact__c = '';
      rtpSubmission.MCFD_Receiving_Training__c = '';
      rtpSubmission.MCFD_Employee_Name__c = '';
      rtpSubmission.ICM_SR_Number__c = '';


      try{
        insert rtpSubmission;
        return rtpSubmission;
      }
      catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return rtpSubmission;
      }
        
      
    }
    
    @AuraEnabled
    public static Request__c createRTP() {
      String returnString = 'SUCCESS';


      //get RTP record type ID
      List<RecordType> rtpRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='RTP']; 



      //create new request
      Request__c rtpSubmission = new Request__c();
        
      rtpSubmission.Primary_Applicant__c = LoggedInUser[0].ContactId;
      //set the record type to be a RTP Request
      rtpSubmission.RecordTypeId = rtpRecordTypeId[0].Id;
      rtpSubmission.MCFD_Status__c = 'Pending';
      rtpSubmission.ICM_SR_Number__c = '';


      //Service Provider Fields
      rtpSubmission.MCFD_Service_Provider_Name__c = '';
      rtpSubmission.MCFD_Service_Provider_Type__c = '';
      rtpSubmission.MCFD_City__c = '';
      rtpSubmission.MCFD_Country__c = '';
      rtpSubmission.MCFD_First_Name__c = '';
      rtpSubmission.MCFD_Last_Name__c = '';
      rtpSubmission.MCFD_Middle_Name__c = '';
      rtpSubmission.MCFD_Phone__c = '';
      rtpSubmission.MCFD_Postal_Code__c = '';
      rtpSubmission.MCFD_Region__c = '';
      rtpSubmission.MCFD_Service_Provider_ID__c = '';
      rtpSubmission.MCFD_Service_Provider_Type__c = '';
      rtpSubmission.MCFD_CAS_Vendor__c = '';
      rtpSubmission.MCFD_CAS_Site__c = '';
      rtpSubmission.MCFD_Funding_Period_Start_Date__c = null;
      rtpSubmission.MCFD_Funding_Period_End_Date__c = null;
      rtpSubmission.MCFD_ChildFirstName__c = '';
      rtpSubmission.MCFD_ChildMiddleName__c = '';
      rtpSubmission.MCFD_ChildLastName__c = '';
      rtpSubmission.MCFD_ChildBirthDate__c = null;
      //Intervention Services Specific Fields

      rtpSubmission.MCFD_Street_Address__c = '';
      rtpSubmission.MCFD_Total_Amount__c = 0;
      rtpSubmission.MCFD_Unit_Number__c = '';
    //  rtpSubmission.MCFD_In_Canada__c = '';
      rtpSubmission.MCFD_USA_Services_Detail__c = '';

      //Travel,Training Equipment specific fields
      rtpSubmission.MCFD_Contact__c = '';
      rtpSubmission.MCFD_Receiving_Training__c = '';


      try{
        insert rtpSubmission;
        return rtpSubmission;
      }
      catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return rtpSubmission;
      }
        
      
    }
    @AuraEnabled
    public static String sendReimburesementToICM(Id requestId)
    {

      System.debug('start of sendRequestToICM');

      Request__c request = [SELECT Id, MCFD_Service_Provider_Type__c, ICM_SR_Number__c, MCFD_Equipment_Sub_Total__c, MCFD_Receiving_Training__c,
                            MCFD_Travel_Sub_Total__c, MCFD_Training_Sub_Total__c, MCFD_Total_Amount__c, MCFD_Service_Auth_Type__c,  
                            MCFD_ChildFirstName__c, MCFD_ChildMiddleName__c, MCFD_ChildLastName__c, MCFD_ChildBirthDate__c,
                            MCFD_Employer_Costs_Sub_Total__c, MCFD_Employee_Name__c, RecordType.Name, MCFD_Status__c,
                            CreatedById, CreatedBy.Name
                            FROM Request__c WHERE ID =: requestId ];

      List<Sub_Sub_request__c> TravelExpenses = new List<Sub_Sub_request__c>();
      List<Sub_Sub_request__c> EquipmentExpenses = new List<Sub_Sub_request__c>();

      List<Sub_Request__c> Travel = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, 
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Travel'];
      System.debug(Travel);
      if (Travel == null){
        Travel = new List<Sub_Request__c>();
      }
      else
      {
        List<Sub_Sub_request__c> newTravelList = new List<Sub_Sub_request__c>();
        for (Sub_Request__c trip : Travel)
        {
          newTravelList = new List<Sub_Sub_request__c>();
          newTravelList = [SELECT Id, Sub_Request__c, MCFD_Service_Description__c, MCFD_Rate__c 
                              FROM Sub_Sub_request__c WHERE Sub_Request__c =: trip.Id];
          for (Sub_Sub_request__c travelItem: newTravelList)
            TravelExpenses.add(travelItem);
        }
      }

      List<Sub_Request__c> Equipment = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, MCFD_Service_Provider_Name__c,
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Equipment'];
      System.debug(Equipment);
      if (Equipment == null){
        Equipment = new List<Sub_Request__c>();
      }
      else
      {
        List<Sub_Sub_request__c> newEquipList = new List<Sub_Sub_request__c>();
        for (Sub_Request__c receipt : Equipment)
        {
          newEquipList = new List<Sub_Sub_request__c>();
          newEquipList = [SELECT Id, Sub_Request__c, MCFD_Service_Description__c, MCFD_Rate__c 
                              FROM Sub_Sub_request__c WHERE Sub_Request__c =: receipt.Id];
          for (Sub_Sub_request__c lineItem: newEquipList)
            EquipmentExpenses.add(lineItem);
        }
      }

      List<Sub_Request__c> Training = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, MCFD_Service_Provider_Name__c,
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Training'];
      if (Training == null)
        Training = new List<Sub_Request__c>();

      List<Sub_Request__c> EmployerExp = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, MCFD_Service_Provider_Name__c,
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Employer Costs'];
      if (EmployerExp == null)
        EmployerExp = new List<Sub_Request__c>();

      System.debug('call xml and icm http class');
      String returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitReimbursement(request, Travel, Equipment, Training, EquipmentExpenses, TravelExpenses, EmployerExp);

      return returnString;
    }

    @AuraEnabled
    public static String sendRequestToICM(Id requestId)
    {
      System.debug('start of sendRequestToICM');

      Request__c request = [SELECT Id, MCFD_Service_Provider_Type__c, MCFD_Address_Update__c, ICM_SR_Number__c, MCFD_New_Funding_Period__c,
                            MCFD_Funding_Period_Start_Date__c, MCFD_Funding_Period_End_Date__c, MCFD_Service_Provider_Name__c,
                            MCFD_First_Name__c, MCFD_Middle_Name__c, MCFD_Last_Name__c, MCFD_Street_Address__c, MCFD_Unit_Number__c,
                            MCFD_City__c, MCFD_Region__c, MCFD_Postal_Code__c, MCFD_Country__c, MCFD_Phone__c, MCFD_Service_Auth_Type__c,
                            MCFD_USA_Services_Detail__c, MCFD_CAS_Vendor__c, MCFD_CAS_Site__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_In_Canada__c,
                            MCFD_Equipment_Sub_Total__c, MCFD_Travel_Sub_Total__c, MCFD_Training_Sub_Total__c, MCFD_Total_Amount__c ,
                            MCFD_ChildFirstName__c, MCFD_ChildMiddleName__c, MCFD_ChildLastName__c, MCFD_ChildBirthDate__c, MCFD_Receiving_Training__c,
                            MCFD_Status__c, RecordType.Name, CreatedById, CreatedBy.Name
                            FROM Request__c WHERE ID =: requestId ];

      List<Sub_Sub_request__c> TravelExpenses = new List<Sub_Sub_request__c>();
      List<Sub_Request__c> interventionList = new List<Sub_Request__c>();
      System.debug(request.MCFD_Service_Auth_Type__c);
      if (request.MCFD_Service_Auth_Type__c == 'Intervention Services')
        interventionList = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, 
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId];
      else
        interventionList = new List<Sub_Request__c>();

      System.debug(interventionList);

      List<Sub_Request__c> Travel = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, 
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Travel'];
      System.debug(Travel);
      if (Travel == null){
        Travel = new List<Sub_Request__c>();
      }
      else
      {
        List<Sub_Sub_request__c> newTravelList = new List<Sub_Sub_request__c>();
        for (Sub_Request__c trip : Travel)
        {
          newTravelList = new List<Sub_Sub_request__c>();
          newTravelList = [SELECT Id, Sub_Request__c, MCFD_Service_Description__c, MCFD_Rate__c 
                              FROM Sub_Sub_request__c WHERE Sub_Request__c =: trip.Id];
          for (Sub_Sub_request__c travelItem: newTravelList)
            TravelExpenses.add(travelItem);
        }
      }


      List<Sub_Request__c> Training = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, 
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Training'];
      if (Training == null)
        Training = new List<Sub_Request__c>();

      List<Sub_Request__c> EquipmentandSupplies = [SELECT Id, MCFD_Request__c, MCFD_RASP__c,MCFD_Rate_Unit__c, MCFD_Service_Type__c, 
                                    MCFD_Reasons_For_Travel__c, MCFD_Start_Date__c, MCFD_End_Date__c, MCFD_Name_Of_Travelers__c, 
                                    MCFD_To_Location__c, MCFD_From_Location__c, MCFD_Contact__c, MCFD_Service_Description__c, MCFD_Rate__c
                                    FROM Sub_Request__c WHERE MCFD_Request__c =: requestId AND MCFD_Service_Type__c =: 'Equipment'];
      if (EquipmentandSupplies == null)
        EquipmentandSupplies = new List<Sub_Request__c>();

      System.debug('call xml and icm http class');
      String returnString = MCFD_SubmitAutismRequestXMLGenerator.SubmitRTP(request, interventionList, Travel, 
                                                                          Training, EquipmentandSupplies, TravelExpenses);
      System.debug(returnString);
      return returnString;
    }
    
    //PDAVE : US 515 - Throwing custom exception after logging it.  - Custom exception not required
    
    //PDAVE: Fixed code quality issues
    // "for" loop should not have DML statement.
    @AuraEnabled
    public static ID SaveRTP(Request__c rtpObject, List<Sub_Request__c> interventionList) {
      System.debug('Saving RTP');

      List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Intervention Service']; 
      
      System.debug(recordTypeId);

      Request__c rtpSubmission = rtpObject;
      System.debug(rtpSubmission);
      System.debug(interventionList);

      try{
        update rtpSubmission;
        //save RTP intervention 
        if (interventionList != null)
        {
          for (Sub_Request__c intervention : interventionList){
            System.debug(intervention);
            //try{
              intervention.RecordTypeId = recordTypeId[0].Id;
              //intervention.MCFD_Service_Type__c = 'Intervention';
              //insert intervention;
            //}
            //catch(System.CalloutException e){
            //MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            //}
            
          }
          insert interventionList;
        }
        //TODO: add logic for saving subrequest of the RTP Part B. This is a user story in the backlog
      }
      catch(Exception e){
        MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
  }
        
      return rtpSubmission.Id;
    }
    
    //PDAVE: Fixed code quality issues
    // "for" loop should not have DML statement.
    // removed unrequired try-catch blocks
    @AuraEnabled
    public static ID SaveRTPPartB(Request__c rtpObject, List<Sub_Request__c> travelList, List<Sub_Sub_request__c> travelCosts,
                                  List<Sub_Request__c> equipmentList, List<Sub_Request__c> trainingList) {
      System.debug('Saving RTP');

	
      Request__c rtpSubmission = rtpObject;
                                      
      //adding below if for remedy 672625 / vsts 7131                                                                 
      if(rtpSubmission.MCFD_Total_Amount__c != null)
      {
			rtpSubmission.MCFD_Total_Amount__c = rtpSubmission.MCFD_Total_Amount__c.setScale(2, RoundingMode.HALF_UP);        
      }
      if(rtpSubmission.MCFD_Equipment_Sub_Total__c != null)
	  {
			rtpSubmission.MCFD_Equipment_Sub_Total__c = rtpSubmission.MCFD_Equipment_Sub_Total__c.setScale(2, RoundingMode.HALF_UP);       
      }
      if(rtpSubmission.MCFD_Training_Sub_Total__c != null)
      {
			rtpSubmission.MCFD_Training_Sub_Total__c = rtpSubmission.MCFD_Training_Sub_Total__c.setScale(2, RoundingMode.HALF_UP);        
      }
	  if(rtpSubmission.MCFD_Travel_Sub_Total__c != null)
      {
			rtpSubmission.MCFD_Travel_Sub_Total__c = rtpSubmission.MCFD_Travel_Sub_Total__c.setScale(2, RoundingMode.HALF_UP);        
      }
                                      
      System.debug(rtpSubmission);

      try{
        update rtpSubmission;
        if (travelList[0].MCFD_Name_of_Travelers__c != '')
        {
            update travelList;
          /*for (Sub_Request__c item : travelList){
            System.debug(item);
            try{
              update item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        else if (travelList[0] != null)
        {
            Sub_Request__c deleteTravel = travelList[0];
            delete deleteTravel;
          /*try{
            Sub_Request__c deleteTravel = travelList[0];
            delete deleteTravel;
          }
          catch(System.CalloutException e){
          MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          }*/
        }
        if (travelCosts[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            for (Sub_Sub_Request__c item : travelCosts){
                System.debug(item);
                item.RecordTypeId = recordTypeId[0].Id;             
            }
            insert travelCosts;
                              
          /*for (Sub_Sub_Request__c item : travelCosts){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='Cost Record']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        if (equipmentList[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items'];            
            for (Sub_Request__c item : equipmentList){
                System.debug(item);
                  item.RecordTypeId = recordTypeId[0].Id;                           
            }
            insert equipmentList;  
          /*for (Sub_Request__c item : equipmentList){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
        if (trainingList[0].MCFD_Rate__c > 0)
        {
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
            
            for (Sub_Request__c item : trainingList){
                System.debug(item);
                item.RecordTypeId = recordTypeId[0].Id;                             
            }
            insert trainingList;              
          /*for (Sub_Request__c item : trainingList){
            System.debug(item);
            List<RecordType> recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Items']; 
            try{
              item.RecordTypeId = recordTypeId[0].Id;
              insert item;
            }
            catch(System.CalloutException e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            }
            
          }*/
        }
      }
      catch(Exception e){
      MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
      }
        
      return rtpSubmission.Id;
    }
    @AuraEnabled 
    public static void updateStatus(Request__c myObject){

       myObject.MCFD_Status__c = 'Submitted';

        try{
          update myObject;

        }
        catch(System.CalloutException e){
        MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }

    }
    @AuraEnabled 
    public static void updateRTP_SRNUM(Request__c rtpObject, String srNum){

        rtpObject.ICM_SR_Number__c = srNum;
        rtpObject.MCFD_Status__c = 'In Progress';

        try{
          update rtpObject;

        }
        catch(System.CalloutException e){
        MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }

    }
    @AuraEnabled 
    public static void updateRTP_ERROR(Request__c rtpObject, String status){

        rtpObject.MCFD_Status__c = status;

        try{
          update rtpObject;

        }
        catch(System.CalloutException e){
        MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
        }

    }

     @AuraEnabled
    public static Sub_Request__c createEquipmentReimbursement(Id parentRequest) {

      //get RTP record type ID
      List<RecordType> reimbursementRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Equipment Request']; 



      //create new request
      Sub_Request__c reimbursement = new Sub_Request__c();


      //set the record type to be a RTP Request
      reimbursement.RecordTypeId = reimbursementRecordTypeId[0].Id;


      //RTP Travel fields
      reimbursement.MCFD_Service_Provider_Name__c = '';
      reimbursement.MCFD_Request__c = parentRequest;
      reimbursement.MCFD_Service_Type__c = 'Equipment';
      

      try{
        insert reimbursement;
        return reimbursement;
      }
      catch(System.CalloutException e){
      MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return reimbursement;
      }
        
      
    }  

    @AuraEnabled
    public static Sub_Request__c createTravelRTP(Id parentRequest) {

      //get RTP record type ID
      List<RecordType> rtpRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='Travel Request']; 



      //create new request
      Sub_Request__c rtpSubmission = new Sub_Request__c();


      //set the record type to be a RTP Request
      rtpSubmission.RecordTypeId = rtpRecordTypeId[0].Id;


      //RTP Travel fields
      rtpSubmission.MCFD_Reasons_For_Travel__c = '';
      rtpSubmission.MCFD_Name_of_Travelers__c = '';
      rtpSubmission.MCFD_From_Location__c = '';
      rtpSubmission.MCFD_To_Location__c = '';
      rtpSubmission.MCFD_Start_Date__c = null;
      rtpSubmission.MCFD_End_Date__c = null;
      rtpSubmission.MCFD_Request__c = parentRequest;
      rtpSubmission.MCFD_Service_Type__c = 'Travel';
      

      try{
        insert rtpSubmission;
        return rtpSubmission;
      }
      catch(System.CalloutException e){
      MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return rtpSubmission;
      }
        
      
    }    

    
    @AuraEnabled
    public static void deleteTravelRTP(Id objectId) {

      //get RTP record type ID
      System.debug(objectId);
      Sub_Request__c request = [SELECT Id from Sub_Request__c Where Id =: objectId LIMIT 1]; 
      System.debug(request);



      try{
        delete request;
        return;
      }
      catch(System.CalloutException e){
      MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          return;
      } 
      
    }

    @AuraEnabled
    public static String SubmitRTP(String JSONString, String SRSubType) {
      System.debug('Calling create');
      String interfaceName = '';
      if(SRSubType == 'Reimbursement'){
          interfaceName = 'Shell SR Creation - Reimbursement';
      }else if(SRSubType == 'Intervention'){
          interfaceName = 'Shell SR Creation - RTP Intervention';
      }else if(SRSubType == 'Travel, Training, or Equipment'){
          interfaceName = 'Shell SR Creation - RTP TTE';
      }
      String returnJSON = '';
      String SRNumber = '';
      String temp = 'Name';
      HttpRequest req = new HttpRequest();
      req.setEndpoint('callout:CallWMToSubmitRTP');
      //req.setEndpoint('callout:TestingSITPS');
          //System.debug(req.getEndpoint());
      req.setMethod('POST');
      req.setHeader('Connection','keep-alive');
      req.setHeader('Content-Type', 'application/json');
      req.setTimeout(Integer.valueOf(Label.Timeout_Reimb_Intrv_TTE_ShellSR_Create));
      //req.setTimeout(60000);
          
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject(); 
          gen.writeStringField('Name', JSONString);
          gen.writeEndObject();
          
      req.setBody(gen.getAsString());
      System.debug(req.getBody()); 
          System.debug(req);
      Http http = new Http();
      try {
        HTTPResponse res = http.send(req);
        returnJSON = res.getBody();
        System.debug('Response'+res.toString());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        System.debug(returnJSON);
        if(res.getStatusCode()==200)
        {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) 
            {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'SRNumber')) 
                {
                    // Get the value.
                    parser.nextToken();
                    // Compute the grand total price for all invoices.
                    SRNumber = parser.getText();
                }
            }
            system.debug('SRNumber=' + SRNumber);
        }
        if(SRNumber == ''){
            MCFD_Logger.log_integration_error(interfaceName, 
                                           MCFD_Logger.error, 
                                           'MCFD_CallICMForAutismDetails', 
                                           'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody());
        }
      }catch(System.CalloutException e) {
         MCFD_Logger.log_integration_error(interfaceName, 
                                           MCFD_Logger.error, 
                                           'MCFD_CallICMForAutismDetails', 
                                           'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
     }     
        return returnJSON;
    }
    
    // PDAVE : US 515 - Adding error logging logic for integration 
    @AuraEnabled
  public static String getCalloutResponseContents(String CaseNum) {
    String returnJSON = '';
    HttpRequest req = new HttpRequest();
    //Set HTTPRequest Method
    req.setEndpoint('callout:CallWMforAutismDetails?CaseNum='+CaseNum+'&CaseType=Autism');
    // req.setEndpoint('callout:TestingSITPS?ContactID='+ContactId+'&CaseType=Autism');
        req.setMethod('GET');
    req.setHeader('Connection','keep-alive');
    req.setTimeout(Integer.valueOf(Label.Timeout_Autism_Funding_Dashboard));
    //Set the HTTPRequest body 
  
    Http http = new Http();
    try {
      HTTPResponse res = http.send(req); 
        returnJSON = res.getBody();
      System.debug('Response'+res.toString());
      System.debug('STATUS:'+res.getStatus());
      System.debug('STATUS_CODE:'+res.getStatusCode());
    } 
    catch(System.CalloutException e) {
        System.debug(e.getmessage());
        MCFD_Logger.log_integration_error('Autism Funding Dashboard', 
                                           MCFD_Logger.error, 
                                           'MCFD_CallICMForAutismDetails', 
                                           'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
    }     
    System.debug(returnJSON);
    return returnJSON;
        
  }
  
   @AuraEnabled
    public static void apexLogError(String apexJsonResponse){
        System.debug('apexLogError() --> Logging error for invalid JSON');
        MCFD_Logger.log_integration_error('Autism Funding Dashboard', 
                                           MCFD_Logger.error, 
                                           'MCFD_CallICMForAutismDetails', 
                                           'Invalid/Error Response - ' + apexJsonResponse);
    }
    
  
   @AuraEnabled
    public static Request__c createRTA(Request__c reqRTA) {
      system.debug('call1');
      Id rtaRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Request__c' and Name='RTA' Limit 1].id; 
      Request__c rta = new Request__c();

      rta.RecordTypeId = rtaRecordTypeId ;
      rta.MCFD_Authorized_Amount__c = reqRTA.MCFD_Authorized_Amount__c;
      rta.MCFD_Remaining_Fund__c = reqRTA.MCFD_Remaining_Fund__c;

      insert rta;
      return rta;
     
    }


    @AuraEnabled
    public static ID SaveRTAServiceOrder(Sub_Request__c sorder) {
      system.debug(sorder);
      Id rtaRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='RTA Service Order' Limit 1].id; 
       System.debug(rtaRecordTypeId );
        Sub_Request__c so = new Sub_Request__c();
        so.RecordTypeId = rtaRecordTypeId ;
        so = sorder;
        insert so;
        return so.Id;
    }

    @AuraEnabled
    public static Id SaveOrderLineItem(Sub_Sub_Request__c orderLine) {
      
      Id recordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='RTA Service Order Line Items'].id; 
      
      Sub_Sub_Request__c solineReq = orderLine;
      solineReq.RecordTypeId = recordTypeId;
      insert solineReq;
      return solineReq.id;   
     
    }
          
    // Vai - May 5 2017 - adding a test method for testing outbound messaging call in a scheduled apex
    
 /*   @AuraEnabled @future(callout=true)
  public static void getCalloutResponseContentsScheduled(String ContactId) {
    String returnJSON = '';
    HttpRequest req = new HttpRequest();
    //Set HTTPRequest Method
    req.setEndpoint('callout:CallWMforAutismDetails?ContactID='+ContactId+'&CaseType=Autism');
    // req.setEndpoint('callout:TestingSITPS?ContactID='+ContactId+'&CaseType=Autism');
        req.setMethod('GET');
    req.setHeader('Connection','keep-alive');
    //Set the HTTPRequest body 
  
    Http http = new Http();
  try {
      HTTPResponse res = http.send(req); 
        returnJSON = res.getBody();
      processResponse(returnJSON);
      System.debug('Response'+res.toString());
      System.debug('STATUS:'+res.getStatus());
      System.debug('STATUS_CODE:'+res.getStatusCode());
  } 
     catch(System.CalloutException e) {
     MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_CallICMForAutismDetails' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
  }     
        
  }

    public static String processResponse(String returnJSON){
        System.debug(returnJSON);
        return(returnJSON);
    }*/
    
    @AuraEnabled
    public static Boolean fetchUserWelcomePagePreference() {
        List<User> UserDetails = [select ContactId, Contact.ICM_Contact_Id__c from user where id =:UserInfo.getUserId() limit 1];
        Contact UserContact = [select LastName, FirstName,ICM_Contact_Id__c,MCFD_Do_Not_Load_Autism_Welcome_Page__c from Contact where id =:UserDetails[0].ContactId limit 1];
        return UserContact.MCFD_Do_Not_Load_Autism_Welcome_Page__c ;
    }
    
    
    
}