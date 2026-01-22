/** * File Name: Milestone1_TaskTableController.apxc
* Description : Controller for c:mytasks Lightning Component
* Copyright : salesforce.com, Inc. (c) 2016
* * @author : Shae Selix
* Modification Log =============================================================== 
Ver Date Author Modification --- ---- ------ -------------
* */ 

public with sharing class Milestone1_TaskTableController {
    
    @AuraEnabled
    public static List<Milestone1_Task__c> getIncompletedTasks() {
        Map<DescribeSObjectResult, Set<String>> fieldsToCheck = 
            new Map<DescribeSObjectResult, Set<String>>();
        fieldsToCheck.put(Milestone1_Task__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name', 'due_date__c', 'assigned_to__c', 'complete__c'});
        fieldsToCheck.put(Milestone1_Milestone__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name'});
        fieldsToCheck.put(Milestone1_Project__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name', 'status__c'});
        
        Boolean userCanAccess = true;
        for (DescribeSObjectResult dfr : fieldsToCheck.keyset()) {
            if (!Milestone1_Security_Utility.fieldsAllAccess(dfr, fieldsToCheck.get(dfr))) {
                userCanAccess = false;
            }
        }
        
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        
        if (userCanAccess) {
            Id uid = UserInfo.getUserId();
        	tasks = [SELECT Id, Name, Due_Date__c,
                	   Project_Milestone__c, Project_Milestone__r.Name, 
                	   Project_Milestone__r.Project__c,
                       Project_Milestone__r.Project__r.Name
                FROM Milestone1_Task__c
                WHERE Assigned_To__c = :uid
                AND Complete__c = false
                AND Project_Milestone__r.Project__r.Status__c = 'Active'
                ORDER BY Project_Milestone__r.Project__r.Name,
                         Project_Milestone__r.Name,
                         Due_Date__c
                LIMIT 50];
        }
        
        return tasks;
        
        
    }
    
    @AuraEnabled
    public static List<Milestone1_Task__c> getLateTasks() {
        
        Map<DescribeSObjectResult, Set<String>> fieldsToCheck = 
            new Map<DescribeSObjectResult, Set<String>>();
        fieldsToCheck.put(Milestone1_Task__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name', 'due_date__c', 'assigned_to__c', 'complete__c'});
        fieldsToCheck.put(Milestone1_Milestone__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name'});
        fieldsToCheck.put(Milestone1_Project__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name'});
        
        Boolean userCanAccess = true;
        for (DescribeSObjectResult dfr : fieldsToCheck.keyset()) {
            if (!Milestone1_Security_Utility.fieldsAllAccess(dfr, fieldsToCheck.get(dfr))) {
                userCanAccess = false;
            }
        }
        
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        
        if (userCanAccess) {
            Id uid = UserInfo.getUserId();
        	Date td = Date.today();
        	tasks = [SELECT Id, Name, Due_Date__c,
                	   Project_Milestone__c, Project_Milestone__r.Name, 
                	   Project_Milestone__r.Project__c,
                       Project_Milestone__r.Project__r.Name
                FROM Milestone1_Task__c
                WHERE Assigned_To__c = :uid
                AND Complete__c = false
                AND Due_Date__c < :td
                ORDER BY Due_Date__c
                LIMIT 50];
        }
        
        return tasks;
    }
    
    @AuraEnabled
    public static List<Milestone1_Task__c> getBlockedTasks() {
        
        Map<DescribeSObjectResult, Set<String>> fieldsToCheck = 
            new Map<DescribeSObjectResult, Set<String>>();
        fieldsToCheck.put(Milestone1_Task__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name', 'due_date__c', 'assigned_to__c', 'blocked__c'});
        fieldsToCheck.put(Milestone1_Milestone__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name'});
        fieldsToCheck.put(Milestone1_Project__c.sObjectType.getDescribe(),
                          new Set<String>{'id', 'name'});
        
        Boolean userCanAccess = true;
        for (DescribeSObjectResult dfr : fieldsToCheck.keyset()) {
            if (!Milestone1_Security_Utility.fieldsAllAccess(dfr, fieldsToCheck.get(dfr))) {
                userCanAccess = false;
            }
        }
        
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        
        if (userCanAccess) {
            Id uid = UserInfo.getUserId();
        	tasks = [SELECT Id, Name, Due_Date__c,
                	   Project_Milestone__c, Project_Milestone__r.Name, 
                	   Project_Milestone__r.Project__c,
                       Project_Milestone__r.Project__r.Name
                FROM Milestone1_Task__c
                WHERE Assigned_To__c = :uid
                AND Blocked__c = true
                ORDER BY Project_Milestone__r.Project__r.Name,
                         Project_Milestone__r.Name,
                         Due_Date__c
                LIMIT 50];
        }
        
        return tasks;
    }

}