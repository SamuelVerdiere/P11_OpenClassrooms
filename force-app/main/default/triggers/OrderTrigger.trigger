trigger OrderTrigger on Order(before update, after delete) {
    OrderTriggerHandler MyOrder = new OrderTriggerHandler();
    if(Trigger.isUpdate) {
        MyOrder.preventUpdateIfNoProduct(Trigger.old);
    }
    if(Trigger.isDelete) {
        MyOrder.uncheckIfNoOrder(Trigger.new);
    }
}