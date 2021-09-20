({
	initData : function(component, event, helper) {
		console.log('***In controller');
        helper.getGrainPricesFromServer(component, event, helper);
	}
})