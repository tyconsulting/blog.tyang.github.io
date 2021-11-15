---
id: 1197
title: My Observation on SCCM Clients BITS Settings
date: 2012-05-05T00:41:49+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=1197
permalink: /2012/05/05/my-observation-on-sccm-clients-bits-settings/
categories:
  - SCCM
  - Windows
tags:
  - BITS
  - GPO
  - SCCM
---
Yesterday, while we were reviewing the SCCM (2007 R3) client BITS settings at work, we (my team) have some interesting findings with SCCM client’s BITS settings.

We found when the BITS bandwidth throttling settings are configured for a SCCM primary site. SCCM clients get the policy and write the settings into Windows local policy:

<strong>SCCM Computer Client Agent BITS Settings:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2012/05/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/05/image_thumb.png" alt="image" width="367" height="463" border="0" /></a>

<strong>BITS Settings from SCCM Client’s Windows local policy (</strong>Local Policy –&gt;Computer Configuration –&gt;Administrative Templates –&gt;Network –&gt;Background Intelligent Transfer Service (BITS) –&gt;Limit the maximum network bandwidth for BITS background transfers<strong>):</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2012/05/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2012/05/image_thumb1.png" alt="image" width="580" height="448" border="0" /></a>

As you can see, the SCCM site setting is identical to SCCM client’s local policy. SCCM 2007 Unleashed has explained the client BITS settings. You can read about it on Google Books <a href="http://books.google.com.au/books?id=dYYKG44dGHQC&pg=PT414&dq=sccm+client+BITS+setting&hl=en&sa=X&ei=qd-jT8_ZCq7vmAWG0qWbCQ&ved=0CDkQ6AEwAA#v=onepage&q&f=false">HERE</a>.

The book did not state and explain the SCCM client actually WRITES the SCCM site’s BITS policy into SCCM client’s Windows local group policy object (GPO). So I did below tests <strong>IN ORDER</strong> in my home <strong>SCCM 2007 R3 AND SCCM 2012</strong> RTM test environments to work out the behaviours of SCCM client and compare SCCM Client’s BITS setting against the above mentioned setting in local policy:

<strong>1. SCCM Client BITS setting left as default in SCCM (Not configured).</strong>
<ul>
	<li>SCCM 2007 Client Computers: BITS policy in local GPO is set to <strong>DISABLED</strong>!</li>
	<li>SCCM 2012 Client Computers: Same as SCCM 2007 client computers</li>
</ul>
<strong>2. Enable BITS in SCCM Computer Client Agent setting (In 2007, apply to both clients and BDPs, in 2012, just enable it since there is no BDPs in 2012 anymore.), and define some throttling settings. Then trigger machine policy retrieval on SCCM client computers.</strong>
<ul>
	<li>SCCM 2007 Client Computers: BITS policy in local GPO is ENABLED in throttling settings are set to as same as SCCM policy.</li>
	<li>SCCM 2012 Client Computers: Same as SCCM 2007 client computers</li>
</ul>
<strong>3. Change BITS throttling settings in SCCM. Then trigger machine policy retrieval on SCCM client computers</strong>
<ul>
<ul>
	<li>SCCM 2007 Client Computers: BITS policy in local GPO updated accordingly.</li>
	<li>SCCM 2012 Client Computers: Same as SCCM 2007 client computers</li>
</ul>
</ul>
<strong>4. Change BITS throttling settings in SCCM client’s Windows local policy. Then trigger machine policy retrieval on SCCM client computers.</strong>
<ul>
<ul>
	<li>SCCM 2007 Client Computers: local policy remained the same after machine policy retrieval.</li>
	<li>SCCM 2012 Client Computers: Same as SCCM 2007 client computers</li>
</ul>
</ul>
<strong>5. Change BITS throttling settings in SCCM again. Then trigger machine policy retrieval on SCCM client computers.</strong>
<ul>
	<li>SCCM 2007 Client Computers: local policy was updated again according to SCCM client’s BITS policy.</li>
	<li>SCCM 2012 Client Computers: Same as SCCM 2007 client computers</li>
</ul>
<strong>Conclusions:</strong>

Based on the tests I have performed. I have come to below conclusions:
<ol>
	<li>When the SCCM client’s BITS policy is not configured, the  BITS throttling settings OS local policy is set to <strong>DISABLED</strong>, so effectively no BITS throttling is allowed for <strong>ALL</strong> the apps that uses BITS on the SCCM client computer. (i.e. in our case, VMM agent)</li>
	<li>Upon SCCM policy change, SCCM client changes local policy with updated settings once it has retrieved the updated policy via SCCM client’s machine policy retrieval (by default runs every 60 minutes).</li>
	<li>The SCCM client’s BITS settings are NOT enforced in local policy. i.e. when local policy is manually updated to be different than SCCM client’s policy, SCCM client does not enforce and update local policy. SCCM clients ONLY write to local policy when the SCCM BITS policy is CHANGED on the primary site.</li>
	<li>SCCM 2007 clients and SCCM 2012 clients exhibit same behaviour.</li>
</ol>
So, please look out if you have other apps that uses BITS and the bandwidth is throttled. SCCM client would update the local policy without you knowing it.

Alternatively, using a domain GPO to set BITS throttling settings seems like a good idea. By doing so, you can target different SCCM clients more granularly (targeting different OUs, using WMI filters and AD groups to set GPO scopes) whereas in SCCM 2007, this setting is unique across all clients in the primary site. Additionally, domain GPO will override local policy so local policy can be ignored.<!--EndFragment-->