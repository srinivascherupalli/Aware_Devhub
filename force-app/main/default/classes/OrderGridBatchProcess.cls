global class OrderGridBatchProcess implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext context){
		String query = 'SELECT Id, Name,' + 
                        '(Select Id, Accountid, OrderedDate '+
                        'FROM Orders '+
                        'WHERE Order.status = "Completed" '+
                        'ORDER BY OrderedDate Asc LIMIT 6)'+
						'FROM Account';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Account> accountList){
		processOrdersForAccounts(accountList);
	}

	public void finish(Database.BatchableContext context){
		//
	}

	public void processOrdersForAccounts(List<Account> accountWithOrdersList){
		try{
             
            Set<Id> orderIdSet = new Set<Id>();
            for (Account acc : accountWithOrdersList){
                for (Order o : acc.Orders){
                    orderIdSet.add(o.Id);
                }
            }
            
            List<OrderItem> orderItemList = [
                SELECT Id, Order.Id,ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice, Order.OrderedDate, Product2Id, Order.Accountid
                FROM OrderItem
                WHERE Order.id IN :orderIdSet and Order.status = 'Completed'
                ORDER BY Order.OrderedDate Asc
            ];
            
            Map<String, Integer> orderDateAndSortOrderMap = new Map<String, Integer>();
            
            for(Account acc : accountWithOrdersList){
                if(acc.Orders.size() >0) {
                    for(Integer i=0; i<acc.Orders.size(); i++) {
                        orderDateAndSortOrderMap.put(String.valueOf(acc.Id+'#'+acc.Orders[i].Id+'#'+acc.Orders[i].OrderedDate), i);
                    }
                }
            }
            
            List<Order_Grid__c> orderGridList = new List<Order_Grid__c>();
            Order_Grid__c orderGridItem = new Order_Grid__c();
            
            for (OrderItem orderItemObj : orderItemList){
                
                orderGridItem = new Order_Grid__c();
                String sortOrder = orderDateAndSortOrderMap.get(orderItemObj.Order.AccountId+'#'+orderItemObj.OrderId+'#'+orderItemObj.Order.OrderedDate);
                orderGridItem.Product_Name__c = orderItemObj.Product_Name__c;
                orderGridItem.Price__c = orderItemObj.ListPrice;
                orderGridItem.Code__c = orderItemObj.Product_Code__c;
                orderGridItem.Account_Name__c = orderItemObj.Order.Accountid;
                orderGridItem.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                orderGridItem.Product__c =orderItemObj.Product2Id;

                
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
            upsert orderGridList;
        }
        catch(Exception e) {
            
        }
	}
}