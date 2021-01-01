---
id: 6315
title: Getting Azure AD Tenant Common Configuration Such as Tenant ID Using PowerShell
date: 2018-01-07T23:48:12+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6315
permalink: /2018/01/07/getting-azure-ad-tenant-common-configuration-such-as-tenant-id-using-powershell/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure AD
  - PowerShell
---
It has been a long time since my last post. I was very busy right until the Christmas eve, and it my to-be-blogged list is getting longer and longer. I had a very good break during the holiday period. My partner and I took our daughter to Sydney on the Christmas day and spent 5 days up there. When we were in Sydney, I visited Hard Rock Cafe for the first time in my life, and also spent 2 days with my buddy and MVP colleague Alex Verkinderen.

Now that I’m somewhat recharged, I will start working on the backlog of these blog posts. I’ll start an easy one today – A quick and easy way to retrieve Azure AD tenant ID (and other pieces of information) using PowerShell without having to authenticate first. This method was shown to me by a colleague at a customer site. He asked me if there is a way to get AAD Tenant ID GUID without having to authenticate to Azure AD first. Before I had time to do any research, he figured out by himself and shown me how it’s done. So full credit goes to my colleague.

Basically, there’s an open REST endpoint you can hit to get the AAD tenant information. This end point is:

https://login.windows.net/<strong>&lt;Tenant Id or Tenant Name&gt;</strong>/.well-known/openid-configuration

I have wrapped this into a PowerShell function:

https://gist.github.com/tyconsulting/7c313dc98947f0e413cf69b0b2321013

You can pass either the Tenant ID into the function (to get other common configuration such as AAD oAuth token endpoint, etc.) or using Tenant Name if you are not sure what the Tenant ID is and you wish to retrieve it.

For example, if I want to retrieve the common configuration for Microsoft’s own AAD tenant (microsoft.com or microsoft.onmicrosoft.com):

<a href="https://blog.tyang.org/wp-content/uploads/2018/01/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/01/image_thumb.png" alt="image" width="982" height="722" border="0" /></a>

The AAD tenant ID is part of several endpoint URIs returned from your request (i.e. in token_endpoint URI as shown above). you can easily retrieve it in PowerShell. i.e.
<pre class="lang:ps decode:true ">(Get-AADTenantConfiguration -TenantName microsoft.onmicrosoft.com).token_endpoint.split('/')[3]</pre>
&nbsp;

<a href="https://blog.tyang.org/wp-content/uploads/2018/01/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/01/image_thumb-1.png" alt="image" width="971" height="72" border="0" /></a>