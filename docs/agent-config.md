# Agent Configuration

Agent: **Loan Support Agent** (Agentforce Service Agent, ReAct planner), surfaces: Messaging and Customer Web Client.

The agent's topics and actions are stored as metadata in this repository (`bots/`, `genAiPlannerBundles/`, `genAiFunctions/`).

## Topics

### 1. Loan Status Inquiry
- **When it applies:** customer asks about loan status, outstanding balance, loan details or next EMI due date.
- **Action:** Get Loan Status → `LoanStatusAction` (Apex)
- **Behaviour:**
  1. Greet the customer and ask for their loan number (format `LN-001`).
  2. Call Get Loan Status.
  3. Return status, outstanding balance, EMI amount and next due date.
  4. Defaulted loan: respond with empathy and advise contacting the loan officer.
  5. Closed loan: congratulate the customer and confirm no further EMIs are due.
  6. Loan not found: ask the customer to verify the loan number.
  7. Ask whether there is anything else to help with.

### 2. EMI Schedule Inquiry
- **When it applies:** customer asks about upcoming EMI payments, payment schedule, due dates or pending instalments.
- **Action:** Get EMI Schedules → `EMIScheduleAction` (Apex), which returns the next 3 pending EMIs.
- **Behaviour:**
  1. Ask for the loan number.
  2. Call Get EMI Schedules.
  3. Present each pending EMI with its due date and amount.
  4. No pending EMIs: tell the customer the loan may be fully paid or closed.
  5. Overdue EMIs: respond with empathy and suggest contacting the loan officer.
  6. Ask whether there is anything else to help with.

### 3. General Loan FAQ
- **When it applies:** general questions about missed EMIs, repayment options, loan closure, or anything not covered above.
- **Actions:** none. Answers come from the model's general knowledge, and the agent states no facts about a specific account.
- **Behaviour:** missed EMI → empathy and advice to contact the loan officer. Loan closure questions → explain the process in general terms and direct account-specific questions to the loan status flow.

## Actions

| Action | Target | Inputs | Outputs |
| --- | --- | --- | --- |
| Get Loan Status | Apex `LoanStatusAction` | Loan number | Status, outstanding balance, EMI amount, next due date |
| Get EMI Schedules | Apex `EMIScheduleAction` | Loan number | Next 3 pending EMIs (due date, amount, status) |

The same Apex classes also serve the `loanSupportChat` LWC through `@AuraEnabled`.

## Known limitations

- **No identity verification.** The bot defines an `isVerified` variable and a `Verified_User` rule, but no topic or action uses them and nothing sets the variable. Any user who supplies a loan number receives that loan's details. This project uses synthetic data only; a production version needs an authenticated session or an OTP step, with the actions gated on verification.
- **No human escalation.** Topics have escalation disabled.
- **The FAQ topic is not grounded in documents.** It answers from general model knowledge, so wording is deliberately generic.
- **Chat only.** The voice context variable was removed so the bot deploys without Service Cloud Voice.