<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<?xml version="1.0" encoding="ISO-8859-1"?>
<head>
<meta http-equiv="Content-Language" content="en-us" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>X-Wrt</title>
<meta name="description" content="X-Wrt is a set of packages and patches to enhance the end user experience of OpenWrt." />
<meta name="keywords" content="X-Wrt XWrt OpenWrt">
</head>

<body>

<script type="text/javascript">
function installWebif(form)
{
  var install_url= "http://" + document.instform.routerip.value + "//cgi-bin/webif/ipkg.sh?action=install&amp;pkg=http://ftp.berlios.de/pub/xwrt/webif_latest.ipk";
  window.open(install_url,'Auto-Install','toolbar=yes,resizable=yes');
  return false;
}

function installWebifMilestone2(form)
{
  var install_url= "http://" + document.instform.routerip.value + "//cgi-bin/webif/ipkg.sh?action=install&amp;pkg=http://ftp.berlios.de/pub/xwrt/packages/webif_milestone2.ipk";
  window.open(install_url,'Auto-Install','toolbar=yes,resizable=yes');
  return false;
}
</script> 

<div align="center">
	<table border="0" width="943" id="table3" bgcolor="#FFFFFF" cellpadding="5">
		<tr>
			<td align="left">&nbsp;<table border="0" width="100%" id="table4">
	<tr>
		<td align="left"><i><font color="#666699"><b>
		<font face="Arial Black" size="7">X</font><font size="6" face="Arial Black">-</font><font size="5" face="Arial Black">Wrt </font></b>
		</font><font face="Verdana"><font size="5">&nbsp;</font><br>
		OpenWrt for end users</font></i></td>
		<td width="130"><font face="Verdana">Hosted at ...<a href="https://developer.berlios.de/projects/xwrt/"><img src="http://developer.berlios.de/bslogo.php?group_id=7373" width="124px" height="32px" border="0" alt="BerliOS Developer Logo" /></a>
		</font>
		</td>
	</tr>
</table>
<hr />
			<blockquote>
				<p><font face="Verdana"><b>X-Wrt</b> is a set of packages and 
				patches to enhance the end user experience of OpenWrt. It is NOT a fork of OpenWrt. 
				We work in conjunction with the OpenWrt developers to extend 
				OpenWrt. </font></p>
				<p><font face="Verdana">Our packages currently work with the 
				latest public release of OpenWrt - White Russian RC6. We also 
				maintain backwards compatibility with OpenWrt White Russian RC5. 
				Support of OpenWrt's upcoming Kamikaze firmware is
				<a href="#kamikaze">coming soon</a>. Explore this page to learn 
				about our work, or just skip straight to
				<a href="#Installation_Instructions">installing X-Wrt</a> and 
				see the fruits of our labor yourself.</font></p>
				<p><b><font face="Verdana">Project Links:</font></b></p>
				<blockquote>
					<ul type="circle">
						<li><font face="Verdana">
						<a href="https://developer.berlios.de/projects/xwrt/">
						Project Hosting</a></font></li>
						<li><font face="Verdana">
						<a href="ftp://ftp.berlios.de/pub/xwrt">FTP Site</a></font></li>
						<li><font face="Verdana">
						<a href="http://developer.berlios.de/mail/?group_id=7373">
						Mailing Lists</a></font></li>
						<li><font face="Verdana">
						<a href="http://www.bitsum.com/smf/index.php?board=17.0">Forums</a></font></li>
						<li><font face="Verdana">
						<a href="http://www.bitsum.com/xwrt">Screenshots</a></font></li>
						<li><font face="Verdana">
						<a href="mailto:jeremy@bitsum.com">Email</a></font></li>
						<li><font face="Verdana"><a href="#x-wrt">IRC</a></font></li>
					</ul>
				</blockquote>
				<p><b><font face="Verdana">Document Navigation:</font></b></p>
				<blockquote>
					<ol type="I">
						<li><font face="Verdana"><a href="#About_X-Wrt">
						Introduction</a></font></li>
						<li><font face="Verdana"><a href="#Project_Status">
						Status</a></font></li>
						<li><font face="Verdana">
						<a href="#Installation_Instructions">Installation 
						Instructions</a></font></li>
						<li><font face="Verdana"><a href="#webif_problems">Webif<sup>2</sup> Troubleshooting</a></font></li>
						<li><font face="Verdana"><a href="#X-Wrt_Packages">X-Wrt 
						Packages</a></font></li>
						<li><font face="Verdana"><a href="#kamikaze">OpenWrt 
						Kamikaze Plans</a></font></li>
						<li><font face="Verdana"><a href="#commercial">
						Commercial Use: Ok</a></font></li>
						<li><font face="Verdana"><a href="#participate">
						Participate</a></font></li>
						<li><font face="Verdana"><a href="#support">Support Us</a></font><br>
&nbsp;</li>
					</ol>
				</blockquote>
			</blockquote>
			<p><a name="About_X-Wrt"><b>
			<font face="Verdana" size="5" color="#666699">Introduction to </font>
			</b></a><b><a name="About_X-Wrt">
			<font size="5" color="#666699" face="Verdana">X-Wrt</font></a></b></p>
			<blockquote>
				<p><font face="Verdana">X-Wrt was started because there was a 
				need for end user extensions to OpenWrt, such as an enhanced web 
				management console (webif). For a long time now it has been 
				established that OpenWrt is the best firmware in its class. It 
				far exceeds other firmwares in performance, stability, 
				extensibility, robustness, and design. We at X-Wrt decided it 
				was long past time for end users to get access to this superior 
				firmware. </font></p>
				<p><font face="Verdana">We are a separate project from OpenWrt 
				due to the difference in focus and development ideals. We are 
				considerably more pragmatic than OpenWrt and have the goal of 
				providing solutions <i>today</i>, while OpenWrt has a more 
				idealistic development philosophy and intends to perfect the 
				firmware core, no matter how many rewrites and how much time it 
				takes. This difference in development attitude creates a 
				complimentary atmosphere that benefits everyone.</font></p>
				<p><font face="Verdana">This is a free, open-source, 
				community-driven project. Our primary project ideals are:</font></p>
				<ul>
					<li><font face="Verdana"><b>Free and open-source. </b>The 
					project should be entirely free and open-source, licensed 
					under the GPL. The project should always be hosted at an 
					easily accessible site and source code readily available and 
					easily built.</font></li>
					<li><font face="Verdana"><b>Easy entrance.</b> The project 
					should always be open to new contributors and have a low 
					entrance barrier. Anyone should be able to contribute. We 
					actively grant write access to anyone interested in having 
					it. We believe people are responsible when given 
					responsibility. Just ask and we'll sign you up.</font></li>
					<li><font face="Verdana"><b>Community driven.</b> This isn't 
					about 'us' offering 'you' something, it's about everyone 
					coming together to work towards the common goal.</font></li>
					<li><font face="Verdana"><b>No monetary donations without 
					accounting. </b>The project can not accept monetary 
					donations without having a treasurer to hold and account for 
					all donations and what they have went towards.<br>&nbsp;</font></li>
				</ul>
			</blockquote>
			<p><font size="5" color="#666699" face="Verdana"><b>
			<a name="Project_Status">Project Status</a></b></font></p>
			<blockquote>
				<p><font face="Verdana">This project is still young, but we are accomplishing things at a rapid 
pace. All our work is currently in beta, but our code can be used today and is 
				more stable than many firmwares in their 'final' state. You can keep up with the latest developments by checking the xwrt-svncheckins 
message list that archives commit logs as they happen:
				<a href="https://lists.berlios.de/pipermail/xwrt-svncheckins/">https://lists.berlios.de/pipermail/xwrt-svncheckins</a>. 
				</font></p>
				<p><font face="Verdana">Our latest stable snapshot of webif<sup>2</sup> is 
				<b>Milestone 2</b>. The 
			install buttons below will have you install it. If you then use the 
			webif's update feature you will get the latest internal build.<br>&nbsp;</font></p>
			</blockquote>
			<p><font size="5" color="#666699" face="Verdana"><b>
			<a name="Installation_Instructions">Installation 
			Instructions</a></b></font></p>
			<blockquote>
				<p><font face="Verdana">X-Wrt is a set of packages that overlay OpenWrt. There are two primary ways to 
install and use X-Wrt on your router:</font></p>
			</blockquote>
			<ol>
				<li><font face="Verdana">Flash OpenWrt White Russian, then install webif<sup>2</sup> and any 
				other X-Wrt packages.<br>
				<b><i>...or...</i></b></font></li>
				<li><font face="Verdana">Flash a pre-built image of OpenWrt White Russian that 
				already includes X-Wrt packages like webif<sup>2</sup>.</font></li>
			</ol>
			<blockquote>
				<p><font face="Verdana" color="#FF0000"><b>WARNING:</b> All 
				X-Wrt packages, including webif<sup>2</sup> are in <b>beta</b>. For 
				stability we recommend you install the latest milestone build 
				and not do any upgrades until a new milestone build is 
				available.</font></p>
			</blockquote>
			<ul>
				<li><font face="Verdana"><b><font size="4">Method #1:
				</font></b><font size="4">
				Flash OpenWrt White Russian then 
				install X-Wrt packages</font></font></li>
			</ul>
			<blockquote>
	<blockquote>
		<ol>
			<li><font face="Verdana">If you do not already have OpenWrt White 
			Russian on your router, download an appropriate OpenWrt White Russian image and flash it 
		(follow instructions in <a href="http://wiki.openwrt.org">OpenWrt's wiki</a>). We recommend 
		White Russian RC5, RC6, or 0.9 (when it is released). Kamikaze is NOT supported yet, 
		but will be <a href="#kamikaze">soon</a>.</font></li>
			<li><font face="Verdana">Enter your router's IP address in the field below and click the 
			button below to install the latest official beta release of X-Wrt's webif. 
			After you install the latest official beta release the 'check for 
			update' and 'upgrade' buttons you'll find in the webif itself will 
			move you up to the latest daily build, which has more features but 
			has been less extensively tested.<br>
			<br>
			This button will <b>NOT </b>work with Internet Explorer at present.</font></li>
		</ol>
	</blockquote>
</blockquote>
<form action="" method="get" name="instform">	
	<blockquote>
		<blockquote>
			<blockquote>
				<blockquote>
					<p><font face="Verdana"><b><br></b>Your Router's IP address:
					<input type="text" name="routerip" size="12" value="192.168.1.1"></input></font><font face="Verdana"><p>				
					<input type="submit" value=" Install Milestone 2 Release of Webif^2 beta " name="install_webif0"  onclick="installWebifMilestone2(this.form)"></p>
				</blockquote>
			</blockquote>
		</blockquote>
	</blockquote>
</form>
			<blockquote>
	<blockquote>
		<p><font color="#FF0000" face="Verdana"><b>WARNING: </b>The very first install of 
		webif<sup>2</sup> will reboot your router!</font></p>
		<p>If the display of the web pages looks funny, do a 
		hard refresh (hold down SHIFT and click REFRESH) to clear out the old 
		CSS.</p>
		<p>Instead of using this automated install procedure, you can also ssh 
		or telnet to the 
				router and run: <span style="background-color: #FFFFCC">&nbsp;ipkg install 
				<a href="http://ftp.berlios.de/pub/xwrt/webif_latest.ipk">http://ftp.berlios.de/pub/xwrt/webif_latest.ipk</a>
		</span></p>
	</blockquote>
</blockquote>
			<ul>
				<li><b><font size="4">Method #2: 
				</font></b><font size="4">
				Flash pre-built OpenWrt White Russian images<u> 
				</u> 
				</font> 
				<blockquote>
					<ol>
						<li><font face="Verdana">Download firmware images from here:
						<a href="ftp://ftp.berlios.de/pub/xwrt/images/">ftp://ftp.berlios.de/pub/xwrt/images/</a> 
						. Download the one appropriate to your router. </font> </li>
						<li><font face="Verdana">Once you've extracted the images, flash the squashfs 
						image appropriate to your router by following the 
						instructions on <a href="http://wiki.openwrt.org">OpenWrt's wiki</a>.</font></li>
					</ol>
					<p><font face="Verdana">Micro builds are currently under development and will be 
					posted as soon as they are ready.</font></p>
					<p><font face="Verdana"><b><i>WARNING:</i> </b><i>These images are in a non-final 
					state and are updated several times a week. Although they 
					should be stable, if you have any troubles with them, please 
					report it.<br>
&nbsp;</i></font></p>
				</blockquote>
				</li>
			</ul>
			<p><font size="5" color="#666699"><b><a name="webif_problems">
			Webif<sup>2</sup> Problems</a></b></font></p>
			<blockquote>
				<p>Since our new webif is in beta sometimes you can get a build 
				that has problems. The best advice is:</p>
				<ol>
					<li>Upgrade to a newer build when it is available.</li>
					<li>Report bugs or other errata you see if you don't find it 
					fixed in the next build. It's hard for us to test every 
					build thoroughly.</li>
					<li>If you somehow got unlucky and ended up with a daily 
					build that was horribly broken and you can't upgrade the 
					webif, ssh into the router and run this:<br>
					<br>
					<i>ipkg install
					<a href="http://ftp.berlios.de/pub/xwrt/webif_latest.ipk">
					http://ftp.berlios.de/pub/xwrt/webif_latest.ipk</a> 
					-force-reinstall</i></li>
				</ol>
			</blockquote>
			<p>&nbsp;</p>
			<p><font size="5" color="#666699"><b><a name="X-Wrt_Packages">X-Wrt Packages</a></b></font></p>
			<blockquote>
				<p>Although all our work is based around our webif<sup>2</sup> package, we 
				actually have a number of packages to add to OpenWrt. At present 
				they are all for White Russian, but we are moving actively into 
				Kamikaze right now. A list of some of our packages are:</p>
				<ul>
					<li><b>webif<sup>2</sup></b> - our new webif, but you already know 
					that ;).</li>
					<li><b>miniupnpd</b> - an offering of this excellent new 
					upnp daemon.</li>
					<li><b>tarfs</b> - a specialized pseudo-filesystem for micro 
					sized routers. <i>- alpha stage development</i></li>
					<li><b>busybox 1.2.1</b> - an update over the Busybox 1.0 
					used in White Russian. It also includes some different 
					applets, like user management utilities.</li>
					<li><b>wireless-tools v29 pre10</b> - an update to 
					wireless-tools (iwconfig, iwlist, etc..).</li>
					<li><b>ipkg-upgrade-fix</b> - issues a warning when a user 
					tries to run 'ipkg upgrade', something known to wreak havoc 
					on unsuspecting users.</li>
				</ul>
				<p>&nbsp;</p>
			</blockquote>
			<p><font size="5" color="#666699" face="Verdana"><b>
			<a name="kamikaze"></a>OpenWrt Kamikaze Plans</b></font></p>
			<blockquote>
				<p>We are working actively towards a version of the webif for 
				OpenWrt's long delayed next generation, Kamikaze. By the time 
				Kamikaze goes public, we probably will have finished support for 
				it.</p>
				<p>OpenWrt Kamikaze represents a substantial and fundamental 
				change. It is not simply a new version of White Russian, but 
				instead a complete rewrite of the build root and configuration 
				structure. That is why White Russian went stagnant for so long, 
				the developers quit working on it in favor of this more 
				ambitious idealized solution. This new branch of OpenWrt took a 
				long, long time to hash out, but now its almost ready.</p>
				<p>The ever-popular NVRAM configuration storage system is no 
				longer utilized in Kamikaze. It has been replaced with 
				configuration files, many stored in the common format known as 
				'UCI'. This was done because although an emulated NVRAM storage 
				area to keep tuple based configuration data can be easily 
				implemented on any platform, the OpenWrt developers felt it 
				wasn't structured enough for their tastes. So, out the window it 
				went.</p>
				<p>To make the webif work with Kamikaze we therefore have to 
				work with this new configuration system. The good news is our 
				webif already supports UCI. Some pages, like the QoS page, use 
				the UCI system entirely. To finalize support for Kamikaze we 
				simply have to take the remaining code that utilizes NVRAM and 
				either write new code or write a translation layer to convert 
				NVRAM to and from UCI configuration files. The end solution may 
				be a combination of both.</p>
				<p>While some do not approve of us maintaining support for White 
				Russian, we believe it is important to continue to support the 
				only stable branch of OpenWrt released at the time of this 
				writing. White Russian will be around for many years and the 
				overhead required in supporting both Kamikaze and White Russian 
				is minimal compared to the rewards.</p>
				<p><i>We hope to have basic Kamikaze support by the end of 2006. 
				Join the team and help us accomplish this!</i></p>
				<p><b>A new webif system</b> ...</p>
				<p>This is only partially related to the Kamikaze support, but 
				it should be mentioned somewhere.</p>
				<p>At the core of the webif is a system that is responsible for 
				actually rendering the webif pages (which are combinations of 
				shell and awk code mostly). There are some in the OpenWrt 
				community who are calling for a complete rewrite of this base 
				webif system. The plan is to develop an AWK-only system that 
				uses no shell scripting. This will have advantages in efficiency 
				and resource use, but will likely not be substantially easier to 
				code for. This rewrite of the base webif system has not yet 
				commenced at the time of this writing. </p>
				<p>We are proceeding in such a way that ensures backwards 
				compatibility with existing webif pages. At first, there will be 
				two webif systems operating together, the old and the new. There 
				will be little to no performance overhead to this dual-system 
				and the base webif system is so small that it will hardly occupy 
				any flash ROM space. What small price there is to having a 
				dual-system in place will be well worth not having to wait 
				indefinitely for all webif pages to be rewritten from scratch.</p>
				<p>It is important to note that nobody should wait for this new 
				system to become available before making contributions to the 
				webif. As stated above, this planned new system has not even 
				been started yet, and it is possible it never will be.</p>
			</blockquote>
			<p><font size="5" color="#666699" face="Verdana"><b><br>
			<a name="commercial">Can I use X-Wrt 
			in my commercial venture</a>?</b></font></p>
			<blockquote>
				<p><font face="Verdana">Yes, you can use X-Wrt in whatever way 
				you like, providing you do not violate the terms of the GPL 
				license agreement and any other licenses applicable. We can help 
				you to rebrand the webif and tweak it to suit your needs. Some 
				of our developers do contract work. If you are interested in 
				using X-Wrt as part of a commercial venture, we'd love to hear 
				about it, and perhaps even brag about it if you give us 
				permission to do so ;). Email us at
				<a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a> to let 
				us know what you are using X-Wrt for.</font></p>
				<p><font face="Verdana"><i>Note to X-Wrt developers: The above 
				solicitation of contract work is for everyone. If you would like 
				your name and email address listed in this space, please let me 
				(db90h) know.</i></font></p>
			</blockquote>
			<p><br>
			<br />
			<font size="5" color="#666699"><b><a name="participate">Participate in X-Wrt</a></b></font></p>
			<blockquote>
				<p><font face="Verdana">We always need developers, testers, documentation writers, 
			translators, and support personnel. Our project is truly OPEN and 
			FREE. Anyone can come join our project. </font></p>
				<p><font face="Verdana">If you would like to get write access to our repository, just 
			create an account at <a href="http://www.berlios.de">www.berlios.de</a> 
			and email <a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a> 
			or contact one of our other developers on the irc channel (#x-wrt / 
			freenode). We do not make anyone pass an 'entrance exam', though we 
			do like for people to supply a patch of some sort just to prove that 
			you are serious.</font></p>
				<p>A listing of some of the needs we have are:</p>
				<ul>
					<li>development</li>
					<li>graphic artists</li>
					<li>localization (translation)</li>
					<li>user support</li>
					<li>documentation writers<br>&nbsp;</li>
				</ul>
			</blockquote>
			<p><font size="5" color="#666699" face="Verdana"><b>
			<a name="support">Support X-Wrt</a></b></font></p>
			<blockquote>
				<p>We do not accept monetary donations 
				because we have no project treasurer to account for those 
				donations and where they go. However, there are some things you 
				can help us with if you choose:</p>
				<ul>
					<li><font face="Verdana"><b>web hosting.</b> Berlios 
					provides most our web services, but we may need other web 
					hosts in the future.</font></li>
					<li><font face="Verdana"><b>hardware donations. </b>You can 
					donate routers or other hardware to our developers, who may 
					be in need of them for testing purposes. We are currently 
					running our poor routers into the ground, so we encourage 
					these type of donations.</font></li>
					<li><font face="Verdana"><b>spread the word.</b> Tell people 
					you think might be interested about our project. Not even 
					all OpenWrt users have heard of our project yet. You might 
					consider mentioning X-Wrt on the OpenWrt forums and in 
					#openwrt on freenode. </font></li>
				</ul>
				<p>&nbsp;</p>
			</blockquote>
			<p><font face="Verdana"><br>
			&nbsp;</font></p>
			</font>
			</td>
		</tr>
		<tr>
			<td align="left">&nbsp;</td>
		</tr>
	</table>
	<p><font face="Verdana">X-Wrt is a free, open-source project maintained by 
	the community that uses it.<br>
	All our work is licensed under the GPL.<br>
	<a href="http://www.x-wrt.org">http://www.x-wrt.org</a></font></div>
<p align="center"><font color="#FFFFFF" face="Verdana">(c)2006 Jeremy Collake / 
X-Wrt Project</font></p>
</body>
</html>