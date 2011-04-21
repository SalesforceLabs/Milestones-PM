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
public with sharing class Milestone1_General_Utility 
{
    public static String processTaskName(String name)
    {
        String nameString = name;
        if(nameString.length() >= 80)
        {
            nameString = nameString.subString(0,76);
            Integer lastSpaceLocation = Milestone1_General_Utility.truncateStringAtSpace(nameString);
            if(lastSpaceLocation > -1)
            {
                nameString = nameString.subString(0,lastSpaceLocation);
            }
            nameString = namesTring + '...';
        }

        return nameString;
    }

	/**
    * Checks if the current User have Permissions like System Admin
    * @return 		boolean
    * @author 		Sebastian Muñoz
    * @createDate 	January 19, 2011
    */
    public static Boolean isSysAdmin() {
    	Profile pObj = [SELECT PermissionsModifyAllData, Id FROM Profile WHERE Id=:Userinfo.getProfileId() limit 1];
		return pObj.PermissionsModifyAllData;
    }
    
    public static Integer truncateStringAtSpace(String inputString)
    {
        Integer location = inputString.lastIndexOf(' ');
        return location;
    }

	static testMethod void testTruncateString()
    {
        String example = 'NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG DESCRIPTION GREATER THAN 80 CHARACTER LIMIT FOR NAME TEST TRUNCATING';
        String nameString = Milestone1_General_Utility.processTaskName(example);
        system.AssertEquals('NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG...',nameString);
    } 
}