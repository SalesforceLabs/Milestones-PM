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
public with sharing class Milestone1_Constants {
    
    static public String TEST3 = 'Github1'; // test
    static public String XML_VERSION = '1.0';
    static public String XML_EXPORT_VERSION_VAL = '1.0';
    static public String XML_EXPORT_VERSION = 'exportVersion';
    static public String XML_EXPORT = 'export';
    static public String XML_META = 'meta';
    static public String XML_ID = 'id';
    static public String XML_NAME = 'name';
    static public String XML_EXPORT_PACKAGE = 'exportPackage';
    static public String XML_EXPORT_PACKAGE_VAL = 'Milestone1_Project_Export';
    static public String XML_EXPORT_AUTHOR = 'exportAuthor';
    static public String XML_EXPORT_AUTHOR_EMAIL = 'exportAuthorEmail';
    static public String XML_EXPORT_ORG = 'exportOrganization';
    static public String XML_EXPORT_DATE = 'exportCreateDate';
    static public String OBJ_NAME_PROJECT = 'Milestone1_Project__c';
    static public String OBJ_NAME_MILESTONE = 'Milestone1_Milestone__c';
    static public String OBJ_NAME_SUB_MILESTONE = 'SubMilestone1_Milestone__c';
    static public String OBJ_NAME_LOG = 'Milestone1_Log__c';
    static public String OBJ_NAME_TASK = 'Milestone1_Task__c';
    static public String OJB_NAME_EXPENSE = 'Milestone1_Expense__c';
    static public String OBJ_NAME_TIME = 'Milestone1_Time__c';
    
    
    static public List<String> XML_OBJECT_PROCESS_ORDER = new List<String>{OBJ_NAME_MILESTONE,OBJ_NAME_LOG};
}