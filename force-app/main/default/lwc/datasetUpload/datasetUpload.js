import { LightningElement} from 'lwc';
import uploadDatasetFile from '@salesforce/apex/FineTuningController.uploadDatasetFile';
import retrieveExamples from '@salesforce/apex/FineTuningController.retrieveExamples';
import saveExamples from '@salesforce/apex/FineTuningController.saveExamples';
import getDatasets from '@salesforce/apex/FineTuningController.getDatasets';
import datasetCreationModal from 'c/datasetCreationModal';
export default class DatasetUpload extends LightningElement {

    //Dataset
    selectedDataset= ''
    datasetOptions;
    datasetFileName = '';
    isModalOpen= false;
    datasetIsSaved = true;
    // Datatable
    rows;
    deletedRows = [];

    //Loading, info & errors
    showRowsInfo = false;
    uploadFileIsLoading = false;
    rowsInfoMessage = '';
    tableIsLoading = true;

    connectedCallback(){
        this.getDatasetsWrapper();

    }
    retrieveExamplesWrapper(){
        retrieveExamples({datasetId : this.selectedDataset}).then(data=>{
            this.rows = data;
            console.log(JSON.stringify(data));
            if(data){
                this.tableIsLoading=false;
            }
           
        }).catch(error=>{
            console.log(error);
        })
    }

    handleChange(event){ 
        const rowId = event.target.dataset.rowid;
        const rowRol = event.target.dataset.rol;
        const newValue = event.target.value; 
        try{
            const rowIndex = this.rows.findIndex(row => row.Id === rowId);
            if (rowIndex !== -1) {
                this.rows[rowIndex][rowRol] = newValue;
            }
        }
        catch(error){
            console.log('error->'+error);
        }       
    }

    handleDatasetChange(event){
        this.selectedDataset = event.detail.value;
        this.datasetIsSaved = false;
        this.retrieveExamplesWrapper();    
    }
    handleUploadFile(){
        console.log(JSON.stringify(this.rows));
        if(this.rows.length<10){
            this.rowsInfoMessage = 'Add at least 10 entries';
            this.showRowsInfo = true;
            setTimeout(() => {
                this.showRowsInfo = false;
            }, 3000)
        }
        else{
            if(!this.datasetIsSaved){
                this.rowsInfoMessage = 'Please save dataset before upload';
                this.showRowsInfo = true;
                setTimeout(() => {
                    this.showRowsInfo = false;
                }, 3000)
            }
            else{
                this.uploadFileIsLoading = true;
                    
                uploadDatasetFile({datasetId: this.selectedDataset}).then(()=>{
                    this.rowsInfoMessage = 'Successfully upload file';
                    this.showRowsInfo = true;
                    this.uploadFileIsLoading = false;
                    setTimeout(() => {
                        this.showRowsInfo = false;
                    }, 3000);

                    const RELOAD_EVENT =new CustomEvent('reloadfile',);
                    this.dispatchEvent(RELOAD_EVENT);
       
                    })
                    .catch(error=>{
                        console.log(error);
                    });
                    
                    console.log(JSON.stringify(stringArray));
            }
        }
    }

    handleSaveFile(){
        const filteredRows = this.rows.filter(row => {
            return !Object.values(row).some(value => typeof value === 'string' && value.trim() === '');
          });
        let rows = JSON.stringify(this.rows);
        let deletedRows = JSON.stringify(this.deletedRows);
        saveExamples({examplesJson: rows, deletedRows: deletedRows, datasetId:this.selectedDataset}).then(()=>{
            this.rowsInfoMessage = 'Saved';
                this.showRowsInfo = true;
                setTimeout(() => {
                    this.showRowsInfo = false;
                }, 3000);
            this.deletedRows = [];
            //Borrar this.retrieveExamplesWrapper(), se usaba para corroborar la equivalencia de la tabla en memoria con la guardada en base de datos
            this.retrieveExamplesWrapper();  
        }).catch(error=>{
            this.rowsInfoMessage = 'Error';
                this.showRowsInfo = true;
                setTimeout(() => {
                    this.showRowsInfo = false;
                }, 3000)
        });
        this.datasetIsSaved = true;
    }

    //Handle Rows
    addRow(){
        let randomId = this.generateUniqueId();
        let newRow = {Id: randomId, SystemMsg: '' ,UserMsg: '',AssistantMsg:''};
        this.rows = [...this.rows, newRow];
    }

    deleteRow(event){
        if(this.rows.length> 1){
            let deletedRow = this.rows[this.rows.findIndex(row => row.Id === event.target.dataset.id)];
            if(!deletedRow.Id.includes('row_')){
                this.deletedRows = [...this.deletedRows, deletedRow];
            };
            
            this.rows.splice(this.rows.findIndex(row => row.Id === event.target.dataset.id), 1);
            this.rows = [...this.rows];
        }
        else{
            let deletedRow = this.rows[this.rows.findIndex(row => row.Id === event.target.dataset.id)];
            if(!deletedRow.Id.includes('row_')){
                this.deletedRows = [...this.deletedRows, deletedRow];
            };
            this.rows =[{UserMsg: '', SystemMsg: '',AssistantMsg:'', Id: this.generateUniqueId()}];
        }
        
    }

    generateUniqueId() {
        return 'row_' + Math.random().toString(36).substr(2, 9);
    }

   async handleNewDataset(){
    this.isModalOpen= true;
    const result = await datasetCreationModal.open({
        size: 'small',
        title : 'New Dataset'

    });
    this.getDatasetsWrapper();


   }
   handleCloseModal(){
    this.isModalOpen = false;
   }

   getDatasetsWrapper(){
    getDatasets({}).then(data=>{
        this.datasetOptions = data.map(item => ({
            label: item.Name,
            value: item.Id
        }));
        
        this.tableIsLoading=false;
    }).catch(error=>{
        console.log(error);
    });
   }
   
}