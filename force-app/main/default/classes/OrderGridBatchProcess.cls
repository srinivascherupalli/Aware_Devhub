global class OrderGridBatchProcess implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext context){
		String query = 'SELECT Id, Name,' + 
                        '(Select Id, Accountid, OrderedDate '+
                        'FROM Orders '+
                        'WHERE Order.status = \'Completed\' '+
                        'Order by OrderedDate Asc limit 6)'+
						'FROM Account WHERE Id=\'001O000001n4dBo\'' ;
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Account> accountList){
		processOrdersForAccountsV1(accountList);
	}

	public void finish(Database.BatchableContext context){
		//
	}

    public void processOrdersForAccountsV1(List<Account> accountWithOrdersList){
        Set<Id> orderIdSet = new Set<Id>();
        List<id> orderGridDatatoDelete = new List<id>(); 
        Map<Id,List<OrderItem>> orderWithLineItems = new Map<Id,List<OrderItem>>();

        for (Account acc : accountWithOrdersList){
            orderGridDatatoDelete.add(acc.id);
            for (Order o : acc.Orders){
                orderIdSet.add(o.Id);
            }
        }
        System.debug('orderIdSet>>>>'+orderIdSet);
        List<Order_Grid__c> orderGridItemstoDelete = new List<Order_Grid__c>();
        orderGridItemstoDelete = [Select id from Order_Grid__c where Account_Name__c in:orderGridDatatoDelete ];
        delete orderGridItemstoDelete;

        for(OrderItem items: [
                            SELECT Id, Order.Id,ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice, Order.OrderedDate, Product2Id, Order.Accountid
                            FROM OrderItem
                            WHERE Order.id IN :orderIdSet and Order.status = 'Completed'
                            ORDER BY Order.OrderedDate Asc
                        ]){
             if(orderWithLineItems.containsKey(items.Order.Id)){
                List<OrderItem> itemList = orderWithLineItems.get(items.Order.Id);
                itemList.add(items);
             }else{
                orderWithLineItems.put(items.Order.Id, new List<OrderItem>{items});
             }               
        }
        Map<string, Order_Grid__c> productWithGridItem ;
        List<Order_Grid__c> gridList = new List<Order_Grid__c>();
        for(Account acc : accountWithOrdersList){
            productWithGridItem = new Map<String, Order_Grid__c>();
            integer i = 1;
            for(Order o : acc.Orders){
                System.debug('order>>>'+o);
                System.debug('i>>>'+i);
                System.debug('productWithGridItem>>>'+productWithGridItem);
                for(OrderItem itm: orderWithLineItems.get(o.Id)){
                    Order_Grid__c orderGridItem ;
                    if(productWithGridItem.containsKey(itm.Product2Id)){
                        orderGridItem = productWithGridItem.get(itm.Product2Id);
                        i++;                        
                    }else{
                        orderGridItem = new Order_Grid__c();
                        orderGridItem.Product_Name__c = itm.Product_Name__c;
                        orderGridItem.Price__c = itm.ListPrice;
                        orderGridItem.Code__c = itm.Product_Code__c;
                        orderGridItem.Account_Name__c = itm.Order.Accountid;
                        orderGridItem.Pack_Size__c = itm.Weight_kg__c == null ? 0 : itm.Weight_kg__c;
                        orderGridItem.Product__c =itm.Product2Id;
                    
                    }
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
                    productWithGridItem.put(itm.Product2Id, orderGridItem);
                    System.debug('gridData>>>>'+productWithGridItem);
                    
                }
                i++;
            }
            gridList.addAll(productWithGridItem.values());
        }
        System.debug('gridList>>>>>'+gridList);
        if(!gridList.isEmpty()){
            upsert gridList;
        }
    }
	public void processOrdersForAccounts(List<Account> accountWithOrdersList){
		//try{
            System.debug('accountWithOrdersList>>>>>'+accountWithOrdersList); 
            Set<Id> orderIdSet = new Set<Id>();
            List<id> orderGridDatatoDelete = new List<id>(); 
            for (Account acc : accountWithOrdersList){
                orderGridDatatoDelete.add(acc.id);
                for (Order o : acc.Orders){
                    orderIdSet.add(o.Id);
                }
            }
            System.debug('orderIdSet>>>>'+orderIdSet);
            List<Order_Grid__c> orderGridItemstoDelete = new List<Order_Grid__c>();
            orderGridItemstoDelete = [Select id from Order_Grid__c where Account_Name__c in:orderGridDatatoDelete ];
            delete orderGridItemstoDelete;

            List<OrderItem> orderItemList = [
                SELECT Id, Order.Id,ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice, Order.OrderedDate, Product2Id, Order.Accountid
                FROM OrderItem
                WHERE Order.id IN :orderIdSet and Order.status = 'Completed'
                ORDER BY Order.OrderedDate Asc
            ];
            System.debug('orderItemList>>>>'+orderItemList);
            
            Map<String, Integer> orderDateAndSortOrderMap = new Map<String, Integer>();
            
            for(Account acc : accountWithOrdersList){
                if(acc.Orders.size() >0) {
                    for(Integer i=0; i<acc.Orders.size(); i++) {
                        orderDateAndSortOrderMap.put(String.valueOf(acc.Id+'#'+acc.Orders[i].Id+'#'+acc.Orders[i].OrderedDate), i);
                    }
                }
            }
            System.debug('orderDateAndSortOrderMap>>>>'+orderDateAndSortOrderMap);
            List<Order_Grid__c> orderGridList = new List<Order_Grid__c>();
            Order_Grid__c orderGridItem = new Order_Grid__c();
            
            for (OrderItem orderItemObj : orderItemList){
                
                orderGridItem = new Order_Grid__c();
                String sortOrder = orderItemObj.Order.AccountId+'#'+orderItemObj.OrderId+'#'+orderItemObj.Order.OrderedDate;
                orderGridItem.Product_Name__c = orderItemObj.Product_Name__c;
                orderGridItem.Price__c = orderItemObj.ListPrice;
                orderGridItem.Code__c = orderItemObj.Product_Code__c;
                orderGridItem.Account_Name__c = orderItemObj.Order.Accountid;
                orderGridItem.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                orderGridItem.Product__c =orderItemObj.Product2Id;
                System.debug('sortOrder>>>>>'+sortOrder);
                switch on orderDateAndSortOrderMap.get(sortOrder) {
                    when 0 {
                        orderGridItem.Order1__c = orderItemObj.Quantity;
                        orderGridItem.Order1_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    
                    when 1 {
                        orderGridItem.Order2__c = orderItemObj.Quantity;
                        orderGridItem.Order2_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    
                    when 2 {
                        orderGridItem.Order3__c = orderItemObj.Quantity;
                        orderGridItem.Order3_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    
                    when 3 {
                        orderGridItem.Order4__c = orderItemObj.Quantity;
                        orderGridItem.Order4_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    
                    when 4 {
                        orderGridItem.Order5__c = orderItemObj.Quantity;
                        orderGridItem.Order5_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    
                    when 5 {
                        orderGridItem.Order6__c = orderItemObj.Quantity;
                        orderGridItem.Order6_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                }
                orderGridList.add(orderGridItem);
            }
            System.debug('orderGridList>>>>'+orderGridList);
            upsert orderGridList;
        //}
        //catch(Exception e) {
            
        //}
	}
}