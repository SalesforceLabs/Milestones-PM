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
global class Milestone1_Email_Handler implements Messaging.InboundEmailHandler 
{ 
    /*
    Email to Apex Class. Milestone Task Created with following mapping: 
    To -> Assigned, 
    Subject -> Brief, 
    TextBody -> Description, 
    Attachments -> Attachments
    
    Parent Milestone is looked up based on Milestone Alias provided in Subject. 
    */

    public static final String REGEX_FWD_RE = '^[ ]*((([Ff][Ww][Dd])|([Rr][Ee]))[ ]*:[ ]*)*';
    public static String ERROR_USERS_NOT_FOUND = 'The User seaches for Assignment (To Address) and/or Ownership (From Address) did not find matches to users in Salesforce.';
    public static String ERROR_SUBJECT_MISSING_ALIAS = 'The subject line did not contain a milestone alias.';
    public static String ERROR_ALIAS_NOT_FOUND = 'The alias provided in subject line did not match a milestone alias in Salesforce.';
    public static String ERROR_FROM_USER_NOT_FOUND = 'The email sender did not match a user in Salesforce.';
    public static String ERROR_TO_USER_NOT_FOUND = 'The list of recipients did not have any matches to a user in Salesforce.';
    public static String ERROR_TASK_NOT_FOUND = 'A matching task was not found for this Email thread in Salesforce. Salesforce was unable to attach this email to the notes for a task.';
    public static String ERROR_SUBJECT_MISSING_TASK	 = 'The subject line did not contain a task.';
    public static String ERROR_SUBJECT_MISSING = 'The subject line did is empty.';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        if(email.inReplyTo != null && email.inReplyTo.length() > 0)
        {
            result = processReplyEmail(email);
        }else
        {
            result = processNewEmail(email);
        }
        
        return result;
    }
    
    public static Messaging.InboundEmailResult processReplyEmail(Messaging.InboundEmail email)
    {
        system.debug('Process a Reply Email. Reply ID ' + email.inReplyTo);
        system.debug('plainTextBodyIsTruncated == ' + email.plainTextBodyIsTruncated);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //processing the subject
        List<String> processedSubjectLine = Milestone1_Email_Handler.processSubject(email.subject);
        String milestoneAliasName = processedSubjectLine.get(0); 
        String taskName = processedSubjectLine.get(1);
        Milestone1_Milestone__c milestone = Milestone1_Email_Handler.getMilestone(milestoneAliasName);
        
        List<Milestone1_Task__c> matchingTasks = [Select Id from Milestone1_Task__c where Name =:taskName and
        										  Project_Milestone__c =:milestone.Id limit 1];
        
        if(matchingTasks == null || matchingTasks.size() == 0)
        {	
        	//As no task was found, assume that it is a forward
        	processNewEmail(email);	
        }else
        {
        	//otherwise it is a reply
            Milestone1_Email_Handler.insertNote(matchingTasks.get(0),email);
            Milestone1_Email_Handler.insertAttachments(matchingTasks.get(0),email);
            Milestone1_Email_Handler.updateMilestoneTask(matchingTasks.get(0),email);
        }
        result.success =  true;
        return result;
    }
    
    public static Messaging.InboundEmailResult processNewEmail(Messaging.InboundEmail email)
    {
        system.debug('Process a new Email');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Milestone1_Milestone__c milestone;
        system.debug('Email In Reply To: ' + email.inReplyTo);
        system.debug('Email Message Id: ' + email.messageId);
        List<User> fromUsers = [Select Id from User where isActive = true and Email = :email.fromAddress];
        String firstEmail;
        if(email.toAddresses != null && email.toAddresses.size() > 0)
        {
            firstEmail = Milestone1_Email_Handler.parseAddress(email.toAddresses.get(0));
            system.debug('First Email == ' + firstEmail);
        }
        List<User> toUsers = [Select Id from User where isActive = true and Email = :firstEmail];
        
        if(fromUsers.size() == 0)
        {
            result.message = ERROR_FROM_USER_NOT_FOUND;
            result.success = false;
        }else if(toUsers.size() == 0)
        {
            result.message = ERROR_TO_USER_NOT_FOUND;
            result.success = false;         
        }else if(email.subject == null){
        	result.message = ERROR_SUBJECT_MISSING;
        	result.success = false;
        }else
        {	
        	//processing the subject
            List<String> processedSubjectLine = Milestone1_Email_Handler.processSubject(email.subject);
            String milestoneAliasName = processedSubjectLine.get(0); 
            String taskName = processedSubjectLine.get(1);
            if(taskName == ''){
            	//Reject code here as there is no task.
                result.message = ERROR_SUBJECT_MISSING_TASK;
                result.success = false;
            }else
            {	
                System.debug('Find the Milestone for Alias: ' + milestoneAliasName); 
                if(milestoneAliasName == ''){
					milestoneAliasName = Milestone1_Settings__c.getOrgDefaults().Default_Milestone_Alias__c;
					if(milestoneAliasName == ''){
						result.message = ERROR_SUBJECT_MISSING_ALIAS;
						result.success = false;
					}                	
                }
                
                milestone = Milestone1_Email_Handler.getMilestone(milestoneAliasName);
                if(milestone == null)
                {
                    //Reject code here as the alias was not found.
                    result.message = ERROR_ALIAS_NOT_FOUND;
                    result.success = false;
                }else 
                {
                	
                    Milestone1_Task__c newTask = Milestone1_Email_Handler.insertMilestoneTask(toUsers,milestone,email,taskName);
                    Milestone1_Email_Handler.insertAttachments(newTask,email);
                    result.success = true;
                }
            }
        }
        return result;
    }
    
    public static Milestone1_Task__c insertMilestoneTask(List<User> toUsers, Milestone1_Milestone__c milestone, Messaging.InboundEmail email, String taskName)
    {
        Milestone1_Task__c newTask = new Milestone1_Task__c();
        newTask.Assigned_To__c = toUsers.get(0).Id;
        newTask.Project_Milestone__c = milestone.Id;
        
        if(taskName.length() > 80)
        {
            newTask.Description__c = taskName + '\n' + email.plainTextBody;   
        }else
        {
            newTask.Description__c =  email.plainTextBody;
        }
      
        newTask.Name = Milestone1_General_Utility.processTaskName(taskName.trim());
        newTask.Email_GUID__c = email.messageId;
        newTask.Last_Email_Received__c = Datetime.now();
        insert newTask;
        system.debug('New Task ID == ' + newTask.Id);
        return newTask;
    }
    
    public static Milestone1_Task__c updateMilestoneTask(Milestone1_Task__c msTask, Messaging.InboundEmail email)
    {
        msTask.Email_GUID__c = email.messageId;
        msTask.Complete__c = false;
        msTask.Last_Email_Received__c = Datetime.now();
        update msTask;
        system.debug('The task ReplyTo chain: ' + msTask.Email_GUID__c);
        return msTask;
    }
    
    public static Note insertNote(Milestone1_Task__c msTask, Messaging.InboundEmail email)
    {
        Note newNote = new Note();
        newNote.parentId = msTask.Id;
        newNote.title = email.subject;
        newNote.body = email.plainTextBody;
        insert newNote;
        system.debug('New Note ID == ' + newNote.Id);
        return newNote;
    }
    
    public static String parseAddress(String emailAddress)
    {
        String[] addressTokens = emailAddress.split(' ');
        String returnEmail = '';
        if(addressTokens != null && addressTokens.size() > 1)
        {
            String buildName = '';
            for(Integer x = 0; x < addressTokens.size() - 1; x++)
            {
                buildName = buildName + addressTokens[x] + ' ';
            }
            buildName = buildName.subString(0,buildName.length() - 1);
            System.debug('Build Name = ' + buildName);
        }
        
        returnEmail = addressTokens[addressTokens.size() -1];
        returnEmail = returnEmail.replace('<','');
        returnEmail = returnEmail.replace('>','');
        system.debug('To adddress email == ' + returnEmail);
        return returnEmail;
    }
    
    /**
    * 	Process the subject extracting the milestone alias and the task name.
    */
    public static List<String> processSubject(String subject)
    {
    	List<String> result = new List<String>();
        if(subject != null){
        	subject =  subject.replaceAll(REGEX_FWD_RE,'');
  			//add the milestone alias
  			result.add(subject.substring(0,subject.indexOf('-')).trim());
  			//add the task name
  			if(subject.lastIndexOf('-')+1 == subject.length()){
    			result.add('');
			}else{
   				result.add(subject.substring(subject.lastIndexOf('-')+1).trim());
			}
        }
        return result;
    }
    
    //Insert the Email's attached files as SFDC Attachment Object on the Milestone Task Object.skh Binary and Text Attachments.
    public static void insertAttachments(Milestone1_Task__c newTask, Messaging.InboundEmail email)
    {
        system.debug('Insert Attachments....');
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = email.binaryAttachments;
        Messaging.InboundEmail.Textattachment[] textAttachments = email.textAttachments;
        List<Attachment> insertAttachments = new List<Attachment>();
        if(binaryAttachments != null)
        {
            system.debug('Binary Attachments != null');
            for(Messaging.InboundEmail.BinaryAttachment currentBinaryAttachment : binaryAttachments)
            {
                if(currentBinaryAttachment.body != null && currentBinaryAttachment.fileName != null)
                {
                    Attachment newAttachment = new Attachment(Name = currentBinaryAttachment.fileName, body = currentBinaryAttachment.body, parentId = newTask.Id );
                    insertAttachments.add(newAttachment);
                }
            }
        }
        if(textAttachments != null)
        {
            system.debug('Text Attachments != null');
            for(Messaging.InboundEmail.Textattachment currentTextAttachment : textAttachments)
            {
                if(currentTextAttachment.body != null && currentTextAttachment.fileName != null)
                {
                    Attachment newAttachment = new Attachment(Name = currentTextAttachment.fileName, body = blob.valueOf(currentTextAttachment.body), parentId = newTask.Id );
                    insertAttachments.add(newAttachment);
                }
            }
        }
        system.debug('Insert the Attachments. Number is ' + insertAttachments.size());
        if(insertAttachments.size() > 0)
        {
            insert insertAttachments;
        }
    }       
    
    /**
    *	Returns a milestone if defined in the param otherwise use the one in the Milestone1_Setting__c
    */
    private static Milestone1_Milestone__c getMilestone( String milestoneAliasName){
    	Milestone1_Milestone__c milestone;
    	if(milestoneAliasName == ''){
    		milestoneAliasName = Milestone1_Settings__c.getOrgDefaults().Default_Milestone_Alias__c;
    	}
    	List<Milestone1_Milestone__c> milestones = [Select Id From Milestone1_Milestone__c where alias__c = :milestoneAliasName limit 1];
        if(!milestones.isEmpty()){
        	milestone = milestones.get(0);
        }        
    	return milestone;
    }
}