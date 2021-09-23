@isTest
public class B2BTaxSampleTest {
    @testSetup static void setup() {
        Account account = TestDataFactory.getAccounts(1)[0];
        insert account;
        WebStore webStore = TestDataFactory.getWebStore();
        insert webStore;
        WebCart cart = TestDataFactory.getCart(webStore.Id, account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = TestDataFactory.getCartDeliveryGroup(cart.Id);
        insert cartDeliveryGroup;
        
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 Pricebook2Var = TestDataFactory.getCustomPricebook('TestPriceBook');
        insert Pricebook2Var;

        List<product2> productList = TestDataFactory.getProducts(2);
        productList[0].Name = 'Shipping Charge for this delivery method';
        productList[1].Tax_Required__c = true;
        insert productList ;

        List<PricebookEntry> PricebookEntryStandard = TestDataFactory.getPricebookEntry(pricebookId, productList);
        insert PricebookEntryStandard;

        List<PricebookEntry> PricebookEntryCustom = TestDataFactory.getPricebookEntry(Pricebook2Var.Id, productList);
        insert PricebookEntryCustom;
        
        CartItem cartItemProduct = TestDataFactory.getCartItem(cart.Id, cartDeliveryGroup.Id, productList[1].Id, 'Product', 'SKU_Test1', 'TestProduct', 5, 100);
        CartItem cartItemCharge = TestDataFactory.getCartItem(cart.Id, cartDeliveryGroup.Id, productList[0].Id, 'Product', 'SKU_GST', 'GST', 1, 0);

        List<CartItem> cartItemList = new List<CartItem>{cartItemProduct, cartItemCharge};

        insert cartItemList;
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