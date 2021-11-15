---
id: 2138
title: Adding Images to OpsMgr 2012 Management Packs in VSAE
date: 2013-09-03T22:41:17+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=2138
permalink: /2013/09/03/adding-images-opsmgr-2012-management-pack-vsae/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
While I was working on the recently published ConfigMgr 2012 Client MP in VSAE, I needed to add few images as icons for the ConfigMgr 2012 Client class that I defined. I couldn’t find any articles on the net explaining how to do so in VSAE for OpsMgr MP’s. Instead, I found [this article](http://marcelzehner.ch/2013/01/04/visual-studio-authoring-extensions-vsae-part-2-creating-a-folder-with-a-custom-image) on how to do it for a Service Manager MP.

It wasn’t too hard to figure out how to do this for OpsMgr MPs, all I had to do is to look at the Microsoft.SystemCenter.Library in VSAE. It turned out adding images for classes in OpsMgr 2012 Mps is a bit different than Service Manager MPs. Since I couldn’t find any blog articles on how to do this for OpsMgr MP’s, I’m documenting this process in this blog, it is also a note for myself as future references. Below is what I had to do:

1. Adding the big (80x80) and small (16x16) images to the MP as Embedded Resource

![](https://blog.tyang.org/wp-content/uploads/2013/09/image.png)

{:start="2"}
2. Add the below XML code into a MP fragment file (IDs and file names needs to be updated accordingly):

```xml
<Categories>
  <Category ID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon.Category" Target="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon" Value="System!System.Internal.ManagementPack.Images.DiagramIcon" />
  <Category ID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon.Category" Target="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon" Value="System!System.Internal.ManagementPack.Images.u16x16Icon" />
</Categories>
<Presentation>
  <ImageReferences>
    <ImageReference ElementID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application" ImageID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon"/>
    <ImageReference ElementID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application" ImageID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon"/>
  </ImageReferences>
</Presentation>
<Resources>
  <Image ID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Diagram.Icon" FileName="CMClientx80.png" Accessibility="Public" HasNullStream="false" Comment="ConfigMgr 2012 Client Icon Diagram" />
  <Image ID="ConfigMgr.2012.Client.Library.ConfigMgr.2012.Client.Application.Small.Icon" FileName="CMClientx16.png" Accessibility="Public" HasNullStream="false" Comment="ConfigMgr 2012 Client Icon Small" />
</Resources>
```

![](https://blog.tyang.org/wp-content/uploads/2013/09/image1.png)

So the difference between the OpsMgr MP and the Service Manager MP is that in OpsMgr MP, there’s an additional section <Categories> that defines the linkages between image references and the image resources.

>**Note:** Because the images are added as embedded resources, when importing the MP into OpsMgr, **you have to use the Management Pack Bundle (.mpb) file** instead of .mp file.

The finishing piece in OpsMgr operational console looks like below:

**16x16 Icon:**

![](https://blog.tyang.org/wp-content/uploads/2013/09/image2.png)

**80x80 Diagram:**

![](https://blog.tyang.org/wp-content/uploads/2013/09/image3.png)