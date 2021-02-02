public with sharing class Milestone1_Schema_Helper {
	private static Map<String, Schema.SObjectType> globalDescribe;
	
	/**
	 * A version of Schema.getGlobalDescribe() with caching to help
	 * avoid govenor limits. It also ensures the sObject types are lower case and that objects include their namespace, if any.
	 * @author capeterson
	 **/
	public static Map<String, Schema.SObjectType> getGlobalDescribe(){
		if(globalDescribe == null){
			globalDescribe = new Map<String, Schema.sObjectType>();
			Map<String, Schema.SObjectType> sfDescribe = Schema.getGlobalDescribe();
			for(String key:sfDescribe.keySet()){
				String objName = sfDescribe.get(key).getDescribe().getName().toLowerCase(); //get the object name with namespace in lower case
				globalDescribe.put(objName,sfDescribe.get(key));
			}
		}
		return globalDescribe;
	}
	
	/**
	 * If chatter is enabled the user sObject is ALWAYS chatter enabled, and cannot be disabled,
	 * so we use it as a quick and easy test for chatter-ness.
	 * @author capeterson
	 **/
	public static boolean isOrgChatterEnabled(){
		return Schema.sObjectType.User.isFeedEnabled();
	}
}