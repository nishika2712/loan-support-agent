@isTest
private class EMIScheduleActionTest {
	@IsTest
    static void testGetEmiSchedules_Success() {

        // Create Loan Account
        Loan_Account__c loan = new Loan_Account__c(
            Loan_Number__c = 'LN1001'
        );
        insert loan;

        // Create Pending EMI Records
        List<EMI_Schedule__c> emiList = new List<EMI_Schedule__c>();

        for(Integer i = 1; i <= 3; i++) {
            emiList.add(new EMI_Schedule__c(
                Loan_Account__c = loan.Id,
                Due_Date__c = Date.today().addMonths(i),
                Amount__c = 5000,
                Status__c = 'Pending'
            ));
        }

        insert emiList;

        // Prepare Request
        EMIScheduleAction.Request req = new EMIScheduleAction.Request();
        req.loanNumber = 'LN1001';

        Test.startTest();
        List<EMIScheduleAction.Result> results = EMIScheduleAction.getEmiSchedules(new List<EMIScheduleAction.Request>{req});
		List<EMI_Schedule__c> res = EMIScheduleAction.getEMIScheduleForLWC('LN1001');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].response.contains('Upcoming EMI schedule for loan LN1001'));
        System.assert(results[0].response.contains('Pending'));
    }

    @IsTest
    static void testGetEmiSchedules_NoPendingEMIs() {

        // Create Loan Account
        Loan_Account__c loan = new Loan_Account__c(
            Loan_Number__c = 'LN2001'
        );
        insert loan;

        // Create EMI with status other than Pending
        EMI_Schedule__c emi = new EMI_Schedule__c(
            Loan_Account__c = loan.Id,
            Due_Date__c = Date.today().addMonths(1),
            Amount__c = 5000,
            Status__c = 'Paid'
        );
        insert emi;

        // Prepare Request
        EMIScheduleAction.Request req = new EMIScheduleAction.Request();
        req.loanNumber = 'LN2001';

        Test.startTest();
        List<EMIScheduleAction.Result> results = EMIScheduleAction.getEmiSchedules(new List<EMIScheduleAction.Request>{req});
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('No pending EMIs found for loan number LN2001. The loan may be fully paid or the loan number may be incorrect.',results[0].response);
    }
}