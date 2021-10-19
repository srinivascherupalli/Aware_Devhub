import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery';
import setDeliveryDate from '@salesforce/apex/OrderGridControler.setDeliveryDate';
import Id from '@salesforce/user/Id';

export default class productDeliveryDatePicker extends LightningElement {

    @api effectiveAccountId;
    @api pickedDate;
    userId = Id;

    connectedCallback(){
        loadScript(this, jQuery)
        .then(() => {
            let innerStyle = '';
            innerStyle+='<style type="text/css">';
            innerStyle+=' .comm-page-detail-0ZG article.results-container,';
            innerStyle+=' .comm-page-detail-0ZG section[b2b_search_results_tiles-resultstiles_resultstiles],';
            innerStyle+=' .comm-page-detail-0ZG .categoryBreadcrumbs,';
            innerStyle+=' .comm-page-detail-0ZG [b2b_buyer_orders-recordlistheader_recordlistheader],';
            innerStyle+=' .comm-page-home [b2b_buyer_orders-recordlist_recordlist],';
            innerStyle+=' .comm-page-home footer[b2b_buyer_orders-recordlist_recordlist] ';
            innerStyle+='{display:none !important;}';
            innerStyle+='</style>';
            $('head').append(innerStyle);
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }
    handleDatePickedFromCalendar(event) {
        this.pickedDate = event.detail;
        setDeliveryDate({ customerUserId: this.userId , accountId: this.effectiveAccountId, deliveryDate: this.pickedDate })
        .then((result) => {
            console.log('In the success setDeliveryDate Function' + result);
        })
        .catch((error) => {
            console.log('In the Error setDeliveryDate Function'+error);
        });


        if(event.detail) {
            let innerStyle = '';
            innerStyle+='<style type="text/css">';
            innerStyle+=' .comm-page-detail-0ZG article.results-container,';
            innerStyle+=' .comm-page-detail-0ZG section[b2b_search_results_tiles-resultstiles_resultstiles],';
            innerStyle+=' .comm-page-home footer[b2b_buyer_orders-recordlist_recordlist]';
            innerStyle+=' {display:flex !important;}';
            innerStyle+=' .comm-page-detail-0ZG .categoryBreadcrumbs,';
            innerStyle+=' .comm-page-detail-0ZG [b2b_buyer_orders-recordlistheader_recordlistheader],';
            innerStyle+=' .comm-page-home [b2b_buyer_orders-recordlist_recordlist]';
            innerStyle+='{display:block !important;}';
            innerStyle+='</style>';
            $('head').append(innerStyle);
        }
    }
}