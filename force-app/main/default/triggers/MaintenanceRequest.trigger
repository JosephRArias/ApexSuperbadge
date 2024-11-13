trigger MaintenanceRequest on Case (after update) {
    MaintenanceRequestHelper handler = new MaintenanceRequestHelper();

if(Trigger.isAfter && Trigger.isUpdate){
    handler.handleUpdate(Trigger.new);
}

}