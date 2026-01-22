trigger Milestone1_Project_Trigger on Milestone1_Project__c (before update, before delete, before insert ) {
    
    if( Trigger.isUpdate ){
    	//TODO can we delete this?
        Milestone1_Project_Trigger_Utility.handleProjectUpdateTrigger(trigger.new);
    } 
    else if( Trigger.isDelete ) {
    	//cascades through milestones
        Milestone1_Project_Trigger_Utility.handleProjectDeleteTrigger(trigger.old);
    }
    else if( Trigger.isInsert ) {
    	//checks for duplicate names
        Milestone1_Project_Trigger_Utility.handleProjectInsertTrigger( trigger.new );
    }

}