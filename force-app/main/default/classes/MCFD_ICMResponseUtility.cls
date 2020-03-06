/*
Description       :   Util class to get the actual value from the ICM response 
Created By        :   Deloitte
Modification Log  :
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Developer         Date                Description
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -          
Abhimanyu            May 26 2018           Created
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -            
*/

public Class MCFD_ICMResponseUtility {

    
    // This method is to get the active CRA conset
    public static Boolean hasActiveCRAConsent(string jsonResponse) {
    
        ICMResponseParser parsedResponse = ICMResponseParser.parse(jsonResponse);
       
        Boolean isActive = false ; 
        if(parsedResponse != null ) {
             
            if(parsedResponse.docPortalResponse != null ) {
                if(parsedResponse.docPortalResponse.HlsCase != null ) {
                    
                    // checkin if the HLS List has some cases 
                    if(parsedResponse.docPortalResponse.HlsCase.size() > 0 ) {
                        
                        // Parsing the HLS Cases 
                        for(ICMResponseParser.hlsCase thisCase :  parsedResponse.docPortalResponse.HlsCase) {
                            if(thisCase.Consent!=null) {
                                
                                // Parsing the Content
                                if(thisCase.Consent.size() > 0) { 
                                    for(ICMResponseParser.Consent thisConsent :  thisCase.Consent) {
                                        
                                        if(string.isNotBlank(thisConsent.SubType)) {
                                            
                                            Date thisEndDate = date.today();
                                            
                                            if(string.isNotBlank(thisConsent.EndDate)) {
                                                 thisEndDate = formatDate(thisConsent.EndDate);
                                            }
                                            
                                            system.debug('----Line- 999--MCFD_CallICMForContact--'+thisEndDate+'==='+thisConsent.SubType+'*******'+thisConsent.EndDate);
                                            if(thisConsent.SubType == 'Consent to collect from CRA' && (thisEndDate > Date.today() || thisConsent.EndDate == '' || thisConsent.EndDate == null)) {
                                                isActive = true;
                                                break;
                                            }
                                        } 
                                        
                                    }
                                }

                            
                            }
                        }         
                    
                    }
                                
                }
            
            } 
             
            
        }
        
        return isActive;
    
    }
    
    
    // This method is to get the active CRA conset
    public static Map<string,boolean> contactActiveCRAConsent(string jsonResponse) {
        
        ICMResponseParser parsedResponse = ICMResponseParser.parse(jsonResponse);
        Map<string,boolean> activeConsentContactMap = new Map<string,Boolean>();
        
        Boolean isActive = false ; 
        if(parsedResponse != null ) {
            
            if(parsedResponse.docPortalResponse != null ) {
                if(parsedResponse.docPortalResponse.HlsCase != null ) {
                    
                    // checkin if the HLS List has some cases 
                    if(parsedResponse.docPortalResponse.HlsCase.size() > 0 ) {
                        
                        // Parsing the HLS Cases   
                        for(ICMResponseParser.hlsCase thisCase :  parsedResponse.docPortalResponse.HlsCase) {
                            if(thisCase.Consent!=null) {
                                
                                // Parsing the Content
                                if(thisCase.Consent.size() > 0) { 
                                    for(ICMResponseParser.Consent thisConsent :  thisCase.Consent) {
                                        
                                        if(string.isNotBlank(thisConsent.SubType)) {
                                            
                                            Date thisEndDate = date.today();
                                            
                                            if(string.isNotBlank(thisConsent.EndDate)) {
                                                thisEndDate = formatDate(thisConsent.EndDate);
                                            }
                                            
                                            system.debug('----Line- 0000--MCFD_CallICMForContact--'+thisEndDate+'==='+thisConsent.SubType+'*******'+thisConsent.EndDate);
                                            if(thisConsent.SubType == 'Consent to collect from CRA' && (thisEndDate > Date.today() || thisConsent.EndDate == '' || thisConsent.EndDate == null)) {
                                                activeConsentContactMap.put(thisConsent.PrimaryContactId,true);
                                                //break;
                                            }
                                            system.debug('----Line- 1111--MCFD_CallICMForContact--'+activeConsentContactMap);
                                            
                                        } 
                                        
                                    }
                                }
                                
                                
                            }
                        }         
                        
                    }
                    
                }
                
            } 
            
            
        }
        
        return activeConsentContactMap;
        
    }
    
    
    // This method is to update the contact from the renewal  the active CRA conset
    public static Map<string,ICMResponseParser.Consent> updateContactFromRenewal(string jsonResponse) {
        
        ICMResponseParser parsedResponse = ICMResponseParser.parse(jsonResponse);
        
        Map<string,ICMResponseParser.Consent> contactConsentMap = new Map<string,ICMResponseParser.Consent>();
        
       
        if(parsedResponse != null ) {
            
            if(parsedResponse.docPortalResponse != null ) {
                if(parsedResponse.docPortalResponse.HlsCase != null ) {
                    
                    // checkin if the HLS List has some cases 
                    if(parsedResponse.docPortalResponse.HlsCase.size() > 0 ) {
                        
                        // Parsing the HLS Cases   
                        for(ICMResponseParser.hlsCase thisCase :  parsedResponse.docPortalResponse.HlsCase) {
                            
                            // COnsent Related changes
                            if(thisCase.Consent!=null) {
                                
                                
                                // Parsing the Content
                                if(thisCase.Consent.size() > 0) { 
    
                                    for(ICMResponseParser.Consent thisConsent : thisCase.Consent) {
    
                                		string icmContactId ; 
                                		
                                		if(string.isNotBlank(thisConsent.PrimaryContactId) &&  thisConsent.PrimaryContactId != 'No Match Row Id') {
                                			
                                			icmContactId = thisConsent.PrimaryContactId;
                                		
                                		} else if(string.isNotBlank(thisConsent.PrimaryToContactId) &&  thisConsent.PrimaryToContactId != 'No Match Row Id' ) {
                                		
                                			icmContactId =  thisConsent.PrimaryToContactId;
                                		
                                		}
                                		
                                		
                                		if(string.isNotBlank(icmContactId)) {
                                			
		                                    contactConsentMap.put(icmContactId,thisConsent);
                                		
                                		}
                                		
                                		
                                
                                    }
                                       
                                    
                                }
                                
                                
                            }
                        }         
                        
                    }
                    
                }
                
            } 
            
            
        }
        
        return contactConsentMap;
        
    }
    
    
    //@future 
    public static void updateSpouseContactFromRenewal(string jsonResponse) {
        
        ICMResponseParser parsedResponse = ICMResponseParser.parse(jsonResponse);
        
        string paContactId;
    	string spouseContactId;
    
       
        if(parsedResponse != null ) {
            
            if(parsedResponse.docPortalResponse != null ) {
                if(parsedResponse.docPortalResponse.HlsCase != null ) {
                    
                    // checkin if the HLS List has some cases 
                    if(parsedResponse.docPortalResponse.HlsCase.size() > 0 ) {
                        
                        // Parsing the HLS Cases   
                        for(ICMResponseParser.hlsCase thisCase :  parsedResponse.docPortalResponse.HlsCase) {
                            
                            // COnsent Related changes
                            if(thisCase.Contact!=null) {
                                
                                
                                // Parsing the Content
                                if(thisCase.Contact.size() > 0) { 
                                	
                                	
                                    for(ICMResponseParser.cls_Contact thisContact : thisCase.Contact) {
    
                                		if(thisContact.Relationship == 'Key player') {
                                			
                                			paContactId = thisContact.ICMContactId;
                                			
                                		} else if(thisContact.Relationship == 'Spouse') {
                                		
                                			spouseContactId = thisContact.ICMContactId;
                                		}
                                		
                                		
                                
                                    }
                                    
                                               
                                    
                                }
                                
                                
                            }
                        }
                        
                        
                        if(string.isNotBlank(paContactId) && string.isNotBlank(spouseContactId)) {
                                    
                        	string contactID;
					      	for( MCFD_Relationship__c relatnship : [SELECT MCFD_Child_Contact__c,MCFD_Child_Contact__r.ICM_Contact_Id__c FROM MCFD_Relationship__c where MCFD_Parent_Contact__r.ICM_Contact_Id__c =: paContactId and MCFD_Relationship_Type__c = 'Spouse' order by createdDate DESC limit 1] ) {
									system.debug('-----Abhi--111---'+relatnship);
									if(string.isBlank(relatnship.MCFD_Child_Contact__r.ICM_Contact_Id__c)) {
										contactID = relatnship.MCFD_Child_Contact__c;
										system.debug('-----Abhi--2222---'+contactID);
									
									}
					
							}
							
							if(string.isNotBlank(contactID)) {
							    system.debug('-----Abhi--3333---'+contactID);
								Contact spouseContact = [select id,ICM_Contact_Id__c from contact where id=:contactID limit 1];
								spouseContact.ICM_Contact_Id__c = spouseContactId;
								update spouseContact;
								
							}
                
                        
                        
                        }
                        
                                 
                        
                    }
                    
                }
                
            } 
            
            
        }
        
       
    }
    
    
    // This method is to Format the Date into current Format 
    public static Date formatDate(String thisDate) {
    
        // Creating the Date format in yyyy, mm, dd
        integer year = integer.valueOf(thisDate.split('/')[2].left(4));
        integer month = integer.valueOf(thisDate.split('/')[0]);
        integer day = integer.valueOf(thisDate.split('/')[1]);
       
        Date thisFormattedDate = date.newInstance(year,month,day);
        return  thisFormattedDate;   
    } 


}