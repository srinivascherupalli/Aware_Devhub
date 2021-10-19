/**
 * @Description : This batch process will update all Accounts in the system with Stripe id.
 *                
 */
global class SyncStripeIdsBatch implements Database.Batchable<Integer>, Database.AllowsCallouts, Database.Stateful, Schedulable {

    //This is used as a Cursor to get the next objects from Stripe. 
    String endingObjId = '';
    //Set value in while to number of Customers in Stripe
    //setting it to 7000/ 100 becuse Stripe call out can get 100 per call.  
    global Iterable<Integer> start(Database.BatchableContext context) {
        Integer[] values = new Integer[0];
        while(values.size() < 70) values.add(values.size());
        return values;
    }
    global void execute(Database.BatchableContext context, Integer[] values) {
        
        String endPoint = 'callout:Stripe/v1/customers?limit=100';
        for(Integer intObj: values)
        {
            callOutStripe(endPoint, endingObjId);
        }
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new OrderGridBatchProcess(), integer.valueOf(Label.SyncStripeIdsBatchSize));
    } 
    global void finish(Database.BatchableContext context) {
    }

    public void callOutStripe(String endPoint, String endingObjId){
        Map<String, String> customerNumbertoStripeIdMap = new Map<String, String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String compEndPoint = '';

        compEndPoint = endPoint +endingObjId;
        request.setEndpoint(compEndPoint);
        String authorizationHeader = 'Bearer '  + '{!$Credential.Password}';
        request.setheader('Authorization', authorizationHeader);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        System.debug('Response :'+ response.getStatusCode());
        if(response.getStatusCode() == 200) {
            System.debug('Received the following :'+ response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            //loop through all the responses and add the Stripe id to Account Stripe id field. 
            customerNumbertoStripeIdMap =  getStripeIds(parser);
            saveStripeIds(customerNumbertoStripeIdMap);

        }
    }

    /**Description: loop through the response and create a Map of Stripe id and Customer Number. 
     */
    public Map<String, String> getStripeIds(JSONParser parser){

      //  JSONParser parser = JSON.createParser(response.getBody());
        String stripeId = '';
        String customerNumber = '000';
        Map<String, String> customerNumbertoStripeIdMap = new Map<String, String>();
        Integer incNumber = 0; 
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    if(parser.getText() == 'id'){
                        customerNumber = customerNumber + incNumber; 
                        incNumber += incNumber +1;
                        // Get the value.
                        parser.nextToken();
                        stripeId = parser.getText();
                        endingObjId = '&starting_after='+stripeId;
                    }
                    if(parser.getText() == 'customer_number'){
                        // Get the value.
                        parser.nextToken();
                        customerNumber = parser.getText();
                        if(!String.isBlank(customerNumber)){
                            customerNumbertoStripeIdMap.put(customerNumber,stripeId);
                        }
                    }
            }
            
        }
        system.debug('StripeIds=' + stripeId);
        system.debug('customerNumber=' + customerNumber);
        system.debug('Map=' + customerNumbertoStripeIdMap);

        return customerNumbertoStripeIdMap;
    }

    public void saveStripeIds(Map<String, String> customerNumbertoStripeIdMap){
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();
        Set<String> customerNumbers = new Set<String>();

        customerNumbers = customerNumbertoStripeIdMap.keySet();

        accList = [Select id, Stripe_Customer_Id__c, Customer_Number__c from Account where Customer_Number__c in: customerNumbers ];        
        for(Account accObj: accLIst){
            accObj.Stripe_Customer_Id__c = customerNumbertoStripeIdMap.get(accObj.Customer_Number__c);
            updateAccList.add(accObj);
        }
        update updateAccList;
    }

}