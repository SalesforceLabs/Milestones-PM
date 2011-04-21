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
public with sharing class Milestone1_XML_Export_Utility {
    
    private Milestone1_Project__c project;
    private List<Milestone1_Milestone__c>  milestones;
    private Map<ID,Milestone1_Milestone__c>  milestonesMap;
    private List<Milestone1_Task__c> milestonesTasks;
    private Map<ID,Milestone1_Task__c> milestonesTasksMap;
    private List<Milestone1_Milestone__c>  subMilestones;
    private Map<ID,Milestone1_Milestone__c>  subMilestonesMap;
    private List<Milestone1_Task__c> subMilestonesTasks;
    private Map<ID,Milestone1_Task__c> subMilestonesTasksMap;
    
    public Milestone1_XML_Export_Utility()
    {
        milestonesMap = new Map<ID,Milestone1_Milestone__c>();
        milestonesTasksMap = new Map<ID,Milestone1_Task__c>();
        subMilestonesMap= new Map<ID,Milestone1_Milestone__c>();
        subMilestonesTasksMap = new Map<ID,Milestone1_Task__c>();
    }

    public Milestone1_Project__c lookup(ID targetId) {
        Milestone1_Project__c project = [Select m.Kickoff__c,m.Deadline__c, m.Total_Hours_Budget__c, m.Total_Expense_Budget__c, m.Status__c, m.Name, m.Id, m.Description__c From Milestone1_Project__c m where Id = :targetId limit 1];
        //Retrieve all the Milestones
        milestones = [Select m1.Id, m1.Name, m1.Alias__c, m1.Deadline__c, m1.Kickoff__c, m1.Complete__c,m1.Description__c, m1.Expense_Budget__c,  m1.Project__c, m1.Hours_Budget__c From Milestone1_Milestone__c m1 where Project__c = :project.Id and Parent_Milestone__c = null];
        for(Milestone1_Milestone__c milestone : milestones)
        {
            milestonesMap.put(milestone.Id,milestone);
        }
        //Retrieve all the Sub-Milestones
        subMilestones = [Select m1.Id, m1.Name,  m1.Alias__c, m1.Deadline__c, m1.Kickoff__c, m1.Complete__c,m1.Description__c, m1.Expense_Budget__c,  m1.Project__c, m1.Hours_Budget__c, Parent_Milestone__c From Milestone1_Milestone__c m1 where Parent_Milestone__c in :milestonesMap.keySet()];
        for(Milestone1_Milestone__c subMilestone : subMilestones)
        {
            subMilestonesMap.put(subMilestone.Id,subMilestone);
        }
        //Retrieve all the Milestone Tasks
        milestonesTasks = [Select m.Id, m.Name, m.Description__c, m.Estimated_Hours__c, m.Estimated_Expense__c, m.Start_Date__c, m.Due_Date__c, m.Priority__c, m.Project_Milestone__c, m.Complete__c From Milestone1_Task__c m where m.Project_Milestone__c in : milestonesMap.keySet()];
        for(Milestone1_Task__c task : milestonesTasks)
        {
            milestonesTasksMap.put(task.Id,task);
        }
        //Retreive all the Sub Miltestone Tasks
        submilestonesTasks = [Select m.Id, m.Name, m.Description__c, m.Estimated_Hours__c, m.Estimated_Expense__c,m.Start_Date__c, m.Due_Date__c, m.Priority__c, m.Project_Milestone__c ,m.Complete__c From Milestone1_Task__c m where m.Project_Milestone__c in : subMilestonesMap.keySet()];
        for(Milestone1_Task__c task : submilestonesTasks)
        {
            subMilestonesTasksMap.put(task.Id,task);
        }
      
        return project;
    }
    
    public String buildProjectXmlString(ID targetId) {
        project = lookup(targetId);
        Xmlstreamwriter out = new Xmlstreamwriter();
        
        out.writeStartDocument(null,Milestone1_Constants.XML_VERSION);
        
        out.writeStartElement(null, Milestone1_Constants.XML_EXPORT, null);
        out.writeStartElement(null, Milestone1_Constants.XML_META, null);
        
        writeElement(out, Milestone1_Constants.XML_EXPORT_PACKAGE, Milestone1_Constants.XML_EXPORT_PACKAGE_VAL);
        writeElement(out, Milestone1_Constants.XML_EXPORT_AUTHOR, UserInfo.getName());
        writeElement(out, Milestone1_Constants.XML_EXPORT_ORG, UserInfo.getOrganizationName());     
        writeElement(out, Milestone1_Constants.XML_EXPORT_DATE, System.now());
        writeElement(out, Milestone1_Constants.XML_EXPORT_VERSION,Milestone1_Constants.XML_EXPORT_VERSION_VAL);
        
        out.writeEndElement();
        
        writeProjectToXML(out,project);

        out.writeEndDocument();
        String ret = out.getXmlString();
        out.close();
        system.debug('Exit <buildXmlString(Milestone1_Project__c target)> in class <Milestone1_XML_Export_Utility> return string == \n ' + ret);
        return ret;
    }

    void writeProjectToXML(XMLstreamwriter out, Milestone1_Project__c project )
    {
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_PROJECT, null);
        writeElement(out,'Id',project.Id);
        writeElement(out,'Total_Hours_Budget__c',project.Total_Hours_Budget__c);
        writeElement(out,'Total_Expense_Budget__c', project.Total_Expense_Budget__c);
        writeElement(out,'Status__c', project.Status__c);
        writeElement(out,'Description__c', Project.Description__c);
        writeElement(out,'Name', Project.Name);
        for(Milestone1_Milestone__c milestone : milestones)
        {
            writeMilestoneToXML(out,milestone,true);
        }
        out.writeEndElement();  
    }
    
    void writeMilestoneToXML(XMLstreamwriter out, Milestone1_Milestone__c milestone, Boolean isParentMilestone )
    {
        List<Milestone1_Task__c> tasks;
        if(isParentMilestone)
        {
            tasks = this.milestonesTasks;
        }else
        {
            tasks = this.subMilestonesTasks;
        }
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_MILESTONE, null);
        writeElement(out,'Id', milestone.Id);
        writeElement(out,'Description__c',milestone.Description__c);
        writeElement(out,'Expense_Budget__c',milestone.Expense_Budget__c);
	    writeElement(out,'Hours_Budget__c', milestone.Hours_Budget__c);
        writeElement(out,'Name', milestone.Name);
        writeElement(out,'Alias__c',milestone.Alias__c);
        for(Milestone1_Task__c task : tasks)
        {
            if(task.Project_Milestone__c == milestone.Id)
            {
                writeTaskToXML(out,task);
            }
        }
        for(Milestone1_Milestone__c subMilestone : subMilestones)
        {
            if(isParentMilestone && subMilestone.Parent_Milestone__c == milestone.Id)
            {
                writeMilestoneToXML(out,subMilestone,false);
            }
        }
        out.writeEndElement();  
    }
    
    
    void writeTaskToXML(XMLstreamwriter out, Milestone1_Task__c task ){
        out.writeStartElement(null, Milestone1_Constants.OBJ_NAME_TASK, null);
        writeElement(out,'Id', task.Id);
        writeElement(out,'Description__c',task.Description__c);
        writeElement(out,'Name',task.Name);
        writeElement(out,'Estimated_Hours__c',task.Estimated_Hours__c);
        writeElement(out,'Estimated_Expense__c',task.Estimated_Expense__c);
        
        out.writeEndElement();  
    }
	
    void writeElement(Xmlstreamwriter out, String tag, Object content) {
    if(content != null){
            out.writeStartElement(null, tag, null);
        	out.writeCharacters(EncodingUtil.urlEncode(String.valueOf(content), 'UTF-8'));
        	out.writeEndElement();
        }  
    }
    
    
}