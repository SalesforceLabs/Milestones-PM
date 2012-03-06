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
public with sharing class Milestone1_One_Line_Controller {
    
    public String line {get; set;}
    public Milestone1_Task__c task {get;set;}
    public Milestone1_One_Line_Controller()
    {
        task = null;
    }
    
    public void executeLine()
    {
        task = null;
        List<String> stringTokens = line.split('---',2);
        if(stringTokens.size() == 2)
        {
            String milestoneAlias = stringTokens.get(0).trim();
            Milestone1_Milestone__c milestone = getMilestoneByAlias(milestoneAlias);
            if(milestone != null)
            {
                try
                {
                    task = new Milestone1_Task__c();
                    String descriptionString = stringTokens.get(1).trim();
                    String nameString = stringTokens.get(1).trim();
                    nameString = Milestone1_General_Utility.processTaskName(nameString);
                    task.Name = nameString; 
                    if(descriptionString.length() >= 5000)
                    {
                        descriptionString = descriptionString.substring(0,4999);
                    }
                    task.Description__c = descriptionString;
                    task.Project_Milestone__c = milestone.Id;
                    insert task;
                    line = '';
                }catch(Exception e)
                {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, system.label.Milestone1_SalesforceDMLError + e.getMessage());
                    ApexPages.addMessage(errorMsg);
                }
            }else
            {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, system.label.Milestone1_Thealias + milestoneAlias + system.label.Milestone1_DidNotMatch);
                ApexPages.addMessage(errorMsg);
            }
        }else
        {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, system.label.Milestone1_PleaseUseFormat);
            ApexPages.addMessage(errorMsg);
        }   
    }
    

    
    private Milestone1_Milestone__c getMilestoneByAlias(String alias)
    {
        List<Milestone1_Milestone__c> milestones = [Select Id, Name, Alias__c from Milestone1_Milestone__c Where alias__c = :alias];
        //Milestones - Alias field is Unique, so we should only have one return value.
        if(milestones.size() > 0)
        {
            return milestones.get(0);
        }
        return null;
    }
    

}