---
id: 5706
title: Feeding Your Power BI Reports from Azure Functions
date: 2016-10-14T07:35:33+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5706
permalink: /2016/10/14/feeding-your-power-bi-reports-from-azure-functions/
categories:
  - Azure
  - Power BI
tags:
  - Azure
  - Azure Functions
  - Power BI
  - PowerShell
---

## Background

Few days ago my good friend and fellow CDM MVP Alex Verkinderen (<a href="https://twitter.com/AlexVerkinderen">@AlexVerkinderen</a>) had a requirement to produce a Power BI dashboard for Azure AD users. so Alex and I started discussing a way to produce such report in Power BI. After exploring various potential possibilities, we have decided to leverage Azure Functions to feed data into Power BI. You can check out the Power BI solution Alex has built on his blog here: <a href="http://www.mscloud.be/retrieve-azure-aad-user-information-with-azure-functions-and-publish-it-into-powerbi">http://www.mscloud.be/retrieve-azure-aad-user-information-with-azure-functions-and-publish-it-into-powerbi</a>

In this blog post, I’m not going to the details of how the AAD Users Power BI report was built. Instead, I will focus on the Azure Functions component and briefly demonstrate how to build a Azure Functions web service and act as a Power BI data source. As an example for this post, I’ll build a Azure Functions web service in PowerShell that brings in Azure VMs information into Power BI. To set the stage, I have already written two blog posts yesterday on Azure Functions:
<ul>
 	<li><a href="http://blog.tyang.org/2016/10/07/using-custom-powershell-modules-in-azure-functions/">Using Custom PowerShell Modules in Azure Functions</a></li>
 	<li><a href="http://blog.tyang.org/2016/10/08/securing-passwords-in-azure-functions/">Securing Passwords in Azure Functions</a></li>
</ul>
These two posts demonstrated two important steps that we need to prepare for the Azure Functions PowerShell code. We will need to follow these posts and prepare the following:
<ul>
 	<li>Upload the latest AzureRM.Profile and AzureRM.Compute PowerShell modules to Azure Functions</li>
 	<li>Encrypt the password for the service account to be used to access the Azure subscription.</li>
</ul>
Once done, we need to update the user name and the encrypted password in the code below (line 24 and 25)

https://gist.github.com/tyconsulting/99f44feff3dbf1287ababa9d652b3064

I have configured the function authorization level to "Function" which means I need to pass an API key when invoking the  function. I also need to pass the Azure subscription Id via the URL. To test, I’m using the Invoke-WebRequest cmdlet and see if I can retrieve the Azure VMs information:
```powershell
$Request = (Invoke-WebRequest -Uri 'https://yourfunctionapp.azurewebsites.net/api/GetAzureVMs?code=xyzbe8da45lqedkh2fk31m4jep61aali&subscriptionId=2699bb49-076d-4f94-987e-a6a41ef17c3f' -UseBasicParsing -Method Get).content
$Request

```
As you can see, the request body content contains a HTML output which contains a table for the Azure VM information

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-11.png" alt="image" width="701" height="140" border="0" /></a>

Now that I’ve confirmed the function is working, all I need to do is to use Power BI to get the data from the web.

<strong>Note: </strong>I’m not going to too deep in Power BI in this post, therefore I will only demonstrate how to do so in Power BI desktop. However Alex’s post has covered how to configure such reports in Power BI Online and ensuring the data is always up-to-date by leveraging the On-Prem Data Gateway component. So, please make sure you also read Alex’s post when you are done with this one.

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-12.png" alt="image" width="169" height="244" border="0" /></a>

In Power BI Desktop, simply enter the URL with the basic setting:

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-13.png" alt="image" width="411" height="148" border="0" /></a>

and choose "Table 0":

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-14.png" alt="image" width="675" height="267" border="0" /></a>

Once imported, you can see the all the properties I’ve defined in the Azure Functions PowerShell script has been imported in the dataset:

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-15.png" alt="image" width="327" height="392" border="0" /></a>

and I’ve used a table visual in the Power BI report and listed all the fields from the dataset:

<a href="http://blog.tyang.org/wp-content/uploads/2016/10/image-16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-16.png" alt="image" width="695" height="217" border="0" /></a>

Since the purpose of this post is only to demonstrate how to use Azure Functions as the data source for Power BI, I am only going to demonstrate how to get the data into Power BI. Creating fancy reports and dashbaords for Azure VM data is not what I intent to cover.

Now that the data is available in Power BI, you can be creative and design fancy reports using different Power BI visuals.

<strong>Note:</strong> The method described in this post may not work when you want to refresh your data after published your report to Power BI Online. You may need to use this C# Wrapper function: <a href="http://blog.tyang.org/2016/10/13/making-powershell-based-azure-functions-to-produce-html-outputs/">http://blog.tyang.org/2016/10/13/making-powershell-based-azure-functions-to-produce-html-outputs/</a>. Alex has got this part covered in his post.

Lastly, make sure you go check out Alex’s post on how he created the AAD Users report using this method. As I mentioned, he has also covered two important aspects – how to make this report online (so you can share with other people) and how to make sure you data is always up to date by using the on-prem data gateway.