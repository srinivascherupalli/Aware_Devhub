import { LightningElement, api, track, wire } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import * as Constants from './constants';

import getPaymentInfo from '@salesforce/apex/B2BPaymentController.getPaymentInfo';
import setPayment from '@salesforce/apex/B2BPaymentController.setPayment';
//import addDiscountItem from '@salesforce/apex/DiscountController.addDiscountItem';
//import isDiscountItemIncluded from '@salesforce/apex/DiscountController.isDiscountItemIncluded';


import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USE_SAVED_CARDS from "@salesforce/schema/User.Contact.B2B_Use_Stored_Credit_Cards__c";
import USER_ID from "@salesforce/user/Id";

const columns = [
    { label: 'Card Number', fieldName: 'DisplayCardNumber' },
    { label: 'Card Type', fieldName: 'CardType' }
];


/**
 * Allows users to choose the type of payment (eg. Purchase Order, Credit Card)
 * and to fill out the required information for the chosen type.
 *
 * @fires FlowNavigationNextEvent
 * @fires FlowNavigationBackEvent
 * @fires PaymentMethod#submitpayment
 */
export default class PaymentMethod extends LightningElement {

    @wire(getRecord, { recordId: USER_ID, fields: [USE_SAVED_CARDS] })
    user;
  
    _useSavedCardsFlag = 'false';

    get useSavedCards() {
        var bRet = getFieldValue(this.user.data, USE_SAVED_CARDS);
        this._useSavedCardsFlag = bRet + '';
        console.log("#### useSavedCardsFlag : " + this._useSavedCardsFlag);
        return bRet;
    }

    // Private attributes
    @track hasPreviousCards;

    columns = columns;    
    _addresses;
    _previousCards;
    _creditCardErrorMessage;
    _purchaseOrderErrorMessage = '';
    _cartId;
    _purchaseOrderNumber;
    _selectedBillingAddress;
    _selectedPaymentType = Constants.PaymentTypeEnum.PONUMBER;

    /**
     * Determines if Purchase Order is a required field.
     * @type {Boolean}
     */
    @api poRequired = false;

    /**
     * Determines if Card Holder Name is a required field.
     * @type {Boolean}
     */
    @api cardHolderNameRequired = false;

    /**
     * Determines if Card Type is a required field.
     * @type {Boolean}
     */
    @api cardTypeRequired = false;

    /**
     * Determines if Expiry Month is a required field.
     * @type {Boolean}
     */
    @api expiryMonthRequired = false;

    /**
     * Determines if Expiry Year is a required field.
     * @type {Boolean}
     */
    @api expiryYearRequired = false;

    /**
     * Determines if CVV is a required field.
     * @type {Boolean}
     */
    @api cvvRequired = false;

    /**
     * Determines if Card Holder Name is a hidden field.
     * @type {Boolean}
     */
    @api hideCardHolderName = false;

    /**
     * Determines if Card Type is a hidden field.
     * @type {Boolean}
     */
    @api hideCardType = false;

    /**
     * Determines if CVV is a hidden field.
     * @type {Boolean}
     */
    @api hideCvv = false;

    /**
     * Determines if Expiry Month is a hidden field.
     * @type {Boolean}
     */
    @api hideExpiryMonth = false;

    /**
     * Determines if Expiry Year is a hidden field.
     * @type {Boolean}
     */
    @api hideExpiryYear = false;

    /**
     * Determines if Purchase Order is a hidden option.
     * @type {Boolean}
     */
    @api hidePurchaseOrder = false;

    /**
     * Determines if Credit Card is a hidden option.
     * @type {Boolean}
     */
    @api hideCreditCard = false;

    /**
     * Text to display on the Previous button. Defaults to "Previous".
     * @type {String}
     */
    @api previousButtonLabel = 'Previous';

    /**
     * Text to display on the Next button. Defaults to "Next".
     * @type {String}
     */
    @api nextButtonLabel = 'Next';

    /**
     * The list of labels used in the cmp. 
     * @type {String}
     */
    get labels() {
        return Constants.labels;
    }

    /**
     * Gets or sets the currently selected payment type.
     *
     * The value of this property is updated in response to user interactions with the control.
     *
     * @type {String}
     */
    @api
    get selectedPaymentType() {
        return this._selectedPaymentType;
    }

    set selectedPaymentType(newPaymentType) {
        this._selectedPaymentType = newPaymentType;
    }

    /**
     * The purchase order number. Used to pass the purchase order to the server and to
     * display the existing purchase order when the component loads.
     *
     * The value of this property is updated in response to user interactions with the control.
     *
     * @type {string}
     */
    @api
    get purchaseOrderNumber() {
        return this._purchaseOrderNumber;
    }

    set purchaseOrderNumber(newNumber) {
        this._purchaseOrderNumber = newNumber;
    }

    @api
    get paymentType() {
        return this._selectedPaymentType;
    }
    
    /**
     * The address data. Used to pass the user's addresses to the child billing address components.
     * @type {Address[]}
     */
    @api
    get addresses() {
        return this._addresses;
    }

    set addresses(billingAddresses) {
        this._addresses = billingAddresses;
    }

    @api
    get previousCards() {
        return this._previousCards;
    }

    set previousCards(previousCardDetails) {
        this._previousCards = previousCardDetails;
    }

    /**
     * Gets or sets the selected billing address.
     * @type {String}
     */
    @api
    get selectedBillingAddress() {
        return this._selectedBillingAddress;
    }

    set selectedBillingAddress(address) {
        this._selectedBillingAddress = address;
    }

    /**
     * Determines if Billing Address is a hidden field.
     * @type {Boolean}
     */
    @api hideBillingAddress = false;

    /**
     * Determines if the billing address field should be marked required.
     * @type {Boolean}
     */
    @api billingAddressRequired = false;

    /**
     * The error message string if there is an error with displaying billing addresses.
     * Errors that are possible are no access to web cart/ no access to CPA/ or no billing addresses in the list.
     *
     * @type {String}
     */
    @api billingAddressErrorMessage;

    /**
     * The cartId for the current webCart.
     * @return {String} the webCartID
     */
    @api
    get cartId() {
        return this._cartId;
    }

    /**Added by : WY
     * Check if cart had a Discount Item set. 
     */
    /* async connectedCallback() {
        isDiscountItemIncluded({
            cartIdValue: this.cartId
        }).then((result) =>{
           if(result){
            this.hidePurchaseOrder = true;
            this.hideCreditCard = false;
           }
           else{
            this.hidePurchaseOrder = false;
            this.hideCreditCard = true;
           }
        }).catch((error) => {
            console.log(error);
        })
     }*/

    /**
     * Sets the cartId of the current webCart.
     * @param {String} cartId
     */
    set cartId(cartId) {
        this._cartId = cartId;
        if (cartId) {
            this.initializePaymentData(cartId);
        }
    }

    /**
     * Gets the payment types
     * PO Number or Card Payment
     */
    get paymentTypes() {
        return {
            poNumber: Constants.PaymentTypeEnum.PONUMBER,
            cardPayment: Constants.PaymentTypeEnum.CARDPAYMENT
        };
    }

    /**
     * Get state of selected payment type
     * @return {boolean} true if selected payment type is Card Payment
     */
    get isCardPaymentSelected() {
        return (
            this.actualSelectedPaymentType ===
                Constants.PaymentTypeEnum.CARDPAYMENT && !this.hideCreditCard
        );
    }

    /**
     * Get state of selected payment type
     * @return {boolean} true if selected payment type is PO number
     */
    get isPoNumberSelected() {
        return (
            this.actualSelectedPaymentType ===
            Constants.PaymentTypeEnum.PONUMBER && !this.hidePurchaseOrder
        );
    }

    /**
     * Get the selected payment type.
     * If hidePurchaseOrder is true, default to cardPayment.
     * if hideCreditCard is true, default to PurchaseOrderNumber.
     * @private
     */
    get actualSelectedPaymentType() {
        return this.hidePurchaseOrder
        ? Constants.PaymentTypeEnum.CARDPAYMENT
        : (this.hideCreditCard ? Constants.PaymentTypeEnum.PONUMBER : this._selectedPaymentType);
    }

    /**
     * Handler to initialize the payment component
     * @param {String} cartId - the current webCart ID
     */
    initializePaymentData(cartId) {
        // If we don't have those values yet
        getPaymentInfo({ cartId: cartId })
            .then((data) => {
                this._purchaseOrderNumber = data.purchaseOrderNumber;
                this._addresses = data.addresses;
                this._previousCards = data.previousCards;
                console.log("## previousCards : " + JSON.stringify(this._previousCards));
                debugger;
                if(this._previousCards.length === 0){
                    hasPreviousCards = false;
                }else{
                    hasPreviousCards = true;
                }
        
                debugger;
                console.log('## previousCards: ' + this._previousCards);
            })
            .catch((error) => {
                //do nothing, continue as normal
            });
    }

    /**
     * Handler for the 'blur' event fired from the purchase order input.
     */
    handleUpdate() {
        const poComponent = this.getComponent('[data-po-number]');
        const poData = (poComponent.value || '').trim();
        this._purchaseOrderNumber = poData;
    }

    /**
     * Handler for the 'click' event fired from the payment type radio buttons.
     * @param {event} event - The selected payment type
     */
    handlePaymentTypeSelected(event) {
        this._selectedPaymentType = event.currentTarget.value;

        /*
        if (
            event.currentTarget.value === Constants.PaymentTypeEnum.CARDPAYMENT
        ) {
            console.log("## calling addDiscountItem.." + event.currentTarget.value);
            addDiscountItem({
                cartId: this.cartId
            }).then(() => {
            }).catch((error) => {
                this._purchaseOrderErrorMessage = error.body.message;
            });
        }
        */
    }

    /**
     * Navigates to the previous page. Doesn't save any information, so that information is lost on clicking
     * Previous.
     */
    handlePreviousButton() {
        const navigatePreviousEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePreviousEvent);
    }

    /**
     * Handler for the 'click' event fired from the payment button.
     * If PO Number is selected, make an apex call to set the new values.
     * If Credit Card is selected, check to see that all required fields are filled in first,
     * then makes an apex call which in turns makes a call to Payment.tokenize endpoint
     */
    handlePaymentButton() {
        const selectedAddressResult = this.getBillingAddress();
        debugger;
        if (
            this.selectedPaymentType !== Constants.PaymentTypeEnum.CARDPAYMENT
        ) {
            if (selectedAddressResult.error) {
                this._purchaseOrderErrorMessage = selectedAddressResult.error;
                return;
            }

            const poInput = this.getComponent('[data-po-number]');            
            // Make sure that PO input is valid first
            if (
                poInput != null &&
                !poInput.reportValidity()
            ) {
                return;
            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: paymentInfo
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this._purchaseOrderErrorMessage = error.body.message;
            });
        } else {
            if (selectedAddressResult.error) {
                this._creditCardErrorMessage = selectedAddressResult.error;
                return;
            }

            var cardsList = this.template.querySelector('lightning-datatable');
            var selectedCard = null;
            if(cardsList!=null){

                selectedCard = cardsList.getSelectedRows();
                console.log("## selectedCard : " + JSON.stringify(selectedCard));

            }

            var creditCardData = null;
            debugger;
            if(selectedCard!=null && selectedCard.length===1){
                creditCardData = {
                    cardPaymentMethodId: selectedCard[0].Id
                };
    
            }else{
    
                // First let's get the cc data
                const creditPaymentComponent = this.getComponent(
                    '[data-credit-payment-method]'
                );

                // Second let's make sure the required fields are valid
                if (
                    creditPaymentComponent != null &&
                    !creditPaymentComponent.reportValidity()
                ) {
                    return;
                }

                creditCardData = this.getCreditCardFromComponent(
                    creditPaymentComponent
                );

                debugger;
                if(this._useSavedCardsFlag==='true'){
                    creditCardData.saveCard = this.selectedValues;
                }else{
                    creditCardData.saveCard = 'false';
                }

            }

            debugger;
            console.log("## useSavedCards : " + this._useSavedCardsFlag);

            console.log("## creditCardData : " + JSON.stringify(creditCardData));
            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: creditCardData
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this._creditCardErrorMessage = error.body.message;
            });
        }
    }

    /**
     * @returns The selected billing address in an object { address: <the selected billing address> } or
     *          { error: <the error message> } if the field is required but missing. It can return an empty
     *          object if there is no billing address and it's not a required field.
     */
    getBillingAddress() {
        if (!Array.isArray(this._addresses) || !this._addresses.length) {
            if (this.billingAddressRequired) {
                return { error: 'Billing Address is required' };
            }
        } else {
            return { address: this._addresses.filter(add => add.id === this.selectedBillingAddress)[0] };
        }

        return {};
    }

    getCreditCardFromComponent(creditPaymentComponent) {
        const cardPaymentData = {};
        [
            'cardHolderName',
            'cardNumber',
            'cvv',
            'expiryYear',
            'expiryMonth',
            'expiryYear',
            'cardType'
        ].forEach((property) => {
            cardPaymentData[property] = creditPaymentComponent[property];
        });
        return cardPaymentData;
    }

    /**
     * Set the address selected
     */
    handleChangeSelectedAddress(event) {
        const address = event.detail.address;
        if (address.id !== null && (address.id).startsWith('8lW')) {
            this._selectedBillingAddress = address.id;
        } else {
            this._selectedBillingAddress = '';
        }
    }

    /**
     * Simple function to query the passed element locator
     * @param {*} locator The HTML element identifier
     * @private
     */
    getComponent(locator) {
        return this.template.querySelector(locator);
    }

    dispatchCustomEvent(eventName, detail) {
        this.dispatchEvent(
            new CustomEvent(eventName, {
                bubbles: false,
                composed: false,
                cancelable: false,
                detail
            })
        );
    }

    value = ['true'];

    get options() {
        return [
            { label: 'Save Card Details', value: 'true' }
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleChange(e) {
        this.value = e.detail.value;
        console.log('##Save Card Details: ' + this.value);
    }

}