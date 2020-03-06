/*********************************************************************************************************
Name            : ICMResponseParser_Test
Description     : This class is to test ICMResponseParser.cls functions.  
Created By      : ARDC ICM
Created Date    : 08/06/2018
Modification Log: 
-------------------------------------------------------------------------------------------------------------- 
Developer       Date        Description
--------------------------------------------------------------------------------------------------------------            
Liliana Trejo   08/JUN/2018   Original version 
--------------------------------------------------------------------------------------------------------------            
***************************************************************************************************************/
@isTest(SeeAllData= false)
public class ICMResponseParser_Test {
    
    static testMethod void ICMResponseParser(){
        String jsonInput = '{\n' +
                ' "description" :"An appliance",\n' +
                ' "accessories" : [ "powerCord", ' + 
                '{ "right":"door handle1", ' + 
                '"left":"door handle2" } ],\n' +
                ' "dimensions" : ' + 
                '{ "height" : 5.5 , ' + 
                '"width" : 3.0 , ' + 
                '"depth" : 2.2 },\n' +
                ' "type" : null,\n' +
                ' "inventory" : 2000,\n' +
                ' "price" : 1023.45,\n' +
                ' "isShipped" : true,\n' +
                ' "modelNumber" : "123"\n' +
                '}';
        Test.startTest();
        	ICMResponseParser.parse(jsonInput);
        Test.stopTest();
    }
}