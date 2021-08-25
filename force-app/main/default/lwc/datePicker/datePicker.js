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

export default class OrderGrid extends LightningElement {

    userId = Id;

    //Date Picker  variables.
    @track pickedDate;
    @track isModalOpen;
    @track daysOfWeek = [];
    @track orders;
    @track selectedOrder = '';
    @track hide;

    @wire(getOrderList, {cuserId: '$userId'})
    orders;

    //data grid columns
    columns = [
        { label: 'Code', fieldName: 'Code__c',initialWidth :70, hideDefaultActions:true },
        { label: 'Product Name', fieldName: 'Product_Name__c', initialWidth :150, hideDefaultActions:true, wrapText:true},
        { label: 'Price', fieldName: 'Price__c',initialWidth :80, type: 'currency', hideDefaultActions:true },
        { label: 'Pack Size', fieldName: 'Pack_Size__c',initialWidth :100, hideDefaultActions:true, cellAttributes: { alignment: 'center' }},
        {label: 'Default', type: 'button', fieldName: 'Avg_Of_Orders__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],  
            typeAttributes:{ label: { fieldName: 'Avg_Of_Orders__c'}, name: '0', ref:'Avg_Of_Orders__c'}
        },
        {label: 'Order_1', type: 'button', fieldName: 'Order1__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],  
            typeAttributes:{ label: { fieldName: 'Order1__c'}, name: '1', ref:'Order1__c'}, initialWidth :80
        },
        {label: 'Order_2', type: 'button', fieldName: 'Order2__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order2__c'}, name: '2', ref:'Order2__c'}, initialWidth :80
        },
        {label: 'Order_3', type: 'button', fieldName: 'Order3__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order3__c'}, name: '3', ref:'Order3__c'}, initialWidth :80
        },
        {label: 'Order_4', type: 'button', fieldName: 'Order4__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order4__c'}, name: '4', ref:'Order4__c'}, initialWidth :80
        },
        {label: 'Order_5', type: 'button', fieldName: 'Order5__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order5__c'}, name: '5', ref:'Order5__c'}, initialWidth :80
        },
        {label: 'Order_6', type: 'button', fieldName: 'Order6__c', cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order6__c'}, name: '6', ref:'Order6__c'}, initialWidth :80
        },
        { label: 'Required', fieldName: 'Order_Required__c',initialWidth :80, hideDefaultActions:true, editable: true, cellAttributes: { alignment: 'center' }  },
        { label: 'Price', fieldName: 'Total_Price_Formula__c',initialWidth :80, hideDefaultActions:true, type: 'currency'},
        { label: 'Weight', fieldName: 'Total_Weight_Formula__c',initialWidth :80, hideDefaultActions:true, cellAttributes: { alignment: 'center' } },
    ];
    newLabel = '';
    connectedCallback() {
        try{
            getOrderList({
                cuserId: this.userId
            })
            .then(result => {
                if(result && result.length>0) {
                    let orders = result;
                    let columns = this.columns;
                    let orderLablesFound = [];

                    if(orders) {
                        for(let orderIndex=0; orderIndex<orders.length; orderIndex++) {
                            let order = orders[orderIndex];

                            console.log(order);

                            for(let prevOrderIndex=1; prevOrderIndex<=6; prevOrderIndex++) {
                                if(order.hasOwnProperty('Order'+prevOrderIndex+'_Date__c')) {
                                    for (let columnIndex = 0; columnIndex < columns.length; columnIndex++) {
                                        if(columns[columnIndex].label == 'Order_'+prevOrderIndex) {
                                            if(orderLablesFound.indexOf(columns[columnIndex].label) == -1 && (columns[columnIndex].label).indexOf('Order_')!= -1) {
                                                orderLablesFound.push(columns[columnIndex].label);
                                            }
                                            
                                            let dateString = order['Order'+prevOrderIndex+'_Date__c'];
                                            let dateSplit = dateString.split('-');
                                            columns[columnIndex].label = dateSplit[2]+'/'+dateSplit[1];
                                        }
                                    }
                                }
                            }
                        }
                    }

                    for (let columnIndex = 0; columnIndex < columns.length; columnIndex++) {
                        if((columns[columnIndex].label).indexOf('Order_')!= -1) {
                            for(let i=0; i<=6; i++) {
                                if(orderLablesFound.indexOf(columns[columnIndex].label) == -1 && (columns[columnIndex].label).indexOf('Order_'+i)!= -1) {
                                    columns = columns.filter(col => col.label !== columns[columnIndex].label);
                                }
                            }
                        }
                    }
                    //Hide all other previous order columns when there is no previous data
                    this.columns = [...columns];
                }
            })
            .catch(error => {
                console.log(error);
            });
        } catch(error) {
            console.log(error);
        }
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


    //Get selected cell and populate Required Order Cell. 
    getSelectedOrder(event) {
        try{
            const action = event.detail.action;
            const row = event.detail.row;

            if(action.hasOwnProperty('ref')){
                if(row.hasOwnProperty('Id') && row.hasOwnProperty(action.ref)) {
                    saveOrderLineItem({objId: row.Id, value: row[action.ref] })
                    .then((result) => {
                        refreshApex(this.orders);
                    })
                    .catch((error) => {
                        console.log('In the create order Function Error: '+error);            
                    });
                }
            }
        } catch(error) {
            console.log(error);
        }
    }

    handleHeaderAction (event) {
        const colDef = event.detail.columnDefinition;
        this.selectedOrder = colDef.fieldName;

        setRequiredOrder({ selectedColumn: this.selectedOrder, cuserId: this.userId })
            .then((result) => {
              refreshApex(this.orders);
            })
            .catch((error) => {
                console.log(error);
            });

    }
}