---
id: 2138
title: Adding Images to OpsMgr 2012 Management Packs in VSAE
date: 2013-09-03T22:41:17+10:00
author: Tao Yang
layout: post
guid: http://blog.tyang.org/?p=2138
permalink: /2013/09/03/adding-images-opsmgr-2012-management-pack-vsae/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
While I was working on the recently published ConfigMgr 2012 Client MP in VSAE, I needed to add few images as icons for the ConfigMgr 2012 Client class that I defined. I couldn’t find any articles on the net explaining how to do so in VSAE for OpsMgr MP’s. Instead, I found <a href="http://marcelzehner.ch/2013/01/04/visual-studio-authoring-extensions-vsae-part-2-creating-a-folder-with-a-custom-image/">this article</a> on how to do it for a Service Manager MP.

It wasn’t too hard to figure out how to do this for OpsMgr MPs, all I had to do is to look at the Microsoft.SystemCenter.Library in VSAE. It turned out adding images for classes in OpsMgr 2012 Mps is a bit different than Service Manager MPs. Since I couldn’t find any blog articles on how to do this for OpsMgr MP’s, I’m documenting this process in this blog, it is also a note for myself as future references. Below is what I had to do:

1. Adding the big (80x80) and small (16x16) images to the MP as Embedded Resource

<a href="http://blog.tyang.org/wp-content/uploads/2013/09/image.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/09/image_thumb.png" width="442" height="336" border="0" /></a>

2. Add the below XML code into a MP fragment file (IDs and file names needs to be updated accordingly):
[sourcecode language="XML"]
  &lt;Categories&gt;
    &lt;Category ID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon.Category&quot; Target=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon&quot; Value=&quot;System!System.Internal.ManagementPack.Images.DiagramIcon&quot; /&gt;
    &lt;Category ID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon.Category&quot; Target=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon&quot; Value=&quot;System!System.Internal.ManagementPack.Images.u16x16Icon&quot; /&gt;
  &lt;/Categories&gt;
  &lt;Presentation&gt;
    &lt;ImageReferences&gt;
      &lt;ImageReference ElementID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application&quot; ImageID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon&quot;/&gt;
      &lt;ImageReference ElementID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application&quot; ImageID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon&quot;/&gt;
    &lt;/ImageReferences&gt;
  &lt;/Presentation&gt;
  &lt;Resources&gt;
    &lt;Image ID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon&quot; FileName=&quot;CMClientx80.png&quot; Accessibility=&quot;Public&quot; HasNullStream=&quot;false&quot; Comment=&quot;ConfigMgr 2012 Client Icon Diagram&quot; /&gt;
    &lt;Image ID=&quot;ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon&quot; FileName=&quot;CMClientx16.png&quot; Accessibility=&quot;Public&quot; HasNullStream=&quot;false&quot; Comment=&quot;ConfigMgr 2012 Client Icon Small&quot; /&gt;
  &lt;/Resources&gt;
[/sourcecode]
<a href="http://blog.tyang.org/wp-content/uploads/2013/09/image1.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/09/image_thumb1.png" width="580" height="143" border="0" /></a>

So the difference between the OpsMgr MP and the Service Manager MP is that in OpsMgr MP, there’s an additional section &lt;Categories&gt; that defines the linkages between image references and the image resources.

<strong><span style="color: #ff0000;">Note:</span></strong> Because the images are added as embedded resources, when importing the MP into OpsMgr, <strong>you have to use the Management Pack Bundle (.mpb) file</strong> instead of .mp file.

The finishing piece in OpsMgr operational console looks like below:

<strong>16x16 Icon:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/09/image2.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/09/image_thumb2.png" width="440" height="364" border="0" /></a>

<strong>80x80 Diagram:</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/09/image3.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-width: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/09/image_thumb3.png" width="580" height="239" border="0" /></a>