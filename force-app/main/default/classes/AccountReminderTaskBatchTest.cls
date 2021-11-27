@isTest
public with sharing class AccountReminderTaskBatchTest {
    @isTest
    static void AssumeTaskIsCreated() {
        //GIVEN :
            //create empty account
        Account myAccount = new Account(Name = 'Test Account');
        insert myAccount;
            //see if there is task within that account
        List<Task> noTasks = [SELECT Id FROM Task WHERE WhatId =: myAccount.Id];
        //WHEN : run batch
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
            //get new values from the account and task
        Account newAccount = [SELECT Id FROM Account];
        List<Task> newTasks = [SELECT WhatId, Subject, Description FROM Task];
        Task myNewTask = [SELECT WhatId, Subject, Description FROM Task LIMIT 1];
        //THEN :
            //assume there was no task at start, and a task after batch
        System.assertEquals(0, noTasks.size());
        System.assertEquals(1, newTasks.size());
            //identify parameters from task to be sure
        System.assertEquals('Call', myNewTask.Subject);
        System.assertEquals('Call client. Reminder in 5 days.', myNewTask.Description);
    }

    @isTest
    static void compareTwoAccounts() {
        //GIVEN
        Date myDate = System.today();
            //Create first account
        Account myAccount = new Account(Name= 'Test Account');
        insert myAccount;
            //create another account which has already a task
        DataFactory.createOrders(1, 0, 0, 1);
        String nam = 'Account for';
        //select account with task; create list of tasks from 1st account; then list of tasks for 2nd account; 
        //then select task from account with task
        Account accWithTask = [SELECT Id FROM Account WHERE Name LIKE:'%' + nam + '%' LIMIT 1];
        List<Task> noTasks = [SELECT Id FROM Task WHERE WhatId =: myAccount.Id];
        List<Task> sizeOneTasks= [SELECT Id FROM Task WHERE WhatId =: accWithTask.Id];
        Task readyTask = [SELECT Id, Description FROM Task WHERE WhatId =: accWithTask.Id];
        //WHEN : use Batch
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
            //get updated walues for tasks from 1st account and task from this 1st account which had no task on start
        List<Task> tasksCreated = [SELECT WhatId, Description FROM Task WHERE WhatId =:myAccount.Id];
        Task createdTask = [SELECT WhatId, Description FROM Task WHERE WhatId =:myAccount.Id LIMIT 1];
        //THEN
            //assume the 1st account had no task, the 2nd had 1
        System.assertEquals(1, sizeOneTasks.size());
        System.assertEquals(0, noTasks.size());
        System.assertNotEquals(sizeOneTasks.size(), noTasks.size());
            //compare created tasks, one from batch, the other from datafactory
        System.assertEquals('Call now', readyTask.Description);
        System.assertEquals('Call client. Reminder in 5 days.', createdTask.Description);
        System.assertNotEquals(readyTask.Description, createdTask.Description);
            //compare new values of tasks lists size
        System.assertEquals(sizeOneTasks.size(),tasksCreated.size());
    }

    @isTest
    static void checkWithManyAccounts() {
        //GIVEN :
            //create empty accounts
        DataFactory.createOrders(200, 0, 0, 0);
        String nam = 'Account for';
            //see if there is task within accounts
        List<Account> accWithoutTasks = [SELECT Id FROM Account];
        Account accWithNoTask = [SELECT Id FROM Account WHERE Name LIKE:'%' + nam + '%' LIMIT 1];
        List<Task> noTasks = [SELECT Id FROM Task];
        //WHEN : run batch
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
            //get new values from the account and task
        Account newAccount = [SELECT Id FROM Account LIMIT 1];
        List<Task> newTasks = [SELECT WhatId, Subject, Description FROM Task];
        Task myNewTask = [SELECT WhatId, Subject, Description FROM Task LIMIT 1];
        //THEN :
            //assume there was no task at start, and a task after batch
        System.assertEquals(0, noTasks.size());
        System.assertEquals(200, newTasks.size());
            //identify parameters from task to be sure
        System.assertEquals('Call', myNewTask.Subject);
        System.assertEquals('Call client. Reminder in 5 days.', myNewTask.Description);
    }

    @isTest
    static void getErrorIfBatchTooBig() {
        //GIVEN :
            //create empty accounts
        DataFactory.createOrders(200, 0, 0, 0);
        String nam = 'Account for';
            //see if there is task within accounts
        List<Account> accWithoutTasks = [SELECT Id FROM Account];
        Account accWithNoTask = [SELECT Id FROM Account WHERE Name LIKE:'%' + nam + '%' LIMIT 1];
        List<Task> noTasks = [SELECT Id FROM Task];
        //WHEN : run batch
        Test.startTest();
        SchedulerReminderTaskBatchable myschedule = new SchedulerReminderTaskBatchable();
        String d = '0 0 1 1/1 * ? *';
        System.schedule('batch Schedule', d, myschedule);
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
            //get new values from the account and task
        Account newAccount = [SELECT Id FROM Account LIMIT 1];
        List<Task> newTasks = [SELECT WhatId, Subject, Description FROM Task];
        Task myNewTask = [SELECT WhatId, Subject, Description FROM Task LIMIT 1];
        //THEN :
            //assume there was no task at start, and a task after batch
        System.assertEquals(0, noTasks.size());
        System.assertEquals(200, newTasks.size());
            //identify parameters from task to be sure
        System.assertEquals('Call', myNewTask.Subject);
        System.assertEquals('Call client. Reminder in 5 days.', myNewTask.Description);
    }

}

