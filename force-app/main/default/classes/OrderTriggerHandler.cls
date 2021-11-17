public class OrderTriggerHandler {
    public void preventUpdateIfNoProduct(List<Order> oldOrders) {
        //on obtient liste des orders & OrderItems
        //pour chaque order dans la liste,
        //si la liste des OrderItems ==0
        //empêche la mise à jour
        //affiche un message d'erreur
        for (Order o: oldOrders) {
            if(OrderItems.size() == 0) {
                o.addError('An order must have at least one product.');
            }}
    }
    public void uncheckIfNoOrder(List<Order> newOrders) {
        //on crée un set d'id
        Set<Id> parentAccountsId;
        for(Order o : newOrders) {
            if(o.AccountId != null) {
                parentAccountsId.add(o.AccountId);
            }}
        //dans le compte parent des orders
        List<Account> accountListWhereOrders = [SELECT Id, (
            SELECT Id, active__c FROM Orders) FROM Account 
            WHERE Id IN : parentAccountsId];
        //si la liste des orders est == 0
        for(Account a: accountListWhereOrders) {
            if(a.Order.size() == 0) {
                //décocher la case du champ "actif__c"
                Order.active__c == false;
            }}
        update accountListWhereOrders;
    }
}