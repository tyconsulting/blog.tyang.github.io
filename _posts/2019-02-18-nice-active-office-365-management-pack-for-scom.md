---
id: 6934
title: NiCE Active Office 365 Management Pack for SCOM
date: 2019-02-18T16:19:55+10:00
author: Tao Yang
layout: post
guid: https://blog.tyang.org/?p=6934
permalink: /2019/02/18/nice-active-office-365-management-pack-for-scom/
categories:
  - SCOM
tags:
  - Management Pack
  - Office 365
---
If you are monitoring your Office 365 services in SCOM, you probably already know how bad the Microsoft Office 365 MP is. In my opinion, it is one of the worst written SCOM MP from Microsoft. That’s why there are many 3rd party or community solutions for monitoring O365 in SCOM.

Recently, my favourite SCOM management pack ISV NiCE (<a title="https://www.nice.de" href="https://www.nice.de">https://www.nice.de</a>) has released a MP for monitoring various Office 365 components. The NiCE Active O365 MP monitors Office 365 services using synthetic transactions by simulating activities such as user login, sending test emails etc. In my opinion, this is a very clever way to tackle the monitoring requirements of a SaaS product, since customers do not have access to the logs and metrics of backend platforms. This MP provides insights into the service availability and performance from end user’s perspective.

The current version of the MP supports monitoring of the following O365 components:

<ul>
    <li>Exchange Online</li>
    <li>Hybrid Exchange environments</li>
    <li>SharePoint Online</li>
    <li>OneDrive</li>
</ul>

It monitors the availability and performance of above mentioned components and the MP supports monitoring of multiple tenants.

<a href="https://blog.tyang.org/wp-content/uploads/2019/02/image.png"><img width="1002" height="502" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/02/image_thumb.png" border="0"></a>

Squared Up dashboard views:

<a href="https://blog.tyang.org/wp-content/uploads/2019/02/image-1.png"><img width="1002" height="628" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/02/image_thumb-1.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2019/02/image-2.png"><img width="1002" height="487" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/02/image_thumb-2.png" border="0"></a>

<a href="https://blog.tyang.org/wp-content/uploads/2019/02/image-3.png"><img width="1002" height="499" title="image" style="display: inline; background-image: none;" alt="image" src="https://blog.tyang.org/wp-content/uploads/2019/02/image_thumb-3.png" border="0"></a>

You can find more details of this MP at NiCE’s website: <a title="https://www.nice.de/nice-active-o365-mp/" href="https://www.nice.de/nice-active-o365-mp/">https://www.nice.de/nice-active-o365-mp/</a>. Christian Heitkamp from NiCE recently has also demonstrated this MP at a Squared Up webinar. you can find the recording on YouTube: <a title="https://www.youtube.com/watch?v=z6xySpvqdFE" href="https://www.youtube.com/watch?v=z6xySpvqdFE">https://www.youtube.com/watch?v=z6xySpvqdFE</a>