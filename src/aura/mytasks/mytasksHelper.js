({
	getsetTasks : function(component, apexFunction) {
		var action = component.get(apexFunction);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                var theTasks = component.get("v.tasks");
                theTasks = response.getReturnValue();
                component.set("v.tasks", theTasks);
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
		
        $A.enqueueAction(action);
	}
})