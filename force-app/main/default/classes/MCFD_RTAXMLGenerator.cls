/**************************************************************************************
Function            : Contains Parsing SiteMinder SAML Response & Redirection Logic 

Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Saxena, Abhishek M          10 MAY 2017             Original Version
* PDAVE                       15 MAY 2017             Refactored coded & added method for inserting Sub Request, Sub Sub Reuest
* PDAVE                       27 MAY 2017             Optimized the code (SOQL outside for loop) and bug fix 4059  
* PDAVE                       27 SEP 2017             Added error handling logic (RTA) as part of US 4589
*************************************************************************************/

public with sharing class MCFD_RTAXMLGenerator{


    public static String createRTAXML(Request__c request){   
    
        Request__c oCurrReq = [Select id, ICM_SR_Number__c, MCFD_Advise_Amendment_required__c, MCFD_Remaining_Fund__c,  MCFD_Authorized_Amount__c, 
                                      MCFD_First_Name__c, MCFD_Middle_Name__c, MCFD_Last_Name__c, MCFD_ChildFirstName__c, MCFD_ChildMiddleName__c,
                                      MCFD_ChildLastName__c, MCFD_ChildBirthDate__c
                                  from Request__c where Id =: request.id];
                        
        //String BCeId = System.Label.Dummy_BCeID;
        
        Id requestCreatorUserId = request.CreatedById;
        String requestCreatetorName = request.CreatedBy.Name;
            
        List<User> requestCreatorUser = [SELECT ContactId, Contact.Name, Contact.MCFD_BCeID__c, Contact.MCFD_GUID__c,
                                          Contact.FirstName, Contact.LastName, Contact.MiddleName, Contact.AssistantPhone,
                                          Contact.HomePhone, Contact.MobilePhone, Contact.Phone,
                                          Contact.MCFD_Primary_Phone_Number_Type__c, Contact.MCFD_Secondary_Phone_Number_Type__c,
                                          FirstName
                                   FROM user 
                                   WHERE id =:requestCreatorUserId limit 1];
        
        //if(BCeId != null)
            //oCurrCon= [Select id, FirstName, LastName, MiddleName, AssistantPhone,HomePhone,MobilePhone,Phone,MCFD_BCeID__c, MCFD_Primary_Phone_Number_Type__c, MCFD_Secondary_Phone_Number_Type__c from Contact where MCFD_BCeID__c =: BCeId Limit 1 ];
                
        List<MCFD_Contact_Address__c> lstOfContactAddress = new List<MCFD_Contact_Address__c>([Select id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, MCFD_Address_Type__c,
                                   City__c, MCFD_Contact__c, Country__c, Postal_Code__c, Province__c from MCFD_Contact_Address__c
                                   where MCFD_Contact__c =: requestCreatorUser[0].ContactId AND MCFD_Address_Type__c='Mailing Address' Limit 1 ]);
        
        
        List<MCFD_Relationship__c> reltnshipList = new List<MCFD_Relationship__c>();
        
        if(oCurrReq != null){
        reltnshipList = [select id, MCFD_Child_Contact__c from MCFD_Relationship__c where MCFD_Request__c =: oCurrReq.id ]; // and MCFD_Parent_Contact__c = oCurrCon.id ];
        }
        list<Id> contactIds = new List<Id>();
        
        if(reltnshipList != null){
        for(MCFD_Relationship__c rel: reltnshipList ){
        contactIds.add(rel.MCFD_Child_Contact__c);
        }
        }
        
        list<Contact> childcon = new list<Contact>();
        if(contactIds != null){
        childcon = [select id, FirstName, LastName, MiddleName, BirthDate from contact where id in : contactIds ];
        }
        
        List<Sub_Request__c> serviceOrderList = new List<Sub_Request__c> ();
        List<Sub_Request__c> serviceOrderList_Decrease = new List<Sub_Request__c> ();
        List<Sub_Request__c> serviceOrderList_Increase_and_NoChange = new List<Sub_Request__c> ();
        
        if(oCurrReq.id != null){
            //serviceOrderList = [select id,  MCFD_Service_Provider_Name__c , MCFD_Order_Number__c,MCFD_Current_Authorization__c, MCFD_New_Authorization__c, MCFD_Amount_Changed__c, 
            //                          MCFD_Start_Date__c, MCFD_Revised_Start_Date__c, MCFD_End_Date__c, MCFD_Revised_End_Date__c from Sub_Request__c where MCFD_Request__c =: oCurrReq.id ];
            
            // Orders with decreases (largest to smallest) like order would be -500, -400, -300
            serviceOrderList_Decrease = [select id,  MCFD_Service_Provider_Name__c , MCFD_Order_Number__c,MCFD_Current_Authorization__c, 
                                                MCFD_New_Authorization__c, MCFD_Amount_Changed__c, MCFD_Start_Date__c, 
                                                MCFD_Revised_Start_Date__c, MCFD_End_Date__c, MCFD_Revised_End_Date__c 
                                         from Sub_Request__c 
                                         where (MCFD_Request__c =: oCurrReq.id
                                            AND MCFD_Amount_Changed__c < 0
                                            AND MCFD_Amount_Changed__c <> Null)                                  
                                         ORDER BY MCFD_Amount_Changed__c ASC];
            
            // Orders with increases (largest to smallest) like order would be 600, 400, 200
            // Orders with no change like  all values null, null, null
            serviceOrderList_Increase_and_NoChange = [select id,  MCFD_Service_Provider_Name__c , MCFD_Order_Number__c,MCFD_Current_Authorization__c, 
                                                MCFD_New_Authorization__c, MCFD_Amount_Changed__c, MCFD_Start_Date__c, 
                                                MCFD_Revised_Start_Date__c, MCFD_End_Date__c, MCFD_Revised_End_Date__c 
                                         from Sub_Request__c 
                                         where (MCFD_Request__c =: oCurrReq.id
                                            AND (MCFD_Amount_Changed__c > 0 OR MCFD_Amount_Changed__c = Null))                                   
                                         ORDER BY MCFD_Amount_Changed__c DESC
                                         NULLS LAST];
                                         
            if(!serviceOrderList_Decrease.isEmpty()){
                serviceOrderList.addAll(serviceOrderList_Decrease);
            }
            if(!serviceOrderList_Increase_and_NoChange.isEmpty()){
                serviceOrderList.addAll(serviceOrderList_Increase_and_NoChange);
            }
        }
        
                                     
        list<Id> subreqIds = new List<Id>();

        if(serviceOrderList != null){
        for(Sub_Request__c so: serviceOrderList ){
        subreqIds.add(so.id);
        }
        }
        List<Sub_Sub_Request__c> solineList = new List<Sub_Sub_Request__c> ();
        
        if(subreqIds != null){
        solineList = [select id, MCFD_Is_Newly_Added__c, MCFD_Original_Order_Line__c, MCFD_Original_Product__c, MCFD_Original_RASP__c, MCFD_Original_Rate__c,
                        MCFD_Original_Unit__c, MCFD_Revised_Order_Line__c, MCFD_Revised_Product__c, MCFD_Revised_RASP__c, MCFD_Revised_Rate__c, MCFD_Revised_Unit__c, Sub_Request__c from Sub_Sub_Request__c where Sub_Request__c in: subreqIds ];
        }
        map<Id,List<Sub_Sub_Request__c>> mapSubReqIdtoListSubSubReq = new map<Id,List<Sub_Sub_Request__c>>();
        
        Map<Id, List<Sub_Sub_Request__c>> mapSubReq_SubSubReq_adjust = new Map<Id, List<Sub_Sub_Request__c>>();
        Map<Id, List<Sub_Sub_Request__c>> mapSubReq_SubSubReq_new = new Map<Id, List<Sub_Sub_Request__c>>();
        
        List <Sub_Sub_Request__c> adjustedServiceOrderLineList = new List<Sub_Sub_Request__c> ([select id, MCFD_Is_Newly_Added__c, MCFD_Original_Order_Line__c, MCFD_Original_Product__c, MCFD_Original_RASP__c, MCFD_Original_Rate__c,
                                                    MCFD_Original_Unit__c, MCFD_Revised_Order_Line__c, MCFD_Revised_Product__c, MCFD_Revised_RASP__c, MCFD_Revised_Rate__c, MCFD_Revised_Unit__c, Sub_Request__c 
                                                from Sub_Sub_Request__c 
                                                where Sub_Request__c IN:subreqIds and MCFD_Is_Newly_Added__c = 'No'
                                                AND MCFD_Revised_Order_Line__c <> Null]);
        
        
        List<Sub_Sub_Request__c> addedServiceOrderLineList = new List<Sub_Sub_Request__c> ([select id, MCFD_Is_Newly_Added__c, MCFD_Original_Order_Line__c, MCFD_Original_Product__c, MCFD_Original_RASP__c, 
                                                                                                      MCFD_Original_Rate__c, MCFD_Original_Unit__c, Sub_Request__c 
                                                                                            from Sub_Sub_Request__c 
                                                                                            where Sub_Request__c IN:subreqIds and MCFD_Is_Newly_Added__c = 'Yes' ]);

        List<Sub_Sub_Request__c> tempSubSubRqList;        
        for(Sub_Sub_Request__c item: adjustedServiceOrderLineList){
            if(mapSubReq_SubSubReq_adjust.get(item.Sub_Request__c) != Null){
                tempSubSubRqList = mapSubReq_SubSubReq_adjust.get(item.Sub_Request__c);
                tempSubSubRqList.add(item);
                mapSubReq_SubSubReq_adjust.put(item.Sub_Request__c, tempSubSubRqList);
            }else{
                mapSubReq_SubSubReq_adjust.put(item.Sub_Request__c, new List<Sub_Sub_Request__c>{item});
            }
            
        }
    
        for(Sub_Sub_Request__c item: addedServiceOrderLineList){
            if(mapSubReq_SubSubReq_new.get(item.Sub_Request__c) != Null){
                tempSubSubRqList = mapSubReq_SubSubReq_new.get(item.Sub_Request__c);
                 tempSubSubRqList.add(item);
                 mapSubReq_SubSubReq_new.put(item.Sub_Request__c, tempSubSubRqList);
            }else{
                mapSubReq_SubSubReq_new.put(item.Sub_Request__c, new List<Sub_Sub_Request__c>{item});
            }
            
        }
        
        //system.debug('mapSubReq_SubSubReq_new--->'+mapSubReq_SubSubReq_new);
        //system.debug('mapSubReq_SubSubReq_adjust--->'+mapSubReq_SubSubReq_adjust);
        
            XmlStreamWriter w = new XmlStreamWriter();
            w.writeStartDocument(null,'1.0');
            w.writeStartElement(null,'Document',null);
            
             w.writeStartElement(null,'Header',null);
                w.writeStartElement(null,'TransactionName',null);
                w.writeCharacters('Autism Request Submit');
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
                 w.writeCharacters(getString(oCurrReq.ICM_SR_Number__c));
                 w.writeEndElement();
                            
                w.writeStartElement(null,'SRType',null);
                w.writeCharacters('Autism Funding Unit');
                w.writeEndElement();
                
                w.writeStartElement(null,'SRSubType',null);
                w.writeCharacters('Request to Amend');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Priority',null);
                w.writeCharacters('3-Standard');
                w.writeEndElement();
                 
                w.writeStartElement(null,'Status',null);
                w.writeCharacters('Open');
                w.writeEndElement();
                 
                w.writeStartElement(null,'AssignedTeam',null);
                w.writeCharacters('Admin Support');
                w.writeEndElement();
                 
                w.writeStartElement(null,'ContMethod',null);
                w.writeCharacters('Client Portal');
                w.writeEndElement();
                 
                w.writeStartElement(null,'SvcOff',null);
                w.writeCharacters('XWB - Child Care Programs and Services Branch');
                w.writeEndElement();
                
                 w.writeStartElement(null,'Organization',null);
                w.writeCharacters('MCFD');
                w.writeEndElement();
                
                 w.writeStartElement(null,'CreatedBy',null);
                w.writeCharacters(requestCreatorUser[0].FirstName);
                w.writeEndElement();
                
                 w.writeStartElement(null,'Created',null);
                w.writeCharacters(String.ValueOf(System.Today()));
                w.writeEndElement();
                
                w.writeStartElement(null,'Memo',null);
                w.writeCharacters(String.valueOf(requestCreatorUser[0].Contact.LastName) + ', ' + String.valueOf(requestCreatorUser[0].Contact.FirstName) + ', ' + String.valueOf(requestCreatorUser[0].Contact.MCFD_BCeID__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'RTA',null);   
                
                        w.writeStartElement(null,'RTAInfo',null); 
                        
                            w.writeStartElement(null,'AdvisedAmendmentRequired',null);
                            w.writeCharacters(getString(oCurrReq.MCFD_Advise_Amendment_required__c));
                            w.writeEndElement();
                            
                            
                            w.writeStartElement(null,'AuthorizedAmount',null);
                            w.writeCharacters(getCurrency(String.ValueOf(oCurrReq.MCFD_Authorized_Amount__c)));
                            w.writeEndElement();
                           
                            
                            w.writeStartElement(null,'RemainingFunds',null);
                            w.writeCharacters(getCurrency(String.ValueOf(oCurrReq.MCFD_Remaining_Fund__c)));
                            w.writeEndElement();
                        
                        w.writeEndElement(); // RTAinfo closed
                        
                w.writeStartElement(null,'ParentGuardian',null); 
                
                
                        w.writeStartElement(null,'ParentFirstName',null);
                        w.writeCharacters(getString(requestCreatorUser[0].Contact.FirstName));
                        w.writeEndElement();
                        
                        
                                      
                        w.writeStartElement(null,'ParentMiddleName',null);
                        w.writeCharacters(getString(requestCreatorUser[0].Contact.MiddleName));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'ParentLastName',null);
                        w.writeCharacters(getString(requestCreatorUser[0].Contact.LastName));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'ApplicantPrimaryPhoneNumber',null);
                        w.writeCharacters(getPhoneNumberString(requestCreatorUser[0].Contact.Phone));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'ApplicantPrimaryPhoneNumberType',null);
                        w.writeCharacters(getString(requestCreatorUser[0].Contact.MCFD_Primary_Phone_Number_Type__c));
                        w.writeEndElement();
                        
                               
                    
                        w.writeStartElement(null,'ApplicantSecondaryPhoneNumber',null);
                        w.writeCharacters(getPhoneNumberString(requestCreatorUser[0].Contact.MobilePhone) );
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'ApplicantSecondaryPhoneNumberType',null);
                        w.writeCharacters(getString(requestCreatorUser[0].Contact.MCFD_Secondary_Phone_Number_Type__c));
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'ApplicantMailingApartment',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].Address_Line_1__c : null));
                        w.writeEndElement();
                        
                         w.writeStartElement(null,'ApplicantMailingAddress1',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].Address_Line_2__c : null));
                        w.writeEndElement();
                        
                        
                         w.writeStartElement(null,'ApplicantMailingAddress2',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].Address_Line_3__c : null));
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'ApplicantMailingCity',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].City__c : null));                       
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'ApplicantMailingPostalCode',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].Postal_Code__c : null));                        
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'ApplicantMailingProvince',null);
                        w.writeCharacters(getString(lstOfContactAddress.size() > 0 ? lstOfContactAddress[0].Province__c : null));                           
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'ApplicantMailingMAKID',null);
                        w.writeCharacters('');
                        w.writeEndElement();
                
                w.writeEndElement(); // parent guardians
                
                /*
                w.writeStartElement(null,'Child',null);
                
                for(Contact child : childcon){
                w.writeStartElement(null,'ChildFirstName',null);
                w.writeCharacters(getString(child.FirstName));
                w.writeEndElement();
                
                
                 w.writeStartElement(null,'ChildMiddleName',null);
                w.writeCharacters(getString(child.MiddleName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildLastName',null);
                w.writeCharacters(getString(child.LastName));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildDateofBirth',null);
                w.writeCharacters(getString(String.ValueOf(child.BirthDate)));
                w.writeEndElement();
                
                }
                
                w.writeEndElement(); // child closed
                */
                
                
                w.writeStartElement(null,'Child',null);
                
                
                w.writeStartElement(null,'ChildFirstName',null);
                w.writeCharacters(getString(oCurrReq.MCFD_ChildFirstName__c));
                w.writeEndElement();
                
                
                 w.writeStartElement(null,'ChildMiddleName',null);
                w.writeCharacters(getString(oCurrReq.MCFD_ChildMiddleName__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildLastName',null);
                w.writeCharacters(getString(oCurrReq.MCFD_ChildLastName__c));
                w.writeEndElement();
                
                w.writeStartElement(null,'ChildDateofBirth',null);
                w.writeCharacters(getString(oCurrReq.MCFD_ChildBirthDate__c != Null ? String.valueOf(oCurrReq.MCFD_ChildBirthDate__c) : null));                
                w.writeEndElement();
                
                               
                w.writeEndElement();
                
                
                
                
                boolean criteria = false;
                for(Sub_Request__c so : serviceOrderList){
                criteria = (so.MCFD_Revised_End_Date__c != Null || so.MCFD_Revised_Start_Date__c != Null || so.MCFD_New_Authorization__c != Null)
                            || (mapSubReq_SubSubReq_adjust.containsKey(so.id) && mapSubReq_SubSubReq_adjust.get(so.id) != Null)
                            || (mapSubReq_SubSubReq_new.containsKey(so.id) && mapSubReq_SubSubReq_new.get(so.id) != Null);
                
                if(criteria){
                     w.writeStartElement(null,'ServiceAmendmentList',null);
                
                
                
                w.writeStartElement(null,'ProviderInformation',null);
                
                
                        w.writeStartElement(null,'ServiceProvider',null);
                        w.writeCharacters(getString(so.MCFD_Service_Provider_Name__c));
                        w.writeEndElement();
                        
                        
                         w.writeStartElement(null,'OrderNumber',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_Order_Number__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'CurrentAuthorization',null);
                        w.writeCharacters(getCurrency(String.ValueOf(so.MCFD_Current_Authorization__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'NewAuthorization',null);
                        w.writeCharacters(getCurrency(String.ValueOf(so.MCFD_New_Authorization__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'AmountChanged',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_Amount_Changed__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'StartDate',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_Start_Date__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'StartDateEdit',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_Revised_Start_Date__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'EndDate',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_End_Date__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'EndDateEdit',null);
                        w.writeCharacters(getString(String.ValueOf(so.MCFD_Revised_End_Date__c)));
                        w.writeEndElement();
                
                            
                
                w.writeEndElement();
                
                               
                
                // List<Sub_Sub_Request__c> adjustedServiceOrderLineList = new List<Sub_Sub_Request__c> ();
        
                // adjustedServiceOrderLineList = [select id, MCFD_Is_Newly_Added__c, MCFD_Original_Order_Line__c, MCFD_Original_Product__c, MCFD_Original_RASP__c, MCFD_Original_Rate__c,
                                                    // MCFD_Original_Unit__c, MCFD_Revised_Order_Line__c, MCFD_Revised_Product__c, MCFD_Revised_RASP__c, MCFD_Revised_Rate__c, MCFD_Revised_Unit__c, Sub_Request__c 
                                                // from Sub_Sub_Request__c 
                                                // where Sub_Request__c =:so.id and MCFD_Is_Newly_Added__c = 'No'
                                                // AND MCFD_Revised_Order_Line__c <> Null];
                
                w.writeStartElement(null,'AdjustedOrderLinesList',null);
                
                
                //for(Sub_Sub_Request__c soline : adjustedServiceOrderLineList){
                if(mapSubReq_SubSubReq_adjust.get(so.id) != Null){
                
                    for(Sub_Sub_Request__c soline : mapSubReq_SubSubReq_adjust.get(so.id)){
                        
                    w.writeStartElement(null,'AdjustedOrderLines',null);
                    
                    
                    w.writeStartElement(null,'OriginalOrderLine',null);
                    w.writeCharacters(getString(soline.MCFD_Original_Order_Line__c));
                    w.writeEndElement();
                    
                    
                    w.writeStartElement(null,'OriginalProduct',null);
                    w.writeCharacters(getString(soline.MCFD_Original_Product__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'OriginalRate',null);
                    w.writeCharacters(getCurrency(String.ValueOf(soline.MCFD_Original_Rate__c)));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'OriginalRateUnit',null);
                    w.writeCharacters(getString(soline.MCFD_Original_Unit__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'OriginalRASP',null);
                    w.writeCharacters(getString(soline.MCFD_Original_RASP__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'RevisedOrderLine',null);
                    w.writeCharacters(getString(soline.MCFD_Revised_Order_Line__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'RevisedProduct',null);
                    w.writeCharacters(getString(soline.MCFD_Revised_Product__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'RevisedRate',null);
                    w.writeCharacters(getCurrency(String.ValueOf(soline.MCFD_Revised_Rate__c)));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'RevisedUnit',null);
                    w.writeCharacters(getString(soline.MCFD_Revised_Unit__c));
                    w.writeEndElement();
                    
                    w.writeStartElement(null,'RevisedRASP',null);
                    w.writeCharacters(getString(soline.MCFD_Revised_RASP__c));
                    w.writeEndElement();

                    w.writeEndElement();
                    
                    }   
                }
                
                w.writeEndElement(); // AdjustedOrderLinesList closed
                
                w.writeStartElement(null,'AddedOrderLinesList',null);
                
                
                // List<Sub_Sub_Request__c> addedServiceOrderLineList = new List<Sub_Sub_Request__c> ();
        
                // addedServiceOrderLineList = [select id, MCFD_Is_Newly_Added__c, MCFD_Original_Order_Line__c, MCFD_Original_Product__c, MCFD_Original_RASP__c, MCFD_Original_Rate__c,
                        // MCFD_Original_Unit__c, Sub_Request__c from Sub_Sub_Request__c where Sub_Request__c =:so.id and MCFD_Is_Newly_Added__c = 'Yes' ];
                
                
                //for(Sub_Sub_Request__c soline : addedServiceOrderLineList){
                if(mapSubReq_SubSubReq_new.get(so.id) != Null){
                    for(Sub_Sub_Request__c soline : mapSubReq_SubSubReq_new.get(so.id)){
                    
                    w.writeStartElement(null,'AddedOrderLines',null);
                    
                    
                        w.writeStartElement(null,'AddedProduct',null);
                        w.writeCharacters(getString(soline.MCFD_Original_Product__c));
                        w.writeEndElement();
                        
                        
                        w.writeStartElement(null,'AddedRate',null);
                        w.writeCharacters(getCurrency(String.ValueOf(soline.MCFD_Original_Rate__c)));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'AddedUnit',null);
                        w.writeCharacters(getString(soline.MCFD_Original_Unit__c));
                        w.writeEndElement();
                        
                        w.writeStartElement(null,'AddedRASP',null);
                        w.writeCharacters(getString(soline.MCFD_Original_RASP__c));
                        w.writeEndElement();
                    
                    w.writeEndElement();
                    
                    }   
                }
                
                w.writeEndElement(); // addedServiceOrderLineList closed
                 w.writeEndElement(); // serviceamendmentlist closed
               }
            }
                                                        
             w.writeEndElement();    // RTA info closed
             
             w.writeEndElement(); // Payload closed
             
            w.writeEndDocument();
            string xml = w.getXmlString();
            w.close();
            return xml;
            
    }
    
     
    // PDAVE: Added error handling logic (RTA) as part of US 4589 
    @AuraEnabled
    public static String SubmitRTA(String sRequestId) 
    {
                
        Request__c oReq = [Select Id, RecordType.Name, MCFD_Status__c,
                                  CreatedById, CreatedBy.Name
                            from Request__c where id=: sRequestId];
        if(oReq != null)
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CallWMToSubmitRTP');
            req.setMethod('POST');
            req.setHeader('Connection','keep-alive');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(Integer.valueOf(System.Label.Timeout_RTA_Submission));  
            String xmlString = MCFD_RTAXMLGenerator.createRTAXML(oReq); 
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('UpdateRequest', xmlString);
            gen.writeEndObject();
            req.setBody(gen.getAsString());
                    
            System.debug('>>>> req.getBody(): ' + req.getBody()); 
            //System.debug('>>>> req: ' + req); 
            Http http = new Http();
            String returnJSON = '';
            try {
                HTTPResponse res = http.send(req);
                returnJSON = res.getBody();
                //System.debug('>>>> Response'+ res.toString());
                //System.debug('>>>> Status:'+ res.getStatus());
                //System.debug('>>>> Status Code:'+ res.getStatusCode());
                //System.debug('>>>> returnJSON:'+ returnJSON);
                 if(res.getStatusCode()==200){
                     
                        String responseBody;
                        if(System.Label.ICM_Dummy_Error_Response_Mode_RTA_Submission.toUpperCase() == 'ON'){
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
                            system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                            
                            if(oReq.RecordType.Name == 'RTA'){
                                MCFD_Logger.log_integ_err_for_request('Submission - RTA', 
                                                                   MCFD_Logger.error, 
                                                                   'MCFD_RTAXMLGenerator', 
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
                        }
                                  
                    }else{
                        oReq.MCFD_Status__c = 'Submission Error';        // Pavan: Bug fix 3918
                        update oReq;   
                        system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                            
                        if(oReq.RecordType.Name == 'RTA'){
                            MCFD_Logger.log_integ_err_for_request('Submission - RTA', 
                                                               MCFD_Logger.error, 
                                                               'MCFD_RTAXMLGenerator', 
                                                               'Invalid/Error Status Code - '+res.getStatusCode()+'\n'+'Invalid/Error Response Body - '+res.getBody(),
                                                               oReq.Id);
                        }
                        
                        oReq.MCFD_Status__c='Submission Error'; 
                        update oReq;
                    }                 
            } 
            catch(System.CalloutException e) {
                //system.debug('Came to Exception');
                //System.debug(e.getmessage());
                system.debug('oReq.RecordType.Name =' + oReq.RecordType.Name );
                
                if(oReq.RecordType.Name == 'RTA'){
                    MCFD_Logger.log_integ_err_for_request('Submission - RTA', 
                                                       MCFD_Logger.error, 
                                                       'MCFD_RTAXMLGenerator', 
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
    
        
    public static String getString(String val)
    {
        String returnVal;
        if(val == null)
        {
            returnVal = '';
        }
        else
        {
            returnVal = String.ValueOf(val);
        }
        return returnVal;
    }
    
    public static String getCurrency(String val)
    {
        String returnVal;
        if(val == null)
        {
            returnVal = '';
        }
        else
        {
            returnVal = '$'+String.ValueOf(val);
        }
        return returnVal;
    }
    
    public static String getPhoneNumberString(String val)
    {
        String returnVal;
        if(val == null)
        {
            returnVal = '';
        }
        else
        {   
            // Salesforce might or might not have format (250) 727-7528 but with space
            if(val.contains('(')){
                val = val.remove('(');
            }
            if(val.contains(')')){
                val = val.remove(')');
            }
            if(val.contains('-')){
                val = val.remove('-');
            }
            if(val.contains(' ')){
                val = val.remove(' ');
            }
            
            if(val.contains('+')){
                val = val.remove('+');
            }
            
            if(val.length()>=10){ 
            	val = val.substring(0,10);
            }
            
            returnVal = val;
            /*if(val.length()==10){                    
                // Bug 4058 - Desired format for Forms (250)727-7528 
                returnVal = '('+val.substring(0, 3)+')'+val.substring(3, 6)+'-'+val.substring(6);                
            }else{
                returnVal = val;
            }*/
        }
        return returnVal;
    }
    
    // Owner : Pavan Dave
    
    @AuraEnabled
    public static List<Sub_Request__c> createSubRequests_updateReq(List<Sub_Request__c> apexSubReqList, Id apexRequestId, 
                                                                   Double apexReqAuthAmt, Double apexReqRemFund, 
                                                                   String apexIsAdviseAmendReq, String apexChildFName,
                                                                   String apexChildMName,String apexChildLName,String apexChildDOB) {
      
     	//adding below if for remedy 672015 / vsts 7129                                                                  
      	//adding below if for remedy 672015 / vsts 7129                                                                  
      if(apexSubReqList.size() > 0)
      {
          for(integer i = 0; i < apexSubReqList.size(); i++)
          {
              if(apexSubReqList[i].MCFD_Current_Authorization__c != null)
              {
              apexSubReqList[i].MCFD_Current_Authorization__c = apexSubReqList[i].MCFD_Current_Authorization__c.setScale(2, RoundingMode.HALF_UP);        
              }
              if(apexSubReqList[i].MCFD_New_Authorization__c != null)
              {
              apexSubReqList[i].MCFD_New_Authorization__c = apexSubReqList[i].MCFD_New_Authorization__c.setScale(2, RoundingMode.HALF_UP);       
              }
              if(apexSubReqList[i].MCFD_Amount_Changed__c != null)
              {
              apexSubReqList[i].MCFD_Amount_Changed__c = apexSubReqList[i].MCFD_Amount_Changed__c.setScale(2, RoundingMode.HALF_UP);        
              }
          }
      }
      
          
      List<Sub_Request__c> insertSubReqList = new List<Sub_Request__c>();
      List<Sub_Request__c> updateSubReqList = new List<Sub_Request__c>();
      
      List<Request__c> lstReq = new List<Request__c>([SELECT id, MCFD_Authorized_Amount__c,MCFD_Remaining_Fund__c, MCFD_Advise_Amendment_required__c, 
                                                                MCFD_ChildBirthDate__c, MCFD_ChildFirstName__c, MCFD_ChildLastName__c,
                                                                MCFD_ChildMiddleName__c
                                                              FROM Request__c 
                                                              WHERE id =: apexRequestId]);
      lstReq.get(0).MCFD_Authorized_Amount__c = apexReqAuthAmt;
      lstReq.get(0).MCFD_Remaining_Fund__c = apexReqRemFund;      
      lstReq.get(0).MCFD_Advise_Amendment_required__c = apexIsAdviseAmendReq;     
      lstReq.get(0).MCFD_ChildFirstName__c = apexChildFName;  
      lstReq.get(0).MCFD_ChildMiddleName__c = apexChildMName;  
      lstReq.get(0).MCFD_ChildLastName__c = apexChildLName;  
      if(apexChildDOB != Null && apexChildDOB != ''){
          List<String> dateParts = new List<String>();
          dateParts = apexChildDOB.split('/');
            lstReq.get(0).MCFD_ChildBirthDate__c = date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)));  
      }
      
      update lstReq.get(0);
      for(Sub_Request__c item: apexSubReqList){
          if(item.Id != Null){
              updateSubReqList.add(item);
          }else{
              insertSubReqList.add(item);
          }
      }
      
      if(!updateSubReqList.isEmpty()){
          update updateSubReqList;
      }
      
      if(!insertSubReqList.isEmpty()){
          Id rtaRecordTypeId = [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Request__c' and Name='RTA Service Order' Limit 1].id; 
          for(Sub_Request__c item: insertSubReqList){
            item.RecordTypeId = rtaRecordTypeId ;        
          }       
          insert insertSubReqList;
      }
          
      return apexSubReqList;   
     
    }
    
     // Owner : Pavan Dave
    
    @AuraEnabled
    //public static List<Sub_Sub_Request__c> createSubSubRequests(List<Sub_Sub_Request__c> apexSubSubReqList, String apexStartDateEdit, Boolean apexIsStartDateChanged, String apexEndDateEdit, Boolean apexIsEndDateChanged) {
      public static List<Sub_Sub_Request__c> createSubSubRequests(List<Sub_Sub_Request__c> apexSubSubReqList, List<Sub_Request__c> apexSubReqList) {
      Id rtaRecordTypeId =  [SELECT Id, Name from RecordType Where SObjectType = 'Sub_Sub_Request__c' and Name='RTA Service Order Line Items'].id; 
      for(Sub_Sub_Request__c item: apexSubSubReqList){
        item.RecordTypeId = rtaRecordTypeId ;        
      }
      
      try{
            
          insert apexSubSubReqList;
          
          /*
          system.debug('apexIsStartDateChanged---'+apexIsStartDateChanged);
          system.debug('apexStartDateEdit---'+apexStartDateEdit);
          system.debug('apexIsEndDateChanged---'+apexIsEndDateChanged);
          system.debug('apexEndDateEdit---'+apexEndDateEdit);
          
          if(apexIsStartDateChanged != Null && apexIsStartDateChanged != Null)
          if(apexIsStartDateChanged || apexIsEndDateChanged){
              if(apexSubSubReqList != Null && apexSubSubReqList.size() > 0){
                  Id subReqId = apexSubSubReqList.get(0).Sub_Request__c;
                  //update the respective sub request if any changes in Start or End Date
                  List<Sub_Request__c> subReq = new List<Sub_Request__c>([SELECT id, MCFD_Revised_End_Date__c, MCFD_Revised_Start_Date__c 
                                                  FROM Sub_Request__c 
                                                  WHERE Id =: subReqId LIMIT 1]); 
                  if(!subReq.isEmpty()){
                      List<String> dateParts = new List<String>();
                      if(apexIsStartDateChanged && apexStartDateEdit != Null){
                          dateParts = apexStartDateEdit.split('/');                // current format from autism funding dashboard is mm/dd/yyyy
                          subReq.get(0).MCFD_Revised_Start_Date__c  = date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)));  
                      }                 
                      if(apexIsEndDateChanged && apexEndDateEdit != Null){
                        dateParts = apexEndDateEdit.split('/');
                        subReq.get(0).MCFD_Revised_End_Date__c = date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)));  
                      }
                      update subReq;
                  }
                                              
              }     
          }*/       
        if(!apexSubReqList.isEmpty()){
            List<String> dateParts = new List<String>();
            for(Sub_Request__c item: apexSubReqList){
                if(item.MCFD_Revised_Start_Date_Text__c != Null){
                    dateParts = item.MCFD_Revised_Start_Date_Text__c.split('/');                // current format from autism funding dashboard is mm/dd/yyyy
                    item.MCFD_Revised_Start_Date__c  = date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)));  
                }
                if(item.MCFD_Revised_End_Date_Text__c != Null){
                    dateParts = item.MCFD_Revised_End_Date_Text__c.split('/');                // current format from autism funding dashboard is mm/dd/yyyy
                    item.MCFD_Revised_End_Date__c  = date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(0)), Integer.valueOf(dateParts.get(1)));     
                }
            }
            update apexSubReqList;
        }
      }catch(Exception e){
            MCFD_Logger.log(MCFD_Logger.ERROR, 'MCFD_RTAXMLGenerator' , 'Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());
            throw new AuthenticationException('Exception Message: '+e.getMessage()+'\n'+'Stack trace: '+ e.getStackTraceString());          
        }
      
      return apexSubSubReqList;   
     
    }
    
    // Owner: Pavan Dave
    // To throw custom exception after logging inside Log table
    
    class AuthenticationException extends Exception {
     // Added by Abhishek to fix CRD
        public AuthenticationException(Exception e, string sourceClass){
            //system.debug('Exeption Name ******' + e);
      }
      // End of Modification by Abhishek
    }
}