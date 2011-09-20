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
private class Milestone1_Test_Move {

    static testMethod void testMilestoneMove() {
        final Integer NUMBER_OF_MILESTONES = 5;
        final Integer NUMBER_OF_TASKS = 20;
        final Integer NUMBER_OF_TIMES = 50;
        final Integer NUMBER_OF_EXPENSES = 50;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a few sub-milestones underneath ms1 and ms2
        List<Milestone1_Milestone__c> subMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms3 = Milestone1_Test_Utility.sampleMilestone(null, ms1.Id, 'ms3');
        subMilestones.add(ms3);
        Milestone1_Milestone__c ms4 = Milestone1_Test_Utility.sampleMilestone(null, ms2.Id, 'ms4');
        subMilestones.add(ms4);
        Milestone1_Milestone__c ms5 = Milestone1_Test_Utility.sampleMilestone(null, ms2.Id, 'ms5');
        subMilestones.add(ms5);
        insert subMilestones;
        
        //collect all milestones that will be moved
        List<Milestone1_Milestone__c> milestonesToMove = new List<Milestone1_Milestone__c>();
        milestonesToMove.add(ms2);
        milestonesToMove.add(ms3);
        
        //create move page controller and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(milestonesToMove);
        stc.setSelected(milestonesToMove);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;
        cont.moveMilestones();
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT Id,
                                                            Name
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Project__c = :proj2.Id
                                                    ];
        
        System.assertEquals(4, milestones2.size());
        
        milestones2[0].Project__c = proj.Id;
        Boolean errorOccured = false;
        try{
            update milestones2[0];
        } catch (DMLException e){
            errorOccured = true;
        } finally {
            System.assert(errorOccured);
        }
    }
    
    static testMethod void testMilestoneMoveDetail() {
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a  top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        insert topMilestones;
             
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms1);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;
        cont.moveMilestones();
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT Id,
                                                            Name
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Project__c = :proj2.Id
                                                    ];
        
        System.assertEquals(1, milestones2.size());
        
        milestones2[0].Project__c = proj.Id;
        Boolean errorOccured = false;
        try{
            update milestones2[0];
        } catch (DMLException e){
            errorOccured = true;
        } finally {
            System.assert(errorOccured);
        }
    }
    
    //RSC 2011-09-20 Added to support milestone dependency.
    //fails when the candidate milestone has a predecessor
    static testMethod void testMilestoneMoveFailsWithPredecessorMilestoneSet1() {

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a  top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms1);
        topMilestones.add(ms2);
        insert topMilestones;
        
        ms2.Predecessor_Milestone__c = ms1.id;
        update ms2;
        
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;

    	cont.moveMilestones();

		System.assert(ApexPages.hasMessages(), 'Apex pages should have had an error message but didnt. (Has predecessor)' );             
        
    }
    
    //RSC 2011-09-20 Added to support milestone dependency.
    //fails when the candidate milestone has successors.
    static testMethod void testMilestoneMoveFailsWithPredecessorMilestoneSet2() {

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a  top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms1);
        topMilestones.add(ms2);
        insert topMilestones;
        
        ms2.Predecessor_Milestone__c = ms1.id;
        update ms2;
        
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms1);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;

    	cont.moveMilestones();

		System.assert(ApexPages.hasMessages(), 'Apex pages should have had an error message but didnt. (Has successors)' );             
        
    }    
    
    //RSC 2011-09-20 Added to support milestone dependency.
    //succeeds for simple moves
    static testMethod void testMilestoneMoveFailsWithPredecessorMilestoneSet3() {

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a  top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms1);
        topMilestones.add(ms2);
        insert topMilestones;
       
        
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms1);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;

    	cont.moveMilestones();

		System.assert(!ApexPages.hasMessages(), 'Apex pages should NOT have had an error message but did. (clean move)' );             
        
    }        
    
    //RSC 2011-09-20 Added to support milestone dependency.
    //succeeds for parent with no preds / successors but children with both.
    static testMethod void testMilestoneMoveFailsWithPredecessorMilestoneSet4() {

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create two projects
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        Milestone1_Project__c proj2 = Milestone1_Test_Utility.sampleProject('proj2');
        insert proj;
        insert proj2;
        
        //create a  top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms1);
        topMilestones.add(ms2);
        insert topMilestones;
        
        Milestone1_Milestone__c ms2a = Milestone1_Test_Utility.sampleMilestone(proj.Id, ms2.id, 'ms2a');
        Milestone1_Milestone__c ms2b = Milestone1_Test_Utility.sampleMilestone(proj.Id, ms2.id, 'ms2b');
        Milestone1_Milestone__c ms2c = Milestone1_Test_Utility.sampleMilestone(proj.Id, ms2.id, 'ms2c');
        insert ms2a; insert ms2b; insert ms2c;
        ms2b.Predecessor_Milestone__c = ms2a.id;
        ms2c.Predecessor_Milestone__c = ms2b.id;
        update ms2b; update ms2c;
        
        //create move page controller and call move action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = proj2.Id;

    	cont.moveMilestones();

		System.assert(!ApexPages.hasMessages(), 'Apex pages should NOT have had an error message but did. (clean move with child milestones with predecessors)' );             
        
    }       
    
    static testMethod void testTaskMoveFromList() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task1);
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task2);
        insert tasks;
        
        //create a time record for task1
        Milestone1_Time__c time1 = Milestone1_Test_Utility.sampleTime(task1.Id);
        insert time1;
        
        List<Milestone1_Task__c> tasksToMove = new List<Milestone1_Task__c>();
        tasksToMove.add(task1);
        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(tasksToMove);
        stc.setSelected(tasksToMove);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        System.assert(cont.hasChildren);
        
        tasksToMove.clear();
        tasksToMove.add(task2);
        
        //create a log record for task2
        Milestone1_Log__c log = new Milestone1_Log__c();
        log.Project__c = proj.Id;
        log.Project_Task__c = task2.Id;
        insert log;
        
        //recreate move page controller and call move action
        stc = new ApexPages.StandardSetController(tasksToMove);
        stc.setSelected(tasksToMove);
        cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();
        
        //load clone back and make sure it exists
        List<Milestone1_Task__c> tasks2 = [SELECT Id,
                                                  Name
                                           FROM Milestone1_Task__c
                                           WHERE Project_Milestone__c = :ms2.Id
                                          ];
        
        System.assertEquals(1, tasks2.size());
        
        //load log back and make sure it points to clone,not original
        log = [SELECT Id FROM Milestone1_Log__c WHERE Project_Task__c = :tasks2[0].Id];
        System.assertNotEquals(null, log);
        
    }
    
    static testMethod void testTaskMove() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        insert task1;
        
        //create a time record for task1
        Milestone1_Time__c time1 = Milestone1_Test_Utility.sampleTime(task1.Id);
        insert time1;
        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardController stc = new ApexPages.StandardController(task1);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        System.assert(cont.hasChildren);
        
        //create a log record for task2
        Milestone1_Log__c log = new Milestone1_Log__c();
        log.Project__c = proj.Id;
        log.Project_Task__c = task1.Id;
        insert log;
        
        //recreate move page controller and call move action
        stc = new ApexPages.StandardController(task1);
        cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();
        
        //load clone back and make sure it exists
        List<Milestone1_Task__c> tasks2 = [SELECT Id,
                                                  Name
                                           FROM Milestone1_Task__c
                                           WHERE Project_Milestone__c = :ms2.Id
                                          ];
        
        System.assertEquals(1, tasks2.size());
        
        //load log back and make sure it points to clone,not original
        log = [SELECT Id FROM Milestone1_Log__c WHERE Project_Task__c = :tasks2[0].Id];
        System.assertNotEquals(null, log, 'Found a log for new Project_Task__c when we should not have.');
        
    }
 
 	//simple move, should fail since the selected task has a successor
    static testMethod void testTaskMoveWithSuccessorsPredecessors1() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        insert task1; insert task2;
        task2.predecessor_task__c = task1.id;
        update task2;
        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardController stc = new ApexPages.StandardController(task1);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();
        
		System.assert(ApexPages.hasMessages(), 'Didnt find a message but should have due to successor task failure.');        
    }
    
    //should success since everything is selected
    static testMethod void testTaskMoveWithSuccessorsPredecessors2() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a couple of milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        milestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        milestones.add(ms2);
        insert milestones;

        //create a couple of tasks
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task1);
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        tasks.add(task2);
        insert tasks;
        task2.Predecessor_Task__c = task1.id;
        update task2;

        
        //create move page controller and ensure that task1 can't be moved
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(tasks);
        stc.setSelected(tasks);
        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = ms2.Id;
        cont.moveTasks();

		//this should success since all tasks are in selected
		System.assert(ApexPages.hasMessages(), 'Found error messages but should not have as all tasks were selected');        
        
    }
    


    static testMethod void testHighTaskMove(){
        Set<Id> srcMilestoneSet = new Set<Id>();
        Set<Id> dstMilestoneSet = new Set<Id>();

        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        // Create projects
        List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
        pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
        pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

        insert pList;
        
        // Create one top level milestone
        Milestone1_Project__c   srcProject   = pList.get(0); 
        Milestone1_Project__c   dstProject   = pList.get(1);
        Milestone1_Milestone__c srcTopMilestone = Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Src Top Milestone');
        Milestone1_Milestone__c dstTopMilestone = Milestone1_Test_Utility.sampleMilestone(dstProject.Id, null, 'Dst Top Milestone');
 
        insert new List<Milestone1_Milestone__c>{ srcTopMilestone, dstTopMilestone};

        // Create two sub-milestones
        List<Milestone1_Milestone__c> subMilestones = new List<Milestone1_Milestone__c>();
        subMilestones.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, srcTopMilestone.Id, 'Second Milestone - 1') );
        subMilestones.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, srcTopMilestone.Id, 'Second Milestone - 2') );

        insert subMilestones;
        
        // Add tasks to each submilestone
        Milestone1_Task__c currentTask;
        List<Milestone1_Task__c>    tskList  = new List<Milestone1_Task__c>();
        List<Milestone1_Task__c>    allTasks = new List<Milestone1_Task__c>();
        
        for(Integer i = 0; i < subMilestones.size(); i++){
            for(Integer j = 0; j < 2; j++){
                for(Integer k = 0; k < 55; k++){
                    tskList.add( Milestone1_Test_Utility.sampleTask(subMilestones.get(i).Id) );
                }

                try{
                    insert tskList;
                }
                catch(Exception e){
                    system.assert(false, e.getMessage());
                }
                
                allTasks.addAll( tskList );
                tskList.clear();
            }
        }

            
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(allTasks);
        stc.setSelected(allTasks);

        Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
        cont.dummyTask.Project_Milestone__c = dstTopMilestone.Id;

        cont.moveTasks();

        // Check if tasks were moved
        Integer srcTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c = :srcTopMilestone.Id]; 
        system.assertEquals( 0, srcTaskCount );

        Integer dstTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c = :dstTopMilestone.Id]; 
        system.assertEquals( 2 * 2 * 55, dstTaskCount );
    }
    
    static testmethod void testSimpleCloneAndMove() {
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
      // Project
      Milestone1_Project__c m = Milestone1_Test_Utility.sampleProjectActive('taskCloneTest');
      insert m;

      // Milestones
      Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(m);
      insert ms1;
      Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(m);
      insert ms2;

      // Tasks
      Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1);
      insert task1;
    
      System.assert(task1.Due_Date__c            != null, 'Due Date is null');
      System.assert(task1.Start_Date__c          != null, 'Start Date is null');
      System.assert(task1.Estimated_Expense__c   != null, 'Estimated Expense is null');
      System.assert(task1.Estimated_Hours__c     != null, 'Estimated Hours is null');
      System.assert(task1.Priority__c            != null, 'Priority is null');
      System.assert(task1.Class__c               != null, 'Class is null');
      System.assert(task1.Task_Stage__c          != null, 'Task Stage is null');
      System.assert(task1.Blocked__c             != null, 'Blocked is null');
      System.assert(task1.Last_Email_Received__c != null, 'Last email is null');

      // Validate basic clone
      Milestone1_Task__c cloneOfTask1 = task1.clone(false, false);
      System.assert(cloneOfTask1.Due_Date__c            == task1.Due_Date__c, 'Due Date fail');
      System.assert(cloneOfTask1.Start_Date__c          == task1.Start_Date__c, 'Start Date fail');
      System.assert(cloneOfTask1.Estimated_Expense__c   == task1.Estimated_Expense__c, 'Estimated Expense fail');
      System.assert(cloneOfTask1.Estimated_Hours__c     == task1.Estimated_Hours__c, 'Estimated Hours fail');
      System.assert(cloneOfTask1.Priority__c            == task1.Priority__c, 'Priority fail');
      System.assert(cloneOfTask1.Class__c               == task1.Class__c, 'Class fail');
      System.assert(cloneOfTask1.Task_Stage__c          == task1.Task_Stage__c, 'Task Stage fail');
      System.assert(cloneOfTask1.Blocked__c             == task1.Blocked__c, 'Blocked fail');
      System.assert(cloneOfTask1.Blocked_Reason__c      == task1.Blocked_Reason__c, 'Blocked Reason fail');
      System.assert(cloneOfTask1.Last_Email_Received__c == task1.Last_Email_Received__c, 'Last Email Received fail');
      
      // Move
      ApexPages.StandardController   stc  = new ApexPages.StandardController(task1);
      Milestone1_Move_Task_Extension cont = new Milestone1_Move_Task_Extension(stc);
      cont.dummyTask.Project_Milestone__c = ms2.Id;
      cont.moveTasks();

      // Validate Move
      List<Milestone1_Task__c> tasks_moved = [SELECT Id,
                                                     Name,
                                                     Due_Date__c,
                                                     Start_Date__c,
                                                     Estimated_Expense__c,
                                                     Estimated_Hours__c,
                                                     Priority__c,
                                                     Class__c,
                                                     Task_Stage__c,
                                                     Blocked__c,
                                                     Blocked_Reason__c,
                                                     Last_Email_Received__c
                                                 FROM Milestone1_Task__c
                                                 WHERE Project_Milestone__c = :ms2.Id 
                                                      AND Name = :task1.Name];

      System.assertEquals(1, tasks_moved.size(), 'Tasks moved comparison failed');

      System.assertEquals(task1.Due_Date__c            , tasks_moved.get(0).Due_Date__c, 'Due date failed');
      System.assertEquals(task1.Start_Date__c          , tasks_moved.get(0).Start_Date__c, 'Start date failed');
      System.assertEquals(task1.Estimated_Expense__c   , tasks_moved.get(0).Estimated_Expense__c, 'Estimated date failed');
      System.assertEquals(task1.Estimated_Hours__c     , tasks_moved.get(0).Estimated_Hours__c, 'Estimated hours failed');
      System.assertEquals(task1.Priority__c            , tasks_moved.get(0).Priority__c, 'Priority failed');
      System.assertEquals(task1.Class__c               , tasks_moved.get(0).Class__c, 'Class failed');
      System.assertEquals(task1.Task_Stage__c          , tasks_moved.get(0).Task_Stage__c, 'Task Stage failed');
      System.assertEquals(task1.Blocked__c             , tasks_moved.get(0).Blocked__c, 'Blocked failed');
      System.assertEquals(task1.Blocked_Reason__c      , tasks_moved.get(0).Blocked_Reason__c, 'Blocked reason failed');
      System.assertEquals(task1.Last_Email_Received__c, tasks_moved.get(0).Last_Email_Received__c, 'Last email received failed orig ' + task1.Last_Email_Received__c + ' moved ' + tasks_moved.get(0).Last_Email_Received__c);
    }
    

}