---
id: 2161
title: Issues with OpsMgr 2012 R2 Upgrade When Management Servers are Load-Balanced
date: 2013-10-30T15:44:43+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2161
permalink: /2013/10/30/issues-opsmgr-2012-r2-upgrade-management-servers-load-balanced/
categories:
  - SCOM
tags:
  - SCOM
---
<strong><span style="color: #ff0000;">27/01/2014 Update:</span></strong>

<em>A colleague of mine advised me the rsreportserver.config file for the SSRS instance also needs to be updated according to <a href="http://social.technet.microsoft.com/Forums/systemcenter/en-US/58551017-ffa3-4a39-862c-81307c5aa364/any-documentation-on-the-reporting-communication-changes-in-scom-2012">this Technet forum thread</a>. I have updated this article reflecting this additional step.</em>

I just came back to work this week after a 4-week holiday in China. Today I have upgraded work’s OpsMgr 2012 SP1 DEV management group to R2.

I firstly upgraded all 3 management servers, they all went smoothly without problems. but when I tried to run the upgrade for the Report Server and Web Console server (2 separate servers), both servers failed the prerequisites check with the same error:

<a href="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb1.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image_thumb[1]" alt="image_thumb[1]" src="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb1_thumb.png" width="512" height="389" border="0" /></a>

It’s saying that the management server the report server / web console server is pointing to has not been upgraded.

We have setup a F5 NLB VIP for all 3 management servers, and all management servers are indeed upgraded successfully. The Report Server and the Web Console server are pointing to the NLB for the default SDK (DAS) service. The <strong>OpsMgrSetupWizard.log</strong> on the report server shows the prerequisite checker cannot connect to the management server:

<a href="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb4.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image_thumb[4]" alt="image_thumb[4]" src="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb4_thumb.png" width="580" height="318" border="0" /></a>

To workaround this problem, I had to point the report server and the web console server to a particular management server (instead of a NLB address), run the upgrade and then point them back to the NLB address. To do so:

<strong><span style="font-size: large;">On the Report Server:</span></strong>

1. Change the registry string value “<strong>HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Reporting\DefaultSDKServiceMachine</strong>” from the NLB address to a management server FQDN.

2. Restart SQL Server Reporting Services

3. Run the Upgrade

4. Change the registry value back to the NLB address.

5. Restart SQL Server Reporting Services

<strong><span style="font-size: large;">On the Web Console Server:</span></strong>

1. Change the registry string value “<strong>HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\System Center Operations Manager\12\Setup\WebConsole\DEFAULT_SERVER</strong>” from the NLB address to a management server FQDN

<span style="color: #ff0000;"><strong>Updated 27/01/2014:</strong></span>

<span style="color: #ff0000;">2. Edit “&lt;SQL SSRS Install Dir&gt;\Reporting Services\ReportServer\rsreportserver.config” file, change the “ServerName” value under the &lt;Security&gt; and &lt;Authentication&gt; tags to the NLB address.</span>

<a href="http://blog.tyang.org/wp-content/uploads/2013/10/SSRS.jpg"><img class="alignnone size-full wp-image-2323" alt="SSRS" src="http://blog.tyang.org/wp-content/uploads/2013/10/SSRS.jpg" width="904" height="389" /></a>

2. Edit “<strong><span style="color: #ff0000;">&lt;OpsMgr 2012 SP1 Install Dir&gt;</span>\WebConsole\WebHost\Web.Config”</strong> file, change the “managementserver name” value within the &lt;connection&gt; tag from the NLB address to a management server FQDN

<a href="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb6.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" title="image_thumb[6]" alt="image_thumb[6]" src="http://blog.tyang.org/wp-content/uploads/2013/10/image_thumb6_thumb.png" width="580" height="165" border="0" /></a>

3. Open a command prompt as administrator and run “iisreset” to restart IIS.

4. Run the upgrade

5. Change the registry string value back to the NLB address.

6. Edit “<strong><span style="color: #ff0000;">&lt;OpsMgr 2012 R2 Install Dir&gt;</span>\WebConsole\WebHost\Web.Config”</strong> file, change the “managementserver name” value within the &lt;connection&gt; tag from the  management server FQDN to the NLB address (<span style="color: #ff0000;">note the location of this file has changed after the upgrade</span>).

3. Open a command prompt as administrator and run “iisreset” to restart IIS again.

After the upgrade, I verified both reporting and web console is working by running a report and logging onto the web console.