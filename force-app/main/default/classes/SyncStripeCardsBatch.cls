public with sharing class SyncStripeCardsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable{

    List<CardPaymentMethod> cardPaymnetMethodList = new List<CardPaymentMethod>();
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'SELECT Id, Name, Stripe_Customer_Id__c ' + 
        ' FROM Account where Stripe_Customer_Id__c != null' ;

		return Database.getQueryLocator(query); 
	}

	public void execute(Database.BatchableContext context, List<Account> accountList){
        String endPoint = 'callout:Stripe/v1/customers/';
        for(Account accObj: accountList){
            updateCardInfo(accObj, endPoint);
        }
        Schema.SObjectField uniqueField = CardPaymentMethod.Fields.stripe_card_id__c;
        if(!cardPaymnetMethodList.isEmpty()){
            database.upsert(cardPaymnetMethodList, uniqueField, false);
        }
		
	}
    public void execute(SchedulableContext SC) {
        database.executebatch(new OrderGridBatchProcess(), integer.valueOf(Label.SyncStripeCardsBatchSize));
    } 
 
	public void finish(Database.BatchableContext context){
		//
	}

    public void updateCardInfo(Account accObj, String endPoint){
        //For each account do an API call to Stripe
        //Get Card info 
        //Update the account card info.
        String endOfURL = '/sources?object=card';
        String stripeId = accObj.Stripe_Customer_Id__c;
        String completeEndPoint = endPoint +stripeId+endOfURL;
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(completeEndPoint);
        String authorizationHeader = 'Bearer '  + '{!$Credential.Password}';
        request.setheader('Authorization', authorizationHeader);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response.
        System.debug('Response :'+ response.getStatusCode());
        if(response.getStatusCode() == 200) {
            System.debug('Received the following :'+ response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());    
            saveCardInfo(accObj, parser);     
        }


    }

    public void saveCardInfo(Account accObj, JSONParser parser){
        String stripeCardId = '';
        String lastFour = '';
        String exp_year = '';
        String expiryMonth ='';
        String brand = '';
        String salesforce_consent = 'true';
//List<CardPaymentMethod> cardPaymnetMethodList = new List<CardPaymentMethod>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if(parser.getText() == 'id'){
                    
                    // Get the value.
                    parser.nextToken();
                    stripeCardId  = parser.getText();
                    //Setting salesforce consent to blank so that for every card its checked. 
                    salesforce_consent = 'true';
                }
                if(parser.getText() == 'last4'){
                    // Get the value.
                    parser.nextToken();
                    lastFour = parser.getText();
                }
                if(parser.getText() == 'exp_year'){
                    // Get the value.
                    parser.nextToken();

                    exp_year = parser.getText();
                }
                if(parser.getText() == 'exp_month'){
                    // Get the value.
                    parser.nextToken();

                    expiryMonth = parser.getText();
                }
                if(parser.getText() == 'brand'){
                    // Get the value.
                    parser.nextToken();

                    brand = parser.getText();
                    if(brand == 'MasterCard'){
                        brand = 'Master Card';
                    }
                }
                if(parser.getText() == 'salesforce_consent'){
                    // Get the value.
                    parser.nextToken();

                    salesforce_consent = parser.getText();
                }
                if(parser.getText() == 'tokenization_method'){
                    // Get the value.
                    parser.nextToken();
                    if(!String.isBlank(stripeCardId) && salesforce_consent != 'false'){
                        CardPaymentMethod cObj = new CardPaymentMethod();
                        cObj.status = 'Active';
                        cObj.ProcessingMode = 'External';
                        cObj.AccountId = accObj.id;
                        cObj.CardLastFour =  Integer.valueOf(lastFour);
                        cObj.ExpiryYear = Integer.valueOf(exp_year);
                        cObj.ExpiryMonth = Integer.valueOf(expiryMonth);
                        cObj.CardType = brand;
                        cObj.stripe_card_id__c=stripeCardId;                    
                        cardPaymnetMethodList.add(cObj);
                    }
                }
            }
        }
    }
}