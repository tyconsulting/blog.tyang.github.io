---
id: 7264
title: Managing Azure Resource Tags using Azure Policy Modify Effect
date: 2020-03-09T18:09:32+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=7264
permalink: /2020/03/09/managing-azure-resource-tags-using-azure-policy-modify-effect/
spay_email:
  - ""
categories:
  - Azure
tags:
  - Azure
  - Azure Policy
---
The new Modify effect for Azure Policy was introduced few months ago. I was really excited about this new addition, but unfortunately I haven’t had time to write this post until today.

The Modify effect is designed <strong><u>SPECIFICALLY</u></strong> for managing resource tags. You can use it to add / update / remove tags during resource creation or update (basically for both new and existing resources).

<strong>Problem we had…</strong>

Before the Modify effect was introduced, we were managing the tags using the “Deny” and “Append” effects:

<ul>
    <li>Deny:
<ul>
    <li>“Require tag and its value” policy</li>
    <li>“Require tag and its value on resource groups” policy</li>
</ul>
</li>
    <li>Append:
<ul>
    <li>“Append tag and its default value” policy</li>
    <li>“Append tag and its default value to resource groups” policy</li>
</ul>
</li>
</ul>

These policies allows you to set and enforce tag names and value on both resources and resource groups. What I did was adding above listed 4 policies into an initiative for each of the mandatory tags. For example, if 5 mandatory tags are required, I would have add these 4 policies 5 times into a single initiative. It worked well in a green field scenario (for new resources and resource groups).

However, when the initiative is assigned to an existing target with conflicting tag values, it will be shown as non-compliant. In this case, to remediate the non-compliant policies, I will need to write a script to update the tag values for these resources in bulk. If I don’t resolve these non-compliant policies, any updates to the resources will be blocked by the policy assignment.

For example, if the “require tag and its value” policy is shown as non-compliant to a key vault. I can’t even grant people access to the key vault (by modify the Key Vault access policies) until the non-compliant policies are fixed. This has been a massive headache for people. For example, you have a tag for recording the owner’s email for resource and resource groups. when the person changes roles within the organization, we often have to change the value of the “owner” tag. to do so, we had to use the following steps to update the tag value:

<ol>
    <li>Delete the initiative assignment</li>
    <li>Use a script to update the owner tag value for all resources and resource groups</li>
    <li>Create initiative assignment with updated tag value.</li>
</ol>

<strong>What about now?</strong>

Now, with the Modify effect, life becomes so much easier. instead of using 4 policies for each required tag, we only need 2:

<ul>
    <li>Add a tag to a resource</li>
    <li>Add a tag to a resource group</li>
</ul>

These 2 policies add the specified tag and value when any resource or resource group missing this tag is created or updated. Existing resource groups can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed.

When assigned these policies to existing resources resources, you can simply create a remediation tasks to update the tags.

When the tag values need to be changed, you can simply update the tag value in the policy or initiative assignment and then use remediation tasks to update the targeted resources.

When someone tries to manually change the tag value, since the tag value update is an update to the existing resource, the policy will modify the request and set the tag value as what’s specified in the policy assignment.

For example, in a resource group, I have a tag named “costCenter”, the value is set to “1234” by the “Add a tag to a resource group” policy:

<a href="https://blog.tyang.org/wp-content/uploads/2020/03/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/03/image_thumb.png" alt="image" width="624" height="203" border="0" /></a>

I tried to update the value to “5555”, and you can see this attempt in the Azure Activity Log:

<a href="https://blog.tyang.org/wp-content/uploads/2020/03/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/03/image_thumb-1.png" alt="image" width="555" height="339" border="0" /></a>

The tag update attempt is intercepted by the existing policy assignment, and the tag value was modified from “5555” back to the original value “1234”:

<a href="https://blog.tyang.org/wp-content/uploads/2020/03/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2020/03/image_thumb-2.png" alt="image" width="1031" height="312" border="0" /></a>

As you can see, the “Modify” effect greatly reduced the effort for managing resource tags in your Azure environment. If you are not using it yet, I strongly recommend you to give it a try.