public with sharing class PastOrdersGridBatch implements Database.Batchable<sObject>{

    List<Order_Grid__c> orderGridtobeUpserted = new List<Order_Grid__c>();

    public Database.QueryLocator start(Database.BatchableContext context){
		String query = 'SELECT Id, Name,' + 
                        '(Select Id, Accountid, OrderedDate '+
                        'FROM Orders '+
                        'WHERE Order.status = \'Completed\' '+
                        'Order by OrderedDate DESC limit 6)'+
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
            Set<Id> accIdSet = new Set<Id>();
            List<Order> lastSixOrder = new List<Order>();
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
                WHERE Order.id IN :orderIdSet and Order.status = 'Completed'
                ORDER BY Order.OrderedDate Asc
            ];

            //Get the Order Grid List of Accountid.
            List<Order_Grid__c> orderGridList = [Select id,Account_Name__c, Product__c from Order_Grid__c where Account_Name__c in :accIdSet];

            //Create a map  Account + Product2id as key and value id Order Grid Item id. 
            Map<String, Id> accProductidToOrderGridItemMap = new Map<String, Id>();
            for(Order_Grid__c orderGridObj : orderGridList){
                accProductidToOrderGridItemMap.put(orderGridObj.Account_Name__c+'-'+orderGridObj.Product__c, orderGridObj.id);
                
            }
            //Create a list of OrderItems per account
            
            for(Account accObj: accountWithOrdersList ){
                List<OrderItem> neworderItemList = new List<OrderItem>();
                List<Order_Grid__c> newOrderGridList = new List<Order_Grid__c>();
                List<Order> newLastSixOrderList = new List<Order>();
                for(OrderItem orderItemObj: orderItemList){
                    if(orderItemObj.Order.Accountid == accObj.id){
                        neworderItemList.add(orderItemObj);
                    }
                }
                for(Order_Grid__c  orderGridObj: orderGridList){
                    if(orderGridObj.Account_Name__c == accObj.id){
                        newOrderGridList.add(orderGridObj);
                    }
                }
                for (Order orderObj : accObj.Orders){
                    newLastSixOrderList.add(orderObj);
                }
                //call method to add OrderItems to OrderGrid.
                addOrderItemsToGrid(neworderItemList, accProductidToOrderGridItemMap, newOrderGridList,newLastSixOrderList);

            }
                  
            System.debug('Just before upsert: '+orderGridtobeUpserted);
            upsert orderGridtobeUpserted;
        }
        catch(Exception e) {
            
        }


	}

    public void addOrderItemsToGrid(List<OrderItem> oderItemsList, Map<String, Id> accProductidToOrderGridItemMap, List<Order_Grid__c> orderGridList, List<Order> LastSixOrders){

        Map<id, Order_Grid__c> orderGridIdandObjMap = new Map<id, Order_Grid__c >();
        for(OrderItem orderItemObj: oderItemsList ){
            String searchKey = orderItemObj.Order.Accountid +'-'+ orderItemObj.Product2id ; 
           ID orderGridItemId=  accProductidToOrderGridItemMap.get(searchKey);
           boolean found = false;
           for(Order_Grid__c orderGridObj : orderGridList){
              // found = false;
            if(orderGridObj.id == orderGridItemId){
                found = true;
                //Add the Quentity and date to the correct Order Number. 
                if(LastSixOrders.size()> 0 && LastSixOrders[0].OrderedDate != null && LastSixOrders[0].OrderedDate == orderItemObj.Order.OrderedDate){                    
                    orderGridObj.Order1__c = orderItemObj.Quantity;
                    orderGridObj.Order1_Date__c = orderItemObj.Order.OrderedDate.date();
                    Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);                  
                }
                if(LastSixOrders.size()> 1 && LastSixOrders[1].OrderedDate != null && LastSixOrders[1].OrderedDate == orderItemObj.Order.OrderedDate){
                    orderGridObj.Order2__c = orderItemObj.Quantity;
                    orderGridObj.Order2_Date__c = orderItemObj.Order.OrderedDate.date();
                    Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);
                }
                if(LastSixOrders.size()> 2 && LastSixOrders[2].OrderedDate  != null && LastSixOrders[2].OrderedDate == orderItemObj.Order.OrderedDate){
                    orderGridObj.Order3__c = orderItemObj.Quantity;
                    orderGridObj.Order3_Date__c = orderItemObj.Order.OrderedDate.date();
                    Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);
                }
                if(LastSixOrders.size()> 3 &&  LastSixOrders[3].OrderedDate != null && LastSixOrders[3].OrderedDate == orderItemObj.Order.OrderedDate){
                    orderGridObj.Order4__c = orderItemObj.Quantity;
                    orderGridObj.Order4_Date__c = orderItemObj.Order.OrderedDate.date();
                    Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);
                }
                if(LastSixOrders.size()> 4 &&  LastSixOrders[4].OrderedDate != null && LastSixOrders[4].OrderedDate == orderItemObj.Order.OrderedDate){
                    orderGridObj.Order5__c = orderItemObj.Quantity;
                    orderGridObj.Order5_Date__c = orderItemObj.Order.OrderedDate.date();
                    Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);
                }
                if(LastSixOrders.size()> 5 && LastSixOrders[5].OrderedDate != null && LastSixOrders[5].OrderedDate == orderItemObj.Order.OrderedDate){
                    orderGridObj.Order6__c = orderItemObj.Quantity;
                    orderGridObj.Order6_Date__c = orderItemObj.Order.OrderedDate.date();
                   Order_Grid__c og =  orderGridIdandObjMap.remove(orderGridObj.id); 
                    orderGridIdandObjMap.put(orderGridObj.id, orderGridObj);
                }
              //  orderGridtobeUpserted.add(orderGridObj);
            }

           }
           if(!found){
                    Order_Grid__c newOrderGridObj= new Order_Grid__c();

                    if(LastSixOrders.size()> 0 && LastSixOrders[0].OrderedDate != null && LastSixOrders[0].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order1__c = orderItemObj.Quantity;
                        newOrderGridObj.Order1_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    if(LastSixOrders.size()> 1 && LastSixOrders[1].OrderedDate != null && LastSixOrders[1].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order2__c = orderItemObj.Quantity;
                        newOrderGridObj.Order2_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    if(LastSixOrders.size()> 2 && LastSixOrders[2].OrderedDate  != null && LastSixOrders[2].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order3__c = orderItemObj.Quantity;
                        newOrderGridObj.Order3_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    if(LastSixOrders.size()> 3 &&  LastSixOrders[3].OrderedDate != null && LastSixOrders[3].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order4__c = orderItemObj.Quantity;
                        newOrderGridObj.Order4_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    if(LastSixOrders.size()> 4 &&  LastSixOrders[4].OrderedDate != null && LastSixOrders[4].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order5__c = orderItemObj.Quantity;
                        newOrderGridObj.Order5_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    if(LastSixOrders.size()> 5 && LastSixOrders[5].OrderedDate != null && LastSixOrders[5].OrderedDate == orderItemObj.Order.OrderedDate){
                        newOrderGridObj.Product_Name__c = orderItemObj.Product_Name__c;
                        newOrderGridObj.Price__c = orderItemObj.ListPrice;
                        newOrderGridObj.Code__c = orderItemObj.Product_Code__c;
                        newOrderGridObj.Account_Name__c = orderItemObj.Order.Accountid;
                        newOrderGridObj.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                        newOrderGridObj.Product__c =orderItemObj.Product2Id;
                        newOrderGridObj.Order6__c = orderItemObj.Quantity;
                        newOrderGridObj.Order6_Date__c = orderItemObj.Order.OrderedDate.date();
                    }
                    //Do not add Order Items which have a Delivery Product. 
                    if(newOrderGridObj.Product_Name__c != 'Shipping Charge for this delivery method'){
                        orderGridtobeUpserted.add(newOrderGridObj);
                    }

           }
        }
        //add all the items in map to the orderGridtobeUpserted list/
        system.debug('the value of New Order Grid'+orderGridIdandObjMap);
        List<Order_Grid__c> listofValues = orderGridIdandObjMap.values();
        orderGridtobeUpserted.addAll(listofValues);
        system.debug('The value of map is :'+orderGridtobeUpserted);

    }
}