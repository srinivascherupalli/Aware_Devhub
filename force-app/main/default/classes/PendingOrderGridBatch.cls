public with sharing class PendingOrderGridBatch implements Database.Batchable<sObject>, schedulable{

    List<Order_Grid__c> orderGridtobeUpserted = new List<Order_Grid__c>();

    public Database.QueryLocator start(Database.BatchableContext context){
		String query = 'SELECT Id, Name,' + 
                        '(Select Id, Accountid, OrderedDate '+
                        'FROM Orders '+
                        'WHERE Order.status = \'On Hold\' '+
                        'Order by OrderedDate Asc limit 1)'+
						'FROM Account ';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Account> accountList){
		processOrdersForAccounts(accountList);
	}

    public void execute(SchedulableContext SC) {
        database.executebatch(new CreateDefaultOrderBatch(), integer.valueOf(Label.PenddingOrderGridBatchSize));
    }

	public void finish(Database.BatchableContext context){
		//
	}

	public void processOrdersForAccounts(List<Account> accountWithOrdersList){
		try{
             
            Set<Id> orderIdSet = new Set<Id>();
            Set<Id> accIdSet = new Set<Id>();
            List<id> orderGridDatatoDelete = new List<id>(); 
            for (Account acc : accountWithOrdersList){
              //  orderGridDatatoDelete.add(acc.id);
              accIdSet.add(acc.id);
                for (Order o : acc.Orders){
                    orderIdSet.add(o.Id);
                }
            }
         //   List<Order_Grid__c> orderGridItemstoDelete = new List<Order_Grid__c>();
         //   orderGridItemstoDelete = [Select id from Order_Grid__c where Account_Name__c in:orderGridDatatoDelete ];
         //   delete orderGridItemstoDelete;

            List<OrderItem> orderItemList = [
                SELECT Id, Order.Id,ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice, Order.OrderedDate, Product2Id, Order.Accountid
                FROM OrderItem
                WHERE Order.id IN :orderIdSet and Order.status = 'On Hold' 
                ORDER BY Order.OrderedDate Asc
            ];

            //Get the Order Grid List of Accountid.
            List<Order_Grid__c> orderGridList = [Select id,Account_Name__c, Product__c from Order_Grid__c where Account_Name__c in :accIdSet];

            //Create a map OrderItemId and Account + Product2id. This is to check if the Product is already in the Grid. 
            Map<String, Id> accProductidToOrderGridItemMap = new Map<String, Id>();
            for(Order_Grid__c orderGridObj : orderGridList){
                if(orderGridObj != null){
                    accProductidToOrderGridItemMap.put(orderGridObj.Account_Name__c+'-'+orderGridObj.Product__c, orderGridObj.id);
                }
                
            }
            //Create a list of OrderItems per account
            // and send i ta a method to add or update the Grid items for that Account.
            for(Account accObj: accountWithOrdersList ){
                List<OrderItem> neworderItemList = new List<OrderItem>();
                for(OrderItem orderItemObj: orderItemList){
                    if(orderItemObj != null ){
                        if(orderItemObj.Order.Accountid == accObj.id){
                            neworderItemList.add(orderItemObj);
                        }
                    }
                }
                //call method to add OrderItems to OrderGrid.
                addOrderItemsToGrid(neworderItemList, accProductidToOrderGridItemMap, orderGridList);

            }
                  

            upsert orderGridtobeUpserted;
        }
        catch(Exception e) {
            System.debug('.getStackTraceString():  '+e.getStackTraceString());
            System.debug('.getMessage():  '+e.getMessage());
            System.debug('.getCause():  '+e.getCause());
            System.debug('.getLineNumber():  '+ e.getLineNumber());
    
        }


	}

    public void addOrderItemsToGrid(List<OrderItem> oderItemsList, Map<String, Id> accProductidToOrderGridItemMap, List<Order_Grid__c> orderGridList){

        System.debug('oderItemsList' + oderItemsList);
        System.debug('accProductidToOrderGridItemMap' + accProductidToOrderGridItemMap);
        System.debug('orderGridList' + orderGridList);
        if(oderItemsList.size() > 0){
        for(OrderItem orderItemObj: oderItemsList){
            if(orderItemObj != null){
                String searchKey = orderItemObj.Order.Accountid +'-'+ orderItemObj.Product2id ; 
                ID orderGridItemId=  accProductidToOrderGridItemMap.get(searchKey);
                boolean found = false;
                if(orderGridList.size() > 0){
                for(Order_Grid__c orderGridObj : orderGridList){
                    if(orderGridObj != null){
                            if(orderGridObj.id == orderGridItemId){
                                found = true;
                                orderGridObj.OrderPending__c = orderItemObj.Quantity == null ? 0 : orderItemObj.Quantity;
                                orderGridObj.Order_Pending_Date__c = orderItemObj.Order.OrderedDate == null ? System.now().date() : orderItemObj.Order.OrderedDate.date();
                                orderGridtobeUpserted.add(orderGridObj);
                            }
                        }
                    }

                }
                if(!found){
                    Order_Grid__c newOrderGridObj= new Order_Grid__c();
                    newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c == null ? '' : orderItemObj.Product_Name__c;
                    newOrderGridObj.Price__c = orderItemObj.ListPrice== null ? 0 : orderItemObj.ListPrice;
                    newOrderGridObj.Code__c = orderItemObj.Product_Code__c == null ? '' :orderItemObj.Product_Code__c;
                    if(orderItemObj.Order.Accountid!= null){
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                    }
                    newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                    if(orderItemObj.Product2Id!= null){
                        newOrderGridObj.Product__c =orderItemObj.Product2Id ;
                    }
                    newOrderGridObj.OrderPending__c = orderItemObj.Quantity== null ? 0 : orderItemObj.Quantity;
                    newOrderGridObj.Order_Pending_Date__c = orderItemObj.Order.OrderedDate.date() == null ? System.now().date() :orderItemObj.Order.OrderedDate.date();
                    newOrderGridObj.Unique_Key__c = String.valueOf(orderItemObj.Order.Accountid) + String.valueOf(orderItemObj.Product2Id); 
                    orderGridtobeUpserted.add(newOrderGridObj);

                }
            }
        }
    }


    }
}