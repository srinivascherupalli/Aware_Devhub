// This must implement the sfdc_checkout.CartTaxCalculations interface
// in order to be processed by the checkout flow and used for your Taxes integration.
global with sharing class B2BTaxSample implements sfdc_checkout.CartTaxCalculations {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            AggregateResult[] groupedResults = [SELECT sum(TotalPrice)CartTotalValue FROM CartItem where cartid=:cartId and type='Product'];
            Decimal CartTotalValue = (Decimal) groupedResults[0].get('CartTotalValue');            
            System.debug('###CartTotalValue : ' + CartTotalValue);
            CartItem taxCartItem = [SELECT Id FROM CartItem WHERE CartId=:cartId and Type='Charge' WITH SECURITY_ENFORCED limit 1];
            delete [SELECT Id FROM CartTax WHERE CartId=:cartId WITH SECURITY_ENFORCED];
            
            // For each cart item, insert a new tax line in the CartTax entity.
            // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
            CartTax[] cartTaxestoInsert = new CartTax[]{};
            CartTax tax = new CartTax( 
                Amount = CartTotalValue*0.1,
                CartItemId = taxCartItem.Id,
                Name = 'GST',
                TaxCalculationDate = Date.today(),
                TaxRate = 10,
                TaxType = 'Actual'
            );
            cartTaxestoInsert.add(tax);
            insert(cartTaxestoInsert);
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }
      
    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    Class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;
        
        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }
        
        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getAmount() {
            return amount;
        }
        
        public String getTaxName() {
            return taxName;
        }
    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user (maximum 255 characters)
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Taxes'
            );
            insert(cartValidationError);
            return integrationStatus;
    }
}