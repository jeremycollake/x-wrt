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

<body bgcolor="#666699">

<script type="text/javascript">
function installWebif(form)
{
  var install_url= "http://" + document.instform.routerip.value + "//cgi-bin/webif/ipkg.sh?action=install&amp;pkg=http://ftp.berlios.de/pub/xwrt/packages/webif_0.3-2_mipsel.ipk";
  window.open(install_url,'Auto-Install','toolbar=yes,resizable=yes');
  return false;
}
</script> 

<div align="center">
	<table border="0" width="800" id="table3" bgcolor="#FFFFFF" cellpadding="5">
		<tr>
			<td align="left">&nbsp;<table border="0" width="100%" id="table4">
	<tr>
		<td align="left"><i><font color="#666699"><b><font face="Book Antiqua" size="7">X</font><font size="6">-Wrt </font></b>
		</font>&nbsp;<br />
		Pragmatism at work.<br />
		</i>
<a href="https://developer.berlios.de/projects/xwrt/">https://developer.berlios.de/projects/xwrt/</a> 
		</td>
		<td width="130"><a href="https://developer.berlios.de/projects/xwrt/%20"> <img src="http://developer.berlios.de/bslogo.php?group_id=7373" width="124px" height="32px" border="0" alt="BerliOS Developer Logo" /></a>
		</td>
	</tr>
</table>
<hr />
<p><i><b>X-Wrt</b></i> is a set of packages and patches to enhance the end user 
experience of OpenWrt<i>.</i> X-Wrt will have the stability and extensibility of 
OpenWrt, but will be easier to use. Furthermore, we aim to be pragmatic in our 
development in that we want to get the job done as elegantly as possible, but 
most importantly, get the job done. If you still don't quite get what X-Wrt is, I recommend reading this short article
<a href="http://developer.berlios.de/blog/archives/69-OpenWrt,-FreeWrt,-and-X-Wrt.html#extended">
here</a>.</p>
<p>Project:
<a href="https://developer.berlios.de/projects/xwrt/">https://developer.berlios.de/projects/xwrt/</a> 
		<b><font size="5" color="#666699"><br />
</font></b>Forums: <a href="http://www.bitsum.com/smf/index.php?board=17.0">
http://www.bitsum.com/smf/index.php?board=17.0</a><br />
Screenshots: <a href="http://www.bitsum.com/xwrt">http://www.bitsum.com/xwrt</a></p>
			<p><br>
			<b><font size="5" color="#666699">Why do this?</font></b></p>
<p>In short, because nobody else is. X-Wrt's target audience has been forced to either 
deal with buggy and/or incomplete end user firmwares, or expend considerable 
time and energy configuring OpenWrt on their routers. Not everyone has the time or desire to 
learn OpenWrt's NVRAM and/or config file based setup. With X-Wrt, people can have 
all the benefits of OpenWrt with a minimal set up time.</p>
<p><br />
<b><font size="5" color="#666699">Will X-Wrt work be ported to OpenWrt, FreeWrt, 
and other projects?</font><font size="4"><br />
<br />
</font>
</b>Some of it will, some of it won't. It isn't up to us, it is up to the 
developers of the projects. We have tried to work with all projects to the best 
our abilities, but many developers of the other projects either have no interest 
in end user extensions, or are actively hostile to it.</p>
<p><br />
<b><font size="5" color="#666699">How much is completed so far?</font></b></p>
<p>This project is still very new, but we are accomplishing things at a rapid 
pace. You can keep up with the latest developments by checking the xwrt-svncheckins 
message list that archives commit logs as they happen:
<a href="https://lists.berlios.de/pipermail/xwrt-svncheckins/">
https://lists.berlios.de/pipermail/xwrt-svncheckins</a> .<br />
&nbsp;</p>
<p><br />
<font size="5" color="#666699"><b>How do I install X-Wrt?</b></font></p>
<p>At present you first install OpenWrt White Russian, then install X-Wrt 
package(s). Alternatively, you can use OpenWrt's image builder to create 
firmware images with X-Wrt's packages pre-installed. </p>
<p>The first and most important package is Webif^2, our new http based managed 
console. Below are instructions on how to install this new webif.</p>
<blockquote>
	<p><br /><b><font size="4" color="#666699">I'm an experienced OpenWrt user, how do I the latest webif^2 package?</font></b></p>
	<blockquote>
		<p>You can install the latest <font color="#666699"><i>alpha build </i>
		</font>of our webif if you are running 
OpenWrt White Russian RC5 or later (but NOT kamikaze) by ssh'ing into the router and running the 
following commands:</p>
	</blockquote>
</blockquote>
<table border="0" width="100%" bgcolor="#FFFFFF" id="table5">
	<tr>
		<td>
		<blockquote>
			<blockquote>
				<p>
				<font size="2" face="Courier New">ipkg install 
			http://ftp.berlios.de/pub/xwrt/packages/webif_0.3-2_mipsel.ipk
				</font></p>
			</blockquote>
		</blockquote>
		</td>
	</tr>
</table>
<blockquote>
	<blockquote>
		<p>If you get a conflict error you may need to add '-force-overwrite'. 
		If you have problems accessing some or all pages, reboot your router to 
		force the httpd to be restart, or run 'killall httpd; 
		/etc/init.d/S50httpd'.</p>
	</blockquote>
	<p><br /><b><font size="4" color="#666699">I'm totally new to OpenWrt. How do I install the latest 
webif^2 package?</font></b></p>
	<blockquote>
		<p>1. Download an appropriate OpenWrt White Russian image. We recommend 
	RC5, <a href="http://downloads.openwrt.org/people/nbd/whiterussian/">pre-RC6</a>, 
		or any later release (presumably, since they don't exist yet). 
		Alternatively, you can download a pre-built X-Wrt OpenWrt image soon.<br />2. Flash it, let it reboot, then reboot it again (in case you used JFFS2 image, 
which needs a second reboot and doesn't do it automatically).<br />3. Then use the following form to install the latest X-Wrt webif^2 on to your 
router:</p></blockquote>
</blockquote>
<form action="" method="post" name="instform">	
	<blockquote>
		<blockquote>
			<p>Your Router's IP: 
			<input type="text" name="routerip" size="12" value="192.168.1.1"></input>
			<input type="submit" value=" Install Webif^2 " name="install_webif"  onclick="installWebif(this.form)"></input></p>
		</blockquote>
	</blockquote>
</form>
<blockquote>
	<blockquote>
		<p>You'll see various text emitted, then finally 'Terminated Successfully'. Ignore any warnings or errors you may get, so long you see that phrase at the end. At this point, reboot your router.</p>
	</blockquote>
</blockquote>
<p><br />
<font size="5" color="#666699"><b>I want to help!</b></font></p>
<p>Great! We really need developers, translators, documentation writers, testers, and plain users ;). Join the 
effort by visiting our forums or emailing
<a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a>. </p>
 <p>
    &nbsp;</p>
			<p>&nbsp;</td>
		</tr>
	</table>
</div>
<p align="center"><font color="#FFFFFF">(c)2006 Jeremy Collake / X-Wrt Project</font></p>
</body>
</html>
