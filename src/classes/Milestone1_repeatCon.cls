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
public with sharing class Milestone1_repeatCon {

 public List<SelectOption> filterList {get;set;}
 public String filterItem {get;set;}
 private final String ALL_ITEMS = system.label.Milestone1_AllItems;
 private final String MY_TASKS = system.label.Milestone1_MyTasksOnly;
 private final String MY_MILESTONES_ONLY = system.label.Milestone1_MyMilestonesOnly;
 private final String MY_PROJECTS_AND_ITEMS = system.label.Milestone1_MyProjectsAndSubProjectItems;
 private Date currentDay;
   /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
 private List<String> projectIds{get;set;}
 private List<String> milestoneIds{get;set;}
 public List<SelectOption> activeProjectList {get;set;}
 public String selectedProject {get;set;}
 
 public List<Milestone1_Project__c> getAllProjectItems(){
     return [Select Id,Name from Milestone1_Project__c where Status__c ='Active' limit 500];
 }

 private Map<ID,Milestone1_Project__c> getSelectedProject(){
        projectIds.clear();
         Map<ID,Milestone1_Project__c> projMap=new  Map<ID,Milestone1_Project__c>();
        if(selectedProject == 'AllProjects' || selectedProject == null )
        {
            List<Milestone1_Project__c> projList = getAllProjectItems();
            for(Milestone1_Project__c projObj : projList){
                projMap.put(projObj.id,projObj);
            }
        }
        else{
        	Milestone1_Project__c project=[Select id from Milestone1_Project__c where id =:  selectedProject];
            projMap.put(project.id,project);
        }
        for(Id setId:projMap.keySet())
        projectIds.add(setId);
    
        return projMap;
 }
 
 private Map<ID,Milestone1_Milestone__c> getProjectSpecificMilestone(){
    milestoneIds.clear();
    Map<ID,Milestone1_Milestone__c> milestonesMap=new  Map<ID,Milestone1_Milestone__c>();
    for(Milestone1_Milestone__c m:[Select Id from Milestone1_Milestone__c where Project__c in : projectIds limit 500])
    {
      milestonesMap.put(m.Id,m);
      //  milestoneIds.add(m.Id);
    }
    for(Id setId:milestonesMap.keySet())
        milestoneIds.add(setId);
    return milestonesMap;
 }
 
  public void next() { 
    addMonth(1);
  }

  public void prev() { 
    addMonth(-1); 
  }

  public void fiveDayView()
  {
    setMonth(currentDay);
    month.getCurrentWeek(currentDay);
    month.fiveDayView = true;  
  
  }

  public void monthView()
  {
    month = new Milestone1_Month(currentDay);
    filter();
  }

  public Milestone1_repeatCon() {
  
   currentDay = system.today();  // default to today 
   integer mo = currentDay.month(); 
   projectIds=new List<String>();
   milestoneIds=new List<String>();
   String m_param = System.currentPageReference().getParameters().get('mo');
   String y_param = System.currentPageReference().getParameters().get('yr');
   
   // allow a month to be passed in on the url as mo=10
   if (m_param != null) { 
        integer mi = integer.valueOf(m_param); 
        if (mi > 0 && mi <= 12) {
          currentDay = Date.newinstance(currentDay.year(),mi,currentDay.day());
        }
   }
   // and year as yr=2008
   if (y_param != null) { 
        integer yr = integer.valueOf(y_param); 
        currentDay = Date.newinstance(yr, currentDay.month(), currentDay.day());
   }
    
   filterList = new List<SelectOption>{new SelectOption(ALL_ITEMS,ALL_ITEMS),new SelectOption(MY_PROJECTS_AND_ITEMS,MY_PROJECTS_AND_ITEMS),new SelectOption(MY_TASKS,MY_TASKS),new SelectOption(MY_MILESTONES_ONLY,MY_MILESTONES_ONLY)};    
  /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
   activeProjectList=new List<SelectOption>();
   activeProjectList.add(new SelectOption('AllProjects','     '));
   for(Milestone1_Project__c project:getAllProjectItems()){
        activeProjectList.add(new SelectOption(project.id,project.name));
   }  
        filterItem = ALL_ITEMS;
        setMonth(currentDay);
        fiveDayView();
  }
 
  public List<Milestone1_Month.Week> getWeeks() { 
    system.assert(month!=null,'month is null');
    return month.getWeeks();
  }
  
  public Milestone1_Month getMonth() { return month; } 


  public void filter()
  {
    List<Milestone1_Calendar_Item> filteredItems = new List<Milestone1_Calendar_Item>();
    month.clearEvents();
    /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
    
    
     if(filterItem == ALL_ITEMS)
    {
        filteredItems = getAllItems(month.getValidDateRange());
    }else if(filterItem == MY_TASKS)
    {
        filteredItems = getMyTasksOnly(month.getValidDateRange());
    }else if(filterItem == MY_MILESTONES_ONLY)
    { 
        filteredItems = getMyMilestonesOnly(month.getValidDateRange());
    }else if(filterItem == MY_PROJECTS_AND_ITEMS)
    {
        filteredItems = getMyProjectsAndItems(month.getValidDateRange());
    }
    month.setEvents(filteredItems);
  }

  private void setMonth(Date d) { 
    month = new Milestone1_Month(d);  
    
   // system.assert(month != null); 
   // Date[] da = month.getValidDateRange();  // gather events that fall in this month
   // month.setEvents(getAllItems(da));  // merge those events into the month class
   filter();
  }
  
  private List<Milestone1_Calendar_Item> getAllItems(Date[] da)
  {
    /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
    getSelectedProject();
    getProjectSpecificMilestone();
    List<Milestone1_Project__c> projects = [Select Id, Deadline__c, Name from Milestone1_Project__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and id in :projectIds limit 500];
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and Project__c in :projectIds LIMIT 500];
    List<Milestone1_Task__c> tasks = [Select Id, Due_Date__c, Name from Milestone1_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1] and Project_Milestone__c in :milestoneIds LIMIT 500];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Milestone1_Project__c proj : projects)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(proj.Id,proj.Name,proj.Deadline__c,Milestone1_Calendar_Item.PROJECT_TYPE);
        events.add(calItem);
    }
    for(Milestone1_Milestone__c milestone : milestones)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    for(Milestone1_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
 private List<Milestone1_Calendar_Item> getMyProjectsAndItems(Date[] da)
  {
     /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
    getSelectedProject();
    getProjectSpecificMilestone();
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    List<Milestone1_Project__c> projects = [Select Id, Deadline__c, Name from Milestone1_Project__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and OwnerId =:Userinfo.getUserId() and id in :projectIds limit 500];
    List<String> projectIds = new List<String>();
    for(Milestone1_Project__c proj : projects)
    {
        projectIds.add(proj.Id);
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(proj.Id,proj.Name,proj.Deadline__c,Milestone1_Calendar_Item.PROJECT_TYPE);
        events.add(calItem);
    }
    
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and Project__c in :projectIds limit 500];
    List<String> milestoneIds = new List<String>();
    for(Milestone1_Milestone__c milestone : milestones)
    {
        milestoneIds.add(milestone.Id);
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    
    List<Milestone1_Task__c> tasks = [Select Id, Due_Date__c, Name from Milestone1_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1] and Project_Milestone__c in:milestoneIds limit 500];
    for(Milestone1_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    
    return events;
  }


  private List<Milestone1_Calendar_Item> getMyMilestonesOnly(Date[] da)
  {
    /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
    getSelectedProject();
    getProjectSpecificMilestone();
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and OwnerId =:Userinfo.getUserId() and Project__c in : projectIds LIMIT 500 ];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Milestone1_Milestone__c milestone : milestones)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
  private List<Milestone1_Calendar_Item> getMyTasksOnly(Date[] da)
  {
    /**
    *Modified Date:04-20-2012.
    *Owner:Persistent.
    *Comment: To add an additional project filter.
    *Bug #: 66.
    */
    getSelectedProject();
    getProjectSpecificMilestone();
    List<Milestone1_Task__c> tasks = [Select Id, Due_Date__c, Name from Milestone1_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1] and Assigned_To__c =:Userinfo.getUserId() and Project_Milestone__c in : milestoneIds LIMIT 500 ];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Milestone1_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
  
  private void addMonth(integer val) { 
    Date d = month.getFirstDate();
    d = d.addMonths(val);
    setMonth(d);
  }

  private Milestone1_Month month;
  
  
  static testMethod void testController()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
           
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
  static testMethod void testControllerFilterTasks()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Tasks Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        List<Id> mIds=new List<Id>();
        mIds.add(testMilestone.id);
        List<Milestone1_Task__c> tasksList=[Select Id from Milestone1_Task__c where Assigned_To__c =:Userinfo.getUserId() and Project_Milestone__c in : mIds ];
        for(Milestone1_Task__c task:tasksList)
        {
            if(testTask.id==task.id)
            system.assertEquals(task.id,testTask.id);
        }
  }
  
  static testMethod void testControllerFilterMilestones()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Milestones Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
         Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
       //system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
  static testMethod void testControllerFilterMyProjects()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
        */ 
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'My Projects And Sub-Project Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
  }
  
   /**
         *Modified Date:04-20-2012.
         *Owner:Persistent.
         *Comment: To add an additional project filter.
         *Bug #: 66.
   */ 
    static testMethod void testControllerFilterAllItems()
    {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = testProject.id;
        controller.filterItem = 'All Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
      
    }
  
  static testMethod void testControllerFilterAllItemsWithBlankProject()
    {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Project__c testProject1 = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject1.Status__c = 'Active';
        testProject1.Deadline__c = Date.today();
        insert testProject1;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Milestone__c testMilestone1 = Milestone1_Test_Utility.sampleMilestone(testProject1.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone1.Deadline__c = Date.today();
        testMilestone1.Complete__c = false;
        insert testMilestone1;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        Milestone1_Task__c testTask1 = Milestone1_Test_Utility.sampleTask(testMilestone1.Id);
        testTask1.Complete__c = false;
        testTask1.Start_Date__c = Date.today();
        testTask1.Due_Date__c = Date.today();
        insert testTask1;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = null;
        controller.filterItem = 'All Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(projMap.containsKey(testProject1.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone1.id),true);
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
        
    }


static testMethod void testControllerFilterMyProjectsWithBlankProject()
  {
         Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Project__c testProject1 = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject1.Status__c = 'Active';
        testProject1.Deadline__c = Date.today();
        insert testProject1;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = 'AllProjects';
        controller.filterItem = 'My Projects And Sub-Project Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(projMap.containsKey(testProject.id),true);
        system.assertEquals(projMap.containsKey(testProject1.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
  }
  
  static testMethod void testControllerFilterMilestonesWithBlankProject()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
      	 Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
        
        Milestone1_Milestone__c testMilestone1 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone1.Deadline__c = Date.today();
        testMilestone1.Complete__c = false;
        insert testMilestone1;
        
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = null;
        controller.filterItem = 'My Milestones Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        system.assertEquals(milestonesMap.containsKey(testMilestone.id),true);
        system.assertEquals(milestonesMap.containsKey(testMilestone1.id),true);
        
        
  }
  
  static testMethod void testControllerFilterTasksWithBlankProject()
  {
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Trial Project ABCXYZ' + System.now());
        testProject.Status__c = 'Active';
        testProject.Deadline__c = Date.today();
        system.debug(testProject.name);
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;
    
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        
        Milestone1_Task__c testTask1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask1.Complete__c = false;
        testTask1.Start_Date__c = Date.today();
        testTask1.Due_Date__c = Date.today();
        insert testTask1;
        
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.selectedProject = 'AllProjects';
        controller.filterItem = 'My Tasks Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        Map<ID,Milestone1_Project__c> projMap= controller.getSelectedProject();
        Map<ID,Milestone1_Milestone__c> milestonesMap=controller.getProjectSpecificMilestone();
        Milestone1_Task__c task=[Select id,name from Milestone1_Task__c where id =: testTask.id];
        system.assertEquals(testTask.id,task.id);
        task=[Select id,name from Milestone1_Task__c where id =: testTask1.id];
        system.assertEquals(testTask1.id,task.id);
  }
  
  
  
  }