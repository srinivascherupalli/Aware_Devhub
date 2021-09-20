import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import getCustomerDeleiveryDates from "@salesforce/apex/DateController.getDeliveryDaysByUser";
import getOrderList from '@salesforce/apex/OrderGridControler.getOrderList';
import setRequiredOrder from '@salesforce/apex/OrderGridControler.setRequiredOrder';
import updateOrderGrid from '@salesforce/apex/OrderGridControler.updateOrderGrid';
import createOrder from '@salesforce/apex/OrderGridControler.createOrder';
import saveOrderLineItem from '@salesforce/apex/OrderGridControler.saveOrderLineItem';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getAllPublicHolidays from '@salesforce/apex/PublicHolidaysController.getAllPublicHolidays';


export default class OrderGrid extends NavigationMixin(LightningElement) {

    userId = Id;

    @api effectiveAccountId;

    //Date Picker  variables.
    @track pickedDate;
    @track isModalOpen;
    @track daysOfWeek = [];
    @track publicHolidays = [];

    @wire(getOrderList, {accountId: '$effectiveAccountId'})
    orders;

   //this for Column Actions

    
   columns = [
        { label: 'Code', fieldName: 'Code__c', hideDefaultActions:true },
        { label: 'Product Name', fieldName: 'Product_Name__c', initialWidth :130, hideDefaultActions:true, wrapText:true},
        { label: 'Price', fieldName: 'Price__c', type: 'currency', hideDefaultActions:true, initialWidth :70 },
        { label: 'Pack Size', fieldName: 'Pack_Size__c', hideDefaultActions:true, cellAttributes: { alignment: 'center' }},
        {label: 'Default Order', type: 'button', fieldName: 'Avg_Of_Orders__c', sortable: true,
            cellAttributes: { alignment: 'center' }, 
            typeAttributes:{ label: { fieldName: 'Avg_Of_Orders__c'}, ref:'Avg_Of_Orders__c'}
        },
        {label: 'Order_1', type: 'button', fieldName: 'Order1__c', sortable: true, cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: true, name:'Select All' }],  
            typeAttributes:{ label: { fieldName: 'Order1__c'}, ref:' Order1__c'}
        },
        {label: 'Order_2', type: 'button', fieldName: 'Order2__c', sortable: true,cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: true, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order2__c'}, ref:'Order2__c'}
        },
        {label: 'Order_3', type: 'button', fieldName: 'Order3__c', sortable: true, cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order3__c'}, ref:'Order3__c'}
        },
        {label: 'Order_4', type: 'button', fieldName: 'Order4__c', sortable: true, cellAttributes: { alignment: 'center' },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order4__c'}, ref:'Order4__c'}
        },
        {label: 'Order_5', type: 'button', fieldName: 'Order5__c', sortable: true, cellAttributes: { alignment: 'center' },
            typeAttributes:{ label: { fieldName: 'Order5__c'}, ref:'Order5__c'}
        },
        {label: 'Order_6', type: 'button', fieldName: 'Order6__c', sortable: true, cellAttributes: { alignment: 'center' },
            typeAttributes:{ label: { fieldName: 'Order6__c'}, ref:'Order6__c'}
        },
        {label: 'Pending', type: 'button', fieldName: 'OrderPending__c', sortable: true, cellAttributes: { alignment: 'center' },
            typeAttributes:{ label: { fieldName: 'OrderPending__c'}, ref:'OrderPending__c'}
        },
        { label: 'Order Required', fieldName: 'Order_Required__c', hideDefaultActions:true, editable: true, cellAttributes: { alignment: 'right' }  },
        { label: 'Price', fieldName: 'Total_Price_Formula__c',hideDefaultActions:true, type: 'currency', initialWidth :70},
        { label: 'Weight', fieldName: 'Total_Weight_Formula__c', hideDefaultActions:true, cellAttributes: { alignment: 'center' } },
    ];
    newLabel = '';
    async connectedCallback() {


        try{
            getOrderList({
                accountId: this.effectiveAccountId
            })
            .then(result => {
                if(result && result.length>0) {
                    let orders = result;
                    let columns = this.columns;
                    let orderLablesFound = [];

                    console.log(orders);
                    if(orders) {
                        for(let orderIndex=0; orderIndex<orders.length; orderIndex++) {
                            let order = orders[orderIndex];
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

            //Date Picker call.
        
            getCustomerDeleiveryDates({
                accountId: this.effectiveAccountId
            }).then((result) =>{
                let daysInAWeek = ['Sunday', 'Monday', 'Tuesday','Wednesday','Thursday','Friday','Saturday'];
                let daysOfWeek = [];
                let daysOfWeekSplit = (result[0].data).split(',');


                for(var i=0; i<daysOfWeekSplit.length; i++) {
                    if(daysOfWeekSplit[i]!= '') {
                        let index = daysInAWeek.indexOf(daysOfWeekSplit[i]);
                        daysOfWeek.push(index.toString());
                    }
                }

                this.daysOfWeek = daysOfWeek;
            }).catch((error) => {
                console.log(error);
            })

            //Get all public holidays 
            getAllPublicHolidays({
                accountId: this.effectiveAccountId
            })
            .then(response => {
                if(response[0].status == 'success') {

                    let data = JSON.parse(response[0].data);
                    let publicHolidays = [];
                    if(data.length>0) {
                        for(var i=0; i<data.length; i++) {
                            if(data[i].Date__c) {
                                publicHolidays.push(data[i].Date__c);
                            }
                        }
                    }
                    
                    this.publicHolidays = publicHolidays;
                }
            }).catch((error) => {
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

    handleHeaderAction  (event) {

        // Retrieves the name of the selected filter
       // const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        console.log('The value of colDef log is:'+colDef.fieldName);
        this.selectedOrder = colDef.fieldName;
        setRequiredOrder({ selectedColumn: this.selectedOrder, accountId: this.effectiveAccountId })
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
        let deliveryDate = this.template.querySelector('.delivery-date');
        if(deliveryDate.reportValidity() && deliveryDate.checkValidity()) {
            createOrder({customerUserId: this.userId , accountId: this.effectiveAccountId, deliveryDate: this.pickedDate})
            .then((result) => {
                console.log(result);
                this.navigateToCartPage(result);
            })
            .catch((error) => {
                console.log('In the create order Function Error: '+error);
            });
        }
    }

    //Get selected cell and populate Required Order Cell. 
    getSelectedOrder(event) {
        try{
            const action = event.detail.action;
            const row = event.detail.row;

            if(action.hasOwnProperty('ref')){
                if(row.hasOwnProperty('Id') && row.hasOwnProperty(action.ref)) {
                    saveOrderLineItem({objId: row.Id, value: parseInt(row[action.ref]) })
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

    navigateToCartPage(cartId) {
        this[NavigationMixin.GenerateUrl]({
          type: "standard__webPage",
          attributes: {
            url: "/s/cart/"+cartId
          }
        }).then((generatedUrl) => {
          document.location = generatedUrl;
        });
      }

      sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onColumnHeaderClick(event) {
        let {fieldName} = event.detail;
        console.log(fieldName);
        setRequiredOrder({ selectedColumn: fieldName, accountId: this.effectiveAccountId })
            .then((result) => {
              refreshApex(this.orders);
            })
            .catch((error) => {
                console.log(error);
                console.log('In the Error Function section'+error);
            });
    }

}