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
// Added for test purposes
public with sharing class Milestone1_Calendar_Item 
{
    public String aid {get;set;}
    public String name {get;set;}
    public Date theDate {get;set;}
    public String theType {get;set;}
    
    public static final String PROJECT_TYPE = 'PROJECT_TYPE';
    public static final String MILESTONE_TYPE = 'MILESTONE_TYPE';
    public static final String TASK_TYPE = 'TASK_TYPE';
    
    public Milestone1_Calendar_Item(String theId, String theName, Date inputDate, String inType)
    {
        aid = theId;
        name = theName;
        theDate = inputDate;
        theType = inType;
    }
    
    static testMethod void testCalendarItem()
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item('ABCDEFG','UNIT TEST',Date.today(),Milestone1_Calendar_Item.PROJECT_TYPE);
        system.assertEquals('UNIT TEST',calItem.name);
        system.assertEquals('ABCDEFG', calItem.aid);
        system.assertEquals(Date.today(),calItem.theDate);
    }
}