---
id: 6646
title: Azure Policy to Restrict Storage Account Firewall Rules
date: 2018-09-21T00:32:53+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6646
permalink: /2018/09/21/azure-policy-to-restrict-storage-account-firewall-rules/
categories:
  - Azure
tags:
  - Azure
  - Azure Resource Policy
---
Back in the Jan 2018, I posted a custom Azure Policy definition that restricts the creation of public-facing storage account – in another word, if the storage account you are creating is not attached to a virtual network Service Endpoint, the policy engine will block the creation of this storage account. You can find the original post here: <a title="https://blog.tyang.org/2018/01/08/restricting-public-facing-azure-storage-accounts-using-azure-resource-policy/" href="https://blog.tyang.org/2018/01/08/restricting-public-facing-azure-storage-accounts-using-azure-resource-policy/">https://blog.tyang.org/2018/01/08/restricting-public-facing-azure-storage-accounts-using-azure-resource-policy/</a>.

When a storage account is connected to a Service Endpoint, you can also white-list one or more IP address ranges to allow them accessing the storage account from the outside of your Azure virtual network (i.e. the Internet). Therefore, in order to totally lock down your storage accounts, not only you need to apply policy to enforce they must be connected to your virtual networks, you also need to make sure only the IP ranges you have allowed can be added to the storage account firewall rules:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-35.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-35.png" alt="image" width="580" height="414" border="0" /></a>

When I wrote the original post, I couldn’t get the firewall rules configured or restricted via Azure Policy. Few months ago, I got in touch with the Azure governance product group seeking for advice. after some discussion, the PG pointed me the right direction. I had a requirement to implement this for a customer but then the requirement changed, it was no longer needed. I had some time yesterday and today so I revisited this policy definition. After few hours tweaking the definition sent to me from the PG, I managed to come up with a definition that restrict only certain IP ranges can be added to a storage account.

Together with the original policy to restrict public facing storage accounts, using these 2 policies, you can enforce that:

1. The storage account MUST be connected to a virtual network (so it is no longer publicly accessible).
2. Only a list of approved IP address ranges (individual addresses or CIDR ranges) can be white-listed.

I have added both policy definitions into my Azure Policy GitHub repo:

* Restrict public storage accounts: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-storageAccount" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-storageAccount">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-public-storageAccount</a>
* Restrict storage account firewall rules: <a title="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-storageAccount-firewall-rules" href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-storageAccount-firewall-rules">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/restrict-storageAccount-firewall-rules</a>

You can simplify your effort by creating a Policy Initiative and include both policies. I created an initiative, and I must supply the list of allowed IP ranges during assignment (each item is separated by ";", keep in mind do not have spaces after semicolons).

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-36.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-36.png" alt="image" width="586" height="628" border="0" /></a>

After the initiative has been assigned, I can no longer add any IP address ranges that are not listed in the initiative assignment:

<a href="https://blog.tyang.org/wp-content/uploads/2018/09/image-37.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2018/09/image_thumb-37.png" alt="image" width="774" height="575" border="0" /></a>

By using these 2 policies, you should be able to configure your storage accounts to only open to trusted network segments (i.e. your on-prem VLANs, or if you don’t have Site-to-Site VPN or ExpressRoute, your on-prem proxy servers).