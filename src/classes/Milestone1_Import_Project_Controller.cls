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
public with sharing class Milestone1_Import_Project_Controller {
    public Milestone1_Project__c project {get; set;}
    public List<Document> docs {get;set;}
    public List<SelectOption> docOptions {get;set;}
    public String contentType {get;set;}
    public String docId{get;set;}
    public string fileName{get;set;}  
    public Blob fileBody{get;set;} 
    public Integer docsSize {get;set;} 
    public Integer maxFileSize {get; set;}
    public static Integer MAX_FILE_SIZE = 500000;
    
    private static String CONTENT_ERROR = system.label.ContentIsNotAllowedInProlog;
    
    public Milestone1_Import_Project_Controller(ApexPages.StandardSetController ssc)
    {
        docOptions = new List<SelectOption>();
        docs = [Select Id, Name from Document where Name like: 'EXPORT %' ];
        
        for (Document doc : docs)
        {
            docOptions.add(new SelectOption(doc.Id,doc.Name));
        }
        docsSize = docs.size();
    }
    
    public PageReference importTemplateXML() {
        
        try {

        	if( this.maxFileSize < 1 ){
        		throw new Milestone1_Import_Exception( Milestone1_Import_Exception.ERROR_EMPTY_XML );
        	}
            Milestone1_XML_Import_Utility importUtility = new Milestone1_XML_Import_Utility();
            String xml = '';
            if( fileBody != null && fileName != null ) {
                system.debug('The Import XML Size == ' + fileBody.size());
                if(fileBody.size() > MAX_FILE_SIZE) {
                    fileBody = null; // Null out the large filesize to prevent ViewState Max Size errors.
                    throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_FILESIZE_TOO_LARGE + ' The number of characters must be less than ' + MAX_FILE_SIZE +'.');
                }
                xml = fileBody.toString();  
            }
            else {
                xml = getDocumentXMLString();
            }
            if(xml == null || xml.length() < 1) {
                return ApexPages.currentPage();
            }

            project = importUtility.importProject(xml);
            
            
        }
        catch( Exception e ) {
            ApexPages.Message errorMsg = new ApexPages.Message( ApexPages.Severity.FATAL, e.getMessage() );
            if(e.getMessage() != null && e.getMessage().contains(CONTENT_ERROR)) {
                errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL,Milestone1_Import_Exception.ERROR_INVALID_XML);
            }
            ApexPages.addMessage( errorMsg );
            return ApexPages.currentPage();
        }
        return new ApexPages.StandardController(project).view();
    }
    
    
    public String getDocumentXMLString()
    {
        List<Document> docs = [Select Id, Body, ContentType From Document Where Id = :docId limit 1];
        if(docs.size() != 0)
        {
            String xml = docs.get(0).body.toString();
            return xml;
        }else
        {
            throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_NO_FILE_SELECTED);
        }
    }
 
}