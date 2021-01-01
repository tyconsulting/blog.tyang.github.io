---
id: 7478
title: Moving My Data to Azure and Office 365 Using Synology Cloud Sync
date: 2020-09-07T23:49:48+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7478
permalink: /2020/09/07/moving-my-data-to-azure-and-office-365-using-synology-cloud-sync/
spay_email:
  - ""
categories:
  - Azure
  - Others
tags:
  - Azure
  - product review
  - Synology
---
Syncing data between on-prem locations and public cloud has become a very common practice for many organisations, and sometimes even for home users. I have seen organisations using solutions from storage providers to sync data to Azure Storage Accounts and other cloud providers. Personally, in order to prevent hardware failure, and being able to access my files while I’m away from home, I’ve also been wanting to migrate some of my data from my NAS to Microsoft OneDrive and Azure Storage Accounts.

Few weeks ago, <a href="https://www.synology.com/">Synology</a> reached out to me and asked me if I’d be interested to review their free <a href="https://www.synology.com/en-global/dsm/feature/cloud_sync">Cloud Sync</a> solution with Azure Storage. Since I’ve been thinking about replacing two 6-year old NAS devices at home, and wanting to move some files to Azure and OneDrive, I have accepted the offer. Although Synology supplied me with the NAS device (<a href="https://www.synology.com/en-global/products/DS920+">DS920+</a>), this is not a sponsored post, I’m only sharing my opinion based on my own experience.

<h3>Installing Cloud Sync</h3>

Synology Cloud Sync is extremely easy to configure. Once you’ve logged in to the web portal of your Synology NAS, it can be found in the Package Center, you can install it with one click (and follow the wizard).

Once installed, we can start creating sync jobs. Cloud Sync supports many public cloud providers such as Microsoft Azure, OneDrive, OneDrive for Business, AWS S3, GCP Cloud Storage, Google Drive, Dropbox, etc. I’ll cover Azure Storage Accounts and Microsoft OneDrive (personal) in this post.

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/SNAGHTML540a34b.png"><img width="1032" height="432" title="SNAGHTML540a34b" style="display: inline; background-image: none;" alt="SNAGHTML540a34b" src="https://blog.tyang.org/wp-content/uploads/2020/09/SNAGHTML540a34b_thumb.png" border="0"></a>

<h3>Azure Storage Account</h3>

Firstly, I have created an Azure Storage Account in Australia Southeast region since it’s the closest region to my home. I connected the storage account to a VNet, and added my home broadband’s IP address to the firewall rule so the NAS device can reach it (as shown below). This restrict accessing to the storage account only from the VNet it connects to, my home IP, and other Azure services (Since I’ve ticked Allow trusted Microsoft services to access this storage account).

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image.png"><img width="497" height="325" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb.png" border="0"></a>

I then created a blob container in the storage account

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-1.png"><img width="665" height="120" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-1.png" border="0"></a>

Then on the Synology NAS web portal, I created a sync job with the following information:

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-2.png"><img width="511" height="306" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-2.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-3.png"><img width="520" height="425" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-3.png" border="0"></a>

<ul>
    <li>Service endpoint: Azure Global</li>
    <li>Storage account: &lt;my storage account name&gt;</li>
    <li>Access key: the primary or secondary key for the storage account</li>
    <li>Blob container name: &lt;my blob container name&gt;</li>
</ul>

Then I can choose the local path (a share on the NAS), and the remote path (in Azure storage blob), I can also select the sync direction. In this case, I’ve chosen bi-directional so changes from both end will be replicated to each other.

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-4.png"><img width="480" height="399" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-4.png" border="0"></a>

I can also specify a schedule, I.e. stop sync during busy hours to save network bandwidth.

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-5.png"><img width="473" height="291" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-5.png" border="0"></a>

I can still modify the settings after the jobs are created. For example, I can configure the polling interval, set network throttling, folder exclusions, file filter (based on file extensions), add/remove/modify sync folders etc.

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-6.png"><img width="559" height="363" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-6.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-7.png"><img width="565" height="376" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-7.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-8.png"><img width="385" height="409" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-8.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-9.png"><img width="397" height="421" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-9.png" border="0"></a>

Depending on the size of the folder and your Internet link speed, the initial synchronisation can take a while. Once completed, you’ll see the status as "Up to date"

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-10.png"><img width="644" height="335" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-10.png" border="0"></a>

At this stage, any changes on the NAS folder or the blob container will be replicated. I’ve done some tests (as shown below):

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-11.png"><img width="851" height="438" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-11.png" border="0"></a>

<ol>
<li>I copied a binary file (AzurePortalInstaller.exe) to the NAS folder, the synchronisation started straightaway, the file got uploaded to the Azure storage blob.</p></li>
<li><p>I deleted some files and folders from the NAS folder ("iTunes"), synchronisation started straightaway, those files and folders got deleted from the storage blob.</p></li>
<li><p>I deleted some files from the storage blob container ("Data Migration Assistant *"), it took few seconds for the NAS device to poll the changes, and the local copy was updated accordingly. – I’m guessing this is dictated by the Polling interval value you have configured earlier.</p></li>
<li><p>I created a new text file ("new Text Document.txt"), then renamed it to "test.txt", then added a line to it. each operations (new file, rename, update) triggered synchronisation instantaneously.</p></li>
</ol>

<p>5.&nbsp; On the Azure Storage Account, I modified the test.txt file using Azure Storage Explorer, and saved the change directly to the storage account. Again, within few seconds, Synology NAS detected the change and downloaded the file from the storage account.

<h3>Microsoft OneDrive (Personal)</h3>

With Microsoft OneDrive, I have 2 real use cases:

<ol>
<li>Since my old NAS devices are running out of space, I have some files that I stored on my personal OneDrive, they are not available locally at home . Although I’m happy to keep those files there, I’d like to have them stored locally at home as well. So I created a sync job to sync with a folder in my OneDrive.</p></li>
<li><p>My daughter’s iPad uploads photos to iCloud automatically and she’s getting close to the free quota. I don’t want to pay for additional storage since everyone in the family is on the Office 365 Family plan which offers 6 users 1TB of space on OneDrive. It is also easier to share them with other family members and we can access OneDrive from any devices such as PC, Mac, Android, iOS, etc. (unlike Apple iCloud). So I manually downloaded those photos from iCloud to a NAS folder, I want to automatically upload them to her OneDrive, so that she can still access those photos via the OneDrive app on her iPad if she needs to.</p></li>
</ol>

<p>Setting up sync jobs for OneDrive is super easier. All you need is to sign in to your Microsoft Account when prompted, and give user consent:

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-12.png"><img width="388" height="405" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-12.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image50.png"><img width="333" height="559" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image50_thumb.png" border="0"></a>

You will be prompted to be redirected to the Synology NAS web portal (a typical oAuth workflow):

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-13.png"><img width="346" height="199" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-13.png" border="0"></a>

All the other settings are the same as the Azure Storage, you can choose sync direction, scheduling settings, pulling interval, network bandwidth throttling, etc.

For the OneDrive connection, I performed similar sets of tests that I previously performed for the Storage Account, the behaviour is very similar – locally initiated changes trigger synchronisation which gets replicated to OneDrive as soon as the changes are made. However, changes on the OneDrive don’t seem to get replicated to the local folder as quickly as when syncing with Azure Storage Account. the default polling interval for OneDrive is 600 seconds (every 10 minutes), I tried to decrease it to 15 seconds, but it doesn’t seem like Cloud Sync is polling OneDrive every 15 seconds as configured. the files did appear on the NAS share after around 10 minutes though. This is not a big deal, I can live with it.

<h3>Conclusion</h3>

Overall, I’m pretty happy with the feature Cloud Sync offers.

For Microsoft OneDrive, although the polling interval is a little bit too long in my opinion, it is perfect for what I need to achieve. Moving forward, I can definitely see myself setting up more and more folders to sync, store a local copy of my OneDrive folders on the NAS so I don’t have to keep cleaning up spaces from the SSDs on my PCs because once you’ve accessed a file via OneDrive client, the file gets downloaded and stored on your PC permanently.

With Azure Storage Accounts, in my opinion since Synology NAS devices are generally used by home users and small to medium businesses, it offers a very cost effective way to migrate / synchronize files to cloud platforms. The configuration is pretty easy and the synchronization is pretty effective based on my testing. However, for large enterprises, I believe it’s missing some features:

<ol>
    <li>It only supports 2 Azure environments: Azure Global and Azure China. It doesn’t support other environments such as Azure Germany, Azure Government.</li>
</ol>

<a href="https://blog.tyang.org/wp-content/uploads/2020/09/image-14.png"><img width="666" height="167" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2020/09/image_thumb-14.png" border="0"></a>

<ol>
    <li>It does not support Azure Files, only blob storage. This limit prevents people who need to access the fires on the Storage Accounts via SMB.</li>
    <li>To sync to Azure Storage Account, it uses Storage Account access keys. Some organisations prohibits users from using access keys. It would be good if we can use an Azure AD Service Principals that have sufficient <a href="https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad-rbac-portal">RBAC permissions</a> to access the storage account.</li>
</ol>

The documentation for the Synology Cloud Sync can be found here: <a href="https://www.synology.com/en-global/knowledgebase/DSM/help/CloudSync/cloudsync">https://www.synology.com/en-global/knowledgebase/DSM/help/CloudSync/cloudsync</a>.

Lastly, I’d like to thank Synology for offering me this great devices to work with. I’ve already loaded it with 4x12GB HDDs and I’m currently in the process of migrating my files to and from other NAS devices and various cloud storage.