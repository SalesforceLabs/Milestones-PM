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
private class Milestone1_Export_Project_Controller_Tst {

    static testMethod void testImportController() {
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
        
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        System.assert(controller.doc != null);
        System.assert(controller.doc.Id != null);
        ApexPages.Pagereference docRef = controller.returnToDocument();
        system.assert(docRef != null);
        ApexPages.Pagereference projRef = controller.returnToProject();
        System.assert(projRef != null);
    }
    
    static testmethod void testExportFileTooLong(){
		// Set new size for project import
    	Integer old_max_file_size = Milestone1_Import_Project_Controller.MAX_FILE_SIZE;
    	Milestone1_Import_Project_Controller.MAX_FILE_SIZE = 1000;
    	
        try{
        	// Create a poject
        	Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('TOO LONG TO EXPORT - PROJECT');
        	insert proj;
        	
        	// Create a milestone
        	Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
        	insert mstone;
        	
        	// Add 100 tasks to the milestone
        	Milestone1_Task__c task;
        	List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();
        	
        	for(Integer i = 0; i < 100; i++){
        		// Add 150 char description to the task
        		task = Milestone1_Test_Utility.sampleTask(mstone.Id);
        		task.Description__c = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        		
        		lTask.add(task);
        	}
        	
			insert lTask;
			
			// Export project
			ApexPages.Standardcontroller         stc       = new ApexPages.Standardcontroller(proj);
			Milestone1_Export_Project_Controller projCntrl = new Milestone1_Export_Project_Controller(stc);
			projCntrl.createExportXML();
			
			system.assert(projCntrl.hasError());
        }
        catch(Exception e){
        	system.assert(false, e.getMessage());
        }
        finally{
        	Milestone1_Import_Project_Controller.MAX_FILE_SIZE = old_max_file_size;	
        }    	
    }
}