@isTest
public class DiscountControllerTest {
    @testSetup
    static void setup() { 
        
       // List<Account> accountList = new List<Account>();
        Account account1 = new Account();
      //  account1.Online_Paymnet_Discount__c = true;
        account1.Online_Discount_Amount__c = 0.7;
        account1.Name = 'Test1';
       // accountList.add(account1);
        insert account1;
        Account  accObj1 = [Select id, ownerid from Account where name = 'Test1' Limit 1];
        WebCart cart = new WebCart();
       // cart.TotalAmount = 100;
        cart.name = 'CartX';                
        cart.AccountId = accObj1.id;//get from userid->Contact->Account
        cart.OwnerId = accObj1.OwnerId;//get from community userid lwc
        cart.WebStoreId = id.valueOf('0ZEO0000000CaRMOA0');//cadecode for now. 
        insert cart;

        CartDeliveryGroup deliveryGroup = new CartDeliveryGroup();
        deliveryGroup.name = 'WYDG';
        deliveryGroup.cartid = cart.id;
        deliveryGroup.DeliverToName = 'WY';
        deliveryGroup.DesiredDeliveryDate = System.now().Date();
        insert deliveryGroup;
        Product2 prod = new Product2();
        prod.name = 'Credit Cards Discount';
        prod.StockKeepingUnit = '0001';
        prod.IsActive = true;
        insert prod;
        CartItem newCartItem = new CartItem();
        newCartItem.name = 'CartItemx';
        newCartItem.type = 'Product';
        newCartItem.sku = prod.StockKeepingUnit;
        newCartItem.CartDeliveryGroupid = deliveryGroup.id;
        newCartItem.CartId = cart.id;
        newCartItem.Product2Id = prod.id;            
        newCartItem.Quantity = 1;
        newCartItem.TotalLineAmount = 100; //get from Order Grid
        newCartItem.TotalPrice = 100; //get from Order Grid
        newCartItem.ListPrice = 100;
        newCartItem.UnitAdjustedPrice =     100;
        insert newCartItem;
        
    }

    static testMethod void testAddDiscount() {
        Test.startTest();
        
        List<CartItem> cartItemList = [Select id from CartItem];
        system.assertEquals(1, cartItemList.size());
        Account accObj = [Select id from Account where name = 'Test1'];
        DiscountController.addDiscountItem(accObj.id);
        List<CartItem> cartItemList2 = [Select id from CartItem];
        system.assertEquals(2, cartItemList2.size());
        

        
        Test.stopTest();
    }
   
}