global class StripeCardsMockHttpResponseGenerator implements HttpCalloutMock{
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
                    '"url": "/v1/customers/cus_8epDebVEl8Bs2V/sources",'+
                    '"has_more": false,'+
                    '"data": ['+
                        '{'+
                        '"id": "card_1JjZDo2eZvKYlo2CLPbRiDH2",'+
                        '"object": "card",'+
                        '"brand": "Visa",'+
                        '"country": "US",'+
                        '"customer": "cus_8epDebVEl8Bs2V",'+
                        '"exp_month": 8,'+
                        '"exp_year": 2022,'+
                        '"fingerprint": "Xt5EWLLDS7FJjR1c",'+
                        '"funding": "credit",'+
                        '"last4": "4242",'+
                        '"metadata": {},'+
                        '"name": null,'+
                        '"tokenization_method": null'+
                        '}'+
                    ']'+
                    '}');
        res.setStatusCode(200);
        return res;
    }

}