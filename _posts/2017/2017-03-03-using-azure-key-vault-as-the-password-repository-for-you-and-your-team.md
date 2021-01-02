---
id: 5930
title: Using Azure Key Vault as the Password Repository For You and Your Team
date: 2017-03-03T19:16:36+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=5930
permalink: /2017/03/03/using-azure-key-vault-as-the-password-repository-for-you-and-your-team/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Key Vault
  - PowerShell
---
<img style="float: left; display: inline;" src="https://github.com/tyconsulting/AzureKeyVaultPasswordRepo-PSModule/raw/master/ModuleIcon.png" width="172" height="172" align="left" />

Over the past decade, I have used several password management applications such as <a href="https://pwsafe.org/">Password Safe</a>, <a href="http://keepass.info/">KeePass</a> and <a href="https://www.lastpass.com/">LastPass</a>. Out of these products, only LastPass is cloud based. I have been hesitate to use LastPass over the last few years and stayed with KeePass because of the <a href="http://www.pcworld.com/article/2936621/the-lastpass-security-breach-what-you-need-to-know-do-and-watch-out-for.html">LastPass data breach back in 2015</a>. Few months ago, my friend Alex Verkinderen finally convinced me to start using LastPass again. But this time, in order to be more secure and being able to use Multi-Factor Authentication (MFA), I have purchased a premium account and also purchased a <a href="https://www.yubico.com/products/yubikey-hardware/yubikey-neo/">YubiKey Neo</a> for MFA. I understand not everyone is willing to spend money on password repository solutions (in my case, USD $12 per year for the LastPass Premium account and USD $50 + shipping for a Yubikey Neo from Amazon). Also, based on my personal experience, there are still many organisations that don’t have a centralised password repositories. Many engineers and consultants I have met still store passwords in clear text.

On the other hand, Azure Key Vault has drawn a lot of attention since it was released and it is become really popular. I have certainly used it a lot over the last few months and managed to integrate it with many solutions that I have built.

## AzureKeyVaultPasswordRepo PowerShell Module

I spent few hours last night and today, developed a PowerShell CLI menu based app based on few existing scripts I wrote in the past. This app allows you to create, manage Azure Key Vault and use it as your personal (or team's) password repository. In order to simplify the process of deploying and using this app, I wrapped it in a PowerShell module. I named this module <strong>AzureKeyVaultPasswordRepo</strong> and it is now available on both PowerShell Gallery and GitHub:

PowerShell Gallery: <a title="https://www.powershellgallery.com/packages/AzureKeyVaultPasswordRepo/" href="https://www.powershellgallery.com/packages/AzureKeyVaultPasswordRepo/">https://www.powershellgallery.com/packages/AzureKeyVaultPasswordRepo/</a>

GitHub: <a title="https://github.com/tyconsulting/AzureKeyVaultPasswordRepo-PSModule/releases/tag/1.0.0" href="https://github.com/tyconsulting/AzureKeyVaultPasswordRepo-PSModule/releases/tag/1.0.0">https://github.com/tyconsulting/AzureKeyVaultPasswordRepo-PSModule/releases/tag/1.0.0</a>

If you are running PowerShell version 5 and later, you can install this module using an one-liner:

<em><span style="background-color: #ffff00;">Install-Module AzureKeyVaultPasswordRepo</span></em>

Once it is installed, you can launch the app either using the full name <strong>Invoke-AzureKeyVaultPasswordRepository</strong>, or use one of the 2 shorter aliases (<strong>ipr</strong> and <strong>Start-PasswordRepo</strong>).
<h4>Initial Setup</h4>
This module requires AzureRm.Profile, AzureRm.Resources and AzureRm.KeyVault modules, which you can also find from the PowerShell Gallery.

When it is launched, it will detect if you are currently Signed in to Azure and ask you if you want to keep using the same account if you are currently signed in.

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb.png" alt="image" width="628" height="98" border="0" /></a>

you have the option to keep using the current account or sign in to Azure using another account.

Then the app will prompt you to use the current Azure subscription that’s set in the context, or select another subscription from the list.

When running it for the first time, you will need to create a new Key Vault from the menu. You can choose an existing resource group, or create a new resource group in your azure region of your choice

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-1.png" alt="image" width="637" height="513" border="0" /></a>

Once the key vault is created, you will need to assign full access to an Azure AD account. This is done by searching Azure AD using a search string and select an user account from the search result list.

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-2.png" alt="image" width="613" height="88" border="0" /></a>

Once the permission is assigned, everything is ready to go. you will be presented with the main menu:

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-3.png" alt="image" width="602" height="228" border="0" /></a>

<strong><span style="color: #ff0000;">Note:</span></strong> It is by design that this app does not use any existing key vaults that you may already have in your subscription. You have to create a new one. Any existing key vaults that are not created by this app will not appear on the list for you to choose.
<h4>Creating Profile to store settings</h4>
In order to make you access this key vault as fast as possible in the future, the first thing I’d suggest you to do is to select option 4 and save the Azure subscription Id and Key Vault name in your profile. this profile is stored in Windows Registry under HKEY_CURRENT_USER\SOFTWARE\TYConsulting\AzureKeyVaultPasswordRepo\Profiles\&lt;your Azure account name&gt;.

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-4.png" alt="image" width="547" height="361" border="0" /></a>

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-5.png" alt="image" width="527" height="200" border="0" /></a>

Once the profile is saved, when you launch this app next time, it will automatically use the Azure subscription and the Key Vault that’s stored in the profile.

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/SNAGHTML6c6b2b3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML6c6b2b3" src="http://blog.tyang.org/wp-content/uploads/2017/03/SNAGHTML6c6b2b3_thumb.png" alt="SNAGHTML6c6b2b3" width="523" height="125" border="0" /></a>
<h4>Creating Credentials</h4>
From the main menu, you have the option to:

1. Create new credential (user name and password). you also have the option to generate random password by not entering a password. if you choose to use this app to generate a random password, the password will be copied to the computer’s clipboard once the credential is created (so you can use Ctrl-V to paste it to wherever you need to).

<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-6.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-6.png" alt="image" width="553" height="208" border="0" /></a>
<h4>List, Retrieve, Update and Delete Credentials</h4>
You can use Option 2 to list, retrieve, update and delete existing credentials. When option 2 is selected, the app will list all credentials stored in the key vault, and from there, you can choose the credential from the list that you are interested in. Once the credential is selected, you have the option to:
<ol>
 	<li>Copy user name to clipboard</li>
 	<li>Copy password to clipboard</li>
 	<li>Update credential (username / password)</li>
 	<li>Delete Credential</li>
</ol>
<a href="http://blog.tyang.org/wp-content/uploads/2017/03/image-7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2017/03/image_thumb-7.png" alt="image" width="640" height="431" border="0" /></a>
<h4>Search Credential</h4>
Instead of selecting a credential to manage from the list, you can also search credentials (based on credential name) using option 3.
<h4>Save / Delete Profile</h4>
As shown previously, for faster access, you can use option 4 to store the Azure subscription Id and the Key Vault Name in the registry. if you decide to delete the profile (i.e. when you decide to use another subscription or key vault), you can use option 5 to delete the existing profile from registry.
<h4>Managing Key Vault Access</h4>
You can use option 6 to grant full access to the key vault to other Azure AD accounts, or use option 7 to remove access.

## Conclusion

Personally I’m pretty happy to see what I have produced during such a short period of time (only few hours based on some existing scripts I wrote few weeks ago). I think this would fill a gap for people and organisations that do not have a commercial password management solution.

Azure Key Vault is a very in-expensive solution, and by using an Azure offering, you automatically inherit the MFA solutions that you have configured for Azure / Azure AD. i.e. I’m not using Azure AD premium for my lab but for my Microsoft (@outlook.com) account, I have enabled MFA using the Microsoft Authenticator app. Therefore in order to access the Key Vault using this module, I will need to use MFA during the sign in process.

I’ve only spent few hours on this PowerShell module, there are still room for improvement. So consider this as a MVP (Minimum Viable Products). I think the following additions would be beneficial in future releases (if I decide to have develop further):
<ul>
 	<li>A GUI interface</li>
 	<li>Support additional types of sensitive information, not just username and passwords</li>
 	<li>Support Service Principal (Azure AD Applications)</li>
 	<li>Support different levels of access (currently everyone has full access)</li>
</ul>
Lastly, please give it a try, and I’d like to hear back from the community. If you are interested to learn how to interact with Key Vault using PowerShell, feel free to read the source code of this module. if you have any questions or suggestions, please feel free to contact me!