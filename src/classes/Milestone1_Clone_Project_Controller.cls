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
public with sharing class Milestone1_Clone_Project_Controller {
    
    public Milestone1_Project__c rec {get; set;}
    public Milestone1_Project__c dummyProj {get; set;}
    private List<Milestone1_Milestone__c> milestones {get; set;}
    private List<Milestone1_Task__c> tasks {get; set;}

    public Milestone1_Clone_Project_Controller(ApexPages.StandardController stc){
        //query project record
        rec = [SELECT Id,
                      Name,
                      Deadline__c,
                      Description__c,
                      Status__c,
                      Total_Expense_Budget__c,
                      Total_Hours_Budget__c,
                      KickOff__c
               FROM Milestone1_Project__c
               WHERE Id = :stc.getId()
              ];
        
        //query milestone records
        milestones = [SELECT Id,
                             Name,
                             Parent_Milestone__c,
                             Complete__c,
                             Deadline__c,
                             Description__c,
                             Expense_Budget__c,
                             Hours_Budget__c,
                             OwnerId,
                             KickOff__c
                      FROM Milestone1_Milestone__c
                      WHERE Project__c = :rec.Id
                     ];
        
        //query task records
        tasks = [SELECT Id,
                        Name,
                        Project_Milestone__c,
                        Assigned_To__c,
                        Complete__c,
                        Description__c,
                        Start_Date__c,
                        Due_Date__c,
                        Priority__c,
				        Task_Stage__c,
				        Class__c,
				        Blocked__c,
				        Blocked_Reason__c,
				        Last_Email_Received__c,
				        Estimated_Hours__c,
				        Estimated_Expense__c
                 FROM Milestone1_Task__c
                 WHERE Project_Milestone__r.Project__c = :rec.Id
                ];
                
        dummyProj = new Milestone1_Project__c();
        dummyProj.Name = 'Copy of ' + rec.Name;
    }
    
    public PageReference createClone(){
        //create new project record
        rec.Name = dummyProj.Name;
        Milestone1_Project__c newProj = Milestone1_Clone_Utility.cloneProject(rec);
        insert newProj;
        
        //separate milestone records into parents and subs
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        List<Milestone1_Milestone__c> bottomMilestones = new List<Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c oldMS : milestones){
            if(oldMS.Parent_Milestone__c == null){
                topMilestones.add(oldMS);
            } else {
                bottomMilestones.add(oldMS);
            }
        }
        
        //clone and insert top milestone records
        Map<String, Milestone1_Milestone__c> newTopMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(topMilestones);
        for(Milestone1_Milestone__c newMS : newTopMilestoneMap.values()){
            newMS.Project__c = newProj.Id;
        }
        insert newTopMilestoneMap.values();
        
        //clone and insert sub milestone records
        Map<String, Milestone1_Milestone__c> newBottomMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(bottomMilestones);
        for(Milestone1_Milestone__c newMS : newBottomMilestoneMap.values()){
            newMS.Project__c = newProj.Id;
            newMS.Parent_Milestone__c = newTopMilestoneMap.get(newMS.Parent_Milestone__c).Id;
        }
        insert newBottomMilestoneMap.values();
        
        //collect all milestones into one map
        Map<String, Milestone1_Milestone__c> allNewMilestoneMap = new Map<String, Milestone1_Milestone__c>();
        allNewMilestoneMap.putAll(newTopMilestoneMap);
        allNewMilestoneMap.putAll(newBottomMilestoneMap);
        
        //clone and insert task records
        List<Milestone1_Task__c> newTasks = Milestone1_Clone_Utility.cloneTasksIntoList(tasks);
        for(Milestone1_Task__c newTask : newTasks){
            newTask.Project_Milestone__c = allNewMilestoneMap.get(newTask.Project_Milestone__c).Id;
        }
        insert newTasks;
        
        //direct user to cloned project's detail page
        return new ApexPages.StandardController(newProj).view();
    }

}