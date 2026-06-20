public class LoanStatusAction {

	@InvocableMethod(label='Get Loan Status' 
                     description='Returns loan details for a given loan number')
    public static List<Result> getLoanStatus(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request req : requests) {
            List<Loan_Account__c> loans = [
                SELECT Loan_Number__c, Outstanding_Balance__c, 
                       EMI_Amount__c, Next_Due_Date__c, Status__c
                FROM Loan_Account__c
                WHERE Loan_Number__c = :req.loanNumber
                LIMIT 1
            ];
            Result res = new Result();
            if (!loans.isEmpty()) {
                Loan_Account__c loan = loans[0];
                res.response = 'Loan ' + loan.Loan_Number__c + 
                    ' is currently ' + loan.Status__c + 
                    '. Outstanding balance: ₹' + loan.Outstanding_Balance__c + 
                    '. Next EMI of ₹' + loan.EMI_Amount__c + 
                    ' is due on ' + loan.Next_Due_Date__c.format();
            } else {
                res.response = 'No loan found with number ' + req.loanNumber;
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
    public static String getLoanStatusForLWC(String loanNumber) {
        List<Loan_Account__c> loans = [
            SELECT Loan_Number__c, Outstanding_Balance__c,
                   EMI_Amount__c, Next_Due_Date__c, Status__c
            FROM Loan_Account__c
            WHERE Loan_Number__c = :loanNumber
            LIMIT 1
        ];
        if (!loans.isEmpty()) {
            Loan_Account__c loan = loans[0];
            return JSON.serialize(loan);
        }
        return null;
    }

}