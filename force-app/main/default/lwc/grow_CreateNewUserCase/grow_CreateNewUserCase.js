import { LightningElement, track } from 'lwc';
 
export default class Grow_CreateNewUserCase extends LightningElement {
    @track initialLoad = true;

    handleNewUserRequest(){
        this.initialLoad = false;
    }
}