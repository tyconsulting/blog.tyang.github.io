---
id: 3665
title: Creating OpsMgr Instance Group for All Computers Running an Application and Their Health Service Watchers
date: 2015-01-18T19:09:07+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=3665
permalink: /2015/01/18/creating-opsmgr-instance-group-computers-running-application-health-service-watchers/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
OK, the title of this blog is pretty long, but please let me explain what I’m trying to do here. In OpsMgr, it’s quite common to create an instance group which contains some computer objects as well as the Health Service Watchers for these computers. This kind of groups can be used for alert subscriptions, overrides, and also maintenance mode targets.

There are many good posts around this topic, i.e.

* From Tim McFadden: <a href="http://www.scom2k7.com/dynamic-computer-groups-that-send-heartbeat-alerts/">Dynamic Computer groups that send heartbeat alerts</a>
* From Kevin Holman: <a href="http://blogs.technet.com/b/kevinholman/archive/2014/04/09/creating-groups-of-health-service-watcher-objects-based-on-other-groups.aspx">Creating Groups of Health Service Watcher Objects based on other Groups</a>

Yesterday, I needed to create several groups that contains computer and health service watcher objects for:

* All Hyper-V servers
* All SQL servers
* All Domain Controllers
* All ConfigMgr servers

Because all the existing samples I can find on the web are all based on computer names, so I thought I’ll post how I created the groups for above mentioned servers. In this post, I will not go through the step-by-step details of how to create these groups, because depending on the authoring tool that you are using the steps are totally different. But I will go through what the actual XML looks like in the management pack.

## Step 1: Create the group class

This is straightforward, because this group will not only contain computer objects, but also the health service watcher objects, we must create an instance group.

i.e. Using SQL servers as an example, the group definition looks like this:

```xml
<TypeDefinitions>
  <EntityTypes>
    <ClassTypes>
      <ClassType ID="TYANG.SQL.Server.Computer.And.Health.Service.Watcher.Group" Accessibility="Public" Abstract="false" Base="MSIL!Microsoft.SystemCenter.InstanceGroup" Hosted="false" Singleton="true" />
    </ClassTypes>
  </EntityTypes>
</TypeDefinitions>
```

>**Note:** the MP alias "MSIL" is referencing "Microsoft.SystemCenter.InstanceGroup.Library" management pack.

## Step 2: Find the Root / Seed Class from the MP for the specific application

Most likely, the application that you are working on (for instance, SQL server) is already defined and monitored by another set of management packs. Therefore, you do not have to define and discover these servers by yourself. The group discovery for the group you’ve just created need to include:

* All computers running any components of the application (in this instance, SQL Server).
* And all Health Service Watcher objects for the computers listed above.

In any decent management packs, when multiple application components are defined and discovered, most likely, the management pack author would define a root (seed) class, representing a computer that runs any application components (in this instance, we refer this as the "SQL server"). Once an instance of this seed class is discovered on a computer, there will be subsequent discoveries targeting this seed class that discovers any other application components (using SQL as example again, these components would be DB Engine, SSRS, SSAS, SSIS, etc.).

So in this step, we need to find the root / seed class for this application. Based on what I needed to do, the seed classes for the 4 applications I needed are listed below:

* SQL Server:
  * Source MP: Microsoft.SQLServer.Library
  * Class Name: Microsoft.SQLServer.ServerRole
  * Alias in my MP: SQL

* HyperV Server:
  * Source MP: Microsoft.Windows.HyperV.Library
  * Class Name: Microsoft.Windows.HyperV.ServerRole
  * Alias in my MP: HYPERV

* Domain Controller:
  * Source MP: Microsoft.Windows.Server.AD.Library
  * Class Name: .Windows.Server.AD.DomainControllerRole
  * Alias in my MP: AD

* ConfigMgr Server
  * Source MP: Microsoft.SystemCenter2012.ConfigurationManager.Library
  * Class Name: Microsoft.SystemCenter2012.ConfigurationManager.Server
  * Alias in my MP: SCCM



Tip: you can use MPViewer to easily check what classes are defined in a sealed MP. Use SQL as example again, in the Microsoft.SQLServer.Library:<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image4.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb4.png" alt="image" width="843" height="424" border="0" /></a>

You can easily identify that "SQL Role" is the seed class because it is based on Microsoft.Windows.ComputerRole and other classes use this class as the base class. You can get the actual name (not the display name) from the "Raw XML" tab.

## Step 3: Create MP References

Your MP will need to reference the instance group library, as well as the MP of which the application seed class is defined (i.e. SQL library):

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image5.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb5.png" alt="image" width="623" height="546" border="0" /></a>

## Step 4: Create the group discovery

The last component we need to create is the group discovery.The Data Source module for the group discovery is Microsoft.SystemCenter.GroupPopulator, and there will be 2 <MembershipRule> sections.i.e. For the SQL group:

<a href="http://blog.tyang.org/wp-content/uploads/2015/01/image6.png"><img class=" alignnone" style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2015/01/image_thumb6.png" alt="image" width="580" height="556" border="0" /></a>

As shown above, I’ve translated each membership rule to plain English. And the XML is listed below. If you want to reuse my code, simply change the line I highlighted in above screenshot to suit your needs.

```xml
<Monitoring>
  <Discoveries>
    <Discovery ID="TYANG.SQL.Server.Computer.And.Health.Service.Watcher.Group.Discovery" Enabled="true" Target="TYANG.SQL.Server.Computer.And.Health.Service.Watcher.Group" ConfirmDelivery="false" Remotable="true" Priority="Normal">
      <Category>Discovery&lt;/Category&gt;
      <DiscoveryTypes>
        <DiscoveryRelationship TypeID="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities" />
      </DiscoveryTypes>
      <DataSource ID="DS" TypeID="SC!Microsoft.SystemCenter.GroupPopulator">
        <RuleId>$MPElement$&lt;/RuleId&gt;
        <GroupInstanceId>$MPElement[Name="TYANG.SQL.Server.Computer.And.Health.Service.Watcher.Group"]$&lt;/GroupInstanceId&gt;
        <MembershipRules>
          <MembershipRule>
            <MonitoringClass>$MPElement[Name="Windows!Microsoft.Windows.Computer"]$&lt;/MonitoringClass&gt;
            <RelationshipClass>$MPElement[Name="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$&lt;/RelationshipClass&gt;
            <Expression>
              <Contains>
                <MonitoringClass>$MPElement[Name="SQL!Microsoft.SQLServer.ServerRole"]$&lt;/MonitoringClass&gt;
              </Contains>
            </Expression>
          </MembershipRule>
          <MembershipRule>
            <MonitoringClass>$MPElement[Name="SC!Microsoft.SystemCenter.HealthServiceWatcher"]$&lt;/MonitoringClass&gt;
            <RelationshipClass>$MPElement[Name="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$&lt;/RelationshipClass&gt;
            <Expression>
              <Contains>
                <MonitoringClass>$MPElement[Name="SC!Microsoft.SystemCenter.HealthService"]$&lt;/MonitoringClass&gt;
                <Expression>
                  <Contained>
                    <MonitoringClass>$MPElement[Name="Windows!Microsoft.Windows.Computer"]$&lt;/MonitoringClass&gt;
                    <Expression>
                      <Contained>
                        <MonitoringClass>$Target/Id$&lt;/MonitoringClass&gt;
                      </Contained>
                    </Expression>
                  </Contained>
                </Expression>
              </Contains>
            </Expression>
          </MembershipRule>
        </MembershipRules>
      </DataSource>
    </Discovery>
  </Discoveries>
</Monitoring>
```

## Result

After I imported the MP into my lab management group, all the SQL computer and Health Service Watcher objects are listed as members of this group:

![](http://blog.tyang.org/wp-content/uploads/2015/01/image7.png)