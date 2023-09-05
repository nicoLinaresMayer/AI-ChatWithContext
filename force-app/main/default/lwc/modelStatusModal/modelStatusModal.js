import { api } from 'lwc';
import LightningModal from 'lightning/modal';
export default class ModelStatusModal extends LightningModal {
    @api statusMessages;
    @api title;
    handleOkay(){
        this.close('OK');
    }
}