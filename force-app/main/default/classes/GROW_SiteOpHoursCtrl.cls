/*
* 
* 
*/

public with Sharing class GROW_SiteOpHoursCtrl {
    
    @AuraEnabled 
    public static List<SiteWrapper> getSites(){ 
        
        try{
            List<Site__c> lstParentSites = new List<Site__c>();
            List<SiteWrapper> lstSites = new List<SiteWrapper>();
            
            lstParentSites = [SELECT Id, Name, Phone__c, Address__c, Site_Related_Alert__c, Site_Manager__r.Name, Site_Manager_Mobile__c, 
                              (SELECT Id, Name, Open_Time__c, Closing_Time__c, Closed__c FROM Operation_Hours__r)
                              FROM Site__c 
                              ORDER BY Name ASC
                              LIMIT 50];
            
            if (lstParentSites.size() > 0){
                lstSites = transformSites(lstParentSites);
            }
            
            return lstSites;
        }
        catch (Exception e){
            throw new AuraHandledException (e.getMessage());
        }
    }
    
    public class SiteWrapper{
        
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String Phone{get;set;}
        @AuraEnabled public String Address{get;set;}
        @AuraEnabled public String MonHours{get;set;}
        @AuraEnabled public String TueHours{get;set;}
        @AuraEnabled public String WedHours{get;set;}
        @AuraEnabled public String ThuHours{get;set;}
        @AuraEnabled public String FriHours{get;set;}
        @AuraEnabled public String SatHours{get;set;}
        @AuraEnabled public String SunHours{get;set;}
        @AuraEnabled public String SiteRelatedAlert{get;set;}
        @AuraEnabled public String SiteManagerName{get;set;}
        @AuraEnabled public String SiteManagerMobile{get;set;}
    }
    
    /* ------------- HELPER METHODS -------------- */
    
    private static List<SiteWrapper> transformSites(List<Site__c> lstSitesPrm){
        SiteWrapper newSite;
        List<SiteWrapper> lstSiteWrapper = new List<SiteWrapper>();
        
        for(Site__c st: lstSitesPrm){
            newSite = new SiteWrapper();
            newSite.Name = st.Name;
            newSite.Address = st.Address__c;
            newSite.Phone = st.Phone__c;
            newSite.SiteRelatedAlert = st.Site_Related_Alert__c;
            newSite.SiteManagerName = st.Site_Manager__r.Name;
            newSite.SiteManagerMobile = st.Site_Manager_Mobile__c;
            
            if (st.Operation_Hours__r.size() > 0){
                for (Operation_Hours__c opHours: st.Operation_Hours__r){
                    
                    if(opHours.Name == 'Monday'){
                        if (opHours.Closed__c) newSite.MonHours = 'Closed';
                        else  newSite.MonHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Tuesday'){
                        if (opHours.Closed__c) newSite.TueHours = 'Closed';
                        else  newSite.TueHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Wednesday'){
                        if (opHours.Closed__c) newSite.WedHours = 'Closed';
                        else  newSite.WedHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Thursday'){
                        if (opHours.Closed__c) newSite.ThuHours = 'Closed';
                        else  newSite.ThuHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Friday'){
                        if (opHours.Closed__c) newSite.FriHours = 'Closed';
                        else  newSite.FriHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Saturday'){
                        if (opHours.Closed__c) newSite.SatHours = 'Closed';
                        else  newSite.SatHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                    else if (opHours.Name == 'Sunday'){
                        if (opHours.Closed__c) newSite.SunHours = 'Closed';
                        else  newSite.SunHours = getFormattedTime(opHours.Open_Time__c) + ' - ' + getFormattedTime(opHours.Closing_Time__c);
                    }
                }
            }
            
            //system.debug('MMM -> Site Wrapper - newSite: '+newSite);
            lstSiteWrapper.add(newSite);
        }
        
        return lstSiteWrapper;
    }
    
    private static String getFormattedTime(Time t){
        if (t == null)
            return '';
        else{
            DateTime dt = DateTime.newInstance(Date.today(), t);
            return dt.format('hh:mm a');
        }
    } 
    
}