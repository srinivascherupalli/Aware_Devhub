@RestResource(urlMapping='/paymentstatuswebservice')
global class PaymentStatusUpdateWebService {
    @HttpGet
    global static String doGet() {
        System.debug('Inside Get Method');
        RestRequest req = RestContext.request;
        System.debug('req>>>>>'+req);
        System.debug('reqBody>>>>>'+req.requestBody.toString());
        return null;
    }
    @HttpPost
    global static String doPost() {
        System.debug('Inside Post Method');
        RestRequest req = RestContext.request;
        System.debug('req>>>>>'+req);
        System.debug('reqBody>>>>>'+req.requestBody.toString());
        processParse(req.requestBody.toString());
        return null;
    }

    public static void processResponse(String responseBody){
        //List<Object> lst_JsonParse = (List<Object>)Json.deserializeUntyped(responseBody);
        Object lst_JsonParse = (Object)Json.deserializeUntyped(responseBody);
        String uniqueIdentifier;
        String callingSystem;
        String stripeEvent;
        /*for(Object obj : lst_JsonParse)
        {
            Map<String,Object> mp_StrObj = (Map<string,Object>)obj;

            if(mp_StrObj.containsKey('type')){
                stripeEvent = string.valueOf(mp_StrObj.get('type'));
            }
            if(mp_StrObj.containsKey('data')){                
                Object dataObject = mp_StrObj.get('data');
                Map<String,Object> dataObjectMap = (Map<string,Object>)dataObject;
                System.debug('dataObjectMap>>>>'+dataObjectMap);
            }
        }*/
        Map<String,Object> mp_StrObj = (Map<string,Object>)lst_JsonParse;

        System.debug('mp_StrObj>>>>'+mp_StrObj);
    }

    public static void processParse(String responseBody){
        String responseBodyV2 = '{'+
            '"id": "evt_3JcfAiDhEzDFhV694KospsrV",'+
            '"object": "event",'+
            '"api_version": "2020-08-27",'+
            '"created": 1632354497,'+
            '"data": {'+
              '"object": {'+
                '"id": "ch_3Jck6LDhEzDFhV692OKaxyZq",'+
                '"object": "charge",'+
                '"amount": 206592,'+
                '"amount_captured": 0,'+
                '"amount_refunded": 0,'+
                '"application": null,'+
                '"application_fee": null,'+
                '"application_fee_amount": null,'+
                '"balance_transaction": null,'+
                '"billing_details": {'+
                  '"address": {'+
                    '"city": null,'+
                    '"country": null,'+
                    '"line1": null,'+
                    '"line2": null,'+
                    '"postal_code": null,'+
                    '"state": null'+
                  '},'+
                  '"email": null,'+
                  '"name": null,'+
                  '"phone": null'+
                '},'+
                '"calculated_statement_descriptor": "Stripe",'+
                '"captured": false,'+
                '"created": 1632354496,'+
                '"currency": "aud",'+
                '"customer": null,'+
                '"description": null,'+
                '"destination": null,'+
                '"dispute": null,'+
                '"disputed": false,'+
                '"failure_code": null,'+
                '"failure_message": null,'+
                '"fraud_details": {'+
                '},'+
                '"invoice": null,'+
                '"livemode": false,'+
                '"metadata": {'+
                '},'+
                '"on_behalf_of": null,'+
                '"order": null,'+
                '"outcome": {'+
                '"network_status": "approved_by_network",'+
                '  "reason": null,'+
                ' "risk_level": "normal",'+
                ' "risk_score": 36,'+
                ' "seller_message": "Payment complete.",'+
                ' "type": "authorized"'+
                '},'+
                '"paid": true,'+
                '"payment_intent": null,'+
                '"payment_method": "card_1JcfAiDhEzDFhV69ZFRPBS0A",'+
                '"payment_method_details": {'+
                ' "card": {'+
                '   "brand": "visa",'+
                '   "checks": {'+
                '     "address_line1_check": null,'+
                '     "address_postal_code_check": null,'+
                '     "cvc_check": null'+
                '   },'+
                '   "country": "US",'+
                '   "exp_month": 9,'+
                '   "exp_year": 2022,'+
                '   "fingerprint": "9iSkj3dizaetjr7X",'+
                '   "funding": "credit",'+
                '   "installments": null,'+
                '   "last4": "4242",'+
                '   "network": "visa",'+
                '   "three_d_secure": null,'+
                '   "wallet": null'+
                ' },'+
                ' "type": "card"'+
                '},'+
                '"receipt_email": null,'+
                '"receipt_number": null,'+
                //"receipt_url": "https://pay.stripe.com/receipts/acct_1JRsL3DhEzDFhV69/ch_3JcfAiDhEzDFhV694yax3BKE/rcpt_KHDbETPexVVVnEvrhzGjpK4MHX4zGlV", 
                '"refunded": false,'+
                '"refunds": {'+
                ' "object": "list",'+
                ' "data": ['+          
                ' ],'+
                ' "has_more": false,'+
                ' "total_count": 0,'+
                ' "url": "/v1/charges/ch_3JcfAiDhEzDFhV694yax3BKE/refunds"'+
                '},'+
                '"review": null,'+
                '"shipping": null,'+
                '"source": {'+
                ' "id": "card_1JcfAiDhEzDFhV69ZFRPBS0A",'+
                ' "object": "card",'+
                ' "address_city": null,'+
                ' "address_country": null,'+
                ' "address_line1": null,'+
                ' "address_line1_check": null,'+
                ' "address_line2": null,'+
                ' "address_state": null,'+
                ' "address_zip": null,'+
                ' "address_zip_check": null,'+
                ' "brand": "Visa",'+
                ' "country": "US",'+
                ' "customer": null,'+
                ' "cvc_check": null,'+
                ' "dynamic_last4": null,'+
                ' "exp_month": 9,'+
                ' "exp_year": 2022,'+
                ' "fingerprint": "9iSkj3dizaetjr7X",'+
                ' "funding": "credit",'+
                ' "last4": "4242",'+
                ' "metadata": {'+
                ' },'+
                ' "name": null,'+
                ' "tokenization_method": null'+
                '},'+
                '"source_transfer": null,'+
                '"statement_descriptor": null,'+
                '"statement_descriptor_suffix": null,'+
                '"status": "succeeded",'+
                '"transfer_data": null,'+
                '"transfer_group": null'+
                '}'+
                '},'+
                '"livemode": false,'+
                '"pending_webhooks": 3,'+
                '"request": {'+
                '      "id": "req_iWmE0MojnhAQxU",'+
                '"idempotency_key": null'+
                '},'+
                '"type": "charge.succeeded"'+
                '}'; 

               Object lst_JsonParse = (Object)Json.deserializeUntyped(responseBody);
                //Object lst_JsonParse = (Object)Json.deserializeUntyped(responseBodyV2);
                System.debug('lst_JsonParse>>>'+lst_JsonParse);
                Map<String,Object> mp_StrObj = (Map<string,Object>)lst_JsonParse;
                String uniqueIdentifier;
                String callingSystem;
                String stripeEvent;

                System.debug('mp_StrObj>>>>'+mp_StrObj);

                if(mp_StrObj.containsKey('type')){
                    stripeEvent = string.valueOf(mp_StrObj.get('type'));
                }
                System.debug('stripeEvent>>>>'+stripeEvent);                
                if(mp_StrObj.containsKey('data')){                
                    Object dataObject = mp_StrObj.get('data');
                    Map<String,Object> dataObjectMap = (Map<string,Object>)dataObject;
                    System.debug('dataObjectMap>>>>'+dataObjectMap);                        
                    if(dataObjectMap.containsKey('object')){
                        Object ObjectDetails = dataObjectMap.get('object');
                        Map<String,Object> ObjectDetailsMap = (Map<string,Object>)ObjectDetails;
                        for(String str:ObjectDetailsMap.keySet()){
                            System.debug('key>>>>'+str);
                            System.debug('value>>>>'+ObjectDetailsMap.get(str));
                            if(ObjectDetailsMap.containsKey('id')){
                                uniqueIdentifier = String.valueOf(ObjectDetailsMap.get('id'));
                            }
                        }
                    }
                    
                }
                
                System.debug('uniqueIdentifier>>>>'+uniqueIdentifier);
                dateTime start = system.now();
                while(system.now()< start.addSeconds(5)){}
                updatePaymentStatus(uniqueIdentifier);
                
    }
    private static void updatePaymentStatus(String uniqueIdentifier){

        PaymentAuthorization PaymentAuthorizationVar = [Select Id, Status, OrderPaymentSummaryId From PaymentAuthorization where GatewayAuthCode =: uniqueIdentifier];
        System.debug('w>>>>>'+PaymentAuthorizationVar);
        
        if(PaymentAuthorizationVar.OrderPaymentSummaryId != null){
        
            OrderPaymentSummary OrderPaymentSummaryVar = [Select Id, OrderSummaryId From OrderPaymentSummary Where Id =: PaymentAuthorizationVar.OrderPaymentSummaryId];
            System.debug('OrderPaymentSummaryVar>>>>'+OrderPaymentSummaryVar);
            System.debug('OrderPaymentSummaryVar>>>>'+OrderPaymentSummaryVar.OrderSummaryId);

            OrderSummary OrderSummaryIdVar = [Select Id, OriginalOrderId, Payment_Status__c from OrderSummary Where Id=: OrderPaymentSummaryVar.OrderSummaryId];
            System.debug('OrderSummaryIdVar>>>>'+OrderSummaryIdVar);
            System.debug('OrderSummaryIdVar>>>>'+OrderSummaryIdVar.OriginalOrderId);

            if(PaymentAuthorizationVar.Status == 'Processed'){
                OrderSummaryIdVar.Payment_Status__c = 'Paid';
                update OrderSummaryIdVar;
            }
            System.debug('OrderSummaryIdVar>>>>'+OrderSummaryIdVar);
        }
        
        

    }
}