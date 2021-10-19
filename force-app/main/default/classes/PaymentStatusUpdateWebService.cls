/**
 * @Description public webservice to update the payment status on order summary and order records once the 
 *              credit card payment is done for an order
 */
@RestResource(urlMapping='/paymentstatuswebservice')
global class PaymentStatusUpdateWebService {
    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        return null;
    }
    @HttpPost
    global static String doPost() {
        try{
            System.debug('Inside Post Method');
            RestRequest req = RestContext.request;
            processResponse(req.requestBody.toString());
         
        }Catch (Exception error){
            String failedDML = error.getMessage();               
            createExceptionLog('', 'Update Payment Status', 'PaymentStatusUpdateWebService', 'doPost', failedDML);
        }
        return null;
    }
    
    public static void processResponse(String responseBody){
        Object lst_JsonParse = (Object)Json.deserializeUntyped(responseBody);
        System.debug('lst_JsonParse>>>'+lst_JsonParse);
        Map<String,Object> mp_StrObj = (Map<string,Object>)lst_JsonParse;
        String uniqueIdentifier;
        String callingSystem;
        String stripeEvent;

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
        if(!test.isRunningTest()){
            while(system.now()< start.addSeconds(5)){}
        }
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

            Order orderRecord = [Select Id, Payment_Status__c From Order Where Id =: OrderSummaryIdVar.OriginalOrderId ];

            if(PaymentAuthorizationVar.Status == 'Processed'){
                OrderSummaryIdVar.Payment_Status__c = 'Paid';
                update OrderSummaryIdVar;

                orderRecord.Payment_Status__c = 'Paid';
                update orderRecord;
            }
            System.debug('OrderSummaryIdVar>>>>'+OrderSummaryIdVar);
        }
    }
    
    private static void createExceptionLog(String parentRecordId, String businessProcess, String className, String methodName, String errorMsg){
        
        Exception_Log__c exceptionRecord = new Exception_Log__c();
        exceptionRecord.Parent_Record_Id__c = parentRecordId ;
        exceptionRecord.Business_process__c = businessProcess ; 
        exceptionRecord.Class_Name__c = className ;
        exceptionRecord.Method_Name__c = methodName ; 
        exceptionRecord.Error_Message__c = errorMsg ;

        insert exceptionRecord;
    }
}