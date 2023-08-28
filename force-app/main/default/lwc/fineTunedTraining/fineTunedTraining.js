import { LightningElement } from 'lwc';

const  COLUMNS = [
    { label: 'System', fieldName: 'system', editable: true },
    { label: 'User', fieldName: 'user', type : 'text',editable: true },
    { label: 'Assistant', fieldName: 'assistant', editable: true }
];
export default class FineTunedTraining extends LightningElement {

    selectedModel;
    datasetEntriesCount;
    columns;
    isLoading = false;

    columns = COLUMNS;
    rows = [{User: '', System: '',Assistant:'', Id: 1}];
    
    handleChange(){
        console.log('change');
    }

    addRow() {
        let randomId = this.generateUniqueId();
        let newRow = {User: '', System: '',Assistant:'', Id: randomId};
        this.rows = [...this.rows, newRow];
    }

    deleteRow(event){
        console.log(event.target.dataset.id);
        console.log('index->'+this.rows.findIndex(row => row.Id === event.target.dataset.id));
        if(this.rows.length> 1){
            this.rows.splice(this.rows.findIndex(row => row.Id === event.target.dataset.id), 1);
            this.rows = [...this.rows];
        }
        else{
            this.rows =[{User: '', System: '',Assistant:'', Id: this.generateUniqueId()}];
        }
        
        //this.rows = [...this.rows, {User: '', System: '',Assistant:'', Id: '2'}];
    }

    generateUniqueId() {
        return 'row_' + Math.random().toString(36).substr(2, 9);
    }

}