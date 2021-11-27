trigger OrderTrigger on Order(before update, after update, after delete) {
    /*This class contains triggers context for object "Order" triggers.
    It instantiates the handler, which method is called and takes ordered objects
    as parameter, old and new version of them. */
    OrderTriggerHandler MyOrder = new OrderTriggerHandler();
    if(Trigger.isBefore && Trigger.isUpdate) {
        MyOrder.preventUpdateIfNoProduct(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        MyOrder.uncheckIfNoOrder(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isDelete) {
        MyOrder.uncheckIfNoOrder(Trigger.old);
    }
}