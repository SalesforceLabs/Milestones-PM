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
public with sharing class Milestone1_Move_Milestone_Extension {
    
    public List<Milestone1_Milestone__c> recs {get; set;}
    private Map<Id, Milestone1_Milestone__c> recsById {get; set;}
    //RSC 2011-09-20 Added to handled successors.
    private Set<id> topRecs { get; set;}
    
    private List<Milestone1_Milestone__c> subMilestones {get; set;}
    private List<Milestone1_Task__c> tasks {get; set;}
    public Milestone1_Milestone__c dummyMS {get; set;}
    public Boolean anySelected {get; set;}
    public String milestoneId {get;set;}
    public String prevPage {get;set;}
    public Boolean hasPermissionProjectField {get;set;}
    public String errorMessagePermission {get;set;}
    private ApexPages.StandardSetController stc;
    
    public Milestone1_Move_Milestone_Extension(ApexPages.StandardController stc)
    {
        Milestone1_Milestone__c currentMilestone = (Milestone1_Milestone__c) stc.getRecord();
        system.debug('Current Milstone Id == ' + currentMilestone.Id);
        recs = new List<Milestone1_Milestone__c>{currentMilestone};
        milestoneId = currentMilestone.Id;
        processSelection(recs);
        checkPermissions();
    }


    public Milestone1_Move_Milestone_Extension(ApexPages.StandardSetController instc){
        stc = instc;
        milestoneId = null;
        recs = stc.getSelected();
        processSelection(recs); 
        checkPermissions();
    }
    
    private void processSelection(List<Milestone1_Milestone__c> processList)
    {
    	if(checkPermissions()){
    		recs = processList;
	        anySelected = recs.size() > 0;
	        if(anySelected){
	            Set<Id> recIds = new Set<Id>();
	            topRecs = new Set<Id>();
	            for(Milestone1_Milestone__c rec : recs){
	                recIds.add(rec.Id);
	                topRecs.add(rec.Id);
	            }
	            recs = [SELECT Id,
	                           Name,
	                           Project__c,
	                           Parent_Milestone__c
	                    FROM Milestone1_Milestone__c
	                    WHERE Id IN :recIds
	                   ];
	    
	            //query sub milestone records
	            subMilestones = [SELECT Id,
	                                    Name,
	                                    Project__c,
	                                    Parent_Milestone__c
	                             FROM Milestone1_Milestone__c
	                             WHERE Parent_Milestone__c IN :recIds
	                            ];
	            
	            //merge both lists so that sub-milestones move with their parents
	            recs.addAll(subMilestones);
	            System.debug('*** milestones being moved: ' + recs.size());
	            
	            recsById = new Map<Id, Milestone1_Milestone__c>();
	            for(Milestone1_Milestone__c rec : recs){
	                rec.Okay_to_Reparent__c = true;
	                recsById.put(rec.Id, rec);
	            }   
	            dummyMS = new Milestone1_Milestone__c();
	        }	
    	}
    }
    
    /**
    *	Check if the user has permission in Project field of Milestone1_Milestone__c object.
    */
    private Boolean checkPermissions(){
    	errorMessagePermission = Milestone1_Milestone_Trigger_Utility.INSUFFICIENT_PRIVILEGES_TO_ACCESS_PROJECT;
    	hasPermissionProjectField = Milestone1_Milestone__c.Project__c.getDescribe().isCreateable();
    	return hasPermissionProjectField;
    }
    
    public PageReference moveMilestones(){
        try
        {
            Milestone1_Project__c proj = [SELECT Id FROM Milestone1_Project__c WHERE Id = :dummyMS.Project__c];
            
            //check to see if move candidates have successor tasks.  If so, they should fail.
            List<Milestone1_Milestone__c> candidateSuccessors = [Select Id From Milestone1_Milestone__c Where 
            	Predecessor_Milestone__c in :topRecs];
            if (candidateSuccessors.size() > 0) {
            	throw new Milestone1_Move_Exception(Milestone1_Move_Exception.ERROR_MILESTONE_HAS_SUCCESSORS);
            }
            
            //check to see if move candidates have predecessor tasks.
            List<Milestone1_Milestone__c> candidateWithPredecessors = [Select Predecessor_Milestone__c From Milestone1_Milestone__c Where 
            	Id in :topRecs AND Predecessor_Milestone__c != null];
            if (candidateWithPredecessors.size() > 0) {
            	throw new Milestone1_Move_Exception(Milestone1_Move_Exception.ERROR_MILESTONE_HAS_PREDECESSOR);
            }
            
            List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
            List<Milestone1_Milestone__c> bottomMilestones = new List<Milestone1_Milestone__c>();
            for(Milestone1_Milestone__c rec : recs){
                system.debug(rec.Project__c + ' == ' + proj.Id);
                if(rec.Project__c == proj.Id)
                {
                    throw new Milestone1_Move_Exception(Milestone1_Move_Exception.ERROR_MILESTONE_ALREADY_ASSIGNED_PROJECT);
                }
                rec.Project__c = proj.Id;
                if(rec.Parent_Milestone__c == null){
                    topMilestones.add(rec);
                } else {
                    if(recsById.get(rec.Parent_Milestone__c) == null){
                        rec.Parent_Milestone__c = null;
                    }
                    bottomMilestones.add(rec);
                }
            }
            
            System.debug('*** topMilestones: ' + topMilestones);
            update topMilestones;
            System.debug('*** bottomMilestones: ' + bottomMilestones);
            update bottomMilestones;
            if(milestoneId != null)
            {
                return new ApexPages.StandardController(new Milestone1_Milestone__c(Id=milestoneId)).view();
            }else
            {
                return stc.cancel();
            }
        }
        catch(Exception e)
        {
            system.debug('Exception thrown!');
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            return ApexPages.currentPage();
        }
    }

}