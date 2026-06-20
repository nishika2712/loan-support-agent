@isTest
private class LoanStatusActionTest {
	@isTest
    static void testGetLoanStatus_Success() {

        // Create test loan record
        Loan_Account__c loan = new Loan_Account__c(
            Loan_Number__c = 'LN1001',
            Outstanding_Balance__c = 50000,
            EMI_Amount__c = 2500,
            Next_Due_Date__c = Date.today().addDays(10),
            Status__c = 'Active'
        );
        insert loan;

        // Prepare request
        LoanStatusAction.Request req = new LoanStatusAction.Request();
        req.loanNumber = 'LN1001';

        List<LoanStatusAction.Request> requests = new List<LoanStatusAction.Request>{req};

        Test.startTest();
        List<LoanStatusAction.Result> results = LoanStatusAction.getLoanStatus(requests);
		String res = LoanStatusAction.getLoanStatusForLWC('LN1001');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].response.contains('LN1001'));
        System.assert(results[0].response.contains('Active'));
        System.assert(results[0].response.contains('50000'));
    }

    @isTest
    static void testGetLoanStatus_NoLoanFound() {

        // Prepare request with non-existing loan number
        LoanStatusAction.Request req = new LoanStatusAction.Request();
        req.loanNumber = 'INVALID123';

        List<LoanStatusAction.Request> requests = new List<LoanStatusAction.Request>{req};

        Test.startTest();
        List<LoanStatusAction.Result> results = LoanStatusAction.getLoanStatus(requests);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('No loan found with number INVALID123',results[0].response);
    }
}