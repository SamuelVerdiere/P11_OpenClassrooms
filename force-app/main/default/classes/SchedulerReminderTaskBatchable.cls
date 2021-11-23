global class SchedulerReminderTaskBatchable implements Schedulable{

	global void execute(SchedulableContext info){
		//cron expression for 1st Monday of each month: 0 0 12 ? 1/1 MON#1 *   
		AccountReminderTaskBatch art = new AccountReminderTaskBatch();
		Database.ExecuteBatch(art, 200);
	}
}

/*
In Dev Console
SchedulerReminderTask srt = new SchedulerReminderTask();
String sch = '0 0 12 ? 1/1 MON#1 * ';
String jobID = system.schedule('Merge Job', sch, srt);
*/