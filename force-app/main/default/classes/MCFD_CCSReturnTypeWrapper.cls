public class MCFD_CCSReturnTypeWrapper {
    @AuraEnabled
    public Map<String, sobject> mapObj {get; set;}
    @AuraEnabled
    public Map<String, list<sobject>> mapListObj {get; set;}
    
    public MCFD_CCSReturnTypeWrapper(Map<String, sobject> mapObj, Map<String, list<sobject>> mapListObj){
        mapObj = mapObj;
        mapListObj = mapListObj;
    }
}