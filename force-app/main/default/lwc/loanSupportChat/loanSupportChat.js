import { LightningElement, track } from 'lwc';
import getLoanStatus from '@salesforce/apex/LoanStatusAction.getLoanStatusForLWC';
import getEMISchedule from '@salesforce/apex/EMIScheduleAction.getEMIScheduleForLWC';

export default class LoanSupportChat extends LightningElement {

    @track loanNumber = '';
    @track isLoading = false;
    @track hasError = false;
    @track errorMessage = '';
    @track hasResponse = false;
    @track hasEMIData = false;
    @track responseTitle = '';
    @track loanStatus = '';
    @track responseFields = [];
    @track emiList = [];

    handleLoanNumberChange(event) {
        this.loanNumber = event.target.value.trim().toUpperCase();
        this.resetState();
    }

    handleClear() {
        this.loanNumber = '';
        this.resetState();
    }

    resetState() {
        this.hasError = false;
        this.errorMessage = '';
        this.hasResponse = false;
        this.hasEMIData = false;
        this.responseFields = [];
        this.emiList = [];
        this.loanStatus = '';
    }

    validateLoanNumber() {
        if (!this.loanNumber) {
            this.hasError = true;
            this.errorMessage = 'Please enter a loan number before proceeding.';
            return false;
        }
        const loanNumberPattern = /^LN-\d{3}$/;
        if (!loanNumberPattern.test(this.loanNumber)) {
            this.hasError = true;
            this.errorMessage = 'Invalid format. Please enter loan number in format LN-001.';
            return false;
        }
        return true;
    }

    handleLoanStatus() {
        if (!this.validateLoanNumber()) return;

        this.resetState();
        this.isLoading = true;

        getLoanStatus({ loanNumber: this.loanNumber })
            .then(result => {
                this.isLoading = false;
                if (result) {
                    this.parseLoanStatusResponse(result);
                } else {
                    this.hasError = true;
                    this.errorMessage = 'No loan found for loan number ' + this.loanNumber;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.hasError = true;
                this.errorMessage = 'Error fetching loan details. Please try again.';
                console.error('Loan Status Error:', JSON.stringify(error));
            });
    }

    handleEMISchedule() {
        if (!this.validateLoanNumber()) return;

        this.resetState();
        this.isLoading = true;

        getEMISchedule({ loanNumber: this.loanNumber })
            .then(result => {
                this.isLoading = false;
                if (result && result.length > 0) {
                    this.parseEMIResponse(result);
                } else {
                    this.hasError = true;
                    this.errorMessage = 'No pending EMIs found for loan number ' + this.loanNumber;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.hasError = true;
                this.errorMessage = 'Error fetching EMI schedule. Please try again.';
                console.error('EMI Schedule Error:', JSON.stringify(error));
            });
    }

    parseLoanStatusResponse(response) {
        this.responseTitle = 'Loan Details — ' + this.loanNumber;
        const loan = JSON.parse(response);

        this.loanStatus = loan.Status__c;
        this.responseFields = [
            { label: 'Loan Number', value: loan.Loan_Number__c, size: 'slds-size_1-of-2' },
            { label: 'Loan Status', value: loan.Status__c, size: 'slds-size_1-of-2' },
            { label: 'Outstanding Balance', value: '₹' + loan.Outstanding_Balance__c, size: 'slds-size_1-of-2' },
            { label: 'EMI Amount', value: '₹' + loan.EMI_Amount__c, size: 'slds-size_1-of-2' },
            { 
                label: 'Next Due Date', 
                value: new Date(loan.Next_Due_Date__c).toLocaleDateString('en-IN', { 
                    day: '2-digit', month: 'short', year: 'numeric' 
                }), 
                size: 'slds-size_1-of-1' 
            }
        ];
        this.hasResponse = true;
    }

    parseEMIResponse(response) {
        this.emiList = response.map((emi, index) => ({
            index: index + 1,
            dueDate: emi.Due_Date__c,
            amount: emi.Amount__c,
            status: emi.Status__c,
            statusClass: emi.Status__c === 'Overdue'
                ? 'slds-badge slds-theme_error'
                : 'slds-badge slds-theme_success'
        }));
        this.hasEMIData = true;
    }

    get statusBadgeClass() {
        if (this.loanStatus === 'Active') 
            return 'slds-badge slds-theme_success';
        if (this.loanStatus === 'Defaulted') 
            return 'slds-badge slds-theme_error';
        if (this.loanStatus === 'Closed') 
            return 'slds-badge slds-theme_shade';
        return 'slds-badge';
    }
}