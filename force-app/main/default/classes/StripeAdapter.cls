global class StripeAdapter implements commercepayments.PaymentGatewayAdapter {

    private static final commercepayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(commercepayments.SalesforceResultCode.Decline);
    private static final List<String> DECLINE_CODES = new List<String>{'card_declined', 'incorrect_cvc', 'expired_card',
     'authentication_required', 'card_not_supported', 'currency_not_supported', 'incorrect_number', 'incorrect_zip'};

    global StripeAdapter() {
    }

    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {    	
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();
        commercepayments.GatewayResponse response;
        
        try {
            if (requestType == commercepayments.RequestType.Authorize) {
                response = createAuthResponse((commercepayments.AuthorizationRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Capture) {
                response =  createCaptureResponse((commercepayments.CaptureRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Sale) {
                response =  createSaleResponse((commercepayments.SaleRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.ReferencedRefund) {
                response = createRefundResponse((commercepayments.ReferencedRefundRequest) paymentRequest);
            } else if (requestType == commercepayments.RequestType.Tokenize) {
                response = createTokenizeResponse((commercepayments.PaymentMethodTokenizationRequest) paymentRequest);
            }
            return response;
        } catch (StripeValidationException e) {
             return new commercepayments.GatewayErrorResponse('400', e.getMessage());
        }
    }

    public commercepayments.GatewayResponse createTokenizeResponse(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        // API: https://stripe.com/docs/api/tokens    
            
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeRequest.cardPaymentMethod;
        
        Map<String, String> params = new Map<String, String>();
        params.put('card[name]', urlEncode(cardPaymentMethod.cardHolderName));
        params.put('card[number]', cardPaymentMethod.cardNumber);
        params.put('card[exp_month]', String.valueOf(cardPaymentMethod.expiryMonth));
        params.put('card[exp_year]', String.valueOf(cardPaymentMethod.expiryYear));
        params.put('card[cvc]', cardPaymentMethod.cvv);
        
        commercepayments.AddressRequest billingAddress = tokenizeRequest.address;

		if (billingAddress != null) {
			params.put('card[address_line1]', billingAddress.street);
			params.put('card[address_city]', billingAddress.city);
			params.put('card[address_state]', billingAddress.state);
			params.put('card[address_zip]', billingAddress.postalCode);
			params.put('card[address_country]', billingAddress.country);
		}

        HttpResponse response = doPost('tokens', params);
        String body = response.getBody();
        System.debug('### cardInfo body >> ' + body);

        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('### tokenizeResponse >> ' + results);
        Integer sc = response.getStatusCode();
		commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
		
		tokenizeResponse.setGatewayDate(system.now());
		
        if (sc >= 200 && sc < 300) {
        	tokenizeResponse.setGatewayToken((String) results.get('id'));
        	tokenizeResponse.setGatewayResultCode('success');
        	tokenizeResponse.setSalesforceResultCodeInfo(RC_SUCCESS);

            Map<String, Object> cardInfo = (Map<String, Object>) results.get('card');

            if(cardInfo!=null && cardInfo.keySet()!=null){
                String StripeCardId = (String) cardInfo.get('id');
                tokenizeResponse.setGatewayResultCodeDescription(StripeCardId);
            }

        }
        else {
			// TODO: lots of error mapping/handling
            Map<String, Object> error = (Map<String, Object>) results.get('error');
            String errorType = (String) error.get('type');
            String errorCode = (String) error.get('code');
            
            if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                tokenizeResponse.setGatewayResultCode(errorCode);
                tokenizeResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                tokenizeResponse.setGatewayMessage((String) error.get('message'));
                tokenizeResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            } else {
                return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
            }
        }
        
        // TODO: more failure cases?
		
        return tokenizeResponse;
    }

    public static void linkCardToCustomer(String gatewayToken,String StripeCustomerId, String salesforceConsent){
        try{

            Map<String, String> params = new Map<String, String>();
            HttpResponse response = null;
            String body = null;
/*
            response = doGET('customers/'+ StripeCustomerId + '/sources/' + gatewayToken, params);
            body = response.getBody();
            System.debug('customer cards response >>>>'+body);
*/
//            if(!body.contains(gatewayToken)){
                params = new Map<String, String>();
                params.put('source', gatewayToken);
                params.put('metadata[salesforce_consent]', salesforceConsent);
    
                response = doPost('customers/'+ StripeCustomerId + '/sources', params);
                body = response.getBody();
                System.debug('link card to customer response >>>>'+body);    
//            }


        }catch(Exception e){
            //token_already_used
        }

    }

    public static String createCustomer(Id AccountId) {
        String StripeCustomerId = null;

        Account acc = [select Name, Customer_Number__c, Stripe_Customer_Id__c from Account where id=:AccountId];

        Map<String, String> params = new Map<String, String>();
        params.put('name', acc.Name);
        params.put('metadata[customer_number]', acc.Customer_Number__c);

        HttpResponse response = doPost('customers', params);
        String body = response.getBody();
        System.debug('body>>>>'+body);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('results>>>>'+results);
        Integer sc = response.getStatusCode();
        System.debug('sc>>>>'+sc);
        
        if (sc >= 200 && sc < 300) {
            StripeCustomerId = (String) results.get('id');
        }
       
        return StripeCustomerId;
    }

    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        // API: https://stripe.com/docs/api/charges/create        

        Id AccountId = authRequest.accountId;
        String StripeCustomerId = null;

        if(AccountId!=null){
            Account customer = [select Id, Stripe_Customer_Id__c from Account where id=:AccountId];
            StripeCustomerId = customer.Stripe_Customer_Id__c;
            if(StripeCustomerId==null || StripeCustomerId==''){
                StripeCustomerId = createCustomer(AccountId);
            }
            System.debug('## StripeCustomerId : ' + StripeCustomerId);
        }
        
        commercepayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;
        System.debug('>>>> authRequest: ' + System.JSON.serializePretty(authRequest));
        System.debug('>>>> paymentMethod: ' + System.JSON.serializePretty(paymentMethod));
        // get the cardPaymentMethod object with the token
        String gatewayToken;
        String stripeCardId;
        String salesforceConsent;
        if(paymentMethod.id !=null) {
            QueryUtils q = new QueryUtils(CardPaymentMethod.SObjectType);
            q.getSelectClause().addField('GatewayToken', false);
            q.getSelectClause().addField('stripe_card_id__c', false);
            
            q.setWhereClause(' WHERE Id =' + '\'' + paymentMethod.id + '\'');
            String query = q.buildSOQL();
            System.debug('>>>> query: ' + query);
            CardPaymentMethod cardPaymentMethod = (CardPaymentMethod)Database.query(query)[0];
            gatewayToken = cardPaymentMethod.GatewayToken;
            stripeCardId = cardPaymentMethod.stripe_card_id__c;
        }

        if (authRequest.additionalData != null) {
            if(stripeCardId==null){
                stripeCardId = authRequest.additionalData.get('StripeCardId');
            }

            if(gatewayToken==null){
                gatewayToken = authRequest.additionalData.get('GatewayToken');
            }

            if(salesforceConsent==null){
                salesforceConsent = authRequest.additionalData.get('saveCard');
            }            
        }

        if (gatewayToken != null && StripeCustomerId!=null && salesforceConsent!=null) {
            linkCardToCustomer(gatewayToken,StripeCustomerId,salesforceConsent);
        }
        
        String currencyIsoCodeLC = authRequest.currencyIsoCode.toLowercase();
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, authRequest.amount);
        
        Map<String, String> params = new Map<String, String>();
        params.put('amount', String.valueOf(amount));
        params.put('currency', currencyIsoCodeLC);
        if(StripeCustomerId!=null){
            params.put('customer',StripeCustomerId);
        }

        if (stripeCardId != null) {
            params.put('source', stripeCardId); 
        }

        //params.put('capture', 'false'); // TODO - how is charge captured?
        //params.put('source','tok_visa'); // TODO - other payment methods
        // params.put('customer','cus_K6l1oSM3m3JXQd'); // TODO - this should come from Account

        HttpResponse response = doPost('charges', params);
        String body = response.getBody();
        System.debug('body>>>>'+body);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('results>>>>'+results);
        Integer sc = response.getStatusCode();
        System.debug('sc>>>>'+sc);
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        
        authResponse.setGatewayDate(system.now());
        
        // map: https://stripe.com/docs/api/errors
        // to: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_commercepayments_SalesforceResultCode.htm
        
        if (sc >= 200 && sc < 300) {
            authResponse.setGatewayResultCode((String) results.get('status'));
            //authResponse.setGatewayResultCodeDescription((String) results.get('status'));
            authResponse.setGatewayResultCodeDescription(StripeCustomerId);            
            authResponse.setGatewayAuthCode((String) results.get('id')); // "ch_..."
            authResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
            //authResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
            authResponse.setAmount(double.valueOf(((Long) integer.valueOf(results.get('amount')))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
        } else {
            // TODO: lots of error mapping/handling
            Map<String, Object> error = (Map<String, Object>) results.get('error');
            System.debug('results>>'+results);
            String errorType = (String) error.get('type');
            String errorCode = (String) error.get('code');
            
            if (errorType.equals('card_error') && DECLINE_CODES.contains(errorCode) ) {
                authResponse.setGatewayResultCode(errorCode);
                authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                authResponse.setGatewayMessage((String) error.get('message'));
                authResponse.setSalesforceResultCodeInfo(RC_DECLINE);
            } else {
                return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
            }
        }
       
        return authResponse;
    }
    
    public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        // API: https://stripe.com/docs/api/charges/capture
                
        // get the GatewayAuthCode
        QueryUtils q = new QueryUtils(PaymentAuthorization.SObjectType);
        q.getSelectClause().addField('GatewayAuthCode', false);
        q.setWhereClause(' WHERE Id =' + '\'' + captureRequest.paymentAuthorizationId + '\'');
        PaymentAuthorization paymentAuthorization = (PaymentAuthorization)Database.query(q.buildSOQL())[0];
        String authCode = paymentAuthorization.GatewayAuthCode;
        
        String currencyIsoCodeLC = 'usd'; // TODO: we need to get this from previous uath
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, captureRequest.amount);
        
        Map<String, String> params = new Map<String, String>();
        params.put('amount', String.valueOf(amount));
        
        HttpResponse response = doPost('charges/' + authCode + '/capture', params);
        
        String body = response.getBody();
        if (response.getStatusCode() != 200) {
            return new commercepayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
        }
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
    
        commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
        //captureResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
        captureResponse.setAmount(double.valueOf(((Long) integer.valueOf(results.get('amount')))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
        captureResponse.setGatewayDate(system.now());
        captureResponse.setGatewayResultCode((String) results.get('balance_transaction'));
        captureResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
        captureResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        return captureResponse;
    }
    
    public commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
         throw new StripeValidationException('TODO: createSaleResponse');  
    }
    
    public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
        // API: https://stripe.com/docs/api/refunds

         // the Stripe charge ID is stored in the PaymentAuthorization gatewayauthcode
        QueryUtils q = new QueryUtils(Payment.SObjectType);
        q.getSelectClause().addField('PaymentAuthorizationId', false);
        q.setWhereClause(' WHERE Id =' + '\'' + refundRequest.paymentId + '\'');
        Payment payment = (Payment)Database.query(q.buildSOQL())[0];

        QueryUtils q1 = new QueryUtils(PaymentAuthorization.SObjectType);
        q1.getSelectClause().addField('GatewayAuthCode', false);
        q1.setWhereClause(' WHERE Id =' + '\'' + payment.PaymentAuthorizationId + '\'');
        PaymentAuthorization paymentAuth = (PaymentAuthorization)Database.query(q1.buildSOQL())[0];

        String currencyIsoCodeLC = 'usd'; // TODO: we need to get this from previous uath
        Long amount = toStripeCurrencyUnits(currencyIsoCodeLC, refundRequest.amount);

        Map<String, String> params = new Map<String, String>();
        params.put('charge', paymentAuth.GatewayAuthCode);
        params.put('amount', String.valueOf(amount));

        HttpResponse response = doPost('refunds', params);

        String body = response.getBody();
        if (response.getStatusCode() != 200) {
            return new commercepayments.GatewayErrorResponse('500', 'ERROR: ' + response + ': ' + body);
        }
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);

        commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
        //refundResponse.setAmount(double.valueOf(((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
        refundResponse.setAmount(double.valueOf(((Long) integer.valueOf(results.get('amount')))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
        refundResponse.setGatewayDate(system.now());
        refundResponse.setGatewayResultCode((String) results.get('balance_transaction'));
        refundResponse.setGatewayResultCodeDescription((String) results.get('receipt_url'));
        refundResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        return refundResponse;
    }

/*
    public static HttpResponse doHTTPPost(String path, Map<String, String> params) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Stripe/v1/');
        // The Stripe Secret API key should be stored as the password in Named Credentials. Username could be anything
        String authorizationHeader = 'Bearer ' + '{!$Credential.Password}';
        request.setHeader('Authorization', authorizationHeader);
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedParams(params));

        Http http = new Http();
        return http.send(request);
    }

    private static HttpResponse doGET(String path, Map<String, String> params) {
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/v1/' + path);

        // The Stripe Secret API key should be stored as the password in Named Credentials. Username could be anything
        String authorizationHeader = 'Bearer ' + '{!$Credential.Password}';
        request.setHeader('Authorization', authorizationHeader);
        
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedParams(params));
        
        return http.send(request);
    }
*/    

    private static HttpResponse doPost(String path, Map<String, String> params) {
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/v1/' + path);

        // The Stripe Secret API key should be stored as the password in Named Credentials. Username could be anything
        String authorizationHeader = 'Bearer ' + '{!$Credential.Password}';
        request.setHeader('Authorization', authorizationHeader);
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedParams(params));
        
        return http.send(request);
    }
    
    private static String urlEncodedParams(Map<String, String> params) {
        String body = '';
        Boolean first = true;
        for (String key: params.keySet()) {
            if (first) {
                first = false;
            } else {
                body += '&';
            }
            // NOTE: do not encode values to allow PaymentsNamedConnection to replace the secure fields
            // values that need to be encoded should be encoded by this method's caller
            body += urlEncode(key) + '=' + params.get(key);
        }
        return body;
    }
    
    private static String urlEncode(String str) {
        return EncodingUtil.urlEncode(str, 'UTF-8');
    }
    
    private static Long toStripeCurrencyUnits(String currencyIsoCodeLC, Double amount) {
        // see https://stripe.com/docs/currencies#zero-decimal
        return Math.roundToLong(amount * 100); // TODO: make sure there are no rounding/precission issues
    }
    
    private static commercepayments.SalesforceResultCodeInfo toCodeInfo(commercepayments.SalesforceResultCode code) {
        return new commercepayments.SalesforceResultCodeInfo(code);
    }
}