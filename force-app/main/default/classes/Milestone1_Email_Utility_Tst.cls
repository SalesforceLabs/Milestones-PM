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
private class Milestone1_Email_Utility_Tst 
{
    static testMethod void testEmailUtilityBody()
    {
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        
        List<Milestone1_Nag__c> nags = new List<Milestone1_Nag__c>();
        Milestone1_Nag__c nag = new Milestone1_Nag__c();
        nag.Project__c = proj.Id;
        insert nag;
        nags.add(nag);
        
        User recipient = [Select Id, Name, Email from User where Id =:UserInfo.getUserId()];
        Messaging.SingleEmailMessage email = Milestone1_Email_Utility.buildEmail(nags, recipient);
        system.assertEquals(Milestone1_Email_Utility.EMAIL_SENDER_NAME,email.getSenderDisplayName());
        system.assertEquals(recipient.Email,email.getToAddresses().get(0));
    }
}