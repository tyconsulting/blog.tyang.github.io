---
id: 6144
title: 'Azure Functions Demo: Voting App'
date: 2017-07-16T15:17:28+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6144
permalink: /2017/07/16/azure-functions-demo-voting-app/
categories:
  - Azure
tags:
  - Azure
  - Azure Functions
  - Azure Key Vault
  - Azure SQL DB
  - Power BI
---
Back in April this year, Pete Zerger (<a href="https://twitter.com/pzerger">@pzerger</a>) and I delivered two sessions in Experts Live Australia. One of which is titled "Cloud Automation Overview". During this session, we have showed off a pretty cool voting demo app that is made up with Azure Functions, Key Vault, Azure SQL DB and Power BI.

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/architecture.png"><img style="display: inline; background-image: none;" title="architecture" src="https://blog.tyang.org/wp-content/uploads/2017/07/architecture_thumb.png" alt="architecture" width="862" height="487" border="0" /></a>

As shown above, this demo app allows attendees in our session to vote on a topic that we have chosen by scanning QR codes using mobile devices. In this case, since we were delivering the session in Melbourne Australia, we have decided to let people to vote how much they like the Australia iconic food Vegemite.

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb.png" alt="image" width="869" height="491" border="0" /></a>

The vote result can be viewed via a Power BI report:

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-1.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-1.png" alt="image" width="888" height="509" border="0" /></a>

This demo was well received during our session, and Pete has used it again with our fellow CDM MVP Lee Berg (<a href="https://twitter.com/LeeAlanBerg">@LeeAlanBerg</a>) during one of their sessions in MMS in May.

A week ago I saw the Azure Functions product group is building a central hub for demos and they are looking for examples. So I reached out to them and offered the voting app demo.<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-2.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-2.png" alt="image" width="516" height="307" border="0" /></a>

They asked me to put everything in a public GitHub repository and also include the deployment instruction. So I spent whole day yesterday, put everything together in a public GitHub repo, and also automated the entire deployment process using PowerShell and ARM template.

Regardless if this demo app is going to make to the Azure Functions gallery or not, I think it’s a pretty cool solution and I’ve decided to publicize it here.  So here’s the Repo:

<a title="https://github.com/tyconsulting/AzureFunctionVotingAppDemo" href="https://github.com/tyconsulting/AzureFunctionVotingAppDemo"><span style="font-size: large;"><strong>https://github.com/tyconsulting/AzureFunctionVotingAppDemo</strong></span></a>

You will find all the deployment artefacts in this demo, as well as a detailed instruction in README.md. The QR codes and sample Power BI report are all actively running in my Azure and O365 subscription. Feel free to try it out!

<del>If this has made to the PG’s gallery, I’ll update this post and include the gallery link later.</del>

Here's the PG's samples gallery wiki page: <a href="https://github.com/Azure/Azure-Functions/wiki/Samples-and-content">https://github.com/Azure/Azure-Functions/wiki/Samples-and-content</a>.

When we were preparing our Experts Live sessions back in March / April this year, since Pete loves Vegemite so much and he’s even got his name printed on the jars, we have decided to use Vegemite as our voting topic:

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-3.png"><img style="margin: 0px; display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-3.png" alt="image" width="244" height="226" border="0" /></a>

Last Christmas, my wife and I found a "Happy Little Vegemite" (a famous Aussie kids song: <a title="https://www.youtube.com/watch?v=0yA98MujNeM" href="https://www.youtube.com/watch?v=0yA98MujNeM">https://www.youtube.com/watch?v=0yA98MujNeM</a>) top in the Australian pyjamas brand Peter Alexander shop and I bought one for myself.

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-4.png"><img style="margin: 0px; display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-4.png" alt="image" width="190" height="244" border="0" /></a>

Before our presentation, we were talking about wearing this top during our session but we couldn’t find one for Pete in the shops – we were told it was a Christmas special edition. The day before our session, my wife managed to find a brand new one on eBay, that is Pete’s size and was located in Melbourne. So she bought it and drove all the way to the seller’s location and picked it up for Pete while we were in the conference delivering the other session. As the result, next day, both Pete and I delivered our Automation session wearing PJs. I don’t know about Pete, but this is certainly my first time (wearing PJ on stage):

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/VegemitePJ.jpg"><img style="display: inline; background-image: none;" title="VegemitePJ" src="https://blog.tyang.org/wp-content/uploads/2017/07/VegemitePJ_thumb.jpg" alt="VegemitePJ" width="962" height="723" border="0" /></a>

<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>