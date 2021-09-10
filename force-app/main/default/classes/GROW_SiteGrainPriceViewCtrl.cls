/*
* 
* 
*/

public with Sharing class GROW_SiteGrainPriceViewCtrl {
    /*
    @AuraEnabled 
    public static List<GrainPriceWrapper> getGrainPrices(){ 
        
        /*try{
            List<Grain_Price__c> lstGrainPrices = new List<Grain_Price__c>();
            List<GrainPriceWrapper> lstGrainPriceWrapper = new List<GrainPriceWrapper>();
            
            lstGrainPrices = [SELECT Id, Bin_Grade__c, Date__c, Price_Per_Metric_Tonne__c, Site__r.Name, Status__c
                              FROM Grain_Price__c 
                              ORDER BY Bin_Grade__c ASC, Site__r.Name ASC
                              LIMIT 200];
            
            if (lstGrainPrices.size() > 0){
                lstGrainPriceWrapper = transformGrainPrices(lstGrainPrices);
                prepareGrainPriceGridValues(lstGrainPrices);
            }
            
            system.debug('MMM -> lstGrainPriceWrapper: '+lstGrainPriceWrapper);
            return lstGrainPriceWrapper;
        }
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
*/
    @AuraEnabled 
    public static GrainPriceWrapper getGrainPrices(){ 
        
        Set<String> setSiteNames = new Set<String>();
        Set<String> setBinGrades = new Set<String>();
        List<String> headerRow = new List<String>();
        List<String> lstBinGrades = new List<String>();
        
        
        Map<String, String> mapBinGradeSitetoPrices = new Map<String, String>();
        List<List<String>> lstGrainPriceGrid = new List<List<String>>();
        
        List<Grain_Price__c> lstGrainPrices = new List<Grain_Price__c>();
        
        lstGrainPrices = [SELECT Id, Bin_Grade__c, Date__c, Price_Per_Metric_Tonne__c, Site__r.Name, Status__c
                          FROM Grain_Price__c
                          ORDER BY Bin_Grade__c ASC, Site__r.Name ASC
                          LIMIT 200];
        
        for(Grain_Price__c gp: lstGrainPrices){
            setSiteNames.add(gp.Site__r.Name);
            setBinGrades.add(gp.Bin_Grade__c);
            
            String key = gp.Bin_Grade__c +'-'+ gp.Site__r.Name;
            String value = String.valueOf(gp.Price_Per_Metric_Tonne__c);
            
            // [27-Aug-2021 - Mansoor] If the grain Price is 0, then display the text message "Not Purchasing".
            if (gp.Price_Per_Metric_Tonne__c == 0.0){
                value = gp.Status__c;
            }
            
            mapBinGradeSitetoPrices.put(key, value);
        }
        
        headerRow.addAll(setSiteNames);
        lstBinGrades.addAll(setBinGrades);
        
        lstGrainPriceGrid = prepareGrainPriceTable(headerRow, lstBinGrades, mapBinGradeSitetoPrices); 
        headerRow.add(0, 'Bin Grades'); // Add Blank Cell
        return new GrainPriceWrapper(headerRow, lstGrainPriceGrid);
        
    }
    
    public class GrainPriceWrapper{
        /*
        @AuraEnabled public String BinGrade{get;set;}
        @AuraEnabled public String Site{get;set;}
        @AuraEnabled public String Price{get;set;}
		*/
        
        @AuraEnabled public List<String> HeaderRow{get; set;}
        @AuraEnabled public List<List<String>> GrainPriceGrid{get; set;}
        
        public GrainPriceWrapper(List<String> headerRowPrm, List<List<String>> grainPriceGridPrm){
            this.HeaderRow = headerRowPrm;
            this.GrainPriceGrid = grainPriceGridPrm;
        }
    }
    
    /* ------------- HELPER METHODS -------------- */
    	/*
    private static List<GrainPriceWrapper> transformGrainPrices(List<Grain_Price__c> lstGrainPricesPrm){
        GrainPriceWrapper newGrainWrapper;
        List<GrainPriceWrapper> lstGrainWrapper = new List<GrainPriceWrapper>();
        
        for(Grain_Price__c gprice: lstGrainPricesPrm){
            newGrainWrapper = new GrainPriceWrapper();
            newGrainWrapper.BinGrade = gprice.Bin_Grade__c;
            newGrainWrapper.Site = gprice.Site__r.Name;
            
            // [27-Aug-2021 - Mansoor] If the grain Price is 0, then display the text message "Not Purchasing".
            if (gprice.Price_Per_Metric_Tonne__c == 0.0){
                newGrainWrapper.Price = gprice.Status__c;
            }
            else{
                newGrainWrapper.Price = String.valueOf(gprice.Price_Per_Metric_Tonne__c);
            }
            
			lstGrainWrapper.add(newGrainWrapper);
        }
        
        return lstGrainWrapper;
    } 
    */
    private static List<List<String>> prepareGrainPriceTable(List<String> headerRowPrm, List<String> lstBinGradesPrm, Map<String, String> mapGrainPricePrm){
        
		List<List<String>> grainPriceGrid = new List<List<String>>();
        
        for (String binGrade: lstBinGradesPrm){
            
            List<String> lstGridCellPrices = new List<String>();
            lstGridCellPrices.add(binGrade);
            
            for (String siteName: headerRowPrm){
                
                if (mapGrainPricePrm.containsKey(binGrade +'-'+ siteName)){
                    lstGridCellPrices.add(mapGrainPricePrm.get(binGrade +'-'+ siteName));
                }
                
                else{
                    lstGridCellPrices.add(' ');
                }
            }
            
            grainPriceGrid.add(lstGridCellPrices);
        }
        
        
        return grainPriceGrid;
    }
    
}