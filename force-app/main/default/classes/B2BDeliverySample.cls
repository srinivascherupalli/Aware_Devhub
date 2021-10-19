// This must implement the sfdc_checkout.CartShippingCharges interface
// in order to be processed by the checkout flow for the "Shipping" integration
global with sharing class B2BDeliverySample implements sfdc_checkout.CartShippingCharges {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // We need to get the ID of the cart delivery group in order to create the order delivery groups.
            Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId WITH SECURITY_ENFORCED][0].Id;

            // Get shipping options, including aspects like rates and carriers, from the external service. 
            ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = new List<ShippingOptionsAndRatesFromExternalService>();
            shippingOptionsAndRatesFromExternalService.add( new ShippingOptionsAndRatesFromExternalService(
                'Standard Delivery',
                'SD',
                0,
                0,
                'Manildra'
            ));

            // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId WITH SECURITY_ENFORCED];

            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            List<Id> orderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

            // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            Integer i = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
               populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                                  cartDeliveryGroupId,
                                                                  orderDeliveryMethodId,
                                                                  cartId);
                i+=1;
            }
            
            // If everything works well, the charge is added to the cart and our integration has been successfully completed.
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;

        } catch(Exception e) {
        }
        return integStatus;
    }

    // Structure to store the shipping options retrieved from external service.
    Class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;

        public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
        }

        public String getProvider() {
            return provider;
        }

        public Decimal getRate() {
            return rate;
        }

        public String getName() {
            return name;
        }
    }

    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private void populateCartDeliveryGroupMethodWithShippingOptions(ShippingOptionsAndRatesFromExternalService shippingOption,
                                                                  Id cartDeliveryGroupId,
                                                                  Id deliveryMethodId,
                                                                  Id webCartId){
        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
        // CartDeliveryGroupId: Id of the delivery group of this shipping option
        // DeliveryMethodId: Id of the delivery method for this shipping option
        // ExternalProvider: Unique identifier of shipping provider
        // Name: Name of the CartDeliveryGroupMethod record
        // ShippingFee: The cost of shipping for the delivery group
        // WebCartId: Id if the cart that the delivery group belongs to
        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOption.getProvider(),
            Name = shippingOption.getName(),
            ShippingFee = shippingOption.getRate(),
            WebCartId = webCartId
        );
        insert(cartDeliveryGroupMethod);
    }

    private List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> shippingOptions) {
        String defaultDeliveryMethodName = 'Standard Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (ShippingOptionsAndRatesFromExternalService shippingOption: shippingOptions) {
            //String shippingOptionNumber = String.valueOf(i);
            String name = defaultDeliveryMethodName; // + shippingOptionNumber;
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :name WITH SECURITY_ENFORCED];
            // This is the case in which an Order Delivery method does not exist.
            if (odms.isEmpty()) {
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = defaultDeliveryMethodName,
                    Carrier = 'Standard Carrier',
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.provider
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod existingodm = odms[0];
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.serviceName;
                    existingodm.ClassOfService = shippingOption.provider;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }

    private Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
}