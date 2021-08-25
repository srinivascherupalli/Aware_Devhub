global class OrderGridBatchScheduler implements Schedulable{
    public execute(SchedulableContext sc) {
        List<Account> accountList = [
            SELECT Id 
            FROM Account
        ];
        OrderGridBatch ob = new OrderGridBatch();
        for(Account account : accountList) {
            //ob.OrderGridBatch();
        }
    }
}
