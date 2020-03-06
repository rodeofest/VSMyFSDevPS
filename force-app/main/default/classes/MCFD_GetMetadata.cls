public class MCFD_GetMetadata {
    @AuraEnabled
    public static String getListView(String listViewName, String objectType){
        String listViewId = '';
        List<ListView> listViews = new List<ListView>();
        
        listViews = [select Id, Name, SobjectType, DeveloperName, NamespacePrefix, issoqlcompatible 
                     from ListView 
                     where DeveloperName = :listViewName 
                     and SobjectType = :objectType];
        if(listViews.size() == 1)
            listViewId = listViews[0].Id;
        
        return listViewId;
    
    }
}