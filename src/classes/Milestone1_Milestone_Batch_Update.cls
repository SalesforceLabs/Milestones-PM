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
/**
* Batchable class to manage milestone updates
*/
global with sharing class Milestone1_Milestone_Batch_Update implements Database.Batchable<sObject>{
	
	global final Set<Id> milestoneIds;
	
	global Milestone1_Milestone_Batch_Update( Set<Id> mIds ){
		this.milestoneIds = mIds;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator( [SELECT Id FROM Milestone1_Milestone__c WHERE Id IN :milestoneIds] );
	}

	global void execute(Database.BatchableContext BC, List<sObject> milestoneScope){
		update milestoneScope;
	}

	global void finish(Database.BatchableContext BC){}
	
	
	public static testmethod void testMilestoneBatchUpdate(){
		// Create a project with milestones
		Milestone1_Project__c         project = Milestone1_Test_Utility.sampleProject('My Project');
		List<Milestone1_Milestone__c> mList   = new List<Milestone1_Milestone__c>();
		
		insert project;
		
		for(Integer i = 0; i < 200; i++){
			mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Test Milestone ' + i) );
		}
		
		insert mList;
		
		// Extract milestones Ids and run in batch
		Set<Id> idSet = new Set<Id>();
		
		for(Milestone1_Milestone__c m : mList){
			idSet.add( m.Id );
		}
		
		Test.StartTest();

		Database.executeBatch( new Milestone1_Milestone_Batch_Update(idSet) );

		Test.StopTest();

		// Test records were updated
		List<Milestone1_Milestone__c> result = [SELECT Id, LastModifiedDate, CreatedDate FROM Milestone1_Milestone__c WHERE Project__c = :project.Id];
		
		idSet.clear();
		for(Milestone1_Milestone__c m : result){
			if( m.LastModifiedDate > m.CreatedDate ){
				idSet.add( m.Id );
			}
		}
		 
		System.AssertEquals( 200, idSet.size() );
	}
}