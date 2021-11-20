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
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 0);
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
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 1);
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
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 2);
        List<Order> listOfOrders = [SELECT Id, Status FROM Order];
        List<OrderItem> listOfItems = [SELECT Id FROM OrderItem];
        //WHEN : activating trigger with conditions
        Test.startTest();
        listOfItems.remove(1);
        update listOfItems;
        for(Order ord: listOfOrders) {
            ord.Status = 'Activated';
        }
        update listOfOrders;
        //THEN : assert results
        Test.stopTest();
        for(Order ord : listOfOrders) {
        System.assertEquals('Activated', ord.Status);
        System.assertEquals(1, listOfItems.size());
    }}

    @isTest
    public static void getErrorIfLastItemDeleted() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 1);
        List<Order> listOfOrders = [SELECT Id, Status FROM Order];
        List<OrderItem> listOfItems = [SELECT Id FROM OrderItem];
        //WHEN : activating trigger with conditions
        Test.startTest();
        listOfItems.remove(0);
        update listOfItems;
        for(Order ord: listOfOrders) {
            ord.Status = 'Activated';
        }
        try {
        update listOfOrders;
            //THEN : assert results
        } catch (Exception e) {
            System.assert(e.getMessage().contains('An order must have at least one product.'));
        }
        Test.stopTest();
        for(Order ord : listOfOrders) {
        System.assertEquals('Activated', ord.Status);
        System.assertEquals(0, listOfItems.size());
    }}

    @isTest
    public static void checkIfNoItemsAndNoTrigger() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 1);
        List<Order> listOfOrders = [SELECT Id, Status FROM Order];
        List<OrderItem> listOfItems = [SELECT Id FROM OrderItem];
        //WHEN : activating trigger with conditions
        Test.startTest();
        listOfItems.remove(0);
        update listOfItems;
        for(Order ord: listOfOrders) {
            ord.Description = 'This is a test description.';
        }
        update listOfOrders;
            //THEN : assert results
        Test.stopTest();
        for(Order ord : listOfOrders) {
        System.assertEquals('Draft', ord.Status);
        System.assertEquals(0, listOfItems.size());
    }}

        /* TESTS IN AFTER DELETE */
    @isTest
    public static void checkedBoxWithDraftStatus() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 2, 1);
        Set<Id> orderId = new Set<Id>();
        List<Account> listOfAccounts = [SELECT Id, actif__c FROM Account];
        for(Account a : listOfAccounts) {
            orderId.add(a.Id);
        }
        List<Order> listOfOrders = [SELECT Id, Status FROM Order WHERE AccountId IN: orderId];
        //WHEN : activating trigger with conditions
        Test.startTest();
        listOfOrders.remove(1);
        for(Account acc : listOfAccounts) {
            for(Order ord: acc.Orders) {
                ord.Description = 'This is test description';
            }
        }
        update listOfAccounts;
        update listOfOrders;
            //THEN : assert results
        Test.stopTest();
        System.assertEquals(1, listOfOrders.size());
        for(Account acc : listOfAccounts) {
            System.assertEquals(true, acc.actif__c);
            for(Order ord : acc.Orders) {
                System.assertEquals('Draft', ord.Status);
    }}}

    @isTest
    public static void checkedBoxWithActiveStatus() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 2, 1);

        Set<Id> orderId = new Set<Id>();
        List<Account> listOfAccounts = [SELECT Id, actif__c FROM Account];
        for(Account a : listOfAccounts) {
            orderId.add(a.Id);
        }
        List<Order> listOfOrders = [SELECT Id, Status FROM Order WHERE AccountId IN: orderId];
        //WHEN : activating trigger with conditions
        Test.startTest();
        update listOfOrders;
        update listOfAccounts;
        listOfOrders.remove(0);
        update listOfOrders;
        update listOfAccounts;
        for(Account acc : listOfAccounts) {
            for(Order ord: acc.Orders) {
                ord.Status = 'Activated';
            }
        }
        update listOfAccounts;
        update listOfOrders;
            //THEN : assert results
        Test.stopTest();
        System.assertEquals(1, listOfOrders.size());
        for(Account acc : listOfAccounts) {
            System.assertEquals(true, acc.actif__c);
            for(Order ord : acc.Orders) {
                System.assertEquals('Activated', ord.Status);
    }}}

    @isTest
    public static void UncheckBoxIfLastOrderDeleted() {
        /* the test method from the factory takes as parameters :
        - The Number of Accounts needed
        - The Number of Orders per Accound needed
        - The quantity of Items per order */
        //GIVEN : create data
        DataFactory.createOrders(1, 1, 0);
        Set<Id> orderId = new Set<Id>();
        List<Account> listOfAccounts = [SELECT Id, actif__c FROM Account];
        for(Account a : listOfAccounts) {
            orderId.add(a.Id);
        }
        List<Order> listOfOrders = [SELECT Id, Status FROM Order WHERE AccountId IN: orderId];
        //WHEN : activating trigger with conditions
        Test.startTest();
        listOfOrders.remove(0);
        update listOfOrders;
        update listOfAccounts;
            //THEN : assert results
        Test.stopTest();
        System.assertEquals(0, listOfOrders.size());
        for(Account acc : listOfAccounts) {
            System.assert(acc.actif__c == false);
        }}

        @isTest
        public static void UncheckedBoxIfNoOrder() {
            /* the test method from the factory takes as parameters :
            - The Number of Accounts needed
            - The Number of Orders per Accound needed
            - The quantity of Items per order */
            //GIVEN : create data
            DataFactory.createOrders(1, 0, 0);
            //WHEN
            Test.startTest();
            List<Account> listOfAccounts = [SELECT Id, actif__c FROM Account];
                //THEN : assert results
            Test.stopTest();
            for(Account acc : listOfAccounts) {
                System.assertEquals(false, acc.actif__c);
            }}
}
