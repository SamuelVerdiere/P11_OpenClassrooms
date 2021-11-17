global class AccountReminderTaskBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Integer processedRecords = 0;

    global Database.QueryLocator start(Database.BatchableContext info) {
        //on va faire la requête des comptes n'aant pas d'order
    }

    global void execute (Database.BatchableContext info, List<Account> scope) {
        //si aucun order n'est rattaché à un compte,
        //on programme le call du batch le 1er lundi de chaque mois + rappel après 5 jours
        //si aucune activité de type "appel" existe déjà, on crée une activité : appel qu'on ajoute au compte
        //l'appel a des champs à remplir
    }
    global void finish(Database.BatchableContext info) {
        //contrôle de l'exécution du batch
    }

}