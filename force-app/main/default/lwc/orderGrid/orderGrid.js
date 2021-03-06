import { LightningElement, track, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import getOrderList from '@salesforce/apex/OrderGridControler.getOrderList';
import setRequiredOrder from '@salesforce/apex/OrderGridControler.setRequiredOrder';
import setPriceInGrid from '@salesforce/apex/OrderGridControler.setPriceInGrid';
import updateOrderGrid from '@salesforce/apex/OrderGridControler.updateOrderGrid';
import createOrder from '@salesforce/apex/OrderGridControler.createOrder';
import saveOrderLineItem from '@salesforce/apex/OrderGridControler.saveOrderLineItem';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class OrderGrid extends NavigationMixin(LightningElement) {

    userId = Id;

    @api effectiveAccountId;
    @api isZeroDollarProductPresent = false;

    //Date Picker  variables.
    @track pickedDate;
    @track isModalOpen;
    @track daysOfWeek = [];
    @track publicHolidays = [];
    

    columns = [
        { label: 'Code', fieldName: 'Code__c', hideDefaultActions:true, cellAttributes: {
            class:{
                fieldName: 'styleClass'
            }
        } },
        { label: 'Product Name', fieldName: 'Product_Name__c', initialWidth :130, hideDefaultActions:true, wrapText:true, cellAttributes: {
            class:{
                fieldName: 'styleClass'
            }
        }},
        { label: 'Price', fieldName: 'Price__c', type: 'currency', hideDefaultActions:true, initialWidth :70, cellAttributes: {
            class:{
                fieldName: 'styleClass'
            }
        } },
        { label: 'Pack Size', fieldName: 'Pack_Size__c', hideDefaultActions:true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } }},
        {label: 'Default Order', type: 'button', fieldName: 'Avg_Of_Orders__c', sortable: true,
            cellAttributes: { alignment: 'center', class:{
                fieldName: 'styleClass'
            } }, 
            typeAttributes:{ label: { fieldName: 'Avg_Of_Orders__c'}, ref:'Avg_Of_Orders__c'}
        },
        {label: 'Order_1', type: 'button', fieldName: 'Order1__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            actions: [{ label: 'Select All', checked: true, name:'Select All' }],  
            typeAttributes:{ label: { fieldName: 'Order1__c'}, ref:' Order1__c'}
        },
        {label: 'Order_2', type: 'button', fieldName: 'Order2__c', sortable: true,cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            actions: [{ label: 'Select All', checked: true, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order2__c'}, ref:'Order2__c'}
        },
        {label: 'Order_3', type: 'button', fieldName: 'Order3__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order3__c'}, ref:'Order3__c'}
        },
        {label: 'Order_4', type: 'button', fieldName: 'Order4__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            actions: [{ label: 'Select All', checked: false, name:'Select All' }],
            typeAttributes:{ label: { fieldName: 'Order4__c'}, ref:'Order4__c'}
        },
        {label: 'Order_5', type: 'button', fieldName: 'Order5__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            typeAttributes:{ label: { fieldName: 'Order5__c'}, ref:'Order5__c'}
        },
        {label: 'Order_6', type: 'button', fieldName: 'Order6__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            typeAttributes:{ label: { fieldName: 'Order6__c'}, ref:'Order6__c'}
        },
        {label: 'Pending', type: 'button', fieldName: 'OrderPending__c', sortable: true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } },
            typeAttributes:{ label: { fieldName: 'OrderPending__c'}, ref:'OrderPending__c'}
        },
        { label: 'Order Required', fieldName: 'Order_Required__c', hideDefaultActions:true, editable: true, cellAttributes: { alignment: 'right', class:{
            fieldName: 'styleClass'
        } }  },
        { label: 'Price', fieldName: 'Total_Price_Formula__c',hideDefaultActions:true, type: 'currency', initialWidth :70, cellAttributes: { alignment: 'right', class:{
            fieldName: 'styleClass'
        } }},
        { label: 'Weight', fieldName: 'Total_Weight_Formula__c', hideDefaultActions:true, cellAttributes: { alignment: 'center', class:{
            fieldName: 'styleClass'
        } } },
    ];
    
    @wire(getOrderList, {accountId: '$effectiveAccountId'})
    orderList(result) {
        this.orders = result;
        if (result.data) {
            this.styleGridRows();
            this.populateGridColumnLabels();
        } else if (result.error) {
          //do nothing
        }
    }

    //variable for checkbox
    selection = 'payOffline'; 
    newLabel = '';
    
    styleGridRows() {
        if(this.orders) {
            let orders = this.orders.data;
            this.isZeroDollarProductPresent = false;
            this.orders.data = orders.map(item=>{
                let styleClass = 'temp';

                if(item.Price__c == 0) {
                    styleClass = 'zero-product';
                    this.isZeroDollarProductPresent = true;
                } 
                return {...item, 
                    "styleClass":styleClass
                }
            })
        }
        
    }

    populateGridColumnLabels() {
        if(this.orders) {
            let orders = this.orders.data;
            let columns = this.columns;
            let orderLablesFound = [];

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
                                    
                                    if(order['Order'+prevOrderIndex+'_Date__c']) {
                                        let dateString = new Date(order['Order'+prevOrderIndex+'_Date__c']);
                                        let day = (dateString.getDate()).toString();
                                        let month = dateString.getMonth();
                                        month = (month+1).toString();
                                        
                                        if(day.length == 1) {
                                            day = '0'+day;
                                        }
                                        
                                        
                                        if(month.length == 1) {
                                            month = '0'+month;
                                        }
                                        columns[columnIndex].label = day+'/'+month;
                                    }
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

    //Here selected itmes are populated in the Cart. 
    handleNextClick(){
        //let deliveryDate = this.template.querySelector('.delivery-date');
        //if(deliveryDate.reportValidity() && deliveryDate.checkValidity()) {
        if(this.pickedDate && (this.pickedDate).length>0 ) {
            createOrder({customerUserId: this.userId , accountId: this.effectiveAccountId, deliveryDate: this.pickedDate, paymentMethod: this.selection})
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

    handleCheckboxChange(){
        const checked = Array.from(
            this.template.querySelectorAll('lightning-input')
        )
            // Filter down to checked items
            .filter(element => element.checked)
            // Map checked items to their labels
            .map(element => element.name);
            if(checked.length > 0){
                this.selection = checked.join(', ');
            }
            else{
                this.selection = 'payOffline';
            }

        console.log('Value of the checkbox: '+this.selection);    

    }

    handleDatePickedFromCalendar(event) {
        this.pickedDate = event.detail;
        //Call the method to Set Price in the Grid. 
        setPriceInGrid({ accountId: this.effectiveAccountId, deliveryDate: this.pickedDate })
            .then((result) => {
              refreshApex(this.orders);
              console.log('In the success after date selection: ' +result);
            })
            .catch((error) => {
                console.log('In the Error Function section'+error);
            });

    }
    
}