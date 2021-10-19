/**
 * @Description :Utility class for CreateDefaultOrderBatch and features implemented are : 
 *               1. Used for Default Order Creation for customers.
 *               2. PreChecks before the default order creation.
 */
public class CreateDefaultOrderUtility {

    private static Id standardOrderDeliveryMethodId {
        get {
          if(standardOrderDeliveryMethodId == null) {
            standardOrderDeliveryMethodId = [Select Id From OrderDeliveryMethod Where Name ='Standard Delivery Method' limit 1].Id ; 
          }
          return standardOrderDeliveryMethodId;
        }
        private set;
    }
    private static Product2 shippingChargeForDeliveryMethod {
        get {
          if(shippingChargeForDeliveryMethod == null) {
            shippingChargeForDeliveryMethod = [Select Id, Name From Product2 Where Name ='Shipping' limit 1]; 
          }
          return shippingChargeForDeliveryMethod;
        }
        private set;
    }

    /**
     * @Description : 1.Loop through the Customers having 'default order Enabled as true'
     *                2. Fetches the related Preferred Delivery Day
     *                3. Checks the Lead Time in Days and cut off time
     *                4. Once all validations satisfies for Default order creation then creates the Order and Order line items
     *                   based on related order grid for a customer
     */
    public static void validateAndCreateDefaultOrders(List<account> accList){
        try{
            Map<Id, Account> accountMap = new Map<Id, Account>(accList);
            Map<Id, List<B2B_Customer_Delivery_Date__c>> accountWithPreferredDeliveryDayMap = new Map<Id, List<B2B_Customer_Delivery_Date__c>>();
            List<account> accountListToProcess = new List<account>();
            
            for(B2B_Customer_Delivery_Date__c deliveryDay : [SELECT Id, Customer__c, Day__c FROM B2B_Customer_Delivery_Date__c WHERE Customer__c IN : accountMap.keyset()]){
                if(accountWithPreferredDeliveryDayMap.containsKey(deliveryDay.Customer__c)){
                    List<B2B_Customer_Delivery_Date__c> deliveryDayList = new List<B2B_Customer_Delivery_Date__c>();
                    deliveryDayList = accountWithPreferredDeliveryDayMap.get(deliveryDay.Customer__c);
                    deliveryDayList.add(deliveryDay);
                }else{                    
                    accountWithPreferredDeliveryDayMap.put(deliveryDay.Customer__c, new List<B2B_Customer_Delivery_Date__c>{deliveryDay});
                }
            }
            // Loop through the account to validate if default order should be created or not

            for(Account act : accList){                
                for(B2B_Customer_Delivery_Date__c preferredDelivery : accountWithPreferredDeliveryDayMap.get(act.Id)){
                    String dayVar = preferredDelivery.Day__c ; 
                    if(act.Lead_Time_In_Days__C != null){
                        Datetime dateToMatch = System.now() -  act.Lead_Time_In_Days__C;
                        String dayOfWeek = dateToMatch.format('EEEE');
                        if(dayOfWeek.equalsIgnoreCase(dayVar)){
                            accountListToProcess.add(act);
                        }
                    }
                }
            }
            System.debug('accountListToProcess>>>>'+accountListToProcess);
            if(!accountListToProcess.isEmpty()){
                List<Account> acctList = preChecksBeforeDefaultOrderCreation(accountListToProcess);
                if(!acctList.isEmpty()){
                    Map<Id,list<Order_Grid__c>> actWithGridMap =  getOrderGridsRelatedToAccount(acctList);
                    System.debug('actWithGridMap>>>>'+actWithGridMap);
                    if(!actWithGridMap.isEmpty()){
                        createOrderAndOrderLineItems(actWithGridMap, accountMap);
                    }
                }
            }
        }Catch (Exception error){
            String failedDML = error.getMessage();               
            Exception_Log__c exceptionLog = createExceptionLog('', 'Create Defaut Order by batch Process', 'CreateDefaultOrderUtility', 'validateAndCreateDefaultOrders', failedDML);
        }
    }

    /**
     * @Description: 1.Loop throug the customer having default order enabled as true.
     *               2.Retrieve the existing orders created on the day the batch runs
     *               3.If there is any order created considering delivery day and lead time in days and cut off time , then exculde those customers
     *                 for default order creation.  
     *                      
     */
    private static List<Account> preChecksBeforeDefaultOrderCreation(List<account> accList){
        Map<Id, Account> accountMap = new Map<Id, Account>(accList);
        List<Account> actListToProcess = new List<Account>();
        Set<Id> accountsToExcludeSet = new Set<Id>();
        for(Order orderRec : [SELECT Id, accountId, CreatedDate FROM Order WHERE accountId IN : accountMap.keySet() AND createdDate >=: (date.today() -  1)]){
            Time cutOffTimeVar = accountMap.get(orderRec.accountId).Cut_Off_Time__c ;
            if(orderRec.CreatedDate.date() == system.now().date()){
                if(orderRec.createdDate.time() < cutOffTimeVar){ 
                    //accountsToExcludeSet.add(orderRec.accountId);
                }
            }else{
                    //accountsToExcludeSet.add(orderRec.accountId);
            }
            
        }
        System.debug('accountsToExcludeSet>>>>'+accountsToExcludeSet);
        for(Id act: accountMap.keySet()){
            if(!accountsToExcludeSet.contains(act)){
                actListToProcess.add(accountMap.get(act));
            }
        }
        return actListToProcess;
    }

    /**
     * @Description: 1. Loop through existing customer having default order enabled as true.
     *               2. Generate the related Order grids and creates a Map<Id,list<Order_grid__c>> for customers
     *                  
     */
    private static Map<Id,list<Order_Grid__c>> getOrderGridsRelatedToAccount(List<account> accList){
        Map<Id, Account> accountMap = new Map<Id, Account>(accList);
        Map<Id, list<Order_Grid__c>> accountWithOrderGridsMap = new Map<Id, list<Order_Grid__c>>();

        for(Order_Grid__c orderGrid : [Select Id, Account_Name__c, Account_Name__r.Name, Account_Name__r.Tax_Exemption_Account__c, Product__c, Avg_Of_Orders__c, Price__c From Order_Grid__c Where Account_Name__c IN : accountMap.keySet()]){
            if(accountWithOrderGridsMap.containsKey(orderGrid.Account_Name__c)){
                List<Order_Grid__c> orderGridList = new List<Order_Grid__c>();
                orderGridList = accountWithOrderGridsMap.get(orderGrid.Account_Name__c);
                orderGridList.add(orderGrid);
            }else{                    
                accountWithOrderGridsMap.put(orderGrid.Account_Name__c, new List<Order_Grid__c>{orderGrid});
            }
        }
        return accountWithOrderGridsMap;
    }
    /**
     * @Description : 1. Created Order and Order line items for customers using the related Order grids details
     */
    private static void createOrderAndOrderLineItems(Map<Id,list<Order_Grid__c>> accountWithOrderGridsMap, Map<Id, Account> accountMap){

        List<Order> orderList = new List<Order>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<sObject> orderWithOrderItemList = new List<SObject>();
        Map<Id,Id> customerWithRelatedStoreMap = getRelatedStoreFrontDetails(accountWithOrderGridsMap.keySet());
        createOrdersWithOrderDeliveryGroup(accountWithOrderGridsMap, accountMap);
    }

    private static void createOrdersWithOrderDeliveryGroup(Map<Id,list<Order_Grid__c>> accountWithOrderGridsMap, Map<Id, Account> accountMap){
        
        Map<Id,order> accountWithOrderMap = new Map<Id,Order>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,Order> successfullyCreatedOrdersMap = new Map<Id,Order>();
        Map<Id,String> unsuccessfulOrderCreationMap = new Map<Id,String>();
        Map<Id,OrderDeliveryGroup> orderWithDeliveryGroupMap = new Map<Id,OrderDeliveryGroup>();
        Map<Id,Id> customerWithRelatedStoreMap = getRelatedStoreFrontDetails(accountWithOrderGridsMap.keySet());
        List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();

        for(Id acctId : accountWithOrderGridsMap.keySet()){
            Order orderObject = new Order();
            orderObject.AccountId = acctId;
            orderObject.Status = 'Draft';
            orderObject.Type='Default Order';
            orderObject.EffectiveDate = date.today();
            orderObject.OrderedDate = date.today();                      
            orderObject.SalesStoreId = customerWithRelatedStoreMap.get(acctId);
            accountWithOrderMap.put(acctId, orderObject);
        }
        List<Database.SaveResult> ordersSaveResults = new List<Database.SaveResult>();
        if(!accountWithOrderMap.isEmpty()){
            ordersSaveResults = database.insert(accountWithOrderMap.values(), false);
        }
        for(Integer i=0;i<ordersSaveResults.size();i++){
            if (ordersSaveResults[i].isSuccess()){
                successfullyCreatedOrdersMap.put(accountWithOrderMap.values()[i].accountId, accountWithOrderMap.values()[i]);              
                orderMap.put(ordersSaveResults[i].getId(), accountWithOrderMap.values()[i]);
            }else if (!ordersSaveResults[i].isSuccess()){
                Exception_Log__c exceptionLog = contructExceptionLog(ordersSaveResults[i], String.valueOf(accountWithOrderMap.values()[i].accountId), 'createOrdersWithOrderDeliveryGroup');
                exceptionLogs.add(exceptionLog);
            }
        }
        // Create Order Delivery Group

        for(Order orderRec : successfullyCreatedOrdersMap.values()){
            OrderDeliveryGroup OrderDeliveryGroupVar = new OrderDeliveryGroup();
            OrderDeliveryGroupVar.OrderId = orderRec.id;
            OrderDeliveryGroupVar.OrderDeliveryMethodId = standardOrderDeliveryMethodId;
            OrderDeliveryGroupVar.DeliverToName = accountWithOrderGridsMap.get(orderRec.accountId)[0].Account_Name__r.Name;
            orderWithDeliveryGroupMap.put(orderRec.Id, OrderDeliveryGroupVar);
        }
        List<Database.SaveResult> orderDeliveryGrpSaveResults = new List<Database.SaveResult>();
        if(!orderWithDeliveryGroupMap.isEmpty()){
            orderDeliveryGrpSaveResults = database.insert(orderWithDeliveryGroupMap.values(), false);
        }
        //Handle the failure scenario

        for(Integer i=0;i<orderDeliveryGrpSaveResults.size();i++){
            if (!orderDeliveryGrpSaveResults[i].isSuccess()){
                Exception_Log__c exceptionLog = contructExceptionLog(orderDeliveryGrpSaveResults[i], String.valueOf(orderWithDeliveryGroupMap.values()[i].OrderId), 'createOrdersWithOrderDeliveryGroup');
                exceptionLogs.add(exceptionLog);
            }
        }
        List<OrderItem> orderItems = new List<OrderItem>();
        Map<Id,List<OrderItem>> orderWithLintItemMap = new Map<Id,List<OrderItem>>();
        Set<Id> productIds = new Set<Id>();
        for(Id acctId : accountWithOrderGridsMap.keySet()){
            if(successfullyCreatedOrdersMap.containsKey(acctId)){
                Order createdOrder = successfullyCreatedOrdersMap.get(acctId);
                if(orderWithDeliveryGroupMap.containsKey(createdOrder.Id)){
                    OrderDeliveryGroup createdOrderDeliveryGroup = orderWithDeliveryGroupMap.get(createdOrder.Id);
                    decimal totalAmount = 0;
                    for(Order_Grid__c orderGrid: accountWithOrderGridsMap.get(acctId)){
                        if(orderGrid.Product__c != null && orderGrid.Avg_Of_Orders__c != 0.0 && customerWithRelatedStoreMap.containsKey(acctId)){
                                    
                            OrderItem orderItemObject = new OrderItem();
                            orderItemObject.Product2Id = orderGrid.Product__c;
                            orderItemObject.UnitPrice = orderGrid.Price__c;
                            orderItemObject.Quantity = orderGrid.Avg_Of_Orders__c;
                            orderItemObject.ListPrice = orderGrid.Price__c;
                            orderItemObject.TotalLineAmount = orderGrid.Price__c;
                            orderItemObject.Type='Order Product';
                            orderItemObject.OrderId = createdOrder.Id;
                            orderItemObject.OrderDeliveryGroupId = createdOrderDeliveryGroup.Id;
                            orderItems.add(orderItemObject);
                            totalAmount = totalAmount + orderGrid.Price__c;
                        }
        
                    }
                    if(totalAmount > 0){
                        OrderItem orderItemForDeliveryCharge = new OrderItem();
                        orderItemForDeliveryCharge.Product2Id = shippingChargeForDeliveryMethod.Id;
                        orderItemForDeliveryCharge.UnitPrice = 0;
                        orderItemForDeliveryCharge.Quantity = 1;
                        orderItemForDeliveryCharge.ListPrice = 0;
                        orderItemForDeliveryCharge.TotalLineAmount = 0;
                        orderItemForDeliveryCharge.Type='Delivery Charge';
                        orderItemForDeliveryCharge.OrderId = createdOrder.Id;
                        orderItemForDeliveryCharge.OrderDeliveryGroupId = createdOrderDeliveryGroup.Id;
                        orderItems.add(orderItemForDeliveryCharge);
                        
                    }

                }
            }
        }
        System.debug('orderItems>>>>>>'+orderItems);
        List<Database.SaveResult> orderItemsSaveResults = new List<Database.SaveResult>();
        if(!orderItems.isEmpty()){
            orderItemsSaveResults = database.insert(orderItems, false);
        }

        for(Integer i=0;i<orderItemsSaveResults.size();i++){
            if (!orderItemsSaveResults[i].isSuccess()){
                Exception_Log__c exceptionLog = contructExceptionLog(orderItemsSaveResults[i], string.valueOf(orderItems[i].OrderId), 'createOrdersWithOrderDeliveryGroup');
                exceptionLogs.add(exceptionLog);
            }
        }        

        for(OrderItem orderItem : orderItems){
            productIds.add(orderItem.Product2Id);
            if(orderWithLintItemMap.containsKey(orderItem.OrderId)){
                List<OrderItem> itmList = orderWithLintItemMap.get(orderItem.OrderId);
                itmList.add(orderItem);
            }else{
                orderWithLintItemMap.put(orderItem.OrderId,  new List<OrderItem>{orderItem});
            }
        }
        Map<Id,Product2> productMaps = getProductsDetails(productIds);
        System.debug('orderWithLintItemMap>>>>>'+orderWithLintItemMap);
        List<OrderItemTaxLineItem> OrderItemTaxLineItemList = new List<OrderItemTaxLineItem>();
        for(Id ordId : orderWithLintItemMap.keySet()){
            Order orderRec = orderMap.get(ordId);
            Account accountRec = accountMap.get(orderRec.accountId);
            if(!accountRec.Tax_Exemption_Account__c){
                Id serviceDeliveryChargeId;
                for(OrderItem item : orderWithLintItemMap.get(ordId)){
                    Decimal totalAmount = (item.UnitPrice*item.Quantity) ;
                    if(productMaps.containsKey(item.Product2Id) && productMaps.get(item.Product2Id).Tax_Required__C){                    
                        OrderItemTaxLineItem OrderItemTaxLineItemVar = new OrderItemTaxLineItem();
                        OrderItemTaxLineItemVar.OrderItemId = item.Id;
                        OrderItemTaxLineItemVar.Rate = 10;
                        OrderItemTaxLineItemVar.Type = 'Actual';
                        OrderItemTaxLineItemVar.Amount = totalAmount/10;
                        OrderItemTaxLineItemVar.Name = productMaps.get(item.Product2Id).Name;
                        OrderItemTaxLineItemVar.TaxEffectiveDate = date.today();  
                        OrderItemTaxLineItemList.add(OrderItemTaxLineItemVar);  
                    }    
                    if(item.Product2Id == shippingChargeForDeliveryMethod.Id && totalAmount > 0){
                        OrderItemTaxLineItem taxLineItemVarForServiceDelivery = new OrderItemTaxLineItem();
                        taxLineItemVarForServiceDelivery.OrderItemId = serviceDeliveryChargeId;
                        taxLineItemVarForServiceDelivery.Rate = 10;
                        taxLineItemVarForServiceDelivery.Type = 'Actual';
                        taxLineItemVarForServiceDelivery.Amount = totalAmount/10;
                        taxLineItemVarForServiceDelivery.Name = 'GST';
                        taxLineItemVarForServiceDelivery.TaxEffectiveDate = date.today();  
                        OrderItemTaxLineItemList.add(taxLineItemVarForServiceDelivery);  
                    }
                    
                }
            }
        }

        List<Database.SaveResult> orderItemsTaxSaveResults = new List<Database.SaveResult>();
        if(!OrderItemTaxLineItemList.isEmpty()){
            orderItemsTaxSaveResults = database.insert(OrderItemTaxLineItemList, false);
        }

        for(Integer i=0;i<orderItemsTaxSaveResults.size();i++){
            if (!orderItemsTaxSaveResults[i].isSuccess()){
                Exception_Log__c exceptionLog = contructExceptionLog(orderItemsTaxSaveResults[i], string.valueOf(OrderItemTaxLineItemList[i].OrderItemId), 'createOrdersWithOrderDeliveryGroup');
                exceptionLogs.add(exceptionLog);
            }
        }

        if(!exceptionLogs.isEmpty()){
            database.insert(exceptionLogs, false);
        }
    }
    /**
     * @Description: Get Customer with related related linked store front
     */
    private static Map<Id,Id> getRelatedStoreFrontDetails(Set<Id> customerIds){
        Map<Id,Id> customerWithStoreFrontIdMap = new Map<Id,Id>();
        Map<Id,Id> customerWithBuyerGroupIdMap = new Map<Id,Id>();
        Map<Id,Id> BuyerGroupIdWithStoreFrontId = new Map<Id,Id>();

        for(BuyerGroupMember grpMember: [Select BuyerGroupId,BuyerId From BuyerGroupMember Where BuyerId IN : customerIds]){
            customerWithBuyerGroupIdMap.put(grpMember.BuyerId, grpMember.BuyerGroupId);
        }
        for(WebStoreBuyerGroup storeVar : [Select WebStoreId, BuyerGroupId From WebStoreBuyerGroup Where BuyerGroupId IN : customerWithBuyerGroupIdMap.values()]){
            BuyerGroupIdWithStoreFrontId.put(storeVar.BuyerGroupId, storeVar.WebStoreId);
        }

        for(Id buyerId : customerWithBuyerGroupIdMap.keySet()){
            Id buyerGrpId = customerWithBuyerGroupIdMap.get(buyerId);
            if(BuyerGroupIdWithStoreFrontId.containsKey(buyerGrpId)){
                customerWithStoreFrontIdMap.put(buyerId, BuyerGroupIdWithStoreFrontId.get(buyerGrpId));
            }          
        }
        return customerWithStoreFrontIdMap;
    }
    private static Map<Id,Product2> getProductsDetails(Set<Id> productIds){
        Map<Id,Product2> productsMap = new Map<Id,Product2>();
        for(Product2 productVar : [Select Id, Tax_Required__C, Name From Product2 Where Id IN : productIds]){
            productsMap.put(productVar.Id, productVar);
        }
        return productsMap;
    }
    public static Exception_Log__c contructExceptionLog(Database.SaveResult saveRslt, String parentId, String methodName){
        Database.Error error = saveRslt.getErrors().get(0);
        String failedDML = error.getMessage();               
        Exception_Log__c exceptionLog = createExceptionLog(parentId, 'Create Defaut Order by batch Process', 'CreateDefaultOrderUtility', methodName, failedDML);
        return exceptionLog;
    }
    private static Exception_Log__c createExceptionLog(String parentRecordId, String businessProcess, String className, String methodName, String errorMsg){
        
        Exception_Log__c exceptionRecord = new Exception_Log__c();
        exceptionRecord.Parent_Record_Id__c = parentRecordId ;
        exceptionRecord.Business_process__c = businessProcess ; 
        exceptionRecord.Class_Name__c = className ;
        exceptionRecord.Method_Name__c = methodName ; 
        exceptionRecord.Error_Message__c = errorMsg ;

        return exceptionRecord;
    }
}