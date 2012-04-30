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
public with sharing class Milestone1_Test_Utility {
    
   
    public static Milestone1_Project__c sampleProject(String name) {
        Milestone1_Project__c rec = new Milestone1_Project__c();
        rec.Name = name + ''+ Datetime.now().getTime();
        return rec;
    }

    public static Milestone1_Project__c sampleProjectActive(String name) {
        Milestone1_Project__c rec = Milestone1_Test_Utility.sampleProject(name);
        rec.Status__c   =   'Active';
        rec.Kickoff__c  =   Date.today().addDays(-14);
        rec.Deadline__c =   Date.today().addDays(14);
        return rec;
    }
    public static Milestone1_Milestone__c sampleMilestone(Milestone1_Project__c project) {
        Milestone1_Milestone__c rec = new Milestone1_Milestone__c();
        rec.Name = project.Name + '' + Datetime.now().getTime();
        rec.Project__c = project.id;
        rec.Complete__c = false; //getRandomBool(.25);
        rec.Kickoff__c = project.Kickoff__c;
        rec.Deadline__c = project.Deadline__c;
        rec.Description__c = 'Description for ' + rec.Name;
        rec.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        rec.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;
        return rec;
    }
    public static Milestone1_Milestone__c sampleMilestone(Id projectId, Id parentMSId, String name) {

        Milestone1_Milestone__c rec = new Milestone1_Milestone__c();
        rec.Name = name;
        rec.Parent_Milestone__c = parentMSId;
        rec.Project__c = projectId;
        rec.Complete__c = false; //getRandomBool(.25);
        rec.Description__c = 'Description for ' + name;
        //rec.Kickoff__c  =   Date.today();
        //rec.Deadline__c =   Date.today().addDays(25);
        rec.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        rec.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;

        return rec;
    }
     /**
         *Modified Date:04-26-2012.
         *Owner:Persistent.
         *Comment: Importing the project with all the relationships intact.
         *Bug #: 66.
    */ 
        
    public static Milestone1_Milestone__c testSampleMilestone(Id projectId, Id predecessorMSId, String name){
        Milestone1_Milestone__c rec = new Milestone1_Milestone__c();
        rec.Name = name;
        rec.Predecessor_Milestone__c = predecessorMSId;
        rec.Project__c = projectId;
        rec.Complete__c = false; //getRandomBool(.25);
        rec.Description__c = 'Description for ' + name;
        if(predecessorMSId==null){
            rec.Kickoff__c =Date.today();
            rec.Deadline__c =Date.today().addDays(5);
        }
        else{
            rec.Kickoff__c =Date.today().addDays(6);
            rec.Deadline__c =Date.today().addDays(7);
        }
        rec.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        rec.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;
        return rec;
    }

    public static Milestone1_Task__c sampleTask(Id milestoneId, Date kickoff, Date deadline, Boolean isComplete, Boolean isBlocked) {
        Milestone1_Task__c rec = new Milestone1_Task__c();
        rec.Project_Milestone__c = milestoneId;
        rec.Assigned_To__c = UserInfo.getUserId();
        rec.Name = 'MS ' + milestoneId + ' task ' + Datetime.now().getTime();
        rec.Complete__c = isComplete; //getRandomBool(.25);
        rec.Description__c   = 'test description ' + rec.Name;
        rec.Start_Date__c   = kickoff;
        rec.Due_Date__c   = deadline;
        rec.Estimated_Expense__c = 100.00;
        rec.Estimated_Hours__c = 110.00;
        rec.Priority__c = '0';
        rec.Task_Stage__c = 'None';
        rec.Class__c = 'Ad Hoc';
        rec.Blocked__c = isBlocked;
        if (!isBlocked) {
            rec.Blocked_Reason__c = null;
        } else {
            rec.Blocked_Reason__c = 'Blocked Task Test';
        }
        rec.Last_Email_Received__c = Datetime.now();
        return rec;     
    }
    
    public static Milestone1_Task__c sampleTask(Id milestoneId,Id PredecessorTaskId,Date kickoff, Date deadline){
        Milestone1_Task__c rec = new Milestone1_Task__c();
        rec.Project_Milestone__c = milestoneId;
        rec.Assigned_To__c = UserInfo.getUserId();
        rec.Predecessor_Task__c=PredecessorTaskId;
        rec.Name = 'MS ' + milestoneId + ' task ' + Datetime.now().getTime();
        rec.Description__c   = 'test description ' + rec.Name;
        rec.Start_Date__c   = kickoff;
        rec.Due_Date__c   = deadline;
        return rec;
    }
    

    public static Milestone1_Task__c sampleTask(Milestone1_Milestone__c milestone) {
        return Milestone1_Test_Utility.sampleTask(milestone.Id, milestone.Kickoff__c.addDays(-1), milestone.Deadline__c.addDays(-1), false, false);
    }
    
    public static Milestone1_Task__c sampleTask(Id milestoneId) {
        return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), false, false);
    }

    public static Milestone1_Task__c sampleTaskComplete(Id milestoneId) {
        return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), true, false);
    }

    public static Milestone1_Task__c sampleTaskBlocked(Id milestoneId) {
        return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), false, true);
    }
    
    public static Milestone1_Time__c sampleTime(Id taskId) {
        Milestone1_Time__c rec = new Milestone1_Time__c();
        rec.Project_Task__c = taskId;
        rec.Hours__c = Math.floor(Math.random() * 10 * 100) / 100;
        return rec;
    }
    
    public static Milestone1_Expense__c sampleExpense(Id taskId) {
        Milestone1_Expense__c rec = new Milestone1_Expense__c();
        rec.Project_Task__c = taskId;
        rec.Amount__c = Math.floor(Math.random() * 1000 * 100) / 100;
        return rec;
    }
    
    public static Boolean getRandomBool(Decimal oddsOfTrue){
        if(Math.random() <= oddsOfTrue){
            return true;
        }
        return false;
    }
    
    public static Date getRandomDate(Integer rangeFromToday){
        return Date.today().addDays((Math.random() * rangeFromToday * 2 - rangeFromToday).intValue());
    }
    
    public static Milestone1_Settings__c createDefaultCustomChatterSettings(Boolean autoFollowTasks)
    {
        
        Milestone1_Settings__c testRule = Milestone1_Settings__c.getOrgDefaults();
        if(testRule == null)
        {
            testRule = new Milestone1_Settings__c();
            testRule.SetupOwnerId = UserInfo.getUserId();
            insert testRule;
        } 
            testRule.Auto_Follow_Task__c = autoFollowTasks;
            testRule.Auto_Follow_Complete_Task__c = autoFollowTasks;
            testRule.Auto_Unfollow_Reassignment__c = autoFollowTasks;
            update testRule;
            System.debug(testRule);
        
        
        return testRule;
    }
    
    /**
    * Extract the ids from a milestone list
    *
    * @param src Milestone list
    * @return Set of milestone ids
    */    
    public static Set<Id> extractMilestoneIds(List<Milestone1_Milestone__c> src){
        Set<Id> res = new Set<Id>();
        
        for(Milestone1_Milestone__c m : src){ 
            res.add( m.Id ); 
        }
        
        return res;
    }
    
    /**
    *   Create a batch of milestones
    */
    public static Map<String,Milestone1_Milestone__c> manyMilestones(Milestone1_Project__c project,
                                                                Milestone1_Milestone__c parentMilestone, Integer size){

        Map<String,Milestone1_Milestone__c> milestonesMap = new Map<String,Milestone1_Milestone__c>();
        Milestone1_Milestone__c milestone;
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Id projectId;
        if(project != null){
            projectId = project.Id; 
        }

        for(Integer i = 0; i < size; i++){
            milestone = Milestone1_Test_Utility.sampleMilestone(projectId, parentMilestone.Id, 'ms'+i);

            milestonesMap.put(milestone.Name,milestone);

        }

        insert milestonesMap.values();

        return milestonesMap;   
    }    
    
    /**
    *   Create a batch of milestones with Parent
    */
    public static Map<String,Milestone1_Milestone__c> manyMilestonesParent(Milestone1_Project__c project, Milestone1_Milestone__c parentMilestone, Integer size){
        Map<String,Milestone1_Milestone__c> milestonesMap = new Map<String,Milestone1_Milestone__c>();
        Milestone1_Milestone__c milestone;
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Id projectId;
        if(project != null){
            projectId = project.Id; 
        }
        for(Integer i = 0; i < size; i++){
            milestone = Milestone1_Test_Utility.sampleMilestone(projectId, parentMilestone.Id, 'ms'+i);
            milestone.Kickoff__c = parentMilestone.Kickoff__c;
            milestone.Deadline__c = parentMilestone.Deadline__c;
            milestonesMap.put(milestone.Name,milestone);
        }
        insert milestonesMap.values();
        return milestonesMap;   
    }    
    
    /**
    *   Create a batch of milestones with Predecessor
    */
    public static Map<String,Milestone1_Milestone__c> manyMilestonesPredecessor(Milestone1_Project__c project, Milestone1_Milestone__c predecessorMilestone, Integer size){
        Map<String,Milestone1_Milestone__c> milestonesMap = new Map<String,Milestone1_Milestone__c>();
        Milestone1_Milestone__c milestone;
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Id projectId;
        if(project != null){
            projectId = project.Id; 
        }
        for(Integer i = 0; i < size; i++){
            milestone = Milestone1_Test_Utility.sampleMilestone(projectId, null, 'ms'+i);
            milestone.Predecessor_Milestone__c = predecessorMilestone.Id;
            milestone.Kickoff__c = predecessorMilestone.Deadline__c.addDays(1);
            milestone.Deadline__c = milestone.Kickoff__c.addDays(1);
            milestonesMap.put(milestone.Name,milestone);
        }
        insert milestonesMap.values();
        return milestonesMap;   
    }   
    

    /**
    *   Create a batch of tasks
    */
    public static Map<String,Milestone1_Task__c> manyTasks(Milestone1_Milestone__c parentMilestone, Integer size){
        
        Map<String,Milestone1_Task__c> tasksMap = new Map<String,Milestone1_Task__c>();
        Milestone1_Task__c task;
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        for(Integer i = 0; i < size; i++){
            task = sampleTask(parentMilestone.Id);
            task.Name =  'ts'+i;
            tasksMap.put(task.Name,task);
        }
        insert tasksMap.values();
        return tasksMap;        
    }    
    
    public static Map<String,Milestone1_Task__c> manyPredecessorTasks(Id mileID,Milestone1_Task__c predecessorTask,Integer size){
        Map<String,Milestone1_Task__c> tasksMap = new Map<String,Milestone1_Task__c>();
        Milestone1_Task__c task;
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        Id milestoneId;
        milestoneId = mileId; 
        for(Integer i = 0; i < size; i++){
            task = Milestone1_Test_Utility.sampleTask(milestoneId,predecessorTask.id,predecessorTask.Due_Date__c.addDays(1),predecessorTask.Due_Date__c.addDays(1));
            task.Name =  'ts'+i;
            tasksMap.put(task.Name ,task);
        }
        insert tasksMap.values();
        return tasksMap;  
    }
     
 public static User createSFUser(){
    
    Profile profileUsed;
        
        String ret = 'word' + math.rint(math.random() * 100000);
        for( Profile p : [ Select Id, PermissionsModifyAllData, Name from Profile limit 100 ] ){
             if( p.PermissionsModifyAllData ){
                 profileUsed = p;
             }
        }
        String namePrefix = ret;
    
         User testUser = new User();
         testUser.Email = 'test@test.com';
         testUser.Username = ret + '@testuser.com';
         testUser.LastName = 'test';
         testUser.Alias = 'test';
         testUser.ProfileId = profileUsed.Id;
         testUser.LanguageLocaleKey = 'en_US';
         testUser.LocaleSidKey = 'en_US';
         testUser.TimeZoneSidKey = 'America/Chicago';
         testUser.EmailEncodingKey = 'UTF-8';
        
         insert testUser;  
         
         return testUser;
  } 
}