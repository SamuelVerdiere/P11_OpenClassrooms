@isTest
public with sharing class OrderTriggerHandlerTest {
    /* This test class will perform many methods relative to the Order Triggers.
    It will test standard scenario, extreme scenarii, conditions inside the triggers logic. */

    /* TESTS IN BEFORE UPDATE : method preventUpdateIfNoProduct */
    @isTest
    public static void updateWithoutOrderItem() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 0, 0);
         List<Order> listOfOrders = [SELECT Id, Status FROM Order];
         //WHEN : activating trigger with conditions
         Test.startTest();
         for(Order ord: listOfOrders) {
             ord.Status = 'Activated';
         }
         try {
         update listOfOrders;
         } catch(Exception e) {
         //THEN : assert results
         System.assert(e.getMessage().contains('An order must have at least one product.'));
         }
         Test.stopTest();
     }

    @isTest
    public static void checkStatusAndOrderItems() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 1, 0);
         List<Order> listOfOrders = [SELECT Id, Status FROM Order];
         //WHEN : activating trigger with conditions
         Test.startTest();
         for(Order ord: listOfOrders) {
             ord.Status = 'Activated';
         }
         update listOfOrders;
         //THEN : assert results
         List<OrderItem> listOfOrderItems = [SELECT Id FROM OrderItem];
         Test.stopTest();
         for(Order ord : listOfOrders) {
         System.assertEquals('Activated', ord.Status);
         System.assertEquals(listOfOrderItems.size(), 1);
     }}

    @isTest
    public static void checkStatusAfterItemDeletion() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 2, 0);
         List<Order> listOfOrders = [SELECT Id, Status FROM Order];
         List<OrderItem> listOfItems = [SELECT Id FROM OrderItem];
         OrderItem myOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
         //WHEN : activating trigger with conditions
         Test.startTest();
         delete myOrderItem;
         for(Order ord: listOfOrders) {
             ord.Status = 'Activated';
         }
         update listOfOrders;
         //THEN : assert results
         Test.stopTest();
         List<OrderItem> newList = [SELECT Id FROM OrderItem];
         for(Order ord : listOfOrders) {
         System.assertEquals('Activated', ord.Status);
         System.assertEquals(1, newList.size());
     }}

    @isTest
    public static void getErrorIfLastItemDeleted() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 1, 0);
         List<Order> listOfOrders = [SELECT Id, Status FROM Order];
         OrderItem myOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
         //WHEN : activating trigger with conditions
         Test.startTest();
         delete myOrderItem;
         try {
         update listOfOrders;
        //THEN : assert results
         } catch (Exception e) {
             System.assert(e.getMessage().contains('An order must have at least one product.'));
         }
         Test.stopTest();
         List<OrderItem> newOrderItems = [SELECT Id FROM OrderItem];
         for(Order ord : listOfOrders) {
         System.assertEquals('Draft', ord.Status);
         System.assertEquals(0, newOrderItems.size());
    }}

    /* TESTS IN AFTER DELETE : method uncheckIfNoOrder */
     @isTest
     public static void UncheckBoxIfLastOrderDeleted() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 0, 0);
         Set<Id> orderId = new Set<Id>();
         Account myAccount = [SELECT Id, actif__c FROM Account WHERE actif__c = true LIMIT 1];
         List<Order> listOfOrders = [SELECT Id, Status FROM Order WHERE AccountId =: myAccount.Id];
         //WHEN : activating trigger with conditions
         Test.startTest();
         delete listOfOrders;
         Test.stopTest();
        //THEN : assert results
         List<Order> newOrders = [SELECT Id, Status FROM Order WHERE AccountId =: myAccount.Id];
         Account newAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
         System.assertEquals(0, newOrders.size());
         System.assertEquals(false, newAccount.actif__c);
    }

     @isTest
     public static void CheckedBoxAtCreation() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 0, 0, 0);
         //WHEN
         Test.startTest();
         Account myAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
         Test.stopTest();
        //THEN : assert results
        System.assertEquals(true, myAccount.actif__c);
     }

    @isTest
     public static void UncheckBoxIfAlreadyChecked() {
         /* the test method from the factory takes as parameters :
         - The Number of Accounts needed
         - The Number of Orders per Accound needed
         - The quantity of Items per order 
         - The number of tasks for account */
         //GIVEN : create data
         DataFactory.createOrders(1, 1, 1, 0);
         Set<Id> orderId = new Set<Id>();
         Account myAccount = [SELECT Id, actif__c FROM Account WHERE actif__c = true LIMIT 1];
         List<Order> listOfOrders = [SELECT Id FROM Order WHERE AccountId =: myAccount.Id];
         //WHEN : activating trigger with conditions
         Test.startTest();
         delete listOfOrders;
         Test.stopTest();
        //THEN : assert results
         Account newAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
         List<Order> newOrders = [SELECT Id FROM Order WHERE AccountId =: newAccount.Id];
         System.assertEquals(0, newOrders.size());
         System.assertEquals(true, myAccount.actif__C);
         System.assertEquals(false, newAccount.actif__c);
         System.assertNotEquals(newAccount.actif__c, myAccount.actif__c);
         }


    @isTest
    public static void checkWithManyOrders() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order 
         - The number of tasks for account */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 1, 0);
        Account myAccount = [SELECT Id, actif__c FROM Account WHERE actif__c = true LIMIT 1];
        List<Order> orderToDelete = [SELECT Id FROM Order WHERE AccountId =: myAccount.Id];
        Date myDate = System.today();
        //WHEN : invoke trigger
        Test.startTest();
        delete orderToDelete;
        //now that the order is deleted, the checkbox should be false:
        Account uncheckedAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
        //then create 2 orders:
        Contract myContract = new Contract(Name='Test Contract', StartDate=myDate, Status='Draft', AccountId = myAccount.Id);
        List<Order> newOrders = new List<Order>();
        for(Integer i=0; i<2; i++) {
        Order myNewOrder = new Order(Name='Test Order'+i, AccountId = myAccount.Id, ContractId= myContract.Id, EffectiveDate=myDate, Status='Draft'); 
            newOrders.add(myNewOrder);
        }
        insert newOrders; 
        //get the trigger to run
        Order orderToUpdate = [SELECT Id, Description FROM Order LIMIT 1];
        orderToUpdate.Description = 'This is test description';
        update orderToUpdate;
        //so the checkbox should be true
        Account checkedAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
        //and the orders should be 2
        List<Order> listOfNewOrders = [SELECT Id FROM Order WHERE AccountId =: checkedAccount.Id];
        Order checkingOrder = [SELECT Id FROM Order WHERE AccountId =: checkedAccount.Id LIMIT 1];
        //then delete 1 order
        delete checkingOrder;
        //checkbox should still be true
        Account stillCheckedAccount = [SELECT Id, actif__c FROM Account LIMIT 1];
        Test.stopTest();
        //THEN : assert results
        System.assertEquals(true, myAccount.actif__c);
        System.assertEquals(false, uncheckedAccount.actif__c);
        System.assertNotEquals(myAccount.actif__c, uncheckedAccount.actif__c);
        System.assertEquals(true, checkedAccount.actif__c);
        System.assertEquals(2, listOfNewOrders.size());
        System.assertEquals(true, stillCheckedAccount.actif__c);
        System.assertEquals(myAccount.actif__c, stillCheckedAccount.actif__c);
    }
}
