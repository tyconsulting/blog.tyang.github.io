---
id: 2386
title: How To Configure OpsMgr 2012 Web Console Single Sign-On
date: 2014-02-27T21:07:12+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2386
permalink: /2014/02/27/configure-opsmgr-2012-web-console-single-sign/
categories:
  - SCOM
tags:
  - SCOM
---
I was trying to configure single sign-on for the OpsMgr 2012 Web Consoles so dashboard users don’t need to enter credentials on shared display screens. I spent almost a day trying to make it work until I gave up and called Microsoft Premier Support yesterday.

On all my management groups, web consoles are installed on a dedicated servers. All the web consoles are connecting to the management servers Load Balancing (NLB) address for Data Access Service rather than individual management servers.

Long story short, since I couldn’t manage to find a clear instruction / requirements for OpsMgr 2012 Web Console single sign-on, the steps listed below is what I had to take to make this work with the help from Microsoft CSS.

<strong>1. Data Access Service (SDK) SPN’s</strong>

Make sure the SPN’s for the management servers Data Access Service is correctly configured. SPN’s are also required for the NLB addresses:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image17.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb17.png" width="580" height="196" border="0" /></a>

<strong>2. Web Console config file Web.Config</strong>

In &lt;OpsMgr 2012 R2 Install Dir&gt;\WebConsole\WebHost\Web.config, the connection tag is configured as below:

&lt;connection <strong>autoSignIn="True"</strong> autoSignOutInterval="0"&gt;
&lt;session encryptionKey="SessionEncryptionKey"&gt;
&lt;overrideTicket encryptionKey="OverrideTicketEncryptionKey"/&gt;
&lt;/session&gt;
&lt;managementServer name="&lt;Mgmt Server or NLB Address&gt;"/&gt;
&lt;/connection&gt;

i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image18.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb18.png" width="580" height="98" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> I also configured autoSignOutInterval=”0” so the web console doesn’t time out.

further down in the web.config file, make sure authentication mode is set to “Windows”

<strong>&lt;authentication mode=”Windows” /&gt;</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image19.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb19.png" width="580" height="194" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> According to the note shown above, the Anonymous authentication should be disabled and Windows Authentication should be enabled for the OperationsManager vroot in IIS

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image20.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb20.png" width="580" height="225" border="0" /></a>

<strong>3. Constraint Delegation on the Web Console computer account</strong>

While I was trying to make it work before calling Microsoft, I followed the guide from this blog article: <a href="http://blogs.technet.com/b/momteam/archive/2008/01/31/running-the-web-console-server-on-a-standalone-server-using-windows-authentication.aspx">Running the Web Console Server on a standalone server using Windows Authentication</a>. Although it was written for OpsMgr 2007, constraint delegation is still required.

I added the MSOMSdkSvc service for all management servers to the list as instructed on the last page of this document:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image21.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb21.png" width="396" height="458" border="0" /></a>

Above screenshot was taken from the guide. However, it turned out it doesn’t seem like the guide is 100% correct for OpsMgr 2012 (I can’t confirm for 2007 as I don’t have a 2007 management group in my lab anymore).

Instead of choosing “Use Kerberos Only”, we should choose the other option <strong>“Use any authentication protocol”</strong>. This is where I got stuck as before I called Microsoft, I did change the NLB address to a management server in the web.config but it didn’t make a difference. Otherwise it would have worked then.

I also had to add the NLB address to the list because my web console is configured to use NLB:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image22.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb22.png" width="460" height="523" border="0" /></a>

This is all that’s required for Single Sign On. After I reboot the web console server, I managed to open the console without getting prompted for credentials.

<strong><span style="color: #ff0000;">Disclaimer:</span></strong> this article is purely based on my own experience. I managed to configure single sign-on on 4 OpsMgr 2012 R2 management groups at work and 1 at home. Please don’t hold me accountable for any issues you may have in your environment.