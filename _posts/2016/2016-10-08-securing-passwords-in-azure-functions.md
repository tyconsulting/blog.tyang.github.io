---
id: 5690
title: Securing Passwords in Azure Functions
date: 2016-10-08T00:08:09+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=5690
permalink: /2016/10/08/securing-passwords-in-azure-functions/
categories:
  - Azure
  - PowerShell
tags:
  - Azure
  - Azure Functions
  - PowerShell
---
**09/10/2016 - Note: This post has been updated as per David O’Brien’s suggestion** .

As I mentioned in my last post, I have started playing with Azure Functions few weeks ago and I’ve already built few pretty cool solutions. One thing that I’ve spent a lot of time doing research on is how to secure credentials in Azure Functions.

Obviously, Azure Key Vault would be an ideal candidate for storing credentials for Azure services. If I’m using another automation product that I’m quite familiar with – Azure Automation, I’d certainly go down the Key Vault path because Since Azure Automation account already creates a Service Principal for logging into Azure and we can simply grant the Azure AD Application access to the Key Vault. However, and please do point me to the correct direction if I’m wrong, I don’t think there is an easy way to access the Key Vault from Azure Functions at this stage.

I cam across 2 feature requests on both <a href="https://github.com/Azure/azure-webjobs-sdk/issues/746">Github</a> and <a href="https://feedback.azure.com/forums/355860-azure-functions/suggestions/14634717-add-binding-to-key-vault">UserVoice</a> suggesting a way to access Key Vault from Azure Functions, so I hope this capability will be added at later stage. But for now, I’ve come up a simple way to encrypt the password in the Azure Functions code so it is not stored in clear text. I purposely want to keep the solution as simple as possible because one of the big advantage of using Azure Functions is being really quick, therefore I believe the less code I have to write the better. I’ll use a PowerShell example to explain what I have done.

I needed to write a function to retrieve Azure VMs from a subscription – and I’ll blog the complete solution next time. Sticking with the language that I know the best, I’m using PowerShell. I have already explained how to use custom PowerShell modules in my <a href="https://blog.tyang.org/2016/10/07/using-custom-powershell-modules-in-azure-functions/">last post</a>. In order to retrieve the Azure VMs information, we need two modules:

 * AzureRM.Profile
 * AzureRM.Compute

I use the method explained in the previous post and uploaded the two modules to the function folder. Obviously, I also need to use a credential to sign in to my Azure subscription before retrieving the Azure VM information.

I’m using a key (a byte array) to encrypt the password secure string.  If you are not familiar with this practice, I found a very detailed 2-part blog post on this topic, you can read them here:

<a href="http://www.adminarsenal.com/admin-arsenal-blog/secure-password-with-powershell-encrypting-credentials-part-1/">Secure Password With PowerShell: Encrypting Credentials – Part 1</a>

<a href="http://www.adminarsenal.com/admin-arsenal-blog/secure-password-with-powershell-encrypting-credentials-part-2/">Secure Password With PowerShell: Encrypting Credentials – Part 2</a>

So firstly, I’ll need to create a key and store the content to a file:

```powershell
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

Set-Content C:\Temp\PassEncryptKey.key $AESKey
```
I then uploaded the key to the Azure Functions folder – I’ve already uploaded the PowerShell modules to the "bin" folder, I created a sub-folder under "bin" called Keys:

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-8.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-8.png" alt="image" width="467" height="307" border="0" /></a>

I wrote a little PowerShell function (that runs on my PC, where a copy of the key file is stored) to encrypt the password.

PowerShell function **Get-EncryptedPassword**:

```powershell
Function Get-EncryptedPassword
{
  param (
    [Parameter(Mandatory=$true,HelpMessage='Please specify the key file path')][ValidateScript({Test-Path $_})][String]$KeyPath,
    [Parameter(Mandatory=$true,HelpMessage='Please specify password in clear text')][ValidateNotNullOrEmpty()][String]$Password
  )
  $secPw = ConvertTo-SecureString -AsPlainText $Password -Force
  $AESKey = Get-content $KeyPath
  $Encryptedpassword = $secPw | ConvertFrom-SecureString -Key $AESKey
  $Encryptedpassword
}
```
I call this function to encrypt the password and copy the encrypted string to the clipboard:

```powershell
$encryptedpass = Get-EncryptedPassword -KeyPath C:\temp\PassEncryptKey.key -Password "ClearTextPassword"
$encryptedpass | clip
```

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-9.png" alt="image" width="691" height="90" border="0" /></a>

I then created two app settings in Azure Functions Application settings:

 * AzureCredUserName
 * AzureCredPassword

The AzureCredUserName has the value of the user name of the service account and AzureCredPassword is the encrypted string that we prepared in the previous step.

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-17.png" alt="image" width="370" height="382" border="0" /></a>

<span style="text-decoration: line-through;"><span style="background-color: #ffff00;">I then paste the encrypted password string to my Azure Functions code (line 24):

The app settings are exposed to the Azure functions as environment variables, so we can reference them in the script as $env:AzureCredUserName and $env:AzureCredPassword (line 23 and 24)

<a href="https://blog.tyang.org/wp-content/uploads/2016/10/image-18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2016/10/image_thumb-18.png" alt="image" width="582" height="334" border="0" /></a>

As shown above, to decrypt the password from the encrypted string to the SecureString, the PowerShell code reads the content of the key file and use it as the key to convert the encrypted password to the SecureString (line 26-27). After the password has been converted to the SecureString, we can then create a PSCredential object and use it to login to Azure (line 28-29).

>**Note:** If you read my last post, I have explained how to use Kudu console to find the absolute path of a file, so in this case, the file path of the key file is specified on line 26.

Needless to say, the key file you’ve created must be stored securely. For example, I’m using KeePass to store my passwords, and I’m storing this file in KeePass. Do not leave it in an unsecured location (such as C:\temp as I demonstrated in this example).

Also, Since the app settings apply to all functions in your Azure Functions account, you may consider using different encryption keys in different functions if you want to limit which which function can access a particular encrypted password.

Lastly, as I stated earlier, I wanted to keep the solution as simple as possible. If you know better ways to secure passwords, please do contact me and I’d like to learn from you.