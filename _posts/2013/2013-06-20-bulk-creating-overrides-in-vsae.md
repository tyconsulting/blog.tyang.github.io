---
id: 1978
title: Bulk Creating Overrides in VSAE
date: 2013-06-20T12:07:19+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=1978
permalink: /2013/06/20/bulk-creating-overrides-in-vsae/
categories:
  - SCOM
tags:
  - MP Authoring
  - VSAE
---
At work, in one of the OpsMgr 2007 management groups, we have 3 sets of Australian state / territory based computer groups. Let’s say they are App-A, App-B, and All computers groups. so each state has 3 computer groups (i.e. NSW App-A, NSW App-B and NSW All Computers).

By default, for computer groups, the Health Rollup Policies for the Health Rollup dependency monitors are configured to use the worst state of any member:

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb2.png" width="407" height="407" border="0" /></a>

Yesterday, there was a requirement to change the health rollup policies for these groups from the "Worst state of any member" to a percentage value of 95% (option 2 from above figure). To do so, the "Percentage" and the "Rollup Algorithm" properties for the monitor needs to be modified via overrides.

Therefore, I will need to create 2 overrides for each monitor:

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb3.png" width="474" height="167" border="0" /></a>

Each group has 4 health rollup dependency monitors (Availability, Configuration, Performance and Security). there are 3 sets of groups (App-A, App-B and All computers), each set contains 7 states. so the total number of overrides that I need to configure is 3(sets) x 7(states) x 4(monitors) x 2(overrides) = 168. And this is because Australia only has 7 states (excluding ACT), imaging if it’s USA, which has 50 states…

I couldn’t imaging doing this in the operational console or the good old Authoring console. VSAE has become a life saver this time. All I had to do was to create a snippet template for each set of group (this is because these overrides are going to different management packs, otherwise, I can just use one snippet template).

The snippet template contains 2 overrides and the optional language pack display strings for each override. It looks something like this:

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image4.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb4.png" width="580" height="258" border="0" /></a>

Because the ID for these groups follows a naming convention, the only differences in the ID is the Australian state abbreviation and the monitor name (Availability, Configuration, Performance and Security), the snippet contains these 2 variables.

Once the snippet template is created, I then created a snippet selected the previously created snippet template as the type

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb5.png" width="496" height="254" border="0" /></a><a href="http://blog.tyang.org/wp-content/uploads/2013/06/image6.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb6.png" width="399" height="384" border="0" /></a>

I then created a very simple CSV file, which contains the state – monitor match:

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image7.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb7.png" width="159" height="414" border="0" /></a>

In the snippet, I chose to import from CSV file

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image8.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb8.png" width="563" height="146" border="0" /></a>

and imported the CSV file I’ve created.

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image9.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb9.png" width="580" height="306" border="0" /></a>

because first line of the CSV is the title, I had to remove it from the snippet once it’s imported it.

Once I saved the snippet, all overrides and associated display string in the language pack is created:

<a href="http://blog.tyang.org/wp-content/uploads/2013/06/image10.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/06/image_thumb10.png" width="580" height="237" border="0" /></a>

I had to repeat this process 3 times because I have 3 sets of groups and the overrides for each set of groups need to be stored in different management packs. It only took me 15-20 minutes and all 168 overrides are created!

Below is the content of the snippet template:

```xml
<ManagementPackFragment SchemaVersion="1.0">
  <Monitoring>
    <Overrides>
      <MonitorPropertyOverride ID="Demo.Server.Override.All.Server.Computer.Group.#text('State')#.#text('Monitor')#.Dependency.Monitor.Health.Algorithm.Override" Context="ServerLib!Demo.Server.Library.All.Server.#text('State')#.Computer.Group" Enforced="false" Monitor="SC!Microsoft.SystemCenter.ComputerGroup.#text('Monitor')#Rollup" Property="Algorithm">
      <Value>Percentage</Value>
      </MonitorPropertyOverride>
      <MonitorPropertyOverride ID="Demo.Server.Override.All.Server.Computer.Group.#text('State')#.#text('Monitor')#.Dependency.Monitor.Health.Percentage.Override" Context="ServerLib!Demo.Server.Library.All.Server.#text('State')#.Computer.Group" Enforced="false" Monitor="SC!Microsoft.SystemCenter.ComputerGroup.#text('Monitor')#Rollup" Property="AlgorithmPercentage">
      <Value>95</Value>
      </MonitorPropertyOverride>
    </Overrides>
  </Monitoring>
  <LanguagePacks>
    <LanguagePack ID="ENU" IsDefault="true">
      <DisplayStrings>
        <DisplayString ElementID="Demo.Server.Override.All.Server.Computer.Group.#text('State')#.#text('Monitor')#.Dependency.Monitor.Health.Algorithm.Override">
          <Name>All Server Computer #text('State')# Group #text('Monitor')# Dependency Monitor Health Algorithm Override</Name>
        </DisplayString>
        <DisplayString ElementID="Demo.Server.Override.All.Server.Computer.Group.#text('State')#.#text('Monitor')#.Dependency.Monitor.Health.Percentage.Override">
          <Name>All Server Computer #text('State')# Group #text('Monitor')# Dependency Monitor Health Percentage Override</Name>
        </DisplayString>
      </DisplayStrings>
    </LanguagePack>
  </LanguagePacks>
</ManagementPackFragment>
```