public class PublicHolidaysController {
    
    @AuraEnabled
    public static List<Map<String, String>> getAllPublicHolidays(String accountId) {
        List<Map<String, String>> responseList = new List<Map<String, String>>();
        Map<String, String> response = new Map<String, String> ();
        try{
            String billingState = [
                SELECT billingState 
                FROM Account 
                WHERE Id=:accountId
            ].billingState;

            List<Public_Holiday__c> publicHolidayList = [
                SELECT Id, Name, Date__c
                FROM Public_Holiday__c
                WHERE State__c=:billingState
            ];

            response.put('status', 'success');
            response.put('data', JSON.serialize(publicHolidayList));
            responseList.add(response);
        }
        catch (Exception e) {
            response.put('status', 'error');
            response.put('message', e.getMessage()+'<br/>'+e.getStackTraceString());
            responseList.add(response);
        }
        return responseList;
    }
}