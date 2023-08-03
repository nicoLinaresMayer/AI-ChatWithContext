import { LightningElement,api } from 'lwc';
import sendPrompt from '@salesforce/apex/ChatController.sendPrompt';

export default class Chat extends LightningElement {
    @api recordId;
    prompt = '';
    response = 'no response';
    handleInputChange(event) {
        this.prompt = event.target.value;
    }

    handleButtonClick(){
        sendPrompt({ prompt: this.prompt ,sessionId : this.recordId})
        .then(result => {
            // Aquí puedes manejar el resultado del método de Apex
            console.log('Resultado de Apex:', result);
            this.response = result;
        })
        .catch(error => {
            // Manejar errores si es necesario
            console.error(error);
        });
    }   
}