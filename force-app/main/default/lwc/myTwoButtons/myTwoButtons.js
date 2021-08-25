import { LightningElement, track, api } from 'lwc';

export default class myTwoButtons extends LightningElement {

    @api rowId;


    handleFirstButtonPressed() {   
        console.log('button pressed');
        const selectEvent = new CustomEvent('firstbuttonpressed', {
            composed: true, 
            bubbles: true, 
            detail: {
                rowId: this.rowId,
            },
        });
        this.dispatchEvent(selectEvent);
    }

    handlePayeePressed() {
        console.log('button pressed second');
        const selectEvent = new CustomEvent('secondbuttonpressed', {
            composed: true, 
            bubbles: true, 
            detail: {
                rowId: this.rowId,
            },
        });
        this.dispatchEvent(selectEvent);
    }

}