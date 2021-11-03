@isTest
public with sharing class test_PlaygroupToDoListController {
    @isTest
    static void getPlaygroupAnimalsSuccess() {
        Animal__c a = TestDataFactory.createAnimal();
        a.Play_Category__c = 'Small Mellow';
        update a;
        Test.startTest();
        List<Animal__c> playgroupAnimals = PlaygroupToDoListController.getPlaygroupAnimals('MRC');
        Test.stopTest();

        List<Animal__c> animals = [SELECT Id, Shelter_Location2__c, Play_Category__c, Behavior_Play_Pause__c, Behavior_Play_Pause_Date__c FROM Animal__c WHERE Id = :a.Id];
        System.assertEquals(1, playgroupAnimals.size());
        System.assertEquals(a.Id, playgroupAnimals[0].Id);
    }

    @isTest
    static void getPlaygroupAnimalsBadCategory() {
        Animal__c a = TestDataFactory.createAnimal();
        Test.startTest();
        List<Animal__c> playgroupAnimals = PlaygroupToDoListController.getPlaygroupAnimals('MRC');
        Test.stopTest();
        System.assertEquals(0, playgroupAnimals.size());
    }

    @isTest
    static void getPlaygroupAnimalsBehaviorPause() {
        Animal__c a = TestDataFactory.createAnimal();
        a.Play_Category__c = 'Small Mellow';
        a.Behavior_Play_Pause__c = 'Aggression';
        update a;
        Test.startTest();
        List<Animal__c> playgroupAnimals = PlaygroupToDoListController.getPlaygroupAnimals('MRC');
        Test.stopTest();
        System.assertEquals(0, playgroupAnimals.size());
    }

    @isTest
    static void getPlaygroupAnimalsBadLocation() {
        Animal__c a = TestDataFactory.createAnimal();
        Test.startTest();
        List<Animal__c> playgroupAnimals = PlaygroupToDoListController.getPlaygroupAnimals('Not MRC');
        Test.stopTest();
        System.assertEquals(0, playgroupAnimals.size());
    }

    @isTest
    static void createPlaygroupSuccess() {
        Animal__c a = TestDataFactory.createAnimal();
        Test.startTest();
        String sessionId = PlaygroupToDoListController.createPlaygroup(new List<String>{a.Id});
        Test.stopTest();
        List<Animal_Playgroup__c> animalPlaygroups = [SELECT Id, Animal__c, Playgroup_Session__c FROM Animal_Playgroup__c WHERE Animal__c = :a.Id];
        System.assertEquals(1, animalPlaygroups.size());
        System.assertEquals(a.Id, animalPlaygroups[0].Animal__c);
        System.assertEquals(sessionId, animalPlaygroups[0].Playgroup_Session__c);
    }

    @isTest
    static void createPlaygroupBadAnimals() {
        Animal__c a = TestDataFactory.createAnimal();
        List<String> animals = new List<String>{a.Id};
        delete a;
        Test.startTest();
        String sessionId = PlaygroupToDoListController.createPlaygroup(animals);
        Test.stopTest();
        System.assertEquals('Error creating animal playgroups', sessionId);
    }

    @isTest
    static void getMedicalIndicatorsSuccess() {
        List<Medical_Conditions__c> medConditions = TestDataFactory.createMedicalConditions();
        Test.startTest();
        List<String> conditions = PlaygroupToDoListController.getMedicalIndicators(medConditions[0].Animal__c);
        Test.stopTest();
        System.assertEquals(2, conditions.size());
        System.assert(conditions.contains('Babesia'));
        System.assert(conditions.contains('In Heat'));
    }

    @isTest
    static void getMedicalIndicatorsNoData() {
        Animal__c a = TestDataFactory.createAnimal();
        Test.startTest();
        List<String> conditions = PlaygroupToDoListController.getMedicalIndicators(a.Id);
        Test.stopTest();
        System.assertEquals(0, conditions.size());
    }

    @isTest
    static void copyPlaygroupSessionSuccess() {
        Playgroup_Session__c playSession = TestDataFactory.createPlaygroupSessionWithAnimals();
        Animal__c a = [SELECT Id FROM Animal__c LIMIT 1];
        Test.startTest();
        Id sessionId = PlaygroupToDoListController.copyPlaygroupSession(playSession.Id, new List<Id>{a.Id});
        Test.stopTest();
        Playgroup_Session__c copiedSession = [SELECT Id, Playgroup_Location__c, Playgroup_Leader__c, (SELECT Id FROM Animal_Playgroups__r) FROM Playgroup_Session__c WHERE Id = :sessionId LIMIT 1];
        System.assertEquals(playSession.Playgroup_Location__c, copiedSession.Playgroup_Location__c);
        System.assertEquals(playSession.Playgroup_Leader__c, copiedSession.Playgroup_Leader__c);
        System.assertEquals(1, copiedSession.Animal_Playgroups__r.size());
    }

    @isTest
    static void copyPlaygroupSessionError() {
        Playgroup_Session__c playSession = TestDataFactory.createPlaygroupSessionWithAnimals();
        Animal__c a = [SELECT Id FROM Animal__c LIMIT 1];
        List<Id> animalIds = new List<Id>{a.Id};
        delete a;
        Test.startTest();
        String errorMsg;
        try {
            Id sessionId = PlaygroupToDoListController.copyPlaygroupSession(playSession.Id, animalIds);
        }
        catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();
        System.assert(!String.isEmpty(errorMsg));
    }
}