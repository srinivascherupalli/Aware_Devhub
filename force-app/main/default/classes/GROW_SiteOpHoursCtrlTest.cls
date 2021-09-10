/*
* 
* 
*/

@isTest
private class GROW_SiteOpHoursCtrlTest {
    
    
    @testSetup
    static void setup() {
        
        // Insert Site
        Site__c testSite = TestDataFactory.getSite('New Test Site');
        insert testSite;
        
        // Insert Operation hours
        List<Operation_Hours__c> lstOPHours = new List<Operation_Hours__c>();
        
        Operation_Hours__c opHours1 = TestDataFactory.getOperationHours(testSite.Id);
        opHours1.Name = 'Monday';
        opHours1.Open_Time__c = System.now().time();
        opHours1.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours1);
        
        Operation_Hours__c opHours2 = TestDataFactory.getOperationHours(testSite.Id);
        opHours2.Name = 'Tuesday';
        opHours2.Open_Time__c = System.now().time();
        opHours2.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours2);
        
        Operation_Hours__c opHours3 = TestDataFactory.getOperationHours(testSite.Id);
        opHours3.Name = 'Wednesday';
        opHours3.Open_Time__c = System.now().time();
        opHours3.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours3);
        
        Operation_Hours__c opHours4 = TestDataFactory.getOperationHours(testSite.Id);
        opHours4.Name = 'Thursday';
        opHours4.Open_Time__c = System.now().time();
        opHours4.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours4);
        
        Operation_Hours__c opHours5 = TestDataFactory.getOperationHours(testSite.Id);
        opHours5.Name = 'Friday';
        opHours5.Open_Time__c = System.now().time();
        opHours5.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours5);
        
        Operation_Hours__c opHours6 = TestDataFactory.getOperationHours(testSite.Id);
        opHours6.Name = 'Saturday';
        opHours6.Open_Time__c = System.now().time();
        opHours6.Closing_Time__c = system.now().addHours(3).time();
        lstOPHours.add(opHours6);
        
        Operation_Hours__c opHours7 = TestDataFactory.getOperationHours(testSite.Id);
        opHours7.Name = 'Sunday';
        opHours7.Open_Time__c = System.now().time();
        // opHours7.Closing_Time__c = system.now().addHours(3).time(); // Closing time not set to evaluate the condition for null value for time
        lstOPHours.add(opHours7);
        
        database.insert(lstOPHours);
    }
    
    @isTest
    static void testMethodGetSites(){
        
        test.startTest();
        
        List<GROW_SiteOpHoursCtrl.SiteWrapper> lstWrapper = GROW_SiteOpHoursCtrl.getSites();
        
        test.stopTest();
    }
}