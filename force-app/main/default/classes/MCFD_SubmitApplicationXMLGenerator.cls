/**************************************************************************************
Function            : Contains Parsing SiteMinder SAML Response & Redirection Logic 

Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Akashdeep Vinnakota         20 APR 2017             Original Version
* Pavan Dave                  24 MAY 2017             Refactored Income, Child, Parent tags for RTA related design changes  (US 1795, 2304)
* Pavan Dave                  06 JUN 2017             Added ConsentPages and it's child tags for US 2749 
* Laura Perry                 15 JUN 2017             Added logic around the address, to limit number of addresses in XML
* PDAVE                       22 SEP 2017             Added error handling logic (CCS Application and Renewal) as part of US 4589
* Ashok Mariappan             18 JUN 2018             Added logic to set netIncomePerMonthFormula to Amount Bug #6538 , HPQC 38406 
* Sonam Raju 		      22 JUN 2018	      Added Logic for Income types and Alt Income reason fields			
*************************************************************************************/

public without sharing class MCFD_SubmitApplicationXMLGenerator {
  public static String createSubmitXML(Request__c request)
  {
      Request__c oCurrReq = new Request__c();
      Contact oCurrCon = new Contact();
      Id oCurrSpouseId;
      List<MCFD_Relationship__c> lstOfContactsRelationships = new List<MCFD_Relationship__c>();
      Map<Id, String> mapContRelation = new Map<Id, String>();
      List<Contact> lstOfDepSpouseContacts = new List<Contact>();
      
      List<MCFD_Contact_Address__c> lstOfContactAddress = new List<MCFD_Contact_Address__c>();
      
      Map<String, Set<String>> mapRelations = new Map<String, Set<String>>();
      List<Reason_For_Care__c> lstOfRFCs = new List<Reason_For_Care__c>();
      Map<Id, String> mapRFCRole = new Map<Id, String>();
      Map<Id, List<Reason_For_Care__c>> mapEmpEmplyr = new Map<Id, List<Reason_For_Care__c>>();
      Map<Id, List<Reason_For_Care__c>> mapSelfEmpBusns = new Map<Id, List<Reason_For_Care__c>>();
      List<Income__c> lstIncome = new List<Income__c>();
      Map<Id, String> mapIncRole = new Map<Id, String>();
      List<MCFD_Employment_Income__c> lstEmpIncome = new List<MCFD_Employment_Income__c>();
      List<MCFD_Self_Employment_Income__c> lstSelfEmpIncome = new List<MCFD_Self_Employment_Income__c>();
      Id requestCreatorUserId = request.CreatedById;
      String requestCreatetorName = request.CreatedBy.Name;

      
      oCurrReq = [Select id, RecordType.Name, Name, MCFD_HasActiveCRAConsent__c, MCFD_Service_Provider_Name__c, MCFD_declaration_and_consent_signed_date__c, MCFD_Type__c,
                          MCFD_DeclarationAndConsent__c, MCFD_spousal_consent_signed_date__c, MCFD_consent_share_info_with_sp_signed__c, 
                          MCFD_consent_to_share_info_with_spouse__c, MCFD_Contact__c, ICM_SR_Number__c, MCFD_spousal_consent_check1__c, MCFD_spousal_consent_check2__c, 
                          Primary_Applicant__c, Primary_Applicant__r.Name, MCFD_CRA_Consent__c, MCFD_CRA_Consent_Signed_Date__c, MCFD_Spousal_CRA_Consent__c, MCFD_Spouse_CRA_Consent_Signed_Date__c,
                          MCFD_CCS_HasFiledTax__c,Spouse__c, MCFD_CCS_SpouseHasFileTax__c, MCFD_CCS_SpouseIncomeDecreased__c, MCFD_CCS_IncomeDecreased__c, MCFD_CCS_DecreaseIncomeReason__c, MCFD_CCS_Spouse_NoTaxFilingReason__c, MCFD_CCS_SpouseHasFiledTax__c, MCFD_CCS_Spouse_DecreaseIncomeReason__c, MCFD_CCS_Spouse_Reason_NotFilingTax__c,MCFD_CCS_IncomeChanged__c,MCFD_CCS_IncomeIncreasedOrDecreased__c,MCFD_CCS_SpouseIncomeIncreasedDecreased__c,MCFD_CCS_SpouseIncomeChanged__c
                          from Request__c where Id =: request.id];
                          
      System.debug(oCurrReq);
      
      if(oCurrReq.Id !=null)
      {
          oCurrCon = [Select Id, MCFD_BCeID__c, FirstName, MiddleName, LastName, Birthdate, MCFD_Gender__c, MCFD_SIN__c, MCFD_Marital_Status__c, 
                  MCFD_Reason_for_no_SIN__c, MCFD_Is_SW_Referred__c, MCFD_SIN_Expiry_Date__c, MCFD_Govt_Disability_Benefit__c, 
                  Phone, MobilePhone,Email, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c ,MCFD_Address_Check__c, Send_ICM_Contact_ID__c, ICM_Contact_Id__c
                  from Contact where id =:oCurrReq.Primary_Applicant__c]; 
      }
      
      List<User> ContactDetails = [select Contact.MCFD_HasActiveCRAConsent__c, Contact.ICM_StartDate__c,ContactId, Contact.FirstName,Contact.LastName, Contact.MCFD_BCeID__c,Contact.MCFD_GUID__c from user where id =:requestCreatorUserId limit 1];
      
      
      if(oCurrReq.Id !=null && oCurrCon.Id !=null)
      {
          lstOfContactAddress = [Select id, Name, UnitNum__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, MCFD_Address_Type__c,
                                 City__c, MCFD_Contact__c, Country__c, Postal_Code__c, Province__c, MAKId__c from MCFD_Contact_Address__c
                                 where MCFD_Contact__c =: oCurrCon.Id AND MCFD_Request__c =: oCurrReq.Id];
          
          lstOfContactsRelationships = [Select Id, Name, MCFD_Child_Contact__c, MCFD_Dependant_Number__c, MCFD_Parent_Contact__c,
                                    MCFD_Relationship_Type__c, MCFD_Request__c from MCFD_Relationship__c where 
                                    MCFD_Parent_Contact__c =: oCurrCon.Id AND MCFD_Request__c =: oCurrReq.id];
          
          if(lstOfContactsRelationships.size() > 0)
          {
              List<String> lstOfDepSpouseContactIds = new List<String>(); 
              for(MCFD_Relationship__c oCurrRel : lstOfContactsRelationships)
              {
                  lstOfDepSpouseContactIds.add(oCurrRel.MCFD_Child_Contact__c);
                  if(oCurrRel.MCFD_Relationship_Type__c == 'Spouse')
                  {
                    system.debug('#####Entered Spouse'+oCurrRel.MCFD_Child_Contact__c);
                      Set<String> setOfSpouses = new Set<String>();
                      if(mapRelations.containsKey('Spouse'))
                          setOfSpouses = mapRelations.get('Spouse');
                      setOfSpouses.add(oCurrRel.MCFD_Child_Contact__c);
                      mapRelations.put('Spouse',setOfSpouses);
                  }
                  else if(oCurrRel.MCFD_Relationship_Type__c == 'Dependant')
                  {
                      Set<String> setOfDependants = new Set<String>();
                      if(mapRelations.containsKey('Dependant'))
                          setOfDependants = mapRelations.get('Dependant');
                      setOfDependants.add(oCurrRel.MCFD_Child_Contact__c);
                      mapRelations.put('Dependant',setOfDependants);
                  }
              }
              lstOfDepSpouseContacts = [Select id, Name, FirstName, MiddleName, LastName, Birthdate, MCFD_Gender__c, MCFD_SIN__c, 
                                        MCFD_Special_needs__c, MCFD_Childcare_Require__c, MCFD_Licensed_Group_CC__c,
                                        MCFD_Licensed_Family_CC__c, MCFD_Licensed_Preschool__c, MCFD_Reg_Lic_Not_Req__c, MCFD_Lic_Not_Reqrd__c, 
                                        MCFD_In_Childs_Own_Home__c, MCFD_Child_Placement__c, MCFD_Is_Custody_Shared__c, MCFD_Custody_Details__c, 
                                        MCFD_Same_Custody_Details__c, MCFD_Reason_for_no_SIN__c, MCFD_Govt_Disability_Benefit__c, Send_ICM_Contact_ID__c, ICM_Contact_Id__c
                                        from Contact where id IN: lstOfDepSpouseContactIds];
          }
          
          // Get the spouse contact
          if(mapRelations.containsKey('Spouse') != Null){
              Set<String> spouseSet = mapRelations.get('Spouse');
              if(spouseSet != Null){
                  oCurrSpouseId = new List<String> (spouseSet).get(0);    
              }               
          }
          List<User> SpouseDetails= new List<User>();
          if (oCurrSpouseId!=null)    
            SpouseDetails= [select Contact.MCFD_HasActiveCRAConsent__c, Contact.ICM_StartDate__c, ContactId, Contact.FirstName,Contact.LastName, Contact.MCFD_BCeID__c,Contact.MCFD_GUID__c from user where Contact.id =:oCurrSpouseId limit 1];
          if(lstOfContactsRelationships.size() > 0){
              for(MCFD_Relationship__c item: lstOfContactsRelationships){
                  if(item.MCFD_Relationship_Type__c == 'Spouse')
                      mapContRelation.put(item.MCFD_Child_Contact__c, 'Spouse');
                  else if(item.MCFD_Relationship_Type__c == 'Dependant'){
                      mapContRelation.put(item.MCFD_Child_Contact__c, 'Dependant');
                  }
              }
              mapContRelation.put(oCurrCon.Id, 'Applicant');
          }
          
          lstOfRFCs = [Select MCFD_Rsn_For_Care_Type__c, MCFD_Name__c, MCFD_Start_Date__c, MCFD_End_Date__c, 
                    MCFD_Number_of_days_weekend__c, MCFD_Number_of_hours_per_day_weekend__c, MCFD_Number_of_days_week__c, 
                    MCFD_Number_of_hours_per_day_week__c, No_change_in_ST_and_ET_on_M_to_F__c, MCFD_Start_Time__c, MCFD_End_Time__c, MCFD_Additional_Info__c,
                    MCFD_When_do_you_work__c, MCFD_Travel_hours__c, Contact__c from Reason_For_Care__c where 
                    Contact__c <> Null
                    AND
                    (Contact__c =: oCurrCon.Id OR Contact__c =: oCurrSpouseId!=null?oCurrSpouseId:oCurrCon.Id)
                    AND MCFD_Request__c =: oCurrReq.id  ORDER BY CreatedDate];
          
          mapRFCRole = calculateRFCRole(lstOfRFCs, mapContRelation);
          System.debug('--mapRFCRole--'+mapRFCRole);
          
          mapEmpEmplyr = calculate_Employment_Employer(lstOfRFCs);
          System.debug('--mapEmpEmplyr--'+mapEmpEmplyr);
          
          mapSelfEmpBusns = calculate_SelfEmployment_Business(lstOfRFCs);
          System.debug('--mapSelfEmpBusns--'+mapSelfEmpBusns);
                      
          String Query = 'Select ';
          Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Income__c.fields.getMap();
          for(String fieldName: schemaFieldMap.keySet()) {
              Query += fieldName + ', ';
          }
          Query = Query.removeEnd(', ');
          //added and commented out by laura for bug 5521
          Query += ' from Income__c where MCFD_Related_Request__c = \'' + request.Id + '\'';
          /*
          if(oCurrSpouseId != Null){
              Query += ' from Income__c where Contact__c = \'' + oCurrCon.Id + '\' OR Contact__c = \''+ oCurrSpouseId + '\''; 
          }else{
              Query += ' from Income__c where Contact__c = \'' + oCurrCon.Id + '\'';  
          }            
         */ System.Debug('>>>> Query: ' + Query);
          try {
              lstIncome = Database.query(Query);
          } catch(Exception e) {
              MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_SubmitApplicationXMLGenerator' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
          }
          
          if(lstIncome.size() > 0)
          {
              
              lstEmpIncome = [Select Id, Name, MCFD_Employer_Name__c, MCFD_Net_Income_Per_Month_Formula__c, MCFD_Hourly_Wage__c, MCFD_Amount_Pay_Stub_1__c, MCFD_Amount_Pay_Stub_2__c,
                                  MCFD_Pay_Frequency__c, Parent_Income_Id__c, MCFD_No_Two_Pay_Stubs__c
                              from MCFD_Employment_Income__c where Parent_Income_Id__c IN:lstIncome];
                      
      
              lstSelfEmpIncome = [Select Id, Name, MCFD_Business_Name__c, MCFD_Net_Income_Per_Month_Formula__c, MCFD_New_Business__c, MCFD_Limited_Company__c, MCFD_Pay_Frequency__c, 
                                      Parent_Income_Id__c, MCFD_Net_Income__c
                                  from MCFD_Self_Employment_Income__c where Parent_Income_Id__c IN:lstIncome];    
          }
          
          mapIncRole = calculateIncRole(lstIncome, mapContRelation);
          System.debug('--mapIncRole--'+mapIncRole);                  
              
          XmlStreamWriter w = new XmlStreamWriter();
          w.writeStartDocument(null,'1.0');
          w.writeStartElement(null,'Document',null);
          w.writeStartElement(null,'Header',null);
              w.writeStartElement(null,'TransactionName',null);
              w.writeCharacters('CCS Application Submit');
              w.writeEndElement();
              w.writeStartElement(null,'CreatedDate',null);
              w.writeCharacters(String.ValueOf(System.Today()));
              w.writeEndElement();
              w.writeStartElement(null,'CreatedBy',null);
              w.writeCharacters(requestCreatetorName);
              w.writeEndElement();
          w.writeEndElement();
          w.writeStartElement(null,'Payload',null);
              w.writeStartElement(null,'Operation',null);
              w.writeCharacters('Update');
              w.writeEndElement();
              w.writeStartElement(null,'SRNumber',null);
              w.writeCharacters(oCurrReq.ICM_SR_Number__c==null?'':oCurrReq.ICM_SR_Number__c);
              w.writeEndElement();
              w.writeStartElement(null,'SRType',null);
              w.writeCharacters('Child Care Subsidy');
              w.writeEndElement();
              w.writeStartElement(null,'SRSubType',null);
              w.writeCharacters(oCurrReq.MCFD_Type__c == 'Child Care Subsidy Application'? 'Application':(oCurrReq.MCFD_Type__c == 'Child Care Subsidy Renewal'?'Renewal':''));
              w.writeEndElement();
              w.writeStartElement(null,'Memo',null);
              w.writeCharacters(ContactDetails[0].Contact.LastName+ ', ' + ContactDetails[0].Contact.FirstName + ', ' + ContactDetails[0].Contact.MCFD_BCeID__c);
              w.writeEndElement();
              
          w.writeStartElement(null,'ListofProspect',null);
              w.writeStartElement(null,'Prospects',null);   
                  // changes for user story 4332 
                  w.writeStartElement(null, 'ICMContactId', null);
                  w.writeCharacters((oCurrCon.ICM_Contact_Id__c!=null && oCurrCon.Send_ICM_Contact_ID__c==true)?oCurrCon.ICM_Contact_Id__c:'');
                  w.writeEndElement();
          
                  w.writeStartElement(null,'ApplicantFirstName',null);
                  w.writeCharacters(oCurrCon.FirstName==null?'':oCurrCon.FirstName);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantMiddleName',null);
                  w.writeCharacters(oCurrCon.MiddleName==null?'':oCurrCon.MiddleName);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantLastName',null);
                  w.writeCharacters(oCurrCon.LastName==null?'':oCurrCon.LastName);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantDateofBirth',null);
                  w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oCurrCon.Birthdate));
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantGender',null);
                  w.writeCharacters(oCurrCon.MCFD_Gender__c==null?'':oCurrCon.MCFD_Gender__c);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantSin',null);
                  w.writeCharacters(oCurrCon.MCFD_SIN__c==null?'':oCurrCon.MCFD_SIN__c);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantMaritalStatus',null);
                  w.writeCharacters(oCurrCon.MCFD_Marital_Status__c==null?'':oCurrCon.MCFD_Marital_Status__c);
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantReasonforNoSin',null);
                  w.writeCharacters(oCurrCon.MCFD_Reason_for_no_SIN__c==null?'':oCurrCon.MCFD_Reason_for_no_SIN__c);
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantSocialWorkerInvolvement',null);
                  w.writeCharacters(oCurrCon.MCFD_Is_SW_Referred__c=='Yes'?'true':'false');
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantSinExpiryDate',null);
                  w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oCurrCon.MCFD_SIN_Expiry_Date__c));
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantGovernmentDisabilityBenefits',null);
                  w.writeCharacters(oCurrCon.MCFD_Govt_Disability_Benefit__c==null?'':oCurrCon.MCFD_Govt_Disability_Benefit__c);
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantPrimaryPhoneNumberType',null);
                  w.writeCharacters(oCurrCon.MCFD_Primary_Phone_Number_Type__c==null?'':oCurrCon.MCFD_Primary_Phone_Number_Type__c);
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantPrimaryPhoneNumber',null);
                   w.writeCharacters(oCurrCon.Phone==null?'': MCFD_RTAXMLGenerator.getPhoneNumberString(oCurrCon.Phone));
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantSecondaryPhoneNumberType',null);
                  w.writeCharacters(oCurrCon.MCFD_Secondary_Phone_Number_Type__c==null?'':oCurrCon.MCFD_Secondary_Phone_Number_Type__c);
                  w.writeEndElement();    
                  w.writeStartElement(null,'ApplicantSecondaryPhoneNumber',null);
                  w.writeCharacters(oCurrCon.MobilePhone==null?'': MCFD_RTAXMLGenerator.getPhoneNumberString(oCurrCon.MobilePhone));
                  w.writeEndElement();
                  w.writeStartElement(null,'ApplicantEmail',null);
                  w.writeCharacters(oCurrCon.Email==null?'':oCurrCon.Email);
                  w.writeEndElement();      
                  
                  //go backwards through list to get most recent address"
                  for(Integer i = lstOfContactAddress.size()-1; i >= 0; i--)
                  {
                      MCFD_Contact_Address__c oCurrAddr = lstOfContactAddress[i];
                      // Bug fix for 4579
                      System.debug(lstOfContactAddress);
                      String addressLine1 = '', unitNum = '';
                    /*  if(oCurrAddr.MAKId__c != null && oCurrAddr.MAKId__c != ''){
                          unitNum = oCurrAddr.UnitNum__c==null? '': oCurrAddr.UnitNum__c;
                          addressLine1 = oCurrAddr.Address_Line_1__c==null? '': oCurrAddr.Address_Line_1__c;
                          addressLine1 = unitNum==''? addressLine1: addressLine1.replace(unitNum + '-', '');
                      }
                      else{
                          addressLine1 = oCurrAddr.Address_Line_1__c==null? '': oCurrAddr.Address_Line_1__c;
                      }*/
                      String tempAddLine1 = '';
                      String tempAddLine2 = '';
                      System.debug('checking if the address is too long');
                      System.debug(oCurrAddr.Address_Line_1__c);
                      System.debug(oCurrAddr.Address_Line_1__c.length() > 24);
                      
                      if (oCurrAddr.Address_Line_1__c.length() > 24){
                          String temp = oCurrAddr.Address_Line_1__c;
                          System.debug(temp.substring(0,24));
                          System.debug(temp.substring(25));
                          tempAddLine1 = temp.substring(0,24);
                          tempAddLine2 = temp.substring(24);
                          System.debug(tempAddLine1.endsWith(' '));
                          System.debug(tempAddLine2.startsWith(' '));
                          if (tempAddLine1.endsWith(' '))
                          {
                              //do nothing

                          }   
                          else if (tempAddLine2.startsWith(' '))
                          {
                              // trim leading space
                              tempAddLine2 = tempAddLine2.replaceFirst(' ', '');
                          }
                          else
                          {
                              //need to push a full word to the second address line
                              String[] addList = tempAddLine1.split(' ');
                              Integer finalStringIndex = addList.size()-1;
                              tempAddLine1 = addList[0];

                              for (Integer addIndex = 1; addIndex < finalStringIndex; addIndex++){
                                  tempAddLine1 = tempAddLine1 + ' ' + addList[addIndex];
                              }
                              
                              tempAddLine2 = addList[finalStringIndex] + tempAddLine2;
                          }
                          //make sure that address line 2 is less than 28
                          if (tempAddLine2.length() > 28)
                          {
                              tempAddLine2 = tempAddLine2.abbreviate(28);
                          }
                      }
                      else
                      {
                          tempAddLine1 = oCurrAddr.Address_Line_1__c;
                      }

                      system.debug('>>>> AddressType '+ oCurrAddr.MCFD_Address_Type__c );
                      system.debug('>>>> Address check '+  oCurrCon.MCFD_Address_Check__c);
                      if((oCurrAddr.MCFD_Address_Type__c == 'Home and Mailing Address' || oCurrAddr.MCFD_Address_Type__c == 'Home Address') && oCurrCon.MCFD_Address_Check__c == 'No' )
                      {
                          w.writeStartElement(null,'ApplicantHomeApartment',null);
                          w.writeCharacters(oCurrAddr.UnitNum__c==null?'':oCurrAddr.UnitNum__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeAddress1',null);
                          w.writeCharacters(tempAddLine1);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeAddress2',null);
                          w.writeCharacters(tempAddLine2);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeCity',null);
                          w.writeCharacters(oCurrAddr.City__c==null?'':oCurrAddr.City__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomePostalCode',null);
                          w.writeCharacters(oCurrAddr.Postal_Code__c==null?'':oCurrAddr.Postal_Code__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeProvince',null);
                          w.writeCharacters(oCurrAddr.Province__c==null?'':oCurrAddr.Province__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeMAKID',null);
                          w.writeCharacters(oCurrAddr.MAKId__c==null?'':oCurrAddr.MAKId__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantAddressCheck',null);
                          w.writeCharacters(oCurrCon.MCFD_Address_Check__c==null?'':oCurrCon.MCFD_Address_Check__c);
                          w.writeEndElement();
                      }
                      if(( oCurrAddr.MCFD_Address_Type__c == 'Mailing Address' && oCurrCon.MCFD_Address_Check__c == 'No'))
                      {
                          w.writeStartElement(null,'ApplicantMailingApartment',null);
                          w.writeCharacters(oCurrAddr.UnitNum__c==null?'':oCurrAddr.UnitNum__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingAddress1',null);
                          w.writeCharacters(tempAddLine1);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingAddress2',null);
                          w.writeCharacters(tempAddLine2);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingCity',null);
                          w.writeCharacters(oCurrAddr.City__c==null?'':oCurrAddr.City__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingPostalCode',null);
                          w.writeCharacters(oCurrAddr.Postal_Code__c==null?'':oCurrAddr.Postal_Code__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingProvince',null);
                          w.writeCharacters(oCurrAddr.Province__c==null?'':oCurrAddr.Province__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingMAKID',null);
                          w.writeCharacters(oCurrAddr.MAKId__c==null?'':oCurrAddr.MAKId__c);
                          w.writeEndElement();
                      }
                      if((oCurrAddr.MCFD_Address_Type__c == 'Home and Mailing Address' && oCurrCon.MCFD_Address_Check__c == 'Yes'))
                      {
                          w.writeStartElement(null,'ApplicantAddressCheck',null);
                          w.writeCharacters(oCurrCon.MCFD_Address_Check__c==null?'':oCurrCon.MCFD_Address_Check__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeApartment',null);
                          w.writeCharacters(oCurrAddr.UnitNum__c==null?'':oCurrAddr.UnitNum__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeAddress1',null);
                          w.writeCharacters(tempAddLine1);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeAddress2',null);
                          w.writeCharacters(tempAddLine2);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeCity',null);
                          w.writeCharacters(oCurrAddr.City__c==null?'':oCurrAddr.City__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomePostalCode',null);
                          w.writeCharacters(oCurrAddr.Postal_Code__c==null?'':oCurrAddr.Postal_Code__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeProvince',null);
                          w.writeCharacters(oCurrAddr.Province__c==null?'':oCurrAddr.Province__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantHomeMAKID',null);
                          w.writeCharacters(oCurrAddr.MAKId__c==null?'':oCurrAddr.MAKId__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingApartment',null);
                          w.writeCharacters(oCurrAddr.UnitNum__c==null?'':oCurrAddr.UnitNum__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingAddress1',null);
                          w.writeCharacters(tempAddLine1);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingAddress2',null);
                          w.writeCharacters(tempAddLine2);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingCity',null);
                          w.writeCharacters(oCurrAddr.City__c==null?'':oCurrAddr.City__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingPostalCode',null);
                          w.writeCharacters(oCurrAddr.Postal_Code__c==null?'':oCurrAddr.Postal_Code__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingProvince',null);
                          w.writeCharacters(oCurrAddr.Province__c==null?'':oCurrAddr.Province__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'ApplicantMailingMAKID',null);
                          w.writeCharacters(oCurrAddr.MAKId__c==null?'':oCurrAddr.MAKId__c);
                          w.writeEndElement();
                      }
                  }
     //Added by Sonam for AltIncome
                 for(Income__c inc: lstIncome)
                     { 
                      if(oCurrReq.Primary_Applicant__c == inc.Contact__c) {
                                      w.writeStartElement(null,'ApplicantReasonforAltIncome',null);
                                      if(string.isBlank(inc.MCFD_Comments__c))
                                          {   
                                              inc.MCFD_Comments__c = '';  
                                          }
                                      String incomepath = ((oCurrReq.MCFD_CCS_HasFiledTax__c == 'Yes' && oCurrReq.MCFD_CCS_IncomeIncreasedOrDecreased__c == 'Decreased')?'IR:'+inc.MCFD_Comments__c:'API:'+inc.MCFD_Comments__c); 
                                      w.writeCharacters(incomepath);
                                      w.writeEndElement() ;
                               }
                           
                      } 
              w.writeEndElement();
              
              if(lstOfDepSpouseContacts.size() > 0)
              {
                  for(Contact oSupDepCon : lstOfDepSpouseContacts)
                  {
                      if(mapRelations.containsKey('Spouse') && mapRelations.get('Spouse').contains(oSupDepCon.id))
                      {
                      if(oCurrCon.MCFD_Marital_Status__c != 'Single, separated, divorced or widowed')
                      {
                          w.writeStartElement(null,'Prospects',null);
                              // changes for user story 4332 
                              w.writeStartElement(null, 'ICMContactId', null);
                              w.writeCharacters((oSupDepCon.ICM_Contact_Id__c!=null && oSupDepCon.Send_ICM_Contact_ID__c==true)?oSupDepCon.ICM_Contact_Id__c:'');
                              w.writeEndElement();
                          
                              w.writeStartElement(null,'SpouseFirstName',null);
                              w.writeCharacters(oSupDepCon.FirstName==null?'':oSupDepCon.FirstName);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseMiddleName',null);
                              w.writeCharacters(oSupDepCon.MiddleName==null?'':oSupDepCon.MiddleName);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseLastName',null);
                              w.writeCharacters(oSupDepCon.LastName==null?'':oSupDepCon.LastName);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseDateofBirth',null);
                              w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oSupDepCon.Birthdate));
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseGender',null);
                              w.writeCharacters(oSupDepCon.MCFD_Gender__c==null?'':oSupDepCon.MCFD_Gender__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseSin',null);
                              w.writeCharacters(oSupDepCon.MCFD_SIN__c==null?'':oSupDepCon.MCFD_SIN__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseReasonforNoSin',null);
                              w.writeCharacters(oSupDepCon.MCFD_Reason_for_no_SIN__c==null?'':oSupDepCon.MCFD_Reason_for_no_SIN__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'SpouseGovernmentDisabilityBenefits',null);
                              w.writeCharacters(oSupDepCon.MCFD_Govt_Disability_Benefit__c==null?'':oSupDepCon.MCFD_Govt_Disability_Benefit__c);
                              w.writeEndElement();
                             //Added by Sonam for Spouse AltIncome
                              for(Income__c incspouse: lstIncome)
                                 { 
                                      if(string.isNotblank(oCurrReq.Spouse__c))
                                          {
                                              if(oCurrReq.Spouse__c == incspouse.Contact__c) {
                                                       w.writeStartElement(null,'SpouseReasonforAltIncome',null);
                                                       if(string.isBlank(incspouse.MCFD_Comments__c))
                                                          {   
                                                              incspouse.MCFD_Comments__c = '';  
                                                          } 
                                                       String incomepath = ((oCurrReq.MCFD_CCS_SpouseHasFileTax__c == 'Yes' && oCurrReq.MCFD_CCS_SpouseIncomeIncreasedDecreased__c == 'Decreased')?'IR:'+incspouse.MCFD_Comments__c:'API:'+incspouse.MCFD_Comments__c); 
                                                       w.writeCharacters(incomepath);
                                                       w.writeEndElement();
                                                    }   
                                           }
                                    } 
                              w.writeStartElement(null,'SpouseBCeID',null);
      if (SpouseDetails.size()>0) {
        w.writeCharacters(SpouseDetails[0].Contact.MCFD_BCeID__c==null?'':SpouseDetails[0].Contact.MCFD_BCeID__c);
      } else {
        w.writeCharacters('');
      }
      w.writeEndElement();
                              w.writeStartElement(null,'SpouseGUID',null);
                              if (SpouseDetails.size()>0)
                                w.writeCharacters(SpouseDetails[0].Contact.MCFD_GUID__c==null?'':SpouseDetails[0].Contact.MCFD_GUID__c);
                              else
                                w.writeCharacters('');
                              w.writeEndElement();
                              
                          w.writeEndElement();
                      }
                      }
                      else if(mapRelations.containsKey('Dependant') && mapRelations.get('Dependant').contains(oSupDepCon.id))
                      {
                          w.writeStartElement(null,'Prospects',null);
                          w.writeStartElement(null,'ListofDependent',null);
                          w.writeStartElement(null,'Dependent',null);
                              // changes for user story 4332 
                              w.writeStartElement(null, 'ICMContactId', null);
                              w.writeCharacters((oSupDepCon.ICM_Contact_Id__c!=null && oSupDepCon.Send_ICM_Contact_ID__c==true)?oSupDepCon.ICM_Contact_Id__c:'');
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantFirstName',null);
                              w.writeCharacters(oSupDepCon.FirstName==null?'':oSupDepCon.FirstName);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantMiddleName',null);
                              w.writeCharacters(oSupDepCon.MiddleName==null?'':oSupDepCon.MiddleName);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantLastName',null);
                              w.writeCharacters(oSupDepCon.LastName==null?'':oSupDepCon.LastName);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantDateofBirth',null);
                              w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oSupDepCon.Birthdate));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantGender',null);
                              w.writeCharacters(oSupDepCon.MCFD_Gender__c==null?'':oSupDepCon.MCFD_Gender__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantSin',null);
                              w.writeCharacters(oSupDepCon.MCFD_SIN__c==null?'':oSupDepCon.MCFD_SIN__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantSpecialNeeds',null);
                              w.writeCharacters(oSupDepCon.MCFD_Special_needs__c==null?'':oSupDepCon.MCFD_Special_needs__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantRequiresChildCare',null);
                              w.writeCharacters(oSupDepCon.MCFD_Childcare_Require__c==null?'':oSupDepCon.MCFD_Childcare_Require__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantLicensedGroup',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_Licensed_Group_CC__c==null?false:oSupDepCon.MCFD_Licensed_Group_CC__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantLicensedFamily',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_Licensed_Family_CC__c==null?false:oSupDepCon.MCFD_Licensed_Family_CC__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantLicensedPreschool',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_Licensed_Preschool__c==null?false:oSupDepCon.MCFD_Licensed_Preschool__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantRegisteredLicenseNotRequired',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_Reg_Lic_Not_Req__c==null?false:oSupDepCon.MCFD_Reg_Lic_Not_Req__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantLicenseNotRequired',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_Lic_Not_Reqrd__c==null?false:oSupDepCon.MCFD_Lic_Not_Reqrd__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantChildsOwnHome',null);
                              w.writeCharacters(String.ValueOf(oSupDepCon.MCFD_In_Childs_Own_Home__c==null?false:oSupDepCon.MCFD_In_Childs_Own_Home__c));
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantMinistryPlacement',null);
                              w.writeCharacters(oSupDepCon.MCFD_Child_Placement__c==null?'':oSupDepCon.MCFD_Child_Placement__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantSharedCustody',null);
                              w.writeCharacters(oSupDepCon.MCFD_Is_Custody_Shared__c==null?'':oSupDepCon.MCFD_Is_Custody_Shared__c);
                              w.writeEndElement();                                
                              w.writeStartElement(null,'DependantCustodyDetails',null);
                              w.writeCharacters(oSupDepCon.MCFD_Custody_Details__c==null?'':oSupDepCon.MCFD_Custody_Details__c);
                              w.writeEndElement();
                              
                              String DependantCustodyDetailsApplyToAllChildren = '';
                              if(oSupDepCon.MCFD_Same_Custody_Details__c == true)
                              {
                                  DependantCustodyDetailsApplyToAllChildren   = 'Yes';
                              }
                              else
                              {
                                  DependantCustodyDetailsApplyToAllChildren = 'No';
                              }
                              w.writeStartElement(null,'DependantCustodyDetailsApplyToAllChildren',null);
                              w.writeCharacters(DependantCustodyDetailsApplyToAllChildren);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantReasonforNoSin',null);
                              w.writeCharacters(oSupDepCon.MCFD_Reason_for_no_SIN__c==null?'':oSupDepCon.MCFD_Reason_for_no_SIN__c);
                              w.writeEndElement();
                              w.writeStartElement(null,'DependantGovernmentDisabilityBenefits',null);
                              w.writeCharacters(oSupDepCon.MCFD_Govt_Disability_Benefit__c==null?'':oSupDepCon.MCFD_Govt_Disability_Benefit__c);
                              w.writeEndElement();
                          w.writeEndElement();
                          w.writeEndElement();
                          w.writeEndElement();
                      }
                  }
                  
              }
              
          
          w.writeStartElement(null,'ListReasonForCare',null);
          if(lstOfRFCs.size() > 0)
          {
              for(Reason_For_Care__c oCurrRFC : lstOfRFCs)
              {
                  /*
                  Commented out by Laura to fix Bug 4582. It doesn't appear that there should be any difference in the Employer or Business
                  Reason for care XMLs.
                  if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Employment' || oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Employer'){
                          if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Employment'){
                              if(mapEmpEmplyr.size() > 0 && mapEmpEmplyr.get(oCurrRFC.Id) != Null){
                                  system.debug('Employment id---'+oCurrRFC.Id);                                   
                                  for(Reason_For_Care__c employerRFCItem: mapEmpEmplyr.get(oCurrRFC.Id)){                                     
                                      w.writeStartElement(null,'ReasonForCare',null);
                                          w.writeStartElement(null,'Role',null);
                                          w.writeCharacters(getValue(mapRFCRole.get(employerRFCItem.Id)));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'Reason',null);
                                          w.writeCharacters('Employment');
                                          w.writeEndElement();
                                          w.writeStartElement(null,'Name',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Name__c==null?'':employerRFCItem.MCFD_Name__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'StartDate',null);
                                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(employerRFCItem.MCFD_Start_Date__c));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'EndDate',null);
                                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(employerRFCItem.MCFD_End_Date__c));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekDaysAndOrWeekEnds',null);
                                          w.writeCharacters(employerRFCItem.MCFD_When_do_you_work__c==null?'':employerRFCItem.MCFD_When_do_you_work__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekEndDaysPerWeek',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Number_of_days_weekend__c==null?'':employerRFCItem.MCFD_Number_of_days_weekend__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekEndHoursPerDay',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Number_of_hours_per_day_weekend__c==null?'':employerRFCItem.MCFD_Number_of_hours_per_day_weekend__c);
                                          w.writeEndElement();                    
                                          w.writeStartElement(null,'WeekDayDaysPerWeek',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Number_of_days_week__c==null?'':employerRFCItem.MCFD_Number_of_days_week__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekDayHoursPerDay',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Number_of_hours_per_day_week__c==null?'':employerRFCItem.MCFD_Number_of_hours_per_day_week__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'RegularscheduleFlag',null);
                                          w.writeCharacters(employerRFCItem.No_change_in_ST_and_ET_on_M_to_F__c==true? '1' : '0');
                                          w.writeEndElement();
                                          w.writeStartElement(null,'StartTime',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Start_Time__c==null?'':employerRFCItem.MCFD_Start_Time__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'EndTime',null);
                                          w.writeCharacters(employerRFCItem.MCFD_End_Time__c==null?'':employerRFCItem.MCFD_End_Time__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'AdditionalComments',null);
                                          w.writeCharacters(employerRFCItem.MCFD_Additional_Info__c==null?'':employerRFCItem.MCFD_Additional_Info__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'TravelTime',null);
                                          w.writeCharacters(oCurrRFC.MCFD_Travel_hours__c==null?'':oCurrRFC.MCFD_Travel_hours__c);            // This is common information saved on Employment RFC record
                                          w.writeEndElement();
                                      w.writeEndElement();
                                  }   
                              }
                          }else if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Employer'){
                              // do nothing
                          }
                  }else if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Self Employment' || oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Business' ){
                      if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Self Employment'){
                              if(mapSelfEmpBusns.size() > 0 && mapSelfEmpBusns.get(oCurrRFC.Id) != Null){
                                  for(Reason_For_Care__c businessRFCItem: mapSelfEmpBusns.get(oCurrRFC.Id)){                                      
                                      w.writeStartElement(null,'ReasonForCare',null);
                                          w.writeStartElement(null,'Role',null);
                                          w.writeCharacters(getValue(mapRFCRole.get(businessRFCItem.Id)));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'Reason',null);
                                          w.writeCharacters('Self Employment');
                                          w.writeEndElement();
                                          w.writeStartElement(null,'Name',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Name__c==null?'':businessRFCItem.MCFD_Name__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'StartDate',null);
                                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(businessRFCItem.MCFD_Start_Date__c));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'EndDate',null);
                                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(businessRFCItem.MCFD_End_Date__c));
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekDaysAndOrWeekEnds',null);
                                          w.writeCharacters(businessRFCItem.MCFD_When_do_you_work__c==null?'':businessRFCItem.MCFD_When_do_you_work__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekEndDaysPerWeek',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Number_of_days_weekend__c==null?'':businessRFCItem.MCFD_Number_of_days_weekend__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekEndHoursPerDay',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Number_of_hours_per_day_weekend__c==null?'':businessRFCItem.MCFD_Number_of_hours_per_day_weekend__c);
                                          w.writeEndElement();                    
                                          w.writeStartElement(null,'WeekDayDaysPerWeek',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Number_of_days_week__c==null?'':businessRFCItem.MCFD_Number_of_days_week__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'WeekDayHoursPerDay',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Number_of_hours_per_day_week__c==null?'':businessRFCItem.MCFD_Number_of_hours_per_day_week__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'RegularscheduleFlag',null);
                                          w.writeCharacters(businessRFCItem.No_change_in_ST_and_ET_on_M_to_F__c==true? '1' : '0');
                                          w.writeEndElement();
                                          w.writeStartElement(null,'StartTime',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Start_Time__c==null?'':businessRFCItem.MCFD_Start_Time__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'EndTime',null);
                                          w.writeCharacters(businessRFCItem.MCFD_End_Time__c==null?'':businessRFCItem.MCFD_End_Time__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'AdditionalComments',null);
                                          w.writeCharacters(businessRFCItem.MCFD_Additional_Info__c==null?'':businessRFCItem.MCFD_Additional_Info__c);
                                          w.writeEndElement();
                                          w.writeStartElement(null,'TravelTime',null);
                                          w.writeCharacters(oCurrRFC.MCFD_Travel_hours__c==null?'':oCurrRFC.MCFD_Travel_hours__c);            // This is common information saved on Employment RFC record
                                          w.writeEndElement();
                                      w.writeEndElement();
                                  }   
                              }
                          }else if(oCurrRFC.MCFD_Rsn_For_Care_Type__c == 'Business'){
                              // do nothing
                          }
                  }else{*/
                      w.writeStartElement(null,'ReasonForCare',null);
                          w.writeStartElement(null,'Role',null);
                          w.writeCharacters(getValue(mapRFCRole.get(oCurrRFC.Id)));
                          w.writeEndElement();
                          w.writeStartElement(null,'Reason',null);
                          w.writeCharacters(oCurrRFC.MCFD_Rsn_For_Care_Type__c==null?'':oCurrRFC.MCFD_Rsn_For_Care_Type__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'Name',null);
                          w.writeCharacters(oCurrRFC.MCFD_Name__c==null?'':oCurrRFC.MCFD_Name__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);
                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oCurrRFC.MCFD_Start_Date__c));
                          w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);
                          w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oCurrRFC.MCFD_End_Date__c));
                          w.writeEndElement();
                          w.writeStartElement(null,'WeekDaysAndOrWeekEnds',null);
                          w.writeCharacters(oCurrRFC.MCFD_When_do_you_work__c==null?'':oCurrRFC.MCFD_When_do_you_work__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'WeekEndDaysPerWeek',null);
                          w.writeCharacters(oCurrRFC.MCFD_Number_of_days_weekend__c==null?'':oCurrRFC.MCFD_Number_of_days_weekend__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'WeekEndHoursPerDay',null);
                          w.writeCharacters(oCurrRFC.MCFD_Number_of_hours_per_day_weekend__c==null?'':oCurrRFC.MCFD_Number_of_hours_per_day_weekend__c);
                          w.writeEndElement();                    
                          w.writeStartElement(null,'WeekDayDaysPerWeek',null);
                          w.writeCharacters(oCurrRFC.MCFD_Number_of_days_week__c==null?'':oCurrRFC.MCFD_Number_of_days_week__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'WeekDayHoursPerDay',null);
                          w.writeCharacters(oCurrRFC.MCFD_Number_of_hours_per_day_week__c==null?'':oCurrRFC.MCFD_Number_of_hours_per_day_week__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'RegularscheduleFlag',null);
                          w.writeCharacters(oCurrRFC.No_change_in_ST_and_ET_on_M_to_F__c==true? '1' : '0');
                          w.writeEndElement();
                          w.writeStartElement(null,'StartTime',null);
                          w.writeCharacters(oCurrRFC.MCFD_Start_Time__c==null?'':oCurrRFC.MCFD_Start_Time__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'EndTime',null);
                          w.writeCharacters(oCurrRFC.MCFD_End_Time__c==null?'':oCurrRFC.MCFD_End_Time__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'AdditionalComments',null);
                          w.writeCharacters(oCurrRFC.MCFD_Additional_Info__c==null?'':oCurrRFC.MCFD_Additional_Info__c);
                          w.writeEndElement();
                          w.writeStartElement(null,'TravelTime',null);
                          w.writeCharacters(oCurrRFC.MCFD_Travel_hours__c==null?'No travel time':oCurrRFC.MCFD_Travel_hours__c);
                          w.writeEndElement();
                      w.writeEndElement();    
                  //}                   
              }
          }
          w.writeEndElement();
          
          w.writeStartElement(null,'ListofIncome',null);
              if(lstIncome.size() > 0)
              {
                  for(Income__c oInc : lstIncome)
                  {
                   if(oInc.MCFD_Employment_Income__c == 'Yes')
                      {                            
                          for(MCFD_Employment_Income__c oCurrEI: lstEmpIncome)
                          {   
                              if(oCurrEI.Parent_Income_Id__c == oInc.Id){                                 
                                  w.writeStartElement(null,'Income',null);
                                  w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                                  w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Employment Income');w.writeEndElement();
                                  w.writeStartElement(null,'Frequency',null);w.writeCharacters('Every year');w.writeEndElement();                          
                                  w.writeStartElement(null,'EmployerBusinessName',null);w.writeCharacters(getValue(oCurrEI.MCFD_Employer_Name__c));w.writeEndElement();
                                  w.writeStartElement(null,'NewJobBusinessFlag',null);w.writeCharacters(String.ValueOf(oCurrEI.MCFD_No_Two_Pay_Stubs__c));w.writeEndElement();
                                  w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oCurrEI.MCFD_Hourly_Wage__c==null?0.00:oCurrEI.MCFD_Hourly_Wage__c));w.writeEndElement();
                                  w.writeStartElement(null,'PayStub1Amount',null);w.writeCharacters(getValue(String.ValueOf(oCurrEI.MCFD_Amount_Pay_Stub_1__c)));w.writeEndElement();
                                  w.writeStartElement(null,'PayStub2Amount',null);w.writeCharacters(getValue(String.ValueOf(oCurrEI.MCFD_Amount_Pay_Stub_2__c)));w.writeEndElement();
                                  //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oCurrEI.MCFD_Net_Income_Per_Month_Formula__c==0.00?'':String.ValueOf(oCurrEI.MCFD_Net_Income_Per_Month_Formula__c) );w.writeEndElement();
                                  w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oCurrEI.MCFD_Hourly_Wage__c==null?0.00:oCurrEI.MCFD_Hourly_Wage__c));w.writeEndElement();
                                  w.writeEndElement();
                              }
                          }
                          
                          
                      }
                      if(oInc.MCFD_Self_Employment_Income__c == 'Yes')
                      {
                         for(MCFD_Self_Employment_Income__c oCurrSEI: lstSelfEmpIncome)
                          {
                              if(oCurrSEI.Parent_Income_Id__c == oInc.Id){        
                                  w.writeStartElement(null,'Income',null);
                                  w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                                  w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Self-Employment Income');w.writeEndElement();                                
                                  w.writeStartElement(null,'Frequency',null);w.writeCharacters(getValue(oCurrSEI.MCFD_Pay_Frequency__c));w.writeEndElement();                         
                                  w.writeStartElement(null,'EmployerBusinessName',null);w.writeCharacters(oCurrSEI.MCFD_Business_Name__c);w.writeEndElement();
                                  w.writeStartElement(null,'NewJobBusinessFlag',null);w.writeCharacters(oCurrSEI.MCFD_New_Business__c=='Yes'?'true':'false');w.writeEndElement();
                                  w.writeStartElement(null,'BusinessIncorporated',null);w.writeCharacters(oCurrSEI.MCFD_Limited_Company__c=='Yes'?'true':'false');w.writeEndElement();
                                  w.writeStartElement(null,'Amount',null);w.writeCharacters(getValue(String.ValueOf(oCurrSEI.MCFD_Net_Income__c)));w.writeEndElement();
                                  //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oCurrSEI.MCFD_Net_Income_Per_Month_Formula__c==0.00?'':String.ValueOf(oCurrSEI.MCFD_Net_Income_Per_Month_Formula__c) );w.writeEndElement();
                                  w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(getValue(String.ValueOf(oCurrSEI.MCFD_Net_Income__c)));w.writeEndElement();
                                  w.writeEndElement();
                              }
                          }                            
                      }
                      
                      if(oInc.MCFD_Band_Assistance__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Band Assistance');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Band_Assistance_Amount__c==null?0.00:oInc.MCFD_Band_Assistance_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Band_Assistance_Freq__c==null?'':oInc.MCFD_Band_Assistance_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Band_Assistance_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_Band_Assistance_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Band_Assistance_Amount__c==null?0.00:oInc.MCFD_Band_Assistance_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
          
          //Changed by Sonam for Disability Benefits from Disability Assistance
                      if(oInc.MCFD_DisabilityBenefits__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Disability Benefits');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_DisabilityBenefitsAmount__c==null?0.00:oInc.MCFD_DisabilityBenefitsAmount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_DisabilityBenefitsFrequency__c==null?'':oInc.MCFD_DisabilityBenefitsFrequency__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Disability_Benefits_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_Disability_Benefits_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_DisabilityBenefitsAmount__c==null?0.00:oInc.MCFD_DisabilityBenefitsAmount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
        
          //Added by Sonam for RRSP as it doesn't exist already
                      if(oInc.MCFD_RRSPIncome__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Registered Retirement Savings Plan income');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_RRSPIncomeAmount__c==null?0.00:oInc.MCFD_RRSPIncomeAmount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_RRSPIncomeFreqency__c==null?'':oInc.MCFD_RRSPIncomeFreqency__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_RRSP_Income_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_RRSP_Income_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_RRSPIncomeAmount__c==null?0.00:oInc.MCFD_RRSPIncomeAmount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
          //Added by Sonam for Pension as it doesn't exist already
                      if(oInc.MCFD_PensionIncome__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Pensions/Superannuation');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_PensionIncomeAmount__c==null?0.00:oInc.MCFD_PensionIncomeAmount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_PensionIncomeFrequency__c==null?'':oInc.MCFD_PensionIncomeFrequency__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Pension_Income_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_Pension_Income_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_PensionIncomeAmount__c==null?0.00:oInc.MCFD_PensionIncomeAmount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
          
                      if(oInc.MCFD_BC_Income_Assistance__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('BC Income Assistance');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_BC_Income_Assistance_Amount__c==null?0.00:oInc.MCFD_BC_Income_Assistance_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_BC_Income_Assistance_Freq__c==null?'':oInc.MCFD_BC_Income_Assistance_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_BC_Income_Monthly__c==0.00?'':String.ValueOf(oInc.MCFD_BC_Income_Monthly__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_BC_Income_Assistance_Amount__c==null?0.00:oInc.MCFD_BC_Income_Assistance_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                     
                      if(oInc.MCFD_Federal_Benefits__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Federal benefits');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Federal_Benefits_Amount__c==null?0.00:oInc.MCFD_Federal_Benefits_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Federal_Benefits_Freq__c==null?'':oInc.MCFD_Federal_Benefits_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Federal_Benefits_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_Federal_Benefits_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Federal_Benefits_Amount__c==null?0.00:oInc.MCFD_Federal_Benefits_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Federal_Employment_Insurance__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Federal Employment Insurance');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Federal_Employment_Insurance_Amount__c==null?0.00:oInc.MCFD_Federal_Employment_Insurance_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Federal_Employment_Insurance_Freq__c==null?'':oInc.MCFD_Federal_Employment_Insurance_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oInc.MCFD_Federal_Employment_Insurance_Start__c));w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Federal_Employment_Insurance_MonInc__c==0.00?'':String.ValueOf(oInc.MCFD_Federal_Employment_Insurance_MonInc__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Federal_Employment_Insurance_Amount__c==null?0.00:oInc.MCFD_Federal_Employment_Insurance_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Grants__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Grants, bursaries or scholarships');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Grants_Amount__c==null?0.00:oInc.MCFD_Grants_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Grants_Freq__c==null?'':oInc.MCFD_Grants_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Grants_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_Grants_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Grants_Amount__c==null?0.00:oInc.MCFD_Grants_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Dep_Adult_Income__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Income earned by dependant adults');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Dep_Adult_Income_Amount__c==null?0.00:oInc.MCFD_Dep_Adult_Income_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Dep_Adult_Income_Freq__c==null?'':oInc.MCFD_Dep_Adult_Income_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Income_earned_by_dep_adults_monthly__c==0.00?'':String.ValueOf(oInc.MCFD_Income_earned_by_dep_adults_monthly__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Dep_Adult_Income_Amount__c==null?0.00:oInc.MCFD_Dep_Adult_Income_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Rental_Income__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Income from rental property');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Rental_Income_Amount__c==null?0.00:oInc.MCFD_Rental_Income_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Rental_Income_Freq__c==null?'':oInc.MCFD_Rental_Income_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Income_from_rental_monthly__c==0.00?'':String.ValueOf(oInc.MCFD_Income_from_rental_monthly__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Rental_Income_Amount__c==null?0.00:oInc.MCFD_Rental_Income_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Interest__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Interest and other investment income');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Interest_Amount__c==null?0.00:oInc.MCFD_Interest_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Interest_Freq__c==null?'':oInc.MCFD_Interest_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Interest_n_other_investment_monthly__c==0.00?'':String.ValueOf(oInc.MCFD_Interest_n_other_investment_monthly__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Interest_Amount__c==null?0.00:oInc.MCFD_Interest_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Other_Income__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Other Income');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Other_Income_Amount__c==null?0.00:oInc.MCFD_Other_Income_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Other_Income_Freq__c==null?'':oInc.MCFD_Other_Income_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_Other_income_monthly__c==0.00?'':String.ValueOf(oInc.MCFD_Other_income_monthly__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Other_Income_Amount__c==null?0.00:oInc.MCFD_Other_Income_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Spousal_Support__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Spousal support');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Spousal_Support_Amount__c==null?0.00:oInc.MCFD_Spousal_Support_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Spousal_Support_Freq__c==null?'':oInc.MCFD_Spousal_Support_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_spousal_support_monthly_income__c==0.00?'':String.ValueOf(oInc.MCFD_spousal_support_monthly_income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Spousal_Support_Amount__c==null?0.00:oInc.MCFD_Spousal_Support_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Tips__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Tips');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Tips_Amount__c==null?0.00:oInc.MCFD_Tips_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Tips_Freq__c==null?'':oInc.MCFD_Tips_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_tips_monthly_income__c==0.00?'':String.ValueOf(oInc.MCFD_tips_monthly_income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Tips_Amount__c==null?0.00:oInc.MCFD_Tips_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_Training_Living_Allowance__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('Training or living allowance');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Training_Living_Allowance_Amount__c==null?0.00:oInc.MCFD_Training_Living_Allowance_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_Training_Living_Allowance_Freq__c==null?'':oInc.MCFD_Training_Living_Allowance_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters('');w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_training_or_living_monthly_income__c==0.00?'':String.ValueOf(oInc.MCFD_training_or_living_monthly_income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_Training_Living_Allowance_Amount__c==null?0.00:oInc.MCFD_Training_Living_Allowance_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      }
                      if(oInc.MCFD_WorkSafeBC__c == 'Yes')
                      {
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'IncomeType',null);w.writeCharacters('WorksafeBC');w.writeEndElement();
                          w.writeStartElement(null,'Amount',null);w.writeCharacters(String.ValueOf(oInc.MCFD_WorkSafeBC_Amount__c==null?0.00:oInc.MCFD_WorkSafeBC_Amount__c));w.writeEndElement();
                          w.writeStartElement(null,'Frequency',null);w.writeCharacters(oInc.MCFD_WorkSafeBC_Freq__c==null?'':oInc.MCFD_WorkSafeBC_Freq__c);w.writeEndElement();
                          w.writeStartElement(null,'StartDate',null);w.writeCharacters(MCFD_SubmitApplicationXMLGenerator.getDateString(oInc.MCFD_WorkSafeBC_Start__c));w.writeEndElement();
                          w.writeStartElement(null,'EndDate',null);w.writeCharacters('');w.writeEndElement();
                          //w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(oInc.MCFD_WorkSafeBC_Monthly_Income__c==0.00?'':String.ValueOf(oInc.MCFD_WorkSafeBC_Monthly_Income__c) );w.writeEndElement();
                          w.writeStartElement(null,'netIncomePerMonthFormula',null);w.writeCharacters(String.ValueOf(oInc.MCFD_WorkSafeBC_Amount__c==null?0.00:oInc.MCFD_WorkSafeBC_Amount__c));w.writeEndElement();
                          w.writeEndElement();
                      } 
                      if(oInc.MCFD_No_Income_Description__c != Null){
                          
                          w.writeStartElement(null,'Income',null);
                          w.writeStartElement(null,'Field2',null);w.writeCharacters(getValue(oInc.MCFD_No_Income_Description__c));w.writeEndElement();                           
                          w.writeEndElement();
                      }
  }
                  
              }
              
          w.writeEndElement();
          w.writeEndElement();
          
          w.writeStartElement(null,'ConsentPages',null);
             /* if(lstIncome.size() > 0)
              {
                  for(Income__c oInc : lstIncome)
                  {
                      
                      if(oInc.MCFD_No_Income_Description__c != Null){
                          w.writeStartElement(null,'NoIncomeConsent',null);
                          w.writeStartElement(null,'Role',null);w.writeCharacters(getValue(mapIncRole.get(oInc.Id)));w.writeEndElement();
                          w.writeStartElement(null,'Field2',null);w.writeCharacters(getValue(oInc.MCFD_No_Income_Description__c));w.writeEndElement();                           
                          w.writeEndElement();
                      }
                  }
              } */
              
              w.writeStartElement(null,'Comments',null);w.writeCharacters('');w.writeEndElement();      // Null or blank value according to Mapping document                      
              
              //-----------Consent to Share Information With Your Spouse - Start---------//               
              if(oCurrReq.MCFD_consent_share_info_with_sp_signed__c != Null){
                  w.writeStartElement(null,'Consent2',null);w.writeCharacters(String.valueOf(oCurrReq.MCFD_consent_to_share_info_with_spouse__c));w.writeEndElement();                           
                  w.writeStartElement(null,'Consent2Date',null);w.writeCharacters(getValue(oCurrReq.MCFD_consent_share_info_with_sp_signed__c));w.writeEndElement();                           
              }
              //-----------Consent to Share Information With Your Spouse - End---------//
              
              //----------- Spousal Consent - Start---------//                
              if(oCurrReq.MCFD_spousal_consent_signed_date__c != Null){
                  w.writeStartElement(null,'Consent3',null);w.writeCharacters(String.valueOf(oCurrReq.MCFD_spousal_consent_check1__c));w.writeEndElement();                           
                  w.writeStartElement(null,'Consent3Date',null);w.writeCharacters(getValue(oCurrReq.MCFD_spousal_consent_signed_date__c));w.writeEndElement();                           
                  w.writeStartElement(null,'Field1',null);w.writeCharacters(String.valueOf(oCurrReq.MCFD_spousal_consent_check2__c));w.writeEndElement();                           
              }
              //----------- Spousal Consent - End---------//
              
              //----------- Declaration and Consent - Start---------//                
              //----------- Declaration and Consent - Start---------//  Vai - Bug fix 3866 changed the date field in the element mapping below              
              if(oCurrReq.MCFD_declaration_and_consent_signed_date__c != Null){
                  w.writeStartElement(null,'Consent1',null);w.writeCharacters(String.valueOf(oCurrReq.MCFD_DeclarationAndConsent__c));w.writeEndElement();                           
                  w.writeStartElement(null,'Consent1Date',null);w.writeCharacters(getValue(oCurrReq.MCFD_declaration_and_consent_signed_date__c));w.writeEndElement();                                            
              }
              //----------- Declaration and Consent - End---------//
              
          w.writeEndElement();    // End of ConsentPages
          string renewalCraConsentDate;
          string renewalSpouseCraConsentDate;
          string consentRenewalForICM = 'false'; 
          w.writeStartElement(null,'CRAConsentPages',null);
          
            w.writeStartElement(null,'ApplicantCRAConsent',null);
            
            // Checking for the renwal, CRA should be always null
              // Checking for the renwal, CRA should be always null
              if(oCurrReq.RecordType.Name == 'Renewal'){ 
              if(ContactDetails[0].Contact.MCFD_HasActiveCRAConsent__c == true) {
                w.writeCharacters(consentRenewalForICM);
              } else {
                if(oCurrReq.MCFD_CRA_Consent__c == true) {
                  w.writeCharacters(String.valueOf(oCurrReq.MCFD_CRA_Consent__c));
                          renewalCraConsentDate = getValue(oCurrReq.MCFD_CRA_Consent_Signed_Date__c) ;
                } else {
                w.writeCharacters(consentRenewalForICM);
              }
              
              }

              
            } else {
              w.writeCharacters(String.valueOf(oCurrReq.MCFD_CRA_Consent__c));
            }
            
            w.writeEndElement();            	
            
            w.writeStartElement(null,'ApplicantFirstName',null);
              w.writeCharacters(oCurrCon.FirstName==null?'':oCurrCon.FirstName);
              w.writeEndElement();
                  
              w.writeStartElement(null,'ApplicantLastName',null);
              w.writeCharacters(oCurrCon.LastName==null?'':oCurrCon.LastName);
              w.writeEndElement();
              
              
                w.writeStartElement(null,'ApplicantCRAConsentDate',null);
            if(oCurrReq.RecordType.Name == 'Renewal'){ 
                  if(string.isNotBlank(renewalCraConsentDate)) {
                      w.writeCharacters(renewalCraConsentDate);
                  } else {
                       w.writeCharacters('');
                  }
          
              } else {
                if(oCurrReq.MCFD_CRA_Consent_Signed_Date__c != Null){
                    w.writeCharacters(getValue(oCurrReq.MCFD_CRA_Consent_Signed_Date__c));
                }    
                  
              }
               /*else if(ContactDetails[0].Contact.ICM_StartDate__c != null) {
                  w.writeCharacters(getValue(ContactDetails[0].Contact.ICM_StartDate__c));
              }*/
            
              w.writeEndElement();  
                
              
              w.writeStartElement(null,'ApplicantBCeID',null);w.writeCharacters(ContactDetails[0].Contact.MCFD_BCeID__c==null?'':ContactDetails[0].Contact.MCFD_BCeID__c);w.writeEndElement();
              
              w.writeStartElement(null,'SpouseCRAConsent',null);
            
              // Checking for the renwal, CRA should be always null
              if(oCurrReq.RecordType.Name == 'Renewal'){ 
              if(SpouseDetails.size()>0) {
              if(SpouseDetails[0].Contact.MCFD_HasActiveCRAConsent__c == true) {
                          w.writeCharacters(consentRenewalForICM);
              } else {
                          if(oCurrReq.MCFD_Spousal_CRA_Consent__c == true) {
                              w.writeCharacters(String.valueOf(oCurrReq.MCFD_Spousal_CRA_Consent__c));
                              renewalSpouseCraConsentDate = getValue(oCurrReq.MCFD_Spouse_CRA_Consent_Signed_Date__c);
                          } else {
                w.writeCharacters(consentRenewalForICM);
              }
                          
                      }
                  } else {
                      w.writeCharacters(consentRenewalForICM);
                  }

            } else {
              w.writeCharacters(String.valueOf(oCurrReq.MCFD_Spousal_CRA_Consent__c));
            }
            
              w.writeEndElement();            	
            
            // Added by Abhi to make sure the spouse contact is not null 
              //if(SpouseDetails[0].Contact != null) {
      if(SpouseDetails.size()>0) {

                  w.writeStartElement(null,'SpouseFirstName',null);
                  w.writeCharacters(SpouseDetails[0].Contact.FirstName);
                  w.writeEndElement();
                      
                  w.writeStartElement(null,'SpouseLastName',null);
                  w.writeCharacters(SpouseDetails[0].Contact.LastName);
                  w.writeEndElement();
                  
                  w.writeStartElement(null,'SpouseBCeID',null);w.writeCharacters(SpouseDetails[0].Contact.MCFD_BCeID__c);w.writeEndElement();
              
                 
              } else {
                  w.writeStartElement(null,'SpouseFirstName',null);
                  w.writeCharacters('');
                  w.writeEndElement();
                      
                  w.writeStartElement(null,'SpouseLastName',null);
                  w.writeCharacters('');
                  w.writeEndElement();
                  
                  w.writeStartElement(null,'SpouseBCeID',null);w.writeCharacters('');w.writeEndElement();
              
              
              }
              
              w.writeStartElement(null,'SpouseCRAConsentDate',null);
          
              if(oCurrReq.RecordType.Name == 'Renewal'){ 
                  if(string.isNotBlank(renewalSpouseCraConsentDate)) {
                      w.writeCharacters(renewalSpouseCraConsentDate);
                  } else {
                       w.writeCharacters('');
                  }
          
              } else {
                  
              if(oCurrReq.MCFD_Spouse_CRA_Consent_Signed_Date__c != Null){
                     
                      w.writeCharacters(getValue(oCurrReq.MCFD_Spouse_CRA_Consent_Signed_Date__c));
                                              
                  //w.writeStartElement(null,'Consent1Date',null);w.writeCharacters(getValue(oCurrReq.MCFD_declaration_and_consent_signed_date__c));w.writeEndElement();                                            
              }
              
              }
              
               /*else if(SpouseDetails.size()>0) {
                  if(SpouseDetails[0].Contact.ICM_StartDate__c != null) {
                      w.writeCharacters(getValue(SpouseDetails[0].Contact.ICM_StartDate__c));
                  }
              }*/
            w.writeEndElement();  
              
              
          
          w.writeEndElement();    // End of CRAConsentPages
          w.writeEndElement();    // End of Payload
          w.writeEndElement();    // End of Document
          w.writeEndDocument();
          string xml = w.getXmlString();
          System.debug(xml);
          w.close();
          return xml;
          
                                
      }
      
      return 'There seems to be some error, please check';
                          
      
  }
  
  // PDAVE : Added error handling logic (CCS Application and Renewal) as part of US 4589
  @AuraEnabled
  public static String SubmitCSSApplication(String sRequestId) 
  {
      //String JSONString = '{"operation":"update"}';
      
      Request__c oReq = [Select Id, RecordType.Name, 
                                CreatedById, CreatedBy.Name
                          from Request__c where id=: sRequestId];
      if(oReq != null)
      {
          HttpRequest req = new HttpRequest();
          req.setEndpoint('callout:CallWMToSubmitRTP');
          //req.setTimeout(60000);
          req.setTimeout(Integer.valueOf(System.Label.Timeout_New_Renewal_CCS_Submission));
          req.setMethod('POST');
          req.setHeader('Connection','keep-alive');
          req.setHeader('Content-Type', 'application/json');
            
          String xmlString = MCFD_SubmitApplicationXMLGenerator.createSubmitXML(oReq); 
          
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject(); 
          gen.writeStringField('UpdateRequest', xmlString);
          gen.writeEndObject();
          req.setBody(gen.getAsString());
                  
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
                  if(System.Label.ICM_Dummy_Error_Response_Mode_CCS_App.toUpperCase() == 'ON'){
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
                      
                      if(oReq.RecordType.Name == 'Application'){
                           MCFD_Logger.log_integ_err_for_request('Shell SR Creation - CCS Application', 
                                                             MCFD_Logger.error, 
                                                             'MCFD_CallICMForAutismDetails', 
                                                             'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                             oReq.Id);
                      }else if(oReq.RecordType.Name == 'Renewal'){
                          MCFD_Logger.log_integ_err_for_request('Submission - CCS Renewal', 
                                                             MCFD_Logger.error, 
                                                             'MCFD_CallICMForAutismDetails', 
                                                             'Invalid/Error Status Code - '+strErrorStatus+'\n'+'Invalid/Error Response Body - '+strErrorMsg,
                                                             oReq.Id);

                      }
                      oReq.MCFD_Status__c='Submission Error'; 
                      update oReq;
                  }else{
                  // ----------------------------------------------- //
                  // ------- Handle success response --------------- //
                  // ----------------------------------------------- //
                      oReq.MCFD_Status__c='Submitted'; 
                      update oReq;
               //       MCFD_Logger.log_integ_err_for_request('Submission - CCS Application', MCFD_Logger.Info,'MCFD_SubmitApplicationXMLGenerator Request',xmlString,oReq.Id);
               //       MCFD_Logger.log_integ_err_for_request('Submission - CCS Application', MCFD_Logger.Info,'MCFD_SubmitApplicationXMLGenerator Response',returnJSON,oReq.Id);              
                  }
                 
              }
          } 
          catch(System.CalloutException e) {
              system.debug('Came to Exception');
              if(oReq.RecordType.Name == 'Application'){
                  MCFD_Logger.log_integ_err_for_request('Submission - CCS Application', 
                                                     MCFD_Logger.ERROR, 
                                                     'MCFD_SubmitApplicationXMLGenerator' , 
                                                     'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                     oReq.Id);
              }else if(oReq.RecordType.Name == 'Renewal'){
                  MCFD_Logger.log_integ_err_for_request('Submission - CCS Renewal', 
                                                    MCFD_Logger.ERROR, 
                                                    'MCFD_SubmitApplicationXMLGenerator' , 
                                                    'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString(),
                                                    oReq.Id);
              }
              oReq.MCFD_Status__c='Submission Error';
              update oReq;                
          }     
          return returnJSON;
      }
      return ''; 
      
  }
  
  public static String getDateString(Date oDateObject)
  {
      if(oDateObject == null)
      {
          return '';
      }
      else
      {
          return String.ValueOf(oDateObject);
      }
  }
  
  public static String getValue(String value){
      if(value == null)
          return '';
      else
          return value;
  }
  
  //Owner: Pavan Dave
  public static Map<Id, String> calculateRFCRole(List<Reason_For_Care__c> lstRFC, Map<Id, String> mapConRealtion){
      Map<Id, String> returnMapRfcRole = new Map<Id, String>();
      for(Reason_For_Care__c item: lstRFC){
          if(item.Contact__c != Null){
              returnMapRfcRole.put(item.Id, mapConRealtion.get(item.Contact__c));
          }
      }
      
      return returnMapRfcRole;
  }
  
  //Owner: Pavan Dave
  public static Map<Id, String> calculateIncRole(List<Income__c> lstInc, Map<Id, String> mapConRealtion){
      Map<Id, String> returnMapIncRole = new Map<Id, String>();
      for(Income__c item: lstInc){
          if(item.Contact__c != Null){
              returnMapIncRole.put(item.Id, mapConRealtion.get(item.Contact__c));
          }
      }
      
      return returnMapIncRole;
  }
  
  //Owner: Pavan Dave
  public static Map<Id, List<Reason_For_Care__c>> calculate_Employment_Employer(List<Reason_For_Care__c> listOfRFC){
      Map<Id, List<Reason_For_Care__c>> map_Emp_Emplr = new Map<Id, List<Reason_For_Care__c>>();
      Reason_For_Care__c employmentRFC; 
      
      for(Reason_For_Care__c item: listOfRFC){
          if(item.MCFD_Rsn_For_Care_Type__c == 'Employment'){
              employmentRFC = new Reason_For_Care__c();
              employmentRFC = item;
          }
      }
      
      if(employmentRFC != Null){
      List<Reason_For_Care__c> lstEmplr = new List<Reason_For_Care__c>();
          for(Reason_For_Care__c item: listOfRFC){
              if(item.MCFD_Rsn_For_Care_Type__c == 'Employer'){
                  lstEmplr.add(item);
              }
          }
          map_Emp_Emplr.put(employmentRFC.Id, lstEmplr);
      }
      
      return map_Emp_Emplr;
  }
  
  //Owner: Pavan Dave
  public static Map<Id, List<Reason_For_Care__c>> calculate_SelfEmployment_Business(List<Reason_For_Care__c> listOfRFC){
      Map<Id, List<Reason_For_Care__c>> map_SelfEmp_Business = new Map<Id, List<Reason_For_Care__c>>();
      Reason_For_Care__c employmentRFC; 
      
      for(Reason_For_Care__c item: listOfRFC){
          if(item.MCFD_Rsn_For_Care_Type__c == 'Self Employment'){
              employmentRFC = new Reason_For_Care__c();
              employmentRFC = item;
          }
      }
      
      if(employmentRFC != Null){
      List<Reason_For_Care__c> lstEmplr = new List<Reason_For_Care__c>();
          for(Reason_For_Care__c item: listOfRFC){
              if(item.MCFD_Rsn_For_Care_Type__c == 'Business'){
                  lstEmplr.add(item);
              }
          }
          map_SelfEmp_Business.put(employmentRFC.Id, lstEmplr);
      }
      
      return map_SelfEmp_Business;
  }
}