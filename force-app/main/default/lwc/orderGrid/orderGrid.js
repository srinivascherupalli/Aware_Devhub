import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getOrderList from '@salesforce/apex/OrderGridControler.getOrderList';
import setRequiredOrder from '@salesforce/apex/OrderGridControler.setRequiredOrder';
import updateOrderGrid from '@salesforce/apex/OrderGridControler.updateOrderGrid';
import getOrde1Date from '@salesforce/apex/OrderGridControler.getOrde1Date';
import createOrder from '@salesforce/apex/OrderGridControler.createOrder';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class OrderGrid extends LightningElement {

    userId = Id;

    @wire(getOrderList, {cuserId: '$userId'})
    orders;

   labelOrder1 = 'O1';
   labelOrder2 = 'O2';
   labelOrder3 = 'O3';
   labelOrder4 = 'O4';
   labelOrder5 = 'O5';
   labelOrder6 = 'O6';
    
    columns = [
        { label: 'Code', fieldName: 'Code__c',initialWidth :30, hideDefaultActions:true },
        { label: 'Product Name', fieldName: 'Product_Name__c',  initialWidth :200 ,hideDefaultActions:true},
        { label: 'Price', fieldName: 'Price__c', initialWidth :70,type: 'currency', hideDefaultActions:true },
        { label: 'Pack Size', fieldName: 'Pack_Size__c', hideDefaultActions:true, initialWidth :60 },
        { label: 'Default Order', fieldName: 'Default_Order__c', type: 'number', initialWidth :80 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder1, fieldName: 'Order1__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder2, fieldName: 'Order2__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder3, fieldName: 'Order3__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder4, fieldName: 'Order4__c',initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder5, fieldName: 'Order5__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: this.labelOrder6, fieldName: 'Order6__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: 'Pending', fieldName: 'OrderPending__c', initialWidth :75 , hideDefaultActions:true, actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: 'Order Required', fieldName: 'Order_Required__c', hideDefaultActions:true, initialWidth :100, editable: true  },
        { label: 'Price', fieldName: 'Total_Price_Formula__c', hideDefaultActions:true, type: 'currency',initialWidth :70 },
        { label: 'Weight', fieldName: 'Total_Weight_Formula__c', hideDefaultActions:true },
    ];
    newLabel = '';
    async connectedCallback() {
      let fLen = this.columns.length;
     // uId = this.userId;
      this.newLabel = 'nLable';
        getOrde1Date({cuserId: this.userId})
        .then((result) => {
            this.newLabel = result;
            console.log('result:'+ result);
            //set the column values.
            let text = 'ff';
            for (let i = 0; i < fLen; i++) {
                text = this.columns[i].label;
                if(text == 'O1'){
                    console.log('This this.newLabel[0]: '+ this.newLabel[0]);
                    if(this.newLabel[0] == 'undefined' || this.newLabel[0] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[0];
                    }
                }
                if(text == 'O2'){
                    console.log('This this.newLabel[0]: '+ this.newLabel[1]);                    
                    if(this.newLabel[1] == 'undefined' || this.newLabel[1] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[1];
                    }
                }
                if(text == 'O3'){
                    console.log('This this.newLabel[2]: '+ this.newLabel[2]);
                    if(this.newLabel[2] == 'undefined' || this.newLabel[2] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[2];
                    }

                }
                if(text == 'O4'){
                    console.log('This this.newLabel[0]: '+ this.newLabel[3]);
                    if(this.newLabel[3] == 'undefined' || this.newLabel[3] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[3];
                    }
                    
                }
                if(text == 'O5'){
                    console.log('This this.newLabel[0]: '+ this.newLabel[4]);
                    if(this.newLabel[4] == 'undefined' || this.newLabel[4] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[4];
                    }
                    
                }
                if(text == 'O6'){
                    console.log('This this.newLabel[0]: '+ this.newLabel[5]);
                    if(this.newLabel[5] == 'undefined' || this.newLabel[5] == null){
                        this.columns[i].label= '--';
                    }
                    else{
                        this.columns[i].label= this.newLabel[5];
                    }
                    
                }
              }
              this.columns = [...this.columns]; 
        })
        .catch((error) => {
            console.log('In the Error Function section'+this.error);
        });
       
     }

    selectedOrder = '';
    @track hide;

    handleHeaderAction  (event) {

        // Retrieves the name of the selected filter
       // const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        console.log('The value of colDef log is:'+colDef.fieldName);
        this.selectedOrder = colDef.fieldName;
        setRequiredOrder({ selectedColumn: this.selectedOrder, cuserId: this.userId })
            .then((result) => {
                console.log('In the success Function section');
              //  this.contacts = result;
              //  this.error = undefined;
              refreshApex(this.orders);
            })
            .catch((error) => {
                console.log('In the Error Function section'+error);
              //  this.error = error;
               // this.contacts = undefined;
            });

    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        // Prepare the record IDs for getRecordNotifyChange()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });
    
        try {
            // Pass edited fields to the updateContacts Apex controller
            const result = await updateOrderGrid({data: updatedFields});
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Order updated',
                    variant: 'success'
                })
            );
    
            // Refresh LDS cache and wires
            getRecordNotifyChange(notifyChangeIds);
    
            // Display fresh data in the datatable
            refreshApex(this.orders).then(() => {

               this.columns = [...this.columns]; 
                this.hide = true;
            });
       } catch(error) {

        };
    }

    handleHideShow(){
        this.hide = false;
    }

    handleNextClick(){
        //TODO: Create the Order Object.
        createOrder({cuserId: this.userId})
        .then((result) => {
            console.log('In the create order Function Success: ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Order Transfered to Cart.',
                    variant: 'success'
                })
            );

        })
        .catch((error) => {
            console.log('In the create order Function Error: '+error);

        });
        //TODO: Populate the Shopping Cart


        //TODO: Populate EndDate in the Order Object. 
    }
}