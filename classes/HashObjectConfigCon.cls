/***************************************************************************
 Name       : HashObjectConfigCon 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 10/31/2013
 Visualforce : HashObjectConfig
 Description  : HashObjectConfigCon is controller class that helps in building the Configurations for Selecting Object and fields. Makes it easy and will allow users to not make any errors when entering the data. 
 		   
****************************************************************************/
public with sharing class HashObjectConfigCon {

	// Public variables
	
	public String selectedObject 			{get;set;}
	public String selectedFields			{get;set;}
	public List<String> availableFields		{get;set;}
	public boolean isObjectSelected			{get;set;}
	
	private List<SelectOption> objectsList;
	
	private Hashmap__c currentHashMap;
	
	// Constructor
	
	public HashObjectConfigCon(){
		
		selectedFields 		= '"none"';
		isObjectSelected	= false;
		availableFields 	= new List<String>();
		
		objectsList = new List<SelectOption>();
		
		
		objectsList.add(new SelectOption('','--Select Object--'));
		init();
	}
	
	
	// This method gets all the Objects using GlobalDescribe.
	
	private void init(){
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         Set<String> objectKeys = gd.keySet();
         
         for(String objectKey: objectKeys) {              
             Schema.SobjectType sobjecttype = gd.get(objectKey);
             Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
             if(r.isAccessible() && r.isCreateable()){                                                 
                 objectsList.add(new SelectOption(r.getName(),r.getLabel()));                                  
             }            
       	 }

	}
	
	// Returns the objects
	public List<SelectOption> getAllObjects(){
		return objectsList;
	}
	
	// Load the fields, if the setting is already defined, load the settings as well.
	public void loadFieldSets(){
		
		if(selectedObject == null)
			return;
		
		availableFields 	= new List<String>();
		
		List<Hashmap__c> hashConfig = [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c where ObjectName__c = :selectedObject];
		
		if(hashConfig == null || hashConfig.size() == 0){
			currentHashMap 		= new Hashmap__c();
			selectedFields 		= '"none"';
		}else {
			currentHashMap = hashConfig[0];
			selectedFields = '';
			selectedFields = '"'+ currentHashMap.CommaSeparatedFields__c.trim() +'"';
			
		}
		
		Map<String, Schema.SobjectField> fieldsMap = Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap();
		
		for( String ky : fieldsMap.keySet() ){
			 DescribeFieldResult f = fieldsMap.get(ky).getDescribe();
			 
			 if(f.isAccessible() && f.isUpdateable()) {
			 	availableFields.add(f.getLocalName());
			 } 	
		}
		
		isObjectSelected = true;
		
	}
	
	// Save the settings to the Config object. (HashMap)
	
	public void saveSettings(){
		
		String selectedCSVFields = Apexpages.currentPage().getParameters().get('fields');
		system.debug('selectedCSVFields ' + selectedCSVFields);
		if(selectedCSVFields == '' || selectedCSVFields == null)
			return;
		
		currentHashMap.ObjectName__c = selectedObject;
		currentHashMap.CommaSeparatedFields__c = selectedCSVFields.removeEnd(',');
		
		upsert currentHashMap; // Upsert
		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Settings Updated for ' + selectedObject));
		
	}
	
	

}