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
private class Milestone1_Test_Import_Export {

    static testMethod void testProjectManyMilestonesManyTasksImportExport() {
         final Integer NUMBER_OF_MILESTONES = 50;
        final Integer NUMBER_OF_TASKS = 5;
        final Integer NUMBER_OF_SUCCESSOR_MILESTONES = 5;
        final Integer NUMBER_OF_SUCCESSOR_TASKS = 3;
        Document doc;
        String projectXML;
        
        //create a project
        Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('proj');
        insert project;
        
        //create a many milestones underneath project
        List<Milestone1_Milestone__c> milestones = manyMilestones(project, null,NUMBER_OF_MILESTONES);
        
        //create a predecessor milestones Linked to above milestones
        List<Milestone1_Milestone__c> successorMilestones = new List<Milestone1_Milestone__c>();//=manyMilestonesPredecessor(project,milestones[0],NUMBER_OF_SUCCESSOR_MILESTONES);
        Id projectId = project.Id; 
        for(Integer i = 0; i < NUMBER_OF_SUCCESSOR_MILESTONES; i++){
           Milestone1_Milestone__c milestone = Milestone1_Test_Utility.testSampleMilestone(projectId, milestones[0].id, 'ms'+i);
            successorMilestones.add(milestone);
        }
        insert successorMilestones;
        
        
        //create tasks linked to milestones
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.add(taskRec);
        }
        insert tasks;
        
        List<Milestone1_Task__c> successorTasks = new List<Milestone1_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_SUCCESSOR_TASKS; i++){
            Id parentMilestoneId = tasks[0].Project_Milestone__c;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId,tasks[0].id,Date.Today().addDays(3),Date.Today().addDays(4));
            successorTasks.add(taskRec);
        }
        insert successorTasks;
        
                
        //create export page controller and call export action
        ApexPages.StandardController stc = new ApexPages.StandardController(project);
        Milestone1_Export_Project_Controller exportProjectController = new Milestone1_Export_Project_Controller(stc);
        exportProjectController.createExportXML();
        doc = exportProjectController.doc;
        projectXML = String.valueOf(doc.Body.toString());  
        
        checkProject(project,projectXML);
        checkMilestones(milestones,projectXML);
        checkTasks(tasks,projectXML);
        
        //make some changes to it 
        modifyProject(project);
        modifyMilestones(milestones);
        modifyTasks(tasks);
        
        //call export action with the new 
        exportProjectController.createExportXML();
        doc = exportProjectController.doc;
        projectXML = String.valueOf(doc.Body.toString());  
        
        // validate
        checkProject(project,projectXML);
        checkMilestones(milestones,projectXML);
        checkSuccessorMilestones(successorMilestones,projectXML);
        checkTasks(tasks,projectXML);
        checkSuccessorTasks(successorTasks,projectXML);
        
        //make some changes to it 
        modifyProject(project);
        modifyMilestones(milestones);
        modifyTasks(tasks);
        
        //delete project 
        stc.delete();
        
        //create import page controller and call import action
        Milestone1_Import_Project_Controller importProjectController = new Milestone1_Import_Project_Controller(null);
        importProjectController.docId = doc.Id;
        importProjectController.importTemplateXML();
        projectXML= importProjectController.getDocumentXMLString();
        
        // validate 
        checkProject(project,projectXML);
        checkMilestones(milestones,projectXML);
        checkSuccessorMilestones(successorMilestones,projectXML);
        checkTasks(tasks,projectXML);
        checkSuccessorTasks(successorTasks,projectXML);
        
    }
    
    /**
    *   Create a batch of milestones
    */
    private static List<Milestone1_Milestone__c> manyMilestones(Milestone1_Project__c project,
                                                                Milestone1_Milestone__c parentMilestone, Integer size){
        Milestone1_Milestone__c milestone;
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        Id projectId,parentMilestoneId;
        if(project != null){
            projectId = project.Id; 
        }
        if(parentMilestone !=  null){
            parentMilestoneId = milestone.Id;
        }
        for(Integer i = 0; i < size; i++){
            milestone = Milestone1_Test_Utility.sampleMilestone(projectId, parentMilestoneId, 'ms'+i);
            milestones.add(milestone);
        }
        insert milestones;
        return milestones;  
    }
     
   
    
    /**
    *   Check the fields of the project match in the xml.
    */
    private static void checkProject(Milestone1_Project__c project,String xml){
        System.assert(checkField(project,'Id',xml), assertMessage('Id',String.valueOf(project.Id)));
        System.assert(checkField(project,'Total_Hours_Budget__c',xml), assertMessage('Total_Hours_Budget__c',String.valueOf(project.Total_Hours_Budget__c)));
        System.assert(checkField(project,'Total_Expense_Budget__c',xml), assertMessage('Total_Expense_Budget__c',String.valueOf(project.Total_Expense_Budget__c)));
        System.assert(checkField(project,'Status__c',xml), assertMessage('Status__c',String.valueOf(project.Status__c)));
        System.assert(checkField(project,'Description__c',xml), assertMessage('Description__c',String.valueOf(project.Description__c)));
        System.assert(checkField(project,'Name',xml),assertMessage('Name',String.valueOf(project.Name)));       
    }
    
    /**
    *   Check the fields of the milestone match in the xml.
    */
    private static void checkMilestones(List<Milestone1_Milestone__c> milestones,String xml){
        for(Milestone1_Milestone__c milestone : milestones){
            System.assert(checkField(milestone,'Id',xml), assertMessage('Id',String.valueOf(milestone.Id))); 
            System.assert(checkField(milestone,'Description__c',xml), assertMessage('Description__c',String.valueOf(milestone.Description__c))); 
            System.assert(checkField(milestone,'Expense_Budget__c',xml), assertMessage('Expense_Budget__c',String.valueOf(milestone.Expense_Budget__c))); 
            System.assert(checkField(milestone,'Hours_Budget__c',xml), assertMessage('Hours_Budget__c',String.valueOf(milestone.Hours_Budget__c))); 
            System.assert(checkField(milestone,'Name',xml), assertMessage('Name',String.valueOf(milestone.Name))); 
            System.assert(checkField(milestone,'Alias__c',xml), assertMessage('Alias__c',String.valueOf(milestone.Alias__c)));  
        }       
    }
    
    /**
    *   Check the fields of the milestone match in the xml.
    */
    private static void checkSuccessorMilestones(List<Milestone1_Milestone__c> milestones,String xml){
        for(Milestone1_Milestone__c milestone : milestones){
            System.assert(checkField(milestone,'Id',xml), assertMessage('Id',String.valueOf(milestone.Id))); 
            System.assert(checkField(milestone,'Description__c',xml), assertMessage('Description__c',String.valueOf(milestone.Description__c))); 
            System.assert(checkField(milestone,'Kickoff__c',xml), assertMessage('Kickoff__c',String.valueOf(milestone.Kickoff__c))); 
            System.assert(checkField(milestone,'Deadline__c',xml), assertMessage('Deadline__c',String.valueOf(milestone.Deadline__c))); 
            System.assert(checkField(milestone,'Name',xml), assertMessage('Name',String.valueOf(milestone.Name))); 
            System.assert(checkField(milestone,'Predecessor_Milestone__c',xml), assertMessage('Predecessor_Milestone__c',String.valueOf(milestone.Predecessor_Milestone__c)));
            System.assert(checkField(milestone,'Alias__c',xml), assertMessage('Alias__c',String.valueOf(milestone.Alias__c)));  
        }       
    }
    
    /**
    *   Check the fields of the task match in the xml.
    */
    private static void checkTasks(List<Milestone1_Task__c> tasks,String xml){
        for(Milestone1_Task__c task : tasks){
            System.assert(checkField(task,'Id',xml), assertMessage('Id',String.valueOf(task.Id))); 
            System.assert(checkField(task,'Description__c',xml), assertMessage('Description__c',String.valueOf(task.Description__c))); 
            System.assert(checkField(task,'Estimated_Hours__c',xml), assertMessage('Estimated_Hours__c',String.valueOf(task.Estimated_Hours__c))); 
            System.assert(checkField(task,'Estimated_Expense__c',xml), assertMessage('Estimated_Expense__c',String.valueOf(task.Estimated_Expense__c))); 
            System.assert(checkField(task,'Name',xml), assertMessage('Name',String.valueOf(task.Name)));    
        }       
    }
    
     /**
    *   Check the fields of the task match in the xml.
    */
    private static void checkSuccessorTasks(List<Milestone1_Task__c> tasks,String xml){
        for(Milestone1_Task__c task : tasks){
            System.assert(checkField(task,'Id',xml), assertMessage('Id',String.valueOf(task.Id))); 
            System.assert(checkField(task,'Description__c',xml), assertMessage('Description__c',String.valueOf(task.Description__c))); 
            System.assert(checkField(task,'Start_Date__c',xml), assertMessage('Start_Date__c',String.valueOf(task.Start_Date__c))); 
            System.assert(checkField(task,'Due_Date__c',xml), assertMessage('Due_Date__c',String.valueOf(task.Due_Date__c))); 
            System.assert(checkField(task,'Predecessor_Task__c',xml), assertMessage('Predecessor_Task__c',String.valueOf(task.Predecessor_Task__c))); 
            System.assert(checkField(task,'Name',xml), assertMessage('Name',String.valueOf(task.Name)));    
        }       
    }
    
    /**
    *   Modify some fields values in the project
    */
    private static void modifyProject(Milestone1_Project__c project){
        Date today = Date.today();
        project.Description__c = String.valueOf(today);
        project.Name = String.valueOf(today);
        update project;
    }
    
     
    /**
    *   Modify some fields values in the milestones list
    */
    private static void modifyMilestones(List<Milestone1_Milestone__c> milestones){
        Date today = Date.today();
        for(Milestone1_Milestone__c milestone : milestones){
            milestone.Description__c = String.valueOf(today);
            milestone.Name = String.valueOf(today); 
        }
        update milestones;
    }
    
     
    /**
    *   Modify some fields values in the tasks list.
    */
    private static void modifyTasks(List<Milestone1_Task__c> tasks){
        Date today = Date.today();
        for(Milestone1_Task__c task : tasks){
            task.Description__c = String.valueOf(today);
            task.Name = String.valueOf(today);  
        }
        update tasks;
    }
    
    /**
    *   Check if the field value of the Sobject named myObject match in the xml.
    */
    private static Boolean checkField(Sobject myObject,String field,String xml){
        String fieldValue = String.valueOf(myObject.get(field));
        return fieldValue == null || xml.indexOf(EncodingUtil.urlEncode(fieldValue,'UTF-8')) > 0;
    }
    
    /**
    *   Generate an assert message with parameters.
    */
    private static String assertMessage(String param1,String param2){
        if(param2 == null){
            param2 = '';
        }
        return 'error in '+param1+' fieldName with value '+param2;
    }
}