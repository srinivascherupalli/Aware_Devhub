@isTest
public class OrderGridControlerTest {
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
        List<Order_Grid__c> orderGrids = TestDataFactory.getOrderGrids(new Map<Id,List<product2>>{act.Id => prodList});
        for(Order_Grid__c ordGrid : orderGrids){
            ordGrid.Order1__c = 6;
            ordGrid.Price__c = 100;
        }       
        insert orderGrids;
    }

    static testMethod void setRequiredOrder1Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order1__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 100 );                                
    }
    static testMethod void setRequiredOrder2Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order2__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 200 );                                
    }
    static testMethod void setRequiredOrder3Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order3__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 300 );                                
    }
    static testMethod void setRequiredOrder4Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order4__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 400 );                                
    }
    static testMethod void setRequiredOrder5Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order5__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 500 );                                
    }
    static testMethod void setRequiredOrder6Test() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;   
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Order6__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 600 );                                
    }
    static testMethod void setRequiredOrderPendingTest() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;  
            orderGrids.OrderPending__c = 7; 
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('OrderPending__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        
        system.assert(orderGrids[0].Total_Price__c == 700 );                                
    }
    
    static testMethod void setRequiredOrderAverageTest() {
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        Account act = [Select Id from Account limit 1];
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;  
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        
        Test.StartTest();
        OrderGridControler.getOrderList(String.valueOf(act.Id));
        OrderGridControler.setRequiredOrder('Avg_Of_Orders__c', String.valueOf(act.Id));
        Test.StopTest();
        List<Order_Grid__c> orderGrids = [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id];

        System.debug('orderGrids>>>'+orderGrids);
        //system.assert(orderGrids[0].Total_Price__c == 800 );                                
    }
    static testMethod void createOrderWithoutPreCartTest() {
        Account act = [Select Id from Account limit 1];
        String userId = String.valueOf(userinfo.getUserId());
        String deliveryDate = String.valueOf(date.today());
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;  
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10; 
            orderGrids.Order_Required__c =  15;  
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        Test.StartTest();
            OrderGridControler.createOrder(userId, string.valueOf(act.Id), deliveryDate, 'payOnline');
        Test.StopTest();
        List<WebCart> cartList = [select id , name , CreatedDate,status, ownerid  from webcart];
        System.assert(!cartList.isEmpty());
    }
    static testMethod void saveOrderLineItemTest() {
        Order_Grid__c ordrGridRecord = [Select Id From Order_Grid__c limit 1];
        Test.StartTest();
        OrderGridControler.saveOrderLineItem(String.valueOf(ordrGridRecord.Id), '2');
        Test.StopTest();
        
    }
    static testMethod void updateOrderGridTest() {
        Account act = [Select Id from Account limit 1];
        List<Order_Grid__c> orderGridsList = new List<Order_Grid__c>();
        for(Order_Grid__c orderGrids : [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                        Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                        Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: act.Id]){

            orderGrids.Order1__c = 1;
            orderGrids.Order2__c = 2;
            orderGrids.Order3__c = 3;
            orderGrids.Order4__c = 4;
            orderGrids.Order5__c = 5;
            orderGrids.Order6__c = 6;  
            orderGrids.Price__c = 100;
            orderGrids.Pack_Size__c = 10;   
            orderGridsList.add(orderGrids);                 
        }
        update orderGridsList;
        Object objectVar = (Object) orderGridsList;
        Test.StartTest();
        OrderGridControler.updateOrderGrid(objectVar);
        Test.StopTest();
    }

    static testMethod void setDeliveryDateTest(){

        //String customerUserId, String accountId, String deliveryDate
        String deliveryDate = '2021-01-01';
        List<Account> accList = [Select id from account where  name = 'TestAccount0'];
        List<User> userList = [select id from User where Alias = 'standt'];
        String accountId = accList[0].id;
        String userId = userList[0].id;
        Test.startTest();
        OrderGridControler.setDeliveryDate(userId,  accountId, deliveryDate);
        List<CartDeliveryGroup> cDeliveryGroupList = [Select id,DesiredDeliveryDate from CartDeliveryGroup Limit  1 ];
        System.assertEquals(2021, cDeliveryGroupList[0].DesiredDeliveryDate.year());
        Test.stopTest();

    }

    static testMethod void setPriceInGridTest(){
        String deliveryDate = '2021-01-01';
        List<Account> accList = [Select id from account where  name = 'TestAccount0'];
        String accountId = accList[0].id;
        Test.startTest();
        OrderGridControler.setPriceInGrid(accountId, deliveryDate);
        List<Order_Grid__c> orderGridList = [Select id,price__c from Order_Grid__c Limit  1 ];
        System.assertNotEquals(null, orderGridList[0].Price__c);
        Test.stopTest();

    }

    static testMethod void getDeliveryDaysByUserTest(){
        List<Map<String, String>> response = new List<Map<String, String>>();
        List<Account> accList = [Select id from account where  name = 'TestAccount0'];
        String accountId = accList[0].id;
        Test.startTest();
        response = DateController.getDeliveryDaysByUser(accountId);
        //List<Order_Grid__c> orderGridList = [Select id,price__c from Order_Grid__c Limit  1 ];
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
}