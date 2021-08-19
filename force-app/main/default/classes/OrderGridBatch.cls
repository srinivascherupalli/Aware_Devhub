public with sharing class OrderGridBatch {
    public OrderGridBatch() {
        
        ID customerId = ID.valueof('001O000001mrT5gIAE');
        //TODO:
        //  -Populate Order Gird with last 6 orders.
        //  1-Get  last 6 Orders from orders table
        //  2-Search the OrderItem object to get the Product name, Quantity and Price. 
        //  3-Upsert the data collected in step 1 and 2 into Order Gird Custom Object.

        List<Order> LastSixOrders = [Select id, Accountid ,OrderedDate 
                                     from Order 
                                     where Accountid =: customerId and Order.status = 'Completed' Order by OrderedDate Asc limit 6 ];
        Set<ID> orderIDList = new Set<ID>();
        for(Order orderObj: LastSixOrders){
            orderIDList.add(orderObj.id);
        }
        system.debug('The number of LastSixOrders records: '+ LastSixOrders.size());
        system.debug('The number of orderIDList records: '+ orderIDList.size());

        //Get the Order Items only in the Last six Orders of the Account. 
        List<OrderItem> orderItemList = [Select id, Order.id, ListPrice, Weight_kg__c, Product_Name__c, Product_Code__c, Quantity, TotalPrice,Order.OrderedDate, Order.Accountid 
                                        from OrderItem 
                                        where Order.id IN :orderIDList and Order.status = 'Completed' Order by Order.OrderedDate Asc Limit 100  ];
        system.debug('The number of orderItemList records: '+ orderItemList.size());
        List<Order_Grid__c> orderGridList = new List<Order_Grid__c>();

        //Delete the data related to the Account.
        List<Order_Grid__c> accountOrders = [Select id from Order_Grid__c where Account_Name__c =:customerId];
        delete accountOrders;
        //loop through the data in such a way to populate Product Code, Name and Quantilty Ordered. Then move to next Order Number and populate all fields.
        //The data has to be grouped by date. 
        for(OrderItem orderItemObj: orderItemList ){
            Order_Grid__c Order_Grid_Item = new Order_Grid__c();
            if(LastSixOrders.size()> 0 && LastSixOrders[0].OrderedDate != null && LastSixOrders[0].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order1__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order1_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            if(LastSixOrders.size()> 1 && LastSixOrders[1].OrderedDate != null && LastSixOrders[1].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order2__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order2_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            if(LastSixOrders.size()> 2 && LastSixOrders[2].OrderedDate  != null && LastSixOrders[2].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order3__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order3_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            if(LastSixOrders.size()> 3 &&  LastSixOrders[3].OrderedDate != null && LastSixOrders[3].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order4__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order4_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            if(LastSixOrders.size()> 4 &&  LastSixOrders[4].OrderedDate != null && LastSixOrders[4].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order5__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order5_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            if(LastSixOrders.size()> 5 && LastSixOrders[5].OrderedDate != null && LastSixOrders[5].OrderedDate == orderItemObj.Order.OrderedDate){
                Order_Grid_Item.Product_Name__c = orderItemObj.Product_Name__c;
                Order_Grid_Item.Price__c = orderItemObj.ListPrice;
                Order_Grid_Item.Code__c = orderItemObj.Product_Code__c;
                Order_Grid_Item.Order6__c = orderItemObj.Quantity;
                Order_Grid_Item.Account_Name__c = orderItemObj.Order.Accountid;
                Order_Grid_Item.Order6_Date__c = orderItemObj.Order.OrderedDate.date();
                Order_Grid_Item.Pack_Size__c = orderItemObj.Weight_kg__c == null ? 0 : orderItemObj.Weight_kg__c;
                Order_Grid_Item.Product__c =orderItemObj.Product2Id;
            }
            orderGridList.add(Order_Grid_Item);
        }
        system.debug('The number of records: '+ orderGridList.size());
        upsert orderGridList;
    }
}