import { LightningElement, wire} from 'lwc';
import uploadDatasetFile from '@salesforce/apex/ChatController.uploadDatasetFile';
import listFineTunes from '@salesforce/apex/ChatController.listFineTunes';
import listDatasetFiles from '@salesforce/apex/ChatController.listDatasetFiles';
import createFineTune from '@salesforce/apex/ChatController.createFineTune';



const  COLUMNS = [
    { label: 'System', fieldName: 'system', editable: true },
    { label: 'User', fieldName: 'user', type : 'text',editable: true },
    { label: 'Assistant', fieldName: 'assistant', editable: true }
];
export default class FineTunedTraining extends LightningElement {

    selectedModel = 'gpt-3.5-turbo-0613';
    modelOptions = '';
    selectedDataset = '';
    datasetOptions = '';
    newDatasetFileName = '';
    newModelSuffix = '';

    //Loading, info & errors
    showRowsInfo = false;
    uploadFileIsLoading = false;
    rowsInfoMessage = '';

    //Datatable
    columns = COLUMNS;
    rows = [{User: '', System: '',Assistant:'', Id: 'row_wzwww'}];


    @wire(listFineTunes, {})
    wiredModels ({error, data}) {
        if (data) {
            this.modelOptions = data.map(item => ({
                label: item,
                value: item
            }));
            this.modelOptions.unshift({label: 'gpt-3.5-turbo-0613 (default)' , value: 'gpt-3.5-turbo-0613'});
        } else if (error) {
            console.log(error);
        }
    }

    @wire(listDatasetFiles, {})
    wiredDatasets ({error, data}) {
        if (data) {
            this.datasetOptions = data.map(item => ({
                label: item,
                value: item
            }));
        } else if (error) {
            console.log(error)
        }
    }
    handleChange(event){ // Obtén el nombre del campo
        const rowId = event.target.dataset.rowid;
       // console.log(rowId);
        const rowRol = event.target.dataset.rol;
        const newValue = event.target.value; // Obtiene el nuevo valor
        // Encuentra la fila correspondiente en el array
        

        // Actualiza el valor en el objeto de la fila
        console.log(this.rows[0].Id == rowId);
        try{
            const rowIndex = this.rows.findIndex(row => row.Id === rowId);
            if (rowIndex !== -1) {
                this.rows[rowIndex][rowRol] = newValue;
            }
            console.log(JSON.stringify(this.rows));
        }
        catch(error){
            console.log('error->'+error);
        }
       
        
    }
    handleUploadFile(){
        console.log(JSON.stringify(this.rows));
        console.log(this.rows.length);
        if(this.rows.length<10){
            this.rowsInfoMessage = 'Add at least 10 entries';
            this.showRowsInfo = true;
            setTimeout(() => {
                this.showRowsInfo = false;
            }, 3000)
        }
        else{
            if(this.newDatasetFileName==''){
                this.rowsInfoMessage = 'Enter a file name';
                this.showRowsInfo = true;
                setTimeout(() => {
                    this.showRowsInfo = false;
                }, 3000)
            }
            else{
                this.uploadFileIsLoading = true;
                let stringArray = this.rows.map(row=>{
                    return JSON.stringify(row);
                });     
                           
                uploadDatasetFile({rows: stringArray, fileName : this.newDatasetFileName+'.jsonl'}).then(()=>{
                    this.rowsInfoMessage = 'Successfully upload file with name \"'+this.newDatasetFileName+'.jsonl'+'\"';
                    this.showRowsInfo = true;
                    this.uploadFileIsLoading = false;
                    setTimeout(() => {
                        this.showRowsInfo = false;
                    }, 3000)
       
                    })
                    .catch(error=>{
                        console.log(error);
                    });
                    console.log(JSON.stringify(stringArray));
            }
        }
    }

    addRow(){
        let randomId = this.generateUniqueId();
        let newRow = {User: '', System: '',Assistant:'', Id: randomId};
        this.rows = [...this.rows, newRow];
    }

    deleteRow(event){
        if(this.rows.length> 1){
            this.rows.splice(this.rows.findIndex(row => row.Id === event.target.dataset.rowid), 1);
            this.rows = [...this.rows];
        }
        else{
            this.rows =[{User: '', System: '',Assistant:'', Id: this.generateUniqueId()}];
        }
        
    }

    generateUniqueId() {
        return 'row_' + Math.random().toString(36).substr(2, 9);
    }

// Select model
    handleModelChange(event) {
        this.selectedModel = event.detail.value;    
    }

    handleDatasetChange(event) {
        this.selectedDataset = event.detail.value;
    }
    handleChangeNewModelSuffix(event){
        this.newModelSuffix =  event.target.value;
    }

    handleChangenewDatasetFileName(event){
        this.newDatasetFileName =  event.target.value;
     }

    // TRAIN MODEL

    handleTrainModel(){
        console.log('datasetName:'+this.selectedDataset + '  baseModel:'+ this.selectedModel + '  suffix:'+ this.newModelSuffix);
        createFineTune({datasetName : this.selectedDataset , baseModel : this.selectedModel, suffixName : this.newModelSuffix}).then((result)=>{
            console.log('ok');
            console.log(result);
        }).catch(error=>{
            console.log(error);
        });
        
    }

    

}