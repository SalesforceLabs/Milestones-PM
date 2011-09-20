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
public with sharing class Milestone1_Move_Task_Extension {
    
    public List<Milestone1_Task__c> recs {get; set;}
    
    //RSC 2011-09-20 Added to support successor / predecessor notes
    private Set<Id> recIds {get;set;}
    
    public Milestone1_Task__c dummyTask {get; set;}
    public Boolean showSave {get; set;}
    public Boolean anySelected {get; set;}
    
    public Boolean hasChildren {get; set;}
    public Boolean hasMultipleMilestones {get;set;}
    public Boolean hasPredecessorTasks {get;set;}
    
    private String taskId;
    private ApexPages.Standardsetcontroller stc;

    public Milestone1_Move_Task_Extension(ApexPages.StandardController stc)
    {
        Milestone1_Task__c moveTask = (Milestone1_Task__c) stc.getRecord();
        taskId = moveTask.Id;
        recs = new List<Milestone1_Task__c>{moveTask};
        processSelection(recs);
    }

    public Milestone1_Move_Task_Extension(ApexPages.StandardSetController instc){
        stc = instc;
        taskId = null;
        recs = stc.getSelected();
        processSelection(recs);
    }
    
    private void processSelection(List<Milestone1_Task__c> processList)
    {
    	Set<Id> milestones = new Set<Id>();
    	
        recs = processList;
        anySelected = recs.size() > 0;
        
        recIds = new Set<Id>();
        for(Milestone1_Task__c rec : recs){
            recIds.add(rec.Id);
        }
        
        //query task records
        recs = [SELECT Id,
                       Name,
                       Project_Milestone__c,
                       Assigned_To__c,
                       Complete__c,
                       Description__c,
                       Due_Date__c,
                       Start_Date__c,
                       Estimated_Expense__c,
                       Estimated_Hours__c,
                       Priority__c,
                       Class__c,
                       Task_Stage__c,
                       Blocked__c,
                       Blocked_Reason__c,
                       Last_Email_Received__c,
                       Predecessor_Task__c,
                       (SELECT Id FROM Project_Times__r),
                       (SELECT Id FROM Project_Expenses__r),
                       (SELECT Id FROM Notes),
                       (SELECT Id FROM Attachments),
                       (SELECT Id FROM NotesAndAttachments)
                FROM Milestone1_Task__c
                WHERE Id IN :recIds
               ];
        
        hasChildren = false;
        hasPredecessorTasks = false;
        hasMultipleMilestones = false;
        
        for(Milestone1_Task__c rec : recs){
            if(rec.Project_Times__r.size() > 0 ||
               rec.Project_Expenses__r.size() > 0 ||
               rec.Notes.size() > 0 ||
               rec.Attachments.size() > 0 ||
               rec.NotesAndAttachments.size() > 0){
                hasChildren = true;
            }
            milestones.add(rec.Project_Milestone__c);
            if (rec.Predecessor_Task__c != null) {
            	hasPredecessorTasks = true;
            }
        }
        
        hasMultipleMilestones = milestones.size() > 1;
        
        showSave = anySelected && !hasChildren;
        
        dummyTask = new Milestone1_Task__c();
    }
    
    //tested in Milestone1 Test Move
    public PageReference moveTasks(){
        
        try
        {
		//fail if their are multiple milestones and preds involved. too complex.
		if (hasMultipleMilestones && hasPredecessorTasks) {
			throw new Milestone1_Move_Exception('Cannot move when you are selecting tasks with precessors from multiple milestones.  Reduce your list and try again.');
		}
		
		//future parent.
        Milestone1_Milestone__c ms = [SELECT Id, Complete__c FROM Milestone1_Milestone__c WHERE Id = :dummyTask.Project_Milestone__c];

		//if we move tasks with successors, and we move ALL of those tasks, we're fine.
		//however, if we have successors, and we don't move all of them, data gets terrible.      	
        /*
            assume this structure:
            Task    Pred
            t1      [none]
            t2      t1
            t3      t2
            t4      [none]
            
            If user selects t1 and t2, those should fail since t2 is listed as a predecessor for t3
            if user selected t1, t2 and t3, that should succeed. since no tasks are listed as predecessors for these
        */
        List<Milestone1_Task__c> successors = [Select Id From Milestone1_Task__c WHERE 
            Predecessor_Task__c in :recIds AND Id not in :recIds];
        
       if (successors.size() > 0) {
           throw new Milestone1_Move_Exception('Selected tasks have successors which are not selected. Clear those and try again OR select only tasks which have no successors.');
       } 
       
       //OK nothing immediately wrong so let's give it a shot.
        
        Map<String, Milestone1_Task__c> newTasksMap = Milestone1_Clone_Utility.cloneTasksIntoMap(recs);
        
        for(Milestone1_Task__c newTask : newTasksMap.values()){
            if(newTask.Project_Milestone__c == ms.Id) {
                throw new Milestone1_Move_Exception(Milestone1_Move_Exception.ERROR_TASK_ALREADY_ASSIGNED_MILESTONE);
            }
            if( ms.Complete__c ){
            	throw new Milestone1_Move_Exception(Milestone1_Move_Exception.ERROR_MILESTONE_COMPLETE);
            }
            
            newTask.Project_Milestone__c = ms.Id;
        }
        
        insert newTasksMap.values();
        
        List<Milestone1_Log__c> logs = [SELECT Id, Project_Task__c FROM Milestone1_Log__c WHERE Project_Task__c IN :newTasksMap.keySet()];
        if(logs.size() > 0){
            for(Milestone1_Log__c log : logs){
                log.Project_Task__c = newTasksMap.get(log.Project_Task__c).Id;
            }
        }
        update logs;
        
        delete recs;
        if(taskId != null)
        {
            //If the Task ID is not null, then this is a single move and we can grab the first (and only) new task created
            Milestone1_Task__c copyTask = newTasksMap.values().get(0);
            return new ApexPages.StandardController(copyTask).view();
        }else
        {
            //Cancel will actually take us back to the List View page for Tasks. It will not cancel the move action. Used for navigating to previous page only.
            return stc.cancel();
        }
        }catch(Exception e)
        {
            system.debug('Exception thrown!');
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            return ApexPages.currentPage();
        }
        
    }

}