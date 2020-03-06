public class MCFD_PrimaryApplicantEmploymentIncome {

    public static Contact conBasicInfo{get;set;}
    public static Id userID{get;set;} 
    public static User uinfo;
   
    //this method is called when Primary Applicant Employment Income page is loaded to create a new income record.
    @AuraEnabled
    public static MCFD_Employment_Income__c getIncome(){
    
       // use below code once logging functionality is enabled.
        userID = UserInfo.getUserId();
        uinfo = [select Contactid, FirstName,MiddleName, LastName from user where id =: userId  Limit 1];
        conBasicInfo = [select Id, FirstName, MiddleName, LastName, MCFD_Gender__c, Birthdate, Email, MCFD_SIN__c, MCFD_Marital_Status__c,MCFD_Govt_Disability_Benefit__c, MCFD_Address_Check__c, MCFD_SIN_Expiry_Date__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c, MobilePhone,Phone  from Contact where id =:uinfo.contactid Limit 1];    
        
        List<Income__c> IncomeList = [select Id from Income__c where Contact__c =: conBasicInfo.id limit 1];
        
        
        List<MCFD_Employment_Income__c> EmpIncomeList = [select Id, MCFD_Amount_Pay_Stub_1__c, MCFD_Amount_Pay_Stub_2__c, MCFD_Employer_Name__c, MCFD_Hourly_Wage__c, Parent_Income_Id__c, 
                                                         MCFD_Non_Deduct_Amount_Pay_Stub_1__c, MCFD_Non_Deduct_Amount_Pay_Stub_2__c,
                                                         MCFD_Pay_Frequency__c from MCFD_Employment_Income__c
                                                         where Parent_Income_Id__c=: IncomeList[0].Id limit 1];
        
        
        MCFD_Employment_Income__c newEmpIncome;
        if(EmpIncomeList.size()== 0)
        {
        newEmpIncome = new MCFD_Employment_Income__c();
        newEmpIncome.Parent_Income_Id__c = IncomeList[0].Id;
        insert(newEmpIncome);
    	}
        else{
    	newEmpIncome = EmpIncomeList[0];
        System.debug(newEmpIncome);
        }
        return newEmpIncome;
    }
    
    // call this function when user clicks on 'Next' button on Primary Applicant Income Page
    @AuraEnabled
    public static void primaryApplicantEmpIncomeSave(List<MCFD_Employment_Income__c> Inc){
        
        system.debug(Inc);
        //PDAVE: Fixed code quality issue
        if(Inc != null && !Inc.isEmpty()  )
        {
        upsert Inc;
            /*For(integer i = 0; i<Inc.size(); i++)
        {
            upsert Inc[i];
        }*/
        }
    }
    


    
    
}