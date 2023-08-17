import { LightningElement,api,wire } from 'lwc';
import getChatCompletion from '@salesforce/apex/ChatController.getChatCompletion';
import retrieveChatMessages from '@salesforce/apex/ChatController.retrieveChat'

export default class Chat extends LightningElement {
    @api recordId;
    prompt = '';
    response = '';
    messages = [];
    temperature = 0.8;
    val = 50;
    handleInputChange(event) {
        this.prompt = event.target.value;
    }

    @wire(retrieveChatMessages,{sessionId : '$recordId'})
    wiredRetrieveChatMessages({error,data}){
        try{
            if (data) {
                console.log(data);
                this.messages = data;
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
        getChatCompletion({ prompt: this.prompt ,sessionId : this.recordId, temperature : this.temperatureValue})
        .then(result => {
            console.log('Resultado de Apex:', result);
            if(result!= ''){
                let newPrompt = {Id : 123 , Content:this.prompt, Response : result};
           
                this.response = '';
                this.messages = [...this.messages, newPrompt];
                this.prompt = '';
            }
            else{
                this.response = 'Error'
            }
            
            this.updateScroll();
            
        })
        .catch(error => {
            this.response = 'Error'
            console.error(error);
        });
    }  
    
    updateScroll(){
        let element = document.getElementsByClassName("chat-container");
        element.scrollTop = element.scrollHeight;
    }
    handleSliderChange(event){
        this.temperatureValue = event.target.value;
    }
}