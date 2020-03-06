public class MCFD_PrimaryApplicantIncomeInformation {

    public static Contact conBasicInfo{get;set;}
    public static Id userID{get;set;} 
    public static User uinfo;
   
    //this method is called when Primary Applicant Income page is loaded to create a new income record.
    @AuraEnabled
    public static Income__c getIncomeId(){
    
        /*use below code once logging functionality is enabled. */
        userID = UserInfo.getUserId();
        uinfo = [select Contactid, FirstName,MiddleName, LastName from user where id =: userId  Limit 1];
        conBasicInfo = [select Id, FirstName, MiddleName, LastName, MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone  from Contact where id =:uinfo.contactid Limit 1];    
        
        List<Income__c> IncomeList = [select Id, MCFD_Band_Assistance__c, MCFD_Band_Assistance_Amount__c, MCFD_Band_Assistance_Freq__c, 
                                      MCFD_BC_Disability_Assistance__c, MCFD_BC_Disability_Assistance_Amount__c, MCFD_BC_Disability_Assistance_Freq__c, 
                                      MCFD_BC_Income_Assistance__c, MCFD_BC_Income_Assistance_Amount__c, MCFD_BC_Income_Assistance_Freq__c, Contact__c, 
                                      MCFD_Employment_Income__c, MCFD_Self_Employment_Income__c, MCFD_Federal_Benefits__c, MCFD_Federal_Benefits_Amount__c, 
                                      MCFD_Federal_Benefits_Freq__c, MCFD_Federal_Employment_Insurance__c, MCFD_Federal_Employment_Insurance_Amount__c, 
                                      MCFD_Federal_Employment_Insurance_Freq__c, MCFD_Federal_Employment_Insurance_Start__c, MCFD_Grants__c, MCFD_Grants_Amount__c, 
                                      MCFD_Grants_Freq__c, MCFD_Dep_Adult_Income__c, MCFD_Dep_Adult_Income_Amount__c, MCFD_Dep_Adult_Income_Freq__c, MCFD_Rental_Income__c, 
                                      MCFD_Rental_Income_Amount__c, MCFD_Rental_Income_Freq__c, MCFD_Interest_Amount__c, MCFD_Interest_Freq__c, MCFD_Interest__c, 
                                      MCFD_No_Income_Description__c, MCFD_Other_Income__c, MCFD_Other_Income_Amount__c, MCFD_Other_Income_Freq__c, MCFD_Related_Request__c, 
                                      MCFD_Spousal_Support__c, MCFD_Spousal_Support_Amount__c, MCFD_Spousal_Support_Freq__c, MCFD_Tips__c, MCFD_Tips_Amount__c, 
                                      MCFD_Tips_Freq__c, MCFD_Training_Living_Allowance__c, MCFD_Training_Living_Allowance_Amount__c, MCFD_Training_Living_Allowance_Freq__c, 
                                      MCFD_WorkSafeBC__c, MCFD_WorkSafeBC_Amount__c, MCFD_WorkSafeBC_Freq__c, MCFD_WorkSafeBC_Start__c
                                      from Income__c where Contact__c =: conBasicInfo.id  limit 1];
        Income__c newIncome;
        if(IncomeList.size()== 0)
        {
        newIncome = new Income__c();
        newIncome.Contact__c = conBasicInfo.id;
        insert(newIncome);
        }
        else
        newIncome = IncomeList[0];
        System.debug(newIncome);
        return newIncome;
        
    }
    
    // call this function when user clicks on 'Next' button on Primary Applicant Income Page
    @AuraEnabled
    public static void primaryApplicantIncomeSave(Income__c Inc){
        system.debug('In');
        update(Inc);
        
    }
    
    //this method is called when Spouse Income page is loaded to create a new income record.
    @AuraEnabled
    public static Income__c getSpouseIncomeId(){
    
        /*use below code once logging functionality is enabled. */
        userID = UserInfo.getUserId();
        uinfo = [select Contactid, FirstName,MiddleName, LastName from user where id =: userId  Limit 1];
        conBasicInfo = [select Id, FirstName, MiddleName, LastName, MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone  from Contact where id =:uinfo.contactid Limit 1];    
        MCFD_Relationship__C spouseRelt = [select id, MCFD_Child_Contact__c from MCFD_Relationship__C where MCFD_Relationship_Type__c='Spouse' AND MCFD_Parent_Contact__c =: uinfo.ContactId];
        List<Income__c> IncomeList = [select Id, MCFD_Band_Assistance__c, MCFD_Band_Assistance_Amount__c, MCFD_Band_Assistance_Freq__c, 
                                      MCFD_BC_Disability_Assistance__c, MCFD_BC_Disability_Assistance_Amount__c, MCFD_BC_Disability_Assistance_Freq__c, 
                                      MCFD_BC_Income_Assistance__c, MCFD_BC_Income_Assistance_Amount__c, MCFD_BC_Income_Assistance_Freq__c, Contact__c, 
                                      MCFD_Employment_Income__c, MCFD_Self_Employment_Income__c, MCFD_Federal_Benefits__c, MCFD_Federal_Benefits_Amount__c, 
                                      MCFD_Federal_Benefits_Freq__c, MCFD_Federal_Employment_Insurance__c, MCFD_Federal_Employment_Insurance_Amount__c, 
                                      MCFD_Federal_Employment_Insurance_Freq__c, MCFD_Federal_Employment_Insurance_Start__c, MCFD_Grants__c, MCFD_Grants_Amount__c, 
                                      MCFD_Grants_Freq__c, MCFD_Dep_Adult_Income__c, MCFD_Dep_Adult_Income_Amount__c, MCFD_Dep_Adult_Income_Freq__c, MCFD_Rental_Income__c, 
                                      MCFD_Rental_Income_Amount__c, MCFD_Rental_Income_Freq__c, MCFD_Interest_Amount__c, MCFD_Interest_Freq__c, MCFD_Interest__c, 
                                      MCFD_No_Income_Description__c, MCFD_Other_Income__c, MCFD_Other_Income_Amount__c, MCFD_Other_Income_Freq__c, MCFD_Related_Request__c, 
                                      MCFD_Spousal_Support__c, MCFD_Spousal_Support_Amount__c, MCFD_Spousal_Support_Freq__c, MCFD_Tips__c, MCFD_Tips_Amount__c, 
                                      MCFD_Tips_Freq__c, MCFD_Training_Living_Allowance__c, MCFD_Training_Living_Allowance_Amount__c, MCFD_Training_Living_Allowance_Freq__c, 
                                      MCFD_WorkSafeBC__c, MCFD_WorkSafeBC_Amount__c, MCFD_WorkSafeBC_Freq__c, MCFD_WorkSafeBC_Start__c
                                      from Income__c where Contact__c =:spouseRelt.MCFD_Child_Contact__c limit 1];
        Income__c newIncome;
        if(IncomeList.size()== 0)
        {
        newIncome = new Income__c();
        newIncome.Contact__c = spouseRelt.MCFD_Child_Contact__c;
        insert(newIncome);
        }
        else
        newIncome = IncomeList[0];
        System.debug(newIncome);
        return newIncome;
        
    }
    
    // call this function when user clicks on 'Next' button on Primary Applicant Income Page
    @AuraEnabled
    public static void SpouseIncomeSave(Income__c Inc){
    
        update(Inc);
        
    }
    

    

    
}