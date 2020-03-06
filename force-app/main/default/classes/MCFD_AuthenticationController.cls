/**************************************************************************************
Function            : Contains Parsing SiteMinder SAML Response & Redirection Logic 

Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanjoy Joseph               05 MAY 2017             Original Version
* Pavan Dave                  09 MAY 2017             Handled addtional contact informaion & pre-fill registration page
* Pavan Dave                  06 JUL 2017             Added method to preserve special symbol from name fields. Bug 4077
* Laura Perry                 26 OCT 2017             Commented out code that is impossible to get to. This is to achieve test class coverage
* PDAVE                       04 DEC 2017             US 5158 - Configuring System Maintenance page
*************************************************************************************/

public without sharing class MCFD_AuthenticationController {
   
    
    /*----------- Decoded SAML resposnse's Contact infromation related variables -----------*/
    private static String FNameAttributeName;
    private static String MNameAttributeName;
    private static String LNameAttributeName;
    private static String EmailAttributeName;
    private static String GuidAttributeName;
    private static String BCeIDAttributeName;
    private static String BCeIDTypeAttributeName;
    private static String IsIDIRAttributeName;
    
    private static String FNameAttributeValue;
    private static String MNameAttributeValue;
    private static String LNameAttributeValue;
    private static String EmailAttributeValue;
    private static String GuidAttributeValue;
    private static String BCeIDAttributeValue;
    private static String BCeIDTypeAttributeValue;
    private static String IsIDIRAttributeValue;
    
    /*----------- SAML Attributes Value Maps -----------*/
    private static Map<String,Dom.XmlNode> SAMLAttribute = new Map<String,Dom.XmlNode>();
    private static Map<String,String> SAMLAttributeValue = new Map<String,String>();
    
    /*----------- Redirection related variables -----------*/
    private static String StandardRedirectUrl;
    private static String PortalRedirectUrl;
    private static String MCFDRegistraionURL;    
    private static String MCFDMessagePageURL;
    private static String MCFDPortalLandingPageURL;
    private static String Syst_Maint_Page_URL;
    
    public String decodedSamlResponse {get; set;}
    public String error {get; set;}
    
     class AuthenticationException extends Exception {
     // Added by Abhishek to fix CRD
        public AuthenticationException(Exception exptn, string sourceClass){
            //system.debug('Exeption Name ******' + exptn);
      }
      // End of Modification by Abhishek
    }
    
    public MCFD_AuthenticationController() {
        // Work performed in evaluateAssertion     
    }
    public PageReference evaluateAssertion() {
        PageReference pr = null;
        try {            
            loadConfig();
            Dom.Document response = loadSamlResponse();
            findAttributeValues(response);
            //system.debug('SAMLAttribute--'+SAMLAttribute);
            //system.debug('SAMLAttributeValue--'+SAMLAttributeValue);
            if(SAMLAttributeValue.get(GuidAttributeName) != Null && SAMLAttributeValue.get(GuidAttributeName) != ''){
                GuidAttributeValue = SAMLAttributeValue.get(GuidAttributeName); 
            }
            if(SAMLAttributeValue.get(FNameAttributeName) != Null && SAMLAttributeValue.get(FNameAttributeName) != ''){
                FNameAttributeValue = preserveSpecialSymbol(SAMLAttributeValue.get(FNameAttributeName));   
            }
            if(SAMLAttributeValue.get(MNameAttributeName) != Null && SAMLAttributeValue.get(MNameAttributeName) != ''){
                MNameAttributeValue = preserveSpecialSymbol(SAMLAttributeValue.get(MNameAttributeName));           
            }
            if(SAMLAttributeValue.get(LNameAttributeName) != Null && SAMLAttributeValue.get(LNameAttributeName) != ''){
                LNameAttributeValue = preserveSpecialSymbol(SAMLAttributeValue.get(LNameAttributeName));
            }
            if(SAMLAttributeValue.get(EmailAttributeName) != Null && SAMLAttributeValue.get(EmailAttributeName) != ''){
                EmailAttributeValue = SAMLAttributeValue.get(EmailAttributeName);
            }
            if(SAMLAttributeValue.get(BCeIDAttributeName) != Null && SAMLAttributeValue.get(BCeIDAttributeName) != ''){
                BCeIDAttributeValue = SAMLAttributeValue.get(BCeIDAttributeName);
            }
            //The BCeID Type attribute can not be null or blank, so this code is impossible to get to
           /* if(SAMLAttributeValue.get(BCeIDTypeAttributeName) != Null && SAMLAttributeValue.get(BCeIDTypeAttributeName) != ''){
                BCeIDTypeAttributeValue = SAMLAttributeValue.get(BCeIDTypeAttributeName);
            }*/
            if(SAMLAttributeValue.get(IsIDIRAttributeName) != Null && SAMLAttributeValue.get(IsIDIRAttributeName) != ''){
                IsIDIRAttributeValue = SAMLAttributeValue.get(IsIDIRAttributeName);
            }      
            
            User user;
            user= loadUserByGuid(GuidAttributeValue);
            if(isPortalUnderMaintenance()){
                pr = new PageReference(Syst_Maint_Page_URL);
            }else if (user == null) {                
               
               if(IsIDIRAttributeValue != Null && IsIDIRAttributeValue != '' && IsIDIRAttributeValue == 'true'){
                   //if SAML response for IDIR Login -> Show error message
                   pr = new PageReference(MCFDMessagePageURL);
                  // pr.getParameters().put('title', 'SignInError'); //Commented for Bug fix 4995
                }else if(IsIDIRAttributeValue != Null && IsIDIRAttributeValue != '' && IsIDIRAttributeValue == 'false'){
                    String paramStr = '';
                    Boolean foundFirstParam = false;
                    // if SAML response for BCeID Login -> Show self registration                
                    // Sample link with contact detail parameters 
                    // /s/registration?lName=test&fName=test&guid=12XXXXXXXXXF45AD939C79A6BFA7F01F&bceidType=Basic&mName=test&bceid=123456&email=pdave%40deloitte.com
                    pr = new PageReference(MCFDRegistraionURL);
                    if(FNameAttributeValue != Null && FNameAttributeValue != ''){
                        //pr.getParameters().put('fName', FNameAttributeValue);   
                        //found FirstParam can only be false in this scenario, so commenting out code that is an impossible case 
                      //  if(foundFirstParam == false){
                            paramStr = paramStr + 'fName' + '=' + FNameAttributeValue;
                      /*  }else{
                            paramStr = paramStr + '&fName' + '=' + FNameAttributeValue;
                        }*/
                        foundFirstParam = true;
                    }
                    if(MNameAttributeName != Null && MNameAttributeName != ''){
                        //pr.getParameters().put('mName', MNameAttributeName);    
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'mName' + '=' + MNameAttributeName;
                        }else{
                            paramStr = paramStr + '&mName' + '=' + MNameAttributeName;
                        }
                        foundFirstParam = true;
                    }
                    if(LNameAttributeValue != Null && LNameAttributeValue != ''){
                        //pr.getParameters().put('lName', LNameAttributeValue);   
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'lName' + '=' + LNameAttributeValue;
                        }else{
                            paramStr = paramStr + '&lName' + '=' + LNameAttributeValue;
                        }
                        foundFirstParam = true;
                    }
                    if(EmailAttributeValue != Null && EmailAttributeValue != ''){
                        //pr.getParameters().put('email', EmailAttributeValue);   
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'email' + '=' + EmailAttributeValue;
                        }else{
                            paramStr = paramStr + '&email' + '=' + EmailAttributeValue;
                        }
                        foundFirstParam = true;
                    }
                    if(BCeIDAttributeValue != Null && BCeIDAttributeValue != ''){
                        //pr.getParameters().put('bceid', BCeIDAttributeValue);   
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'bceid' + '=' + BCeIDAttributeValue;
                        }else{
                            paramStr = paramStr + '&bceid' + '=' + BCeIDAttributeValue;
                        }
                        foundFirstParam = true;
                    }
                    if(BCeIDTypeAttributeValue != Null && BCeIDTypeAttributeValue != ''){
                        //pr.getParameters().put('bceidType', BCeIDTypeAttributeValue);   
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'bceidType' + '=' + BCeIDTypeAttributeValue;
                        }else{
                            paramStr = paramStr + '&bceidType' + '=' + BCeIDTypeAttributeValue;
                        }
                        foundFirstParam = true;
                    }
                    if(GuidAttributeValue != Null && GuidAttributeValue != ''){
                        //pr.getParameters().put('guid', GuidAttributeValue);
                        if(foundFirstParam == false){
                            paramStr = paramStr + 'guid' + '=' + GuidAttributeValue;
                        }else{
                            paramStr = paramStr + '&guid' + '=' + GuidAttributeValue;
                        }
                        foundFirstParam = true;
                    }
                    system.debug('paramStr-->'+paramStr);
                    Blob cryptoKey = Blob.valueOf(System.Label.Crypto_Key_16_Digit);    //16 byte string. since characters used are ascii, each char is 1 byte.
                    Blob data = Blob.valueOf(paramStr);
                    Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
                    //String paramStrEncrpt = EncodingUtil.base64Encode(b);
                    String paramStrEncrpt = EncodingUtil.base64Encode(encryptedData);
                    system.debug('paramStrEncrpt-->'+paramStrEncrpt);
                    pr.getParameters().put('e',paramStrEncrpt);
                    system.debug('pr-->'+pr);                     
                }else{
                   pr = new PageReference(MCFDMessagePageURL);
                   // pr.getParameters().put('title', 'IsIDIR Attibute Not Found'); //Commented for Bug fix 4995
                }                                           
                pr.setRedirect(true);                
            } else if(!user.isActive){
                //throw new AuthenticationException('User is inactive.');
                pr = new PageReference(MCFDMessagePageURL);
                // pr.getParameters().put('title', 'SignInError'); //Commented for Bug fix 4995
            } else if(isUserFrozen(user)){
                pr = new PageReference(MCFDMessagePageURL);
                // pr.getParameters().put('title', 'SignInError'); //Commented for Bug fix 4995
            }else {
                //Redirect to correct siteminder
                pr = redirectToSso(user);
                pr.setRedirect(true);                
            }
        } catch (Exception e) {
            error = e.getMessage();
            pr = new PageReference(MCFDMessagePageURL);
            // pr.getParameters().put('title', error); //Commented for Bug fix 4995
            //logException(e, decodedSamlResponse);
        }
        return pr;
    }
    public Dom.Document loadSamlResponse() {
        // Retrieve the base64 encoded SAML response
        String encodedSamlResponse = ApexPages.currentPage().getParameters().get('SAMLResponse');
        if (encodedSamlResponse == null) {
            // No SAML response was found.
            throw new AuthenticationException('No SAML assertion was found');
        }
        //System.debug(encodedSamlResponse);
        Blob decodedSamlResponseBlob = EncodingUtil.base64Decode(encodedSamlResponse);
        //System.debug(decodedSamlResponseBlob);
        if (decodedSamlResponseBlob == null) {
            // There was a problem decoding the SAML response.
            throw new AuthenticationException('An error occurred while decoding the SAML assertion');
        }
        
        decodedSamlResponse = null;
       
        decodedSamlResponse = decodedSamlResponseBlob.toString();
       // decodedSamlResponse = String.valueOf(decodedSamlResponseBlob);
       // System.debug(decodedSamlResponse);
        Dom.Document response = new Dom.Document();
        response.load(decodedSamlResponse);
        return response;
    }
    public void findAttributeValues(Dom.Document response) {
        
        if (response == null) {
            throw new AuthenticationException('No SAML response was found');
        }
        Dom.XmlNode root = response.getRootElement();
        Dom.XmlNode assertion = getChildElementByName(root, 'Assertion');
        if (assertion == null) {
            throw new AuthenticationException('No SAML assertion was found');
        }
        Dom.XmlNode attributeStatement = getChildElementByName(assertion, 'AttributeStatement');
        if (attributeStatement == null) {
            throw new AuthenticationException('No SAML attribute statement was found');
        }
        //Map<String,Dom.XmlNode> guidAttribute;
         SAMLAttribute.put(GuidAttributeName,getChildElementByAttribute(attributeStatement, 'Name', GuidAttributeName));
        if (SAMLAttribute.get(GuidAttributeName) == null) {
            throw new AuthenticationException('No SAML Identifier attribute was found');
        }
        SAMLAttribute.put(FNameAttributeName,getChildElementByAttribute(attributeStatement, 'Name', FNameAttributeName));     
        SAMLAttribute.put(LNameAttributeName,getChildElementByAttribute(attributeStatement, 'Name', LNameAttributeName));    
        SAMLAttribute.put(EmailAttributeName,getChildElementByAttribute(attributeStatement, 'Name', EmailAttributeName));
        SAMLAttribute.put(MNameAttributeName,getChildElementByAttribute(attributeStatement, 'Name', MNameAttributeName));
        SAMLAttribute.put(BCeIDAttributeName,getChildElementByAttribute(attributeStatement, 'Name', BCeIDAttributeName));
        SAMLAttribute.put(IsIDIRAttributeName,getChildElementByAttribute(attributeStatement, 'Name', IsIDIRAttributeName));     
        
        SAMLAttributeValue.put(GuidAttributeName,getChildElementByName(SAMLAttribute.get(GuidAttributeName), 'AttributeValue').getText());
        
        if (SAMLAttributeValue.get(GuidAttributeName) == null) {
            throw new AuthenticationException('No SAML Identifier value was found');
        }
        if(SAMLAttribute.get(FNameAttributeName) != Null){
        SAMLAttributeValue.put(FNameAttributeName,getChildElementByName(SAMLAttribute.get(FNameAttributeName), 'AttributeValue').getText());
        }
        if(SAMLAttribute.get(LNameAttributeName) != Null){
            SAMLAttributeValue.put(LNameAttributeName,getChildElementByName(SAMLAttribute.get(LNameAttributeName), 'AttributeValue').getText());
        }
        
        if(SAMLAttribute.get(EmailAttributeName) != Null){
            SAMLAttributeValue.put(EmailAttributeName,getChildElementByName(SAMLAttribute.get(EmailAttributeName), 'AttributeValue').getText());        
        }
        
        
        //SAMLAttributeValue.put(EmailAttributeName,getChildElementByName(SAMLAttribute.get(EmailAttributeName), 'AttributeValue').getText());        
        if(SAMLAttribute.get(MNameAttributeName) != Null){
            SAMLAttributeValue.put(MNameAttributeName,getChildElementByName(SAMLAttribute.get(MNameAttributeName), 'AttributeValue').getText());    
        }
        if(SAMLAttribute.get(BCeIDAttributeName) != Null){
            SAMLAttributeValue.put(BCeIDAttributeName,getChildElementByName(SAMLAttribute.get(BCeIDAttributeName), 'AttributeValue').getText());    
        }
        if(SAMLAttribute.get(IsIDIRAttributeName) != Null){
            SAMLAttributeValue.put(IsIDIRAttributeName,getChildElementByName(SAMLAttribute.get(IsIDIRAttributeName), 'AttributeValue').getText());
        }
        
    }
    private Dom.XmlNode getChildElementByName(Dom.XmlNode parent, String name) {
        for (Dom.XmlNode node : parent.getChildElements()) {
            if (node.getName() == name) {
                return node;
            }
        }
        return null;
    }
    private Dom.XmlNode getChildElementByAttribute(Dom.XmlNode parent, String attribute, String value) {
            String attributeValue;
        for (Dom.XmlNode node : parent.getChildElements()) {
            //String attributeValue = node.getAttributeValue(attribute, '');
            attributeValue = node.getAttributeValue(attribute, '');
            //PDAVE: Task 5710 - Broken Null Check
            if (!(value != null) && !(attributeValue != null)) {
                return node;
            }
            if (attributeValue != null && value != null && attributeValue == value) {
                return node;
            }
        }
        return null;
    }
    private String preserveSpecialSymbol(String val){
        String retVal;
        if(val != Null && val != ''){
            retVal = val.replace('+', ' ');                 //preserve space
            retVal = retVal.replace('&#39;', '\'');         //preserve apostrophe
        }
        return retVal;
    }

    
    public static void loadConfig() {
        MCFD_Portal_SSO_Redirection__c config = MCFD_Portal_SSO_Redirection__c.getAll().values().get(0);
        MCFD_Portal_Settings__c mcfdSetting = MCFD_Portal_Settings__c.getAll().values().get(0);
        
        if (config == null || mcfdSetting == null) {
            return;
        }
        GuidAttributeName = config.Federation_Identifier_Attribute_Name__c;
        FNameAttributeName = config.First_Name_Attribute_Name__c;
        MNameAttributeName = config.Middle_Name_Attribute_Name__c;
        LNameAttributeName = config.Last_Name_Attribute_Name__c;
        EMailAttributeName = config.Email_Attribute_Name__c;    //EMailAttributeName = '123';
        BCeIDAttributeName = config.BCeID_Attribute_Name__c;
        BCeIDTypeAttributeName = config.BCeID_Type_Attribute_Name__c;
        IsIDIRAttributeName = config.IsIDIR_Attribute_Name__c;        
        PortalRedirectUrl = config.External_User_URL__c;
        StandardRedirectUrl = config.Internal_User_URL__c;
        MCFDRegistraionURL = mcfdSetting.Portal_Registration_Page_URL__c;
        MCFDMessagePageURL = mcfdSetting.Portal_Error_Page_URL__c;
        MCFDPortalLandingPageURL= mcfdSetting.Portal_Landing_Page_url__c;   
        Syst_Maint_Page_URL = mcfdSetting.System_Maintenance_URL__c;
    }
    private User loadUserByGuid(String guid) {
        if (guid == null || guid == '' || guid.isWhitespace()) {
            throw new AuthenticationException('The federation identifier was empty');
        }
        User[] users = [Select Id, isActive, Username, UserType, IsPortalEnabled From User Where FederationIdentifier = :guid Limit 2];
        if (users.size() > 1) {
            throw new AuthenticationException('Multiple users were found with this federation identifier');
        }
        if (users.size() < 1) {
            return null;
        }
        return users.get(0);
    }
    public PageReference redirectToSso(User user) {
        if (user == null) {
            return null;
        }
        if (user.isPortalEnabled) {
            return new PageReference(PortalRedirectUrl);
            }
        else{
            return new PageReference(StandardRedirectUrl+'&RelayState=%2F');
            }
    }
    public boolean isUserFrozen(User usr){
        Boolean isFrozenUser = false;
        List<User> frozenUsers = new List<User>([SELECT Id, Name, Email, Phone, IsActive, LastLoginDate 
                                                    FROM User 
                                                    WHERE Id 
                                                    IN (SELECT UserId FROM UserLogin WHERE IsFrozen = true)]);

        Set<Id> frozenUserIds = new Set<Id>();
        for(User item: frozenUsers){
            frozenUserIds.add(item.id);
        }

        if(frozenUserIds.contains(usr.id)){
            isFrozenUser = true;
        }else{
            isFrozenUser = false;
        }                        
        //System.debug('isFrozenUser ' + isFrozenUser);  
        return isFrozenUser;                           
    }
    
    @AuraEnabled
    public static string portalLandingPage(){
        MCFD_Portal_Settings__c mcfdSetting = MCFD_Portal_Settings__c.getAll().values().get(0);
        MCFDPortalLandingPageURL= mcfdSetting.Portal_Landing_Page_url__c;   
        return MCFDPortalLandingPageURL;
    }
    
    public boolean isPortalUnderMaintenance(){
        boolean underMaintenance = false;
        if(System.Label.Sys_Maint_Master_Switch.toUpperCase() == 'ON'){
            underMaintenance = true;
        }
        return underMaintenance;
    }
}