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
public with sharing class Milestone1_Charts_GanttController {

    public String mytarget {get; 
    	set{
    		this.mytarget = value;
    		init();
    	}
    	}
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 	public String projectGanttJson{get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
    
    
    private List<Sobject> sobjectList;
    private static final String REGEXP_QUOTES    = '(?<!\\\\)"';
    
    public static final String COLOR_COMPLETE = '#333333';
    public static final String COLOR_LATE = '#ee3322';
    public static final String COLOR_FUTURE = '#666666';
    public static final String COLOR_CURRENT = '#2299bb';
    
    public Milestone1_Charts_GanttController()
    {
    	init();
    }
    
    private void init()
    {
    	if (myTarget != null)
    	{
         initFieldNames();
       	 retrieveData();
        projectGanttJson = toJSon();
        
    	}
    }
    
    public String getProjectGanttJson() {
        
        init();
        return projectGanttJson;
    }
    
    /*
    * 	Initialize the variables depending on the object type possible values: 
    * 	Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
    	if(mytarget != null){
    		if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){
	    		/*startDateFieldName = 'Kickoff__c';
	    		endDateFieldName = 'Deadline__c';
	    		nameFieldName = 'NameClean__c';
	    		filterFieldName = 'Project__c';*/
	    		
	    		startDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
				endDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
	    		nameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
	    		filterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();
	    			    		
	    		//objectType = 'Milestone1_Milestone__c';
	    		objectType = Schema.SObjectType.Milestone1_Milestone__c.getName();
	    	}else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){

	    		startDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
				endDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
	    		nameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
	    		filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
	    			    		
	    		objectType = Schema.SObjectType.Milestone1_Task__c.getName();
	    	} else {
	    		throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
	    	}
	    	idFieldName = 'Id';
	    	completedFieldName = 'Complete__c';	
    	}
    }
    
    /*
    * 	Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
    	
    	String query = 'Select '+idFieldName+','+startDateFieldName+','+endDateFieldName+','+nameFieldName+','+completedFieldName+
    				   ' from '+objectType+ ' where '+filterFieldName+'=\''+mytarget+'\' order by Name';
    	sobjectList = Database.query(query);
    }
    
    /**
    *	Generate the output in json format to be rendered in the jquery gantt.
    */
    private String toJSon(){
    	
    	String ret = 'var ganttData' +mytarget + ' = [{id: 1, name: "", series: [';
    	Boolean addComma=false,completed;
    	Date startDate,endDate;
    	String name,id;
        for (Sobject current : sobjectList){ 
            
            if(current.get(startDateFieldName) == null){
            	startDate = Date.today();
            }else{
            	startDate = Date.valueOf(current.get(startDateFieldName));
            }
            if(current.get(endDateFieldName) == null){
            	endDate = startDate;
            }else{
            	endDate = Date.valueOf(current.get(endDateFieldName));
            }
            completed = Boolean.valueOf(current.get(completedFieldName));
            name = escapeDoubleQuotes(String.valueOf(current.get(nameFieldName)));
            id = String.valueOf(current.get(idFieldName));
            if (addComma) { ret += ','; }
            
            String color=COLOR_CURRENT;
            
            if (completed) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
            
            ret += 	'{'+
            		'id:"'+id+'",'+ 
            		'name: "'+name+'",'+
            		'start: new Date(' +startDate.year() +',' + (startDate.month()-1) +',' + startDate.day() +'),'+
             		'end: new Date(' +endDate.year() +',' + (endDate.month()-1) + ',' + endDate.day() +'), ' +
                	'color: "' + color + '"'+
                	'}';
                	
            addComma=true;
            
        }
        
        ret+=']}];';
        return ret;   	
    }
    
    private String escapeDoubleQuotes(String word){
    	return word.replaceAll(REGEXP_QUOTES,'\\\\"');
    }
    
    static testMethod void TestProjectJson() {
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        Milestone1_Milestone__c m1 = Milestone1_Test_Utility.sampleMilestone(p1);
        insert m1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = p1.id;

        String ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf('ganttData') > -1);
        System.assert(ret.indexOf(m1.Name) > -1);    
        //RSC 2011-05-09 bad test -- fails when there is an interesting dateformat.
        //System.assert(ret.indexOf(Date.today().format().substring(5)) > -1); // Test today's
        String testDateString = 'new Date(' +m1.Kickoff__c.year() +',' + (m1.Kickoff__c.month()-1) +',' + m1.Kickoff__c.day() +')';
    	System.assert(ret.indexOf(testDateString) > -1, 'expected: ' + testDateString + ': in: ' + ret);
    
        m1.Complete__c = true;
        update m1;
    
        Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;    
        
        Milestone1_Milestone__c m3 = Milestone1_Test_Utility.sampleMilestone(p1);
        m3.Kickoff__c = Date.today()+1;
        insert m3;            
    
        ret = cls.getProjectGanttJson();
        
        System.assert(ret.indexOf(COLOR_COMPLETE) > -1);
        System.assert(ret.indexOf(COLOR_LATE) > -1);
        System.assert(ret.indexOf(COLOR_FUTURE) > -1);
                
    }
    
    static testMethod void TestMilestoneJson() {
    	Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
      	Milestone1_Milestone__c m2 = Milestone1_Test_Utility.sampleMilestone(p1);
        m2.Deadline__c = Date.today()-1;
        insert m2;   
    	
    	Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(m2.Id);
        insert t1;
        
        Milestone1_Charts_GanttController cls = new Milestone1_Charts_GanttController();
        cls.mytarget = m2.Id;
        String ret = cls.getProjectGanttJson();
                   
        System.debug(LoggingLevel.Info, '12345:' + ret);
        
        System.assert(ret.indexOf(COLOR_FUTURE) > -1);
    }
}