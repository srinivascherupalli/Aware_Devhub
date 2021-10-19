@isTest
public class StripeAdapterTest {

    public static testmethod void testAuthRequest() {

        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());

        //Create an auth request
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(80);
        authRequest.paymentMethod = paymentMethod;
        authRequest.currencyIsoCode = 'AUD';
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);
                
        StripeAdapter adapter = new StripeAdapter();
        commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
    }
    public static testmethod void createCaptureResponseTest() {
        PaymentAuthorization auth = initializeAuthObject();
        insert auth;
        Test.startTest();
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();       

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());

        //Create an auth request
        commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(80, auth.id);
        /*captureRequest.paymentMethod = paymentMethod;
        captureRequest.currencyIsoCode = 'AUD';*/
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.Capture);
                
        StripeAdapter adapter = new StripeAdapter();
        commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
        Test.stopTest();
    }
    public static testmethod void createSaleResponseTest() {
        Test.startTest();
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();       

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());

        //Create an auth request
        commercepayments.SaleRequest captureRequest = new commercepayments.SaleRequest(80);
        /*captureRequest.paymentMethod = paymentMethod;
        captureRequest.currencyIsoCode = 'AUD';*/
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.Sale);
                
        StripeAdapter adapter = new StripeAdapter();
        commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
        Test.stopTest();
    }
    public static testmethod void createRefundResponseTest() {
        Payment pmt = initializePaymentObject();
        insert pmt;
        Test.startTest();
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = createAuthPaymentMethodRequest();       

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());

        //Create an auth request
        commercepayments.ReferencedRefundRequest captureRequest = new commercepayments.ReferencedRefundRequest(80, pmt.id);
        /*captureRequest.paymentMethod = paymentMethod;
        captureRequest.currencyIsoCode = 'AUD';*/
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(captureRequest, commercepayments.RequestType.ReferencedRefund);
                
        StripeAdapter adapter = new StripeAdapter();
        commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
        Test.stopTest();
    }
    public static testmethod void createTokenizeResponseTest() {
        
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PaymentCalloutMock());

        //Create an auth request
        commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest(NULL);
        tokenizeRequest.cardPaymentMethod = getCardPaymentMethod();
        tokenizeRequest.address = getAddress();
        commercepayments.PaymentGatewayContext p = new commercepayments.PaymentGatewayContext(tokenizeRequest, commercepayments.RequestType.Tokenize);
                
        StripeAdapter adapter = new StripeAdapter();
        commercepayments.GatewayResponse authResponse = adapter.processRequest(p);
        Test.stopTest();
    }

    private static commercepayments.AuthApiPaymentMethodRequest createAuthPaymentMethodRequest()
    {
        //Create a PaymentMethod instance
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = new commercepayments.AuthApiPaymentMethodRequest(getCardPaymentMethod());
        return paymentMethod;
    }

    private static commercepayments.AddressRequest getAddress(){
        /*
        commercepayments.AddressRequest address = new commercepayments.AddressRequest();
        address.street = 'encodedStreet';
        address.city = 'city';
        address.state = 'state';
        address.country = 'country';
        address.postalCode = 'postcode';        
        return address;
        */
        return new commercepayments.AddressRequest('street', 'city', 'state', 'country', 'postalCode');
    }

    private static commercepayments.CardPaymentMethodRequest getCardPaymentMethod(){
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = new commercepayments.CardPaymentMethodRequest(commercepayments.CardCategory.CreditCard);
        cardPaymentMethod.cardType = commercepayments.CardType.Visa;
        cardPaymentMethod.cardHolderFirstName = 'Test';
        cardPaymentMethod.cardHolderLastName = 'Test';
        cardPaymentMethod.cardHolderName = 'Test Test';
        cardPaymentMethod.cardNumber = '4443434343284111';
        cardPaymentMethod.cvv = '123';
        cardPaymentMethod.email = 'h@test.com';
        cardPaymentMethod.expiryMonth = 2;
        cardPaymentMethod.expiryYear = 1111;
        cardPaymentMethod.startMonth = 2;
        cardPaymentMethod.startYear = 1333;
        return cardPaymentMethod;
    }
    private static PaymentAuthorization initializeAuthObject()
    {
        PaymentAuthorization auth = new PaymentAuthorization();
        auth.amount = 1500;
        auth.Status = 'Processed';
        auth.ProcessingMode = 'External';
        auth.GatewayRefNumber = 'testreferencenumber';
        auth.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        return auth;
    
    }
    private static Payment initializePaymentObject()
    {
        PaymentAuthorization PaymentAuthorizationVar = new PaymentAuthorization();
              PaymentAuthorizationVar.GatewayAuthCode = '12345_test';
              PaymentAuthorizationVar.Amount = 100;
              PaymentAuthorizationVar.Status = 'Processed';
              PaymentAuthorizationVar.ProcessingMode = 'External';
              insert PaymentAuthorizationVar;

        Payment pmt = new Payment();
        pmt.amount = 1500;
        pmt.Status = 'Processed';
        pmt.ProcessingMode = 'External';
        pmt.GatewayRefNumber = 'testreferencenumber';
        pmt.Type = 'Capture';
        pmt.GatewayRefDetails = '{"method":"credit_card","transaction_id":"ET119982"}';
        pmt.PaymentAuthorizationId = PaymentAuthorizationVar.Id;
        return pmt;    
    }
}