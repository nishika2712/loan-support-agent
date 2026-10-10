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

## Custom Objects

**Loan_Account__c**
- Loan Number, Customer Name, Principal Amount
- Outstanding Balance, EMI Amount, Status, Next Due Date

**EMI_Schedule__c**
- Master-Detail to Loan Account
- Due Date, Amount, Status (Pending/Paid/Overdue)

## Agentforce Configuration

Three topics configured:
1. **Loan Status Inquiry** — triggers Get Loan Status Apex action
2. **EMI Schedule Inquiry** — triggers Get EMI Schedule Apex action
3. **General Loan FAQ** — handled by Agent reasoning, no Apex needed

## How to Deploy

1. Clone this repository
2. Authorise your Dev Hub: sf org login web --set-default-dev-hub
3. Create a scratch org:
   sf org create scratch --alias loan-scratch --duration-days 7 --definition-file config/project-scratch-def.json
4. Deploy: sf project deploy start --source-dir force-app --target-org loan-scratch
5. Assign access: sf org assign permset --name Loan_Agent_Access --target-org loan-scratch
6. Load sample data: sf data import tree --plan data/Loan_Account__c-EMI_Schedule__c-plan.json --target-org loan-scratch
7. Run tests: sf apex run test --code-coverage --result-format human --wait 10 --target-org loan-scratch
8. Configure the Agentforce agent topics and actions (see docs/agent-config.md)
9. Add the loanSupportChat LWC to a Loan Account record page via App Builder

## Test Coverage

- LoanStatusActionTest — covers found, not found, and LWC method
- EMIScheduleActionTest — covers pending EMIs, empty result, and LWC method
- 90%+ coverage maintained across all classes

## What I Would Add in Production

- Einstein Sentiment Analysis on customer queries
- Escalation Flow to human agent for Defaulted loans
- Named Credential based authentication for external loan bureau APIs
- Experience Cloud deployment for customer-facing portal