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
        return null;
    }
}