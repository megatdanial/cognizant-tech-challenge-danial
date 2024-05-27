import { LightningElement, wire } from 'lwc';
import Toast from 'lightning/toast';
import getComboboxOptions from '@salesforce/apex/ComboboxOptionsController.getComboboxOptions';
import checkPhone from '@salesforce/apex/ContactController.checkPhone';
import createContact from '@salesforce/apex/ContactController.createContact';
import updateContact from '@salesforce/apex/ContactController.updateContact';

export default class GrantApplicationForm extends LightningElement {
    firstName = '';
    lastName = '';
    phone = '';
    postalCode = '';
    income = '';
    cid = '';
    options = [];
    selectedValue;

    @wire(getComboboxOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.options = data.map(option => {
                return { label: option.MasterLabel + ': SGD ' + option.Fund__c + ' per month for ' + option.Period__c + ' months', value: option.MasterLabel };
            });
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleChange(event) {
        const field = event.target.dataset.id;
        if (field === 'firstName') this.firstName = event.target.value;
        else if (field === 'lastName') this.lastName = event.target.value;
        else if (field === 'phone') this.phone = event.target.value;
        else if (field === 'postalCode') this.postalCode = event.target.value;
        else if (field === 'income') this.income = event.target.value;
        else if (field === 'supportOption') this.selectedValue = event.target.value;
    }
    
    handleSubmit() {
        checkPhone({ phone: this.phone })
            .then(result => {
                if (result != null) {
                    this.cid = result;
                    this.updateContactRecord();
                } else {
                    this.createContactRecord();
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', error, 'error');
            });
    }

    createContactRecord() {
        const fields = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Phone: this.phone,
            MailingPostalCode: this.postalCode,
            Monthly_Income__c: this.income,
            Support_Option__c: this.selectedValue
        };
        createContact({ contact: fields })
            .then(() => {
                this.showToast('Success', 'Contact created successfully!', 'success');
                this.resetForm();
            })
            .catch(error => {
                console.log(error);
                if(error.body.pageErrors != null){
                    console.log('run');
                    this.showToast('Error', error.body.pageErrors[0].message, 'error');
                }
                else{
                    this.showToast('Error', error.body.message, 'error');
                }
            });
    }

    updateContactRecord(){
        const fields = {
            Id: this.cid,
            FirstName: this.firstName,
            LastName: this.lastName,
            Phone: this.phone,
            MailingPostalCode: this.postalCode,
            Monthly_Income__c: this.income,
            Support_Option__c: this.selectedValue
        };
        updateContact({ contact: fields })
            .then(() => {
                this.showToast('Success', 'Contact update successfully!', 'success');
                this.resetForm();
            })
            .catch(error => {
                console.log(error);
                if(error.body.pageErrors != null){
                    console.log('run');
                    this.showToast('Error', error.body.pageErrors[0].message, 'error');
                }
                else{
                    this.showToast('Error', error.body.message, 'error');
                }
            });
    }

    resetForm() {
        this.firstName = '';
        this.lastName = '';
        this.phone = '';
        this.postalCode = '';
        this.income = '';
        this.selectedValue = '';
    }

    showToast(title, message, variant) {
        console.log('showtoast');
        console.log(title);
        console.log(message);
        console.log(variant);
        Toast.show({
            label: title,
            message: message,
            variant: variant
        }, this);
    }

}