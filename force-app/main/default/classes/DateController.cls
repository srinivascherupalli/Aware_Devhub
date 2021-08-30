public with sharing class DateController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getDeliveryDaysByUser() {
        List<Map<String, String>> responseList = new List<Map<String, String>>();
        Map<String, String> response = new Map<String, String>();
        try {

            Id contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
            Id accountId  = [Select AccountID from Contact where id =: contactId].AccountId;
            List<B2B_Customer_Delivery_Date__c> customerDeliveryDatesList = [
                SELECT Id, Day__c
                FROM B2B_Customer_Delivery_Date__c
                WHERE Customer__c=:accountId
            ];

            String customerDeliveryDays = '';

            for(B2B_Customer_Delivery_Date__c bb :customerDeliveryDatesList) {
                customerDeliveryDays+= bb.Day__c+',';
            }
            response.put('status', 'success');
            response.put('data', customerDeliveryDays);
            responseList.add(response);
        } catch(Exception e) {
            response.put('status','error');
            response.put('message',e.getMessage());
            responseList.add(response);
        }
        return responseList;
    }
}