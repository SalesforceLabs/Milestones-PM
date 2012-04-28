/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Milestone1_XML_Import_Export_Tst {

    static testMethod void testProjectManyPredecessorMilestonesManyTasks() {
        final Integer NUMBER_OF_MILESTONES = 50;
	    final Integer NUMBER_OF_TASKS = 10;
	    final Integer NUMBER_OF_SUCCESSOR_MILESTONES = 10;
	    final Integer NUMBER_OF_SUCCESSOR_TASKS = 5;
	  	Document doc;
	    String projectXML;
	    
	    //create a project
	    Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('proj');
	    insert project;
	    
	    //create a many milestones underneath project
	    List<Milestone1_Milestone__c> milestones = Milestone1_Test_Utility.manyMilestones(project, null,NUMBER_OF_MILESTONES).values();
	    
	    //create a many successor milestones linked to the above created milestones.
	    Map<Milestone1_Milestone__c,List<Milestone1_Milestone__c>> successorMilestones=new Map<Milestone1_Milestone__c,List<Milestone1_Milestone__c>>();
	    for(Milestone1_Milestone__c predecessorMilestone:milestones){
	    	List<Milestone1_Milestone__c> successorMilestone = Milestone1_Test_Utility.manyMilestonesPredecessor(project,predecessorMilestone,NUMBER_OF_SUCCESSOR_MILESTONES).values();
	    	successorMilestones.put(predecessorMilestone,successorMilestone);
	    }
	    
	    //create tasks linked to milestones
	    List<Milestone1_Task__c> tasks;
	    for(Milestone1_Milestone__c mile:milestones)
	    	tasks = Milestone1_Test_Utility.manyTasks(mile,NUMBER_OF_TASKS).values();    
	    
	    //create successor tasks linked to the milestones
	    Map<Milestone1_Task__c,List<Milestone1_Task__c>> successorTasks=new Map<Milestone1_Task__c,List<Milestone1_Task__c>>();
	    for(Milestone1_Task__c task:tasks){
	    	List<Milestone1_Task__c> successorTask= Milestone1_Test_Utility.manyTasksPredecessor(task.Project_Milestone__c,task,NUMBER_OF_SUCCESSOR_TASKS).values();
	    	successorTasks.put(task,successorTask);
	    }
    }
    
   
}