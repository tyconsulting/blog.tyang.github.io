---
id: 3755
title: My Experience of Using Silect MP Studio During Management Pack Update Process
date: 2015-02-25T21:33:32+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=3755
permalink: /2015/02/25/my-experience-of-using-silect-mp-studio-during-management-pack-update-process/
categories:
  - SCOM
tags:
  - Management Pack
  - SCOM
---
Thanks to Silect’s generosity, I have been given a NFR (Not For Resell) license for the MP Studio to be used in my lab last November. When I received the license, I created a VM and installed it in my lab straightaway.  However, due to my workloads and other commitments, I haven’t been able to spend too much time exploring this product. In the mean time, I’ve been trying to get all the past and current MS management packs ready so I can load them into MP Studio to build my repository.

Today, one of my colleagues came to me seeking help on an error logged in the Operations Manager log on all our DPM 2012 R2 servers (where SQL is locally installed):

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image10.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb10.png" alt="image" width="506" height="355" border="0" /></a>

It’s obvious the offending script(GetSQL2012SPNState.vbs) is from the SQL 2012 MP, and we can tell the error is that the computer FQDN where WMI is trying to connect to is incorrect. In the pixelated area, the FQDN contains the NetBIOS computer name plus **2** domain names from the same forest.

I knew the SQL MP in our production environment is 2 version behind (Currently on version 6.4.1.0), so I wanted to find out if the latest one (6.5.4.0) has fixed this issue.

Therefore, as I always do, I firstly went through the change logs in the MP guide. The only thing I can find that might be related to SPN monitoring is this line:

<span style="text-decoration: underline;">SPN monitor now has overridable ‘search scope’ which allows the end user to choose between LDAP and Global Catalog</span>

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image11.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb11.png" alt="image" width="454" height="184" border="0" /></a>

I’m not really sure if the new MP is going to fix the issue, and no, I don’t have time to unseal and read the raw XML code to figure it out because this version of the SQL 2012 monitoring MP has 49,723 lines of code!

At this stage, I thought MP Studio might be able to help (by comparing 2 MPs). So I remoted back to my home lab and quickly loaded all versions of SQL MP that I have into MP Studio.

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/SNAGHTML10c3cde7.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="SNAGHTML10c3cde7" src="https://blog.tyang.org/wp-content/uploads/2015/02/SNAGHTML10c3cde7_thumb.png" alt="SNAGHTML10c3cde7" width="269" height="266" border="0" /></a>

I then chose to compare version 6.5.4.0 (the latest version) with version 6.4.1.0 (the version loaded in my production environment):

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image12.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; margin: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb12.png" alt="image" width="244" height="148" border="0" /></a>

It took MP Studio few seconds to generate the comparison result, and I was surprised how many items have been updated!

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image13.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb13.png" alt="image" width="684" height="421" border="0" /></a>

Unfortunately, there is no search function in the comparison result window, but fortunately, I am able to export the result to Excel. When I exported to Excel, there are 655 rows! when I searched the script name mentioned in the Error log (GetSQL2012SPNState.vbs), I found the script was actually updated:

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image14.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb14.png" alt="image" width="686" height="209" border="0" /></a>

Because the script is too long and it’s truncated in the Excel spreadsheet, I had to go back to MP Studio and find this entry (luckily entries are sorted alphabetically).

Once the change is located, I can copy both parent value and the child value into clipboard:

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image15.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb15.png" alt="image" width="694" height="84" border="0" /></a>

I pasted the value into Notepad++, as it contains some XML headers / footers and both versions of script, I removed headers and footers, and separated the scripts into 2 files.

Lastly, I used the Compare Plugin from NotePad++ to compare the differences in both scripts, and I found an additional section in the new MP (6.5.4.0) may be related to the error that we are getting (as it has something to do with generating the domain FQDN):

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image16.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb16.png" alt="image" width="700" height="277" border="0" /></a>

After seeing this, I took an educated guess that this could be the fix to our issue and asked my colleague to load MP version 6.5.4.0 into our Test management group to see if it fixes the issue. When we went to load the MP, we found out that I have already loaded it in Test (I’ve been extremely busy lately and I forgot I did it!). So my colleague checked couple of DPM servers in our test environment and confirmed the error does not exist in Test. It seems we have nailed this issue.

## Conclusion

Updating management packs has always been a challenging task (for everyone I believe). In my opinion, we are all facing challenges because not knowing EXACTLY what has been changed. This is because:

* It is impossible to read and compare each MP files (i.e. the SQL 2012 Monitoring MP has around 50,000 lines of code, then plus the 2008 and 2005 MP, plus the library MP, etc.), they are just too big to read!
* MP Guide normally only provides a vague description in the change log (if the are change logs after all).
* Any bugs caused by the human error would not be captured in the change logs.
* Sometimes it is harder to test a MP in test environment because test environments normally don’t have the same load as production, therefore it is harder to test some workflows (i.e. performance monitors).

And we normally rely on the following sources to make our judgement:

* The MP Guide. – Only if the changes are captured in the guide, and they are normally very vague.
* Social media (tweets and blogs) – but this is only based on the blog author’s experience, the bug you have experienced may not been seen in other people’s environment (i.e. this particular error I mentioned in this post probably won’t happen in my lab because I only have a single domain in the forest).

Normally, you’d wait someone else to be the guinea pig, test it out and let you know if there are any issues before you start updating your environment (i.e. the recent <a href="https://nocentdocent.wordpress.com/2015/01/13/scom-os-mp-6-0-7294-0-serious-flaw/">bug in Server OS MP 6.0.7294.0 was firstly identified by SCCDM MVP Daniele Grandini</a> and it was soon been removed from the download site by microsoft).

In MP Studio, the feature that I wanted to explore the most is the MP compare function. It really provides OpsMgr administrators a detailed view on what has been changed in the MP and you (as OpsMgr admin) can use this information to make better decisions (i.e. whether to upgrade or not? are there any additional overrides required?). Based on today’s experience, if I start timing before I loaded the MPs into the repository, it probably took me less than 15 minutes to identify this MP update is something very worth trying (in order to fix my production issue).

Lastly, There are many other features MP Studio provides, I have only spent a little bit time on it today (and the result is positive). In my opinion, sometimes, the best way to describe something is to use an example, thus I’m sharing today’s experience with you. I hope you’ve found it informative and useful.

P.S. Coming back to the bug in the Server OS MP 6.0.7294 that I have mentioned above, I ran a comparison between 6.0.7294 and previous version 6.0.7292, I can see a lot of perf collection rules have been changed:

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image17.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb17.png" alt="image" width="609" height="433" border="0" /></a>

and if I export the result in Excel, I can actually see the issue described by Daniele (highlighted in yellow):

<a href="https://blog.tyang.org/wp-content/uploads/2015/02/image18.png"><img style="background-image: none; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border: 0px;" title="image" src="https://blog.tyang.org/wp-content/uploads/2015/02/image_thumb18.png" alt="image" width="598" height="316" border="0" /></a>

Oh, one last word before I call it the day, to Silect – would it be possible to provide search function in the comparison result window (so I don’t have to rely on Excel export)?