({
    getGrainPricesFromServer : function(component, event, helper) {
        console.log('***In helper');
        var action = component.get('c.getGrainPrices');
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                var responseVal = response.getReturnValue();
                component.set("v.HeaderRow", responseVal.HeaderRow);
                component.set("v.GrainPriceGrid", responseVal.GrainPriceGrid);
                // helper.prepareGrainPriceTable(component, event, helper);
                
            }
            
            else{
                alert('There was some error while processing this information. Please contact the Administrator. Error Message: '+ response);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    prepareGrainPriceTable : function(component, event, helper) {
        var lstGrainPrices = JSON.parse(JSON.stringify(component.get("v.GrainPriceWrapperList")));
        const sites = new Set();
        const binGrades = new Set();
        for (let i=0; i<lstGrainPrices.length; i++){
            sites.add(lstGrainPrices[i].Site);
            binGrades.add(lstGrainPrices[i].BinGrade);
        }
        
        // Convert set to Array
        var sitesArray = Array.from(sites);
        var str = '';
        
        // Create header row and pre
        sitesArray.forEach(function(siteName){
        	str += '<th class="" scope="col">';
            str +=    '<div class="slds-truncate" title="Opportunity Name"> </div>';
      		str += '</th>';
        });
        
        component.find("headerRow1").innerHTML = str;
    }
})