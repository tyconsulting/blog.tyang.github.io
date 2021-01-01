---
id: 2025
title: Creating a VBScript file Within a VSAE Project
date: 2013-07-12T23:34:48+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2025
permalink: /2013/07/12/creating-a-vbscript-file-within-a-vsae-project/
categories:
  - SCOM
tags:
  - MP Authoring
  - SCOM
---
Not sure if this issue has been blogged before. Yesterday, while I was working on a management pack project, I noticed that if I created a new VBScript file within VSAE (In Visual Studio), the script will not run when I test it in command prompt.

To replicate this issue again, I firstly created a brand new VBScript file inside the project:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image9.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb9.png" width="527" height="298" border="0" /></a>

Then added one line to the script and saved it:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb10.png" width="535" height="296" border="0" /></a>

Now, when tried to run it via the command prompt, I got a error saying there’s an invalid character at position (1,1) – which is the beginning of the script:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb11.png" width="580" height="136" border="0" /></a>

This error normally means the encoding for the .vbs file is not set as ANSI, which is exactly the problem in this case. When I opened the VBScript using NotePad++, looks like the script is encoded in UTF-8

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb12.png" width="559" height="291" border="0" /></a>

To fix this issue, I simply changed the encoding to ANSI and saved the VBScript

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb13.png" width="544" height="267" border="0" /></a>

Now it runs perfectly:

<a href="http://blog.tyang.org/wp-content/uploads/2013/07/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2013/07/image_thumb14.png" width="580" height="102" border="0" /></a>

However, once the VBScript gets updated and saved again within Visual Studio, the encoding will revert back to UTF-8.

I don’t think this issue impacts the finishing piece of the management pack, but will impact developers when testing the script while still writing the MP. The alternative is to create the blank file outside of the Visual Studio and import it in by adding an existing item. I noticed if the file was initially created outside of Visual Studio and later got updated in Visual Studio, the encoding remains as ANSI.

Because of this reason, from now on, I’ll always create the VBScript file outside of Visual Studio when using VSAE.