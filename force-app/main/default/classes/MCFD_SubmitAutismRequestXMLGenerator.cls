/*********************************************************************************************************
Name            : MCFD_SubmitAutismRequestXMLGenerator.cls  
Description     : This class is to generate XML for Autism Request  
Created By      : Deloitte
Created Date    : 10/May/2017
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Laura      10/May/2017   
--------------------------------------------------------------------------------------------------------------              
PDAVE      02/Aug/2017      US 515 - Adding error handling logic
PDAVE      27 SEP 2017      Added error handling logic (Reimbursement) as part of US 4589
--------------------------------------------------------------------------------------------------------------              

***************************************************************************************************************/

public with sharing class MCFD_SubmitAutismRequestXMLGenerator {
    public static String createRTPXML(Request__c request, List<Sub_Request__c> InterventionServices, List<Sub_Request__c> Travel,
                                        List<Sub_Request__c> Training, List<Sub_Request__c> EquipmentandSupplies, List<Sub_Sub_Request__c> TravelExpenses)
    {       
            //System.debug('In the MCFD_SubmitAutismRequestXMLGenerator');
            //define the sub sub type
            String SubSubType = request.MCFD_Service_Auth_Type__c;
            if (SubSubType == 'Travel, Training, Equipment, and Supplies'){
                SubSubType = 'Travel, Training, or Equipment';
                }
            else{
                SubSubType = 'Intervention';
                }
            //System.debug('The RTP type is '+SubSubType);

            //String EquipmentAmount = String.valueOf(equipTotal);
            //String TrainingAmount = String.valueOf(trainingTotal);
            //String TravelAmount = String.valueOf(travelTotal);



        
            //if the service provider type is blank, then it is an existing service provider
            Boolean ExistingProvider;
            //System.debug(request.MCFD_Service_Provider_Type__c);
            if (request.MCFD_Service_Provider_Type__c == '' || request.MCFD_Service_Provider_Type__c == null){
                ExistingProvider = true;
                }
            else{
                ExistingProvider = false;
                }

            //popoulate the memo with the required information
            String Memo;

            //System.debug(UserInfo.getUserId());
            
            Id requestCreatorUserId = request.CreatedById;
            String requestCreatetorName = request.CreatedBy.Name;
            
            //ASHAIKH - added code to update Memo with logged in user's info.
            List<User> ContactDetails = [select ContactId, Contact.LastName, Contact.FirstName, Contact.MiddleName, Contact.MCFD_Primary_Phone_Number_Type__c, 
                                        Contact.ICM_Cell_Phone__c, Contact.ICM_Home_Phone__c, Contact.ICM_Message_Phone__c, Contact.ICM_Work_Phone__c,
                                        Contact.MCFD_Secondary_Phone_Number_Type__c, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, 
                                        Contact.MailingState, Contact.MCFD_MAKID__c, Contact.MCFD_BCeID__c from user where id =:requestCreatorUserId limit 1];

            
           
        

            String PrimaryPhone = '';
            String SecondaryPhone = '';
            String AssignedTeam;
            if (ContactDetails.size() > 0)
            {
                System.debug(ContactDetails[0]);

                
                if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c != null)
                {   
                    if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Home'){
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Home_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Cell'){
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Cell_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Work'){
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Work_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Message Phone'){
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Message_Phone__c;}
                }

                if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c != null)
                {
                    if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Home'){
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Home_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Cell'){
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Cell_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Work'){
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Work_Phone__c;}

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Message Phone'){
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Message_Phone__c;}
                }

                //need to determine the assigned team based off of if an existing service provider was slected
                //if existing service provider and there was no address change. assignedteam= 'Adjudication' else = 'SPMG'
                

                //if there is an address value then there has been and address edit
                if (request.MCFD_Address_Update__c == 'No')
                {
                    AssignedTeam = 'SPMG';
                    if (ExistingProvider)
                        Memo = ContactDetails[0].Contact.LastName + ', '+ContactDetails[0].Contact.FirstName+', '+ContactDetails[0].Contact.MCFD_BCeID__c+'. Address Update';
                    else
                        Memo = ContactDetails[0].Contact.LastName + ', '+ContactDetails[0].Contact.FirstName+', '+ContactDetails[0].Contact.MCFD_BCeID__c+'. New Provider';
                }
                else
                {
                    AssignedTeam = 'Adjudication';
                    Memo = ContactDetails[0].Contact.LastName + ', '+ContactDetails[0].Contact.FirstName+', '+ContactDetails[0].Contact.MCFD_BCeID__c+'.';
                }
            }
            

            

            XmlStreamWriter w = new XmlStreamWriter();
            //document tag
            w.writeStartDocument(null,'1.0');
                w.writeStartElement(null,'Document',null);
                //header tag
                w.writeStartElement(null,'Header',null);
                    w.writeStartElement(null,'TransactionName',null);
                    w.writeCharacters('Autism Funding RTP Submit');
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedDate',null);
                    w.writeCharacters(String.valueOf(System.Today()));
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedBy',null);
                    w.writeCharacters(requestCreatetorName!=null?requestCreatetorName:'');
                    w.writeEndElement();
                //header end tag
                w.writeEndElement();
                //payload tag
                w.writeStartElement(null,'Payload',null);
                    w.writeStartElement(null,'Operation',null);
                    w.writeCharacters('Update');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRNumber',null);
                    w.writeCharacters(request.ICM_SR_Number__c!=null?request.ICM_SR_Number__c:'');
                    w.writeEndElement();
                    w.writeStartElement(null,'Status',null);
                    w.writeCharacters('Ready');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRType',null);
                    w.writeCharacters('Autism Funding Unit');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRSubType',null);
                    w.writeCharacters('Request to Pay');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRSubSubType',null);
                    w.writeCharacters(SubSubType!=null?SubSubType:'');
                    w.writeEndElement();
                    w.writeStartElement(null,'AssignedTeam',null);
                    w.writeCharacters(AssignedTeam!=null?AssignedTeam:'');
                    w.writeEndElement();
                    w.writeStartElement(null,'Memo',null);
                    w.writeCharacters(Memo!=null?Memo:'');
                    w.writeEndElement();
                    w.writeStartElement(null,'NewFundingPeriod',null);
                    w.writeCharacters(String.valueOf(request.MCFD_New_Funding_Period__c)!=null?String.valueOf(request.MCFD_New_Funding_Period__c):'false');
                    w.writeEndElement(); 
                    w.writeStartElement(null,'FundingPeriodStart',null);
                    w.writeCharacters(String.valueOf(request.MCFD_Funding_Period_Start_Date__c)!=null?String.valueOf(request.MCFD_Funding_Period_Start_Date__c):'');
                    w.writeEndElement(); 
                    w.writeStartElement(null,'FundingPeriodEnd',null);
                    w.writeCharacters(String.valueOf(request.MCFD_Funding_Period_End_Date__c)!=null?String.valueOf(request.MCFD_Funding_Period_End_Date__c):'');
                    w.writeEndElement(); 

                    if (ContactDetails.size() > 0)
                    {
                        //ParentGaurdian tag
                        w.writeStartElement(null,'ParentGuardian',null);  
                            w.writeStartElement(null,'ParentFirstName',null);
                            w.writeCharacters(ContactDetails[0].Contact.FirstName != null? ContactDetails[0].Contact.FirstName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ParentMiddleName',null);
                            w.writeCharacters(ContactDetails[0].Contact.MiddleName != null? ContactDetails[0].Contact.MiddleName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ParentLastName',null);
                            w.writeCharacters(ContactDetails[0].Contact.LastName != null? ContactDetails[0].Contact.LastName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantPrimaryPhoneNumber',null);
                            w.writeCharacters(PrimaryPhone!=null?PrimaryPhone:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantPrimaryPhoneNumberType',null);
                            w.writeCharacters(ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c != null? ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantSecondaryPhoneNumber',null);
                            w.writeCharacters(SecondaryPhone!=null?SecondaryPhone:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantSecondaryPhoneNumberType',null);
                            w.writeCharacters(ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c != null? ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c:'');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingApartment',null);
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingAddress1',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingStreet != null? ContactDetails[0].Contact.MailingStreet:'');
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingAddress2',null);
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingCity',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingCity != null? ContactDetails[0].Contact.MailingCity:'');
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingPostalCode',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingPostalCode != null? ContactDetails[0].Contact.MailingPostalCode:'');
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingProvince',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingState != null? ContactDetails[0].Contact.MailingState:'');
                            w.writeCharacters('');
                            w.writeEndElement(); 
                            w.writeStartElement(null,'ApplicantMailingMAKID',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MCFD_MAKID__c != null? ContactDetails[0].Contact.MCFD_MAKID__c:'');
                            w.writeCharacters('');
                            w.writeEndElement();   
                        //end ParentGaurdian tag 
                        w.writeEndElement();
                    }

                    //Child Tag
                    w.writeStartElement(null,'Child',null);  
                        w.writeStartElement(null,'ChildFirstName',null);
                        w.writeCharacters(request.MCFD_ChildFirstName__c!=null?request.MCFD_ChildFirstName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildMiddleName',null);
                        w.writeCharacters(request.MCFD_ChildMiddleName__c!=null?request.MCFD_ChildMiddleName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildLastName',null);
                        w.writeCharacters(request.MCFD_ChildLastName__c!=null?request.MCFD_ChildLastName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildDateOfBirth',null);
                        w.writeCharacters(request.MCFD_ChildBirthDate__c!=null?String.valueOf(request.MCFD_ChildBirthDate__c):'');
                        w.writeEndElement();
                    //end Child tag
                    w.writeEndElement();

                    //ServiceProvider tag
                    w.writeStartElement(null,'ServiceProvider',null);  
                        w.writeStartElement(null,'ExistingProvider',null);
                        w.writeCharacters(ExistingProvider?'true':'false');
                        w.writeEndElement();
                        w.writeStartElement(null,'RequestId',null);
                        w.writeCharacters(request.Id);
                        w.writeEndElement();
                        w.writeStartElement(null,'BusName',null);
                        w.writeCharacters(request.MCFD_Service_Provider_Name__c==null?'':request.MCFD_Service_Provider_Name__c);
                        w.writeEndElement();
                        w.writeStartElement(null,'IndOrBus',null);
                        w.writeCharacters(request.MCFD_Service_Provider_Type__c==null?'':request.MCFD_Service_Provider_Type__c);
                        w.writeEndElement();
                        w.writeStartElement(null,'FirstName',null);
                        w.writeCharacters(request.MCFD_First_Name__c==null?'':request.MCFD_First_Name__c);
                        w.writeEndElement();
                        w.writeStartElement(null,'MiddleName',null);
                        w.writeCharacters(request.MCFD_Middle_Name__c==null?'':request.MCFD_Middle_Name__c);
                        w.writeEndElement();
                        w.writeStartElement(null,'LastName',null);
                        w.writeCharacters(request.MCFD_Last_Name__c==null?'':request.MCFD_Last_Name__c);
                        w.writeEndElement();    
                        w.writeStartElement(null,'AddressEdit',null);
                        w.writeCharacters(request.MCFD_Address_Update__c=='No'?'true':'false');
                        w.writeEndElement();    
                        w.writeStartElement(null,'MailingAddress',null);
                        w.writeCharacters(request.MCFD_Street_Address__c!=null?request.MCFD_Street_Address__c: '');
                        w.writeEndElement();    
                        w.writeStartElement(null,'UnitNum',null);
                        w.writeCharacters(request.MCFD_Unit_Number__c!=null?request.MCFD_Unit_Number__c: '');
                        w.writeEndElement();    
                        w.writeStartElement(null,'City',null);
                        w.writeCharacters(request.MCFD_City__c!=null?request.MCFD_City__c: '');
                        w.writeEndElement();    
                        w.writeStartElement(null,'Province',null);
                        w.writeCharacters(request.MCFD_Region__c!=null?request.MCFD_Region__c: '');
                        w.writeEndElement();    
                        w.writeStartElement(null,'PostalCode',null);
                        w.writeCharacters(request.MCFD_Postal_Code__c!=null?request.MCFD_Postal_Code__c: '');
                        w.writeEndElement(); 
                        w.writeStartElement(null,'Country',null);
                        w.writeCharacters(request.MCFD_Country__c!=null?request.MCFD_Country__c: '');
                        w.writeEndElement(); 
                        w.writeStartElement(null,'Phone',null);
                        w.writeCharacters(request.MCFD_Phone__c!=null?request.MCFD_Phone__c: '');
                        w.writeEndElement();   
                        w.writeStartElement(null,'ServiceType',null);
                        w.writeCharacters(request.MCFD_Service_Auth_Type__c==null?'':request.MCFD_Service_Auth_Type__c);
                        w.writeEndElement();   
                        w.writeStartElement(null,'ServiceInCanada',null);
                        w.writeCharacters(request.MCFD_In_Canada__c?'true':'false');
                        w.writeEndElement();   
                        w.writeStartElement(null,'USAserviceDesc',null);
                        w.writeCharacters(request.MCFD_USA_Services_Detail__c==null?'':request.MCFD_USA_Services_Detail__c);
                        w.writeEndElement(); 

                        w.writeStartElement(null,'CASVendorID',null);
                        w.writeCharacters(request.MCFD_CAS_Vendor__c==null?'':request.MCFD_CAS_Vendor__c);
                        w.writeEndElement();   
                        w.writeStartElement(null,'CASSiteID',null);
                        w.writeCharacters(request.MCFD_CAS_Site__c==null?'':request.MCFD_CAS_Site__c);
                        w.writeEndElement();   
                    //end ServiceProvider tag 
                    w.writeEndElement();
                    
                    //InterventionService tag 
                    w.writeStartElement(null,'InterventionService',null);
                        w.writeStartElement(null,'StartDate',null);
                        w.writeCharacters(request.MCFD_Start_Date__c==null?'':request.MCFD_Start_Date__c!=null?String.valueOf(request.MCFD_Start_Date__c):'');
                        w.writeEndElement();
                        w.writeStartElement(null,'EndDate',null);
                        w.writeCharacters(SubSubType!='Intervention'?'':request.MCFD_End_Date__c!=null?String.valueOf(request.MCFD_End_Date__c):'');
                        w.writeEndElement();
                        w.writeStartElement(null,'TotalAmount',null);
                        w.writeCharacters(SubSubType!='Intervention'?'0':request.MCFD_Total_Amount__c!=null?('$'+String.valueOf(request.MCFD_Total_Amount__c)):'');
                        w.writeEndElement();

                        w.writeStartElement(null,'ServicesList',null);
                        if(InterventionServices.size() > 0)
                        {
                            for(Sub_Request__c intService : InterventionServices)
                            {   
                                //Services tag
                                w.writeStartElement(null,'Services',null);
                                    w.writeStartElement(null,'RASP',null);w.writeCharacters(intService.MCFD_RASP__c==null?'':intService.MCFD_RASP__c);w.writeEndElement();
                                    w.writeStartElement(null,'Rate',null);w.writeCharacters(intService.MCFD_Rate__c==null?'':'$'+String.valueOf(intService.MCFD_Rate__c));w.writeEndElement();
                                    w.writeStartElement(null,'RateUnit',null);w.writeCharacters(intService.MCFD_Rate_Unit__c==null?'':intService.MCFD_Rate_Unit__c);w.writeEndElement();
                                    w.writeStartElement(null,'ServiceDecs',null);w.writeCharacters(intService.MCFD_Service_Description__c==null?'':intService.MCFD_Service_Description__c);w.writeEndElement();
                                    w.writeStartElement(null,'ServiceType',null);w.writeCharacters(intService.MCFD_Service_Type__c==null?'':intService.MCFD_Service_Type__c);w.writeEndElement();
                                //Services end tag
                                w.writeEndElement();
                            }    
                        }
                        else
                        {
                            w.writeStartElement(null,'Services',null);
                                w.writeStartElement(null,'RASP',null);w.writeCharacters('');w.writeEndElement();
                                w.writeStartElement(null,'Rate',null);w.writeCharacters('');w.writeEndElement();
                                w.writeStartElement(null,'RateUnit',null);w.writeCharacters('');w.writeEndElement();
                                w.writeStartElement(null,'ServiceDecs',null);w.writeCharacters('');w.writeEndElement();
                                w.writeStartElement(null,'ServiceType',null);w.writeCharacters('');w.writeEndElement();
                            //Services end tag
                            w.writeEndElement();  
                        }
                        //ServicesList end tag
                        w.writeEndElement();
                    //InterventionService end tag
                    w.writeEndElement();
                    

                    //need to populate details for a TTE RTP
                    //PartB tag

                    w.writeStartElement(null,'PartB',null);  

                        w.writeStartElement(null,'EquipmentandSuppliesSubTotal',null);
                        w.writeCharacters(request.MCFD_Equipment_Sub_Total__c!=null?'$'+String.valueOf(request.MCFD_Equipment_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'TravelSubTotal',null);
                        w.writeCharacters(request.MCFD_Travel_Sub_Total__c!=null?'$'+String.valueOf(request.MCFD_Travel_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'TrainingSubTotal',null);
                        w.writeCharacters(request.MCFD_Training_Sub_Total__c!=null?'$'+String.valueOf(request.MCFD_Training_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'TTETotalAmount',null);
                        w.writeCharacters(SubSubType!='Intervention'?'$'+String.valueOf(request.MCFD_Total_Amount__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'IAgreeThat',null);
                        w.writeCharacters(SubSubType!='Intervention'?'true':'');
                        w.writeEndElement();

                        //EquipmentandSuppliesList tag
                         w.writeStartElement(null,'EquipmentandSuppliesList',null);
                        if(EquipmentandSupplies.size() > 0)
                        {
                            for(Sub_Request__c equip: EquipmentandSupplies)
                            {
                                //EquipmentandSuppliesList tag
                                w.writeStartElement(null,'EquipmentandSupplies',null);
                                    w.writeStartElement(null,'RetailContact',null);
                                    w.writeCharacters(equip.MCFD_Contact__c!=null?equip.MCFD_Contact__c:'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'DateofPurchase',null);
                                    w.writeCharacters(equip.MCFD_Start_Date__c!=null?String.valueOf(equip.MCFD_Start_Date__c):'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'DescriptionofItem',null);
                                    w.writeCharacters(equip.MCFD_Service_Description__c!=null?equip.MCFD_Service_Description__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'CostofItem',null);
                                    w.writeCharacters(equip.MCFD_Rate__c!=null?'$'+String.valueOf(equip.MCFD_Rate__c):'');
                                    w.writeEndElement();
                                //EquipmentandSupplies End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            //EquipmentandSuppliesList tag
                            w.writeStartElement(null,'EquipmentandSupplies',null);
                                w.writeStartElement(null,'RetailContact',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'DateofPurchase',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'DescriptionofItem',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'CostofItem',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                            //EquipmentandSupplies End tag
                            w.writeEndElement(); 
                        }
                        //EquipmentandSuppliesList end tag
                        w.writeEndElement();

                        //TravelList tag
                         w.writeStartElement(null,'TravelList',null);
                        if(Travel.size() > 0)
                        {
                            for(Sub_Request__c item: Travel)
                            {
                                //Travel tag
                                w.writeStartElement(null,'Travel',null);
                                    w.writeStartElement(null,'ReasonForTravel',null);
                                    w.writeCharacters(item.MCFD_Reasons_For_Travel__c!=null?item.MCFD_Reasons_For_Travel__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'StartDate',null);
                                    w.writeCharacters(item.MCFD_Start_Date__c!=null?String.valueOf(item.MCFD_Start_Date__c): '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'EndDate',null);
                                    w.writeCharacters(item.MCFD_End_Date__c!=null?String.valueOf(item.MCFD_End_Date__c): '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'NameofTravelers',null);
                                    w.writeCharacters(item.MCFD_Name_Of_Travelers__c!=null?item.MCFD_Name_Of_Travelers__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'ToLocation',null);
                                    w.writeCharacters(item.MCFD_To_Location__c!=null?item.MCFD_To_Location__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'FromLocation',null);
                                    w.writeCharacters(item.MCFD_From_Location__c!=null?item.MCFD_From_Location__c: '');
                                    w.writeEndElement();

                                    //TravelExepenseList tag
                                    w.writeStartElement(null,'TravelExpenseList',null);
                                    if(TravelExpenses.size() > 0)
                                    {
                                        for(Sub_Sub_Request__c expense: TravelExpenses)
                                        {
                                            //Only add the travel expenses for the correct travel
                                            if (expense.Sub_Request__c == item.Id)
                                            {
                                                //EquipmentandSuppliesList tag
                                                w.writeStartElement(null,'TravelExpense',null);
                                                    w.writeStartElement(null,'DescriptionofExpense',null);
                                                    w.writeCharacters(expense.MCFD_Service_Description__c!=null?expense.MCFD_Service_Description__c: '');
                                                    w.writeEndElement();
                                                    w.writeStartElement(null,'CostofItem',null);
                                                    w.writeCharacters(expense.MCFD_Rate__c!=null?'$'+String.valueOf(expense.MCFD_Rate__c):'');
                                                    w.writeEndElement();
                                                //TravelExpense end tag
                                                w.writeEndElement();
                                            }   
                                        }
                                    }

                                    //TravelExpenseList end tag
                                    w.writeEndElement();

                                //Travel End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            w.writeStartElement(null,'Travel',null);
                                w.writeStartElement(null,'ReasonForTravel',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'StartDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'EndDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'NameofTravelers',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'ToLocation',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'FromLocation',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'TravelExpenseList',null);
                                    w.writeStartElement(null,'TravelExpense',null);
                                        w.writeStartElement(null,'DescriptionofExpense',null);
                                        w.writeCharacters('');
                                        w.writeEndElement();
                                        w.writeStartElement(null,'CostofItem',null);
                                        w.writeCharacters('');
                                        w.writeEndElement();
                                    //TravelExpense end tag
                                    w.writeEndElement();
                                //TravelExpenseList end tag
                                w.writeEndElement();
                            //Travel End tag
                            w.writeEndElement();
                        }
                        //TravelList end tag
                        w.writeEndElement();

                        //TrainingList tag
                         w.writeStartElement(null,'TrainingList',null);
                        if(Training.size() > 0)
                        {
                            for(Sub_Request__c item: Training)
                            {
                                //Training tag
                                w.writeStartElement(null,'Training',null);
                                    w.writeStartElement(null,'NameofPersonReceivingTraining',null);
                                    w.writeCharacters(request.MCFD_Receiving_Training__c!=null?request.MCFD_Receiving_Training__c:'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'NameTypeofTraining',null);
                                    w.writeCharacters(item.MCFD_Service_Description__c!=null?item.MCFD_Service_Description__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'StartDate',null);
                                    w.writeCharacters(item.MCFD_Start_Date__c!=null?String.valueOf(item.MCFD_Start_Date__c):'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'EndDate',null);
                                    w.writeCharacters(item.MCFD_End_Date__c!=null?String.valueOf(item.MCFD_End_Date__c):'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'CostofExpense',null);
                                    w.writeCharacters(item.MCFD_Rate__c!=null?'$'+String.valueOf(item.MCFD_Rate__c):'');
                                    w.writeEndElement();
                                //Training End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            //Training tag
                            w.writeStartElement(null,'Training',null);
                                w.writeStartElement(null,'NameofPersonReceivingTraining',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'NameTypeofTraining',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'StartDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'EndDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'CostofExpense',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                            //Training End tag
                            w.writeEndElement();
                        }
                        //TrainingList end tag
                        w.writeEndElement();


                    //PartB end tag
                    w.writeEndElement();
                    

                //payload end tag
                w.writeEndElement();
            //document end tag
            w.writeEndElement();
            string xml = w.getXmlString();
            w.close();
            return xml;
        
    }
    
    @AuraEnabled
    public static String SubmitRTP(Request__c sRequest, List<Sub_Request__c> InterventionServices, List<Sub_Request__c> Travel,
                                        List<Sub_Request__c> Training, List<Sub_Request__c> EquipmentandSupplies, List<Sub_Sub_Request__c> TravelExpenses) 
    {
        System.debug('In the MCFD_SubmitRTP on XML class');
     if(sRequest != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMToSubmitRTP');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(Integer.valueOf(System.Label.Timeout_RTP_Submission));
            //req.setTimeout(60000);
              
            String xmlString = MCFD_SubmitAutismRequestXMLGenerator.createRTPXML(sRequest, InterventionServices, Travel, Training, EquipmentandSupplies, TravelExpenses); 
            System.debug(xmlString);

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('UpdateRequest', xmlString);
            gen.writeEndObject();
            req.setBody(gen.getAsString());

            //req.setBody(xmlString);
                    
            System.debug('>>>> req.getBody(): ' + req.getBody()); 
            System.debug('>>>> req: ' + req); 
            Http http = new Http();
            String returnJSON = '';
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                System.debug('>>>> Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                System.debug('>>>> returnJSON:'+ returnJSON);
                if(res.getStatusCode()==200)
                 {  
                    String responseBody;
                    if(System.Label.ICM_Dummy_Error_Response_Mode_RTP_Submission.toUpperCase() == 'ON'){
                        responseBody = System.Label.ICM_Dummy_Error_Response;
                    }else{
                        responseBody = res.getBody();
                    }
                    
                    Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    system.debug('ICM_Response-->'+ICM_Response);
                    
                    // ----------------------------------------------- //
                    // ------- Handle error response (if any) -------- //
                    // ----------------------------------------------- //
                    if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
                        String strErrorStatus;
                        String strErrorMsg;
                    
                        List<Object> errorDetailsList = (List<Object>)ICM_Response.get(System.Label.ICM_Error_Response_Parent_Tag);
                        system.debug('errorDetail-->'+errorDetailsList[0]);
                        Map<String, Object> errorDetail = (Map<String, Object>)errorDetailsList[0];
                        if(errorDetail.containsKey(System.Label.ICM_Error_Response_Error_Message_Tag)){
                            strErrorMsg = (String)errorDetail.get(System.Label.ICM_Error_Response_Error_Message_Tag);        
                        }
                         if(errorDetail.containsKey(System.Label.ICM_Error_Response_Status_Tag)){
                            strErrorStatus = (String)errorDetail.get(System.Label.ICM_Error_Response_Status_Tag);        
                        }
                        system.debug('strErrorStatus=' + strErrorStatus);
                        system.debug('strErrorMsg=' + strErrorMsg);
                        system.debug('sRequest.RecordType.Name =' + sRequest.RecordType.Name );
                        
                        if(sRequest.RecordType.Name == 'RTP'){
                            MCFD_Logger.log_integ_err_for_request('Submission - RTP Intervention', 
                                                               MCFD_Logger.error, 
                                                               'MCFD_SubmitAutismRequestXMLGenerator', 
                                                               'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                               sRequest.Id);
                        }else if(sRequest.RecordType.Name == 'RTP - Travel, Training, and Equipment'){
                            MCFD_Logger.log_integ_err_for_request('Submission - RTP TTE', 
                                                               MCFD_Logger.error, 
                                                               'MCFD_SubmitAutismRequestXMLGenerator', 
                                                               'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                               sRequest.Id);
                        }
                        
                        
                        sRequest.MCFD_Status__c='Submission Error'; 
                        update sRequest;
                    }else{
                    // ----------------------------------------------- //
                    // ------- Handle success response --------------- //
                    // ----------------------------------------------- //
                        sRequest.MCFD_Status__c='Submitted'; 
                        update sRequest;
                    }
                   
                }
            } 
            catch(System.CalloutException e) {
                system.debug('Came to Exception');
                sRequest.MCFD_Status__c='Submission Error'; 
                update sRequest;
                if(System.isBatch() == true){
                    // If exception occurs during retry batch, throwing manual exception and it will be handled in the same batch itself
                    throw new RTP_Submission_Exception('Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
                }else{
					if(sRequest.RecordType.Name == 'RTP'){
						MCFD_Logger.log_integ_err_for_request('Submission - RTP Intervention', 
                                                           MCFD_Logger.error, 
                                                           'MCFD_SubmitAutismRequestXMLGenerator', 
                                                           'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                           sRequest.Id);
														   
					}else if(sRequest.RecordType.Name == 'RTP - Travel, Training, and Equipment'){
						MCFD_Logger.log_integ_err_for_request('Submission - RTP TTE', 
                                                           MCFD_Logger.error, 
                                                           'MCFD_SubmitAutismRequestXMLGenerator', 
                                                           'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                           sRequest.Id);														   
					}
						
                }
            }     
            return xmlString;
        }
        return ''; 
        
    }


    public static String createReimbursementXML(Request__c request, List<Sub_Request__c> Travel, List<Sub_Request__c> Equipment, List<Sub_Request__c> Training, 
                                                List<Sub_Sub_Request__c> EquipmentExpenses, List<Sub_Sub_Request__c> TravelExpenses, List<Sub_Request__c> EmployerExp)
    {       
            
            Id requestCreatorUserId = request.CreatedById;
            String requestCreatetorName = request.CreatedBy.Name;
            
            //popoulate the memo with the required information
            List<User> ContactDetails = [select ContactId, Contact.LastName, Contact.FirstName, Contact.MiddleName, Contact.MCFD_Primary_Phone_Number_Type__c, 
                                        Contact.ICM_Cell_Phone__c, Contact.ICM_Home_Phone__c, Contact.ICM_Message_Phone__c, Contact.ICM_Work_Phone__c,
                                        Contact.MCFD_Secondary_Phone_Number_Type__c, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, 
                                        Contact.MailingState, Contact.MCFD_MAKID__c, Contact.MCFD_BCeID__c from user where id =:requestCreatorUserId limit 1];

            String PrimaryPhone = '';
            String SecondaryPhone = '';
            String Memo = '';
            if (ContactDetails.size() > 0)
            {
                if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c != null)
                {   
                    if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Home')
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Home_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Cell')
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Cell_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Work')
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Work_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c == 'Message Phone')
                        PrimaryPhone = ContactDetails[0].Contact.ICM_Message_Phone__c;
                }

                if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c != null)
                {
                    if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Home')
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Home_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Cell')
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Cell_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Work')
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Work_Phone__c;

                    else if (ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c == 'Message Phone')
                        SecondaryPhone = ContactDetails[0].Contact.ICM_Message_Phone__c;
                }
                Memo = ContactDetails[0].Contact.LastName + ', '+ContactDetails[0].Contact.FirstName+', '+ContactDetails[0].Contact.MCFD_BCeID__c+'.';

            }
            

            

            

            XmlStreamWriter w = new XmlStreamWriter();
            //document tag
            w.writeStartDocument(null,'1.0');
                w.writeStartElement(null,'Document',null);
                //header tag
                w.writeStartElement(null,'Header',null);
                    w.writeStartElement(null,'TransactionName',null);
                    w.writeCharacters('Autism Funding RTP Submit');
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedDate',null);
                    w.writeCharacters(String.valueOf(System.Today()));
                    w.writeEndElement();
                    w.writeStartElement(null,'CreatedBy',null);
                    w.writeCharacters(requestCreatetorName!=null?requestCreatetorName:'');
                    w.writeEndElement();
                //header end tag
                w.writeEndElement();
                //payload tag
                w.writeStartElement(null,'Payload',null);
                    w.writeStartElement(null,'Operation',null);
                    w.writeCharacters('Update');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRNumber',null);
                    w.writeCharacters(request.ICM_SR_Number__c!=null?request.ICM_SR_Number__c:'');
                    w.writeEndElement();
                    w.writeStartElement(null,'Status',null);
                    w.writeCharacters('Ready');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRType',null);
                    w.writeCharacters('Autism Funding Unit');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRSubType',null);
                    w.writeCharacters('Reimbursement');
                    w.writeEndElement();
                    w.writeStartElement(null,'SRSubSubType',null);
                    w.writeCharacters('');
                    w.writeEndElement();
                    w.writeStartElement(null,'AssignedTeam',null);
                    w.writeCharacters('SPMG');
                    w.writeEndElement();
                    w.writeStartElement(null,'Memo',null);
                    w.writeCharacters(Memo!=null?Memo:'');
                    w.writeEndElement();
                    
                    if (ContactDetails.size() > 0)
                    {
                        //ParentGaurdian tag
                        w.writeStartElement(null,'ParentGuardian',null);  
                            w.writeStartElement(null,'ParentFirstName',null);
                            w.writeCharacters(ContactDetails[0].Contact.FirstName != null? ContactDetails[0].Contact.FirstName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ParentMiddleName',null);
                            w.writeCharacters(ContactDetails[0].Contact.MiddleName != null? ContactDetails[0].Contact.MiddleName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ParentLastName',null);
                            w.writeCharacters(ContactDetails[0].Contact.LastName != null? ContactDetails[0].Contact.LastName:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantPrimaryPhoneNumber',null);
                            w.writeCharacters(PrimaryPhone!=null?PrimaryPhone:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantPrimaryPhoneNumberType',null);
                            w.writeCharacters(ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c != null? ContactDetails[0].Contact.MCFD_Primary_Phone_Number_Type__c:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantSecondaryPhoneNumber',null);
                            w.writeCharacters(SecondaryPhone!=null?SecondaryPhone:'');
                            w.writeEndElement();
                            w.writeStartElement(null,'ApplicantSecondaryPhoneNumberType',null);
                            w.writeCharacters(ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c != null? ContactDetails[0].Contact.MCFD_Secondary_Phone_Number_Type__c:'');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingApartment',null);
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingAddress1',null);
                            w.writeCharacters('');
                            //w.writeCharacters(ContactDetails[0].Contact.MailingStreet != null? ContactDetails[0].Contact.MailingStreet:'');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingAddress2',null);
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingCity',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingCity != null? ContactDetails[0].Contact.MailingCity:'');
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingPostalCode',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingPostalCode != null? ContactDetails[0].Contact.MailingPostalCode:'');
                            w.writeCharacters('');
                            w.writeEndElement();    
                            w.writeStartElement(null,'ApplicantMailingProvince',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MailingState != null? ContactDetails[0].Contact.MailingState:'');
                            w.writeCharacters('');
                            w.writeEndElement(); 
                            w.writeStartElement(null,'ApplicantMailingMAKID',null);
                            //w.writeCharacters(ContactDetails[0].Contact.MCFD_MAKID__c != null? ContactDetails[0].Contact.MCFD_MAKID__c:'');
                            w.writeCharacters('');
                            w.writeEndElement();   
                        //end ParentGaurdian tag 
                        w.writeEndElement();
                    }

                    //Child Tag
                    w.writeStartElement(null,'Child',null);  
                        w.writeStartElement(null,'ChildFirstName',null);
                        w.writeCharacters(request.MCFD_ChildFirstName__c!=null?request.MCFD_ChildFirstName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildMiddleName',null);
                        w.writeCharacters(request.MCFD_ChildMiddleName__c!=null?request.MCFD_ChildMiddleName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildLastName',null);
                        w.writeCharacters(request.MCFD_ChildLastName__c!=null?request.MCFD_ChildLastName__c:'');
                        w.writeEndElement();
                        w.writeStartElement(null,'ChildDateOfBirth',null);
                        w.writeCharacters(request.MCFD_ChildBirthDate__c!=null?String.valueOf(request.MCFD_ChildBirthDate__c):'');
                        w.writeEndElement();
                    //end Child tag
                    w.writeEndElement();
                    

                    //Reimbursment Details
                    w.writeStartElement(null,'ListofReimbursement',null);  

                        w.writeStartElement(null,'EquipmentandSuppliesSubTotal',null);
                        w.writeCharacters(request.MCFD_Equipment_Sub_Total__c!=null?String.valueOf(request.MCFD_Equipment_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'TravelSubTotal',null);
                        w.writeCharacters(request.MCFD_Travel_Sub_Total__c!=null?String.valueOf(request.MCFD_Travel_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'TrainingSubTotal',null);
                        w.writeCharacters(request.MCFD_Training_Sub_Total__c!=null?String.valueOf(request.MCFD_Training_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'EmployerCostsSubTotal',null);
                        w.writeCharacters(request.MCFD_Employer_Costs_Sub_Total__c!=null?String.valueOf(request.MCFD_Employer_Costs_Sub_Total__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'Total',null);
                        w.writeCharacters(request.MCFD_Total_Amount__c!=null?String.valueOf(request.MCFD_Total_Amount__c):'0');
                        w.writeEndElement();
                        w.writeStartElement(null,'IAgreeThat',null);
                        w.writeCharacters('true');
                        w.writeEndElement();

                        
                        //TravelList tag
                         w.writeStartElement(null,'EquipmentandSuppliesList',null);
                        if(Equipment.size() > 0)
                        {
                            for(Sub_Request__c item: Equipment)
                            {

                                    if(EquipmentExpenses.size() > 0)
                                    {
                                        for(Sub_Sub_Request__c expense: EquipmentExpenses)
                                        {
                                            //Only add the receipt items for the correct receipt
                                            if (expense.Sub_Request__c == item.Id)
                                            {
                                                //EquipmentandSuppliesList tag
                                                w.writeStartElement(null,'EquipmentandSupplies',null);
                                                    w.writeStartElement(null,'NameofRetailer',null);
                                                    w.writeCharacters(item.MCFD_Service_Provider_Name__c!=null?item.MCFD_Service_Provider_Name__c: '');
                                                    w.writeEndElement();
                                                    w.writeStartElement(null,'PurchaseDate',null);
                                                    w.writeCharacters(item.MCFD_Start_Date__c!=null?String.valueOf(item.MCFD_Start_Date__c): '');
                                                    w.writeEndElement();
                                                    w.writeStartElement(null,'DescriptionofExpense',null);
                                                    w.writeCharacters(expense.MCFD_Service_Description__c!=null?expense.MCFD_Service_Description__c: '');
                                                    w.writeEndElement();
                                                    w.writeStartElement(null,'CostofItem',null);
                                                    w.writeCharacters(expense.MCFD_Rate__c!=null?String.valueOf(expense.MCFD_Rate__c):'0');
                                                	w.writeEndElement();
                                                //EquipmentandSupplies end tag
                                                w.writeEndElement();
                                            }   
                                        }
                                    }
                            }
                        }
                        else
                        {
                            //EquipmentandSuppliesList tag
                            w.writeStartElement(null,'EquipmentandSupplies',null);
                                w.writeStartElement(null,'NameofRetailer',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'PurchaseDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'DescriptionofExpense',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'CostofItem',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                            //EquipmentandSupplies end tag
                            w.writeEndElement();
                        }
                        //EquipmentandSuppliesList end tag
                        w.writeEndElement();

                        //TravelList tag
                         w.writeStartElement(null,'TravelList',null);
                        if(Travel.size() > 0)
                        {
                            for(Sub_Request__c item: Travel)
                            {
                                //Travel tag
                                w.writeStartElement(null,'Travel',null);
                                    w.writeStartElement(null,'ReasonForTravel',null);
                                    w.writeCharacters(item.MCFD_Reasons_For_Travel__c!=null?item.MCFD_Reasons_For_Travel__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'StartDate',null);
                                    w.writeCharacters(item.MCFD_Start_Date__c!=null?String.valueOf(item.MCFD_Start_Date__c): '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'EndDate',null);
                                    w.writeCharacters(item.MCFD_End_Date__c!=null?String.valueOf(item.MCFD_End_Date__c): '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'NameofTravelers',null);
                                    w.writeCharacters(item.MCFD_Name_Of_Travelers__c!=null?item.MCFD_Name_Of_Travelers__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'ToLocation',null);
                                    w.writeCharacters(item.MCFD_To_Location__c!=null?item.MCFD_To_Location__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'FromLocation',null);
                                    w.writeCharacters(item.MCFD_From_Location__c!=null?item.MCFD_From_Location__c: '');
                                    w.writeEndElement();

                                    //TravelExepenseList tag
                                    w.writeStartElement(null,'TravelExpenseList',null);
                                    if(TravelExpenses.size() > 0)
                                    {
                                        for(Sub_Sub_Request__c expense: TravelExpenses)
                                        {
                                            //Only add the travel expenses for the correct travel
                                            if (expense.Sub_Request__c == item.Id)
                                            {
                                                //EquipmentandSuppliesList tag
                                                w.writeStartElement(null,'TravelExpense',null);
                                                    w.writeStartElement(null,'DescriptionofExpense',null);
                                                    w.writeCharacters(expense.MCFD_Service_Description__c!=null?expense.MCFD_Service_Description__c: '');
                                                    w.writeEndElement();
                                                    w.writeStartElement(null,'CostofItem',null);
                                                    w.writeCharacters(expense.MCFD_Rate__c!=null?String.valueOf(expense.MCFD_Rate__c):'0');
                                                    w.writeEndElement();
                                                //TravelExpense end tag
                                                w.writeEndElement();
                                            }   
                                        }
                                    }

                                    //TravelExpenseList end tag
                                    w.writeEndElement();

                                //Travel End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            //Travel tag
                            w.writeStartElement(null,'Travel',null);
                                w.writeStartElement(null,'ReasonForTravel',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'StartDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'EndDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'NameofTravelers',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'ToLocation',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'FromLocation',null);
                                w.writeCharacters('');
                                w.writeEndElement();

                                //TravelExepenseList tag
                                w.writeStartElement(null,'TravelExpenseList',null);
                                //TravelExpense tag
                                    w.writeStartElement(null,'TravelExpense',null);
                                        w.writeStartElement(null,'DescriptionofExpense',null);
                                        w.writeCharacters('');
                                        w.writeEndElement();
                                        w.writeStartElement(null,'CostofItem',null);
                                        w.writeCharacters('');
                                        w.writeEndElement();
                                    //TravelExpense end tag
                                    w.writeEndElement();
                                //TravelExpenseList end tag
                                w.writeEndElement();

                            //Travel End tag
                            w.writeEndElement();
                        }
                        //TravelList end tag
                        w.writeEndElement();

                        //TrainingList tag
                         w.writeStartElement(null,'TrainingList',null);
                        if(Training.size() > 0)
                        {
                            for(Sub_Request__c item: Training)
                            {
                                //Training tag
                                w.writeStartElement(null,'Training',null);
                                    w.writeStartElement(null,'NameofPersonReceivingTraining',null);
                                    w.writeCharacters(request.MCFD_Receiving_Training__c!=null?request.MCFD_Receiving_Training__c:'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'NameTypeofTraining',null);
                                    w.writeCharacters(item.MCFD_Service_Description__c!=null?item.MCFD_Service_Description__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'StartDate',null);
                                    w.writeCharacters(item.MCFD_Start_Date__c!=null?String.valueOf(item.MCFD_Start_Date__c):'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'EndDate',null);
                                    w.writeCharacters(item.MCFD_End_Date__c!=null?String.valueOf(item.MCFD_End_Date__c):'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'CostofExpense',null);
                                    w.writeCharacters(item.MCFD_Rate__c!=null?String.valueOf(item.MCFD_Rate__c):'0');
                                    w.writeEndElement();
                                //Training End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            //Training tag
                            w.writeStartElement(null,'Training',null);
                                w.writeStartElement(null,'NameofPersonReceivingTraining',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'NameTypeofTraining',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'StartDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'EndDate',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'CostofExpense',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                            //Training End tag
                            w.writeEndElement();
                        }
                        //EquipmentandSuppliesList end tag
                        w.writeEndElement();

                        //EmployerExp tag
                         w.writeStartElement(null,'EmployerCostList',null);
                        if(EmployerExp.size() > 0)
                        {
                            for(Sub_Request__c item: EmployerExp)
                            {
                                //Employers Costs
                                w.writeStartElement(null,'EmployerCost',null);
                                    w.writeStartElement(null,'NameofEmployee',null);
                                    w.writeCharacters(request.MCFD_Employee_Name__c!=null?request.MCFD_Employee_Name__c:'');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'TypeOfExpense',null);
                                    w.writeCharacters(item.MCFD_Service_Description__c!=null?item.MCFD_Service_Description__c: '');
                                    w.writeEndElement();
                                    w.writeStartElement(null,'CostofExpense',null);
                                    w.writeCharacters(item.MCFD_Rate__c!=null?String.valueOf(item.MCFD_Rate__c):'0');
                                    w.writeEndElement();
                                //Employer Costs End tag
                                w.writeEndElement();
                                   
                            }
                        }
                        else
                        {
                            w.writeStartElement(null,'EmployerCost',null);
                                w.writeStartElement(null,'NameofEmployee',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'TypeOfExpense',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                                w.writeStartElement(null,'CostofExpense',null);
                                w.writeCharacters('');
                                w.writeEndElement();
                            //Employer Costs End tag
                            w.writeEndElement();
                        }
                        //EquipmentandSuppliesList end tag
                        w.writeEndElement();


                    //ListofReimbursement end tag
                    w.writeEndElement();
                    

                //payload end tag
                w.writeEndElement();
            //document end tag
            w.writeEndElement();
            string xml = w.getXmlString();
            w.close();
            return xml;
        
    }
    
    // PDAVE : Added error handling logic (Reimbursement) as part of US 4589
    @AuraEnabled
    public static String SubmitReimbursement(Request__c request, List<Sub_Request__c> Travel, List<Sub_Request__c> Equipment, List<Sub_Request__c> Training, 
                                                List<Sub_Sub_Request__c> EquipmentExpenses, List<Sub_Sub_Request__c> TravelExpenses, List<Sub_Request__c> EmployerExp) 
    {
        System.debug('In the MCFD_SubmitRTP on XML class');
     if(request != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMToSubmitRTP');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(Integer.valueOf(System.Label.Timeout_Reimbursement_Submission));
              
            String xmlString = MCFD_SubmitAutismRequestXMLGenerator.createReimbursementXML(request, Travel, Equipment, Training, EquipmentExpenses,TravelExpenses, EmployerExp); 
            System.debug(xmlString);

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('UpdateRequest', xmlString);
            gen.writeEndObject();
            req.setBody(gen.getAsString());

            //req.setBody(xmlString);
                    
            System.debug('>>>> req.getBody(): ' + req.getBody()); 
            System.debug('>>>> req: ' + req); 
            Http http = new Http();
            String returnJSON = '';
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                System.debug('>>>> Response'+ res.toString());
                System.debug('>>>> Status:'+ res.getStatus());
                System.debug('>>>> Status Code:'+ res.getStatusCode());
                System.debug('>>>> returnJSON:'+ returnJSON);
                 if(res.getStatusCode()==200){
                     
                    String responseBody;
                    if(System.Label.ICM_Dummy_Error_Response_Mode_Reimbursement_Submission.toUpperCase() == 'ON'){
                        responseBody = System.Label.ICM_Dummy_Error_Response;
                    }else{
                        responseBody = res.getBody();
                    }
                    
                    Map<String, Object> ICM_Response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    system.debug('ICM_Response-->'+ICM_Response);
                    
                    // ----------------------------------------------- //
                    // ------- Handle error response (if any) -------- //
                    // ----------------------------------------------- //
                    if(ICM_Response.containsKey(System.Label.ICM_Error_Response_Parent_Tag)){
                        String strErrorStatus;
                        String strErrorMsg;
                    
                        List<Object> errorDetailsList = (List<Object>)ICM_Response.get(System.Label.ICM_Error_Response_Parent_Tag);
                        system.debug('errorDetail-->'+errorDetailsList[0]);
                        Map<String, Object> errorDetail = (Map<String, Object>)errorDetailsList[0];
                        if(errorDetail.containsKey(System.Label.ICM_Error_Response_Error_Message_Tag)){
                            strErrorMsg = (String)errorDetail.get(System.Label.ICM_Error_Response_Error_Message_Tag);        
                        }
                         if(errorDetail.containsKey(System.Label.ICM_Error_Response_Status_Tag)){
                            strErrorStatus = (String)errorDetail.get(System.Label.ICM_Error_Response_Status_Tag);        
                        }
                        system.debug('strErrorStatus=' + strErrorStatus);
                        system.debug('strErrorMsg=' + strErrorMsg);
                        system.debug('request.RecordType.Name =' + request.RecordType.Name );
                        
                        if(request.RecordType.Name == 'Reimbursement'){
                            MCFD_Logger.log_integ_err_for_request('Submission - Reimbursement', 
                                                               MCFD_Logger.error, 
                                                               'MCFD_SubmitAutismRequestXMLGenerator', 
                                                               'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                               request.Id);
                        }
                        
                        request.MCFD_Status__c='Submission Error'; 
                        update request;
                    }else{
                    // ----------------------------------------------- //
                    // ------- Handle success response --------------- //
                    // ----------------------------------------------- //
                        request.MCFD_Status__c='Submitted'; 
                        update request;
                    }
                              
                }else{
                    request.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
                    update request;   
                    system.debug('request.RecordType.Name =' + request.RecordType.Name );
                        
                    if(request.RecordType.Name == 'Reimbursement'){
                        MCFD_Logger.log_integ_err_for_request('Submission - Reimbursement', 
                                                           MCFD_Logger.error, 
                                                           'MCFD_SubmitAutismRequestXMLGenerator', 
                                                           'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
                                                           request.Id);
                    }
                    
                    request.MCFD_Status__c='Submission Error'; 
                    update request;
                }     
            } 
            catch(System.CalloutException e) {
                system.debug('Came to Exception');
                system.debug('request.RecordType.Name =' + request.RecordType.Name );
                        
                if(request.RecordType.Name == 'Reimbursement'){
                    MCFD_Logger.log_integ_err_for_request('Submission - Reimbursement', 
                                                       MCFD_Logger.error, 
                                                       'MCFD_SubmitAutismRequestXMLGenerator', 
                                                       'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                       request.Id);
                }
                
                request.MCFD_Status__c='Submission Error'; 
                update request;
            }     
            return xmlString;
        }
        return ''; 
        
    }

    
    // PDAVE: US 515 - Adding custom exception class for RTP Submission 
    public class RTP_Submission_Exception extends Exception {
      public RTP_Submission_Exception(Exception exptn, string sourceClass){
        //system.debug('Exeption Name ******' + exptn);
      }
    }
}