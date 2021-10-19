@IsTest(SeeAllData=true)
public class CancelOrderTest {

    static testMethod void testCase1() {
        
        List<Account> accountList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Test1';
        accountList.add(account1);
        
        Account account2 = new Account();
        account2.Name = 'Test1';
        accountList.add(account2);
        insert accountList;
        
        List<Product2> productList = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product1';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Product1';
        productList.add(product2);
		insert productList;
        
        OrderDeliveryMethod od = new OrderDeliveryMethod();
        od.Name = 'Standard';
        insert od;
         
        
        Order order = new Order();
        order.AccountId=accountList[0].Id;
        order.Status='Draft';
        order.EffectiveDate=date.today();
        insert order;
         
        
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();
        orderDeliveryGroup.OrderId=order.id;
        orderDeliveryGroup.OrderDeliveryMethodId=od.Id;
        orderDeliveryGroup.DeliverToName='The Shipping Address';
        insert orderDeliveryGroup;
        
         
        OrderItem orderItem = new OrderItem();
        orderItem.OrderId=order.Id;
        orderItem.OrderDeliveryGroupId = orderDeliveryGroup.Id;
        orderItem.Product2Id=productList[0].Id;
        orderItem.Quantity=1;
        orderItem.ListPrice=999;
        orderItem.UnitPrice=999;
        orderItem.TotalLineAmount=999;
        orderItem.Type='Order Product';
        insert orderItem;
         
        order = [SELECT ID FROM Order Where Id=:order.Id];
        order.Status = 'Activated';
        update order;
        
        Test.startTest();
        ConnectApi.OrderSummaryInputRepresentation osir = new
        ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=order.Id;
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor =
        ConnectApi.OrderSummaryCreation.createOrderSummary(osir);  
        
        List<OrderSummary> orderSummaryList = [
            SELECT Id
            FROM OrderSummary
        ];
        
        List<String> orderSumaryIds = new List<String>();
        for(OrderSummary os : orderSummaryList) {
            orderSumaryIds.add(os.Id);
        }
        
        CancelOrder.cancelOrder(orderSumaryIds);
        Test.stopTest();
    }

    static testMethod void testNegative() {
        Test.startTest();
        CancelOrder.cancelOrder(null);
        Test.stopTest();
    }
}