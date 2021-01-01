---
id: 5475
title: ConfigMgr OMS Connector
date: 2016-08-06T21:37:39+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5475
permalink: /2016/08/06/configmgr-oms-connector/
categories:
  - OMS
  - PowerShell
  - SCCM
tags:
  - OMS
  - Powershell
  - SCCM
---
Earlier this week, Microsoft has release a new feature  in System Center Configuration Manager 1606 called OMS Connector:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image.png"><img style="padding-top: 0px; padding-left: 0px; margin: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb.png" alt="image" width="200" height="244" border="0" /></a>

As we all know, OMS supports computer groups. We can either manually create computer groups in OMS using OMS search queries, or import AD and WSUS groups. With the ConfigMgr OMS Connector, we can now import ConfigMgr device collections into OMS as computer groups.

Instead of using the OMS workspace ID and keys to access OMS, the ConfigMgr OMS connector requires an Azure AD Application and Service Principal. My friend and fellow Cloud and Data Center Management MVP Steve Beaumont has blogged his setup experience few days ago. You can read Steve’s post here: <a title="http://www.poweronplatforms.com/configmgr-1606-oms-connector/" href="http://www.poweronplatforms.com/configmgr-1606-oms-connector/">http://www.poweronplatforms.com/configmgr-1606-oms-connector/</a>.  As you can see from Steve’s post, provisioning the Azure AD application for the connector can be pretty complex if you are doing it manually – it contains too many steps and you have to use both the old Azure portal (<a href="https://manage.windowsazure.com">https://manage.windowsazure.com</a>) and the new Azure Portal (<a href="https://portal.azure.com">https://portal.azure.com</a>).

To simplify the process, I have created a PowerShell script to create the Azure AD application for the ConfigMgr OMS Connector. The script is located in my GitHub repository: <a title="https://github.com/tyconsulting/BlogPosts/tree/master/OMS" href="https://github.com/tyconsulting/BlogPosts/tree/master/OMS">https://github.com/tyconsulting/BlogPosts/tree/master/OMS</a>

In order to run this script, you will need the following:
<ul>
 	<li>The latest version of the AzureRM.Profile and AzureRM.Resources PowerShell module</li>
 	<li>An Azure subscription admin account from the Azure Active Directory that your Azure Subscription is associated to (the UPN must match the AAD directory name)</li>
</ul>
When you launch the script, you will firstly be prompted to login to Azure:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-1.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-1.png" alt="image" width="520" height="376" border="0" /></a>

Once you have logged in, you will be prompted to select the Azure Subscription and then specify a display name for the Azure AD application. If you don’t assign a name, the script will try to create the Azure AD application under the name “ConfigMgr-OMS-Connector”:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/SNAGHTMLc560723.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="SNAGHTMLc560723" src="http://blog.tyang.org/wp-content/uploads/2016/08/SNAGHTMLc560723_thumb.png" alt="SNAGHTMLc560723" width="700" height="297" border="0" /></a>

This script creates the AAD application and assign it Contributor role to your subscription:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-2.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-2.png" alt="image" width="378" height="217" border="0" /></a>

At the end of the script, you will see the 3 pieces of information you need to create the OMS connector:
<ul>
 	<li>Tenant</li>
 	<li>Client ID</li>
 	<li>Client Secret Key</li>
</ul>
You can simply copy and paste these to the OMS connector configuration.

Once you have configured the connector in ConfigMgr and enabled SCCM as a group source, you will soon start seeing the collection memberships being populated in OMS. You can search them in OMS using a search query such as <strong>“Type=ComputerGroup GroupSource=SCCM”:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-3.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-3.png" alt="image" width="675" height="315" border="0" /></a>

Based on what I see, the connector runs every 6 hours and any membership additions or deletions will be updated when the connector runs.

i.e. If I search for a particular collection based on the last 6 hours, I can see this particular collection has 9 members:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-4.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-4.png" alt="image" width="591" height="151" border="0" /></a>

During my testing, I deleted 2 computers from this collection few days ago. If I specify a custom range targeting a 6-hour time window from few days ago, I can see this collection had 11 members back then:

<a href="http://blog.tyang.org/wp-content/uploads/2016/08/image-5.png"><img style="padding-top: 0px; padding-left: 0px; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/08/image_thumb-5.png" alt="image" width="583" height="287" border="0" /></a>

This could be useful sometimes when you need to track down if certain computers have been placed into a collection in the past.

This is all I have to share today. Until next time, enjoy OMS <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http://blog.tyang.org/wp-content/uploads/2016/08/wlEmoticon-smile.png" alt="Smile" />.