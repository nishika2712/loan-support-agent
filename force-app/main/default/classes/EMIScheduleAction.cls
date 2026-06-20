public class EMIScheduleAction {

	@InvocableMethod(label='Get EMI Schedules'
					 description='Returns upcoming 3 pending EMIs for a given loan number')
	public static List<Result> getEmiSchedules(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            List<EMI_Schedule__c> emis = [
                SELECT Due_Date__c, Status__c, Amount__c
                FROM EMI_Schedule__c
                WHERE Loan_Account__r.Loan_Number__c = :req.loanNumber
				AND Status__c = 'Pending'
                ORDER BY Due_Date__c ASC
                LIMIT 3
            ];
            Result res = new Result();
            if (!emis.isEmpty()) {
                String scheduleDetails = 'Upcoming EMI schedule for loan ' + req.loanNumber + ':\n';
                Integer count = 1;
                for (EMI_Schedule__c emi : emis) {
                    scheduleDetails += count + '. Due Date: ' + emi.Due_Date__c.format() + 
                                       ' | Amount: ₹' + emi.Amount__c + 
                                       ' | Status: ' + emi.Status__c + '\n';
                    count++;
                }
                res.response = scheduleDetails;
            } else {
                res.response = 'No pending EMIs found for loan number ' + req.loanNumber + 
                               '. The loan may be fully paid or the loan number may be incorrect.';
            }
            
            results.add(res);
        }
        return results;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String loanNumber;
    }

    public class Result {
        @InvocableVariable
        public String response;
    }

    @AuraEnabled(cacheable=true)
    public static List<EMI_Schedule__c> getEMIScheduleForLWC(String loanNumber) {
        return [
            SELECT Due_Date__c, Amount__c, Status__c
            FROM EMI_Schedule__c
            WHERE Loan_Account__r.Loan_Number__c = :loanNumber
            AND Status__c = 'Pending'
            ORDER BY Due_Date__c ASC
            LIMIT 3
        ];
    }
}