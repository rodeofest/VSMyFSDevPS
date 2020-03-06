@IsTest
private class ContactServiceTest {
    @IsTest
    static void testSinFormat() {
        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;

        Test.startTest();
        con.MCFD_SIN__c = '927 887 281';
        update con;
        con = [
            SELECT MCFD_SIN__c
            FROM Contact
            WHERE id = :con.id
            LIMIT 1
        ];
        System.assertEquals(con.MCFD_SIN__c, '927887281');
        Test.stopTest();
    }
}