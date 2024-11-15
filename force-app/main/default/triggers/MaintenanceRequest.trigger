trigger MaintenanceRequest on Case (after update) {

if(Trigger.isAfter && Trigger.isUpdate){
    MaintenanceRequestHelper.handleUpdate(Trigger.new);
}

}