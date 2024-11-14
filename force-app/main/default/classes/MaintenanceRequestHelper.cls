public with sharing class MaintenanceRequestHelper {
    public MaintenanceRequestHelper() {

    }
    public void handleUpdate(List<Case> maintenanceRequests){
        List<Case> routineCheckups = new List<Case>();
        Id maintenanceRequestId;
        for(Case c : maintenanceRequests){
           if(c.Status == 'Closed' && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')){
                maintenanceRequestId = c.Id;
                Case newCase = new Case();
                newCase.Vehicle__c = c.Vehicle__c;
                newCase.ProductId = c.ProductId;
                newCase.Type = 'Routine Maintenance';
                newCase.Subject = 'Future Routine Checkup';
                newCase.Date_Reported__c = Date.today();
                newCase.Date_Due__c = calculateDateDue(maintenanceRequestId);
                routineCheckups.add(newCase);
           }
        }
        if(routineCheckups.size()>0){
            List<Equipment_Maintenance_Item__c> equipmentsToTransfer = [SELECT Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :maintenanceRequestId];
            List<Equipment_Maintenance_Item__c> equipmentsToAdd = new List<Equipment_Maintenance_Item__c>();
            for(Equipment_Maintenance_Item__c eq : equipmentsToTransfer){
                
            }
            insert routineCheckups;
        }
    }
    public Date calculateDateDue(Id maintenanceRequestId){
        List<AggregateResult> results = new List<AggregateResult>();
        Date dueDate;
        results = [SELECT Equipment__c, MIN(Equipment__r.Maintenance_Cycle__c) minCycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :maintenanceRequestId GROUP BY Equipment__c];
        for(AggregateResult ar : results){
            Decimal minCycle = (Decimal) ar.get('minCycle');
            Integer minCycleInt = minCycle.intValue();
            Date todayDate = Date.today();
            dueDate = todayDate.addDays(minCycleInt);
        }
        return dueDate;
    }
}