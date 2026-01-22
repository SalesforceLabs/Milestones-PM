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
public with sharing class Milestone1_Month {
    private List<Week> weeks; 
    public Date firstDate; // always the first of the month
    private Date upperLeft; 
    public Boolean fiveDayView = false;
    
    public List<Date> getValidDateRange() { 
        // return one date from the upper left, and one from the lower right
        List<Date> ret = new List<Date>();
        ret.add(upperLeft);
        ret.add(upperLeft.addDays(5*7) );
        return ret;
    }
    
    public String getMonthName() { 
        return DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).format('MMMM');
    } 
    
    public String getYearName() { 
        return DateTime.newInstance(
        firstDate.year(),firstdate.month(),firstdate.day()).format('yyyy');
    } 
    
    public String[] getWeekdayNames() { 
        Date today = system.today().toStartOfWeek();
        DateTime dt = DateTime.newInstanceGmt(today.year(),today.month(),today.day());      
        list<String> ret = new list<String>();
        for(Integer i = 0; i < 7;i++) { 
            ret.add( dt.formatgmt('EEEE') );
            dt= dt.addDays(1);
        } 
        return ret;
    }
    
    public Date getfirstDate() { return firstDate; } 

    public Milestone1_Month( Date value ) {
        weeks = new List<Week>();
        firstDate = value.toStartOfMonth();
        upperLeft = firstDate.toStartOfWeek();
        Date tmp = upperLeft;
        for (Integer i = 0; i < 5; i++) {
            Week w = new Week(i+1,tmp,value.month());   
            system.assert(w!=null); 
            this.weeks.add( w );
            tmp = tmp.addDays(7);
        }

    }
    
    public void clearEvents(){
        for(Week w:weeks) { 
            for(Day c: w.getDays() ) { 
                    c.eventsToday = new List<Milestone1_Calendar_Item>();
            } 
        } 
    }
 
    public void setEvents(List<Milestone1_Calendar_Item> ev) { 
        // merge these events into the proper day 
        for(Milestone1_Calendar_Item e:ev) { 
            for(Week w:weeks) { 
                for(Day c: w.getDays() ) { 
                    if ( e.theDate.isSameDay(c.theDate))  { 
                        // add this event to this calendar date
                        c.eventsToday.add(e);
                        // add only three events, then a More... label if there are more
                    } 
                } 
            } 
        }
    }
    
    public List<Week> getWeeks() { 
        system.assert(weeks!=null,'could not create weeks list');
        return this.weeks; 
    }
    
    public List<Week> getCurrentWeek(Date d)
    {
        List<Week> returnWeek = new List<Week>();
        for(Week w:weeks)
        {
            for(Day c: w.getDays())
            {
                if( d.isSameDay(c.theDate))
                {
                    returnWeek.add(w);
                    break;
                }
            }
        }
        weeks = returnWeek;
        return returnWeek;
    }
        

    /* 
     * helper classes to define a month in terms of week and day
     */
    public with sharing class Week {
     public List<Day> days;
     public Integer weekNumber; 
     public Date startingDate; // the date that the first of this week is on
     // so sunday of this week
     
     public List<Day> getDays() { return this.days; }
     
     public Week () { 
        days = new List<Day>();     
     }
     public Week(Integer value,Date sunday,Integer month) { 
        this();
        weekNumber = value;
        startingDate = sunday;
        Date tmp = startingDate;
        for (Integer i = 0; i < 7; i++) {
            Day d = new Day( tmp,month ); 
            tmp = tmp.addDays(1);
            d.dayOfWeek = i+1;          
        //  system.debug(d);
            days.add(d);
        } 
        
     }
     public Integer getWeekNumber() { return this.weekNumber;}
     public Date getStartingDate() { return this.startingDate;}
     
    }
    
    public with sharing class Day {
         
        public Date         theDate;
        public List<Milestone1_Calendar_Item>   eventsToday; // list of events for this date
        public Integer      month, dayOfWeek;
        public String       formatedDate; // for the formated time  
        private String      cssclass = 'calActive';
         
        public Date         getDate() { return theDate; }
        public Integer      getDayOfMonth() { return theDate.day(); }
        public String       getDayOfMonth2() { 
            if ( theDate.day() <= 9 ) 
                return '0'+theDate.day(); 
            return String.valueof( theDate.day()); 
        }
        public Integer getDayOfYear() { return theDate.dayOfYear(); }
        public List<Milestone1_Calendar_Item>   getDayAgenda() { return eventsToday; }
        public String       getFormatedDate() { return formatedDate; }
        public Integer      getDayNumber() { return dayOfWeek; }
        public List<Milestone1_Calendar_Item>   getEventsToday() { return eventsToday; }
        public String       getCSSName() {  return cssclass; }
        
        public Day(Date value,Integer vmonth) { 
            theDate=value; month=vmonth;        
            formatedDate = '12 21 08';// time range..
            //9:00 AM - 1:00 PM
            eventsToday = new List<Milestone1_Calendar_Item>();  
            // three possible Inactive,Today,Active  
            if ( theDate.daysBetween(System.today()) == 0 ) cssclass ='calToday';
            // define inactive, is the date in the month?
            if ( theDate.month() != month) cssclass = 'calInactive';
        }
            
    }

    static testMethod void testMe() {
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
        testTask.Start_Date__c = Date.today().addDays(-1);
        testTask.Due_Date__c = Date.today().addDays(-1);
        
        insert testTask;
        
        Milestone1_Month m = new Milestone1_Month( Date.today());
        system.assert(m!=null); 
        List<Week> l = m.getWeeks(); 
        for(Week w : l)
        {
            List<Day> days = w.getDays();
            for(Day d : days)
            {
                system.debug(d.getDayOfYear());
                system.debug(d.getDayOfMonth());
                system.debug(d.getDayNumber());
                system.debug(d.getCSSName());
            }
        }
        system.debug(m.getFirstDate());
        system.debug(m.getWeekdayNames());
        system.debug(m.getYearName());
        system.debug(m.getMonthName());
        system.assert(m.getWeeks() != null);
        system.assert(m.getWeeks().size() > 3);
    }
}