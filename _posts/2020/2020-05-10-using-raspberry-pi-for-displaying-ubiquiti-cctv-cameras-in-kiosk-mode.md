---
id: 7357
title: Using Raspberry Pi for Displaying Ubiquiti CCTV Cameras in Kiosk Mode
date: 2020-05-10T21:00:06+10:00
author: Tao Yang
#layout: post
guid: https://blog.tyang.org/?p=7357
permalink: /2020/05/10/using-raspberry-pi-for-displaying-ubiquiti-cctv-cameras-in-kiosk-mode/
spay_email:
  - ""
categories:
  - Others
tags:
  - Raspberry Pi
  - Ubiquiti
---
<!-- wp:paragraph -->
<p>I recently blogged <a href="https://blog.tyang.org/2020/03/18/my-home-office-setup/">my home office setup</a>. When we bought the house, there is a TV wall mount already installed in my office, right above where I put the elliptical:</p>
<!-- /wp:paragraph -->

<!-- wp:image -->
<figure class="wp-block-image"><img src="https://blog.tyang.org/wp-content/uploads/2020/03/IMG_20200318_182538.jpg" alt=""/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Unfortunately, I couldn’t use it because the previous owner didn’t leave the mounting VASE plate with us. I wanted to put a spare monitor there and use it to view the live footage of my Ubuiqiti Unifi CCTV cameras. after several failed attempts in finding the compatible VASE plate, I finally managed to find one on Amazon, so I mounted a spare 24 inch monitor onto the wall mount.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I have done some research previously, it doesn’t look like Ubiquiti have any apps for their cameras for Apple TV or Roku devices. So I have decided to use Raspberry Pi since I have a spare Raspberry Pi 3 at home. I managed to wired everything up, and placed the Raspberry Pi securely using cable ties:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"linkDestination":"custom"} -->
<figure class="wp-block-image"><a href="https://blog.tyang.org/wp-content/uploads/2020/05/image.png"><img src="https://blog.tyang.org/wp-content/uploads/2020/05/image_thumb.png" alt="image"/></a></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>I have 6 Unifi cameras connected to the Unifi NVR device. Although Ubiquiti has announced that their new app Unifi Protect will be made available for the NVR a long time ago, I still haven’t seen it yet, so I’m still using Unifi Video (which is the predecessor for Unifi Protect). So my goal was to setup Raspberry Pi to automatically enter the kiosk mode and connect to Unifi Video’s web portal when it boots up.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I faced several challenges:</p>
<!-- /wp:paragraph -->

<!-- wp:list {"ordered":true} -->
<ol><li>The Unifi Video web portal is using self-signed cert, so I get a SSL error when opening it on a web browser</li><li>There is no way to bypass the sign-in page for Unifi Video</li><li>There is no way to enter full screen in Unifi Video via URL, I can only enter full-screen mode by clicking the Full screen button on the portal.</li><li>The Chronium version that comes with Raspbian is too old but there is no update available (known issue), so I’d get a prompt to update Chronium on the screen.</li></ol>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>I managed to overcome these challenges by using few unsupported flags when starting Chronium, and using xdotool to simulate key strokes.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>To configure the Raspberry Pi after installing the latest Raspbian, I’ve carried out the following steps:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1. Use raspbian-config to set host name and enabled ssh</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>2. Update</strong></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>3. install required apps</strong></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">sudo apt -y install xrdp xdotool unclutter sed rpi-chromium-mods
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>4. Create shell script (~/chromium-signin.sh) to sigin to Unifi Video web portal (and enter full screen mode)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">nano ~/chromium-signin.sh
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>and enter the following (you will need to update the Unifi Video user name and password):</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">#!/bin/bash
sleep 20
xdotool type &lt;unifi video user id&gt;
xdotool key Tab
xdotool type &lt;enter password here&gt;
xdotool key Return
sleep 10
xdotool key Tab
xdotool key Return

```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>Make the script executable:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>chomod –x ~/chromium-signin.sh</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>5. Configure Auto Start</strong></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>and enter the following (you will need to update the Unifi Video URL):</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@xset s off
@xset -dpms
@xset s noblank
@chromium-browser --noerrdialogs --ignore-certificate-errors&nbsp; --disable-infobars --kiosk&nbsp; https://&lt;nvr url&gt;:7443/live-view
@/home/pi/chromium-signin.sh

```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>6. Disable Chromium update check</strong></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">sudo nano /etc/chromium-browser/customizations/01-disable-update-check
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>and enter the following:</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">CHROMIUM_FLAGS="${CHROMIUM_FLAGS} --check-for-update-interval=31536000"
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>7. Setting up daily reboots</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I’ve configured the Raspberry Pi to reboot twice a day (10:00pm and 7:00am) using cron:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>open cron editor:</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted">crontab –e
```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>enter the following:</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted -->
<pre class="wp-block-preformatted"># Daily reboot (22:00/10:00pm) 0 22 * * * root /home/pi/reboot.sh
# Daily reboot (07:00/07:00am) 0 7 * * * root /home/pi/reboot.sh

```
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>This is it, for configuring Raspberry Pi. I also wanted to shutdown the monitor at night. Since I’m using Xiaomi’s home automation kit, I’ve connected the monitor’s power supply to a Xiaomi power plug, and configured it to power off at 9:30pm and power on at 7:30am.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Once all setup, it looks like this:</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":7363,"width":384,"height":512,"sizeSlug":"large"} -->
<figure class="wp-block-image size-large is-resized"><img src="https://blog.tyang.org/wp-content/uploads/2020/05/image-1.png" alt="" class="wp-image-7363" width="384" height="512"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Note:</strong> The only issue I’ve had is, since the Raspberry Pi is using WiFi, and the Unifi web portal is complaining about insufficient bandwidth to stream all the cameras I’ve configured in the view (6 in total). As the result, the footage was few minutes behind the real time due to the lack of bandwidth. So I created another view, with just one camera (for my front entrance). it is capable of streaming one camera in real time without any lag.</p>
<!-- /wp:paragraph -->