---
id: 2000
title: Creating a VSAE Project (Solution) Including Multiple Management Packs
date: 2013-07-03T16:41:55+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2000
permalink: /2013/07/03/creating-a-vsae-project-solution-including-multiple-management-packs/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
When writing management packs for an application / system, it is very common to have multiple management packs included in the end monitoring solution. i.e. a library MP, a discovery MP, a monitoring MP, etc.

Back in the old days when using the OpsMgr 2007 R2 Authoring console, these separate management packs need to be created separately. If one of these MPs (i.e. the library MP) is referenced in other MPs (i.e. discovery MP and monitoring MP), the referenced MP (i.e. the library MP) needs to be developed and sealed prior to making the references in the referencing MPs (i.e. discovery and monitoring MPs). further more, when the referenced MP gets updated with additional classes or modules, the minimum version number for this reference on the referencing MPs needs to be manually updated and the sealed updated referenced MP needs to be copied to a reference search location that has been defined in the Authoring Console so the referencing MPs can find it.

As you can see, there are a lot of manually steps involved when working on multiple management packs simultaneously, not to mention MP authors will almost always have multiple instances of Authoring Consoles opened, – one instance for each MP.

Now, with VSAE, when developing a rather complex MP project that involves multiple MPs, it is almost a no brainer, none of above mentioned manual steps is required anymore.

Firstly, when start authoring the management packs, MP authors can create a Visual Studio solution which contains multiple projects (each project represents a management pack). To do so, instead of using the Management Pack project templates, a blank Visual Studio Solution needs to be created first.

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb.png" width="453" height="337" border="0" /></a>

Once the solution is created, each management pack project can be created individually by going to <strong>File—&gt;Add—&gt;New Project…</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image1.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb1.png" width="347" height="256" border="0" /></a>

And choose the appropriate management pack project template

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image2.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb2.png" width="471" height="271" border="0" /></a>

Once all management pack projects are created, all of them will show up in the Solutions Explorer and Management Pack Browser within Visual Studio

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image3.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb3.png" width="580" height="357" border="0" /></a>

I can now reference the library MP in the Discovery and Monitoring MP. – without having to firstly write and seal the library MP first. To do so, simply add a reference in the referencing MP:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image4.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb4.png" width="244" height="232" border="0" /></a>

Instead of referencing an existing management pack, the reference can be another project:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image5.png"><img style="background-image: none; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb5.png" width="366" height="309" border="0" /></a>

Whenever the version of the library MP is increased, the reference in the referencing MPs are automatically updated:

i.e. when the library MP is on version 0.0.0.1, the reference property is as below:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image6.png"><img style="background-image: none; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb6.png" width="244" height="176" border="0" /></a>

When the library MP version gets updated to 0.0.0.2, the reference is automatically updated in the referencing MPs:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image7.png"><img style="padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb7.png" width="244" height="172" border="0" /></a>

When building the solution in Visual Studio, it will build all the MPs included in the solution, in the appropriate order. Unlike back in the old days, the library MPs will need to be built and sealed prior to other MPs. This is not required anymore.

In conclusion, VSAE provides a single console for MP developers to build multiple MPs as a single solution, and it manages the relationships between these MPs automatically. It ensures the latest version of the referenced MPs are always being used in referencing MPs.