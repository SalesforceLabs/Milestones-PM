({

    incompleteTasks : function(component, event, helper) {
        helper.getsetTasks(component, "c.getIncompletedTasks");
    },
    lateTasks : function(component, event, helper) {
        helper.getsetTasks(component, "c.getLateTasks");
    },
    blockedTasks : function(component, event, helper) {
        helper.getsetTasks(component, "c.getBlockedTasks")
    },
    deleteTasks : function(component, event, helper) {
        var theTasks = component.get("v.tasks");
        theTasks = null;
        component.set("v.tasks", theTasks);
    }
})