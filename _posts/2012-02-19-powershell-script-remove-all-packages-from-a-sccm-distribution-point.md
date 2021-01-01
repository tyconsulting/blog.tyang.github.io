---
id: 1015
title: 'PowerShell Script: Remove All Packages From A SCCM Distribution Point'
date: 2012-02-19T19:19:58+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1015
permalink: /2012/02/19/powershell-script-remove-all-packages-from-a-sccm-distribution-point/
categories:
  - PowerShell
  - SCCM
tags:
  - Featured
  - Powershell
  - SCCM
---
Often, SCCM administrators found packages still assigned to distribution points that no longer exist. There are scripts available to remove these “orphaned” package distributions via SMS Provider. i.e. This one called <strong>DPClean.vbs</strong> from TechNet Blog: <a href="http://blogs.msdn.com/b/rslaten/archive/2006/03/01/removing-a-retired-dp-from-all-your-packages.aspx">Removing a retired DP from all your packages</a>. It was written for SMS 2003.

I’m not sure if SMS 2003 works differently when deleting package distribution via SMS Provider as I don’t have a SMS 2003 environment around that I can test. But, this script may not work in a multi-tiered SCCM environment (multiple primary sites below a central site). This script only tries to remove package distributions from the site where the user entered.

Use my test environment at home as an example to explain the issue with this script in SCCM 2007:

I have a central site (Site Code: CEN, Site Server: ConfigMgr00), a primary site (Site Code: TAO, Site Server: ConfigMgr01) and a secondary site (Site Code: S01, Site Server; ConfigMgr02) reporting to the primary site TAO.

I created a package called “Configure Windows Firewall Service” on my central site CEN. The Package ID is CEN00013:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb.png" alt="image" width="580" height="254" border="0" /></a>

This package has been assigned to 2 distribution points:

<strong>ConfigMgr01</strong>

<strong>MGMT02\Packages$</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image1.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb1.png" alt="image" width="580" height="191" border="0" /></a>

Notice that there is a pad lock symbol next to ConfigMgr01. If you right click <a href="//\\MGMT02\Packages$">\\MGMT02\Packages$</a>, there is a “Delete” option:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image2.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb2.png" alt="image" width="563" height="318" border="0" /></a>

When right click CONFIGMGR01, “Delete” option is not available:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image3.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb3.png" alt="image" width="580" height="280" border="0" /></a>

This is because even though the package was created on the central site CEN, but this package was assigned to the DP CONFIGMGR01 on the child primary site TAO.

If I get to the package on Child Primary site TAO, there is no pad lock on CONFIGMGR01 and the “Delete” option is available:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image4.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb4.png" alt="image" width="580" height="302" border="0" /></a>

If I use the same way as DPClean.vbs (only in PowerShell this time):

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image5.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb5.png" alt="image" width="580" height="388" border="0" /></a>

I Firstly locate the package distribution from the central site CEN’s SMSProvider, then use delete() method to remove it, I get a “Generic failure” error.

Notice that the properties of the package distribution object, the SourceSite value is “TAO”. it means the package was assigned to the specific DP from site “TAO”.

Now, if I repeat above PowerShell commands on site “TAO”:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image6.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb6.png" alt="image" width="580" height="292" border="0" /></a>

No errors returned as it was successfully deleted.

Now, on the SCCM console:

On TAO:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image7.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb7.png" alt="image" width="500" height="279" border="0" /></a>

On CEN:

<a href="http://blog.tyang.org/wp-content/uploads/2012/02/image9.png"><img style="padding-left: 0px; padding-right: 0px; padding-top: 0px; border: 0px;" src="http://blog.tyang.org/wp-content/uploads/2012/02/image_thumb9.png" alt="image" width="499" height="270" border="0" /></a>

The DP was deleted on both sites.

In conclusion, no matter which method is used (either via GUI or via SMS provider), the package can only be removed from a DP on the site where it was distributed.

I am also facing the issues around how the SCCM environment is operated at work. we have around over 1000 branch DPs across multiple primary sites. These branch DPs often get decommissioned or rebuilt (not by people who manage SCCM). the people who decommission these Branch DPs do not have knowledge on how SCCM environment is setup. I would not expect them to correctly enter the SCCM site server name when running the script.

Therefore I’ve re-written the script in PowerShell. The only parameter this script requires is the name of the distribution point (can be a normal DP, a DP that’s a Server Share or a Branch DP).

<strong>Pre-requisites:</strong>
<ul>
	<li>The SCCM site information are published in AD</li>
	<li>Remote registry service is enabled on both management point and the site server.</li>
	<li>The account that runs the script needs to have admin access to the management point and site server.</li>
	<li>The account that runs the script has access to SMS provider’s WMI namespace root\sms\site_&lt;site code&gt;.</li>
</ul>
<strong>How the script works:</strong>
<ol>
	<li>Search AD for active/accessible SCCM sites</li>
	<li>Connect to the management point and site server of each site published in AD and get details of each SCCM site.</li>
	<li>Connect to the SMS provider of each discovered primary site and search for the distribution point.</li>
	<li>If the distribution point is found, connect the SMS provider of the primary site where the DP belongs to and get a list of all packages that are assigned to this DP. The list of packages assigned to the DP is displayed on the PowerShell console. If nothing is found, the script ends.</li>
	<li>For each package distribution that belongs to DP’s home primary site, delete it using the delete() method.</li>
	<li>For each package distribution that belongs to other primary sites, search for the site info of that particular site from the list that obtained from step 2, and get the SMS provider server name. Then connect to the SMS provider of the source site and delete the package distribution using delete() method.</li>
	<li>details of any successful and failed deletions are displayed on the PowerShell console.</li>
	<li>Wait for 15 seconds, repeat step 3 to double check, see if there are still any packages been assigned to the DP.</li>
	<li>If there are still packages assigned to the DP, display a message on the PowerShell console with instruction and a SQL query to run against the SCCM site database to remove them from the database (*Note: deleting straight off the database is not supported by Microsoft.)</li>
</ol>
<strong>An Issue with the script:</strong>

While I was testing the script, I did find an issue (not sure if the issue is with the logics of the script or, with SCCM itself).

I ran the script to delete all packages off a DP located on my secondary site S01. at that time, there were 3 “Install_Pending” packages against this DP. there were assigned to this DP from the central site CEN. The script ran successfully, deleted all packages on this DP from each package distribution’s source site, including these 3 “Install_Pending” packages (from CEN). However, when double check again, these 3 packages still exist in S01’s primary site TAO’s database. So, the deletions have not been replicated from central site CEN to child primary TAO.

This is why I configured the script to display instructions on how to remove them from site database (unsupported way).

The script can be downloaded here: <a href="http://blog.tyang.org/wp-content/uploads/2012/02/Clean-DP.zip">Clean-DP.PS1</a>

<span style="color: #ff0000;"><strong>*Note:</strong></span> This script DOES NOT remove the actual packages from the hard disks of distribution points. The script does not actually connect to the DP at all. it can run AFTER the DP is decommissioned.

&nbsp;

Please do not hesitate to contact me if you have any issues or questions about this script.