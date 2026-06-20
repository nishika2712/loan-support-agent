# AI-Powered Loan Support Agent — Salesforce Agentforce + LWC

An end-to-end AI-powered loan servicing solution built on Salesforce, 
combining Agentforce conversational AI with a Lightning Web Component 
for real-time loan data retrieval.

## Screenshots

### Loan Status View
![Loan Status](screenshots/loan-status.png)

### EMI Schedule View
![EMI Schedule](screenshots/emi-schedule.png)

## Architecture
```
Customer Query
      ↓
Agentforce Service Agent
      ↓
Agent Topics (Loan Status / EMI Schedule / General FAQ)
      ↓
Apex Invocable Actions (@InvocableMethod)
      ↓
Custom Objects (Loan_Account__c / EMI_Schedule__c)
```
## Key Design Decision — Dual Apex Architecture

Each Apex class serves two consumers:
- **@InvocableMethod** — called by Agentforce Agent Actions
- **@AuraEnabled** — called directly by the LWC component

This avoids code duplication while serving both AI and UI layers 
from a single class.

## Salesforce Features Used

- Agentforce Service Agent with custom Topics and Actions
- Apex Invocable Methods for Agent Actions
- Apex AuraEnabled Methods for LWC
- Lightning Web Components with dynamic rendering
- Custom Objects: Loan Account, EMI Schedule, Support Query Log
- SOQL with relationship traversal across Master-Detail
- Platform Events architecture (Agentforce routing)

## Custom Objects

**Loan_Account__c**
- Loan Number, Customer Name, Principal Amount
- Outstanding Balance, EMI Amount, Status, Next Due Date

**EMI_Schedule__c**
- Master-Detail to Loan Account
- Due Date, Amount, Status (Pending/Paid/Overdue)

**Support_Query__c**
- Query Type, Response Given, Timestamp

## Agentforce Configuration

Three topics configured:
1. **Loan Status Inquiry** — triggers Get Loan Status Apex action
2. **EMI Schedule Inquiry** — triggers Get EMI Schedule Apex action
3. **General Loan FAQ** — handled by Agent reasoning, no Apex needed

## How to Deploy

1. Clone this repository
2. Authorise your Salesforce org:
```bash
   sf org login web --alias myorg
```
3. Deploy metadata:
```bash
   sf project deploy start --source-dir force-app
```
4. Load sample data from /data/sample-loans.json
5. Configure Agentforce Agent Actions pointing to 
   LoanStatusAction and EMIScheduleAction
6. Add loanSupportChat LWC to any Loan Account record page 
   via App Builder

## Test Coverage

- LoanStatusActionTest — covers found, not found, and LWC method
- EMIScheduleActionTest — covers pending EMIs, empty result, and LWC method
- 90%+ coverage maintained across all classes

## What I Would Add in Production

- Einstein Sentiment Analysis on customer queries
- Escalation Flow to human agent for Defaulted loans
- Platform Event logging to Support_Query__c on every Agent interaction
- Named Credential based authentication for external loan bureau APIs
- Experience Cloud deployment for customer-facing portal