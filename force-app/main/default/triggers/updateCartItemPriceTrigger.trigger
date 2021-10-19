trigger updateCartItemPriceTrigger on CartDeliveryGroup (before update) {

    List<CartItem> catItemList = new List<CartItem>();

    Decimal dec = 0.00;
    CartDeliveryGroup dgObj = new CartDeliveryGroup();
    List<CartDeliveryGroup> cDeliveryGroupList = Trigger.new;
    system.debug('The value cDeliveryGroupList: '+cDeliveryGroupList);
    dgObj = cDeliveryGroupList[0];
    
  //  ID productId = cItem.product2Id;
    WebCart cartObj = new WebCart();
    cartObj = [Select id, accountId from WebCart where id =: dgObj.cartId];
   // CartDeliveryGroup cDeliveryGroupObj = [Select id, DesiredDeliveryDate from CartDeliveryGroup where cartId =: cItem.cartId Limit 1];
     Datetime deliveryDateTime = dgObj.DesiredDeliveryDate;
    ID accountId = cartObj.accountId;
    List<CartItem> cItemToUpdateList = new List<CartItem>();
    List<CartItem> cItemList = [Select id,product2Id, Quantity, TotalAdjustmentAmount, UnitAdjustedPrice,SalesPrice,totalprice,TotalLineAmount
                                     from CartItem 
                                    where cartid=: cartObj.id];
    //Loop through all Cart Items and update Prices. 
    for(CartItem cItem: cItemList ){
        if(cItem.TotalAdjustmentAmount != dec){
            //Do nothing. 
        }
        if(cItem.TotalAdjustmentAmount == dec){        
            /**
             * get all Account ids
             * get all Price Books and PriceBook Entries
             * update the Price based on valid Price Book entry. 
             */

            //get the BuyersGroup for the account id
            List<BuyerGroupMember>  buyerGroupMemList = [select id, buyerGroupId from BuyerGroupMember where buyerId =: accountId];
            system.debug('The value buyerGroupMemList: '+buyerGroupMemList);
            if(buyerGroupMemList.size() > 0){
                ID buyerGroupId = buyerGroupMemList[0].buyerGroupId;
                
                //Get all the Price Books for the Buyers Group.
                List<BuyerGroupPricebook>  buyerGroupPricebookList = [select id, Pricebook2Id, buyerGroupId 
                                                                        from BuyerGroupPricebook 
                                                                        where buyerGroupId =: buyerGroupId];
                List<ID> priceBookIds = new List<ID>();
                List<ID> validPriceBookIds = new List<ID>();
                for(BuyerGroupPricebook buyerGroupPricebookObj :buyerGroupPricebookList ){
                    priceBookIds.add(buyerGroupPricebookObj.Pricebook2Id);
                }
                system.debug('The value priceBookIds: '+priceBookIds);
                system.debug('The value deliveryDateTime: '+deliveryDateTime);
                //Get Valid Price Books 
                List<Pricebook2> priceBookList = [Select id 
                                                    from Pricebook2 
                                                    where id in: (priceBookIds) and ValidFrom	<=: deliveryDateTime and  ValidTo >=: deliveryDateTime ];
                system.debug('The value priceBookList size: '+priceBookList.size());
                Map<id,Order_Grid__c> checkDuplicate = new Map<Id, Order_Grid__c>();
                if(priceBookList.size() > 0 ){
                    for(Pricebook2 pbookObj: priceBookList){
                        validPriceBookIds.add(pbookObj.id);
                    }
                    system.debug('The value validPriceBookIds: '+validPriceBookIds);
                    // ID priceBookId = priceBookList[0].id;
                    //Get the PriceBook Entries form the valid Price Book.SELECT  FROM Account
                    List<PricebookEntry> priceBookEntryList = [select id, product2Id, UnitPrice 
                                                                from PriceBookEntry 
                                                                where Pricebook2Id in: validPriceBookIds and Product2Id =: cItem.product2Id];
                
                
                    //Set the Price values in the Cart Item
                    cItem.UnitAdjustedPrice = priceBookEntryList[0].UnitPrice;
                    cItem.SalesPrice  = priceBookEntryList[0].UnitPrice;
                    cItem.totalprice = cItem.UnitAdjustedPrice *cItem.quantity;
                    cItem.TotalLineAmount = cItem.UnitAdjustedPrice *cItem.quantity;
                }
            }
        }
        cItemToUpdateList.add(cItem);
    }
    update cItemToUpdateList;
}