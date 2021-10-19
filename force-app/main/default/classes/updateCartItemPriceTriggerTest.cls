@istest
public class updateCartItemPriceTriggerTest {
  
    @testSetup static void setup() {
        OrderDeliveryMethod orderDeliveryMethodVar = TestDataFactory.getOrderDeliveryMethod(); 
        insert orderDeliveryMethodVar;

        BuyerGroup buyerGroupVar = TestDataFactory.getBuyerGroup();
        insert buyerGroupVar;

        User userObj = TestDataFactory.getUser();
        insert userObj;

        Account act = TestDataFactory.getAccounts(1)[0];
        act.Default_Order_Enabled__C = true;
        act.Lead_Time_In_Days__C = 0;
        act.Cut_Off_Time__C = Time.newinstance(11,0,0,0);
        insert act;

        BuyerAccount buyrAccount = TestDataFactory.getBuyerAccount(act.Id);
        insert buyrAccount;

        BuyerGroupMember BuyerGroupMemberVar = TestDataFactory.getBuyerGroupMember(buyerGroupVar.Id, act.Id);
        insert BuyerGroupMemberVar;

        WebStore webStoreVar = TestDataFactory.getWebStore();
        insert webStoreVar;

        WebStoreBuyerGroup webStoreBuyerGroupVar = TestDataFactory.getWebStoreBuyerGroup(webStoreVar.Id, buyerGroupVar.Id);
        insert webStoreBuyerGroupVar;

        Datetime dateToMatch = System.now();
        String dayOfWeek = dateToMatch.format('EEEE');
        B2B_Customer_Delivery_Date__c preferredDeliveryDay = TestDataFactory.getPreferredDeliveryDay(act.Id, dayOfWeek);
        insert preferredDeliveryDay;

        product2 deliveryChargeProductVar = TestDataFactory.getProducts(1)[0];
        deliveryChargeProductVar.Name = 'Shipping Charge for this delivery method';

        List<product2> prodList = TestDataFactory.getProducts(2);
        prodList[0].Tax_Required__C = true;
        prodList[1].Tax_Required__C = true;
        prodList.add(deliveryChargeProductVar);

        insert prodList;

      
//        Pricebook2 priceBookStdObj = [select id from Pricebook2 where isStandard = true Limit 1];

        List<PricebookEntry> standardPriceBookEntryList = TestDataFactory.getPricebookEntry(Test.getStandardPricebookId(), prodList);
        insert standardPriceBookEntryList; 
        Pricebook2 priceBookObj = TestDataFactory.getCustomPricebook('TestPriceBook');
        insert priceBookObj; 
        List<PricebookEntry> priceBookEntryList = TestDataFactory.getPricebookEntry(priceBookObj.id, prodList);
        insert priceBookEntryList; 
        BuyerGroupPricebook getBuyerGroupPricebook = TestDataFactory.getBuyerGroupPricebook(buyerGroupVar.id, priceBookObj.id);
        insert getBuyerGroupPricebook; 

        WebCart webCartObj = TestDataFactory.getCart(webStoreVar.id, act.id);
        insert webCartObj;

        CartDeliveryGroup cartDeliveryGroupObj = TestDataFactory.getCartDeliveryGroup(webCartObj.id);
        insert cartDeliveryGroupObj;

        CartItem cartItemObj = TestDataFactory.getCartItem(webCartObj.id, cartDeliveryGroupObj.id, prodList[0].id, 'Product', '000', 'CartItem', 1, 10);
        cartItemObj.TotalAdjustmentAmount = 0;
        insert cartItemObj;
    }

    
    static testMethod void beforeCartDeliveryGroupTest(){

        Test.startTest();
//List<CartItem> cartItemList = [select id, name from CartItem where name = 'CartItem'];
        List<WebCart> cartList = [select id, name, AccountId from WebCart where name = 'Cart'];
        List<CartDeliveryGroup> CartDeliveryGroupList = [select id, name, DesiredDeliveryDate from CartDeliveryGroup where name = 'Default Delivery'];
        Id accountId = cartList[0].AccountId;
     //   //CartItem cartItemObj = cartItemList[0];
        CartDeliveryGroup cartDeliveryGroupObj = CartDeliveryGroupList[0];
        cartDeliveryGroupObj.DesiredDeliveryDate = Date.valueOf('2022-02-01');
        update cartDeliveryGroupObj;
        List<BuyerGroupMember> buyerGroupMemList = [select id, buyerGroupId from BuyerGroupMember where buyerId =: accountId];
        system.debug('The value buyerGroupMemList: '+buyerGroupMemList);
        List<CartDeliveryGroup> CartDeliveryGroupList2 = [select id, name, DesiredDeliveryDate from CartDeliveryGroup where name = 'Default Delivery'];
        CartDeliveryGroup cartDeliveryGroupObj2 = CartDeliveryGroupList2[0];
        System.assertNotEquals(null, cartDeliveryGroupObj2.DesiredDeliveryDate);
        Test.stopTest();
    }

}