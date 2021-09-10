@isTest
public class B2BTaxSampleTest {
    @testSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            TotalPrice=100,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;

        cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_GST', 
            Quantity=1, 
            Type='Charge', 
            Name='GST',
            TotalPrice=10, 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
    }
    
    @isTest static void testCartTaxForCartItemSuccessfullyInserted() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetTaxesResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        B2BTaxSample apexSample = new B2BTaxSample();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(null, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        List<CartTax> cartTaxesForCartItem = [SELECT Id FROM CartTax WHERE CartItemId = :cartItemId];
        Test.stopTest();
    }
    
}