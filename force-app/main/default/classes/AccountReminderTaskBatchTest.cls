@isTest
public with sharing class AccountReminderTaskBatchTest {
    @isTest
    static void AssumeTaskIsCreated() {
        //GIVEN :
        Account myAccount = new Account(Name = 'Test Account');
        insert myAccount;
        List<Task> noTasks = [SELECT Id FROM Task WHERE WhatId =: myAccount.Id];
        //WHEN :
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
        Account newAccount = [SELECT Id FROM Account];
        List<Task> newTasks = [SELECT WhatId, Subject, Description FROM Task];
        Task myNewTask = [SELECT WhatId, Subject, Description FROM Task LIMIT 1];
        //THEN :
        System.assertEquals(1, newTasks.size());
        System.assertEquals('Call', myNewTask.Subject);
        System.assertEquals('Call client. Reminder in 5 days.', myNewTask.Description);
        System.assertEquals(0, noTasks.size());
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
}

