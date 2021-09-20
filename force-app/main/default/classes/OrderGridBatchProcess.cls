/**
 * @Description : Batch process looks for last six completed orders for each customer
 *                and create/update the Order grids details base on last six completed orders
 */
global class OrderGridBatchProcess implements Database.Batchable<sObject>{
	private static Product2 shippingChargeForDeliveryMethod {
        get {
          if(shippingChargeForDeliveryMethod == null) {
            shippingChargeForDeliveryMethod = [Select Id, Name From Product2 Where Name ='Shipping Charge for this delivery method' limit 1]; 
          }
          return shippingChargeForDeliveryMethod;
        }
        private set;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
		String query = 'SELECT Id, Name,' + 
                        '(Select Id, Accountid, OrderedDate, orderNumber '+
                        'FROM Orders '+
                        'WHERE Order.status = \'Completed\' '+
                        'Order by OrderedDate Asc limit 6)'+
						'FROM Account ' ;
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Account> accountList){
		processOrdersForAccounts(accountList);
	}
    public void execute(SchedulableContext SC) {
        database.executebatch(new OrderGridBatchProcess(), integer.valueOf(Label.OrderGridBatchProcessBatchSize));
    } 
	public void finish(Database.BatchableContext context){
		//
	}

    public void processOrdersForAccounts(List<Account> accountWithOrdersList){
        try{
            Set<Id> orderIdSet = new Set<Id>();
            List<id> orderGridDatatoDelete = new List<id>(); 
            Map<Id,List<OrderItem>> orderWithLineItems = new Map<Id,List<OrderItem>>();

            for (Account acc : accountWithOrdersList){
                orderGridDatatoDelete.add(acc.id);
                for (Order o : acc.Orders){
                    orderIdSet.add(o.Id);
                }
            }
            for(OrderItem items: [
                                SELECT Id, Order.Id,ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice, Order.OrderedDate, Product2Id, Order.Accountid
                                FROM OrderItem
                                WHERE Order.id IN :orderIdSet and Order.status = 'Completed'
                                ORDER BY Order.OrderedDate Asc
                            ]){
                if(items.Product_Name__c != shippingChargeForDeliveryMethod.Name){                
                    if(orderWithLineItems.containsKey(items.Order.Id) ){
                        List<OrderItem> itemList = orderWithLineItems.get(items.Order.Id);
                        itemList.add(items);
                    }else{
                        orderWithLineItems.put(items.Order.Id, new List<OrderItem>{items});
                    }
                }               
            }
            Map<string, Order_Grid__c> productWithGridItem ;
            List<Order_Grid__c> gridList = new List<Order_Grid__c>();
            Map<Date,integer> orderDateMap = new Map<Date,integer>();
            for(Account acc : accountWithOrdersList){
                productWithGridItem = new Map<String, Order_Grid__c>();
                integer i = 0;
                for(Order o : acc.Orders){
                    System.debug('order>>>'+o);
                    System.debug('i>>>'+i);
                    System.debug('productWithGridItem>>>'+productWithGridItem);
                    if(orderWithLineItems.containsKey(o.Id)){
                        for(OrderItem itm: orderWithLineItems.get(o.Id)){
                            Order_Grid__c orderGridItem ;
                            if(productWithGridItem.containsKey(itm.Product2Id)){
                                orderGridItem = productWithGridItem.get(itm.Product2Id);
                                System.debug('ExistingorderGridItem>>>'+orderGridItem);
                                integer k = 0 ;
                                System.debug('orderDateMap>>>'+orderDateMap);
                                System.debug('itm>>>'+itm);
                                if(orderDateMap.containsKey(itm.Order.OrderedDate.date())){
                                    k =  orderDateMap.get(itm.Order.OrderedDate.date());
                                }else{
                                    if(orderGridItem.Order2__c == null){
                                        k = 2;
                                    }else if(orderGridItem.Order3__c == null){
                                        k = 3;
                                    }else if(orderGridItem.Order4__c == null){
                                        k = 4;
                                    }else if(orderGridItem.Order5__c == null){
                                        k = 5;
                                    }else{
                                        k = 6;
                                    }
                                }
                                System.debug('K>>>'+k);
                                orderGridItem = updateOrderGrid(k, orderGridItem, itm);
                                orderDateMap.put(itm.Order.OrderedDate.date(),k);
                            }else{
                                orderGridItem = new Order_Grid__c();                            
                                orderGridItem.Product_Name__c = itm.Product_Name__c;
                                orderGridItem.Unique_Key__c = string.valueOf(itm.Order.Accountid) + String.valueOf(itm.Product2Id) ;
                                orderGridItem.Price__c = itm.ListPrice;
                                orderGridItem.Code__c = itm.Product_Code__c;
                                orderGridItem.Account_Name__c = itm.Order.Accountid;
                                orderGridItem.Pack_Size__c = itm.Weight_kg__c == null ? 0 : itm.Weight_kg__c;
                                orderGridItem.Product__c =itm.Product2Id;
                                orderGridItem.Order1__c = null;
                                orderGridItem.Order1_Date__c = null ;
                                orderGridItem.Order2__c = null;
                                orderGridItem.Order2_Date__c = null ;
                                orderGridItem.Order3__c = null;
                                orderGridItem.Order3_Date__c = null ;
                                orderGridItem.Order4__c = null;
                                orderGridItem.Order4_Date__c = null ;
                                orderGridItem.Order5__c = null;
                                orderGridItem.Order5_Date__c = null ;
                                orderGridItem.Order6__c = null;
                                orderGridItem.Order6_Date__c = null ;
                                i++;
                                if(orderDateMap.containsKey(itm.Order.OrderedDate.date())){
                                    integer k =  orderDateMap.get(itm.Order.OrderedDate.date());
                                    orderGridItem = updateOrderGrid(k, orderGridItem, itm);
                                }else{
                                    orderGridItem = updateOrderGrid(i, orderGridItem, itm);
                                }
                                System.debug('NeworderGridItem>>>'+orderGridItem);
                                orderDateMap.put(itm.Order.OrderedDate.date(),i);
                            }
                            
                            productWithGridItem.put(itm.Product2Id, orderGridItem);
                            System.debug('gridData>>>>'+productWithGridItem);
                            
                        }
                    }
                
                }
                gridList.addAll(productWithGridItem.values());
            }
            System.debug('gridList>>>>>'+gridList);
            Schema.SObjectField uniqueField = Order_Grid__c.Fields.Unique_Key__c;
            if(!gridList.isEmpty()){
                database.upsert(gridList, uniqueField, false);
            }
        }Catch (Exception error){
            String failedDML = error.getMessage();               
            System.debug('failedDML>>>'+failedDML);
        } 
    }

    private Order_Grid__c updateOrderGrid(integer i, Order_Grid__c orderGridItem, OrderItem itm){
        switch on i {
            when 1 {
                orderGridItem.Order1__c = itm.Quantity;
                orderGridItem.Order1_Date__c = itm.Order.OrderedDate.date();
            }                                
            when 2 {
                orderGridItem.Order2__c = itm.Quantity;
                orderGridItem.Order2_Date__c = itm.Order.OrderedDate.date();
            }
            
            when 3 {
                orderGridItem.Order3__c = itm.Quantity;
                orderGridItem.Order3_Date__c = itm.Order.OrderedDate.date();
            }
            
            when 4 {
                orderGridItem.Order4__c = itm.Quantity;
                orderGridItem.Order4_Date__c = itm.Order.OrderedDate.date();
            }
            
            when 5 {
                orderGridItem.Order5__c = itm.Quantity;
                orderGridItem.Order5_Date__c = itm.Order.OrderedDate.date();
            }
            
            when 6 {
                orderGridItem.Order6__c = itm.Quantity;
                orderGridItem.Order6_Date__c = itm.Order.OrderedDate.date();
            }
        }
        return orderGridItem;
    }
}