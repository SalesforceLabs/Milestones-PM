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
*	Schedulable class to update the active projects with priority order the  
*	lastmodified date.
*/
global public with sharing class Milestone1_Project_Active_Sched_Update implements Schedulable{

	global void execute( SchedulableContext sc ) {
		Integer availableDMLRows = Limits.getLimitDmlRows() - Limits.getDmlRows();	
		
		update [select Id from Milestone1_Project__c  where Status__c = 'Active' order by LastModifiedDate asc limit :availableDMLRows];
	}	
	
	public static testMethod void testUdpateProject(){
		//clean the org with projects
		delete [select Id from Milestone1_Project__c limit 1000];
		
		Date today = Date.today();
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('My Project');
		insert project;
		//modify a status to update the project
		project.Status__c = 'Active';
		Milestone1_Project_Active_Sched_Update scheduleJob = new Milestone1_Project_Active_Sched_Update();
		scheduleJob.execute(null);
		
		System.assertEquals(1,[SELECT count() FROM Milestone1_Project__c WHERE Id =:project.Id AND Status__c = 'Active']);
	}

}