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
    public Milestone1_Task__c dummyTask {get; set;}
    public Boolean showSave {get; set;}
    public Boolean anySelected {get; set;}
    public Boolean hasChildren {get; set;}
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
        recs = processList;
        anySelected = recs.size() > 0;
        
        Set<Id> recIds = new Set<Id>();
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
                       (SELECT Id FROM Project_Times__r),
                       (SELECT Id FROM Project_Expenses__r),
                       (SELECT Id FROM Notes),
                       (SELECT Id FROM Attachments),
                       (SELECT Id FROM NotesAndAttachments)
                FROM Milestone1_Task__c
                WHERE Id IN :recIds
               ];
        
        hasChildren = false;
        
        for(Milestone1_Task__c rec : recs){
            if(rec.Project_Times__r.size() > 0 ||
               rec.Project_Expenses__r.size() > 0 ||
               rec.Notes.size() > 0 ||
               rec.Attachments.size() > 0 ||
               rec.NotesAndAttachments.size() > 0){
                hasChildren = true;
            }
        }
        
        showSave = anySelected && !hasChildren;
        
        dummyTask = new Milestone1_Task__c();
    }
    
    
    public PageReference moveTasks(){
        
        try
        {
        Milestone1_Milestone__c ms = [SELECT Id, Complete__c FROM Milestone1_Milestone__c WHERE Id = :dummyTask.Project_Milestone__c];
        
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