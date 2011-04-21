trigger Milestone1_Time_Trigger on Milestone1_Time__c (before insert, before update) 
{
	if(Trigger.isBefore)
	{
		Milestone1_Time_Trigger_Utility.handleTimeBeforeTrigger(Trigger.new);
	}

}