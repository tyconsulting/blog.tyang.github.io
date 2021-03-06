---
id: 6158
title: Free PowerShell OpsMgr Management Pack from Squared Up
date: 2017-07-19T16:06:58+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=6158
permalink: /2017/07/19/free-powershell-opsmgr-management-pack-from-squared-up/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
Squared Up is releasing a new free management pack that provides several PowerShell related templates that allows SCOM administrators to create the following workflows:

| Name                                          | Type       | Description                                                                        |
| --------------------------------------------- | ---------- | ---------------------------------------------------------------------------------- |
| Run a PowerShell Script                       | Diagnostic | Runs a script as a diagnostic, returning text                                      |
| PowerShell Script Three State Monitor         | Monitor    | Runs a script and reports Healthy, Warning, or Critical based on the script output |
| PowerShell Script Two State Monitor           | Monitor    | Runs a script and reports Healthy or Warning/Critical based on the script output   |
| Run a PowerShell Script                       | Recovery   | Runs a script as a recovery, returning text                                        |
| PowerShell Script Alert Generating Rule       | Rule       | Raises Alerts if the output of a PowerShell script matches a specified criteria    |
| PowerShell Script Event Collection Rule       | Rule       | Collects events created and submitted by a PowerShell script                       |
| Run a PowerShell Script on an event           | Rule       | Runs a PowerShell script if a specified event is detected                          |
| PowerShell Script Performance Collection Rule | Rule       | Collects performance metrics created and submitted by a PowerShell script          |
| Run a PowerShell Script                       | Rule       | Runs a PowerShell script on a routine interval                                     |
| Run a PowerShell script                       | Task       | Runs a simple script as an agent task, returning text                              |

To install the PowerShell Monitoring MP you will need:

 * SCOM 2012 R2 or later (earlier versions may be supported but are untested)
 * SCOM Admin rights (only administrators can import management packs)
 * SCOM authoring rights provided to any user who needs to create PowerShell-based workflows


## Install the SCOM Management Pack

Import the management pack into SCOM using the standard process.

The MP will show up as ```PowerShell Monitoring - Community Management Pack```.

## Using the MP

The MPs add various templates to the appropriate Create... wizards in the <em>Authoring</em> tab of the SCOM console.

i.e.

**Unit Monitors:**

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-5.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-5.png" alt="image" width="717" height="676" border="0" /></a>

**Rules:**

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-6.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-6.png" alt="image" width="716" height="885" border="0" /></a>

**Diagnostic Task:**

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-7.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-7.png" alt="image" width="720" height="618" border="0" /></a>

**Recovery Task:**

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-8.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-8.png" alt="image" width="710" height="611" border="0" /></a>

**Agent Task:**

<a href="https://blog.tyang.org/wp-content/uploads/2017/07/image-9.png"><img style="display: inline; background-image: none;" title="image" src="https://blog.tyang.org/wp-content/uploads/2017/07/image_thumb-9.png" alt="image" width="704" height="607" border="0" /></a>

Squared Up told me that:
>Each template allows you to specify a script and dynamically insert arguments based on the workflow target. Each template includes a sample script that already has the necessary boilerplate to work with the SCOM API, so no prior knowledge is necessary. However, scripts <u>will not</u> be checked for correctness by the template, so please ensure you have thoroughly tested them prior to using the templates.

Arguments are passed to the script as a single string, so if you need to pass multiple arguments you should use the ```String``` ```.Split``` method with an appropriate separator to convert **```$Arguments```** into an array. Remember that you can also insert values from the Targeted class anywhere into the script (i.e. into unique variables in the script body) so the main purpose of injecting values via arguments is for overrides (since the Arguments value is overridable in all templates).

The Monitor, Alert Rule, Performance Collection, and Event collection rules all have samples already configured in the UI that, whilst not useful in production, do illustrate how the workflow works and provide enough boilerplate to get started.

They are also looking for your help:

### How can you help?

**Bugs** – if you find any, please let us know asap!

**1. Feature Requests** – if you have any requests for additional functionality you think others would find valuable, please do let us know. We can’t promise to incorporate these into the initial or indeed any future release, but we’ll certainly take the suggestions onboard and look to incorporate them if possible / appropriate.  Of course, the MP will shortly be available, open source on GitHub, so at that point you’ll be able to make any personal modifications to it that way, should you prefer.

**2. Sample scripts** - if you’re interested in sharing a script that you think would be broadly applicable and useful, please let us know and we’ll happily share that with the wider community, either directly in the release webinar, via a link to a blog or repo of yours and / or in GitHub when we release the MP to the community.

**3. Anecdotes** – if you’re not able to share scripts but do have a great use case(s) you’d like to share to help inspire others as to what they can achieve with the MP, please let us know and we’ll share that with the community

**4. Encourage your colleagues** – as a SCOM guru, hopefully you’ve already been able to achieve a lot of what <i>you</i> want to with SCOM via Management Packs but we believe the beauty of this MP is opening up the power of SCOM to those without such specialist knowledge. So, if you’ve got non-SCOM colleagues who you know have a locker full of handy PowerShell scripts, why not show them how those can now be leveraged via SCOM and encourage them to share too

**5. Publicise the MP** – we hope you’ll lend you voice to helping the community know all about the free MP via our <a href="https://squaredup.com/free-powershell-management-pack/?utm_source=blogger&utm_medium=public-relations&utm_campaign=powershell">release webinar on 19 July</a>

The webinars are scheduled today, within few hours time. If you are interested in learning more about the MP, please register using the this link: <a href="https://squaredup.com/free-powershell-management-pack/?utm_source=blogger&utm_medium=public-relations&utm_campaign=powershell">Registeration Page</a>.