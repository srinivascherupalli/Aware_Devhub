public with sharing class CancelOrder {

    @InvocableMethod(label='Cancel Order' description='Cancel the order summary.' category='B2B Commerce')
    public static void cancelOrder(List<String> orderSumaryIds) {

        String id = '';

        try {

            for(String orderSummaryId: orderSumaryIds){
                id = orderSummaryId;
            }

            //Cancel the order
            OrderSummary os = [SELECT Id, AccountId, Status, GrandTotalAmount FROM OrderSummary WHERE id=:id LIMIT 1];
            os.status = 'Cancelled';
            update os;

            //Add credit back to the Customer
            BuyerAccount ba = [select CurrentBalance from BuyerAccount where BuyerId=:os.AccountId];
            ba.CurrentBalance = ba.CurrentBalance - os.GrandTotalAmount;
            update ba;

        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage());
        }
    }
}