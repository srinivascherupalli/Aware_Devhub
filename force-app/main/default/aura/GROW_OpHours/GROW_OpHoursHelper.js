({
    setSiteWrapperhelper : function(component, event, helper) {
        console.log('***In helper');
        var action = component.get('c.getSites');
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                //var responseVal = response.getReturnValue();
                component.set('v.SitesWrapperList', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})