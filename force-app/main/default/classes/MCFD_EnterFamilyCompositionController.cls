/*********************************************************************************************************
Name            : MCFD_EnterFamilyCompositionController.cls  
Description     : This class is used to insert and update the primary applicants and their dependants information  
Created By      : Deloitte
Created Date    : 27/Feb/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Abhishek      27/Feb/2017   
--------------------------------------------------------------------------------------------------------------            
Areeb         07/Mar/2017   Added function getContactInfofromBackend to retreive family composition info for 
                            logged in user from backend
--------------------------------------------------------------------------------------------------------------            

***************************************************************************************************************/

public without sharing class MCFD_EnterFamilyCompositionController{
    
    public static Contact conBasicInfo;
    public static Id userID;
    public static User uinfo;
    public static Set<Id> dependantsConID ;
    public static List<MCFD_Relationship__c> relnshipList ;
    public static List<MCFD_Contact_Address__c> contAddressList ;
    
    @AuraEnabled
    public static String GetSRfromICM(String JSONString, String AppNo) {
        
    Request__c Request = [select Id, ICM_SR_Number__c from Request__c where Name =: AppNo Limit 1];    
    
    if(Request.ICM_SR_Number__c == null || Request.ICM_SR_Number__c == '')
    {
        System.debug('Calling submit');
        String returnJSON = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CallWMToSubmitRTP');
        req.setMethod('POST');
        req.setHeader('Connection','keep-alive');
        req.setHeader('Content-Type', 'application/json');
          
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
                String SRNumber = '';
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
                Request.ICM_SR_Number__c = SRNumber;
                update Request;                
            }
        } 
        catch(System.CalloutException e) 
        {
        }     
        return returnJSON;
    }
    else
    {
        return '{"ErrorMessage":"SR exists"}';        
    }
    }


    
    @AuraEnabled
    public static Boolean changeToSpouseDOB (Contact spouse){
        List<Contact> OldSpouseInfo = [SELECT Id, Birthdate FROM Contact WHERE Id =: spouse.Id];

        Boolean returnVal;

        if (OldSpouseInfo.size() > 0)
        {
            System.debug(OldSpouseInfo[0].Birthdate);
            System.debug(spouse);

            System.debug(spouse.Birthdate);

            System.debug(spouse.Birthdate == OldSpouseInfo[0].Birthdate);

            

            if (spouse.Birthdate == OldSpouseInfo[0].Birthdate)
            {
                returnVal = false;
            }
            else
            {
                returnVal = true;
                //update spouse;
            }

            System.debug('returnVal == '+returnVal);
        }
        else
        {
            returnVal = true;
        }

        return returnVal;
    }

    @AuraEnabled
    public static Boolean changeToSpouseInfo (Contact spouse){    	
    	System.debug('DLS--in changeToSpouseInfo');
        List<Contact> OldSpouseInfo = [SELECT Id, BirthDate, FirstName, MiddleName, LastName FROM Contact WHERE Id =: spouse.Id];

        Boolean returnVal;

        if (OldSpouseInfo.size() > 0)
        {	System.debug('Have a record. Old data:');
            System.debug(OldSpouseInfo[0].FirstName);
            System.debug(OldSpouseInfo[0].MiddleName);
            System.debug(OldSpouseInfo[0].LastName);
            System.debug(OldSpouseInfo[0].BirthDate);
			System.debug('New data:');
            System.debug(spouse.FirstName);
			System.debug(spouse.MiddleName);
            System.debug(spouse.LastName);
            System.debug(spouse.BirthDate);
            if ((spouse.LastName == OldSpouseInfo[0].LastName)&&(spouse.FirstName == OldSpouseInfo[0].FirstName)&&(spouse.MiddleName == OldSpouseInfo[0].MiddleName)&&(spouse.BirthDate == OldSpouseInfo[0].BirthDate))
            {	
                returnVal = false;
            }
            else
            {	
                returnVal = true;
                //update spouse;
            }

            System.debug('returnVal == '+returnVal);
        }
        else
        {	
            returnVal = true;
        }

        return returnVal;
    }        
        
        
     @AuraEnabled
    public static void updateDependants(Contact DepContact) {
    
    upsert(DepContact);
    
    }
       
     
    @AuraEnabled
    public static void updateFamilyCompContacts(Map<String, Contact> ContactMap) {
    
        Contact PrimCon = ContactMap.get('Primary');
        upsert(PrimCon);
        
        if(ContactMap.get('Spouse')!=null)
        {
            Contact SpouseCon = ContactMap.get('Spouse');
            if(SpouseCon.Id !=null || SpouseCon.Id != '')
            {
            update(SpouseCon);
              
            List<MCFD_Relationship__c> SpouseConList = new List<MCFD_Relationship__c>();
            SpouseConList = [select Id,MCFD_Child_Contact__c, MCFD_Parent_Contact__c from MCFD_Relationship__c 
                             where MCFD_Parent_Contact__c =: PrimCon.Id and MCFD_Child_Contact__c=: SpouseCon.Id
                             and MCFD_Relationship_Type__c = 'Spouse' limit 1];    
            
                if(SpouseConList.size()==0)
                {
                MCFD_Relationship__c SpouseReln = new MCFD_Relationship__c();
                SpouseReln.MCFD_Child_Contact__c = (Id)SpouseCon.Id;
                SpouseReln.MCFD_Parent_Contact__c = (Id)PrimCon.Id;
                SpouseReln.MCFD_Relationship_Type__c = 'Spouse';
                insert SpouseReln;   
                }
                
            }
           
            
        }
          
         
        }
        
        
        
    
    
    
    @AuraEnabled
    public static void utilityMethod1() {
        userID = UserInfo.getUserId();
        System.debug('THIS IS USERS ID '+ userID);
        uinfo = [select Contactid, FirstName,MiddleName, LastName from user where id =: userID  Limit 1];
        System.debug('THIS IS USERS INFO '+ uinfo);
        System.debug('THIS IS USERS INFO '+ uinfo.ContactId);
      
        conBasicInfo = [select Id, FirstName, MiddleName,MCFD_Age__c , LastName, MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone, MCFD_Attending_School__c,MCFD_Currently_Employed__c,MCFD_Looking_For_Work__c,MCFD_Self_Employed__c,MCFD_Employment_Prog__c,MCFD_Medical_Condition__c from Contact where id =:uinfo.contactid Limit 1]; /*'0034D000001lgXX'*/    
         
         
         
         
    }
              

    @AuraEnabled
    public static void utilityMethod2() {         
                 relnshipList = [select MCFD_Parent_Contact__c, MCFD_Child_Contact__c, MCFD_Relationship_Type__c, MCFD_Request__c, MCFD_Dependant_Number__c from MCFD_Relationship__c where MCFD_Parent_Contact__c =: uinfo.ContactId ORDER BY MCFD_dependant_Number__c ];
    system.debug('inside utility1'+relnshipList);
    }   
    
    @AuraEnabled
    public static void utilityMethod3() {
                 contAddressList = [select MCFD_Address__c, MCFD_Address_Type__c, MCFD_Contact__c, MCFD_Request__c from MCFD_Contact_Address__c where MCFD_Contact__c =: uinfo.ContactId];
    }   
    
       
    // Call this function when Family Composition page loads 
    // use this function to show Primary Applicants Information 
    @AuraEnabled
    public static Contact getBasicInfo(){
        
        utilityMethod1();
        return conBasicInfo;
        
    } 
    
    

    // This function is used to update Primary Applicant's info
    // Use this funtion to insert spouse record
    @AuraEnabled
    public static void updtPrimaryAndSpouseInfo (Contact con,String conType){
        Id spouseReltnId;
        utilityMethod1();
        utilityMethod2();
        // update Primary applicants information
        if(conType == 'Primary'){
        
          update con;
          
        }
        // insert/update spouse information 
        else if(conType == 'Spouse'){
         // insert Spouse Information
         
         if(con.id!=null||con.id!='')
            spouseReltnId = con.id; 
         
            
         upsert con;
           

        }
    } 
    
    // This function is used to insert/update dependants info
    // Commenting this function as part of test class task 5475
/*    @AuraEnabled
    public static void upsertDependantsInfo (List<Contact> addDependants){
        utilityMethod1();
        utilityMethod2();
        System.debug('Check dependants 1 '+ addDependants);
        if(addDependants != Null && addDependants.size() > 0){
            // insert/update dependants information
           
             upsert addDependants ;
             
        }         
            dependantsConID = new Set<Id>();
            // collect dependants record id in a list
            if(relnshipList != Null && relnshipList.size() > 0){
                for(MCFD_Relationship__c rec: relnshipList){
                      
                    if(rec.MCFD_Relationship_Type__c == 'Dependant'){
                       
                     dependantsConID.add(rec.MCFD_Child_Contact__c); 
                     
                    }
                 }   
            }
            List<MCFD_Relationship__c> storeReltnshp = new List<MCFD_Relationship__c>();
            Integer Sequence=0;
            Boolean allNewFlag = true;
            if(dependantsConID != Null){
                Sequence = dependantsConID.size();
                allNewFlag = false;
                }
            for(Contact conDep : addDependants){
                
               
                // if dependants id doesnot exist in database then we need to create relationship record
                if(allNewFlag == true || !dependantsConID.contains(conDep.Id)){
                    
                MCFD_Relationship__c reltnew = new MCFD_Relationship__c();
                reltnew.MCFD_Child_Contact__c = (Id)conDep.id;
              //  reltnew.MCFD_Parent_Contact__c = (Id)uinfo.Contactid;
                reltnew.MCFD_Relationship_Type__c = 'Dependant';
                reltnew.MCFD_Dependant_Number__c = ++Sequence;    
                
                storeReltnshp.add(reltnew);
                
                }
                // perform insert operation for relationship             
            }
            
            if(storeReltnshp != Null && storeReltnshp.size() > 0){
                    insert storeReltnshp;
                }
    }    */
    
   
    // Call this when Family Composition page loads to display dependants information
    // Task 5475 - commenting this out as part of test class preparation 
     @AuraEnabled
     public static List<Contact> dependantsInfo (){
         utilityMethod1();
         utilityMethod2();
         List<Id> ConDependantIds = new List<Id>();
         List<Contact> dependantsList = new List<Contact>();
         // storing dependants id in a list
         for(MCFD_Relationship__c rec: relnshipList){
                                 if(rec.MCFD_Relationship_Type__c == 'Dependant'){
                     ConDependantIds.add(rec.MCFD_Child_Contact__c); 
                    }         
         }
         // query list of dependants
         if(ConDependantIds != null && ConDependantIds.size() > 0){
            dependantsList = [select Id,Name, FirstName, MiddleName, MCFD_Age__c ,LastName,(select id,MCFD_Relationship_Type__c from ChildContact__r), MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone from contact where id  in: ConDependantIds];     
         }
        
         if(dependantsList != Null && dependantsList.size() > 0){
             return dependantsList;
         }
         else{
             return null;
         }
        
    }
    
    // This function is used to delete dependants record along with Relationship
    // Call this function when user clicks on 'Delete dependant' button
    // Commenting this method as part of task 5475 - test class prep
/*    @AuraEnabled
    public static void deleteDependants(Contact deleteDependant){
       utilityMethod1();
       utilityMethod2();
       MCFD_Relationship__c reltnToDelete;
       for(MCFD_Relationship__c rec: RelnshipList){ 
           if(rec.MCFD_Child_Contact__c == deleteDependant.id){
                         reltnToDelete = rec;  
                          break;
           }            
         }
        if(reltnToDelete != Null){
        delete reltnToDelete; 
        }
        if(deleteDependant != Null){
        delete deleteDependant;
        }
    }*/
    
    
     
    // Call this function to load Home Address for Primary Applicant
    
    
    // Use this function to get the address record based on address type
    // commenting this blank function out as part of task 5475 - test class prep
/*    @AuraEnabled
    public static void getAddr(String AddressType){
                             
        
     }*/

    
    // call this function when user clicks on 'Next' button on Family Composition page
    // Task 5475 - commenting this function as this is not required
/*    @AuraEnabled
    public static void familyCompositionSave(Contact contPrimary, Contact contSpouse, List<Contact> dependants) {
        // To update Primary Applicants information
        updtPrimaryAndSpouseInfo(contPrimary, 'Primary'); 
        // To insert/update Spouse information
        if(contSpouse != Null && contSpouse.LastName !=''){  
        updtPrimaryAndSpouseInfo(contSpouse, 'Spouse');
        }
        // If spouse record is Null; delete the spouse record as well as relationship record
        if( (contSpouse != Null && contSpouse.LastName =='') || (contPrimary.MCFD_Marital_Status__c != 'Married, or living in a marriage-like relationship')) {    
        deleteDependants(contSpouse);
        }
        // To insert/update dependants information
        if(dependants != Null){        
        upsertDependantsInfo(Dependants);        
        }
    }*/
    
    // call this function when user clicks on 'Next' button on Primary Applicant Page
   @AuraEnabled
    public static void primaryApplicantSave(Contact contPrimary, MCFD_Address__c HomeAddress , MCFD_Address__c MailAddress){
        // To update primary applicants information
        updtPrimaryAndSpouseInfo(contPrimary, 'Primary');
        
        utilityMethod3();
        
        Map<ID,String> mapIdtoAddrType = new Map<ID,String>();
        List<MCFD_Address__c> AddrList = new List<MCFD_Address__c>();
        MCFD_Address__c MailAddr;
        MCFD_Address__c HmAddr;
        MCFD_Address__c HmAndMailAddr;
        MCFD_Contact_Address__c  ContAddrHome;
       
       
            }
       
    
              
     // call this function when user saves Dependants information
/*     @AuraEnabled
    public static void saveDependantInfo(Contact dependantsInfo){
        List<Contact> dependantsList = new List<Contact>();
        dependantsList.add(dependantsInfo);
        if(dependantsList != Null && dependantsList.size()>0){
        upsertDependantsInfo(dependantsList);
        }
       }*/
    
    // call this function to load Dependants information
    // Task 5475 - commenting out this method
    @AuraEnabled
    public static Contact individualDependantInfo(Integer dependantNo,String Type){
        Integer ListOrder = integer.valueof(dependantNo);
        
        System.debug('Dependant Number '+ dependantNo ); 
        System.debug('Type of '+ Type);
               
        List<Contact> addDependant = new List<Contact>();
        List<Contact> addAdultDependant = new List<Contact>();
        List<Contact> dependantsList = new List<Contact>();
            dependantsList = dependantsInfo();
        system.debug(dependantsList);
        for(Contact cont : dependantsList){
            if(cont.MCFD_Age__c > 19) {
                addAdultDependant.add(cont);
            } 
            
             if(cont.MCFD_Age__c <= 18) {
                addDependant.add(cont);
            } 
                                        
        }    
        system.debug('check child dependant '+ addDependant);
        system.debug('check adult dependant '+ addAdultDependant);
        if(addDependant != Null && addDependant.size()>0  && Type == 'Child'){
            return addDependant[ListOrder];            
            }
        if(addAdultDependant != Null && addAdultDependant.size()>0 && Type == 'Adult'){
             System.debug('Addult Dependant is '+ addAdultDependant[0] );   
            return addAdultDependant[ListOrder]; 
                   
            }    
            else{
            return null;
            }
        }
        
        
     // Call this function when main screen upload for RSN F CARE
    @AuraEnabled
    public static void saveContactInfo(Contact primCont){
    updtPrimaryAndSpouseInfo(Primcont, 'Spouse' );
    }
     
    @AuraEnabled
    public static User loggedInUserInfo(){
        return MCFD_LoggedInUser.getCurrentUser();
    }
    
   
    @AuraEnabled
    public static MCFD_Address__c preFillAddressMail(){
        List<MCFD_Contact_Address__c> conAdd = new List<MCFD_Contact_Address__c>([SELECT id, MCFD_Address__c, MCFD_Address_Type__c 
                                                FROM MCFD_Contact_Address__c 
                                                WHERE MCFD_Contact__c =: loggedInUserInfo().ContactId
                                                AND MCFD_Address_Type__c <> 'Home Address'
                                                ORDER BY LastModifiedDate DESC]);
        System.debug(conAdd);
        List<MCFD_Address__c> conMail = new List<MCFD_Address__c>([SELECT id, MCFD_Address_Line_1__c, MCFD_Address_Line_2__c, MCFD_Address_Line_3__c,
                                                                            MCFD_City__c, MCFD_Country__c, MAKId__c, MCFD_Postal_Code__c, MCFD_Province__c, 
                                                                            UnitNum__c
                                                                    FROM MCFD_Address__c
                                                                    WHERE Id =: conAdd[0].MCFD_Address__c]);
        return conMail[0];
    }

    @AuraEnabled
    public static void InsertDocumentChecklistMessage(String MessageToUser, String document, String subject, String caseType)
    {
        System.debug('Insert access denied message');
        //create an access denied message if there is no other access denied message for this CaseType
        //get all messages for the logged in user and check if they have an access denied message already
        List<User> LoggedInUser = [select ContactId, Contact.Name, Contact.MCFD_BCeID__c from user where id =:UserInfo.getUserId() limit 1];
        
        MCFD_Message__c newMessage = new MCFD_Message__c();

        //newMessage.Message_Received_From__c = 'My Family Services';
        newMessage.ICM_Date_Message_Sent__c = datetime.now();


        newMessage.Contact__c = LoggedInUser[0].ContactId;

        newMessage.Message_Status__c = 'Sent from ICM';
        newMessage.Message_Body__c = MessageToUser;
        newMessage.Message_Subject__c = subject;
        newMessage.ICM_Program_Type__c = caseType;
        newMessage.ICM_Disable_Reply__c = true;
        newMessage.Message_Recipient__c = LoggedInUser[0].Contact.Name;
        newMessage.Message_Type__c = 'General Message';


        try{
            insert newMessage;

            newMessage.ICM_Conversation_Id__c = newMessage.Id;

            update newMessage;
        }
        catch (DMLException e){
            System.debug('failed to create access denied message');
            System.debug(e);
            }
        


        
    }
  
    //SND fix for Bug 704774 
     @AuraEnabled
    public static Contact[] searchContact(Id primCont){
    Contact[] objContact=[Select id,Birthdate,LastName,FirstName,MiddleName from Contact where id=:primCont];
    
    return objContact;
    }

   

            
}