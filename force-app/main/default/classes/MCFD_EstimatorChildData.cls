public class MCFD_EstimatorChildData{
    @AuraEnabled public String name{get;set;}
    @AuraEnabled public Boolean specialNeeds{get;set;}
    @AuraEnabled public Integer age{get;set;}
   @AuraEnabled public String selectedTypeOfCare{get;set;}
     @AuraEnabled public String scheduleType{get;set;}
    @AuraEnabled public Decimal groupAmount;
    @AuraEnabled public Decimal familyAmount;
    @AuraEnabled public Decimal preschoolAmount;
    @AuraEnabled public Decimal schoolAmount;
    @AuraEnabled public Decimal LNRAmount;
    @AuraEnabled public Decimal inHomeAmount;
    @AuraEnabled public Decimal registeredAmount;
    @AuraEnabled public String mondayCare;
    @AuraEnabled public String tuesdayCare;
    @AuraEnabled public String wednesdayCare;
    @AuraEnabled public String thursdayCare;
    @AuraEnabled public String fridayCare;
    @AuraEnabled public String saturdayCare;
    @AuraEnabled public String sundayCare;
    @AuraEnabled public Integer childCount;
    @AuraEnabled public Boolean noCare;
    
    public MCFD_EstimatorChildData() {
        this.noCare = false;
    }
    
    
    public static MCFD_EstimatorChildData createData(Integer a,Boolean sn, String n, String sc, String st){
        System.debug('In createData');
        MCFD_EstimatorChildData d = new MCFD_EstimatorChildData();
        d.name=n;
        d.age=a;
        if (sn == null)
            d.specialNeeds=false;
        else
            d.specialNeeds=sn;
        d.noCare=false;
        d.selectedTypeOfCare=sc;
        d.scheduleType=st;
        return d;
    }

        
}