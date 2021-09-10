/*
* 
* 
*/

@isTest
private class GROW_SiteGrainPriceViewCtrlTest {
    
    
    @testSetup
    static void setup() {
        
        // Insert Lead
        Lead testLead = TestDataFactory.getLead();
        testLead.Delivery_Window_Start__c = system.now().addHours(2).time();
        testLead.Delivery_Window_End__c = system.now().addHours(5).time();
        testLead.Delivery_Dates__c = 'Monday;Tuesday';
        
        insert testLead;
    }
    
    @isTest
    static void testMethodcreatePrefDelDateOnLeadConvert(){
        
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'test lead' LIMIT 1];
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);

        test.startTest();

        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        test.stopTest();
    }
}