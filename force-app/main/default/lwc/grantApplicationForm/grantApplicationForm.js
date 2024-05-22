import { LightningElement, wire } from 'lwc';
import getComboboxOptions from '@salesforce/apex/ComboboxOptionsController.getComboboxOptions';

export default class GrantApplicationForm extends LightningElement {
    options = [];
    selectedValue;

    @wire(getComboboxOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.options = data.map(option => {
                return { label: option, value: option };
            });
        } else if (error) {
            console.error('Error fetching combobox options', error);
        }
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

}