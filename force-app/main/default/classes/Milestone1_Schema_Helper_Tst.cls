@isTest
private class Milestone1_Schema_Helper_Tst {
	static testmethod void getGlobalDescribe(){
		Map<String, Schema.SObjectType> describeResults;
		//Test the caching - the std library method can only be called 10 times
		for(integer i = 0; i < 15; i++){
			describeResults = Milestone1_Schema_Helper.getGlobalDescribe();
		}
		Map<String, Schema.SObjectType> systemResults = Schema.getGlobalDescribe();
		
		System.assertEquals(systemResults.keySet().size(),describeResults.keySet().size(),'global describe is missing keys');
		
	}
	
	static testmethod void isOrgChatterEnabled(){
		System.assertNotEquals(null, Milestone1_Schema_Helper.isOrgChatterEnabled(),'Unable to determine if chatter is enabled in this org.');
	}
}