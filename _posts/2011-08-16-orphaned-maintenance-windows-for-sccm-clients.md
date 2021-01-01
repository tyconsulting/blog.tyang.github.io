---
id: 651
title: '&ldquo;Orphaned&rdquo; Maintenance Windows for SCCM clients'
date: 2011-08-16T11:53:41+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=651
permalink: /2011/08/16/orphaned-maintenance-windows-for-sccm-clients/
categories:
  - SCCM
tags:
  - SCCM
  - SCCM Clients Maintenance Windows
---
Last week, in my SCCM test environment, I noticed there are several maintenance windows applied to clients that I had no idea where were they come from.

<strong>Symptoms</strong>:

When using <a href="http://sourceforge.net/projects/smsclictr/">SCCM Client Center</a>, it shows this particular client (MGMT01) has 3 maintenance windows (service window) assigned to it:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb3.png" alt="image" width="580" height="345" border="0" /></a>

PolicySpy from <a href="http://www.microsoft.com/download/en/details.aspx?id=9257">ConfigMgr 2007 Toolkit</a> also shows the same:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb4.png" alt="image" width="580" height="110" border="0" /></a>

The problem is, there should ONLY be 1 maintenance window for this client:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb5.png" alt="image" width="580" height="143" border="0" /></a>

and actually, there is <strong>ONLY 1</strong> maintenance window in total in my entire environment:

I ran <strong>“SELECT * from v_ServiceWindow”</strong> against the site database and there is only 1 row returned.

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb6.png" alt="image" width="580" height="146" border="0" /></a>

<strong>Background</strong>:

Sometime last year, I installed a new central site called “<strong>CEN</strong>” and set the existing primary site “<strong>TAO</strong>” as the child site.

The only legitimate maintenance window in my SCCM hierarchy should be the one showed above in the database, it is created for a collection I created called “All Windows Server 2008 R2 Systems (CEN0000E)” on central site “CEN”.

I suspect I might have created 2 maintenance windows for the 2 built-in collections “All Systems" (SMS00001)” and “All Windows Server Systems (SMS000DS)” on site “TAO” before I configured “TAO” as child primary under “CEN”. but it has been too long and I couldn’t remember it.

<strong>Troubleshooting:</strong>

1. I tried to reset SCCM clients policies using PolicySpy, it did not help. these maintenance windows came back after machine policy retrieval and evaluation and it is logged in PolicyEvaluator.log:

<strong><em>Updating policy CCM_Policy_Policy4.PolicyID="SMS00001-{bf9d2dba-eb0a-412f-9147-82f12b4f136a}",PolicySource="SMS:TAO",PolicyVersion="1.00"    PolicyAgent_PolicyEvaluator    16/08/2011 8:23:41 AM    3624 (0x0E28)</em></strong>

<strong><em>Applying policy SMS00001-{bf9d2dba-eb0a-412f-9147-82f12b4f136a}    PolicyAgent_PolicyEvaluator    16/08/2011 8:23:41 AM    3624 (0x0E28)</em></strong>

2. Since I cannot modify the built-in collections from the child primary sites because they also exist in parent sites, and it is only a test environment, I removed parent-child relationship between CEN and TAO and waited overnight, then checked maintenance windows settings for SMS00001 and SMS000DS on TAO, there are no maintenance windows created for these 2 collections. So this step did not help me resolving the issue.

3. I then had a look at the policy table in both CEN and TAO site databases trying to find the policy for these orphaned maintenance windows using the policyID showed in PolicySpy:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb7.png" alt="image" width="580" height="251" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image8.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb8.png" alt="image" width="580" height="244" border="0" /></a>

I ran <strong>“SELECT * FROM Policy where PolicyID  LIKE 'SMS%'</strong>” on both site databases, “CEN” database returned nothing and “TAO” has returned 2 rows and the policyIDs match the ones for orphaned maintenance windows:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb9.png" alt="image" width="580" height="148" border="0" /></a>

I deleted these 2 rows from <strong>Policy</strong> table:

[sourcecode language="SQL" light="true"]
delete FROM Policy where PolicyID = 'SMS00001-{bf9d2dba-eb0a-412f-9147-82f12b4f136a}'
delete FROM Policy where PolicyID = 'SMS000DS-{4fe54281-f3f1-4b9f-9d9e-d1eb12b4a87e}'
[/sourcecode]

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb10.png" alt="image" width="580" height="177" border="0" /></a>

and from <strong>PolicyAssignment</strong> table:

[sourcecode language="SQL" light="true"]
delete FROM PolicyAssignment where PolicyID = 'SMS00001-{bf9d2dba-eb0a-412f-9147-82f12b4f136a}'
delete FROM PolicyAssignment where PolicyID = 'SMS000DS-{4fe54281-f3f1-4b9f-9d9e-d1eb12b4a87e}'
[/sourcecode]

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image11.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb11.png" alt="image" width="579" height="378" border="0" /></a>

Then restarted <strong>SMS_EXECUTIVE</strong> and <strong>SMS_SITE_COMPONENT_MANAGER</strong> services on TAO site server (also the MP). – Not sure if this is required, I did it anyway.

Finally, I <strong>reset</strong> SCCM client policy via PolicySpy and initiated <strong>“Machine Policy Retrieval and Evaluation Cycle”</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image12.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb12.png" alt="image" width="244" height="210" border="0" /></a>

Once evaluation is completed, SCCM Client Center is showing the correct maintenance windows setting:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image13.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb13.png" alt="image" width="580" height="143" border="0" /></a>

Since I need to do this to all SCCM clients (because SMS00001 = “All Systems” collection), I’ll create a software package with a batch file as program:

[sourcecode language="text" light="true"]
WMIC /Namespace:\\root\ccm path SMS_Client CALL ResetPolicy 1 /NOINTERACTIVE
WMIC /Namespace:\\root\ccm path SMS_Client CALL RequestMachinePolicy 1 /NOINTERACTIVE
[/sourcecode]

<span style="color: #ff0000;"><strong>Disclaimer</strong>: The purpose of this post is only to document the steps I have taken to resolve this particular issue in my <strong>TEST</strong> environment. I did not consult with any other parties (including Microsoft) during troubleshooting. Even though I have not seen any negative impacts after I implemented this change in my test environment, I am not responsible for any damages it may cause in other SCCM environments.</span>