public with sharing class OrderGridControler {

    @AuraEnabled(cacheable=true)
    public static List<Order_Grid__c> getOrderList(String accountId) {

        system.debug('The Account id is:'+accountId);
        return [SELECT Id, Code__c, Order1_Date__c, Order2_Date__c,Order3_Date__c,Order4_Date__c,Order5_Date__c,Order6_Date__c,Price__c, Total_Price_Formula__c,Total_Weight_Formula__c, Pack_Size__c, Default_Order__c, 
                        Product_Name__c, Order_Required__c, Order1__c, Order2__c, Order3__c, Order4__c, Order5__c, Order6__c, Avg_Of_Orders__c, Total_Price__c, 
                        Total_Weight__c, OrderPending__c FROM Order_Grid__c where Account_Name__c =: accountId AND Code__c!=''];
    }

    @AuraEnabled
    public static void setRequiredOrder(String  selectedColumn, String accountId ) {

    /*    Id customerUserId = ID.valueof(cuserId);
        system.debug('The user id is:'+customerUserId);
        User communityUser =  [Select id, ContactId From User where id =:customerUserId Limit 1];
        Id contactId = communityUser.ContactId;
        Contact contactuser = [Select id, Accountid from COntact where id =: contactId Limit 1];
        ID accountid = contactuser.accountid;
*/
        String column = '';
        column = selectedColumn;
        Double orderQuantity = 0.0;

        List<Order_Grid__c> orderGridList =  [SELECT Id, Code__c,Price__c, Pack_Size__c, Default_Order__c,OrderPending__c, Order1__c, 
                                                Order2__c, Order3__c, Order4__c, Order5__c, Order6__c , Avg_Of_Orders__c, Product_Name__c, Order_Required__c, 
                                                Total_Price__c, Total_Weight__c FROM Order_Grid__c where Account_Name__c =: accountId];

        List<Order_Grid__c> updateOrderGridList = new List<Order_Grid__c>();
        for(Order_Grid__c orderGridObj : orderGridList){
            if(column.equals('Order1__c')){
                if(orderGridObj.Order1__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order1__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order1__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('Order2__c')){
                if(orderGridObj.Order2__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order2__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order2__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c *orderQuantity;
                }
            }
            if(column.equals('Order3__c')){
                if(orderGridObj.Order3__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order3__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order3__c;
                if(orderGridObj.Price__c!= null){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('Order4__c')){
                if(orderGridObj.Order4__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order4__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order4__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('Order5__c')){
                if(orderGridObj.Order5__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order5__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order5__c;
                if(orderGridObj.Price__c!= null ){
                    orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                    orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('Order6__c')){
                if(orderGridObj.Order6__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Order6__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Order6__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('OrderPending__c')){
                if(orderGridObj.OrderPending__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.OrderPending__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.OrderPending__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            if(column.equals('Avg_Of_Orders__c')){
                if(orderGridObj.Avg_Of_Orders__c == null){
                    orderQuantity = 0.0;
                }else {
                    orderQuantity = orderGridObj.Avg_Of_Orders__c;
                }
                orderGridObj.Order_Required__c = orderGridObj.Avg_Of_Orders__c;
                if(orderGridObj.Price__c!= null ){
                orderGridObj.Total_Price__c = orderGridObj.Price__c * orderQuantity;
                orderGridObj.Total_Weight__c = orderGridObj.Pack_Size__c * orderQuantity;
                }
            }
            
            updateOrderGridList.add(orderGridObj);
        }
        update updateOrderGridList;

    }

    @AuraEnabled
    public static string updateOrderGrid(Object data) {
        List<Order_Grid__c> ordersForUpdate = (List<Order_Grid__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Order_Grid__c>.class
        );
        System.debug('The value of orders to update'+ordersForUpdate);
        System.debug('The value of orders to update'+ordersForUpdate.size());
        if(ordersForUpdate.size()> 0){
            
            System.debug('The value of ordersForUpdate[0].id'+ordersForUpdate[0].id);
        }
        try {
            update ordersForUpdate;
            return 'Success: contacts updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    //Create Required Order from the required quantity field in the Order Grid custom object. 
    @AuraEnabled
    public static string createOrder(String customerUserId, String accountId, String deliveryDate) {
        system.debug('createOrder delivery Date:'+deliveryDate);
        system.debug('Account id passed in accountId: '+accountId);

     /*   Id customerUserId = ID.valueof(cuserId);
        system.debug('The user id is:'+customerUserId);
        User communityUser =  [Select id, ContactId From User where id =:customerUserId Limit 1];
        Id contactId = communityUser.ContactId;
        Contact contactuser = [Select id, Accountid from COntact where id =: contactId Limit 1];
        ID accountid = contactuser.accountid;*/
        try {
            //Check is the Cat already exists.
            WebCart cart ;//= new WebCart();
            CartDeliveryGroup deliveryGroup = new CartDeliveryGroup();
            List<WebCart> cartList = [select id , name , CreatedDate,status, ownerid  from webcart where ownerid = :customerUserId and status = 'Active' and accountid=:accountId Limit 1];
    
            if (cartList.size() > 0)
            cart = cartList[0];
            //If cart does not exist then create a new Cart. 
            if(cart == null){          
                cart = new WebCart();  
                cart.name = 'CartX';                
                cart.AccountId = Id.valueOf(accountid);//get from userid->Contact->Account
                cart.OwnerId = customerUserId;//get from community userid lwc
                cart.WebStoreId = id.valueOf('0ZEO0000000CaRMOA0');//cadecode for now. 
                insert cart;
                //insert the Cart Delivery Group. 
                deliveryGroup.name = 'WYDG';
                deliveryGroup.cartid = cart.id;
                deliveryGroup.DeliverToName = 'WY';
                system.debug('Setting the delivery Date: '+Date.valueOf(deliveryDate));
                deliveryGroup.DesiredDeliveryDate = Date.valueOf(deliveryDate);
                insert deliveryGroup;
            }else{
                ID cartId = cart.id;
                cart.IsRepricingNeeded = true;
                update cart;
                deliveryGroup = [select id,DesiredDeliveryDate   from CartDeliveryGroup where cartid =: cartId  Limit 1];
                system.debug('Setting the delivery Date in else loop: '+Date.valueOf(deliveryDate));
                deliveryGroup.DesiredDeliveryDate = Date.valueOf(deliveryDate);
                update deliveryGroup;
                
            }

            //Get data from Order Grid to Populate the cart.
            //-quantity is required Order.
            //-Prive is Price__c
            //

            List<CartItem> newCartItemsList = new List<CartItem>();
            List<Order_Grid__c> orderData = [Select id, Order_Required__c, Price__c ,product__c, product__r.StockKeepingUnit
                                            from Order_Grid__c 
                                            where Account_Name__c =:accountid];
            for(Order_Grid__c orderGridObj : orderData){

                CartItem newCartItem = new CartItem();
                newCartItem.name = 'CartItemx';
                newCartItem.type = 'Product';
                newCartItem.sku = orderGridObj.product__r.StockKeepingUnit;
                newCartItem.CartDeliveryGroupid = deliveryGroup.id;
                newCartItem.CartId = cart.id;
                newCartItem.Product2Id = orderGridObj.product__c;            
                newCartItem.Quantity = orderGridObj.Order_Required__c;
                newCartItem.TotalLineAmount = orderGridObj.Price__c; //get from Order Grid
                newCartItem.TotalPrice = orderGridObj.Price__c * orderGridObj.Order_Required__c; //get from Order Grid
                newCartItem.ListPrice = orderGridObj.Price__c;
                newCartItem.UnitAdjustedPrice = orderGridObj.Price__c;
                if(newCartItem.quantity > 0 ){
                    newCartItemsList.add(newCartItem);
                }
            }

            insert newCartItemsList;
            return cart.Id;
        }
        catch (Exception e) {
            
            System.debug('.getStackTraceString():  '+e.getStackTraceString());
            System.debug('.getMessage():  '+e.getMessage());
            System.debug('.getCause():  '+e.getCause());
            System.debug('.getLineNumber():  '+ e.getLineNumber());
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static string saveOrderLineItem(String objId, String value){

        try{
        ID orderGridid = ID.valueOf(objId);
        Order_Grid__c orderGridObj = [Select id , order1__c, Order_Required__c from Order_Grid__c where id =:orderGridid Limit 1];
        orderGridObj.Order_Required__c = Integer.valueOf(value);
        update orderGridObj;
        return 'Success: contacts updated successfully';
        }catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
}