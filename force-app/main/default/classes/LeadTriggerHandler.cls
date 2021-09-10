//LeadTriggerHandler class
public with sharing class LeadTriggerHandler extends TriggerHandler {
    
    private Map<Id, Lead> newObjMap;
    private Map<Id, Lead> oldObjMap;
    private List<Lead> newObjList;
    private List<Lead> oldObjList;
    private Lead oldLead;
    
    public LeadTriggerHandler() {
        this.newObjMap = (Map<Id, Lead>) Trigger.newMap;
        this.newObjList = (List<Lead>) Trigger.new;
        this.oldObjMap = (Map<Id, Lead>) Trigger.oldMap;
        this.oldObjList = (List<Lead>) Trigger.old;
    }
    
    public override void beforeInsert() {
        //Trigger logic
    }
    
    public override void beforeUpdate() {
        //Trigger logic
    }
    
    public override void beforeDelete() {
        //Trigger logic
    }
    
    public override void afterInsert() {
        //Trigger logic
    }
    
    public override void afterUpdate() {
        
        List<Lead> lstConvertedLeads = new List<Lead>();
        
        for(Lead newLead: newObjList){
            oldLead = oldObjMap.get(newLead.Id);
            
            // [03-Sept-2021 - Mansoor] Create Preferred Delivery Day records when Lead is converted
            if(newLead.IsConverted && newLead.IsConverted != oldLead.IsConverted){
                
                // [03-Sept-2021 - Mansoor] Create a list of all converted leads and then pass it to separate method for processing
                lstConvertedLeads.add(newLead);
            }
        }
        
        if(lstConvertedLeads.size() > 0){
            createPreferredDeliveryDayRecords(lstConvertedLeads);
        }
    }
    
    public override void afterDelete() {
        //Trigger logic
    }
    
    public override void afterUndelete() {
        //Trigger logic
    }
    
    
    
    
    /**************	Helper Methods **************/
    
    private static void createPreferredDeliveryDayRecords(List<Lead> lstLeadsPrm){
        
        B2B_Customer_Delivery_Date__c prefDeliveryDay;
        List<Account> lstAccounts = new List<Account>();
        List<B2B_Customer_Delivery_Date__c> lstPrefDeliveryDaystoInsert = new List<B2B_Customer_Delivery_Date__c>();
        
        lstAccounts = [SELECT Id, Delivery_Dates__c, Delivery_Window_Start__c, Delivery_Window_End__c, Delivery_Details__c 
                       FROM Account
                       WHERE Id IN (SELECT ConvertedAccountId FROM Lead WHERE Id IN:lstLeadsPrm)
                       LIMIT 1000];
        
        for(Lead newLead: lstLeadsPrm){
            
            // Split the multi-picklist values into the separate selected values 
            List<String> selections = newLead.Delivery_Dates__c != null ? newLead.Delivery_Dates__c.split(';') : null;
            
            // Loop on the selected days and create corresponding Preferred Days Records\
            if (selections != null && !selections.isEmpty()) {
                for(String dayName : selections){
                    prefDeliveryDay = new B2B_Customer_Delivery_Date__c();
                    prefDeliveryDay.Day__c = dayName;
                    prefDeliveryDay.Time_from__c = newLead.Delivery_Window_Start__c;
                    prefDeliveryDay.Time_to__c = newLead.Delivery_Window_End__c;
                    prefDeliveryDay.Customer__c = newLead.ConvertedAccountId;
                    
                    lstPrefDeliveryDaystoInsert.add(prefDeliveryDay);
                }
            } 
        }
        
        if(lstPrefDeliveryDaystoInsert.size() > 0){
            database.insert(lstPrefDeliveryDaystoInsert);
        }
    }
}