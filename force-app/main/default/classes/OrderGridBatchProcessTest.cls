@isTest
public class OrderGridBatchProcessTest {
    @testSetup static void setup() {
        Account act = TestDataFactory.getAccounts(1)[0];
        insert act;

        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 Pricebook2Var = TestDataFactory.getCustomPricebook('TestPriceBook');
        insert Pricebook2Var;

        List<product2> productList = TestDataFactory.getProducts(7);
        productList[0].Name = 'Shipping Charge for this delivery method';
        insert productList ;
        System.debug('productList>>>'+productList);

        List<PricebookEntry> PricebookEntryStandard = TestDataFactory.getPricebookEntry(pricebookId, productList);
        insert PricebookEntryStandard;

        List<PricebookEntry> PricebookEntryCustom = TestDataFactory.getPricebookEntry(Pricebook2Var.Id, productList);
        insert PricebookEntryCustom;

        List<Order> orderList = TestDataFactory.getOrders(7, act.Id, Pricebook2Var.Id); 
        insert orderList;

        List<OrderItem> orderItemList = new List<OrderItem>();
        integer i = 0;
        Map<Id,Id> productWithEntryMap = new Map<Id,Id>();
        for(PricebookEntry PricebookEntryVar :[Select Id, Product2Id From PricebookEntry]){
            productWithEntryMap.put(PricebookEntryVar.Product2Id, PricebookEntryVar.Id);
        }
        for(Order ord: orderList){
            OrderItem OrderItemVar = TestDataFactory.getOrderItem(ord.Id, productList[i].Id, productWithEntryMap.get(productList[i].Id));
            orderItemList.add(OrderItemVar);
            if(i==3){
                OrderItem OrderItemVarClone = TestDataFactory.getOrderItem(ord.Id, productList[i].Id, productWithEntryMap.get(productList[i].Id));
                orderItemList.add(OrderItemVarClone);
            }
            i++;
        }
        insert orderItemList;
        System.debug('orderItemList>>>'+orderItemList);
        for(Order ord: orderList){
            ord.status = 'Completed';
        }
        
        update orderList;    
    }
    static testMethod void createOrderGridBatchProcessTest() {
        Test.StartTest();
            OrderGridBatchProcess batchVar = new OrderGridBatchProcess();
            batchVar.execute(null);
        Test.StopTest();
        List<Order_Grid__c> grildList = [Select Id from Order_Grid__c];
        System.assert(grildList.size() == 5 );
    }
}