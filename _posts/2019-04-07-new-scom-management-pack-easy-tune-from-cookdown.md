---
id: 6980
title: 'New SCOM Management Pack: Easy Tune from Cookdown'
date: 2019-04-07T14:22:26+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6980
permalink: /2019/04/07/new-scom-management-pack-easy-tune-from-cookdown/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
  - SquaredUp
---
Squared Up should not be a stranger for any seasoned SCOM administrators. For me, it is absolutely my favourite ISV when it comes to SCOM. Recently, at Experts Live USA, Squared Up has announced a new brand name called Cookdown, which is focused on extending the capabilities of SCOM (i.e. management packs development). When we firstly heard the name “Cookdown” at Experts Live USA, all the SCOM folks in the room laughed (in a good way). You must be a hardcore SCOM person to understand and appreciate the name. Originally in SCOM, the term“Cookdown” refers to a process that you can configure multiple workflows in your MP to share the same data source. It seems like the new company “Cookdown” is doing exactly that – by sharing knowledges and tools with the greater community, making SCOM more fun to work with. To me, the name “Cookdown” demonstrate the level of dedication and technical competency that this new company is committed to SCOM.

With the launch of Cookdown, an awesome management pack called <strong>Easy Tune</strong> has been made available to the general public.

When working with SCOM, one of the biggest pain is MP tuning. Generally, a MP includes tens, or even hundreds of different rules and monitors. To tune these rules and monitors can be very time consuming. Often, in order to tune the MPs, the SCOM administrators also need to read the MP documentation and work with application owners to determine exactly how the MPs need to be tuned. We often find ourselves in situation where an app owner told you “I’d like to monitor a, b, c, can we use SCOM?” and your answer would be “yes, SCOM can monitor a, b, c, and hundred different other things for your app.” Back in the days when I was working on SCOM, MP tuning must be my least favourite task. Imagine when your customer asked you for a, b and c, and you need to go disable all the rest of the rules and monitors in a MP? I’m sure this is not a task that anyone would enjoy doing!

I remember many years ago (like a decade ago), few of the then-SCOM-focused Microsoft MVPs (such as John Joyner and Cameron Fuller) was sharing tuning tips for different MPs in their SCOM Unleashed book’s blog. It was a good way to share their experiences, and certainly helped me a lot, but it’s is still a manual and time-consuming following John and Cameron’s instructions from those blog posts.

Easy Tune is a MP is intended to address this decade long problem in SCOM. It provides a console UI that allows you to select the level of tuning, then automatically creates overrides for the selected MPs. It is backed by an open-source public GitHub repo, where you can view (and even contribute) the details of each “tuning pack”. It also supports private local store if you have specific tuning requirements only relevant to your environment, if you decided not to share with the rest of the community.

<strong>SCOM console UI experience:</strong>

<a href="https://blog.tyang.org/wp-content/uploads/2019/04/image.png"><img width="840" height="408" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/04/image_thumb.png" border="0"></a>

Select tuning levels:

<a href="https://blog.tyang.org/wp-content/uploads/2019/04/image-1.png"><img width="488" height="409" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/04/image_thumb-1.png" border="0"></a>

List of overrides to be created based on the tuning level you’ve selected:

<a href="https://blog.tyang.org/wp-content/uploads/2019/04/image-2.png"><img width="738" height="542" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/04/image_thumb-2.png" border="0"></a>

This UI automatically creates overrides for the selected MP based on the tuning level you’ve selected. With few clicks, you can create hundreds of overrides within minutes!

The “tuning pack” is a simple CSV file, it' is designed to be consumed by non-SCOM people (i.e. your server admins or SQL DBAs). You can find all the built-in packs at Cookdown’s GitHub repo here: <a href="https://github.com/cookdown/easytune_overrides">https://github.com/cookdown/easytune_overrides</a>

So, how much does this MP cost? Cookdown offers a free version and a pro (paid) version All the capabilities I’ve shown in this post is free. The Pro version offers few additional capabilities such as migration tools for existing overrides, Powershell automation, configuration drift detection, etc. You can find more details, download the MP, and watch the introduction video at Cookdown’s website: <a href="http://cookdown.com/scom-essentials/easy-tune/">http://cookdown.com/scom-essentials/easy-tune/</a>

Lastly, make sure you follow Cookdown on Twitter: <a href="https://twitter.com/team_cookdown" target="_blank" rel="noopener noreferrer">@team_cookdown</a>, and register their launch webinar on 10th Apr: <a href="https://app.livestorm.co/cookdown/launch-webinar">https://app.livestorm.co/cookdown/launch-webinar</a>