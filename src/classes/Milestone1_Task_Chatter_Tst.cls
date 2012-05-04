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
private class Milestone1_Task_Chatter_Tst 
{
    static testMethod void testChatterTaskFollows()
    { 
        if(!Milestone1_Schema_Helper.isOrgChatterEnabled())
            return; //chatter is disabled - we can't run this test. 
        
        
        User userObj = Milestone1_Test_Utility.createSFUser();
        
        System.runAs(userObj) {
        
	        Milestone1_Settings__c settings = Milestone1_Test_Utility.createDefaultCustomChatterSettings(true);
	        System.assert(settings.Auto_Follow_Task__c, 'Auto Follow Task must be true for this test to work.');
	        
	        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
	        insert testProject;
	        
	        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
	        insert testMilestone;
	
	        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
	        testTask.Assigned_To__c = UserInfo.getUserId();
	        testTask.Complete__c = false;
	        insert testTask;
	        
	        sObject subscription = Database.query('Select Id, ParentId, SubscriberId from EntitySubscription where ParentId = \''+testTask.Id+'\'');
	        //assert that the user is following this object
	        system.assertEquals(UserInfo.getUserId(),(id) subscription.get('SubscriberId'));
	        
	        testTask.Complete__c = true;
	        update testTask;
	        
	        List<sObject> subscriptionList = Database.query('Select Id, ParentId, SubscriberId from EntitySubscription where ParentId = \''+testTask.Id+'\'');
	        //assert that no one is following this object after its marked as complete
	        system.assertEquals(0,subscriptionList.size());
        }
        
    }
    
    static testMethod void testChatterTaskReassignment()
    {
        if(!Milestone1_Schema_Helper.isOrgChatterEnabled())
            return; //chatter is disabled - we can't run this test. 
        
        User userMain = Milestone1_Test_Utility.createSFUser();
        
        System.runAs(userMain) {
        User userObj = Milestone1_Test_Utility.createSFUser();
       
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(true);
        
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Assigned_To__c = UserInfo.getUserId();
        testTask.Complete__c = false;
        insert testTask;
        
        sObject subscription = Database.query('Select Id, ParentId, SubscriberId from EntitySubscription where ParentId = \''+testTask.Id+'\'');
        //assert that the user is following this object
        system.assertEquals(UserInfo.getUserId(),(id)subscription.get('SubscriberId'));
        system.debug('Other User Id == ' + userObj.Id + 'Task Assigned Id ==' + testTask.Assigned_To__c);
        testTask.Assigned_To__c = userObj.Id;
        update testTask;
        
        List<sObject> subscriptionList = Database.query('Select Id, ParentId, SubscriberId from EntitySubscription where ParentId = \''+testTask.Id+'\' and SubscriberId = \''+UserInfo.getUserId()+'\'');
        //assert that no one is following this object after its marked as complete
        system.assertEquals(0,subscriptionList.size());
        }
        
    }
    

}