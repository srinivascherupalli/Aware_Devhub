import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery';

export default class productDeliveryDatePicker extends LightningElement {

    @api effectiveAccountId;
    @api pickedDate;

    connectedCallback(){
        loadScript(this, jQuery)
        .then(() => {
            $('head').append('<style type="text/css"> article.results-container,section[b2b_search_results_tiles-resultstiles_resultstiles], div.categoryBreadcrumbs  {display:none !important;} </style>');
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }
    handleDatePickedFromCalendar(event) {
        //console.log(event.detail);
        //this.pickedDate = event.detail;
        $('head').append('<style type="text/css"> article.results-container,section[b2b_search_results_tiles-resultstiles_resultstiles] {display:flex !important;} div.categoryBreadcrumbs {display:block !important;} </style>');
    }
}