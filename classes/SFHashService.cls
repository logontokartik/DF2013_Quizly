/***************************************************************************
 Name       : SFHashService 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 10/31/2013
 Description  : The Custom Apex REST Service, that accepts the List of Ids and Hashes of the Records and compares with the current Data in the system and returns back the Ids that are changed.
 
 
 URL :  '/services/apexrest/1.0/Hash'
 Method : POST only
 
 Format : {"<Salesforce Id","<Hash Value>}"
 
 Sample JSON : 
 
 {
    "001i000000RSUnAAAX": "6GNeh4vpsYUrM2eBCm6M1G0/QrU=",
    "001i000000Ra2CDAAZ": "MhN1IgD4lz9VWNItwfkc0Lf2hrM=",
    "001i000000Ra2CLAAZ": "+NthbVRzEPPMHMW58ZyTqXluxs8=",
    "001i000000RSURuAAP": "iM6QQqERKhdbg6dUfz9gIt3Nsio=",
    "001i000000Ra2CKAAZ": "ZzQpVk7W3TxpBloR0PA36BBBBrA=",
    "001i000000Ra2CBAAZ": "feb5FCvh+8+m21QpjGQA99s0B40=",
    "001i000000Ra2CEAAZ": "KBjyskrBN2bHcXXhKE/lnGIY5pk=",
    "001i000000RSU5dAAH": "SVVhZTkycMKn/i8x8QKqmxQ9mCQ=",
    "001i000000RSUkEAAX": "DJmR/ROwvwk3F0geiIHHQAUjHoo=",
    "001i000000Ra2CJAAZ": "QA7XQlsKYxnhCr1LgI+I5Uclags=",
    "001i000000RSUk4AAH": "kFiWPdhR5vd0O1LzO6j9hRP1hBc=",
    "001i000000Ra2CIAAZ": "+amNbeV1HKFfrn1f7kT4HfH+imM=",
    "001i000000Ra2CCAAZ": "p4am0WEZtR76XR7LZy6Gk4prPoc=",
    "001i000000RSUkdAAH": "NnmR2muURJpnf8ACMbYU5PetYEs=",
    "001i000000Ra2CFAAZ": "q7B4znPEeRM2fUDIYxTGNy2XlVA=",
    "001i000000Ra2CGAAZ": "3r/jrYQrL7szc0JbIzKtNR0BZHA=",
    "001i000000Ra2CHAAZ": "mC0hahE1uZpiibW3fCPxkw5mV/4=",
    "001i000000Ra2CAAAZ": "5+gy69izHvcIPZ0r3UBrCXznTFs="
}
 
 
The Service uses the SHA1 algorithm that is combined with various Crypto Methods to generate the SHA1 Hash. Also the settings for each object are defined in the HashMap Custom Object, where you can select the fields you want to use the map for.

All the errors are returned as custom Exceptions HashException.
 				   
 		   
****************************************************************************/


@RestResource(urlMapping='/1.0/Hash')
global with sharing class SFHashService {
	
	// Static hash variable	
	public static String HashAlgorithmSHA1='SHA1';
	
	
	// Post Method
	@HttpPost
	global static List<String> doPost(){
		
		RestRequest req  = RestContext.request;
		RestResponse res = RestContext.response;
		
		String jsonBody = req.requestBody.toString().trim();
		Map<String,String> inputMaps;
		
		try {
			inputMaps = (Map<String,String>)JSON.deserialize(jsonBody,Map<String,String>.class);
		}catch(Exception e){
			throw new HashException('Exception parsing JSON; check body ' + e.getMessage());
		}
		
		return differences(inputMaps);
				
				
	}
	
	// Method to return the Differences.
	
	private static List<String> differences(Map<String,String> hashMapValues){
		
		// Local Definitions
		List<String> differentIds 			= new List<String>();
		Map<String,String> newhashMapValues = new Map<String,String>();
		Map<String,String> objectSettings 	= new Map<String,String>();
		Map<String,Set<String>> idTypeMap 	= new Map<String,Set<String>>();
		
		
		// Populate all the Types into the Map, so it would be Map of ObjectName => List<Ids>
		for(Id s : hashMapValues.keySet()){
			
			String sobjectName = s.getSObjectType().getDescribe().getName();
			
			Set<String> ids;
			
			if(idTypeMap.get(sobjectName) != null){
				ids = idTypeMap.get(sobjectName);
			}else{
				ids = new Set<String>();
			}
			
			ids.add(s);
			
			idTypeMap.put(sobjectName,ids);
			
		}
		
		// Get the Config Settings for the Object types that are sent.
		
		for(Hashmap__c m : [Select Id, ObjectName__c, CommaSeparatedFields__c from Hashmap__c where ObjectName__c in :idTypeMap.keySet()]){
			objectSettings.put(m.ObjectName__c,m.CommaSeparatedFields__c);
		}		
		
		// Throw exceptions if not found or if more than 100 types are sent. 
		
		if(objectSettings.size()==0){
			throw new HashException('Hashmap Config not defined for sent SObject Types');
		}
		
		if(idTypeMap.keySet().size() > 100){
			throw new HashException('Cannot have more than 100 different SObject Types');
		}
		
		try {
			// Get the current Record in Salesforce for each SobjectType Set
			for(String s : idTypeMap.keySet()){ 
				
				Set<String> idSet 	  = idTypeMap.get(s);
				String soql 	  	  = 'Select Id, ' + objectSettings.get(s).trim() + ' from ' + s + ' WHERE ID IN :idSet';
				List<SObject> records = Database.query(soql);
				
				for(SObject o : records){
					newhashMapValues.put(o.Id,EncodingUtil.base64Encode(Crypto.generateDigest(HashAlgorithmSHA1, convertObject(o))));
				}
				 
			}
			// Compare and return.
			for(String s : hashMapValues.keySet()){
				if(newhashMapValues.get(s) == null || (newhashMapValues.get(s) != hashMapValues.get(s)))
					differentIds.add(s);
			}
		
		}catch(Exception e){
			throw new HashException('Error in main handle ' + e.getMessage());
		}
		
		return differentIds;
		
	}
	
	// Utility Methods 

	private static Blob convertObject(SObject o){
		return Blob.valueof(JSON.serialize(o));
	}
	
	public class HashException extends Exception {
		
	}
	

}