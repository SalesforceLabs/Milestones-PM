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
public with sharing class Milestone1_Move_Exception extends Exception{
    
    public static final String ERROR_MILESTONE_ALREADY_ASSIGNED_PROJECT = system.label.Milestone1_MilestoneYouAreAttempting;
    public static final String ERROR_TASK_ALREADY_ASSIGNED_MILESTONE = system.label.Milestone1_TaskYouAreAttempting;
    public static final String ERROR_MILESTONE_COMPLETE = system.label.Milestone1_MilestoneIsComplete;
    public static final String ERROR_MILESTONE_HAS_SUCCESSORS = system.label.Milestone1_TopLevelMilestoneHasSuccessors;
    public static final String ERROR_MILESTONE_HAS_PREDECESSOR = system.label.Milestone1_TopLevelMilestoneHasPredecessor;
    
    static testMethod void testConstants() 
    {
        //Just a place holder test method for static constants on this exception class.
        system.assert(true);
    }

}