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
public with sharing class Milestone1_Milestone_Values_Helper {
    
    //used by Milestone1_Milestone_Trigger_Utility to track new field values for a Milestone
    
    public Milestone1_Milestone__c oldRecord {get; set;}
    public Milestone1_Milestone__c newRecord {get; set;}
    
    public Milestone1_Milestone_Values_Helper(Milestone1_Milestone__c rec){
        oldRecord = rec;
        
        //fields require initialization or the "newRecord.[something] += " will fail with an NPE
        newRecord = new Milestone1_Milestone__c();
        newRecord.Actual_Hours_From_Sub_Milestones__c =0;
        newRecord.Actual_Expense_From_Sub_Milestones__c  =0;
        newRecord.Estimated_Hours_From_Sub_Milestones__c  =0;
        newRecord.Estimated_Expense_From_Sub_Milestones__c  =0;
        newRecord.Hours_Budget_from_Sub_Milestones__c  =0;
        newRecord.Expense_Budget_from_Sub_Milestones__c  =0;
        newRecord.Open_Tasks_in_Sub_Milestones__c  =0;
        newRecord.Late_Tasks_in_Sub_Milestones__c  =0;
        newRecord.Complete_Tasks_in_Sub_Milestones__c  =0;
        newRecord.Blocked_Tasks_in_Sub_Milestones__c  =0;

    }
    
    public void addValuesFromChild(Milestone1_Milestone__c child){
        System.debug('*** Adding values from "' + child.Name + '" to "' + oldRecord.Name + '"');
        System.debug('*** Values being added are: ' + child);
        
        newRecord.Actual_Hours_From_Sub_Milestones__c += child.Total_Actual_Hours__c;
        newRecord.Actual_Expense_From_Sub_Milestones__c += child.Total_Actual_Expense__c;
        newRecord.Estimated_Hours_From_Sub_Milestones__c += child.Total_Estimated_Hours__c;
        newRecord.Estimated_Expense_From_Sub_Milestones__c += child.Total_Estimated_Expense__c;
        newRecord.Open_Tasks_in_Sub_Milestones__c += child.Total_Open_Tasks__c;
        newRecord.Late_Tasks_in_Sub_Milestones__c += child.Total_Late_Tasks__c;
        newRecord.Complete_Tasks_in_Sub_Milestones__c += child.Total_Complete_Tasks__c;
        newRecord.Blocked_Tasks_in_Sub_Milestones__c += child.Total_Blocked_Tasks__c;
                        
        if (child.Hours_Budget__c != null)
        	newRecord.Hours_Budget_from_Sub_Milestones__c += child.Hours_Budget__c;
        
        if (child.Expense_Budget__c != null)	
        	newRecord.Expense_Budget_from_Sub_Milestones__c += child.Expense_Budget__c;
        	
        //2011-03-01 Based on comment from user.
        //newRecord.Complete_Tasks_in_Sub_Milestones__c += child.Total_Late_Tasks__c;
        
        System.debug('*** New values are: ' + newRecord);
    }
    
    public void updateOldWithNew(){
        oldRecord.Estimated_Hours_From_Sub_Milestones__c = newRecord.Estimated_Hours_From_Sub_Milestones__c;
        oldRecord.Estimated_Expense_From_Sub_Milestones__c = newRecord.Estimated_Expense_From_Sub_Milestones__c;
        oldRecord.Actual_Hours_From_Sub_Milestones__c = newRecord.Actual_Hours_From_Sub_Milestones__c;
        oldRecord.Actual_Expense_From_Sub_Milestones__c = newRecord.Actual_Expense_From_Sub_Milestones__c;
        oldRecord.Hours_Budget_From_Sub_Milestones__c = newRecord.Hours_Budget_From_Sub_Milestones__c;
        oldRecord.Expense_Budget_From_Sub_Milestones__c = newRecord.Expense_Budget_From_Sub_Milestones__c;
        oldRecord.Open_Tasks_in_Sub_Milestones__c = newRecord.Open_Tasks_in_Sub_Milestones__c;
        oldRecord.Late_Tasks_in_Sub_Milestones__c = newRecord.Late_Tasks_in_Sub_Milestones__c;
        oldRecord.Complete_Tasks_in_Sub_Milestones__c = newRecord.Complete_Tasks_in_Sub_Milestones__c;
        oldRecord.Blocked_Tasks_in_Sub_Milestones__c = newRecord.Blocked_Tasks_in_Sub_Milestones__c;
        System.debug('*** Final values are: ' + oldRecord);
    }

}