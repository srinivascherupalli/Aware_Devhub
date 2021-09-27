import { LightningElement, track, api, wire } from 'lwc';
import getAllPublicHolidays from '@salesforce/apex/PublicHolidaysController.getAllPublicHolidays';
import getCustomerDeleiveryDates from "@salesforce/apex/DateController.getDeliveryDaysByUser";

export default class OrderGrid extends LightningElement {

    
    @track daysOfWeek = [];
    @track publicHolidays = [];
    @track pickedDate;
    @track isModalOpen;
    @api effectiveAccountId;

    async connectedCallback() {
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

    }

    handleKeyValueChange(event) {
        this.isModalOpen = false;
        this.pickedDate = event.detail;

        const selectedEvent = new CustomEvent('datepicked', {
            detail:event.detail
        });
        this.dispatchEvent(selectedEvent);

        window.setTimeout(() => {
            let deliveryDate = this.template.querySelector('.delivery-date');
            deliveryDate.reportValidity();
        });
        
    }

    handleDateInputClick () {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
}