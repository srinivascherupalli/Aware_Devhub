({
    initialize : function(component, event, helper) {
        var newCaseUrl = 'https://dev-manildragroup.cs5.force.com/growersportal/s/create-case';
        component.set('v.notAMemberLink', newCaseUrl);
        
    }
})