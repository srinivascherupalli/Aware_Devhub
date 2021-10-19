import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/JQuery';

export default class Test1 extends LightningElement {

    @api effectiveAccountId;

    connectedCallback(){
        console.log('inside connected');
        loadScript(this, jQuery)
        .then(() => {
            console.log('inside 1');
            $('head').append('<style type="text/css"> .results-container[b2b_search_results_tiles-resultstiles_resultstiles],[b2b_buyer_product_category-banner_banner-host], div.categoryBreadcrumbs, [b2b_search_results_tiles-resultstiles_resultstiles]  {display:none !important;} </style>');
        })
        .catch(error=>{
            console.log('Failed to load the JQuery : ' +error);
        });
    }
    handleDatePickedFromCalendar(event) {
        $('head').append('<style type="text/css"> .results-container[b2b_search_results_tiles-resultstiles_resultstiles], div.categoryBreadcrumbs, [b2b_search_results_tiles-resultstiles_resultstiles]  {display:block !important;} [b2b_buyer_product_category-banner_banner-host] {display:grid !important;}</style>');
    }
}