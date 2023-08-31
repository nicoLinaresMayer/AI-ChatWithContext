import { LightningElement, wire} from 'lwc';
export default class FineTunedTraining extends LightningElement {   
   
   fileUploadedReload= false;


    handleReload(){
        this.fileUploadedReload = !this.fileUploadedReload;
    }
}