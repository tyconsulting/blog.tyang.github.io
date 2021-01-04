---
id: 7081
title: 'New Azure Policy Definition: Deploy VM Shutdown Schedule'
date: 2019-06-02T17:36:29+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7081
permalink: /2019/06/02/new-azure-policy-definition-deploy-vm-shutdown-schedule/
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
I wrote an Azure Policy definition few days ago, it deploys VM shutdown schedule together with VMs using <strong>deployIfNotExists</strong> effect. You can find it at my Azure Policy GitHub repo: <a href="https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/deploy-vm-shutdown-schedule">https://github.com/tyconsulting/azurepolicy/tree/master/policy-definitions/deploy-vm-shutdown-schedule</a>. This policy will be very useful when managing non-production workload.

Input parameters:

<a href="https://blog.tyang.org/wp-content/uploads/2019/06/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/06/image_thumb.png" alt="image" width="451" height="532" border="0" /></a>

Deployed schedule:

<a href="https://blog.tyang.org/wp-content/uploads/2019/06/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2019/06/image_thumb-1.png" alt="image" width="478" height="396" border="0" /></a>