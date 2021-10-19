@istest
public class SyncStripeCardsBatchTest {

        @testSetup static void setup() {

        Account act = TestDataFactory.getAccounts(1)[0];
        act.Stripe_Customer_Id__c = 'cus_8epDebVEl8Bs2V';
        insert act;
        }

        @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new StripeCardsMockHttpResponseGenerator());

        Test.startTest();
        SyncStripeCardsBatch b = new SyncStripeCardsBatch();
        Database.executeBatch(b, 1);

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 

        List<CardPaymentMethod> cards = [Select id from CardPaymentMethod Limit 1];
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        // String actualValue = res.getBody();
        //JSONParser parser = JSON.createParser(response.getBody());
        //String expectedValue = '{"example":"test"}';
        //        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(0, cards.size());
        Test.stopTest();
        }


    
}