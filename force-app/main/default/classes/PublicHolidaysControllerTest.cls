@isTest
public class PublicHolidaysControllerTest {
    @testSetup
    static void setup() { 
        
        List<Account> accountList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Test1';
        account1.BillingState = 'NSW';
        accountList.add(account1);
        insert accountList;

        Public_Holiday__c publicHoliday = new Public_Holiday__c();
        publicHoliday.State__c = 'NSW';
        publicHoliday.Date__c = Date.today();
        publicHoliday.Name = 'Public Holiday';
        insert publicHoliday;


    }
    
    
    static testMethod void testCase1() {
        Test.startTest();

        Account account = [
            SELECT Id
            FROM Account
            WHERE Name='Test1'
        ];

        PublicHolidaysController.getAllPublicHolidays(account.Id);

        Test.stopTest();
    }
}