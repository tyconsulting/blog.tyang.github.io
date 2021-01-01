---
id: 2335
title: Configuring System Center Update Publisher 2011 (SCUP) for Multiple Users
date: 2014-02-11T21:23:21+10:00
author: Tao Yang
#layout: post
guid: http://blog.tyang.org/?p=2335
permalink: /2014/02/11/configuring-system-center-update-publisher-2011-scup-multiple-users/
categories:
  - SCCM
tags:
  - SCUP
---
One thing I really don’t like about SCUP 2011 is, the settings are user specific, which means different users will have to manually configure SCUP settings on the same computer. By default, even the SCUP database is stored within the user’s profile. There are already many articles out there on how to change the SCUP database location. (i.e. <a title="http://myitforum.com/cs2/blogs/rzander/archive/2011/05/30/scup-2011-with-shared-database.aspx" href="http://myitforum.com/cs2/blogs/rzander/archive/2011/05/30/scup-2011-with-shared-database.aspx">http://myitforum.com/cs2/blogs/rzander/archive/2011/05/30/scup-2011-with-shared-database.aspx</a>)

Other than the database locations, all other settings such as WSUS connection, SCCM connection, Certificate, source location, etc. are all user based when configured within SCUP Options window:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb.png" width="413" height="410" border="0" /></a>

I figured out an very easy way to make these settings machine-based settings.

To do so,

01. Firstly configure all required settings in the options window as shown above.

02. Browse to <strong>“C:\Users\&lt;UserID&gt;\AppData\Local\Microsoft”,</strong> locate a folder with the name starts with <strong>“Scup2011.exe_StrongName”</strong>. i.e.

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image1.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb1.png" width="552" height="301" border="0" /></a>

03. Open above mentioned folder and it’s sub folder, you’ll see a “user.config” file:

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image2.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb2.png" width="500" height="159" border="0" /></a>

04. Open both the <strong>“user.config”</strong> file as mention above and <strong>“&lt;SCUP Install Dir&gt;\Scup2011.exe.config”</strong>

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image3.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb3.png" width="580" height="462" border="0" /></a>

05. For each setting in user.config file, locate the same setting in Scup2011.exe.config and copy the value to Scup2011.exe.config

<a href="http://blog.tyang.org/wp-content/uploads/2014/02/image4.png"><img style="display: inline; border: 0px;" title="image" alt="image" src="http://blog.tyang.org/wp-content/uploads/2014/02/image_thumb4.png" width="580" height="306" border="0" /></a>

06. Delete the “Scup2011.exe_StrongName_xxxxxxxxx” folder from your profile

07. Open SCUP console, make sure the options are still configured

08. Logon to the SCUP computer with another ID, open SCUP console, confirm the settings are not lost.