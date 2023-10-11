import LightningModal from 'lightning/modal';
import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class DatasetCreationModal extends LightningModal {
    name= '';
    title='Create new Dataset'
    handleOkay(){
        this.close('OK');
    }

    handleSuccess(event){
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Dataset created. Please close modal',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        setTimeout(() => {
            this.dispatchEvent(new CustomEvent('closemodal'));
        }, 3000)

    }
}