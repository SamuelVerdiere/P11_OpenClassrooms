global class AccountReminderTaskBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Integer processedRecords = 0;

    global Database.QueryLocator start(Database.BatchableContext info) {
        //query each account that does not have order
        return Database.getQueryLocator('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }

    global void execute (Database.BatchableContext info, List<Account> scope) {
        //create set of ids for pre existing tasks
        Set<Id> existingTask = new Set<Id>();
        //create list to query existing tasks for account
        List<Task> listOfPresentTasks = [SELECT WhatId FROM task WHERE what.type = 'Account' AND ReminderDateTime > TODAY AND WhatId IN: scope];
        //for each task in that list, add its id to the set
        for(Task oldTask: listOfPresentTasks) {
            existingTask.add(oldTask.WhatId);
        }
        //for each account of the scope that does not have a task - that does not contain task id from the set - add task to list + insert
        List<Task> listOfNewTasks = new List<Task>();
        //create date variable for customizing task
        Date myDate = System.today();
        myDate.addDays(5);
        //For each account of the scope,
        for(Account acc : scope) {
            //if the account does not contain task,
            if(!existingTask.contains(acc.Id)) {
                //create new task and add it to list
                Task newTask = new Task (Description = 'Call client. Reminder in 5 days.', 
                Status = 'New', 
                Subject = 'Call', 
                ReminderDateTime = myDate,
                WhatId = acc.Id, Priority = 'Normal', CallType = 'Outbound');
                listOfNewTasks.add(newTask);
            }
            //add 1 to number of records processed
            processedRecords += 1;
        }
        //if that list of new tasks isn't empty, insert tasks from this list
        if(!listOfNewTasks.isEmpty()) {
            insert listOfNewTasks;
            System.debug('tasks created: ' + listOfNewTasks);
        }
    }

    global void finish(Database.BatchableContext info) {
        //get infos from job
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :info.getJobId()
        ];
        //display job & number of records that were processed
        System.debug(job);
        System.debug('There were ' + processedRecords + ' records processed.');
    }

}