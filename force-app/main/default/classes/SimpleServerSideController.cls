/**************************************************************************************
Apex Class Name     : SimpleServerSideController.cls
Version             : 1.0 
Created Date        : 03/20/2017
Function            : This class is to get the user information.
Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Fariba Taheri              03/20/2017               Original Version
*************************************************************************************/

public class  SimpleServerSideController {
	
   @AuraEnabled
    public static User getCurrentUser() {
      User toReturn = [SELECT Id, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return toReturn;
  			}
	 }