trigger Milestone1_Expense_Trigger on Milestone1_Expense__c (before insert, before update) 
{
	if(Trigger.isBefore)
	{
		Milestone1_Expense_Trigger_Utility.handleExpenseBeforeTrigger(Trigger.new);
	}
}