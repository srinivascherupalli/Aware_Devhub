/*
* 
* 
*/

@isTest
private class GROW_SiteGrainPriceViewCtrlTest {

    @testSetup
    static void setup() {

        // Insert Site
        Site__c testSite = TestDataFactory.getSite('New Test Site');
        insert testSite;
        
        Grain_Price__c grainPrice = new Grain_Price__c();
        grainPrice.Site__c = testSite.Id;
        grainPrice.Bin_Grade__c = 'binGrade';
        grainPrice.Price_Per_Metric_Tonne__c = 10;
        insert grainPrice;

        grainPrice = new Grain_Price__c();
        grainPrice.Site__c = testSite.Id;
        grainPrice.Bin_Grade__c = 'binGrade1';
        grainPrice.Price_Per_Metric_Tonne__c = 0;
        insert grainPrice;
        
    }
     
    
    @isTest
    static void testPositive(){
        GROW_SiteGrainPriceViewCtrl.getGrainPrices();
    }    


}