@isTest
private class CreateDefaultOrderBatchTest {
    @testSetup static void setup() {
        
        OrderDeliveryMethod orderDeliveryMethodVar = TestDataFactory.getOrderDeliveryMethod(); 
        insert orderDeliveryMethodVar;

        BuyerGroup buyerGroupVar = TestDataFactory.getBuyerGroup();
        insert buyerGroupVar;

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
    static testMethod void CreateDefaultOrderBatchTest() 
    {   Account act = [Select Id from Account Limit 1];
        Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        Test.StartTest();
            CreateDefaultOrderBatch batchVar = new CreateDefaultOrderBatch();
            batchVar.execute(null);
            Exception_Log__c exceptionLog = CreateDefaultOrderUtility.contructExceptionLog(sr, act.Id, 'TestName');
        Test.StopTest();
        
        Order orderRecord = [Select Id from Order where accountId =: act.Id];
        system.assert(orderRecord != null);
        system.assert(exceptionLog.Parent_Record_Id__c== act.Id);
    }
}