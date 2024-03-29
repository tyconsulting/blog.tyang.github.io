---
id: 4322
title: Spend Your Money Wisely
date: 2015-08-07T22:48:04+10:00
author: Tao Yang
#layout: post
excerpt: ""
header:
  overlay_image: /wp-content/uploads/2015/08/spending.jpg
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
guid: https://blog.tyang.org/?p=4322
permalink: /2015/08/07/spend-your-money-wisely/
categories:
  - Others
tags:
  - Others
---
As what I’d like to consider myself as – a seasoned System Center specialist, I have benefitted from many awesome resources from the community during my career in System Center. These resources consist of blogs, whitepapers, training videos, management packs and various tools and utilities. Although some of them are not free (and in my opinion, they are not free for a good reason), but large percentage of these resources I value the most are all free of charge.

This is what I like the most about the System Center community. Over the last few years, I got to know many unselfish people and organisations in the System Center space, who have made their valuable work completely free and open source for the broader community. Due to what I am going to talk about in this post, I am not going to mention any names in this post (unless I absolutely have to) . But if anyone is interested t know my opinion, I’m happy to write a separate post introducing what I believe are valuable resources.

First of all, I’m just going to put it out there, I am not upset, and this is not going to be a rant and I’m trying to stay positive.

I started working on System Center around 2007-2008 (ConfigMgr and OpsMgr at that time) . I started working on OpsMgr because my then colleague and now fellow SCCDM MVP (like I mentioned, not going to mention names) has left the company we were working for and I had to pick up the MOM 2005 to OpsMgr 2007 project he left behind. The very first task for me was to figure out a way to pass the server’s NetBIOS name to the help desk ticketing system and I managed to achieve this by creating a PowerShell script and utilised the command notification channel to execute the script when alerts were raised. I then used the same concept and developed a PowerShell script to be used in the command notification to send content rich notification emails which covered many information not available from native email notification channel.

When I started blogging 5 years ago, this script was one of the very first posts I published here. I named this solution [Enhanced SCOM Alert Notification Emails](https://blog.tyang.org/2010/07/19/enhanced-scom-alerts-notification-emails). Since it was published, it has received many positive feedbacks and recommendations. I have since published the updated version (2.0) here:

[https://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/](https://blog.tyang.org/2012/08/16/scom-enhanced-email-notification-script-version-2/)

After version 2.0 was published, a fellow member in the System Center community, Mr. Tyson Paul has contacted me, told me he has updated my script. I was really happy to see my work got carried on by other members in the community and since then, Tyson has already made several updates to this script and published it on his blog (for free of course):

Version 2.1: [http://blogs.msdn.com/b/tysonpaul/archive/2014/08/04/scom-enhanced-email-notification-script-version-2-1.aspx](http://blogs.msdn.com/b/tysonpaul/archive/2014/08/04/scom-enhanced-email-notification-script-version-2-1.aspx)

Version 2.2: [http://blogs.msdn.com/b/tysonpaul/archive/2015/01/30/scom-enhanced-email-notification-script-version-2-2.aspx](http://blogs.msdn.com/b/tysonpaul/archive/2015/01/30/scom-enhanced-email-notification-script-version-2-2.aspx)

This morning, I have received an email from a person I have never heard of. This person told me his organisation has developed a commercial solution called "Enhanced Notification Service for SCOM" and I can request a NFR by filling out a form from his website. As the name suggests (and I had a look on the website), it does exactly what mine and Tyson’s script does – sending HTML based notification emails which include content rich information including associated knowledge articles.

Well, to be fair, on their website, they did mention a limitation of running command notifications that you have a AsyncProcessLimit of 5. But, there is a way to increase this limit and if your environment is still hitting the limit after you’ve increased it, I believe you have a more serious issue to fix (i.e. alert storm) rather than enjoying reading those "sexy" notification emails. Anyways, I don’t want to get into technical argument here, it’s not the intention of this post.

So, do I think someone took my idea and work from Tyson and myself? It is pretty obvious, make your own judgement. Am I upset? not really. If I want to make a profit from this solution, I wouldn’t have published out on my blog in the first place. And believe me, there are many solutions and proof-of-concepts I have developed in the past that I sincerely hope some software vendors can pickup and develop a commercial solution for the community – simply I don’t have the time and resources to do all these by myself (i.e. my recently published post on managing ConfigMgr log files using OMS would be a good commercial solution).
In the past, I have also seen people took scripts I published on my blog, replaced my name with theirs from the comment section and published it on social media without mentioning me whatsoever. I knew it was my script because other comments in the script are identical to my initial version. When I saw it, I have decided not to let these kind behaviour get under my skin, and I believe the best way to handle it is to let it go. So, I am not upset when I read this email today. Instead, I laughed! Hey, if this organisation can make people to pay $2 per OpsMgr agent per year (which means for a fully loaded OpsMgr management group would cost $30k per year for "sexy" notification emails), all I’m going to say is:

![](https://blog.tyang.org/wp-content/uploads/2015/08/good-for-you.jpg)

However, I do want to advise the broader System Center community: **Please spend your money wisely!**

There is only so much honey in the pot. You all have a budget. This is what the economist would call [Opportunity Cost](https://en.wikipedia.org/wiki/Opportunity_cost). If you have a certain needs or requirement and you can satisfy your requirement using free solutions, you can spend your budget on something that has a higher Price-Performance Ratio. If you think there’s a gap between the free and paid solution, please ask your self these questions:

* Are these gaps really cost me this much?
* Are there any ways to overcome this gap?
* Have I reached out the the SMEs and confirm if this is a reasonable price?
* How much would it cost me if I develop an in-house solution?

Lastly, I receive many emails from people in the community asking me for advise, and providing feedback to the tools I have published. I am trying my best to make sure I answer all the emails (and apologies if I have missed). So if you have any doubts in the future that you’d like to know my opinion, please feel free to contact me. And I am certain, not only myself, but other SMEs and activists in the System Center community would also love to help a fellow community member.