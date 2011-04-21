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
/* 
 * 
 * Construct a feed of milestones for a Simile Timeline
 * Ron Hess, Winter 2010
 *
 */
public with sharing class Milestone1_TimelineCon {
    public Milestone1_Milestone__c rec {get; set;}
    //public Milestone1_Milestone__c dummyMS {get; set;}
    
    private List<Milestone1_Milestone__c> milestones {get; set;}
    private List<Milestone1_Task__c> tasks {get; set;} {            tasks = new List<Milestone1_Task__c>();  }
    
    public  ApexPages.StandardController con { get; set;}  
    public Milestone1_TimelineCon ( ApexPages.StandardController stc){
        con = stc;
    }

    private List<milestoneEvent> allEvents = new List<milestoneEvent>();
    private final String HOST_NAME = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
    
    //getters and setters
    public String getTod_ay()    {      return toDateTime( System.Today() ).formatGMT('MMM d yyyy HH:mm:ss') + ' GMT'; } 
    public String getTomorr_ow() {      return toDateTime( System.Today().addDays(1) ).formatGMT('MMM d yyyy HH:mm:ss') + ' GMT'; }
    
    public List<milestoneEvent> getAllEvents() { return this.allEvents; } 
    
    // Constructor
    // public Milestone1_TimelineCon() {    }

    // Methods 
    public List<Milestone1_Task__c> getMyFeed()
    {
        try { 
            // TODO filter this down by project
    
            //query main milestone record
            rec = [SELECT Id,
                          Name,
                          Project__c,
                          Parent_Milestone__c,
                          Complete__c,
                          Deadline__c,
                          Description__c,
                          Expense_Budget__c,
                          Hours_Budget__c,
                          Kickoff__c,

                          OwnerId
                          FROM Milestone1_Milestone__c
                          WHERE Id = :con.getId()
                         ];
            
            //query sub milestone records
            milestones = [SELECT Id,
                                 Name,
                                 Parent_Milestone__c,
                                 Complete__c,
                                 Deadline__c,
                                 Description__c,
                                 Expense_Budget__c,
                                 Hours_Budget__c,

                                 Kickoff__c,
                                 OwnerId
                          FROM Milestone1_Milestone__c
                          WHERE Parent_Milestone__c = :rec.Id
                         ];
            
            //query task records
            tasks = [SELECT Id,
                            Name,
                            Project_Milestone__c,
                            Assigned_To__c,
                            Complete__c,
                            Description__c,
                            Due_Date__c ,
                            Start_Date__c 
                     FROM Milestone1_Task__c
                     WHERE Project_Milestone__c = :rec.Id
                     OR Project_Milestone__r.Parent_Milestone__c = :rec.Id
                    ];
            
            
            // TODO add kickoff and deadline as milestones
            
        } catch( Exception e) {
        }
        return tasks;
    }
   
    public void init() {
        for ( Milestone1_Task__c f : getMyFeed() )  { 
            allEvents.add(new milestoneEvent(f)); 
        }
        
        if ( rec.Kickoff__c != null ) {
            Milestone1_Task__c tt = new Milestone1_Task__c(); 
            tt.Start_Date__c = rec.kickoff__c;
            tt.name = 'Kickoff';
            tt.Description__c = rec.name + ' kickoff date ';
            milestoneEvent me = new milestoneEvent(tt);
            me.classname = 'kickoff'; 
            allEvents.add ( me );
        }

        if ( rec.Deadline__c != null ) {
            Milestone1_Task__c tt = new Milestone1_Task__c(); 
            tt.Start_Date__c = rec.Deadline__c;
            tt.name = 'Deadline';
            tt.Description__c = rec.name + ' deadline date ';
            milestoneEvent me = new milestoneEvent(tt);
            me.classname = 'deadline'; 
            allEvents.add ( me );
        }

    }


    public  class milestoneEvent {  // inner class for formatting strings
    /*********************************
     *
     * Class milestoneEvent, holds one of the points or bands that will appear on the timeline
     * Used by Milestone1_TimelineData page
     * See Docs : http://code.google.com/p/simile-widgets/wiki/Timeline_EventSources
     * Ron Hess, rhess@salesforce.com 11/14/2010
     */
     
        public Milestone1_Task__c mtask {get; private set; }
        
        public  milestoneEvent (Milestone1_Task__c t) { mtask = t;  
            classname = '';
            icon='';
            link='';
            if ( mtask.description__c == null ) mtask.description__c= '';
            System.debug( LoggingLevel.INFO, this); 
        }

        public String getEndAttribute(){
            if ( mtask.Due_Date__c != null ) {
                return 'end="'+toDateTime(mtask.Due_Date__c).formatGMT('MMM d yyyy HH:mm:ss') + ' GMT" ';   
            }
            return '';
        }

        public String getStart() {          
            DateTime startDateTime = this.mtask.Start_Date__c;  
            if ( startDateTime == null )    
                startDateTime = this.mtask.Due_Date__c;     
            
            return startDateTime.formatGMT('MMM d yyyy HH:mm:ss') + ' GMT';
        }   
        
        public String getTitle() {
            string title =  this.mtask.name;
            if ( title !=null ) {
                title = title.replaceAll( '<','&lt;');
                title = title.replaceAll( '>','&gt;');
                title = title.replaceAll( '&','&amp;');
                title = title.replaceAll( '"','&quot;');
                
            }
            return title;
        }
        
        public String getDurationEvent(){
            if ( mtask.Due_Date__c != null ) { return 'true'; } 
            return 'false'; 
        }
            
        public String description { get {
            string description = mtask.Description__c;
            if ( description != null ) {
                description = description.replaceAll( '<','&lt;');
                description = description.replaceAll( '>','&gt;');
                description = description.replaceAll( '&','&amp;');
                description = description.replaceAll( '"','&quot;');
                    
                description = description.replaceAll('\n',' '); // must use ALL since many new line may get 
                description = description.replaceAll('\r',' '); // get these also!
            }
            return description;
        } private set; }
        
        public String icon {get; private set;}
        public String link {get; private set;}
        public String classname {get; private set;}
    
        /* more ?
        public String color;
        public String textColor;
        public String caption;
        public String classname;
        */      
    }


    public static DateTime toDateTime(Date d) {     
        if ( d == null ) return System.now();
        return Datetime.newInstance(d.year(),d.month(),d.day()); 
    }
    
}