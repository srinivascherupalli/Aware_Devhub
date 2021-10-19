@istest
public class SyncStripeIdsBatchTest {

    @testSetup static void setup() {

        Account act = TestDataFactory.getAccounts(1)[0];
        act.Customer_Number__c = '6735';
        insert act;
    }

    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new StripeMockHttpResponseGenerator());

        Test.startTest();
        SyncStripeIdsBatch b = new SyncStripeIdsBatch();
        Database.executeBatch(b, 70);
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 

        Account acc = [Select id, Stripe_Customer_Id__c from Account Limit 1];
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
       // String actualValue = res.getBody();
        //JSONParser parser = JSON.createParser(response.getBody());
        //String expectedValue = '{"example":"test"}';
//        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(null, acc.Stripe_Customer_Id__c);
        Test.stopTest();
    }


}