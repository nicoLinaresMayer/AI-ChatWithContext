import { LightningElement,wire } from 'lwc';
import uploadDatasetFile from '@salesforce/apex/ChatController.uploadDatasetFile';

export default class DatasetUpload extends LightningElement {

    // Datatable
    rows = [{User: '', System: '',Assistant:'', Id: 'row_wzwww'}];

    newDatasetFileName = '';

    //Loading, info & errors
    showRowsInfo = false;
    uploadFileIsLoading = false;
    rowsInfoMessage = '';

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

    //Handle props changes
    handleChangenewDatasetFileName(event){
        this.newDatasetFileName =  event.target.value;
     }


   
}