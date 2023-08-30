import { LightningElement,api} from 'lwc';
import getModels from '@salesforce/apex/ChatController.getModels';
import getModelNameById from '@salesforce/apex/ChatController.getModelNameById';

export default class SessionContainer extends LightningElement {
    
    @api recordId;
    chatContext = [];
    selectedModel = 'gpt-3.5-turbo';
    selectedModelNameId = 'gpt-3.5-turbo';
    modelOptions= [];

    connectedCallback(){
        getModels().then(data=>{
            console.log(JSON.stringify(data));
            this.modelOptions = data.map(item => ({
                label: item.Name,
                value: item.Model_Id__c
            }));
            this.modelOptions.unshift({label:'gpt-3.5-turbo', value : 'gpt-3.5-turbo'});
        }).catch(error=>{
            console.log(error);
        })
    }

    handleSaveContext(event){
        this.chatContext = event.detail.split('\n');
    }
    handleModelChange(event) {

        this.selectedModel = event.detail.value;
        if(this.selectedModel != 'gpt-3.5-turbo'){
            getModelNameById({fineTuneId: event.detail.value}).then(modelName=>{
                this.selectedModelNameId = modelName;
            }).catch(error=>{
                console.log(JSON.stringify(error));
            })
        }
        else{
            this.selectedModelNameId = 'gpt-3.5-turbo'
        }
        
    
        console.log(this.selectedModelNameId);
    }
    
}