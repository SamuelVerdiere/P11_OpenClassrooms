trigger OrderTrigger on Order(before update, after update, after delete) {
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