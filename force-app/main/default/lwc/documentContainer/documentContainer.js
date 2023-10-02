import { LightningElement,api } from 'lwc';
import getDocumentsByType from '@salesforce/apex/DocumentController.getDocumentsByType';
import getDocumentSectionsById from '@salesforce/apex/DocumentController.getDocumentSectionsById';
import updateDocument from '@salesforce/apex/DocumentController.updateDocument';


export default class DocumentContainer extends LightningElement {

@api lastResponse;
//Types
  selectedType = '';
  documentTypes = [{label:'Deck', value:'Deck'},{label:'White Paper', value:'WhitePaper'},{label:'One-Pager', value:'OnePager'}];
  
//Documents
selectedDocument = '';
documents=[];
//Sections
selectedSection = '';
sections=[];

  handleTypeChange(event){
    this.selectedType= event.target.value;
    getDocumentsByType({documentType: this.selectedType}).then(result =>{
        console.log('result->'+ JSON.stringify(result));
        this.documents = result.map(item=>{
            return {label: item.Name, value: item.Id}
        });
    }).catch(error=>{
        console.log('error->'+ error);
    });
  }


  handleDocumentChange(event){
    this.selectedDocument = event.target.value;
    getDocumentSectionsById({documentId: this.selectedDocument, documentType: this.selectedType}).then(result =>{
        console.log('result->'+ JSON.stringify(result));
        const transformedData = [];
        for (const key in result) {
            if (result.hasOwnProperty(key)) {
                transformedData.push({
                    label: result[key],
                    value: key
                });
            }
        }
        this.sections= transformedData;
      
    }).catch(error=>{
        console.log('error->'+ error);
    });
  }

  handleSectionChange(event){
    this.selectedSection = event.target.value;
  }

  handleUpdateDocument(){
    console.log(this.selectedDocument);
    console.log(this.selectedSection);
    console.log(this.lastResponse);
    updateDocument({documentId:this.selectedDocument,documentType: this.selectedType, fieldToUpdate : this.selectedSection, response: this.lastResponse }).then(result=>{
        console.log('ok');
    }).catch(error=>{
        console.log('Error->'+error);
    })

  }
}