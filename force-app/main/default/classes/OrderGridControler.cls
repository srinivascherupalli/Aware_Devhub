public without sharing class OrderGridControler {

    @AuraEnabled(cacheable=true)
    public static List<Order_Grid__c> getOrderList(String accountId) {

        system.debug('The Account id is:'+accountId);
        return [SELECT Id, Code__c, Order1_Date__c, Order2_Date__c,Order3_Date__c,Order4_Date__c,Order5_Date__c,Order6_Date__c,Price__c, Total_Price_Formula__c,Total_Weight_Formula__c, Pack_Size__c, Default_Order__c, 
                        Product_Name__c, Order_Required__c, Order1__c, Order2__c, Order3__c, Order4__c, Order5__c, Order6__c, Avg_Of_Orders__c, Total_Price__c, 
                        Total_Weight__c, OrderPending__c FROM Order_Grid__c where Account_Name__c =: accountId AND Code__c!=''];
    }

    @AuraEnabled
    public static void setRequiredOrder(String  selectedColumn, String accountId ) {

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
    public static string createOrder(String customerUserId, String accountId, String deliveryDate, String paymentMethod) {
        system.debug('createOrder delivery Date:'+deliveryDate);
        system.debug('Account id passed in accountId: '+accountId);
        try {
            //Check is the Cat already exists.
            WebCart cart ;//= new WebCart();
            CartDeliveryGroup deliveryGroup = new CartDeliveryGroup();
            List<WebCart> cartList = [select id , name , CreatedDate,status, ownerid  from webcart where ownerid = :customerUserId and status = 'Active' and accountid=:accountId Limit 1];
            List<CartItem> cartItemToDel = new List<CartItem>();
            WebStore	store = [select id from WebStore where name = 'Manildra B2B' Limit 1];  
            if (cartList.size() > 0){
                cart = cartList[0];
                cartItemToDel = [Select id from CartItem where cartid =: cart.id ];
                delete cartItemToDel;
            }
            //If cart does not exist then create a new Cart. 
            if(cart == null){          
                cart = new WebCart();  
                cart.name = 'CartX';                
                cart.AccountId = Id.valueOf(accountid);//get from userid->Contact->Account
                cart.OwnerId = customerUserId;//get from community userid lwc
                cart.WebStoreId =store.id;//id.valueOf('0ZEO0000000CaRMOA0');//cadecode for now. 
              
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
            /**
             *Get data from Order Grid to Populate the cart.
             *-quantity is required Order.
             *-Prive is Price__c 
             */

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
    
                if(orderGridObj.Order_Required__c != null && orderGridObj.Order_Required__c > 0){        
                    newCartItem.Quantity = orderGridObj.Order_Required__c;
                    newCartItem.TotalPrice = orderGridObj.Price__c * orderGridObj.Order_Required__c; 
                    newCartItem.TotalPriceAfterAllAdjustments = orderGridObj.Price__c * orderGridObj.Order_Required__c;
                    newCartItem.TotalPromoAdjustmentAmount = 0;
                   // newCartItem.TotalPromoAdjustmentTaxAmount = 0;
                    newCartItem.TotalAdjustmentAmount = 0;
                }
                else {
                    newCartItem.Quantity = 0;
                    newCartItem.TotalPrice = orderGridObj.Price__c * 0; 
                }
                newCartItem.TotalLineAmount = orderGridObj.Price__c; //get from Order Grid
                //get from Order Grid
                newCartItem.ListPrice = orderGridObj.Price__c;
                newCartItem.UnitAdjustedPrice = orderGridObj.Price__c;

                if(newCartItem.quantity > 0 && newCartItem.ListPrice >0){
                    newCartItemsList.add(newCartItem);
                }
            }

            insert newCartItemsList;
            //Add discount item for Online Payment.
            System.debug('Discount Mathod value:'+paymentMethod);
            if(paymentMethod.equals('payOnline') ){
                DiscountController.addDiscountItem(cart.id, deliveryGroup.id);

            }
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

    @AuraEnabled
    public static string setDeliveryDate(String customerUserId, String accountId, String deliveryDate){
        try {
                  //Check is the Cat already exists.
                  WebCart cart ;//= new WebCart();
                  CartDeliveryGroup deliveryGroup = new CartDeliveryGroup();
                  List<WebCart> cartList = [select id , name , CreatedDate,status, ownerid  from webcart where ownerid = :customerUserId and status = 'Active' and accountid=:accountId Limit 1];
                  WebStore	store = [select id from WebStore where name = 'Manildra B2B' Limit 1];  
                  if (cartList.size() > 0)
                  cart = cartList[0];
                  //If cart does not exist then create a new Cart. 
                  if(cart == null){          
                      cart = new WebCart();  
                      cart.name = 'CartX';                
                      cart.AccountId = Id.valueOf(accountid);//get from userid->Contact->Account
                      cart.OwnerId = customerUserId;//get from community userid lwc
                      cart.WebStoreId = store.id;//id.valueOf('0ZEO0000000CaRMOA0');//cadecode for now.               
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
                  return 'Success: DesiredDeliveryDate updated successfully';
            
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    /**
    * @Description : Batch process populated the Price for each Item. 
    *  step1 get all the items in grid and the Priductid
    *  step2 Get the Price books based on Delivery Date
    *  step3 get the Price book entry based on ProdcutId
    *  step4 get the Price from Price Book entry and Populate the Grid Item. 
    */

    @AuraEnabled
    public static string setPriceInGrid(String accountId, String deliveryDate){
        try {
            //Adding time value to make it compatable with DateTime field. 
            String dDateTimeStr = deliveryDate + ' 00:00:00';
            system.debug('The value accountId: '+accountId);
            system.debug('The value dDateTimeStr: '+dDateTimeStr);

            Datetime deliveryDateTime = Datetime.valueOfGMT(dDateTimeStr);
            List<Order_Grid__c> updateOrderGridList = new List<Order_Grid__c>();
            Map<Id, Order_Grid__c> productIDtoOrderGridObjMap = new Map<Id, Order_Grid__c>();
            List<Order_Grid__c> orderGridList = [select id, Product__c, Price__c from Order_Grid__c where Account_Name__c =:accountId];
            List<ID> productIds = new List<ID>();
            for(Order_Grid__c orderGridObj :orderGridList ){
                productIds.add(orderGridObj.Product__c);
            }

            //carete Productid to Order grid Map.
            for(Order_Grid__c orderObj:orderGridList ){
                productIDtoOrderGridObjMap.put(orderObj.Product__c, orderObj);
            }
            List<BuyerGroupMember>  buyerGroupMemList = [select id, buyerGroupId from BuyerGroupMember where buyerId =: accountId];
            system.debug('The value buyerGroupMemList: '+buyerGroupMemList);
            ID buyerGroupId = buyerGroupMemList[0].buyerGroupId;
            List<BuyerGroupPricebook>  buyerGroupPricebookList = [select id, Pricebook2Id, buyerGroupId from BuyerGroupPricebook where buyerGroupId =: buyerGroupId];
            List<ID> priceBookIds = new List<ID>();
            List<ID> validPriceBookIds = new List<ID>();
            for(BuyerGroupPricebook buyerGroupPricebookObj :buyerGroupPricebookList ){
                priceBookIds.add(buyerGroupPricebookObj.Pricebook2Id);
            }
            system.debug('The value priceBookIds: '+priceBookIds);
            system.debug('The value deliveryDateTime: '+deliveryDateTime);
            List<Pricebook2> priceBookList = [Select id from Pricebook2 where id in: (priceBookIds) and ValidFrom	<=: deliveryDateTime and  ValidTo >=: deliveryDateTime ];
            system.debug('The value priceBookList size: '+priceBookList.size());
            Map<id,Order_Grid__c> checkDuplicate = new Map<Id, Order_Grid__c>();
            if(priceBookList.size() > 0 ){
                for(Pricebook2 pbookObj: priceBookList){
                    validPriceBookIds.add(pbookObj.id);
                }
                system.debug('The value validPriceBookIds: '+validPriceBookIds);
                // ID priceBookId = priceBookList[0].id;
                List<PricebookEntry> priceBookEntryList = [select id, product2Id, UnitPrice, IsActive 
                                                                from PriceBookEntry 
                                                                where Pricebook2Id in: validPriceBookIds 
                                                                        and Product2Id in: productIds];

                system.debug('The value priceBookEntryList: '+priceBookEntryList);

                for(PricebookEntry pBookentry: priceBookEntryList){
                    if(checkDuplicate.get(pBookentry.Product2Id) == null){
                        Order_Grid__c orderGrid =  productIDtoOrderGridObjMap.get(pBookentry.product2Id); 
                        if(!pBookentry.IsActive){
                            orderGrid.price__c = 0;    
                        }else{
                            orderGrid.price__c =  pBookentry.UnitPrice;
                            
                        }
                        checkDuplicate.put(pBookentry.product2Id,orderGrid);
                        updateOrderGridList.add(orderGrid);
                    }

                }

            }
            //Set 0 for all Products which do not have a Price Book Entry.
            for(Order_Grid__c oGridObj: orderGridList){
                if(checkDuplicate.size() == 0 || checkDuplicate.get(oGridObj.Product__c) == null){
                    oGridObj.Price__c = 0;
                    updateOrderGridList.add(oGridObj);
                }
            }
            system.debug('The value id updateOrderGridList: '+updateOrderGridList);
            update updateOrderGridList;
                
            return 'Success: updateOrderGridList: ' +updateOrderGridList;
            
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }  

}