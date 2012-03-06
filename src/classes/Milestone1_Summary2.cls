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
public with sharing class Milestone1_Summary2 {

    public ID targetProject {get; set;}

    public String searchText {get; set;}
    public List<Milestone1_Project__c> projectResults {get; private set;}
    public List<Milestone1_Milestone__c> milestoneResults {get; private set;}
    public List<Milestone1_Task__c> taskResults {get; private set;}
    public boolean displaySearchError {private get; private set;}
    public boolean searchLengthError {private get; private set;}
    public List<Pair> recentItems {get; private set;}
    
    public boolean hasSearchResultsError {
        get {
            return displaySearchError != null && displaySearchError == true;
        }
    }
    
    public boolean hasSearchLengthError{
    	get{
    		return searchLengthError != null && searchLengthError == true;
    	}
    }
    
    public boolean hasProjectResults {
        get {
            return projectResults != null && !projectResults.isEmpty();
        }
    }
    
    public boolean hasMilestoneResults {
        get {
            return milestoneResults != null && !milestoneResults.isEmpty();
        }
    }
    
    public boolean hasTaskResults {
        get {
            return taskResults != null && !taskResults.isEmpty();
        }
    }
    
    public boolean hasSettings{

        get{
            return settings != null;
        }
    }
    
    public boolean isDeployed{
        get{
            Id myProfileId = UserInfo.getProfileId();
            Profile myProfile = [Select Id, Name from Profile where Id=:myProfileId];
            
            Boolean objectsDeployed = true;
            if (myProfile.Name != 'System Administrator')
            {
            
                try{
        
                    Schema.DescribeFieldResult F = Schema.SObjectType.Milestone1_Milestone__C.fields.Name;
                    if ( F.isAccessible() == true)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                    return true;
                }
                catch (System.UnexpectedException e)
                {
            
                    
                    return false;
                }
            
            }
            return objectsDeployed;
        }
    }
    
    
    
    public Milestone1_Settings__c settings = Milestone1_Settings__c.getInstance();
    
    public void initialize() {

        
        if (isDeployed)
        {
            List<Milestone1_Project__c> recentProjects = [Select Id, Name from Milestone1_Project__c order by LastModifiedDate desc limit 5];
            List<Milestone1_Milestone__c> recentMilestones = [Select Id, Name from Milestone1_Milestone__c order by LastModifiedDate desc limit 50];
            List<Milestone1_Task__c> recentTasks = [Select Id, Name from Milestone1_Task__c order by LastModifiedDate desc limit 100];
    
            this.recentItems = new List<Pair>();
            this.recentItems.addAll(createPairObjects(recentProjects, 'Project: '));
            this.recentItems.addAll(createPairObjects(recentMilestones, 'Milestone: '));
            this.recentItems.addAll(createPairObjects(recentTasks, 'Task: '));
        }
    }

    
    public void searchProjects() {

        if (searchText.length() < 2)
        {
            this.searchLengthError = true;
            return;
        }
        else
        {
            this.searchLengthError = false;
        }
        
        List<List<SObject>> searchList = [FIND :searchText in all fields returning 
        Milestone1_Project__c (Id, Name, Owner.Name, Status__c LIMIT 5), 
        Milestone1_Milestone__c (Id, Name, Project__r.Name LIMIT 10), 
        Milestone1_Task__c (Id, Name, Project_Milestone__r.Name LIMIT 25) 
        ];
        this.projectResults = (List<Milestone1_Project__c>) searchList[0];
        this.milestoneResults = (List<Milestone1_Milestone__c>) searchList[1];
        this.taskResults = (List<Milestone1_Task__c>) searchList[2];
        
        if (this.projectResults.isEmpty() && this.milestoneResults.isEmpty() && this.taskResults.isEmpty()) {
            this.displaySearchError = true;
        }
        else {
            this.displaySearchError = false;
        }
    }
    
    private List<Pair> createPairObjects(List<SObject> records, String namePrefix) {
        List<Pair> newPairs = new List<Pair>(); 
        for (SObject record: records) {
            //RSC 2011-05-06 am getting occassional script exceptions
            if (record != null && record.get('name') != null) {
                newPairs.add(new Pair(namePrefix + (String)record.get('name'), (String)record.id));
            }
        }
        return newPairs;
    }
    
    public List<Milestone1_Project__c> getProjects() {
        
        
         return (List<Milestone1_Project__c>) setCon.getRecords();
        

    }
    
    
   public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                          [Select m.Id, m.Total_Open_Task_Count__c, m.Total_Complete_Task_Count__c, 
            m.Total_Blocked_Task_Count__c, m.Total_Late_Task_Count__c, m.Status_TasksOpenBlockedLate__c,
            m.Total_Hours_Budget__c, m.Total_Hours_Budget_from_Milestones__c, m.Total_Hours_Estimate__c, m.Total_Hours_Incurred__c, 
            m.Status_BudgetMiletoneEstimate__c, m.Status_BudgetExpenseSummary__c, m.Name, m.Deadline__c, m.Kickoff__c, 
            m.Duration__c, m.GoogleGanntUrl__c
            From Milestone1_Project__c m where m.status__c = 'Active']));
                setCon.setPageSize(20);
            }
            return setCon;
        }
        set;
    }
    
    

  //Boolean to check if there are more records after the present displaying records  
    public Boolean hasNext  
    {  
        get  
        {  
            return setCon.getHasNext();  
        }  
        set;  
    }  
   
    //Boolean to check if there are more records before the present displaying records  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return setCon.getHasPrevious();  
        }  
        set;  
    }  
   
    //Page number of the current displaying records  
    public Integer pageNumber  
    {  
        get  
        {  
            return setCon.getPageNumber();  
        }  
        set;  
    } 
    
    public Integer totalPages
    {

        get
        {
            Integer pages = (setCon.getResultSize() / 20);
            if (math.mod(setCon.getResultSize(), 20) != 0)
            {
                pages += 1;
            }
            return pages;
        }
        set;

    } 
  
    //Returns the previous page of records  
    public void previous()  
    {  
        setCon.previous();  
    }  
   
    //Returns the next page of records  
    public void next()  
    {  
        setCon.next();  
    }      
    
    
    
    public Pagereference view() {

        return new Pagereference('/' + targetProject);
    }
    
    public Pagereference viewMyTasks() {
        return new Pagereference('/' + settings.Report_Id_My_tasks_by_project__c + '?pv0=' + String.valueOf(targetProject).substring(0,15) + '&pv1=' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
    }

    public Pagereference viewBlockedTasks() {
    	
        return new Pagereference('/' + settings.Report_Id_Blocked_Tasks_by_Project__c + '?pv0=' + String.valueOf(targetProject).substring(0,15) );
    }

    public Pagereference viewOverdueTasks() {
        return new Pagereference('/' + settings.Report_Id_Overdue_Tasks_by_Project__c + '?pv0=' + String.valueOf(targetProject).substring(0,15) );
    }

    public Pagereference viewOpenTasks() {
        return new Pagereference('/' + settings.Report_Id_Open_Task_Status_by_Project__c + '?pv0=' + String.valueOf(targetProject).substring(0,15) );
    }

    public Pagereference viewMilestoneOpenTasks() {
        return new Pagereference('/' + settings.Report_Id_Project_Milestone_Open_Task__c + '?pv0=' + String.valueOf(targetProject).substring(0,15) );
    }

    public Pagereference incompleteTasksByProject() {

        return new Pagereference('/' + settings.Report_Id_My_Tasks_By_Project_Milesto__c + '?pv0=' + Encodingutil.urlEncode(''+UserInfo.getName(), 'UTF-8' ));
    }

    public Pagereference incompleteTasksByPriority() {
	
        return new Pagereference('/' + settings.Report_Id_My_Tasks_By_Priority_Project__c + '?pv0=' + Encodingutil.urlEncode(''+UserInfo.getName(), 'UTF-8' ) );
    }

    public Pagereference summaryMyLateTasks() {
   	
        return new Pagereference('/' + settings.Report_Id_My_Late_Tasks__c + '?pv0=' + Encodingutil.urlEncode(''+UserInfo.getName(), 'UTF-8' ) );
    }
    
    public Pagereference summaryMyBlockedTasks() {
   	
        return new Pagereference('/' + settings.Report_Id_My_Blocked_Tasks__c + '?pv0=' + Encodingutil.urlEncode(''+UserInfo.getName(), 'UTF-8' ) );
    }
    
    class Pair {
        Pair(String key, String value) {
            this.key = key;
            this.value = value;
        }
        
        public String key {get; private set;}
        public String value {get; private set;}
    }
    
    static TestMethod void testController() {
        
        //make sure it shows active projects
        Milestone1_Summary2 summary2 = new Milestone1_Summary2();
        
        //important for new installs
        if (summary2.settings == null) {
            summary2.settings = new Milestone1_Settings__c();
        }
        
        if (summary2.settings.Report_Id_Blocked_Tasks_by_Project__c == null) {
            summary2.settings.Report_Id_Blocked_Tasks_by_Project__c = 'a';
            summary2.settings.Report_Id_My_tasks_by_project__c = 'b';
            summary2.settings.Report_Id_Overdue_Tasks_by_Project__c = 'c';
        }
        
        Integer i = summary2.getProjects().size();
        
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Controller Test');
        insert p1;


        
        //make sure we get page references back
        summary2.targetProject = p1.id;
        
        System.assert(summary2.view() != null);
        System.assert(summary2.viewMyTasks() != null);
        System.assert(summary2.viewBlockedTasks() != null);
        System.assert(summary2.viewOverdueTasks() != null);
        
        summary2.initialize();
        System.assert(summary2.recentItems != null);
        
        //Test.setFixedSearchResults(new Id[] {p1.Id});
        summary2.searchText = 's';
        summary2.searchProjects();
        System.assertEquals(true, summary2.hasSearchLengthError);
        
        
        summary2.searchText = 'Test';
        summary2.searchProjects();
        System.assert(summary2.hasSearchResultsError);
        System.assert(!summary2.hasProjectResults);
        System.assert(!summary2.hasMilestoneResults);
        System.assert(!summary2.hasTaskResults);
        
        
        
        System.assertEquals(1, summary2.pageNumber);
        
        
        if(summary2.hasNext == true)
        {
        	summary2.next();
        }
        if(summary2.hasPrevious == true)
        {
        	summary2.previous();
        }
        
    }

}