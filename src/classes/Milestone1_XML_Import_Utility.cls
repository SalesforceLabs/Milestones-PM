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
global with sharing class Milestone1_XML_Import_Utility {
    
   global with sharing class XML_Metadata {
     String ExportVersion; 
     String ExportAuthor;
     String ExportPackage;
     String ExportOrganization;
     DateTime ExportCreateDate;
   }
    
    Milestone1_Project__c project;
    List<Milestone1_Milestone__c> milestones;
    List<Milestone1_Milestone__c> subMilestones;
    /**
      *Bug # 44.
      *Modified Date:04-18-2012.
      *Owner: Persistent.
      *Comments:Importing the project with all the relationships intact.
    */
    List<Milestone1_Milestone__c> successorsList;
    List<Milestone1_Task__c> tasks;
    List<Milestone1_Task__c> subTasks;
    List<Milestone1_Time__c> times;
    XML_Metadata metadata = new XML_Metadata();

    global Milestone1_XML_Import_Utility()
    {
        project = new Milestone1_Project__c();
        milestones = new List<Milestone1_Milestone__c>();
        subMilestones = new List<Milestone1_Milestone__c>();
        /**
      	 *Bug # 44.
      	 *Modified Date:04-18-2012.
       	 *Owner: Persistent.
         *Comments:Importing the project with all the relationships intact.
        */
        successorsList=new List<Milestone1_Milestone__c>();
        tasks = new List<Milestone1_Task__c>();
        subTasks = new List<Milestone1_Task__c>();
        times = new List<Milestone1_Time__c>();
    }
    
    global Milestone1_Project__c importProject(String xml) {

        Savepoint sp = Database.setSavepoint();
        try{
            /*
             * TEST FLS CREATE
             */ 
            Map<DescribeSObjectResult, Set<String>> flsMap = new Map<DescribeSObjectResult, Set<String>>();
            flsMap.put(
                Milestone1_Project__c.SObjectType.getDescribe(),
                new Set<String>{
                    'Status__c',
                    'Total_Expense_Budget__c',
                    'Total_Hours_Budget__c',
                    'Description__c',
                    'ImportId__c',
                    'Name'
                }
            );
            flsMap.put(
                Milestone1_Milestone__c.SObjectType.getDescribe(),
                new Set<String>{
                    'Name',
                    'Predecessor_Milestone__c',
                    'Parent_Milestone__c',
                    'ImportID__c',
                    'Hours_Budget__c',
                    'Expense_Budget__c',
                    'Description__c',
                    'Project__c',
                    'Deadline__c',
                    'Kickoff__c'
                }
            );
            flsMap.put(
                Milestone1_Task__c.SObjectType.getDescribe(),
                new Set<String>{
                    'Predecessor_Task__c',
                    'ImportID__c',
                    'Estimated_Hours__c',
                    'Estimated_Expense__c',
                    'Description__c',
                    'Project_Milestone__c',
                    'Name',
                    'Due_Date__c',
                    'Start_Date__c'
                }
            );
            flsMap.put(
                Milestone1_Time__c.SObjectType.getDescribe(),
                new Set<String>{
                    'Project_Task__c',
                    'ImportID__c',
                    'Hours__c',
                    'Description__c'
                }
            );
            
            for (DescribeSObjectResult dsr : flsMap.keySet()) {
                Milestone1_Security_Utility.fieldsCreateable(
                    dsr, flsMap.get(dsr));
            }
            /*
             * END TEST FLS CREATE
             */ 
            
            Xmlstreamreader reader = new Xmlstreamreader(xml);
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META) {
                //System.debug(LoggingLevel.warn, 'Parse XML Metadata');
                	parseMeta(reader);
                }
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT) {
                //System.debug(LoggingLevel.warn, 'Parse XML Project');
                	parseProject(reader);
                }
                reader.next();
            }
            insertSalesforceObjects();
        } catch(Exception ex) {
        	Database.rollback(sp);
        	throw ex;
        //throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_INVALID_XML);
		}
        return project;
    }

    private void insertSalesforceObjects()
    {
        //System.debug('Number of Milestones: ' + this.milestones.size());
        //System.debug('Number of Tasks: ' + this.tasks.size());
        
        
        if(project == null || project.Name == null || project.ImportID__c == null || project.ImportID__c.length() < 15)
        {
            throw new Milestone1_Import_Exception(system.label.Milestone1_ProjectCannotBeNull);
        }
        
        //attempt to validate 10 variations of the name
        String targetName = '%' + project.Name + '%';
        Integer existingLikeName = [Select Count() from Milestone1_Project__c where Name LIKE :targetName];
        
        if(existingLikeName!=null && existingLikeName > 0)
        {
            if (Schema.sObjectType.Milestone1_Project__c.fields.Name.isCreateable() && 
                Schema.sObjectType.Milestone1_Project__c.fields.Name.isUpdateable()) {
            	project.Name = project.Name + ' Copy ' + (existingLikeName +1);
            } else {
                throw new Milestone1_Exception('Insufficient Privileges');
            }
        }
        
        if (Schema.sObjectType.Milestone1_Project__c.isCreateable()) {
        	insert project;
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}
        
	    for(Milestone1_Milestone__c currentMilestone : milestones)
	        {
	            currentMilestone.Project__c = project.Id;
	            if(currentMilestone.Predecessor_Milestone__c!=null)
	            	{
	            		successorsList.add(currentMilestone);
                        Milestone1_Security_Utility.fieldCreateable(
            				Milestone1_Milestone__c.Predecessor_Milestone_Import_Id__c.getDescribe());
	            		currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
                        Milestone1_Security_Utility.fieldCreateable(
            				Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe());
	            		currentMilestone.Predecessor_Milestone__c=null;
	            	}
	        }
        
        if (Schema.sObjectType.Milestone1_Milestone__c.isCreateable()) {
        	insert milestones;
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}
        
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            Milestone1_Security_Utility.fieldCreateable(
            	Milestone1_Milestone__c.Project__c.getDescribe());
            currentMilestone.Project__c = project.Id;
            matchMilestonesToMilestones(subMilestones,currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone : subMilestones)
        if(currentMilestone.Predecessor_Milestone__c != null)
	    {
	    	successorsList.add(currentMilestone);
            Milestone1_Security_Utility.fieldCreateable(
            	Milestone1_Milestone__c.Predecessor_Milestone_Import_Id__c.getDescribe());
            Milestone1_Security_Utility.fieldCreateable(
            	Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe());
	        currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
	        currentMilestone.Predecessor_Milestone__c=null;
	    }
        
        if (Schema.sObjectType.Milestone1_Milestone__c.isCreateable()) {
	    	insert subMilestones;
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}
        
        /*
        for(Milestone1_Milestone__c currentMilestone : milestones){
        	updatePredecessorMilestones(currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone: subMilestones){
        	updatePredecessorMilestones(currentMilestone);
        }
        
		update successorsList;
		*/
        //System.debug('NUMBER OF TASKS == ' + tasks.size());
        for(Milestone1_Task__c currentTask : tasks)
        {
            //System.debug('Task Parent Milestone ID == ' + currentTask.Project_Milestone__c);
            Boolean foundMatch = false;
            foundMatch = matchTaskToMilestone(milestones,currentTask);
            foundMatch = matchTaskToMilestone(subMilestones,currentTask);
        }
        
        for(Milestone1_Task__c currentTask : tasks)
        {
            Milestone1_Security_Utility.fieldCreateable(
            	Milestone1_Task__c.Predecessor_Task_Import_Id__c.getDescribe());
            Milestone1_Security_Utility.fieldCreateable(
            	Milestone1_Task__c.Predecessor_Task__c.getDescribe());
        	currentTask.Predecessor_Task_Import_Id__c=currentTask.Predecessor_Task__c;
        	currentTask.Predecessor_Task__c=null;
        }

        if (Schema.sObjectType.Milestone1_Task__c.isCreateable()) {
        	insert tasks;
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}

        system.debug('tasks'+tasks);
        /*
        for(Milestone1_Task__c currentTask : tasks){
        	matchTaskToTask(currentTask);
        }
        update subtasks;
        system.debug('subtasks'+subtasks);
        */
        for(Milestone1_Time__c currentTime : times){
        	matchTimetoTask(tasks,currentTime);
        }
        if (Schema.sObjectType.Milestone1_Time__c.isCreateable()) {
        	insert times;
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}
    }
    /*
    global void updatePredecessorMilestones(Milestone1_Milestone__c currentMilestone){
    	
    	for(Milestone1_Milestone__c milestone:successorsList){
    		
    		if(milestone.Predecessor_Milestone_Import_Id__c==currentMilestone.ImportID__c)
    			{
    				milestone.Predecessor_Milestone__c=currentMilestone.Id;
    			    milestone.Project__c = currentMilestone.Project__c;
    			}
    	}
    }
    */
    global void matchMilestonesToMilestones(List<Milestone1_Milestone__c> milestones, Milestone1_Milestone__c currentMilestone){
        for(Milestone1_Milestone__c currentSubMilestone : milestones)
        {
            if(currentSubMilestone.Parent_Milestone__c == currentMilestone.ImportID__c)
            {
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Parent_Milestone__c.getDescribe());
                currentSubMilestone.Parent_Milestone__c = currentMilestone.Id;
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Project__c.getDescribe());
                currentSubMilestone.Project__c = currentMilestone.Project__c;
            }
        }
    }

    global Boolean matchTaskToMilestone(List<Milestone1_Milestone__c> milestones, Milestone1_Task__c currentTask){
        for(Milestone1_Milestone__c currentMilestone : milestones){
            if(currentTask.Project_Milestone__c == currentMilestone.ImportID__c){
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Project_Milestone__c.getDescribe());
                currentTask.Project_Milestone__c = currentMilestone.Id;
                return true;
            }
        }
        return false;
    }
    /*
	global void matchTaskToTask(Milestone1_Task__c currentTask){
		for(Milestone1_Task__c task:subTasks){
			 if(task.Predecessor_Task_Import_Id__c==currentTask.ImportID__c){
                 task.Predecessor_Task__c=currentTask.id;
             }
		}
	}
    */
	global Boolean matchTimeToTask(List<Milestone1_Task__c> tasks, Milestone1_Time__c currentTime) {
        for(Milestone1_Task__c currentTask : tasks) {
            if(currentTime.Project_Task__c == currentTask.ImportID__c) {
                Milestone1_Security_Utility.fieldCreateable(
                    Milestone1_Time__c.Project_Task__c.getDescribe());
            	currentTime.Project_Task__c = currentTask.Id;
            	return true;
            }
        }
        return false;
	}

    global void parseProject(Xmlstreamreader reader) {
        //name goes to name
        //id goes to importid
        //System.debug(LoggingLevel.warn, 'in Project');
        while (reader.hasNext()) {
            //handle name field
            //system.debug(reader.getLocalName());
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                //system.debug('Processing Project Name');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.Name.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.Name.isUpdateable()) {
                    project.Name = getDecodedString(reader);
                    if (project.Name.length() == 0) {
                        throw new Milestone1_Import_Exception(system.label.Milestone1_InvalidName);
                    }
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                //system.debug('Processing Project Desc');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.Description__c.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.Description__c.isUpdateable()) {
                	project.Description__c = getDecodedString(reader);
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Hours_Budget__c') {
                //system.debug('Processing Project Est');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.Total_Hours_Budget__c.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.Total_Hours_Budget__c.isUpdateable()) {
                    String val = getDecodedString(reader);
                    if(val == null || val == 'null') {
                        val = '0.0';
                    }
                    project.Total_Hours_Budget__c = Decimal.valueOf(val);
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Expense_Budget__c') {
                //system.debug('Processing Project Budg');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.Total_Expense_Budget__c.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.Total_Expense_Budget__c.isUpdateable()) {
                    String val = getDecodedString(reader);
                    if(val == null || val == 'null') {
                        val = '0.0';
                    }
                    project.Total_Expense_Budget__c = Decimal.valueOf(val);
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
                
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Status__c') {
                //system.debug('Processing Project Stat');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.Status__c.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.Status__c.isUpdateable()) {
                	project.Status__c = getDecodedString(reader);
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                //system.debug('Processing Project Milestone');
                reader.next();
                parseMilestone(reader,null);
            }
            //handle import id field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                //System.debug(LoggingLevel.warn, 'in id');
                reader.next();
                if (Schema.sObjectType.Milestone1_Project__c.fields.ImportId__c.isCreateable() && 
                    Schema.sObjectType.Milestone1_Project__c.fields.ImportId__c.isUpdateable()) {
                    project.ImportId__c = getDecodedString(reader);
                    //system.debug('Import ID == ' + project.ImportID__c);
                    if (project.ImportId__c.length() > 15) {
                        project.ImportId__c = project.ImportId__c.substring(0,15);
                    }
                    if (project.ImportId__c.length() != 15) {
                        throw new Milestone1_Import_Exception('Invalid Import ID (length must be 15)');
                    }
                } else {
                    throw new Milestone1_Exception('Insufficient Privileges');
                }
            }
            //validate that we're done
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT){
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
    }
    
    global void parseMilestone(Xmlstreamreader reader, Milestone1_Milestone__c parentMilestone)
    {
        
        Milestone1_Milestone__c currentMilestone = new Milestone1_Milestone__c();
        if(parentMilestone != null)
        {
            //System.debug(LoggingLevel.warn, 'in SUB Milestone');
            Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Parent_Milestone__c.getDescribe());
            currentMilestone.Parent_Milestone__c = parentMilestone.ImportID__c;
        }else
        {
            //System.debug(LoggingLevel.warn, 'in Milestone');
        }
        Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Project__c.getDescribe());
        currentMilestone.Project__c = project.ImportID__c;
        
        while (reader.hasNext()){
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.ImportID__c.getDescribe());
                currentMilestone.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Name.getDescribe());
                currentMilestone.Name = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Expense_Budget__c') {
                reader.next();
                
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
                    val = '0.0';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Expense_Budget__c.getDescribe());
                currentMilestone.Expense_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Description__c.getDescribe());
                currentMilestone.Description__c = getDecodedString(reader);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours_Budget__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
                    val = '0.0';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Hours_Budget__c.getDescribe());
                currentMilestone.Hours_Budget__c = Decimal.valueOf(val);
            }
            /**
              *Bug # 44.
              *Modified Date:04-18-2012.
              *Owner: Persistent.
              *Comments:Importing the project with all the relationships intact.
            */
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Milestone__c'){
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe());
                currentMilestone.Predecessor_Milestone__c =getDecodedString(reader);
               
             }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Kickoff__c'){
                reader.next();
                
                String val=getDecodedString(reader);
                if(val == null || val == 'null') {
                    val= '';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Kickoff__c.getDescribe());
                currentMilestone.Kickoff__c=date.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Deadline__c'){
                reader.next();
                
                String val=getDecodedString(reader);
                if(val == null || val == 'null') {
                    val= '';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Milestone__c.Deadline__c.getDescribe());
                currentMilestone.Deadline__c=date.valueOf(val);
                
            }
          
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                //system.debug('Processing Sub Milestone');
                reader.next();
                parseMilestone(reader,currentMilestone);
            }
           
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK) {
                //system.debug('Processing Sub Tasks');
                reader.next();
                parseTask(reader,currentMilestone);
            }
            //system.debug('Current Milestone ---- Name == ' + currentMilestone.Name + ' ImportID__c ' + currentMilestone.ImportID__c + ' Expense Budget ' + currentMilestone.Expense_Budget__c + ' Nag ' + currentMilestone.Nag__c + ' Description ' + currentMilestone.Description__c + ' Hours Budget ' + currentMilestone.Hours_Budget__c);
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
        if(parentMilestone != null)
        {
            subMilestones.add(currentMilestone);
        }else
        {
            milestones.add(currentMilestone);
        }
    }
    
    global void parseTask(XMLStreamreader reader, Milestone1_Milestone__c currentMilestone){
        Milestone1_Task__c currentTask = new Milestone1_Task__c();
        Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Project_Milestone__c.getDescribe());
        currentTask.Project_Milestone__c = currentMilestone.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.ImportID__c.getDescribe());
                currentTask.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Description__c.getDescribe());
                currentTask.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Name.getDescribe());
                currentTask.Name = getDecodedString(reader);
                if(currentTask.Name == null){
                    system.debug('Name is NULL ');
                    Milestone1_Security_Utility.fieldCreateable(
            			Milestone1_Task__c.Name.getDescribe());
                    currentTask.Name = 'Name Blank';
                }
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Hours__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
					val = '0.0';                    
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Estimated_Hours__c.getDescribe());
                currentTask.Estimated_Hours__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Expense__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
                    val = '0.0';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Estimated_Expense__c.getDescribe());
                currentTask.Estimated_Expense__c = Decimal.valueOf(val);
            }
            /**
              *Bug # 44.
              *Modified Date:04-18-2012.
              *Owner: Persistent.
              *Comments:Importing the project with all the relationships intact.
            */
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Task__c') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Predecessor_Task__c.getDescribe());
                currentTask.Predecessor_Task__c=getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Project_Milestone__c') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Project_Milestone__c.getDescribe());
                currentTask.Project_Milestone__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Start_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
                     val='';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Start_Date__c.getDescribe());
                currentTask.Start_Date__c=date.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Due_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null') {
                    val='';
                }
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Task__c.Due_Date__c.getDescribe());
                currentTask.Due_Date__c = date.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME) {
                //system.debug('Processing Sub Milestone');
                reader.next();
                parseTime(reader,currentTask);
            }
            
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
        
        if( currentTask.Predecessor_Task__c != null)
        {
             subTasks.add(currentTask);
        }
        tasks.add(currentTask);
    }
    
    global void parseTime(XMLStreamreader reader, Milestone1_Task__c currentTask){
        Milestone1_Time__c currentTime = new Milestone1_Time__c();
        Milestone1_Security_Utility.fieldCreateable(
            Milestone1_Time__c.Project_Task__c.getDescribe());
        currentTime.Project_Task__c = currentTask.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Time__c.ImportID__c.getDescribe());
                currentTime.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                Milestone1_Security_Utility.fieldCreateable(
            		Milestone1_Time__c.Description__c.getDescribe());
                currentTime.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val != null || val != 'null') {
                    Milestone1_Security_Utility.fieldCreateable(
            			Milestone1_Time__c.Hours__c.getDescribe());
                    currentTime.Hours__c = Decimal.valueOf(val);
                }
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
        times.add(currentTime);
    }
    
    global void parseMeta(Xmlstreamreader reader) {
        //system.debug('Process Metadata');
        while (reader.hasNext()) {
            //handle name field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_VERSION) {
                reader.next();
                metadata.ExportVersion = getDecodedString(reader);
                //system.debug('Version == ' + metadata.ExportVersion);
                //system.debug('Org Version == ' + Milestone1_Constants.XML_EXPORT_VERSION_VAL);
                if(metadata.ExportVersion != Milestone1_Constants.XML_EXPORT_VERSION_VAL)
                {
                    //system.debug('Throw the Exception');
                    throw new Milestone1_Import_Exception(system.label.Milestone1_InvalidVersion + metadata.ExportVersion + system.label.Milestone1_OrganizationsVersion + Milestone1_Constants.XML_EXPORT_VERSION_VAL + system.label.Milestone1_ProjectsMustBeExported);
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_PACKAGE) {
                reader.next();
                metadata.ExportPackage = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_AUTHOR) {
                reader.next();
                metadata.ExportAuthor = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_ORG) {
                reader.next();
                metadata.ExportOrganization = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_DATE) {
                reader.next();
                metadata.ExportCreateDate = DateTime.valueOf(getDecodedString(reader));
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
    }
    
    global String getDecodedString(Xmlstreamreader reader) {
        return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
    }

}