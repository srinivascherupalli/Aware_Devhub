@isTest(SeeAllData=true)
public  class PaymentStatusUpdateWebServiceTest {
    
    public static testmethod void testPostMessageFailureScenario() {

        OrderDeliveryMethod OrderDeliveryMethodVar = TestDataFactory.getOrderDeliveryMethod();
        insert OrderDeliveryMethodVar;

        Account account = TestDataFactory.getAccounts(1)[0];
        insert account;
        WebStore webStore = TestDataFactory.getWebStore();
        insert webStore;
        WebCart cart = TestDataFactory.getCart(webStore.Id, account.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = TestDataFactory.getCartDeliveryGroup(cart.Id);
        insert cartDeliveryGroup;
        
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 Pricebook2Var = TestDataFactory.getCustomPricebook('TestPriceBook');
        insert Pricebook2Var;

        List<product2> productList = TestDataFactory.getProducts(1);       
        insert productList ;

        List<PricebookEntry> PricebookEntryStandard = TestDataFactory.getPricebookEntry(pricebookId, productList);
        insert PricebookEntryStandard;

        List<PricebookEntry> PricebookEntryCustom = TestDataFactory.getPricebookEntry(Pricebook2Var.Id, productList);
        insert PricebookEntryCustom;

        WebStore getWebStoreVar = TestDataFactory.getWebStore();
        insert getWebStoreVar;


        ID odmId = OrderDeliveryMethodVar.Id; // Order Delivery Method
        ID productId = productList[0].Id; // Ordered product
        ID storeId = getWebStoreVar.Id; // Webstore (aka "sales store")
        ID accountId =account.Id; // The order will be related to this account
        ID buyerId = userInfo.getuserId(); // The order will be owned by this buyer

        Order o;
        OrderItem oi;
        OrderDeliveryGroup odg;

        // Create order

        ///////////////

        o = new Order();
        o.AccountId=accountId;
        o.SalesStoreId=storeId;
        o.Status='Draft';
        o.EffectiveDate=date.today();
        o.OwnerId = buyerId;
        o.Pricebook2Id = Pricebook2Var.Id;
        insert o;
        

        // Create Order Delivery Group

        ///////////////////////////////
        odg = new OrderDeliveryGroup();
        odg.OrderId=o.id;
        odg.OrderDeliveryMethodId=odmId;
        odg.DeliverToName='The Shipping Address';
        insert odg;

        // Add Order Item to Order
        ///////////////////////////
        oi = new OrderItem();
        oi.OrderId=o.Id;
        oi.OrderDeliveryGroupId = odg.Id;
        oi.Product2Id=productId;
        oi.Quantity=1;
        //oi.ListPrice=999;
        oi.priceBookEntryId=PricebookEntryCustom[0].Id;
        oi.UnitPrice=999;
        oi.TotalLineAmount=999;
        oi.Type='Order Product';
        insert oi;
        

        // Activate order
        o = [SELECT ID FROM Order Where Id=:o.Id];
        o.Status = 'Activated';
        update o;
        

        ID oId = o.Id; // Order ID
        
        System.debug('oId>>>>'+oId);
        // create order summary
        ConnectApi.OrderSummaryInputRepresentation osir = new
        ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=oId;
        osir.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor =
        ConnectApi.OrderSummaryCreation.createOrderSummary(osir);   


        OrderSummary OrderSummaryVar = [Select Id From OrderSummary limit 1];
        System.debug('OrderSummaryVar>>>>'+OrderSummaryVar);
        //OrderPaymentSummary OrderPaymentSummaryVar = new OrderPaymentSummary();
        DateTime currentTimeVar = Datetime.now();
        String uniqueId = string.valueOf(currentTimeVar.millisecond());
        //'"id": "evt_3JcfAiDhEzDFhV694KospsrV",'+
        String uniqueString = '"'+uniqueId+'"';
        String reqst = '{'+
        '"id": "evt_3JcfAiDhEzDFhV694KospsrV",'+
            '"object": "event",'+
            '"api_version": "2020-08-27",'+
            '"created": 1632354497,'+
            '"data": {'+
              '"object": {'+
              '"id":'+ uniqueString +','+
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
                System.debug('reqst>>>>>'+reqst);
                String JsonMsg=JSON.serialize(reqst);

                Test.startTest();

                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();
                req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
                req.httpMethod = 'POST';//HTTP Request Type
                req.requestBody = Blob.valueof(reqst);
                RestContext.request = req;
                RestContext.response= res;
                PaymentStatusUpdateWebService.doPost();
                Test.stopTest();
    }
    public static testmethod void testPostMessage() {

      OrderDeliveryMethod OrderDeliveryMethodVar = TestDataFactory.getOrderDeliveryMethod();
      insert OrderDeliveryMethodVar;

      Account account = TestDataFactory.getAccounts(1)[0];
      insert account;
      WebStore webStore = TestDataFactory.getWebStore();
      insert webStore;
      WebCart cart = TestDataFactory.getCart(webStore.Id, account.Id);
      insert cart;
      CartDeliveryGroup cartDeliveryGroup = TestDataFactory.getCartDeliveryGroup(cart.Id);
      insert cartDeliveryGroup;
      
      Id pricebookId = Test.getStandardPricebookId();

      Pricebook2 Pricebook2Var = TestDataFactory.getCustomPricebook('TestPriceBook');
      insert Pricebook2Var;

      List<product2> productList = TestDataFactory.getProducts(1);       
      insert productList ;

      List<PricebookEntry> PricebookEntryStandard = TestDataFactory.getPricebookEntry(pricebookId, productList);
      insert PricebookEntryStandard;

      List<PricebookEntry> PricebookEntryCustom = TestDataFactory.getPricebookEntry(Pricebook2Var.Id, productList);
      insert PricebookEntryCustom;

      WebStore getWebStoreVar = TestDataFactory.getWebStore();
      insert getWebStoreVar;


      ID odmId = OrderDeliveryMethodVar.Id; // Order Delivery Method
      ID productId = productList[0].Id; // Ordered product
      ID storeId = getWebStoreVar.Id; // Webstore (aka "sales store")
      ID accountId =account.Id; // The order will be related to this account
      ID buyerId = userInfo.getuserId(); // The order will be owned by this buyer

      Order o;
      OrderItem oi;
      OrderDeliveryGroup odg;

      // Create order

      ///////////////

      o = new Order();
      o.AccountId=accountId;
      o.SalesStoreId=storeId;
      o.Status='Draft';
      o.EffectiveDate=date.today();
      o.OwnerId = buyerId;
      o.Pricebook2Id = Pricebook2Var.Id;
      insert o;
      

      // Create Order Delivery Group

      ///////////////////////////////
      odg = new OrderDeliveryGroup();
      odg.OrderId=o.id;
      odg.OrderDeliveryMethodId=odmId;
      odg.DeliverToName='The Shipping Address';
      insert odg;

      // Add Order Item to Order
      ///////////////////////////
      oi = new OrderItem();
      oi.OrderId=o.Id;
      oi.OrderDeliveryGroupId = odg.Id;
      oi.Product2Id=productId;
      oi.Quantity=1;
      //oi.ListPrice=999;
      oi.priceBookEntryId=PricebookEntryCustom[0].Id;
      oi.UnitPrice=999;
      oi.TotalLineAmount=999;
      oi.Type='Order Product';
      insert oi;
      

      // Activate order
      o = [SELECT ID FROM Order Where Id=:o.Id];
      o.Status = 'Activated';
      update o;
      

      ID oId = o.Id; // Order ID
      
      System.debug('oId>>>>'+oId);
      // create order summary
      ConnectApi.OrderSummaryInputRepresentation osir = new
      ConnectApi.OrderSummaryInputRepresentation();
      osir.orderId=oId;
      osir.orderLifeCycleType='UNMANAGED';
      ConnectApi.OrderSummaryOutputRepresentation osor =
      ConnectApi.OrderSummaryCreation.createOrderSummary(osir); 


      OrderSummary OrderSummaryVar = [Select Id From OrderSummary where OriginalOrderId =: oId limit 1];
      System.debug('OrderSummaryVar>>>>'+OrderSummaryVar);
      //OrderPaymentSummary OrderPaymentSummaryVar = new OrderPaymentSummary();     


      DateTime currentTimeVar = Datetime.now();
      String uniqueId = string.valueOf(currentTimeVar.millisecond());
      //'"id": "evt_3JcfAiDhEzDFhV694KospsrV",'+
      String uniqueString = '"'+uniqueId+'"';
      String reqst = '{'+
      '"id": "evt_3JcfAiDhEzDFhV694KospsrV",'+
          '"object": "event",'+
          '"api_version": "2020-08-27",'+
          '"created": 1632354497,'+
          '"data": {'+
            '"object": {'+
            '"id":'+ uniqueString +','+
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
              System.debug('reqst>>>>>'+reqst);
              String JsonMsg=JSON.serialize(reqst);
              /*OrderPaymentSummary OrderPaymentSummaryVar = [Select Id from OrderPaymentSummary Where OrderSummaryId=: OrderSummaryVar.Id];
              System.debug('OrderPaymentSummaryVar>>>>'+OrderPaymentSummaryVar);
              
              PaymentAuthorization PaymentAuthorizationVar = [Select Id, GatewayAuthCode From PaymentAuthorization Where OrderPaymentSummaryId=: OrderPaymentSummaryVar.Id];
              System.debug('PaymentAuthorizationVar>>>>'+PaymentAuthorizationVar);*/

              /*OrderPaymentSummary OrderPaymentSummaryVar = new OrderPaymentSummary();
              OrderPaymentSummaryVar.OrderSummaryId = OrderSummaryVar.Id;
              insert OrderPaymentSummaryVar;*/
              
              PaymentAuthorization PaymentAuthorizationVar = new PaymentAuthorization();
              PaymentAuthorizationVar.GatewayAuthCode = uniqueId;
              PaymentAuthorizationVar.Amount = 100;
              PaymentAuthorizationVar.Status = 'Processed';
              PaymentAuthorizationVar.ProcessingMode = 'External';
              //PaymentAuthorizationVar.OrderPaymentSummaryId = OrderPaymentSummaryVar.Id;
              insert PaymentAuthorizationVar;

              ConnectApi.CreateOrderPaymentSummaryInputRepresentation ops = new
            ConnectApi.CreateOrderPaymentSummaryInputRepresentation();
            ops.orderSummaryId=OrderSummaryVar.Id;
            ops.paymentAuthorizationId=PaymentAuthorizationVar.Id;
            //ConnectApi.orderPaymentSummaryOutputRepresentation opsOutput =
            //ConnectApi.OrderSummaryCreation.createOrderPaymentSummary(opsOutput); 


              Test.startTest();

              RestRequest req = new RestRequest(); 
              RestResponse res = new RestResponse();
              req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
              req.httpMethod = 'POST';//HTTP Request Type
              req.requestBody = Blob.valueof(reqst);
              RestContext.request = req;
              RestContext.response= res;
              PaymentStatusUpdateWebService.doPost();
              Test.stopTest();
  }
}