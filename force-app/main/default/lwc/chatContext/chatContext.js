import { LightningElement, api, wire } from 'lwc';
import retrieveContextMessages from '@salesforce/apex/ChatController.retrieveContext'
import saveContextPrompts from '@salesforce/apex/ChatController.saveContextPrompts'
export default class ChatContext extends LightningElement {
    @api sessionId;
    contextPrompts = '';
    infoMessage = '';
    isLoading = true;

    @wire(retrieveContextMessages,{sessionId : '$sessionId'})
    wiredContextMessages({error,data}){
        try{
            if (data) {
                this.contextPrompts = data.map(element=>{
                    return element.Content + '\n__-__\n';
                }).join('');;
                console.log(JSON.stringify(this.contextPrompts));
                this.isLoading = false;

            } else if (error) {
                console.log('error-->'+error);
            }
        }
        catch(error){
            console.log('Error.');
            console.log(JSON.stringify(error));
        }
    }

    handleChange(event){
        this.contextPrompts= event.target.value;
    }
    handleSave(){
        let arrayContextPrompts = this.contextPrompts.split('\n__-__\n');
        console.log(JSON.stringify(arrayContextPrompts));
        saveContextPrompts({ sessionId: this.sessionId, contextPrompts: arrayContextPrompts })
            .then(() => {
                this.infoMessage = 'Success';
                setTimeout(() => {
                    this.infoMessage = '';
                }, 5000)
            })
            .catch(error => {
                console.log(error);
                this.infoMessage = 'Error';
                setTimeout(() => {
                    this.infoMessage = '';
                }, 5000)
            });
    }
}