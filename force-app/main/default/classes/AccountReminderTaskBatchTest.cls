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
        //myDate.addDays(5);
        Account myAccount = new Account(Name= 'Test Account');
        insert myAccount;
        Account otherAccount = new Account(Name ='Account Test');
        insert otherAccount;
        Task myTask = new Task(Description = 'Call now', Status = 'New',
        Subject='Call', ReminderDateTime=myDate, WhatId=otherAccount.Id,
        Priority='Normal', CallType='Outbound');
        insert myTask;
        update otherAccount;
        List<Task> noTasks = [SELECT Id FROM Task WHERE WhatId =: myAccount.Id];
        List<Task> sizeOneTasks= [SELECT Id FROM Task WHERE WhatId =: otherAccount.Id];
        //Task oneTask = [SELECT WhatId, Description FROM Task WHERE WhatId =: otherAccount.Id LIMIT 1];
        Task readyTask = [SELECT Id, Description FROM Task WHERE WhatId =: otherAccount.Id];
        //WHEN
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
        List<Task> tasksCreated = [SELECT WhatId, Description FROM Task WHERE WhatId =:myAccount.Id];
        Task createdTask = [SELECT WhatId, Description FROM Task WHERE WhatId =:myAccount.Id LIMIT 1];
        //THEN
        System.assertEquals(1, sizeOneTasks.size());
        System.assertEquals(0, noTasks.size());
        System.assertNotEquals(sizeOneTasks.size(), noTasks.size());
        System.assertEquals('Call now', readyTask.Description);
        System.assertEquals('Call client. Reminder in 5 days.', createdTask.Description);
        System.assertNotEquals(readyTask.Description, createdTask.Description);
        System.assertEquals(sizeOneTasks.size(),tasksCreated.size());

    }

}

