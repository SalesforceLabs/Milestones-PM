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
public with sharing class Milestone1_Time_Trigger_Utility {

    public static void handleTimeBeforeTrigger(List<Milestone1_Time__c> recs)
    {
        for(Milestone1_Time__c rec : recs)
        {
            if(rec.Incurred_By__c == null)
            {
                rec.Incurred_By__c = UserInfo.getUserId();
            }
            if(rec.Date__c == null)
            {
                rec.Date__c = Date.today();
            }
        }
    }
    
    static testMethod void testTriggerUtility()
    {
        List<Milestone1_Time__c> recs = new List<Milestone1_Time__c>{new Milestone1_Time__c()};
        Milestone1_Time_Trigger_Utility.handleTimeBeforeTrigger(recs);
        for(Milestone1_Time__c rec : recs)
        {
            System.assertEquals(UserInfo.getUserId(),rec.Incurred_By__c);
            System.assertEquals(Date.today(),rec.Date__c);
        }
    }
}