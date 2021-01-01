---
id: 618
title: 'SCCM Package stuck at &ldquo;Install Pending&rdquo; state'
date: 2011-08-03T10:02:10+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=618
permalink: /2011/08/03/sccm-package-stuck-at-install-pending-state/
categories:
  - SCCM
tags:
  - Package Distribution
  - SCCM
---
Last week, someone power cycled one of our secondary site server (also a DP) via the remote management card without shutting down the OS first. At that time, a software update deployment package (total size of 13MB) was being pushed to this site. As result, this particular update package got stuck at "Install Pending" even few days after the reboot.

I noticed below error was logged in <strong>distmgr.log</strong> every few minutes:

<strong>Cannot update the package server &lt;site server NAL path&gt; for package &lt;package ID&gt;, error = 8</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb.png" alt="image" width="580" height="196" border="0" /></a>

No other errors were found in despool.log or sender.log. I have tried refreshing DP, manually copying the .PCK and .PKG files from parent primary site, update DPs, restarting SMS Site Component service, taking the DP out from the package and put it back in after a weekend, none of them fixed the problem.

In the end, I have taken a more brutal method to fix the problem:

1. remove the DP from the package and wait couple of hours

2. make sure the package distribution is not at "Install Pending" state

3. manually deleted the following files from secondary site server:

<a href="http://blog.tyang.org/wp-content/uploads/2011/08/image1.png"><img style="border: 0px currentColor; padding-top: 0px; padding-right: 0px; padding-left: 0px; display: inline; background-image: none;" title="image" src="http://blog.tyang.org/wp-content/uploads/2011/08/image_thumb1.png" alt="image" width="626" height="142" border="0" /></a>

4.  deleted from PkgStatus table from both central and parent primary site (this is a 3-tier environment): <strong>DELETE FROM PkgStatus WHERE ID=’&lt;Package ID&gt;’ AND SiteCode = ‘&lt;Secondary site code&gt;’</strong>

5. Verify PkgServer table, make sure there are no entries for this package on this particular site: <strong>SELECT * FROM PkgServer WHERE PkgID=’&lt;Package ID&gt;’ AND SiteCode=’&lt;Secondary site code&gt;’</strong>, delete if it exists.

6. Wait couple of hours, then add the DP to the package again.

Within few minutes, this software update deployment package was successfully installed on this server.

<strong><span style="color: #ff0000;">Please Note: Manually editing the database is not supported by Microsoft. Please use this method with caution. I am not accountable for any damages you’ve done to your SCCM database.</span></strong>