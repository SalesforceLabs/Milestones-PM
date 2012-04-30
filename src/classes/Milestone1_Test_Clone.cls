/* 
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
@isTest
private class Milestone1_Test_Clone { 
                  
    static testMethod void testProjectManyMilestonesManyTasksClone() {
        final Integer NUMBER_OF_MILESTONES = 200;
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project 
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('proj');
        insert proj;
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a many sub-milestones underneath ms2
        Map<String,Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestones(null, ms2,NUMBER_OF_MILESTONES);
        
        //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        milestones.addAll(subMilestones.values());
        Map<Id, Milestone1_Milestone__c> milestonesById = new Map<Id, Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c ms : milestones){
            milestonesById.put(ms.Id, ms);
        }
        
        //create tasks linked to milestones
        Map<String,Milestone1_Task__c> tasks = new Map<String,Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);
        cont.createClone();
        
        Milestone1_Project__c proj2 = [SELECT Id,
                                              Name,
                                              Deadline__c,
                                              Description__c,
                                              Status__c
                                       FROM Milestone1_Project__c
                                       WHERE ImportID__c = :proj.Id
                                      ];                                      
        
        System.assertEquals('Copy of ' + proj.Name, proj2.Name, 'Name failed');
        System.assertEquals(proj.Deadline__c, proj2.Deadline__c, 'Deadline failed');
        System.assertEquals(proj.Description__c, proj2.Description__c, 'Description failed');
        System.assert(proj2.Status__c != null);
        System.assertEquals(proj.Status__c, proj2.Status__c, 'Status failed');
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT 
                                                        Id,ImportID__c,Name,Project__c,Complete__c,Kickoff__c,Deadline__c,
                                                        Description__c,Expense_Budget__c,Hours_Budget__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Project__c = :proj2.Id
                                                    ];
        System.assertEquals(NUMBER_OF_MILESTONES + 2, milestones2.size(), 'Query size comparison failed');
        
        Map<String,Milestone1_Task__c> tasks2 = new Map<String,Milestone1_Task__c>([SELECT 
                                            Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
                                            Estimated_Expense__c,Estimated_Hours__c,Priority__c,
                                            Task_Stage__c,Class__c,Assigned_To__c,
                                            Last_Email_Received__c
                                            FROM Milestone1_Task__c
                                            WHERE Project_Milestone__r.Project__c = :proj2.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
    }
 
    static testMethod void testProjectManyTasksClone() {
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms2);
        insert topMilestones;
        
       //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        Map<Id, Milestone1_Milestone__c> milestonesById = new Map<Id, Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c ms : milestones){
            milestonesById.put(ms.Id, ms);
        }
        
        //create tasks linked to milestones
        Map<String,Milestone1_Task__c> tasks = new Map<String,Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);
        cont.createClone();
        
        Map<String,Milestone1_Task__c> tasks2 = new Map<String,Milestone1_Task__c>([SELECT 
                                                Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
                                                Estimated_Expense__c,Estimated_Hours__c,Priority__c,
                                                Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
                                                Last_Email_Received__c,Assigned_To__c
                                            FROM Milestone1_Task__c
                                            WHERE Project_Milestone__r.Project__c = :proj.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
    }
    
     static testMethod void testMilestoneWithManyTasksManySubMilestonesClone() {
        final Integer NUMBER_OF_MILESTONES = 200;
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms');
        ms2.Alias__c = 'DCMTEST927';
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a few sub-milestones underneath ms2
        Map<String,Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestones(proj,ms2,NUMBER_OF_MILESTONES);
        
        //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        milestones.addAll(subMilestones.values());
        
        //create tasks linked to milestones
        Map<String,Milestone1_Task__c> tasks = new Map<String,Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);
        cont.createClone();
        
        Milestone1_Milestone__c ms2Clone = [SELECT Id,
                                                   Name,
                                                   Alias__c
                                            FROM Milestone1_Milestone__c
                                            WHERE ImportID__c = :ms2.Id
                                           ];
        System.assertNotEquals(null, ms2Clone);
        System.assertEquals(null, ms2Clone.Alias__c);
        
        Map<String,Milestone1_Milestone__c> milestones2 = new Map<String,Milestone1_Milestone__c>([SELECT
                                Id,ImportID__c,Name,Project__c,Complete__c,Kickoff__c,Deadline__c,
                                Description__c,Expense_Budget__c,Hours_Budget__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Parent_Milestone__c = :ms2Clone.Id
                                                    ]);
                                                            
        System.assertEquals(NUMBER_OF_MILESTONES, milestones2.size());

        areEqualsMilestones(milestones2,subMilestones);        
        Map<String,Milestone1_Task__c> tasks2 = new Map<String,Milestone1_Task__c>([SELECT 
                        Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
                            Estimated_Expense__c,Estimated_Hours__c,Priority__c,
                            Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
                            Last_Email_Received__c,Assigned_To__c
                                            FROM Milestone1_Task__c
                                            WHERE Project_Milestone__c = :ms2Clone.Id
                                            OR Project_Milestone__r.Parent_Milestone__c = :ms2Clone.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
        
    }


    static testMethod void testMilestoneWithManyTasksClone(){
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        ms2.Alias__c = 'DCMTEST927';
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create tasks linked to the first milestone 
        Map<String,Milestone1_Task__c> tasks = manyTasks(ms2,NUMBER_OF_TASKS);
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);
        cont.createClone();
        
        Milestone1_Milestone__c ms2Clone = [SELECT 
                                                Id,ImportID__c,Name,Project__c,Complete__c,Kickoff__c,Deadline__c,
                                                Description__c,Expense_Budget__c,Hours_Budget__c,Alias__c
                                            FROM Milestone1_Milestone__c
                                            WHERE ImportID__c = :ms2.Id
                                           ];
        System.assertNotEquals(null, ms2Clone);
        System.assertEquals(null, ms2Clone.Alias__c);
              
        Map<String,Milestone1_Task__c> tasks2 = new Map<String,Milestone1_Task__c>([SELECT 
                                                Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
                                                Estimated_Expense__c,Estimated_Hours__c,Priority__c,
                                                Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
                                                Last_Email_Received__c,Assigned_To__c
                                            FROM Milestone1_Task__c
                                            WHERE Project_Milestone__c = :ms2Clone.Id
                                            OR Project_Milestone__c = :ms2Clone.Id 
                                           ]);
                                  
        areEqualsTasks(tasks2, tasks);
    }
    
    
    
    static testmethod void testProjectCloneInactiveOwner() {        
        
         User u = Milestone1_Test_Utility.createSFUser();
         u.IsActive = true;
         Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
         System.runAs(u){           
            insert proj;
         }       
            u.IsActive = false;
            update u;

         User testUser = Milestone1_Test_Utility.createSFUser();
         testUser.IsActive = true;
         update testUser;        
            
          System.runAs(testUser){         
            ApexPages.StandardController stc = new ApexPages.StandardController(proj);
            Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);            
            
                PageReference ref = cont.createClone();
                
                Boolean flag = false;
                
                if (ref == null){                   
                    proj.OwnerId = testUser.Id;
                    update proj;
                    flag = true;
                }
                System.assertEquals(true,flag);
                System.assertEquals(proj.OwnerId,testUser.Id);
                System.assertNotEquals(proj.OwnerId,u.Id);
            }
    }
    
    static testmethod void testProjectCloneActiveOwner() {      
        
         User u = Milestone1_Test_Utility.createSFUser();
         u.IsActive = true;
         Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
         System.runAs(u){           
            insert proj;
         }       
         User testUser = Milestone1_Test_Utility.createSFUser();
         testUser.IsActive = true;
         update testUser;        
            
         System.runAs(testUser){            
            ApexPages.StandardController stc = new ApexPages.StandardController(proj);
            Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);            
            
                PageReference ref = cont.createClone();
                            
                Boolean flag = false;
                
                if (ref != null){
                    flag = true;
                }
                System.assertEquals(true,flag);
            }
    }
    
   static testmethod void testMilestoneCloneInactiveOwner() {
        
        User u = Milestone1_Test_Utility.createSFUser();
        u.IsActive = true;
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        System.runAs(u){
            insert proj;
        } 
        
        //create a milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms');        
        topMilestones.add(ms2);   
            
        System.runAs(u){
            insert topMilestones;
        }        
        u.IsActive = false;
        update u;

        User testUser = Milestone1_Test_Utility.createSFUser();
        testUser.IsActive = true;
        update testUser;
        
        System.runAs(testUser) {
            
            ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
            Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);            
            
            pageReference ref = cont.createClone();

            Boolean flag = false;
            if (ref == null){
                
                ms2.OwnerId = testUser.Id;
                update ms2;
                flag = true;
            }
            System.assertEquals(true,flag);
            System.assertEquals(ms2.OwnerId,testUser.Id);
            System.assertEquals(topMilestones[0].Expense_Budget__c,ms2.Expense_Budget__c);
        }
   }

    
    static testmethod void testMilestoneCloneActiveOwner() {        
        
        User u = Milestone1_Test_Utility.createSFUser();
        u.IsActive = true;
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        System.runAs(u){
            insert proj;
        } 
        
        //create a milestone
        List<Milestone1_Milestone__c> testmilestone = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms');
        ms2.Alias__c = 'TEST111';
        testmilestone.add(ms2);   
            
        System.runAs(u){
            insert testmilestone;
        }

        User testUser = Milestone1_Test_Utility.createSFUser();
        testUser.IsActive = true;
        update testUser;
        
        System.runAs(testUser) {
            
            ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
            Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);            
            
            pageReference ref = cont.createClone();
            Boolean flag = false;               
                if (ref != null){
                    flag = true;
                }
            Milestone1_Milestone__c ms2Clone = [SELECT Id,
                                                   Name,
                                                   Alias__c,
                                                   Expense_Budget__c
                                                FROM Milestone1_Milestone__c
                                                WHERE ImportID__c = :ms2.Id
                                                ];
            System.assertNotEquals(null, ms2Clone);
            System.assertEquals(null, ms2Clone.Alias__c);
            System.assertEquals(true,flag);
            System.assertEquals(testmilestone[0].Expense_Budget__c,ms2Clone.Expense_Budget__c);
            }       
    }
    /**
    *   Create a batch of tasks
    */
    public static Map<String,Milestone1_Task__c> manyTasks(Milestone1_Milestone__c parentMilestone, Integer size){
        
        Map<String,Milestone1_Task__c> tasksMap = new Map<String,Milestone1_Task__c>();
        Milestone1_Task__c task;
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        for(Integer i = 0; i < size; i++){
            task = Milestone1_Test_Utility.sampleTask(parentMilestone.Id);
            task.Name =  'ts'+i;
            tasksMap.put(task.Name,task);
        }
        insert tasksMap.values();
        return tasksMap;        
    }
    

    
    
    
    public static void areEqualsMilestones (Map<String,Milestone1_Milestone__c> milestonesOriginal,
                                                Map<String,Milestone1_Milestone__c> milestones){
    
        Milestone1_Milestone__c milestone;
        for(Milestone1_Milestone__c milestoneOriginal : milestonesOriginal.values()){
            milestone = milestones.get(milestoneOriginal.Name);
            System.assert(milestone != null,milestoneOriginal.Name);
            System.assertEquals(milestoneOriginal.Name , milestone.Name, 'MILESTONE name not equal');
            System.assertEquals(milestoneOriginal.Kickoff__c , milestone.Kickoff__c, 'MILESTONE kickoff not equal');
            System.assertEquals(milestoneOriginal.Deadline__c , milestone.Deadline__c, 'MILESTONE deadline not equal');
            System.assertEquals(milestoneOriginal.Description__c , milestone.Description__c, 'MILESTONE description not equal');
            System.assertEquals(milestoneOriginal.Expense_Budget__c , milestone.Expense_Budget__c, 'MILESTONE expense budget not equal');
            System.assertEquals(milestoneOriginal.Hours_Budget__c , milestone.Hours_Budget__c, 'MILESTONE hours budget not equal');             
        }
    }
    
    public static void areEqualsTasks (Map<String,Milestone1_Task__c> tasksOriginal,
                                                Map<String,Milestone1_Task__c> tasks){
    
        Milestone1_Task__c task;
        for(Milestone1_Task__c taskOriginal : tasksOriginal.values()){
            task = tasks.get(taskOriginal.Name);
            System.assert(task != null,taskOriginal.Name);
            System.assertEquals(taskOriginal.Name , task.Name, 'TASK Name not equal');
            System.assertEquals(taskOriginal.Due_Date__c , task.Due_Date__c, 'TASK Due date not equal');
            System.assertEquals(taskOriginal.Start_Date__c , task.Start_Date__c, 'TASK Start date not equal');
            System.assertEquals(taskOriginal.Description__c ,task.Description__c, 'TASK Description not equal');
            System.assertEquals(taskOriginal.Estimated_Expense__c , task.Estimated_Expense__c,'TASK Estimated expense not equal');
            System.assertEquals(taskOriginal.Estimated_Hours__c , task.Estimated_Hours__c, 'TASK Estimated hours not equal');
            System.assertEquals(taskOriginal.Last_Email_Received__c , task.Last_Email_Received__c, 'TASK Last email received not equal');
            System.assertEquals(taskOriginal.Assigned_To__c , task.Assigned_To__c, 'TASK Assigned to not equal');
            System.assertEquals(taskOriginal.Priority__c , task.Priority__c, 'TASK Priority not equal');
            System.assertEquals(taskOriginal.Class__c , task.Class__c, 'TASK Class not equal');             
        }
    }
}