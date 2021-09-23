/**
 * @Description : 1.Generates the Default Order for the Customers considering below checks.
 *                 a. Default Order Enabled is true
 *                 b. Preferred Delivery Day 
 *                 c. Lead Time in Days
 *                 d. Cut off time
 *                 2. Creates default order and order line items and send confirmation to customer.  
 */
public class CreateDefaultOrderBatch implements Database.Batchable<sObject>, schedulable{

    public Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT ID, Lead_Time_In_Days__C, Cut_Off_Time__C, Tax_Exemption_Account__c FROM Account WHERE Default_Order_Enabled__C= true';
        return Database.getQueryLocator(queryString); 
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        CreateDefaultOrderUtility.validateAndCreateDefaultOrders((List<Account>) scope);
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new CreateDefaultOrderBatch(), integer.valueOf(Label.CreateDefaultOrderBatchSize));
    } 
    public void finish(Database.BatchableContext BC){
        
    }
}