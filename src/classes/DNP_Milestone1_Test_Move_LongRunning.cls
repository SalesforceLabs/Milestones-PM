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
@istest
private with sharing class DNP_Milestone1_Test_Move_LongRunning {

	static testmethod void testHighSecondLevelMilestoneMove(){
		final Integer NUMBER_OF_TOPLEVEL_MILESTONES    = 200;
		final Integer NUMBER_OF_SECONDLEVEL_MILESTONES = 110;

		Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
		
		Set<Id> srcMilestoneSet = new Set<Id>();
		Set<Id> dstMilestoneSet = new Set<Id>();

    	// Create projects
		List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
		pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
		pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

		insert pList;
    	
		// Create top-level milestones
    	Milestone1_Project__c         srcProject = pList.get(0); 
    	Milestone1_Project__c         dstProject = pList.get(1);
        List<Milestone1_Milestone__c> topList    = new List<Milestone1_Milestone__c>();

		for(Integer i = 0; i < NUMBER_OF_TOPLEVEL_MILESTONES; i++){
	        topList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Top Milestone' + i) );
		}
        
		try{
			insert topList;
			srcMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds(topList) ); 
		}
		catch(Exception e){
			system.assert(false, e.getMessage());
		}
		
		// Create second level milestones on the first two top-level milestones
        List<Milestone1_Milestone__c> mList     = new List<Milestone1_Milestone__c>();
        List<Milestone1_Milestone__c> tmpList   = new List<Milestone1_Milestone__c>();
        List<Id>            milestonesWithTasks = new List<Id>();

		for(Integer j = 0; j < 2; j++){
			for(Integer k = 0; k < NUMBER_OF_SECONDLEVEL_MILESTONES; k++){
	        	tmpList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, topList.get(j).Id, 'Milestone' + j) );
			}	

			try{
				insert tmpList;
				mList.addAll( tmpList );
				srcMilestoneSet.addAll( Milestone1_Test_utility.extractMilestoneIds(tmpList) ); 
				tmpList.clear();
			}
			catch(Exception e){
				system.assert(false, e.getMessage());
			}
		}
        
		
		// Create tasks in second level
        List<Milestone1_Task__c> tskList = new List<Milestone1_Task__c>();
		for(Integer l = 0; l < 2; l++){
			for(Integer m = 0; m < 2; m++){
				for(Integer n = 0; n < 35; n++){
					tskList.add( Milestone1_Test_Utility.sampleTask( mList.get(l).Id ) );
				}

				try{
					insert tskList;
					tskList.clear();
				}
				catch(Exception e){
					system.assert(false, e.getMessage());
				}
			}
			
			milestonesWithTasks.add( mList.get(l).Id );
		}
		
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(topList);
        stc.setSelected(new List<Milestone1_Milestone__c>{ topList.get(0), topList.get(1)});
        
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = dstProject.Id;
        
        cont.moveMilestones();
        
		dstMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds([SELECT Id FROM Milestone1_Milestone__c WHERE Project__c = :dstProject.Id]) );
		
		// Check if milestones were moved
		system.assert( srcMilestoneSet.containsAll(dstMilestoneSet) );
		
		
		// Check if tasks were moved
		Integer dstTaskCount = [SELECT count() FROM Milestone1_Task__c WHERE Project_Milestone__c IN :milestonesWithTasks]; 
		system.assertEquals( 2 * 2 * 35, dstTaskCount );
    }
    
    static testmethod void testHighTopLevelMilestoneMove(){
		final Integer NUMBER_OF_MILESTONES = 400;

		Set<Id> srcMilestoneSet = new Set<Id>();
		Set<Id> dstMilestoneSet = new Set<Id>();

		Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
		
    	// Create projects
		List<Milestone1_Project__c> pList = new List<Milestone1_Project__c>();
		pList.add( Milestone1_Test_Utility.sampleProject('Src Project') ); 
		pList.add( Milestone1_Test_Utility.sampleProject('Dst Project') ); 

		insert pList;
    	
		// Create top-level milestones
    	Milestone1_Project__c         srcProject = pList.get(0); 
    	Milestone1_Project__c         dstProject = pList.get(1);
        List<Milestone1_Milestone__c> topList    = new List<Milestone1_Milestone__c>();

		for(Integer i = 0; i < NUMBER_OF_MILESTONES; i++){
	        topList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, null, 'Top Milestone' + i) );
		}
        
		try{
			insert topList;
			srcMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds(topList) ); 
		}
		catch(Exception e){
			system.assert(false, e.getMessage());
		}
		
		// Create one second level milestones on each top-level milestones
        List<Milestone1_Milestone__c> sndList = new List<Milestone1_Milestone__c>();

		for(Integer j = 0; j < NUMBER_OF_MILESTONES; j++){
        	sndList.add( Milestone1_Test_Utility.sampleMilestone(srcProject.Id, topList.get(j).Id, 'Milestone' + j) );
		}
        
		try{
			insert sndList;
		}
		catch(Exception e){
			system.assert(false, e.getMessage());
		}
		
        // Collect milestones and call move action
        ApexPages.StandardSetController stc = new ApexPages.StandardSetController(topList);
        stc.setSelected( topList );
        
        Milestone1_Move_Milestone_Extension cont = new Milestone1_Move_Milestone_Extension(stc);
        cont.dummyMS.Project__c = dstProject.Id;
        
        Test.startTest();
        cont.moveMilestones();
        Test.stopTest();
        
        srcMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds(topList) );
        srcMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds(sndList) );
		dstMilestoneSet.addAll( Milestone1_Test_Utility.extractMilestoneIds([SELECT Id FROM Milestone1_Milestone__c WHERE Project__c = :dstProject.Id]) );
		
		// Check if milestones were moved
		system.assert( srcMilestoneSet.containsAll(dstMilestoneSet) );
		system.assert( dstMilestoneSet.containsAll(srcMilestoneSet) );
    }    
    
    static testMethod void testMilestonesWithManyMilestonesClone(){
    	final Integer NUMBER_OF_MILESTONES = 1000;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        ms2.Alias__c = 'DCMTEST927';
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a few sub-milestones underneath ms2
        Map<String,Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestones(proj,ms2,NUMBER_OF_MILESTONES);
   		
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);
        Test.startTest();
        cont.createClone();
        Test.stopTest();
        
        Milestone1_Milestone__c ms2Clone = [SELECT Id,
                                                   Name,
                                                   Alias__c
                                            FROM Milestone1_Milestone__c
                                            WHERE ImportID__c = :ms2.Id
                                           ];
        System.assertNotEquals(null, ms2Clone);
        System.assertEquals(null, ms2Clone.Alias__c);
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT 
        												Id,ImportID__c,Name,Project__c,Complete__c,Kickoff__c,Deadline__c,
        												Description__c,Expense_Budget__c,Hours_Budget__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Parent_Milestone__c = :ms2Clone.Id
                                                    ];
        System.assertEquals(NUMBER_OF_MILESTONES, milestones2.size());
   
    }    
    
}