// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global with sharing class B2BTaxSample implements sfdc_checkout.CartTaxCalculations {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        System.debug('###startCartProcessAsync : started....');
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {            
            CartItem taxCartItem = null;
            CartItem deliveryCartItem = new CartItem();
            Decimal deliveryCartItemPrice = 0;
            
            List<CartItem> taxCartItemList = [SELECT Id FROM CartItem WHERE CartId=:cartId and Type='Charge' WITH SECURITY_ENFORCED];
            if(taxCartItemList!=null && !taxCartItemList.isEmpty()){
                taxCartItem = taxCartItemList[0];
            }else{

                CartDeliveryGroup cartDeliveryGroup = null;
                OrderDeliveryMethod odm = null;
                List<CartDeliveryGroup> cartDeliveryGroupList = [SELECT Id,DeliveryMethodId FROM CartDeliveryGroup WHERE CartId=:cartId WITH SECURITY_ENFORCED];
                if(cartDeliveryGroupList!=null && !cartDeliveryGroupList.isEmpty()){
                    cartDeliveryGroup = cartDeliveryGroupList[0];
                    if(cartDeliveryGroup.DeliveryMethodId==null){
                        odm = new OrderDeliveryMethod(Name='Default Order Delivery Method', isActive=true);
                        insert odm;

                        cartDeliveryGroup.DeliveryMethodId= odm.Id;

                        update cartDeliveryGroup;
                    }
                }else{
                    odm = new OrderDeliveryMethod(Name='Default Order Delivery Method', isActive=true);
                    insert odm;
    
                    cartDeliveryGroup = new CartDeliveryGroup(CartId=cartId, Name='Default Delivery', DeliveryMethodId=odm.Id);
                    insert cartDeliveryGroup;    
                }
                                
                deliveryCartItem.CartId=cartId;
                deliveryCartItem.Sku='SKU_GST'; 
                deliveryCartItem.Quantity=1;
                deliveryCartItem.Type='Charge'; 
                deliveryCartItem.Name='GST';
                deliveryCartItem.TotalPrice=deliveryCartItemPrice;
                deliveryCartItem.CartDeliveryGroupId=cartDeliveryGroup.Id;
                
                insert deliveryCartItem;
    
            }

            try{
                delete [SELECT Id FROM CartTax WHERE CartId=:cartId WITH SECURITY_ENFORCED];
            }catch(Exception e){}
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            Boolean exemptFromTax = false;
            webcart cartVar = [Select Id, accountId from webcart where id=:cartId];
            Account accountRecord = [Select Id, Tax_Exemption_Account__c From Account where Id =: cartVar.accountId];
            if(!accountRecord.Tax_Exemption_Account__c){
                CartTax[] cartTaxestoInsert = new CartTax[]{};
                    for(CartItem item : [Select Id, TotalPrice, product2.Name From CartItem where cartid=:cartId AND (type='Product' and product2.Tax_Required__c = true)]){
                    
                        CartTax tax = new CartTax( 
                        Amount = item.TotalPrice*0.1,
                        CartItemId = item.Id,
                        Name = item.product2.Name,
                        TaxCalculationDate = Date.today(),
                        TaxRate = 10,
                        TaxType = 'Actual'
                    );
                    cartTaxestoInsert.add(tax);
                }
                /*
                    Since Delivery charge is 0 at present so related tax will also be 0. Hence below code is commented out.
                    In Future, if delivery charge is applied , then below code needs to be uncommented
                */ 

                /*if(deliveryCartItemPrice > 0){
                    CartTax tax = new CartTax( 
                        Amount = deliveryCartItemPrice,
                        CartItemId = taxCartItem.Id,
                        Name = 'GST',
                        TaxCalculationDate = Date.today(),
                        TaxRate = 10,
                        TaxType = 'Actual'
                    );
                    cartTaxestoInsert.add(tax);
                }*/
                
                insert(cartTaxestoInsert);
            }
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
       } catch(Exception e) {
        System.debug('Eror while calculating tax: '+e.getMessage());    
    }
        
        return integStatus;
    }
      
}