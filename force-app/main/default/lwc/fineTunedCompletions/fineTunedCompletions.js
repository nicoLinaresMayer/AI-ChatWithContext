import { LightningElement } from 'lwc';
import getSingleCompletion from '@salesforce/apex/ChatController.getSingleCompletion';
export default class FineTunedCompletions extends LightningElement {

    messages = [{Content:"Start typing a prompt", Response : "And get the response here"}];
    prompt = '';
    temperature = 0.8;
    response = '';
    model = 'curie:ft-personal-2023-08-17-22-35-36'

    handleSliderChange(event){
        this.temperature = event.target.value;
    }
    handleInputChange(event) {
        this.prompt = event.target.value;
    }
    handleButtonClick(){
        this.response = 'Waiting for response...';
        console.log(this.prompt);
        getSingleCompletion({ prompt : this.prompt,temperature : this.temprature, model : this.model})
        .then(result => {
            if(result!= ''){
                let newPrompt = {Id : 123 , Content:this.prompt, Response : result};
                this.response = '';
                this.messages = [...this.messages, newPrompt];
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