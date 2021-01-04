---
id: 2598
title: Using Computers And Health Service Watchers Groups in a Management Group containing Clusters
date: 2014-04-23T00:50:37+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2598
permalink: /2014/04/23/using-computers-health-service-watchers-groups-management-group-containing-clusters/
categories:
  - SCOM
tags:
  - SCOM
---
It’s very common for OpsMgr administrators to create instance groups contain windows computer objects and the health service watcher objects for these computers so these groups can be used in alert subscriptions for different support teams. There are many articles out there explaining how to create these groups such as:

<a title="http://www.scom2k7.com/dynamic-computer-groups-that-send-heartbeat-alerts/" href="http://www.scom2k7.com/dynamic-computer-groups-that-send-heartbeat-alerts/">http://www.scom2k7.com/dynamic-computer-groups-that-send-heartbeat-alerts/</a>

<a title="http://blogs.technet.com/b/kevinholman/archive/2014/04/09/creating-groups-of-health-service-watcher-objects-based-on-other-groups.aspx" href="http://blogs.technet.com/b/kevinholman/archive/2014/04/09/creating-groups-of-health-service-watcher-objects-based-on-other-groups.aspx">http://blogs.technet.com/b/kevinholman/archive/2014/04/09/creating-groups-of-health-service-watcher-objects-based-on-other-groups.aspx</a>

Please keep in mind, if there are clusters monitored in your environment, and you’d like to include cluster alerts in the subscriptions you’ve setup, these groups do not contain windows clusters so subscriptions will not process some of the cluster alerts. I noticed it last week when I was configuring Alert Update Connectors using such groups, some of the cluster alerts are not processed such as this one:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/ClusterAlert.png"><img style="display: inline; border: 0px;" title="Cluster Alert" src="http://blog.tyang.org/wp-content/uploads/2014/04/ClusterAlert_thumb.png" alt="Cluster Alert" width="580" height="167" border="0" /></a>

This is because clusters are actually groups.

Class Definition in Windows Cluster Management MP:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image31.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb31.png" alt="image" width="580" height="158" border="0" /></a>

In Operations console:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image32.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb32.png" alt="image" width="580" height="386" border="0" /></a>

As you can see each discovered Windows cluster is a group, and it contains all cluster resources:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML66a977a.png"><img style="display: inline; border: 0px;" title="SNAGHTML66a977a" src="http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML66a977a_thumb.png" alt="SNAGHTML66a977a" width="580" height="294" border="0" /></a>

So in order for the "Computer and Health Service Watcher" instance groups to include clusters, the GroupPopulator in the group discovery data source needs to be updated to include an additional <MemberShipRule> segment. in the example below, I’ve created a group that contains all computers with the NetBIOS name starts with the letter "S", associated health service watcher objects, and all clusters with the name starts with letter "S" as well:

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image33.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb33.png" alt="image" width="580" height="570" border="0" /></a>

Of course, in order to add highlighted section in the discovery, I also added the Microsoft.Windows.Cluster.Library as a reference (with alias "Cluster"):

<a href="http://blog.tyang.org/wp-content/uploads/2014/04/image34.png"><img style="display: inline; border: 0px;" title="image" src="http://blog.tyang.org/wp-content/uploads/2014/04/image_thumb34.png" alt="image" width="407" height="402" border="0" /></a>

Here’s the XML code for the group discovery if you want to copy and paste:
```xml
  <Monitoring>
    <Discoveries>
      <Discovery ID="Demo.CompAndHSW.Instance.Group.Discovery" Enabled="true" Target="Demo.CompAndHSW.Instance.Group" ConfirmDelivery="false" Remotable="true" Priority="Normal">
        <Category>Discovery</Category>
        <DiscoveryTypes />
        <DataSource ID="DS" TypeID="SC!Microsoft.SystemCenter.GroupPopulator">
          <RuleId>$MPElement$</RuleId>
          <GroupInstanceId>$MPElement[Name="Demo.CompAndHSW.Instance.Group"]$</GroupInstanceId>
          <MembershipRules>
            <MembershipRule>
              <MonitoringClass>$MPElement[Name="Windows!Microsoft.Windows.Computer"]$</MonitoringClass>
              <RelationshipClass>$MPElement[Name="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$</RelationshipClass>
              <Expression>
                <RegExExpression>
                  <ValueExpression>
                    <Property>$MPElement[Name="Windows!Microsoft.Windows.Computer"]/NetbiosComputerName$</Property>
                  </ValueExpression>
                  <Operator>MatchesRegularExpression</Operator>
                  <Pattern>^[Ss]</Pattern>
                </RegExExpression>
              </Expression>
            </MembershipRule>
            <MembershipRule>
              <MonitoringClass>$MPElement[Name="SC!Microsoft.SystemCenter.HealthServiceWatcher"]$</MonitoringClass>
              <RelationshipClass>$MPElement[Name="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$</RelationshipClass>
              <Expression>
                <Contains>
                  <MonitoringClass>$MPElement[Name="SC!Microsoft.SystemCenter.HealthService"]$</MonitoringClass>
                  <Expression>
                    <Contained>
                      <MonitoringClass>$MPElement[Name="Windows!Microsoft.Windows.Computer"]$</MonitoringClass>
                      <Expression>
                        <Contained>
                          <MonitoringClass>$Target/Id$</MonitoringClass>
                        </Contained>
                      </Expression>
                    </Contained>
                  </Expression>
                </Contains>
              </Expression>
            </MembershipRule>
            <MembershipRule>
              <MonitoringClass>$MPElement[Name="Cluster!Microsoft.Windows.Cluster"]$</MonitoringClass>
              <RelationshipClass>$MPElement[Name="MSIL!Microsoft.SystemCenter.InstanceGroupContainsEntities"]$</RelationshipClass>
              <Expression>
                <RegExExpression>
                  <ValueExpression>
                    <Property>$MPElement[Name="Cluster!Microsoft.Windows.Cluster"]/Name$</Property>
                  </ValueExpression>
                  <Operator>MatchesRegularExpression</Operator>
                  <Pattern>^[Ss]</Pattern>
                </RegExExpression>
              </Expression>
            </MembershipRule>
          </MembershipRules>
        </DataSource>
      </Discovery>
    </Discoveries>
  </Monitoring>
```
Once the additional <MembershipRule> segement is added to the GroupPopulator module, all windows clusters will be shown as child groups for both my custom defined group and the "Windows Clusters" group:

![](http://blog.tyang.org/wp-content/uploads/2014/04/SNAGHTML67d6784.png)

Lastly, if you are updating a existing group, don’t forget to change the display name to something like "Computers, Clusters and Health Service Watchers Group" :smiley: