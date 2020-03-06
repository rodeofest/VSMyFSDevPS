public without sharing class MCFD_GetSetContactDetails {

    @AuraEnabled
	public static Contact getContactDetails(){
        
    List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
    
    List<Contact> primecon = [Select FirstName,MiddleName,LastName,ICM_Home_Phone__c, ICM_Cell_Phone__c, 
                              ICM_Message_Phone__c, ICM_Work_Phone__c, Email from Contact where id =: ContactDetails[0].ContactId Limit 1];

    //System.debug(primecon[0]);
    return primecon[0];
        
        
    }
    
    @AuraEnabled
    public static void SetContactEmail(String Email){
    
    List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
    
    List<Contact> primecon = [Select FirstName,MiddleName,LastName,ICM_Home_Phone__c, ICM_Cell_Phone__c, 
                              ICM_Message_Phone__c, ICM_Work_Phone__c, Email from Contact where id =: ContactDetails[0].ContactId Limit 1];

    	primecon[0].Email = Email;
        update primecon[0];
    
        }
    @AuraEnabled
    public static void SetContactPhone(String Phone){
    List<User> ContactDetails = [select ContactId from user where id =:UserInfo.getUserId() limit 1];
    
    List<Contact> primecon = [Select FirstName,MiddleName,LastName,ICM_Home_Phone__c, ICM_Cell_Phone__c, 
                              ICM_Message_Phone__c, ICM_Work_Phone__c, Email from Contact where id =: ContactDetails[0].ContactId Limit 1];

    	primecon[0].ICM_Cell_Phone__c = Phone;
       
        update primecon[0];
        
    }
    
}