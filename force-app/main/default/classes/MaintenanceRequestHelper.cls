public with sharing class MaintenanceRequestHelper {
    public MaintenanceRequestHelper() {

    }
    @AuraEnabled(cacheable=false)
    public static void handleUpdate(List<Case> maintenanceRequests){
        List<Case> routineCheckups = new List<Case>();
        Set<Id> maintenanceRequestIds  = new Set<Id>();
        Map<Id,Id> oldAndNewMaintenanceRequest = new Map<Id,Id>();
        for(Case c : maintenanceRequests){
           if(c.Status == 'Closed' && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')){
                maintenanceRequestIds.add(c.Id);
           }
        }
        Map<Id, Date> caseToDueDateMap = new Map<Id, Date>();
        List<AggregateResult> results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) minCycle
                                         FROM Equipment_Maintenance_Item__c 
                                         WHERE Maintenance_Request__c IN :maintenanceRequestIds 
                                         GROUP BY Maintenance_Request__c];
    
        for (AggregateResult ar : results) {
            Id maintenanceRequestId = (Id) ar.get('Maintenance_Request__c');
            Decimal minCycle = (Decimal) ar.get('minCycle');
            Date dueDate = Date.today().addDays(minCycle.intValue());
            caseToDueDateMap.put(maintenanceRequestId, dueDate);
        }
        for(Case c : maintenanceRequests){
            if(maintenanceRequestIds.contains(c.Id)){
                Case newCase = new Case();
                newCase.Vehicle__c = c.Vehicle__c;
                newCase.ProductId = c.ProductId;
                newCase.Type = 'Routine Maintenance';
                newCase.Subject = 'Future Routine Checkup';
                newCase.Date_Reported__c = Date.today();
                newCase.Date_Due__c = caseToDueDateMap.get(c.Id);
                routineCheckups.add(newCase);
            }
        }

        if(routineCheckups.size()>0){
            insert routineCheckups;
            for (Integer i = 0; i < maintenanceRequests.size(); i++) {
                oldAndNewMaintenanceRequest.put(maintenanceRequests[i].Id, routineCheckups[i].Id);
            }
            cloneEMIs(oldAndNewMaintenanceRequest);
        }
    }
    public static void cloneEMIs(Map<Id,Id> oldAndNewRequest){

        List<Equipment_Maintenance_Item__c> clonedEquipment = new List<Equipment_Maintenance_Item__c>();
        List<Equipment_Maintenance_Item__c> equipment = [SELECT Equipment__c, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :oldAndNewRequest.keySet()];
        for(Equipment_Maintenance_Item__c emi : equipment){
            Equipment_Maintenance_Item__c emiClone = emi.clone();
            emiClone.Maintenance_Request__c = oldAndNewRequest.get(emi.Maintenance_Request__c);
            clonedEquipment.add(emiClone);
        }
        insert clonedEquipment;

    }
}