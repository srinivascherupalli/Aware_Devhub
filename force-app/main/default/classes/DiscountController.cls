public with sharing class DiscountController {

    @AuraEnabled
    public static void addDiscountItem(Id  cartId, ID deliveryGroupId) {

      System.debug('discountApplied: ' + discountApplied(cartId));
      System.debug('Value of CartId: ' + cartId);
      System.debug('Value of deliveryGroupId: ' + deliveryGroupId);
      if(!discountApplied(cartId)){ // avoid duplicate discount items
        System.debug('Value of CartId in if loop: ' + cartId);
      //  ID cartIdValue = ID.valueOf(cartId);
      try{
        CartDeliveryGroup deliveryGroup = new CartDeliveryGroup();

        //Get Shoping cart and total amount
        WebCart cartObj = [select id, TotalAmount, accountid from Webcart 
                           where id =:cartId Limit 1];
        ID accIdValue = cartObj.accountid;
        Account userAcc = [Select id, Online_Discount_Amount__c from Account where id =: accIdValue Limit 1];

       // ID cartIdValue = cartObj.id;
     //   deliveryGroup = [select id,DesiredDeliveryDate   from CartDeliveryGroup where cartid =: cartId  Limit 1];  

        Decimal totalCartValue = cartObj.TotalAmount;
        Decimal discountAmount = userAcc.Online_Discount_Amount__c;
        Decimal totalDiscount = totalCartValue * (discountAmount/100);
        totalDiscount = -totalDiscount;
        System.debug('Value of total Discount: ' + totalDiscount);
        //Create a Discount Product.
        Product2 discountProduct = [Select id, StockKeepingUnit
                                    from Product2 
                                    where name ='Credit Cards Discount' Limit 1];
        CartItem newCartItem = new CartItem();
        newCartItem.name = 'CartItemd';
        newCartItem.type = 'Product';
        newCartItem.sku= discountProduct.StockKeepingUnit;
        newCartItem.CartDeliveryGroupid = deliveryGroupId;
        newCartItem.CartId = cartId;
        newCartItem.Product2Id = discountProduct.id;            
        newCartItem.Quantity = 1;
        newCartItem.TotalLineAmount = totalDiscount; //get from Order Grid
        newCartItem.TotalPrice = totalDiscount; //get from Order Grid
        newCartItem.ListPrice = totalDiscount;
        newCartItem.UnitAdjustedPrice = totalDiscount;
        //---
        newCartItem.TotalPriceAfterAllAdjustments = totalDiscount;
        newCartItem.TotalPromoAdjustmentAmount = 0;
       // newCartItem.TotalPromoAdjustmentTaxAmount = 0;
        newCartItem.TotalAdjustmentAmount = 0;

        insert newCartItem;
        }catch(Exception e){
          System.debug('.getStackTraceString():  '+e.getStackTraceString());
          System.debug('.getMessage():  '+e.getMessage());
          System.debug('.getCause():  '+e.getCause());
          System.debug('.getLineNumber():  '+ e.getLineNumber());
        }
      }

    }

    private static boolean discountApplied(Id cartId){
      boolean applied = false;

      List<CartItem> discountItem = [select id from CartItem where name = 'CartItemd' and type = 'Product' and CartId =:cartId];

      if(discountItem!=null && !discountItem.isEmpty()){
        applied = true;
      }

      return applied;

    }

    
    @AuraEnabled
    public static Boolean isDiscountItemIncluded(String cartIdValue){
      //  Id cartIdObj = ID.valueOf(cartIdValue);
        try {

            List<CartItem> cartItemLst = [Select id, name from CartItem where cartid=: cartIdValue and name= 'CartItemd' Limit 1];
            if(cartItemLst != null && cartItemLst.size()> 0 ){
                return true;
            }else{
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}