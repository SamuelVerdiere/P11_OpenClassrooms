global class SchedulerReminderTaskBatchable implements Schedulable{

	global void execute(SchedulableContext info){
		//instantiate batch class & execute it, limit batch to 200 records   
		AccountReminderTaskBatch art = new AccountReminderTaskBatch();
		Database.ExecuteBatch(art, 200);
	}
}