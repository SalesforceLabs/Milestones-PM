/** * File Name: Milestone1_TaskTableController_Test.apxc
* Description : Test Class for Milestone1_TaskTableController.apxc
* Copyright : salesforce.com, Inc. (c) 2016
* * @author : Shae Selix
* Modification Log =============================================================== 
Ver Date Author Modification --- ---- ------ -------------
* */ 

@isTest
private class Milestone1_TaskTableController_Test {
    
    @isTest static void testTaskListMethods() {
        
        Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        insert p;
        
        Milestone1_Milestone__c m = Milestone1_Test_Utility.sampleMilestone(p);
        m.Deadline__c = Date.today()-1;
        insert m;
        
        List<Milestone1_Task__c> testTasks = new List<Milestone1_Task__c>();
        
        // Incomplete task, not blocked, not late
        Milestone1_Task__c t0 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, false);
        testTasks.add(t0);
        
        // Incomplete task, late, not blocked
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(-1), false, false);
        testTasks.add(t1);
        
        // Incomplete task, not late, blocked
        Milestone1_Task__c t2 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), false, true);
        testTasks.add(t2);
        
        // Complete task
        Milestone1_Task__c t3 = Milestone1_Test_Utility.sampleTask(
            m.Id, Date.today().addDays(-2), Date.today().addDays(1), true, false);
        testTasks.add(t3);
        
        insert testTasks;
        
        List<Milestone1_Task__c> incTasks = Milestone1_TaskTableController.getIncompletedTasks();
        System.debug('# Incomplete Tasks: ' + incTasks.size());
        System.assertEquals(3, incTasks.size());
        
        List<Milestone1_Task__c> lateTasks = Milestone1_TaskTableController.getLateTasks();
        System.debug('# Late Tasks: ' + lateTasks.size());
        System.assertEquals(1, lateTasks.size());
        
        List<Milestone1_Task__c> blockedTasks = Milestone1_TaskTableController.getBlockedTasks();
        System.debug('# Blocked Tasks: ' + blockedTasks.size());
        System.assertEquals(1, blockedTasks.size());
        
        
        
    }

}