import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getCustomerDeleiveryDates from "@salesforce/apex/DateController.getDeliveryDaysByUser";
import getOrderList from '@salesforce/apex/OrderGridControler.getOrderList';
import setRequiredOrder from '@salesforce/apex/OrderGridControler.setRequiredOrder';
import updateOrderGrid from '@salesforce/apex/OrderGridControler.updateOrderGrid';
import getOrde1Date from '@salesforce/apex/OrderGridControler.getOrde1Date';
import createOrder from '@salesforce/apex/OrderGridControler.createOrder';
import saveOrderLineItem from '@salesforce/apex/OrderGridControler.saveOrderLineItem';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


const    action0 = [
    { label: 'Select Order', name: 'save_default' }
    ];
const    action1 = [
    { label: 'Select Order', name: 'save_order1' }
    ];
const    action2 = [
        { label: 'Select Order', name: 'save_order2' }
        ];
const    action3 = [
        { label: 'Select Order', name: 'save_order3' }
        ];
const    action4 = [
        { label: 'Select Order', name: 'save_order4' }
        ];
const    action5 = [
        { label: 'Select Order', name: 'save_order5' }
        ];
const    action6 = [
        { label: 'Select Order', name: 'save_order6' }
        ];    
export default class OrderGrid extends LightningElement {

    userId = Id;

    //Date Picker  variables.
    @track pickedDate;
    @track isModalOpen;
    @track daysOfWeek = [];

    @wire(getOrderList, {cuserId: '$userId'})
    orders;

   labelOrder1 = 'O1';
   labelOrder2 = 'O2';
   labelOrder3 = 'O3';
   labelOrder4 = 'O4';
   labelOrder5 = 'O5';
   labelOrder6 = 'O6';

   //this for Column Actions

    
    columns = [
        { label: 'Code', fieldName: 'Code__c',initialWidth :30, hideDefaultActions:true },
        { label: 'Product Name', fieldName: 'Product_Name__c',  initialWidth :100 ,hideDefaultActions:true, wrapText:true},
        { label: 'Price', fieldName: 'Price__c', initialWidth :70,type: 'currency', hideDefaultActions:true },
        { label: 'Pack Size', fieldName: 'Pack_Size__c', hideDefaultActions:true, initialWidth :60 },
        { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action0, menuAlignment: 'right' } },        
        { label: 'Default Order', fieldName: 'Avg_Of_Orders__c', type:'number', hideDefaultActions:true, initialWidth :80, wrapText:true,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] }, 
        { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action1, menuAlignment: 'right' } },
        { label: this.labelOrder1, fieldName: 'Order1__c' ,initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] }, 
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action2, menuAlignment: 'right' } },       
        { label: this.labelOrder2, fieldName: 'Order2__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action3, menuAlignment: 'right' } },
        { label: this.labelOrder3, fieldName: 'Order3__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action4, menuAlignment: 'right' } },
        { label: this.labelOrder4, fieldName: 'Order4__c',initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action5, menuAlignment: 'right' } },
        { label: this.labelOrder5, fieldName: 'Order5__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action6, menuAlignment: 'right' } },
        { label: this.labelOrder6, fieldName: 'Order6__c', initialWidth :75 , hideDefaultActions:true ,actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
            { label: '  ', fieldName: '--', type: 'action', initialWidth :50 ,typeAttributes: { rowActions: action1, menuAlignment: 'right' } },
        { label: 'Pending', fieldName: 'OrderPending__c', initialWidth :75 , hideDefaultActions:true, actions: [
            { label: 'Select', checked: false, name:'Select' },
            ] },
        { label: 'Order Required', fieldName: 'Order_Required__c', hideDefaultActions:true, initialWidth :80, editable: true  },
        { label: 'Price', fieldName: 'Total_Price_Formula__c', hideDefaultActions:true, type: 'currency',initialWidth :60 },
        { label: 'Weight', fieldName: 'Total_Weight_Formula__c', hideDefaultActions:true,initialWidth :60  },
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

        //Date Picker call.
        
        getCustomerDeleiveryDates({

        }).then((result) =>{
            let daysInAWeek = ['Sunday', 'Monday', 'Tuesday','Wednesday','Thursday','Friday','Saturday'];
            let daysOfWeek = [];
            let daysOfWeekSplit = (result[0].data).split(',');


            for(var i=0; i<daysOfWeekSplit.length; i++) {
                if(daysOfWeekSplit[i]!= '') {
                    let index = daysInAWeek.indexOf(daysOfWeekSplit[i]);
                    console.log(index.toString());
                    daysOfWeek.push(index.toString());
                }
            }

            this.daysOfWeek = daysOfWeek;
        }).catch((error) => {
            console.log(error);
        })
       
     }

     
    handleKeyValueChange(event) {
        this.isModalOpen = false;
        this.pickedDate = event.detail;
    }

    handleDateInputClick () {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    selectedOrder = '';
    @track hide;

    handleHeaderAction  (event) {

        // Retrieves the name of the selected filter
       // const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        console.log('The value of colDef log is:'+colDef.fieldName);
        this.selectedOrder = colDef.fieldName;

        console.log(event.detail);
        console.log(colDef);
        console.log(this.selectedOrder);
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
        //Populate the Cart Object.
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
    }

    //Get selected cell and populate Required Order Cell. 
    getSelectedOrder(event) {
        const action = event.detail.action;
            const row = event.detail.row;
        
            switch (action.name) {
                case 'save_default':
                    console.log('The value of Order1 is: '+row.Id);
                    console.log('The value of Avg_Of_Orders__c is: '+row.Avg_Of_Orders__c);
                   //save Order item. 
                    saveOrderLineItem({objId: row.Id, value: row.Avg_Of_Orders__c })
                    .then((result) => {
                        refreshApex(this.orders);
                        console.log('In the create order Function Success: ');
                    })
                    .catch((error) => {
                        console.log('In the create order Function Error: '+error);            
                    });
                    break;
                case 'save_order1':
                    console.log('The value of Order1 is: '+row.Id);
                   //save Order item. 
                    saveOrderLineItem({objId: row.Id, value: row.Order1__c })
                    .then((result) => {
                        refreshApex(this.orders);
                        console.log('In the create order Function Success: ');
                    })
                    .catch((error) => {
                        console.log('In the create order Function Error: '+error);            
                    });
                    break;
                case 'save_order2':
                    console.log('The value of Order1 is: '+row.Id);
                   //save Order item. 
                    saveOrderLineItem({objId: row.Id, value: row.Order2__c })
                    .then((result) => {
                        refreshApex(this.orders);
                        console.log('In the create order Function Success: ');
                    })
                    .catch((error) => {
                        console.log('In the create order Function Error: '+error);            
                    });
                    break;
                    case 'save_order3':
                        console.log('The value of Order1 is: '+row.Id);
                       //save Order item. 
                        saveOrderLineItem({objId: row.Id, value: row.Order3__c })
                        .then((result) => {
                            refreshApex(this.orders);
                            console.log('In the create order Function Success: ');
                        })
                        .catch((error) => {
                            console.log('In the create order Function Error: '+error);            
                        });
                        break;
                        case 'save_order4':
                            console.log('The value of Order1 is: '+row.Id);
                           //save Order item. 
                            saveOrderLineItem({objId: row.Id, value: row.Order4__c })
                            .then((result) => {
                                refreshApex(this.orders);
                                console.log('In the create order Function Success: ');
                            })
                            .catch((error) => {
                                console.log('In the create order Function Error: '+error);            
                            });
                            break;
                            case 'save_order5':
                                console.log('The value of Order1 is: '+row.Id);
                               //save Order item. 
                                saveOrderLineItem({objId: row.Id, value: row.Order5__c })
                                .then((result) => {
                                    refreshApex(this.orders);
                                    console.log('In the create order Function Success: ');
                                })
                                .catch((error) => {
                                    console.log('In the create order Function Error: '+error);            
                                });
                                break;
                                case 'save_order6':
                                    console.log('The value of Order1 is: '+row.Id);
                                   //save Order item. 
                                    saveOrderLineItem({objId: row.Id, value: row.Order6__c })
                                    .then((result) => {
                                        refreshApex(this.orders);
                                        console.log('In the create order Function Success: ');
                                    })
                                    .catch((error) => {
                                        console.log('In the create order Function Error: '+error);            
                                    });
                                    break;
            }
    }

    //Handle cell click
    handleCellClick(event) {
        console.log(event);
        console.log(event.detail);
        console.log(event.detail.value);
        console.log(event.target);
        console.log('hello');
        const rowNode = event.toElement.closest('tr');
        console.log(rowNode);
        // Row index (-1 to account for header row)
        console.log(rowNode.rowIndex - 1);

        // Row Id
        console.log(rowNode.dataset.rowKeyValue);
    }
}