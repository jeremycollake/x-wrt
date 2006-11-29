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
		<font face="Arial Black" size="7">X</font><font size="6" face="Arial Black">-Wrt </font></b>
		</font><font face="Arial Black">&nbsp;</font><b><br>
		</b><font size="2">End User Extensions for OpenWrt</font></i></td>
		<td width="130"><a href="https://developer.berlios.de/projects/xwrt/%20"> <img src="http://developer.berlios.de/bslogo.php?group_id=7373" width="124px" height="32px" border="0" alt="BerliOS Developer Logo" /></a>
		</td>
	</tr>
</table>
<hr />
			<blockquote>
				<p><i><b>X-Wrt</b></i> is a set of packages and patches to enhance the end user 
experience of OpenWrt<i>.</i> X-Wrt will have the stability and extensibility of 
OpenWrt, but will be easier to use. Furthermore, we aim to be pragmatic in our 
development in that we want to get the job done as elegantly as possible, but 
most importantly, get the job done. If you still don't quite get what X-Wrt is, I recommend reading this short article
				<a href="http://developer.berlios.de/blog/archives/69-OpenWrt,-FreeWrt,-and-X-Wrt.html#extended">here</a>.</p>
				<blockquote>
					<p>Project:
					<a href="https://developer.berlios.de/projects/xwrt/">https://developer.berlios.de/projects/xwrt/</a>
					<b><font size="5" color="#666699"><br /></font></b>Forums: 
					<a href="http://www.bitsum.com/smf/index.php?board=17.0">http://www.bitsum.com/smf/index.php?board=17.0</a><br />Screenshots: 
					<a href="http://www.bitsum.com/xwrt">http://www.bitsum.com/xwrt</a> 
(usually out-dated)<br>Email contact(s): <a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a>
					<br>IRC: #x-wrt on irc.freenode.net<br>
&nbsp;</p>
				</blockquote>
			</blockquote>
			<p><b><font size="5" color="#666699">About X-Wrt</font></b></p>
			<blockquote>
				<p>X-Wrt was started because there was a need for end user 
				extensions to OpenWrt, such as an enhanced web management 
				console (webif). For a long time now it has been established 
				that OpenWrt is the best firmware in its class. It far exceeds 
				other firmwares in performance, stability, extensibility, 
				robustness, and design. We at X-Wrt decided it was long past 
				time for end users to get access to this superior firmware. </p>
				<p>This is a free, open-source, community-driven project. Our 
				primary project ideals are:</p>
				<ul>
					<li><b>Free and open-source. </b>The project should be 
					entirely free and open-source, licensed under the GPL. The 
					project should always be hosted at an easily accessible site 
					and source code readily available and easily built.</li>
					<li><b>Easy entrance.</b> The project should always be open 
					to new contributors and have a low entrance barrier. Anyone 
					should be able to contribute. We actively grant write access 
					to anyone interested in having it. We believe people are 
					responsible when given responsibility. Just ask and we'll 
					sign you up.</li>
					<li><b>Democracy.</b> Control should not rest in the hands 
					of any single person. A project yields the best results when 
					it is managed&nbsp; by the community, with decisions made in 
					a democratic manner. We realize that no single person is 
					perfect and any time a project becomes a dictatorship it is 
					subject to the faults of its dictator.</li>
					<li><b>Community driven.</b> This isn't about 'us' offering 
					'you' something, it's about everyone coming together to work 
					towards common goal.</li>
					<li><b>No monetary donations without accounting. </b>We 
					realize that revenue generation is a temptation when any 
					project becomes popular, so we've structured the project to 
					resist such pressures by being non-centralized and having 
					distributed ownership. This inherently means that the 
					project can not accept monetary donations without having a 
					treasurer to hold and account for all donations and what 
					they have went towards. If we did it any other way then 
					there would be some question as to whom the donations are 
					going to. Individual X-Wrt developers may accept monetary 
					donations and users are encouraged to donate directly to 
					them.<br>
&nbsp;</li>
				</ul>
			</blockquote>
			<p><font size="5" color="#666699"><b>Project Status</b></font></p>
			<blockquote>
				<p>This project is still young, but we are accomplishing things at a rapid 
pace. All our work is currently in beta, but our code can be used today and is 
				more stable than many firmwares in their 'final' state. You can keep up with the latest developments by checking the xwrt-svncheckins 
message list that archives commit logs as they happen:
				<a href="https://lists.berlios.de/pipermail/xwrt-svncheckins/">https://lists.berlios.de/pipermail/xwrt-svncheckins</a>. 
				</p>
				<p>Our latest stable snapshot of webif^2 is <b>Milestone 2</b>. The 
			install buttons below will have you install it. If you then use the 
			webif's update feature you will get the latest internal build.<br>&nbsp;</p>
			</blockquote>
			<p><font size="5" color="#666699"><b>Installation Instructions</b></font></p>
			<blockquote>
				<p>X-Wrt is a set of packages that overlay OpenWrt. There are two primary ways to 
install and use X-Wrt on your router:</p>
			</blockquote>
			<ol>
				<li>Flash OpenWrt White Russian, then install webif^2 and any 
				other X-Wrt packages.</li>
				<li>Flash a pre-built image of OpenWrt White Russian that 
				already includes X-Wrt packages like webif^2 as well as other 
				X-Wrt updates.<br>
&nbsp;</li>
			</ol>
			<ul>
				<li><b><font size="4"><u>
				Method #1:
				</u></font></b><u><font size="4">
				Flash OpenWrt White Russian RC5 or RC6 then 
				install X-Wrt packages like Webif^2.</font></u></li>
			</ul>
			<blockquote>
	<p><font size="4" color="#666699"><b>Step-by-step if you have NOT already 
	flashed OpenWrt</b></font></p>
	<blockquote>
		<ol>
			<li>Download an appropriate OpenWrt White Russian image and flash it 
		(follow instructions on <a href="http://wiki.openwrt.org">OpenWrt's wiki</a>). We recommend 
		White Russian RC5, RC6, or 0.9 (when it is released). Kamikaze is NOT supported yet, 
		but will be eventually.</li>
			<li>Flash it.</li>
			<li>Enter your router's IP address in the field below and click one 
			of the two buttons to install either the latest daily build of 
			webif^2, or the last official release. The last official release 
			(currently milestone 2) might be more well tested, but has not got 
			all the latest updates included.</li>
		</ol>
	</blockquote>
</blockquote>
<form action="" method="get" name="instform">	
	<blockquote>
		<blockquote>
			<blockquote>
				<p><b><br>
				Your Router's IP:</b>
				<input type="text" name="routerip" size="12" value="192.168.1.1"></input>
				<input type="submit" value=" Install Latest Daily Build of Webif^2 " name="install_webif"  onclick="installWebif(this.form)"></input>
				<i>newer<br>
				</i><b><br>
				Your Router's IP:</b>
				<input type="text" name="routerip0" size="12" value="192.168.1.1"></input>
				<input type="submit" value=" Install Milestone 2 Release of Webif^2 " name="install_webif0"  onclick="installWebifMilestone2(this.form)"></input>
				<i>better tested</i></p>
				<p>
				<i>NOTE: This button will NOT work with Internet Explorer!<br>
				<br>
				</i>Alternately, if you are an advanced user you can ssh to the 
				router and run &quot;<font size="2" face="Courier New"><b>ipkg install 
				http://ftp.berlios.de/pub/xwrt/webif_latest.ipk&quot;.</b></font></p>
			</blockquote>
		</blockquote>
	</blockquote>
</form>
<blockquote>
	<blockquote>
		<ol start="4">
			<li>Once the installation has completed, you may need to reboot your 
		router. </li>
			<li>If the display of the web pages looks funny, do a 
		hard refresh (hold down SHIFT and click REFRESH) to clear out the old 
		CSS.</li>
		</ol>
	</blockquote>
	<blockquote>
		<p><font color="#FF0000"><b>WARNING: </b>The very first install of 
		webif^2 will reboot your router!</font></p>
	</blockquote>
</blockquote>
			<ul>
				<li><b><font size="4"><u>
				Method #2: 
				</u> </font></b><u><font size="4">
				Flash 
				pre-built OpenWrt White Russian images that already contain 
				X-Wrt packages. </font> 
				</u> 
				<blockquote>
					<ol>
						<li>Download firmware images from here:
						<a href="ftp://ftp.berlios.de/pub/xwrt/images/">ftp://ftp.berlios.de/pub/xwrt/images/</a> 
						. Download the one appropriate to your router. </li>
						<li>Once you've extracted the images, flash the squashfs 
						image appropriate to your router by following the 
						instructions on <a href="http://wiki.openwrt.org">OpenWrt's wiki</a>.</li>
					</ol>
					<p>Micro builds are currently under development and will be 
					posted as soon as they are ready.</p>
					<p><b><i>WARNING:</i> </b><i>These images are in a non-final 
					state and are updated several times a week. Although they 
					should be stable, if you have any troubles with them, please 
					report it.<br>
&nbsp;</i></p>
				</blockquote>
				</li>
			</ul>
			<p><font size="5" color="#666699"><b>Can I use X-Wrt in my 
			commercial venture?</b></font></p>
			<blockquote>
				<p>Yes, you can use X-Wrt in whatever way you like, providing 
				you do not violate the terms of the GPL license agreement and 
				any other licenses applicable. We can help you to rebrand the 
				webif and tweak it to suit your needs. Some of our developers do 
				contract work. If you are interested in using X-Wrt as part of a 
				commercial venture, we'd love to hear about it, and perhaps even 
				brag about it if you give us permission to do so ;). Email us at
				<a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a> to let 
				us know what you are using X-Wrt for.</p>
				<p><i><b>Note to X-Wrt developers:</b> The above solicitation of 
				contract work is for everyone. If you would like your name and 
				email address listed in this space, please let me (db90h) know.</i></p>
			</blockquote>
			<p><br />
			<font size="5" color="#666699"><b>Participate in X-Wrt</b></font></p>
			<blockquote>
				<p>We always need developers, testers, documentation writers, 
			translators, and support personnel. Our project is truly OPEN and 
			FREE. Anyone can come join our project. </p>
				<p>If you would like to get write access to our repository, just 
			create an account at <a href="http://www.berlios.de">www.berlios.de</a> 
			and email <a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a> 
			or contact one of our other developers on the irc channel (#x-wrt / 
			freenode). We do not make anyone pass an 'entrance exam', though we 
			do like for people to supply a patch of some sort just to prove that 
			you are serious. <br>
&nbsp;</p>
			</blockquote>
			<p><font size="5" color="#666699"><b>Support X-Wrt</b></font></p>
			<blockquote>
				<p>We do not accept monetary donations because we have no 
				project treasurer to account for those donations and where they 
				go. However, there are some things you can help us with if you 
				choose:</p>
				<ul>
					<li><b>web hosting.</b> Berlios provides most our web 
					services, but we may need other web hosts in the future.</li>
					<li><b>domain name purchases.</b> Domain names aren't as 
					important as they used to be, but we wouldn't mind having a 
					few more to ensure people can easily find our project. You 
					can guess which ones we might want, anything that has to do 
					with x-wrt. If you register a domain name for us you must 
					register it in one of our developers names, or transfer 
					ownership of it to us.</li>
					<li><b>hardware donations. </b>You can donate routers or 
					other hardware to our developers, who may be in need of them 
					for testing purposes. We are currently running our poor 
					routers into the ground, so we encourage these type of 
					donations.</li>
					<li><b>spread the word.</b> Tell people you think might be 
					interested about our project. That helps tremendously.</li>
				</ul>
				<p>&nbsp;</p>
			</blockquote>
			<p><br>
			&nbsp;</p>
			</td>
		</tr>
		<tr>
			<td align="left">&nbsp;</td>
		</tr>
	</table>
	<p>X-Wrt is a free, open-source project maintained by the community that 
	uses it.<br>
	All our work is licensed under the GPL.<br>
	<a href="http://www.x-wrt.org">http://www.x-wrt.org</a></div>
<p align="center"><font color="#FFFFFF">(c)2006 Jeremy Collake / X-Wrt Project</font></p>
</body>
</html>
