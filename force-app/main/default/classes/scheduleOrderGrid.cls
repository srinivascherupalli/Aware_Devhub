global class scheduleOrderGrid implements schedulable{

   global void execute(Schedulablecontext sc)
          {
             PastOrdersGridBatch oGridBatch=new PastOrdersGridBatch();
             //Database.executeBatch(instance,size);
             Database.executeBatch(oGridBatch,50);
          }

}