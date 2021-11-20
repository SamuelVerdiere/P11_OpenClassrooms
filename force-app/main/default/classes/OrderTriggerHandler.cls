public class OrderTriggerHandler {
    public void preventUpdateIfNoProduct(Map<id,Order> oldOrderMap, Map<id,Order> newOrderMap) {
        //on obtient liste des orders & OrderItems
        //pour chaque order dans la liste,
        //si la liste des OrderItems ==0
        //empêche la mise à jour
        //affiche un message d'erreur
        //1. Get + Compare Status or orders between Old & New
        //2. If in new orders with modified status = no order items = error
        //create id set
        Set<Id> newOrderIds = new Set<Id>();

        for (Order newOrd : newOrderMap.values()) {
            //access "old" record by its id in trigger.oldmap
            Order oldOrd = oldOrderMap.get(newOrd.Id);
            //if old status differs from new status and if new status is "activated", then
            if(oldOrd.Status != newOrd.Status && newOrd.Status == 'Activated') {
                //add new order id to set
                newOrderIds.add(newOrd.id);
            }
        }
        //create list of orders + orderitems with Id from the set
        List<Order> listOrderWithItems = [SELECT Id, (SELECT Id FROM OrderItems) 
                                         FROM Order WHERE Id in : newOrderIds];
        //if list with new orders has at least 1 element
        if(newOrderIds.size() > 0 && newOrderIds != null) {
            //then for each element of the order list,
            for(Order newOrder : listOrderWithItems) {
                //if order has no order items, then display custom error message
                if(newOrder.OrderItems.size() == 0 || newOrder.OrderItems ==null) {
                    newOrderMap.get(newOrder.Id).addError('An order must have at least one product.');
                }
            }
        }
    }
    public void uncheckIfNoOrder(List<Order> triggeredOrders) {
        //create lists of accounts and orders
        List<Account> accountForUpdate = new List<Account>();
        List<Order> ordersWithinAccount = new List<Order>();
        //create set of id that will contain AccountId for each order
        Set<Id> parentAccountsId = new Set<Id>();
        for(Order o : triggeredOrders) {
            if(o.AccountId != null) {
                parentAccountsId.add(o.AccountId);
            }}
        //query necessary fields from accoutns & orders
        List<Account> accountWithOrders = [SELECT Id, actif__c, (SELECT Id, AccountId FROM Orders) 
        FROM Account WHERE Id IN : parentAccountsId];
        //if there is at least 1 AccountId in the Id Set:
        if(parentAccountsId.size() > 0) {
            //Then for each account,
        for(Account a : accountWithOrders) {
            //if there is no orders, then set checkbox to false if it wasn't. Add this on list
            if(a.orders == null || a.orders.size() == 0) {
                if(a.actif__c == true) {
                    a.actif__c = false;
                    accountForUpdate.add(a);
                }
            //else if there are orders, set checkbox to true, add this on list.
            } else {
                if(a.actif__c == false) {
                    a.actif__c = true;
                    accountForUpdate.Add(a);
                }
            }}}
            //finally, update list outside loop
            if(accountForUpdate.size() > 0) {
                update accountForUpdate;
            }
      }
}