@isTest
global class StripeMockHttpResponseGenerator  implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
  '"object": "list",'+
  '"url": "/v1/customers",'+
  '"has_more": false,'+
    '"data": ['+
    '{'+
      '"id": "cus_8epDebVEl8Bs2V",'+
      '"object": "customer",'+
      '"address": null,'+
      '"balance": 0,'+
      '"created": 1466202923,'+
      '"currency": "usd",'+
      '"default_source": "card_18NVYR2eZvKYlo2CQ2ieV9S5",'+
      '"delinquent": true,'+
      '"description": "Mia Wilson",'+
      '"discount": null,'+
      '"email": "mia.wilson.99@example.com",'+
      '"invoice_prefix": "D86E170",'+
      '"invoice_settings": {'+
        '"custom_fields": null,'+
        '"default_payment_method": null,'+
        '"footer": null'+
      '},'+
      '"livemode": false,'+
      '"metadata": {'+
        '"order_id": "6735"'+
      '},'+
      '"name": "Lets go",'+
      '"next_invoice_sequence": 285373,'+
      '"phone": null,'+
      '"preferred_locales": [],'+
      '"shipping": null,'+
      '"tax_exempt": "none"'+
    '}'+
  ']'+
'}');
        res.setStatusCode(200);
        return res;
    }
}