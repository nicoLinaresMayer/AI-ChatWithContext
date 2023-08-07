import { LightningElement,api,wire } from 'lwc';
import sendPrompt from '@salesforce/apex/ChatController.sendPrompt';
import retrieveChatMessages from '@salesforce/apex/ChatController.retrieveChatMessages'

export default class Chat extends LightningElement {
    @api recordId;
    prompt = '';
    response = '';
    messages = [];
    handleInputChange(event) {
        this.prompt = event.target.value;
    }

    @wire(retrieveChatMessages,{sessionId : '$recordId'})
    wiredRetrieveChatMessages({error,data}){
        try{
            if (data) {
                let index = 1;
    
                this.messages = data.map(element=>{
                    let object = JSON.parse(element);
                    object['Id'] = index;
                    index++;
                    return object;
                });
                console.log(JSON.parse(JSON.stringify(this.messages)));
            } else if (error) {
                console.error(error);
                console.log('error-->'+error);
            }
        }
        catch(error){
            console.log(error);
        }
        
    }

    handleButtonClick(){
        this.response = 'Waiting for response...';
        console.log(this.prompt);
        sendPrompt({ prompt: this.prompt ,sessionId : this.recordId})
        .then(result => {
            // Aquí puedes manejar el resultado del método de Apex
            console.log('Resultado de Apex:', result);
            if(result!= ''){
                let newMessages = [{role:"user",content:this.prompt, Id : 123},{role: "system" , content: result, Id : 1234}];
                this.response = '';
                this.messages = [...this.messages, newMessages[0],newMessages[1]];
                this.prompt = '';
            }
            else{
                this.response = 'Error'
            }
            
            
        })
        .catch(error => {
            this.response = 'Error'
            console.error(error);
        });
    }  
    

}