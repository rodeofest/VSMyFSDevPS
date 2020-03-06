public with sharing class MCFD_LoggedInUser {
    public MCFD_LoggedInUser() {
         
    }
    // Modified by PDAVE: US 435 - CCS Application - Pre-Population of Form Fields from User Profile Information and Contact Data Model Update
    @AuraEnabled
    public static User getCurrentUser() {
        User toReturn = [SELECT Id, FirstName, LastName, Contact.Id,
                                Contact.FirstName,Contact.MiddleName,Contact.LastName, 
                                Contact.Birthdate, Contact.Email, 
                                Contact.MCFD_Primary_Phone_Number_Type__c, Contact.Phone,
                                Contact.MCFD_Secondary_Phone_Number_Type__c, Contact.MobilePhone
                         FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return toReturn;
    }  
}