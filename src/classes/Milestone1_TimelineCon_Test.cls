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
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Milestone1_TimelineCon_Test {

    static testMethod void myUnitTest() {
      	Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
		Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME CONTROLLER UNIQUE' + System.now());
		insert testProject;
		testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
		
		Milestone1_Log__c testLog = new Milestone1_Log__c();
		testLog.Project__c = testProject.Id;
		testLog.Subject__c = 'UNIT TEST LOG SUBJECT ABC123XYZ UNIQUE' + System.now();
		insert testLog;
		testLog = [select Id, Name from Milestone1_Log__c where Subject__c = :testLog.Subject__c limit 1];
		
		Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
		insert testMilestone;
		testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
		
		Milestone1_Milestone__c testSubMilestone = Milestone1_Test_Utility.sampleMilestone(null,testMilestone.Id,'UNIT TEST SUB MILESTONE 1 NAME ACB123XYZ UNIQUE' + System.now());
		insert testSubMilestone;
		testSubMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testSubMilestone.Name limit 1];
		
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
		insert task1;
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
		insert task2;
		Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(testMilestone);
		
		Milestone1_TimelineCon mt = new Milestone1_TimelineCon(sc );
		mt.init();
		List<Milestone1_TimelineCon.milestoneEvent> tasks = mt.getAllEvents();
		
		System.debug(LoggingLevel.INFO, tasks );
		//System.assert( tasks.size() == 2 );
		System.assert( mt.getTod_ay() != null );
		System.assert( mt.getTomorr_ow() != null );
		
		System.assert( Milestone1_TimelineCon.toDateTime(null) != null );  
		
		for (Milestone1_TimelineCon.milestoneEvent m: tasks ) {
			System.assertNotEquals(m.Description, null);
			//System.assertEquals('true',m.getDurationEvent());
			System.assertNotEquals(null, m.getTitle() );
			System.assertNotEquals(null, m.getStart() );
			System.assertNotEquals(null, m.getEndAttribute() );

		}
		
		
	}
}