// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global with sharing class B2BTaxSample implements sfdc_checkout.CartTaxCalculations {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        System.debug('###startCartProcessAsync : started....');
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
//        try {
            AggregateResult[] groupedResults = [SELECT sum(TotalPrice)CartTotalValue FROM CartItem where cartid=:cartId and type='Product'];
            Decimal CartTotalValue = (Decimal) groupedResults[0].get('CartTotalValue');  
            Decimal totalTaxAmount = CartTotalValue*0.1; //10% GST

            System.debug('###CartTotalValue : ' + CartTotalValue);

            CartItem taxCartItem = null;

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
        
                taxCartItem = new CartItem(
                    CartId=cartId, 
                    Sku='SKU_GST', 
                    Quantity=1, 
                    Type='Charge', 
                    Name='GST',
                    TotalPrice=0, 
                    CartDeliveryGroupId=cartDeliveryGroup.Id
                );
                insert taxCartItem;
    
            }

            try{
                delete [SELECT Id FROM CartTax WHERE CartId=:cartId WITH SECURITY_ENFORCED];
            }catch(Exception e){}
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            CartTax tax = new CartTax( 
                Amount = totalTaxAmount,
                CartItemId = taxCartItem.Id,
                Name = 'GST',
                TaxCalculationDate = Date.today(),
                TaxRate = 10,
                TaxType = 'Actual'
            );
            cartTaxestoInsert.add(tax);
            insert(cartTaxestoInsert);
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
/*        } catch(Exception e) {
        }
        */
        return integStatus;
    }
      
}