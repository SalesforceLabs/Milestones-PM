/*
    The test class for the Task Dependency feature
*/
@isTest
private class Milestone1_Test_Task_Dependency {
    
    static testMethod void testMilestoneWithManyTasksManySubMilestonesDependency() {
        final Integer NUMBER_OF_MILESTONES = 200;
        final Integer NUMBER_OF_TASKS = 200;
        final Integer NUMBER_OF_DAYS_SHIFTED = -10;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms');
        ms2.Alias__c = 'DCMTEST927';
        ms2.Kickoff__c = Date.today();
        ms2.Deadline__c = Date.today().addDays(1);
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a few sub-milestones underneath ms2
        Map<String, Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestonesParent(proj,ms2,NUMBER_OF_MILESTONES);
        
        //create a few successor milestones underneath ms2
        Map<String,Milestone1_Milestone__c> succMilestones = Milestone1_Test_Utility.manyMilestonesPredecessor(proj,ms2,NUMBER_OF_MILESTONES);
        
        //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        milestones.addAll(subMilestones.values());
        milestones.addAll(succMilestones.values());
        
        //create tasks linked to milestones
        Map<String,Milestone1_Task__c> tasks = new Map<String,Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            if(i > 0) taskRec.Predecessor_Task__c = tasks.values()[(Math.random() * tasks.size()).intValue()].Id;
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //call update action
        ms2.Kickoff__c = ms2.Kickoff__c.addDays(NUMBER_OF_DAYS_SHIFTED);
        ms2.Deadline__c = ms2.Deadline__c.addDays(NUMBER_OF_DAYS_SHIFTED);
        Test.startTest();
        update ms2;
        Test.stopTest();
        
        //do assertions
        Map<String,Milestone1_Milestone__c> milestones2 = new Map<String,Milestone1_Milestone__c>([SELECT
                                                        Id,Kickoff__c,Deadline__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Parent_Milestone__c = :ms2.Id
                                                     OR Predecessor_Milestone__c = :ms2.Id
                                                    ]);
        areShiftedMilestones(milestones2, new Map<String, Milestone1_Milestone__c>(milestones), NUMBER_OF_DAYS_SHIFTED);        
        Map<String,Milestone1_Task__c> tasks2 = new Map<String,Milestone1_Task__c>([SELECT 
                                                Name,Start_Date__c,Due_Date__c
                                            FROM Milestone1_Task__c
                                            WHERE Project_Milestone__c = :ms2.Id
                                            OR Project_Milestone__r.Parent_Milestone__c = :ms2.Id
                                            OR Project_Milestone__r.Predecessor_Milestone__c = :ms2.Id
                                           ]);
        
        //RSC 2011-09-20 This was original in a method, refactored here for a clean security scan from http://security.force.com
        
        Milestone1_Task__c task;
        for(Milestone1_Task__c taskOriginal : tasks2.values()){
            task = tasks.get(taskOriginal.Name);
            
            if(taskOriginal.Due_Date__c != null && task.Due_Date__c != null && taskOriginal.Start_Date__c != null && task.Start_Date__c != null) {
                System.assertEquals(task.Due_Date__c.daysBetween(taskOriginal.Due_Date__c) , NUMBER_OF_DAYS_SHIFTED, 'TASK date not shifted');
                System.assertEquals(task.Start_Date__c.daysBetween(taskOriginal.Start_Date__c) , NUMBER_OF_DAYS_SHIFTED, 'TASK date not shifted');
            }
        }
        
        
        
    }
    
    public static void areShiftedMilestones (Map<String,Milestone1_Milestone__c> milestonesOriginal, 
                                                Map<String,Milestone1_Milestone__c> milestones, Integer numberOfDaysShifted){
    
        Milestone1_Milestone__c milestone;
        for(Milestone1_Milestone__c milestoneOriginal : milestonesOriginal.values()){
            milestone = milestones.get(milestoneOriginal.Id);
            if(milestoneOriginal.Kickoff__c != null && milestone.Kickoff__c != null && milestoneOriginal.Deadline__c != null && milestone.Deadline__c != null) {
                System.assertEquals(milestone.Kickoff__c.daysBetween(milestoneOriginal.Kickoff__c) , numberOfDaysShifted, 'MILESTONE date not shifted');
                System.assertEquals(milestone.Deadline__c.daysBetween(milestoneOriginal.Deadline__c) , numberOfDaysShifted, 'MILESTONE date not shifted');
            }
        }
    }
    

}