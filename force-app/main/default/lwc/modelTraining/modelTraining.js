import { LightningElement} from 'lwc';
import createFineTune from '@salesforce/apex/FineTuningController.createFineTune';
import getModels from '@salesforce/apex/FineTuningController.getModels';
import getDatasets from '@salesforce/apex/FineTuningController.getDatasets';
import getModelEventMessages from '@salesforce/apex/FineTuningController.getFineTuneJobEventMessages';
import modelStatusModal from 'c/modelStatusModal';


export default class ModelTraining extends LightningElement {
     //Dataset options
     datasetOptions = '';
     selectedDataset = {};
     // Model options
     modelOptions = '';
     selectedModel = 'gpt-3.5-turbo-0613';
     newModelSuffix = '';
     showNewModelAdded = false;
     showNewModelAddedError = false;
     newModelAddedErrorMsg = '';
 
     handleModelChange(event) {
         this.selectedModel = event.detail.value;    
     }
     
     handleChangeNewModelSuffix(event){
         this.newModelSuffix =  event.target.value;
     }
 
     handleDatasetChange(event) {
        this.selectedDataset = event.detail.value
     }

    connectedCallback(){
        this.getModelsWrapper();
        this.getDatasetsWrapper();
    }

    getDatasetsWrapper(){
        getDatasets().then((data)=>{
            console.log(JSON.parse(JSON.stringify(data)));
            this.datasetOptions = data.map(item => ({
                label: item.Name,
                value: item.Id__c
            }));
        }).catch(error=>{
            console.log(error)
        })
    }
     // TRAIN MODEL
     handleTrainModel(){
         console.log('datasetId:'+this.selectedDataset + '  baseModel:'+ this.selectedModel + '  suffix:'+ this.newModelSuffix);
         /*createFineTune({datasetId : this.selectedDataset , baseModel : this.selectedModel, suffixName : this.newModelSuffix}).then((result)=>{
             if(result!='' && !result.includes('Error')){
                this.getModelsWrapper();
                this.showNewModelAdded = true;
                setTimeout(() => {
                   this.showNewModelAdded = false;
               }, 3000)
             }
            else{
                this.newModelAddedErrorMsg = result;
                this.showNewModelAddedError = true
                setTimeout(() => {
                    this.showNewModelAddedError = false;
                    this.newModelAddedErrorMsg = '';
                }, 7000)
            }

             
         }).catch(error=>{
             console.log(error);
         });*/
         
     }
     getModelsWrapper(){
        getModels().then(data=>{
            console.log(JSON.stringify(data));
            this.modelOptions = data.map(item => ({
                label: item.Name,
                value: item.Model_Id__c
            }));
            this.modelOptions.unshift({label:'gpt-3.5-turbo-0613 (default)', value : 'gpt-3.5-turbo-0613'});
        }).catch(error=>{
            console.log(error);
        })
     }
     
     async handleCheckModelStatus(){
        let modelIsFinished = false;
        await getModelEventMessages({fineTuneId : this.selectedModel}).then(result=>{
            this.resultMessages = result.map(item=>{
                let isFinished = false;
                if(item.includes('successfully completed')){
                    isFinished = true;
                    modelIsFinished = true;
                }
               
                return {Id : this.generateUniqueId(), Message: item , Class :  isFinished ? 'green-text' : '.normal-text'}
            });
        }).catch(error=>{
            console.log(error);
        });
        const result = await modelStatusModal.open({
            size: 'small',
            statusMessages : this.resultMessages,
            title : modelIsFinished ? 'Model is ready to use' : 'Model continues training please wait'

        });
     }

     handleRefreshDatasetList(){
        console.log(JSON.stringify(this.datasetOptions));
        this.getDatasetsWrapper();
     }
    //Utils
    generateUniqueId() {
        return 'message_' + Math.random().toString(36).substr(2, 9);
    }
}