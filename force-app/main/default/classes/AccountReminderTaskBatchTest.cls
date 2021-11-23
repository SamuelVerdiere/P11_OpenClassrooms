@isTest
public with sharing class AccountReminderTaskBatchTest {
    @isTest
    static void AssumeTaskIsCreated() {
        //create account at some date
        //check if task is created 5 days later
        //GIVEN :
        Date myDate = System.today();
        Date futureDate = myDate.addDays(5);
        Account myAccount = new Account(Name = 'Test Account');
        List<Task> noTasks = [SELECT Id FROM Task WHERE WhatId =: myAccount.Id];
        //WHEN :
        Test.startTest();
        AccountReminderTaskBatch mybatch = new AccountReminderTaskBatch();
        Id batchId = Database.executeBatch(mybatch);
        Test.stopTest();
        Account newAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
        List<Task> newTasks = [SELECT WhatId FROM Task WHERE WhatId =: newAccount.Id];
        Task myNewTask = [SELECT WhatId FROM Task LIMIT 1];
        //THEN :
        System.assertEquals(1, newTasks.size());
        System.assertEquals('Call', myNewTask.Subject);
        System.assertEquals('Call client. Reminder in 5 days.', myNewTask.Description);
    }
}

