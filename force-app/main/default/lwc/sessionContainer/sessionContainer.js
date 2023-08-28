import { LightningElement,api} from 'lwc';

export default class SessionContainer extends LightningElement {
    
    @api recordId;
    chatContext = [];

    handleSaveContext(event){
        this.chatContext = event.detail.split('\n');
    }

}