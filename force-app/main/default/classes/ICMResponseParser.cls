/*
Description       :   This class is to parse the JSON response from ICM.
Created By        :   Deloitte
Modification Log  :
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Developer         Date                Description
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -          
Abhimanyu            May 26 2018            Created . Commented out the attribute as it is not required. Uncomment the attribute, if needed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -            
*/

public class ICMResponseParser{
    
    public docPortalResponse docPortalResponse;
    
    public  class docPortalResponse {
        public HlsCase[] HlsCase;
    }
    public  class HlsCase {
        public String CaseNum;  //1-9762834368
        public String Status;   //Open
        public String Type; //Child Care Subsidy
        public String SpouseLivingAway; //N
        public String SpousalConsentFlagCalc;   //N
        public String TranslatorRequired;   //N
        public String TotalMonthlyIncome;   //0
        public String IncomeLastVerifiedDate;   //
        public String DocumentsOutstanding; //
        public String DocumentsComments;    //
        public String FAIRCCompleted;   //
        public String RenewReviewDate;  //
        public String RowId;    //1-4HGJF7K
        public PubCaseBenefitPlan[] PubCaseBenefitPlan;
        public cls_Contact[] Contact;
        public cls_Attachment[] Attachment;
        public Consent[] Consent;
        
    }
    public class Income {
    	public String IncomeType;
    	public String RowId;
    	public String SubType;
    	public String Source;
    	public String Amount;
    	public String Frequency;
    	public String StartDate;
    	public String EndDate;
    	public String CaseType;
    	public String SamplePayFrequency;
    	public String ConversionFactor;
    	public String Sample1DatePaid;
    	public String Sample1PayPeriodStart;
    	public String Sample1PayPeriodEnd;
    	public String Sample1NetPay;
    	public String Sample1GrossPay;
    	public String Sample1AddBack;
    	public String Sample1TotalAmount;
    	public String NoSample2Flag;
    	public String Sample2DatePaid;
    	public String Sample2PayPeriodStart;
    	public String Sample2PayPeriodEnd;
    	public String Sample2NetPay;
    	public String Sample2AddBack;
    	public String Sample2TotalAmount;
    	public String TotalNetPay;
    	public String Sample2Deduction;
    	public String Sample1Deduction;
    	public String Sample2GrossPay;
    	public String TotatAdjustments;
    	public String TotalIncome;
    	public String TaxYear;
    	public String CRARequestNumber;
    	    	
    }
    public class PubCaseBenefitPlan {
      /*  public String AllocationAmount; //0
        public String ApprovedBy;   //
        public String ApprovedDate; //
        public String ApprovedOrders;   //
        public String BenefitPlanNum;   //1-9764261508
        public String BenefitPlanType;  //Benefit Plan
        public String CloseReason;  //
        public String Comments; //
        public String Commitment;   //0
        public String CreatedByOffice;  //MCFD
        public String EndPeriod;    //Dec 2019
        public String FamilyIncome; //
        public String FamilyType;   //
        public String InCycleAllocationCalc;    //0
        public String InCycleRemainderCalc; //0
        public String LockedFlag;   //N
        public String OutofCycleAllocationCalc; //0
        public String OutofCycleRemainderCalc;  //24
        public String PlanExpiryDate;   //12/31/2019
        public String PlanName; //
        public String PlanStartDate;    //05/01/2018
        public String ProgramArea;  //
        public String ProgramLength;    //
        public String ProgramName;  //CCS Benefit Plan
        public String RemainderAmount;  //24
        public String ServicePlan;  //
        public String StartPeriod;  //May 2018
        public String Status;   //Approved
        public String SystemComments;   //
        public String TotalAmount;  //24
        public String TotalInCycleAmountCalc;   //
        public String TotalOutofCycleAmountCalc;    //24
        public String TransitArea;  //
        public String TransitRate;  //
        public String RowId;    //1-4HHE0EC
        public String VSFTotalAmount;   //0
        */
        public PubCaseBenefitPlanLineItem[] PubCaseBenefitPlanLineItem; 
    }
    class PubCaseBenefitPlanLineItem {
      /*  public String ActualAmount; 
      //
        public String BenefitAmount;    //24
        
        public String BenefitId;    //1-9YC-155
        public String BenefitName2; //Licensed Family
        public String CFCSAmount;   //
        public String CancellationDate; //
        public String CaseOfficeName;   //HUC - Centralized Services Hub
        public String Comments; //
        public String CostCare; //
        public String CreatedByOffice;  //MCFD
        public String EffectiveDate;    //05/01/2018
        public String EstimatedAmount;  //
        public String ExpirationDate;   //05/31/2018
        public String FamilyUnitFlag;   //N
        public String FirstPaymentDate; //
        public String Frequency;    //Monthly
        public String FullDayRate;  //
        public String FullDays; //
        public String Funder;   //
        public String HalfDayRate;  //
        public String HalfDays; //
        public String InCycleFlag;  //N
        public String LockedFlag;   //N
        public String OPAAmountPaid;    //
        public String OPABenefitMonth;  //
        public String OPADeterminedAmount;  //
        public String OPAMaritalStatus; //
        public String OverriddenBy; //
        public String OverrideDate; //
        public String OverrideFlag; //N
        public String ParentPortionAmount;  //
        public String Period;   //May 2018
        public String PeriodAdjusted;   //
        public String Product;  //J1
        public String ProductSTOB;  //7916
        public String ProductServiceId; //
        public String ProviderName; //1-42112966
        public String Quantity; //
        public String ReasonCare;   //
        public String RecipientContactFirstName;    //Rocket
        public String RecipientContactLastName; //Racoon
        public String RecipientContactId;   //1-4HGJAVV
        public String RecipientContactMiddleName;   //checl
        public String RecurringPaymentAmount;   //
        public String ServiceLocationType;  //
        public String ServiceRequestId; //
        public String Status;   //Approved
        public String SupervisorApprovalFlag;   //N
        public String SystemComments2;  //
        public String Type; //
        public String UnitofMeasure;    //
        public String YPPAmount;    //
        public String RowId;    //1-4HHMWD6
        */
        public String UnitAmount;   //24
        public String TransitionAdjustment; //15 */
    }
    public class cls_Contact {
    	
       public String ICMContactId;
       public String Relationship;
       public String SpecialNeedsStatus; 
      /*  public String SIN;  //329626378
        public String Gender;   //Female
        public String MiddleName;   //abc
        public String ICMContactId; //1-36OIMNP
        public String BirthDate;    //10/20/1946
        public String FirstName;    //CHILD1
        public String LastName; //"R32-CCS-GD->36mths"
        public String SpecialNeedsStatus;   //
        public String ChildCareRequired;    //N
        public String MinistryPlacementStatus;  //N
        public String SharedCustodyStatus;  //N
        public String CustodyDetail;    //
        public String DisabilityStatus; //
        public String Email;    //
        public String CellPhone;    //
        public String HomePhone;    //
        public String WorkPhone;    //
        public String SPEIClient;   //N
        public String PlacementType;    //
        public String CareRequired; //N
        public String BCAssistance; //N
        public String FederalBenefits;  //N
        public String MoreThan1Case;    //N
        */
        public String IncomePath;   //
        public Income[] Income;
        public CRARequest[] CRARequest; 
    }
    class CRARequest {
        public String RowId;    //1-4HHOJKP
        public String TaxYear;  //2017
        public String ReasonForRequest; //
        public String DateRequested;    //05/14/2018 21:24:47
        public String ConsentConfirmed; //N
        public String LegalRepresentative;  //N
        public String Status;   //Pending
        public String ConsentConfirmedBy;   //
        public String PersonIdICM;  //1-6934324021
        public String LastName; //"R32-CCS-GD->36mths"
        public String FirstName;    //CHILD1
        public String MiddleName;   //abc
        public String ResponseText; //
        public String ErrorDescription; //
        public String IntegrationState; //
        public String IVRequestCount;   //1
        public String CRARequestNumber; //1-9764752921
        public String ReassessmentCount;    //
        public String ReassessmentDate; //
        public String CreatedByLogin;   //AKKAMATA
        public String MaritalStatus;    //
        public String CRAInactiveFlag;  //N
        public String TotalIncome;  //
        public String SocialAssistancePayment;  //
        public String UpdatedSIN;   //
        public String SIN;  //329626378
        public String CaseNumber;   //1-9762834368
        public String DateOfBirth;  //10/20/1946 
    }
    public class cls_Attachment {
    
        public String Type; //Document
        public String Template; //
        public String FileName; //output
        public String Status;   //Profiled
        public String Category; //Assessment
        public String SubCategory;  //Career Assessment
        public String RowId;    //1-4HHDGY4
        public String FormDescription;  //
    }
    public class Consent {
        public String EndDate;  //05/15/2018 00:00:00
        public String SubType;  //Consent to collect from CRA
        
        //public String RowId;    //1-4HH1O43
        public String CreatedByName;    //AKKAMATA
        public String CaseNumber;   //1-9762834368
        public String Status;   //Open
        public String StartDate;    //05/08/2018 21:13:32
        
        public String DueDate;  //
        public String Description;  //see this
        public String FromContact;  //
        public String PrimaryContactId; //No Match Row Id
        public String ToContact;    //Racoon
        public String PrimaryToContactId;   //1-4HGJAVV
        public String Created;  //05/08/2018 21:13:32
    }
    public static ICMResponseParser parse(String json){
        
        ICMResponseParser response = (ICMResponseParser) System.JSON.deserialize(json, ICMResponseParser.class);
        system.debug('======='+response);
        return response;
    }
    
    
    
}