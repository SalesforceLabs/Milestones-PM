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
public with sharing class Milestone1_Email_Utility 
{
    public static final String EMAIL_SENDER_NAME = system.label.ProjectMilestoneNagEngine;
    public static final String EMAIL_SUBJECT = system.label.ProjectMilestoneNotification;
    public static final String EMAIL_BODY_START = system.label.TheFollowingSalesforceProjectMilestoneItems;

    public static Messaging.SingleEmailMessage buildEmail(List<Milestone1_Nag__c> nags, User recipient)
    {
        System.debug('Processing number of nags == ' + nags.size());
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{recipient.Email};
        email.setToAddresses(toAddresses);
        email.setSubject(EMAIL_SUBJECT);
        email.setSenderDisplayName(Milestone1_Email_Utility.EMAIL_SENDER_NAME);
        email.setHtmlBody(buildHTMLBody(nags));
        return email;
    }
    
    private static String buildHTMLBody(List<Milestone1_Nag__c> nags)
    {
        String returnBody = EMAIL_BODY_START;
        for(Milestone1_Nag__c nag : nags)
        {
             String item = '';
             if(nag.Project__c != null)
             {
                item = nag.Project__c;
             }else if(nag.Project_Milestone__c != null)
             {
                item = nag.Project_Milestone__c;
             }else if(nag.Project_Task__c != null)
             {
                item = nag.Project_Task__c;
             }
             returnBody = returnBody + '<br/> <a href=https://www.salesforce.com/' + item + '>' + nag.Parent_Name__c + '</a> - ' + nag.Nag_Status__c;
        }
        system.debug(returnBody);
        return returnBody;
    }
}