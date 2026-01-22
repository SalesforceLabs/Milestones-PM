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
private class Milestone1_XML_Import_Utility_Test {  
   /*static TestMethod void testSOQLQueries1()
    {
        Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Milestone__c testMilestone2 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME2 ACB123XYZ UNIQUE' + System.now());
        insert testMilestone2;
        testMilestone2 = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone2.Name limit 1];
        
        Milestone1_Milestone__c testMilestone3 = Milestone1_Test_Utility.sampleMilestone(null,testMilestone.Id,'UNIT TEST MILESTONE NAME3 ACB123XYZ UNIQUE' + System.now());
        insert testMilestone3;
        testMilestone3 = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone3.Name limit 1];
        

       
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task2;
        
        Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        insert task3;
        
        Milestone1_Task__c task4 = Milestone1_Test_Utility.sampleTask(testMilestone3.Id);
        insert task4;
        
        Milestone1_Task__c task5 = Milestone1_Test_Utility.sampleTask(testMilestone3.Id);
        insert task5;
       
        String xmlString = m1exportutility.buildProjectXmlString(testProject.Id);
        System.assertNotEquals(xmlString, null);
        system.debug('Number of soql queries fired'+Limits.getQueries());
        
        Milestone1_XML_Import_Utility importXMLUtility = new Milestone1_XML_Import_Utility();
        importXMLUtility.importProject(xmlString);
        system.debug('Number of soql queries fired'+Limits.getQueries());
    }*/
    	/**
         *Modified Date:04-26-2012.
         *Owner:Persistent.
         *Comment: Importing the project with all the relationships intact.
         *Bug #: 66.
   	     */ 
    static TestMethod void  testSOQLQueries(){
    	Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
    	 
    	Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        insert testProject;
        //testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
    	
    	Milestone1_Milestone__c testPredecessorMilestone = Milestone1_Test_Utility.testSampleMilestone(testProject.Id,null,'UNIT_TEST_PREDECESSOR_MILESTONE_NAME_ACB123XYZ_UNIQUE' + System.now());
        insert testPredecessorMilestone;
        //testPredecessorMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testPredecessorMilestone.Name limit 1];
        
        Milestone1_Milestone__c testSuccessorMilestone = Milestone1_Test_Utility.testSampleMilestone(testProject.Id,testPredecessorMilestone.Id,'UNIT_TEST_SUCCESSOR_MILESTONE_1_NAME_ACB123XYZ_UNIQUE' + System.now());
        insert testSuccessorMilestone;
        //testSuccessorMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testSuccessorMilestone.Name limit 1];
        
        Milestone1_Task__c predecessorTask = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id,null,Date.today(),Date.today().addDays(1));
        insert predecessorTask;
        
        Milestone1_Task__c successorTask = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id,predecessorTask.Id,Date.today().addDays(2),Date.today().addDays(3));
        insert successorTask;
        system.debug('Successor Task'+successorTask);
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id);
        insert task1;
        
       test.startTest();
        String xmlString = m1exportutility.buildProjectXmlString(testProject.Id);
       
        Milestone1_XML_Import_Utility importXMLUtility = new Milestone1_XML_Import_Utility();
        importXMLUtility.importProject(xmlString);
        test.stopTest();
        System.assertNotEquals(xmlString, null);
        
    
    }
    
  
}