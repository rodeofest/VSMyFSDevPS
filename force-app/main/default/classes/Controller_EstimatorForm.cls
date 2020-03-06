/*********************************************************************************************************
Name            : Controller_EstimatorForm.cls  
Description     : This class is used to handle estimation of a subsidy. 
Created By      : Deloitte
Created Date    : 5/June/2018
Modification Log:
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Steven         19 July 2018   Complete refactor of class. Old class is in Controller_EstimatorFormOld.cls
Deanna         05 June 2018   Class creation
--------------------------------------------------------------------------------------------------------------                      

***************************************************************************************************************/

public class Controller_EstimatorForm {
    static List<MCFD_EstimatorChildData> childList= new List<MCFD_EstimatorChildData>();
    static List<Subsidy_Info__mdt> subsidies;
    static Estimator_Rule__mdt rule;
    
    static Decimal netIncome;
    
    public void Controller_EstimatorForm(){
        //Construct collection that has one child in it
        createChildren(1);
    }
    
    @AuraEnabled
    public static List<MCFD_EstimatorChildData> createChildren(Integer aNum){
        Integer currentCount;
        childList = new List<MCFD_EstimatorChildData>();
        
        for(currentCount=0; currentCount < aNum; currentCount++){
            MCFD_EstimatorChildData newChild = new MCFD_EstimatorChildData();
            newchild.childCount = currentCount + 1;
            childList.add(newChild);
        }

        return childList;
    }
    
    @AuraEnabled
    public static List<MCFD_EstimatorChildData> estimateSubsidy(String income, Integer numAdults, Integer numChildren, Integer specNeedsNum, String children){
        childList = new List<MCFD_EstimatorChildData>();  
    
        // Create list raw list of children from JSON
        List<MCFD_EstimatorChildData> tempList = (List<MCFD_EstimatorChildData>) System.JSON.deserialize(children, List<MCFD_EstimatorChildData>.class);    
        
        Integer childCount = 1;
        
        for (MCFD_EstimatorChildData rawChild : tempList) {
            MCFD_EstimatorChildData newChild = MCFD_EstimatorChildData.createData(rawChild.age, rawChild.specialNeeds, rawChild.name, rawChild.selectedTypeOfCare, 
                                                          rawChild.scheduleType);
            newChild.mondayCare = rawChild.mondayCare;
            newChild.tuesdayCare = rawChild.tuesdayCare;
            newChild.wednesdayCare = rawChild.wednesdayCare;
            newChild.thursdayCare = rawChild.thursdayCare;
            newChild.fridayCare = rawChild.fridayCare;
            newChild.saturdayCare = rawChild.saturdayCare;
            newChild.sundayCare = rawChild.sundayCare;
            
            newChild.childCount = childCount;
            
            if (!(rawChild.noCare == null || !rawChild.noCare)){
                newChild.noCare = true;
            }

            childList.add(newChild);   
            childCount += 1;
        }
        
        //Pull Subsidy records from custom metadata types
        String query='SELECT ';
        for(String st: Schema.getGlobalDescribe().get('Subsidy_Info__mdt').getDescribe().fields.getMap().keySet())
        {
            query = query + st + ' ,';
        }
        query = query.left(query.length()-1);
        query = query + ' FROM Subsidy_Info__mdt ORDER BY AgeGroup__c';
        subsidies = database.query(query);
  
        //Pull Estimator Rule records from custom metadata
        query='SELECT ';
        for(String st: Schema.getGlobalDescribe().get('Estimator_Rule__mdt').getDescribe().fields.getMap().keySet())
        {
            query = query + st + ' ,';
        }
        
        query = query.left(query.length()-1);
        query = query + ' FROM Estimator_Rule__mdt';
        
        List<Estimator_Rule__mdt> estimatorRules = database.query(query);
        
        rule = estimatorRules[0];
        
        
        netIncome = Decimal.valueOf(income);
        
        //Adjust income for family size
        if ((numAdults >1)|| (numChildren > 1)){
            netIncome = netIncome - ((numAdults + numChildren - 2) * (rule.FamilyCompositionDeduction__c));
        }
        
        if (specNeedsNum == null) {
            specNeedsNum = 0;
        }
        
        //Adjust income for special needs
        netIncome = netIncome - (specNeedsNum * (Integer)rule.SpecialNeedsDeduction__c);
        
        if(netIncome < 0)
            netIncome = 0;
        
        System.debug('Adjusted annual income: ' + netIncome);
        
        //Iterate through children and compute benefit amount
        for (MCFD_EstimatorChildData child : childList) {
            switch on child.selectedTypeOfCare {
                when '1'{
                    assessChildForGroupCare(child);
                }
                when '2'{
                    assessChildForFamilyCare(child);
                }
                when '3'{
                    assessChildForPreschoolCare(child);
                }
                when '4' {
                    assessChildForRegisteredCare(child);
                }
                when '5'{
                    assessChildForLNRCare(child);
                }
            }
        }
        
        assessForHomeCare();
        
        return childList;
    }
    
    public static void assessChildForGroupCare(MCFD_EstimatorChildData child){
        Decimal multiplier = assessChildcareSchedule(child);
        child.groupAmount=0;
     
        Subsidy_Info__mdt subsidy=subsidies[child.age-1];
        System.debug('Group subsidy is '+ subsidy);
        if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel1__c)){
            
            child.groupAmount= (subsidy.GIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN); 
            System.debug('Income level 1  with groupAmount '+child.groupAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel2__c)){  
            //child.groupAmount= (subsidy.GIG1__c-((netIncome - rule.LicensedIncomeLevel1__c)/12 * subsidy.GIG2__c)).setScale(0, RoundingMode.DOWN);
            child.groupAmount = (subsidy.GIG1__c * (1 - (((netIncome - rule.LicensedIncomeLevel1__c) * rule.LicensedMultiplier1__c)/(rule.LicensedIncomeLevel2__c - rule.LicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 2 with groupAmount '+child.groupAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel3__c)){  
            child.groupAmount = (rule.LicensedMultiplier2__c * subsidy.GIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 3 with groupAmount '+ child.groupAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel4__c)){  
            //child.groupAmount= (subsidy.GIG3__c-((netIncome - rule.LicensedIncomeLevel3__c)/12 * subsidy.GIG4__c)).setScale(0, RoundingMode.DOWN);
            child.groupAmount = ((subsidy.GIG1__c * rule.LicensedMultiplier2__c) * (1 - ((netIncome - rule.LicensedIncomeLevel3__c)/(rule.LicensedIncomeLevel4__c - rule.LicensedIncomeLevel3__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            
            System.debug('Income level 4 with groupAmount '+child.groupAmount);
        }
    }
    
    public static void assessChildForFamilyCare(MCFD_EstimatorChildData child) {
        Decimal multiplier = assessChildcareSchedule(child);
        child.familyAmount =0;            
        Subsidy_Info__mdt subsidy = subsidies[child.age-1];
        
        if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel1__c)){
            child.familyAmount= (subsidy.JIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN); 
            System.debug('Income level 1 with familyAmount '+child.familyAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel2__c)){  
            //child.familyAmount= (subsidy.JIG1__c-((netIncome - rule.LicensedIncomeLevel1__c)/12 * subsidy.JIG2__c)).setScale(0, RoundingMode.DOWN);
            child.familyAmount = (subsidy.JIG1__c * (1 - (((netIncome - rule.LicensedIncomeLevel1__c) * rule.LicensedMultiplier1__c)/(rule.LicensedIncomeLevel2__c - rule.LicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 2 with familyAmount '+child.familyAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel3__c)){  
            child.familyAmount= (rule.LicensedMultiplier2__c * subsidy.JIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 3 with familyAmount '+child.familyAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel4__c)){  
            //child.familyAmount= (subsidy.JIG3__c-((netIncome - rule.LicensedIncomeLevel3__c)/12 * subsidy.JIG4__c)).setScale(0, RoundingMode.DOWN);
            child.familyAmount = ((subsidy.JIG1__c * rule.LicensedMultiplier2__c) * (1 - ((netIncome - rule.LicensedIncomeLevel3__c)/(rule.LicensedIncomeLevel4__c - rule.LicensedIncomeLevel3__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 4 with familyAmount '+child.familyAmount);
        }
    }
    
    public static void assessChildForPreschoolCare(MCFD_EstimatorChildData child){
        Decimal multiplier = assessChildcareSchedule(child);
        Subsidy_Info__mdt subsidy = null;
        child.preschoolAmount =0;
        subsidy = subsidies[child.age-1];
        System.debug('In preschool -- child age is '+ child.age);
        System.debug('In preschool -- subsidy is '+ subsidy);
        //This only applies to 30 months plus, but the UI only asks 36 months plus
        if ((child.age==6)&&(subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel1__c)){
            child.preschoolAmount= (subsidy.NIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN); 
            System.debug('Income level 1 with preschoolAmount '+child.preschoolAmount);
        }
        else if ((child.age==6)&&(subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel2__c)){  
            //child.preschoolAmount= (subsidy.NIG1__c-((netIncome - rule.LicensedIncomeLevel1__c)/12 * subsidy.NIG2__c)).setScale(0, RoundingMode.DOWN);
            child.preschoolAmount = (subsidy.NIG1__c * (1 - (((netIncome - rule.LicensedIncomeLevel1__c) * rule.LicensedMultiplier1__c)/(rule.LicensedIncomeLevel2__c - rule.LicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);

            System.debug('Income level 2 with preschoolAmount '+child.preschoolAmount);
        }
        else if ((child.age==6)&&(subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel3__c)){  
            child.preschoolAmount = (rule.LicensedMultiplier2__c * subsidy.NIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 3 with preschoolAmount '+child.preschoolAmount);
        }
        else if ((child.age==6)&&(subsidy!=null)&&(netIncome < rule.LicensedIncomeLevel4__c)){  
            child.preschoolAmount = ((subsidy.NIG1__c * rule.LicensedMultiplier2__c) * (1 - ((netIncome - rule.LicensedIncomeLevel3__c)/(rule.LicensedIncomeLevel4__c - rule.LicensedIncomeLevel3__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 4 with preschoolAmount '+child.preschoolAmount);
        }
    }
    
    public static void assessChildForLNRCare(MCFD_EstimatorChildData child) {         
        Decimal multiplier = assessChildcareSchedule(child);
        
        child.LNRAmount =0;            
        Subsidy_Info__mdt subsidy=subsidies[child.age-1];
        
        if ((subsidy!=null)&&(netIncome < rule.UnlicensedIncomeLevel1__c)){
            child.LNRAmount= (subsidy.FIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN); 
            System.debug('Income level 1 with LNRAmount '+child.LNRAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.UnlicensedIncomeLevel2__c)){    
            child.LNRAmount= (subsidy.FIG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 2 with LNRAmount '+child.LNRAmount);
        }
    }
    
    public static void assessChildForRegisteredCare(MCFD_EstimatorChildData child) {  
        Decimal multiplier = assessChildcareSchedule(child);
        child.registeredAmount =0;            
        Subsidy_Info__mdt subsidy=subsidies[child.age-1];
        
        System.debug('subsidy.RegisteredforIG1:' + subsidy.RegisteredforIG1__c);
        System.debug('multiplier:' + multiplier);
        
        
        if ((subsidy!=null)&&(netIncome < rule.RegisteredIncomeLevel1__c)){
            child.registeredAmount = (subsidy.RegisteredforIG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
            System.debug('Income level 1 with registeredAmount '+child.registeredAmount);
        }
        else if ((subsidy!=null)&&(netIncome < rule.RegisteredIncomeLevel2__c)){    
            //child.registeredAmount= ((subsidy.RegisteredforIG1__c -((netIncome - rule.RegisteredIncomeLevel1__c )/12 * subsidy.RegisteredforIG2__c)).setScale(0, RoundingMode.DOWN))*multiplier/100;
            child.registeredAmount = (subsidy.RegisteredforIG1__c * (1 - ((netIncome - rule.RegisteredIncomeLevel1__c)/(rule.RegisteredIncomeLevel2__c-rule.RegisteredIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
            
            System.debug('Income level 2 with registeredAmount '+child.registeredAmount);
        }
    }

    public static void assessForHomeCare(){
        Subsidy_Info__mdt subsidy;

        Integer x=1;
        
        Integer childrenUnder19Months = 0;
        Integer childrenOver19Months = 0;
        
        Boolean H4ATriggered = false;
        Boolean H2Skipped = false;
        
        // H4A Trigger & H2 Skipping Checks
        for(MCFD_EstimatorChildData child: childList){
            if (child.noCare) {
                continue;
            }
            if(child.selectedTypeOfCare == '6'){
                if(child.age == 1) {
                    H2Skipped = true;
                }
                if(child.age < 4) {
                    H4ATriggered = true;
                }
            }
        }
        
        for(MCFD_EstimatorChildData child: childList){
            if (child.noCare) {
                continue;
            }
            
            subsidy=subsidies[child.age-1];
            Decimal multiplier = assessChildcareSchedule(child);
            // used for scenarios where child is schoolage but is in H4A, not L2 – so half days
            // should be 50%.
            Decimal multiplier2 = assessChildcareSchedule(child, 10);
            
            if(child.selectedTypeOfCare == '6'){
                System.debug('In Home Care, child age is '+ child.age +' and subsidy is '+ subsidy);
                if ((subsidy!=null)&&(child.age==1)){
                    if (childrenUnder19Months==0){//First child under 19 months                    
                        if(netIncome < rule.UnlicensedIncomeLevel1__c)
                            child.inHomeAmount = (subsidy.h1IG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN); 
                        else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                            child.inHomeAmount = (subsidy.h1IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
                        System.debug('First child under 19 months in home subsidy: '+ child.inHomeAmount);
                        childrenUnder19Months++;
                    }
                    else if (childrenUnder19Months==1){//Second child
                        if(netIncome < rule.UnlicensedIncomeLevel1__c)                        
                            child.inHomeAmount = (subsidy.h3IG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
                        else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                            child.inHomeAmount = (subsidy.h3IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);                                              
                        System.debug('Second child under 19 months in home subsidy: '+ child.inHomeAmount);
                        childrenUnder19Months++;
                    }
                    
                    else if (childrenUnder19Months>=2){//Each additional child under 19 months (multiple births, adoptions, etc)
                        if(netIncome < rule.UnlicensedIncomeLevel1__c)
                            child.inHomeAmount = (subsidy.h4IG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
                        else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                            child.inHomeAmount = (subsidy.h4IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);                                                                                          
                        System.debug('Third+ child under 19 months in home subsidy: '+ child.inHomeAmount);
                        childrenUnder19Months++;
                    }
                }
                else if ((subsidy!=null)&&(child.age >1))  {
                    
                    if (childrenOver19Months==0){//First child over 19 months
                        if((child.age == 4 && H4ATriggered) || H2Skipped) {
                            if(netIncome < rule.UnlicensedIncomeLevel1__c)
                                child.inHomeAmount = (subsidy.h4IG1__c * multiplier2 / 100).setScale(0, RoundingMode.DOWN);
                            else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                                child.inHomeAmount = (subsidy.h4IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier2 / 100).setScale(0, RoundingMode.DOWN);
                            H4ATriggered = false;
                        }
                        else {
                            if(netIncome < rule.UnlicensedIncomeLevel1__c)
                                child.inHomeAmount = (subsidy.h2IG1__c * multiplier / 100).setScale(0, RoundingMode.DOWN);
                            else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                                child.inHomeAmount = (subsidy.h2IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier / 100).setScale(0, RoundingMode.DOWN);
                        }
                        childrenOver19Months++;
                    } 
                    else if (childrenOver19Months>=1){//Each additional child over 19 months
                        if(netIncome < rule.UnlicensedIncomeLevel1__c)
                            child.inHomeAmount = (subsidy.h4IG1__c * multiplier2 / 100).setScale(0, RoundingMode.DOWN);
                        else if (netIncome < rule.UnlicensedIncomeLevel2__c)
                            child.inHomeAmount = (subsidy.h4IG1__c * (1 - ((netIncome - rule.UnlicensedIncomeLevel1__c)/(rule.UnlicensedIncomeLevel2__c-rule.UnlicensedIncomeLevel1__c))) * multiplier2 / 100).setScale(0, RoundingMode.DOWN);
                        childrenOver19Months++;
                    }    
                }
                x+=1;
            }
        }  
        
    }

    
    private static Decimal assessChildcareSchedule(MCFD_EstimatorChildData child){
    	return assessChildcareSchedule(child, null);
    }
    
    private static Decimal assessChildcareSchedule(MCFD_EstimatorChildData child, Decimal partTimeMultiplier){
        if (child.scheduleType == '1') {
            return 100;
        }
        
        Decimal multiplier = 100;
        Integer fullTimeDays = 0;
        Integer partTimeDays = 0;
        
        //Iterate through the care schedule for the child, first for number of full days, then for number of half days
        if(child.mondayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.mondayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }
        
        if(child.tuesdayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.tuesdayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }
        
        if(child.wednesdayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.wednesdayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }
        
        if(child.thursdayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.thursdayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }   
        if(child.fridayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.fridayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }   
        if(child.saturdayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.saturdayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }   
        if(child.sundayCare ==String.valueOf(2)){
            fullTimeDays +=1;
        }   
        else if (child.sundayCare ==String.valueOf(1)){
            partTimeDays+=1;
        }
        
        Integer partTimeDaysMax = 0;
        
        if (child.selectedTypeOfCare == '3') {
            // For preschool, part time days are treated as full days.
            multiplier = partTimeDays*20;           
        } else {
            multiplier = fullTimeDays*20;
            if (multiplier < 100)   {
                //A maximum of five days of care, even if some of the "days" are half days
                partTimeDaysMax = 5 - fullTimeDays;
                if (partTimeDaysMax < 0){
                    partTimeDaysMax = 0;
                }
                
                //If there is a specific partTime multiplier to use.
                if (partTimeMultiplier != null) {
                    if(partTimeDays > partTimeDaysMax)
                            multiplier = multiplier + (partTimeDaysMax * partTimeMultiplier);
                        else
                            multiplier = multiplier + (partTimeDays * partTimeMultiplier);
                } else {
                
                    if (child.age == 4) {
                        // Half Day = 83.33% of schoolage
                        if(partTimeDays > partTimeDaysMax)
                            multiplier = multiplier + (partTimeDaysMax * 16.666);
                        else
                            multiplier = multiplier + (partTimeDays * 16.666);
                    } else {
                        // Half Day = 50% of schoolage
                        if(partTimeDays > partTimeDaysMax)
                            multiplier = multiplier + (partTimeDaysMax * 10);
                        else
                            multiplier = multiplier + (partTimeDays * 10);
                    }
                }
            }
        }
        
        if (multiplier >100)
            return 100;
        else    
            return multiplier;
    }
}