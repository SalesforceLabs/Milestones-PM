trigger Milestone1_Milestone_Trigger on Milestone1_Milestone__c (before insert, before update, before delete,
																 after insert, after update, after delete) {
	
	if(Trigger.isbefore){
		if(Trigger.isDelete){
			Milestone1_Milestone_Trigger_Utility.handleMilestoneDeleteTrigger(trigger.oldMap);
		} 
		else if(Trigger.isUpdate){
			//prevent manual reparenting of Milestones
			Milestone1_Milestone_Trigger_Utility.checkMilestoneManualReparent(trigger.oldMap, trigger.newMap);
		} 
		else {
			//insert
			Milestone1_Milestone_Trigger_Utility.handleMilestoneBeforeTrigger(trigger.new, trigger.newMap);
		}
	} 
	else {
		if(Trigger.isDelete){
			Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.oldMap);
		} 
		else {
			Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.newMap);
		}
	}
	
}