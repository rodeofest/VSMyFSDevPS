public class ContactService {
    public static Contact sinFormat(Contact con) {
        try {
            if(con.MCFD_SIN__c != null) {
                con.MCFD_SIN__c = con.MCFD_SIN__c.replaceAll('[^0-9]','');
            }
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage());
        }
        return con;
    }
}