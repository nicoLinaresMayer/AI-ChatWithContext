import { LightningElement,api,wire } from 'lwc';
import getDocumentsByType from '@salesforce/apex/DocumentController.getDocumentsByType';
import getDocumentSections from '@salesforce/apex/DocumentController.getDocumentSections';
import updateDocument from '@salesforce/apex/DocumentController.updateDocument';
//news
import getDocumentTypes from '@salesforce/apex/DocumentController.getDocumentTypes';


export default class DocumentContainer extends LightningElement {

@api lastResponse;
//Types
  selectedType = '';
  documentTypes = [];
//Documents
    selectedDocument = '';
    documents=[];
 //Sections
    selectedSection = '';
    sections=[];

@wire(getDocumentTypes, {})
wiredDocumentTypes ({error, data}) {
    if (error) {
        console.log('Error with document types');
        console.log(error)
    } else if (data) {
        this.documentTypes = data.map(item=>{
            return {label:item, value:item}
        });
    }
}

    handleTypeChange(event){
        this.selectedType= event.target.value;
    }

    @wire(getDocumentsByType, {documentType : '$selectedType'})
    wiredDocuments ({error, data}) {
        if (error) {
            console.log('Error in getDocuments : '+ JSON.stringify(error));
        } else if (data) {
            console.log('data->'+ JSON.stringify(data));
            this.documents = data.map(item=>{
                return {label:item.Name , value:item.Id}
            });
        }
    }
    @wire(getDocumentSections, {documentId : '$selectedDocument'})
    wiredDocumentSections ({error, data}) {
        if (error) {
            console.log('Error in getDocumentSections : '+ JSON.stringify(error));
        } else if (data) {
            this.sections = data.map(item=>{
                return {label:item.Name , value:item.Id}
            });
        }
    }


    handleDocumentChange(event){
        this.selectedDocument = event.target.value;
    }

    handleSectionChange(event){
        this.selectedSection = event.target.value;
    }

    handleUpdateDocument(){
        console.log(this.selectedDocument);
        console.log(this.selectedSection);
        console.log(this.lastResponse);
        updateDocument({sectionToUpdate : this.selectedSection, response: this.lastResponse }).then(result=>{
            console.log('ok');
        }).catch(error=>{
            console.log('Error->'+JSON.stringify(error));
        })

    }
}