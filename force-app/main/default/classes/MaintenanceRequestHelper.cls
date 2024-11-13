public with sharing class MaintenanceRequestHelper {
    public MaintenanceRequestHelper() {

    }
    public void handleUpdate(List<Case> maintenanceRequests){
        List<Case> routineCheckups = new List<Case>();
        for(Case c : maintenanceRequests){
           if(c.Status == 'Closed' && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')){
                Case newCase = new Case();
                newCase.Vehicle__c = c.Vehicle__c;
                newCase.ProductId = c.ProductId;
                newCase.Type = 'Routine Maintenance';
                newCase.Subject = 'Future Routine Checkup';
                newCase.Date_Reported__c = Date.today();
                routineCheckups.add(newCase);
           }
        }
        if(routineCheckups.size()>0){
            insert routineCheckups;
        }
    }
}