import { LightningElement,api,wire } from 'lwc';
import sendPrompt from '@salesforce/apex/ChatController.sendPrompt';
import retrieveChatMessages from '@salesforce/apex/ChatController.retrieveChatMessages'

export default class Chat extends LightningElement {
    @api recordId;
    prompt = '';
    response = 'no response';
    messages = [];
    handleInputChange(event) {
        this.prompt = event.target.value;
    }

    @wire(retrieveChatMessages,{sessionId : '$recordId'})
    wiredRetrieveChatMessages({error,data}){
        if (data) {
            let index = 1;
            this.messages = data.map(element=>{
                let object = JSON.parse(element);
                object.Id = index;
                index++;
                return object;
            });
            console.log(JSON.parse(JSON.stringify(this.messages)));
        } else if (error) {
            console.error(error);
        }
    }

    handleButtonClick(){
        this.response = 'Waiting for response...';
        sendPrompt({ prompt: this.prompt ,sessionId : this.recordId})
        .then(result => {
            // Aquí puedes manejar el resultado del método de Apex
            console.log('Resultado de Apex:', result);
            let newMessages = [{role:"user",content:this.prompt, Id : 123},{role: "system" , content: result, Id : 1234}];
            this.response = result;
            this.messages = [...this.messages, newMessages[0],newMessages[1]];
            this.prompt = '';
            
        })
        .catch(error => {
            // Manejar errores si es necesario
            console.error(error);
        });
    }  
    

}