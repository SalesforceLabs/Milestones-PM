/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
global with sharing class Milestone1_Export_Project_Controller { 
    
    private final String ERROR_STRING_FILE_TOO_LONG = 
    	system.label.Milestone1_ProjectIsTooLarge + Milestone1_Import_Project_Controller.MAX_FILE_SIZE + 
    	system.label.Milestone1_CurrentExport;
    
    global Milestone1_Project__c rec {get; set;}
    global Boolean exportSuccess{get;set;}
    global Document doc{get;set;}
    global String errorMessage {get; private set;}
    
    global Milestone1_Export_Project_Controller(ApexPages.StandardController stc)
    {
    	errorMessage = null;
    	
        rec = [SELECT Id,
                      Name, 
                      Description__c 
               FROM Milestone1_Project__c
               WHERE Id = :stc.getId()
              ];
    }
    
    global void createExportXML()
    {
        Milestone1_XML_Export_Utility xmlUtil = new Milestone1_XML_Export_Utility();
        String xmlString = xmlUtil.buildProjectXmlString(rec.Id);
        
        // Check export length < max import size
        if( xmlString.length() > Milestone1_Import_Project_Controller.MAX_FILE_SIZE ){
        	errorMessage = ERROR_STRING_FILE_TOO_LONG.replace('$1', xmlString.length().format());
        }
        else{
	        String exportName = rec.Name;
	        String description = rec.Description__c;
	        //description max length on Milestone1_Project__c is 5000, but description on Documents has a maxlength of 255
	        if (description != null && description.length() > 250) {
	        	description=description.substring(0,250);
	        }
	        doc = saveToDocument(exportName,xmlString,description); 
        }
    }
    
    /**
    * Returns true if an error has been flagged
    *
    * @result Boolean True if any error has been flagged
    */
    global Boolean hasError(){
    	return this.errorMessage != null;
    }
    
    global PageReference returnToProject()
    {
        return new ApexPages.StandardController(rec).view();
    }
    
    global PageReference returnToDocument()
    {
        return new ApexPages.StandardController(doc).view();
    }
    
    global Document saveToDocument(String name, String xml, String description) {
        Document d = new Document();
        d.body = Blob.valueOf(xml);
        d.ContentType = 'text/xml';
        d.name = 'Export - ' + name + ' - ' + System.now() + '.xml';
        d.Description = description;
        d.FolderId = UserInfo.getUserId();
        insert d;
        return d;
  }
}