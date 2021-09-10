@isTest
public class PendingOrderGridBatchTest {
    @testSetup
    static void setup() { 
        
        List<Account> accountList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Test1';
        accountList.add(account1);
        
        Account account2 = new Account();
        account2.Name = 'Test1';
        accountList.add(account2);
        insert accountList;

        List<Order> orderList = new List<Order>();
        Order order1 = new Order();
        order1.AccountId = accountList[0].Id;
        order1.Status = 'Draft';
        order1.EffectiveDate = Date.today();
        order1.OrderedDate = Date.today();
        orderList.add(order1);
        
        Order order2 = new Order();
        order2.AccountId = accountList[0].Id;
        order2.Status = 'Draft';
        order2.EffectiveDate = Date.today();
        order2.OrderedDate = (Date.today()).addMonths(-1);
        orderList.add(order2);
        
        Order order3 = new Order();
        order3.AccountId = accountList[0].Id;
        order3.Status = 'Draft';
        order3.EffectiveDate = Date.today();
        order3.OrderedDate = (Date.today()).addMonths(-2);
        orderList.add(order3);
        
        Order order4 = new Order();
        order4.AccountId = accountList[0].Id;
        order4.Status = 'Draft';
        order4.EffectiveDate = Date.today();
        order4.OrderedDate = (Date.today()).addMonths(-3);
        orderList.add(order4);
        
        Order order5 = new Order();
        order5.AccountId = accountList[0].Id;
        order5.Status = 'Draft';
        order5.EffectiveDate = Date.today();
        order5.OrderedDate = (Date.today()).addMonths(-4);
        orderList.add(order5);
        
        Order order6 = new Order();
        order6.AccountId = accountList[0].Id;
        order6.Status = 'Draft';
        order6.EffectiveDate = Date.today();
        order6.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order6);
        
        Order order7 = new Order();
        order7.AccountId = accountList[1].Id;
        order7.Status = 'Draft';
        order7.EffectiveDate = Date.today();
        order7.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order7);
        
        Order order8 = new Order();
        order8.AccountId = accountList[1].Id;
        order8.Status = 'Draft';
        order8.EffectiveDate = Date.today();
        order8.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order8);
        
        Order order9 = new Order();
        order9.AccountId = accountList[1].Id;
        order9.Status = 'Draft';
        order9.EffectiveDate = Date.today();
        order9.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order9);
        
        Order order10 = new Order();
        order10.AccountId = accountList[1].Id;
        order10.Status = 'Draft';
        order10.EffectiveDate = Date.today();
        order10.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order10);
        
        Order order11 = new Order();
        order11.AccountId = accountList[1].Id;
        order11.Status = 'Draft';
        order11.EffectiveDate = Date.today();
        order11.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order11);
        
        Order order12 = new Order();
        order12.AccountId = accountList[1].Id;
        order12.Status = 'Draft';
        order12.EffectiveDate = Date.today();
        order12.OrderedDate = (Date.today()).addMonths(-5);
        orderList.add(order12);
        
        insert orderList;
        
        List<Product2> productList = new List<Product2>();
        Product2 product1 = new Product2();
        product1.Name = 'Product1';
        productList.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'Product1';
        productList.add(product2);
		insert productList;
        
	    List<OrderItem> orderItemList = new List<OrderItem>();    
        OrderItem orderItem1 = new OrderItem();
        orderItem1.OrderId = orderList[0].Id;
        orderItem1.ListPrice = 100;
        orderItem1.Weight_kg__c = 1;
        orderItem1.Quantity = 1;
        orderItem1.Product2Id = productList[0].Id;
        orderItem1.UnitPrice = 100;
        orderItemList.add(orderItem1);
        
        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = orderList[1].Id;
        orderItem2.ListPrice = 100;
        orderItem2.Weight_kg__c = 1;
        orderItem2.Quantity = 1;
        orderItem2.Product2Id = productList[0].Id;
        orderItem2.UnitPrice = 100;
        orderItemList.add(orderItem2);
        
        OrderItem orderItem3 = new OrderItem();
        orderItem3.OrderId = orderList[2].Id;
        orderItem3.ListPrice = 100;
        orderItem3.Weight_kg__c = 1;
        orderItem3.Quantity = 1;
        orderItem3.Product2Id = productList[0].Id;
        orderItem3.UnitPrice = 100;
        orderItemList.add(orderItem3);
        
        OrderItem orderItem4 = new OrderItem();
        orderItem4.OrderId = orderList[3].Id;
        orderItem4.ListPrice = 100;
        orderItem4.Weight_kg__c = 1;
        orderItem4.Quantity = 1;
        orderItem4.Product2Id = productList[0].Id;
        orderItem4.UnitPrice = 100;
        orderItemList.add(orderItem4);
        
        OrderItem orderItem5 = new OrderItem();
        orderItem5.OrderId = orderList[4].Id;
        orderItem5.ListPrice = 100;
        orderItem5.Weight_kg__c = 1;
        orderItem5.Quantity = 1;
        orderItem5.Product2Id = productList[0].Id;
        orderItem5.UnitPrice = 100;
        orderItemList.add(orderItem5);
        
        OrderItem orderItem6 = new OrderItem();
        orderItem6.OrderId = orderList[5].Id;
        orderItem6.ListPrice = 100;
        orderItem6.Weight_kg__c = 1;
        orderItem6.Quantity = 1;
        orderItem6.Product2Id = productList[0].Id;
        orderItem6.UnitPrice = 100;
        orderItemList.add(orderItem6);
        
        OrderItem orderItem7 = new OrderItem();
        orderItem7.OrderId = orderList[6].Id;
        orderItem7.ListPrice = 100;
        orderItem7.Weight_kg__c = 1;
        orderItem7.Quantity = 1;
        orderItem7.Product2Id = productList[0].Id;
        orderItem7.UnitPrice = 100;
        orderItemList.add(orderItem7);
        
        OrderItem orderItem8 = new OrderItem();
        orderItem8.OrderId = orderList[7].Id;
        orderItem8.ListPrice = 100;
        orderItem8.Weight_kg__c = 1;
        orderItem8.Quantity = 1;
        orderItem8.Product2Id = productList[0].Id;
        orderItem8.UnitPrice = 100;
        orderItemList.add(orderItem8);
        
        OrderItem orderItem9 = new OrderItem();
        orderItem9.OrderId = orderList[8].Id;
        orderItem9.ListPrice = 100;
        orderItem9.Weight_kg__c = 1;
        orderItem9.Quantity = 1;
        orderItem9.Product2Id = productList[0].Id;
        orderItem9.UnitPrice = 100;
        orderItemList.add(orderItem9);
        
        OrderItem orderItem10 = new OrderItem();
        orderItem10.OrderId = orderList[9].Id;
        orderItem10.ListPrice = 100;
        orderItem10.Weight_kg__c = 1;
        orderItem10.Quantity = 1;
        orderItem10.Product2Id = productList[0].Id;
        orderItem10.UnitPrice = 100;
        orderItemList.add(orderItem10);
        
        OrderItem orderItem11 = new OrderItem();
        orderItem11.OrderId = orderList[10].Id;
        orderItem11.ListPrice = 100;
        orderItem11.Weight_kg__c = 1;
        orderItem11.Quantity = 1;
        orderItem11.Product2Id = productList[0].Id;
        orderItem11.UnitPrice = 100;
        orderItemList.add(orderItem11);
        
        OrderItem orderItem12 = new OrderItem();
        orderItem12.OrderId = orderList[11].Id;
        orderItem12.ListPrice = 100;
        orderItem12.Weight_kg__c = 1;
        orderItem12.Quantity = 1;
        orderItem12.Product2Id = productList[0].Id;
        orderItem12.UnitPrice = 100;
        orderItemList.add(orderItem12);
        
        insert orderItemList;
        
        List<Order_Grid__c> orderGridItemList = new List<Order_Grid__c>();
        Order_Grid__c orderGridItem1 = new Order_Grid__c();
        orderGridItem1.Account_Name__c = accountList[0].Id;
        orderGridItem1.Product__c = productList[0].Id;
        orderGridItemList.add(orderGridItem1);
        
        Order_Grid__c orderGridItem2 = new Order_Grid__c();
        orderGridItem2.Account_Name__c = accountList[1].Id;
        orderGridItem2.Product__c = productList[1].Id;
        orderGridItemList.add(orderGridItem2);
        insert orderGridItemList;
        
        orderList[0].Status = 'On Hold';
        orderList[1].Status = 'On Hold';
        orderList[2].Status = 'On Hold';
        orderList[3].Status = 'On Hold';
        orderList[4].Status = 'On Hold';
        orderList[5].Status = 'On Hold';
        orderList[6].Status = 'On Hold';
        orderList[7].Status = 'On Hold';
        orderList[8].Status = 'On Hold';
        orderList[9].Status = 'On Hold';
        orderList[10].Status = 'On Hold';
        orderList[11].Status = 'On Hold';
        update orderList;

    }
    
    
    static testMethod void testCase1() {
        Test.startTest();
        PendingOrderGridBatch b = new PendingOrderGridBatch();
        Database.executeBatch(b, 100);
        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('PendingOrderGridBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
        Test.stopTest();
    }
}