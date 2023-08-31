import { LightningElement,api,wire } from 'lwc';
import getChatCompletion from '@salesforce/apex/ChatController.getChatCompletion';
import retrieveChatMessages from '@salesforce/apex/ChatController.retrieveChat'


export default class Chat extends LightningElement {
    @api sessionId;
    @api model;
    prompt = '';
    response = '';
    messages = [];
    temperatureValue = 0.8;
    responseIsLoading = false;


    val = 50;
    handleInputChange(event) {
        this.prompt = event.target.value;
    }

    @wire(retrieveChatMessages,{sessionId : '$sessionId'})
    wiredChatMessages({error,data}){
        try{
            if (data) {
                this.messages = data;
            } else if (error) {
                console.log('Error in wiredChatMessages->'+error);
            }
        }
        catch(error){
            console.log(error);
        }
        
    }


    handleButtonClick(){
        this.responseIsLoading = true;
        console.log(this.prompt);
        getChatCompletion({ prompt: this.prompt, model : this.model,sessionId : this.sessionId, temperature : this.temperatureValue})
        .then(result => {
            console.log('Resultado de Apex:', result);
            if(result!= ''){
                let newPrompt = {Id : 123 , Content:this.prompt, Response : result, Type : 'Default'};
                this.response = '';
                this.messages = [...this.messages, newPrompt];
                this.prompt = '';
            }
            else{
                this.response = 'Error - Please check the status of fine-tuned model'
            }
            this.responseIsLoading = false;
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