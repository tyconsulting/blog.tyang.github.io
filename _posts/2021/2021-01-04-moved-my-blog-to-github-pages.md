---
title: Moved My Blog to GitHub Pages
date: 2021-01-04 15:00
author: Tao Yang
permalink: /2021/01/04/moved-my-blog-to-github-pages/
summary: 
categories:
  - Others
tags:
  - Blog Site
  - GitHub Pages
---

You might wonder why does my blog look different now. This is because I have just moved it from a self-hosted WordPress site to GitHub Pages (running Jekyll). This is somethings I've been wanting to do for couple of of years.

I had 3 WordPress sites hosted with a hosting company over in California. I attempted to get move all of them to GitHub Pages over the last 2 Christmas / New Year holiday period but never managed to find enough time to complete it. 

This years is a little bit different, since we are all staying home due to the COVID pandemic, I have more time I can spent on this. I have to say, it's not an easy task to move those 3 sites, each of them had different kinds of problems. Now, after 7 days of solid work, I managed to move them all to GitHub Pages - this site is the last one I moved since it's the biggest.

So why did I move away from WordPress? I think I can summerise into the following reasons:

**1. Cost**

I have been paying USD $250 a year to the hosting company for the 3 sites I have (my blog, my company's site and my wife's blog). These sites are sharing the resources allocated to my account. In addition to to the hosting cost, there are also potential costs for:

* SSL Certificates
* Various WordPress Plugins and Themes
* Other WordPress services (i.e. site backup)

Hosting on GitHub Pages is free, and GitHub also generates SSL certificates for your sites free of charge.

**2. Security**

Keeping WordPress sites secure is not an easy task. I constant need to respond to attacks from the Internet (i.e. brutal force attack, SQL Injection, etc.). I had several security related plugins installed on my sites and my blog still have been hacked for few times over the past.

i.e. I took this screenshot before I shutdown the old WordPress site for my blog:

![](../../../../assets/images/2021/01/image1.png)

My site is constantly under attack and I'm sick of it!

and when I was examining the last scheduled backup of the WP site, I found a suspecious file somehow placed on my site that I wasn't even aware. When I opened it, it contains a list of usernames and passwords for Netflix. I have no idea how this got onto my blog site, I don't recall seeing any alerts from all those plugins I installed.

![](../../../../assets/images/2021/01/image2.png)

With GitHub, I can control who can contribute to the repository used by my blog site, and I have enabled MFA for my account. In order to sign in, I need to either use the authenticator app on my phone or my [Yubikey](https://www.yubico.com/). I can also stop direct commit into the master branch, and enforce PR and code review.

**3. Site Availability and SLA**

the JetPack for WordPress would notify you when your site gets offline. I constantly get these type of alerts. And every now and then, the hoster have very long outages. i.e. This is from today:

![](../../../../assets/images/2021/01/image3.png)

I'm sick of all the downtime from the hoster, not to mention they never offered me any compensation for all the outages. GitHub would provide a far better SLA and far less outages than my hoster for sure!

**4. Admin Effort**

With WordPress, in addition to all the security threats that I constantly need to respond to, I also need to keep the WordPress, Plugins, Themes and PHP versions are up-to-date. and deal with the Plugin compatibility issues after each update. I have been doing since I started blogging back in 2010. I HATE IT!!!

**5. Authoring Experience**

I have been using the Windows Live Writer (and Open Live Writer over the last few years). It provdes a similar user experience just like MS Word. If I get to choose, I definitely prefer writing Markdown in VSCode instead. I have written enough Markdown that I am really comfortable wit it.

Lastly, now that this site has been migrated to GitHub Pages, if you see any formatting issues or broken links, please let me know and I'll try to fix it as soon as I can.