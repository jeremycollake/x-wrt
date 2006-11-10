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
	<table border="0" width="1000" id="table3" bgcolor="#FFFFFF" cellpadding="5">
		<tr>
			<td align="left">&nbsp;<table border="0" width="100%" id="table4">
	<tr>
		<td align="left"><i><font color="#666699"><b><font face="Book Antiqua" size="7">X</font><font size="6">-Wrt </font></b>
		</font>&nbsp;<br />
		<b>End User Extensions for OpenWrt</b><br />
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
Screenshots: <a href="http://www.bitsum.com/xwrt">http://www.bitsum.com/xwrt</a> 
(usually very out-dated)</p>
			<p>&nbsp;</p>
			<p><br>
			<b><font size="5" color="#666699">Why do this?</font></b></p>
<p>In short, because nobody else is. X-Wrt's target audience has been forced to either 
deal with buggy and/or incomplete end user firmwares, or expend considerable 
time and energy configuring OpenWrt on their routers. Not everyone has the time or desire to 
learn OpenWrt's NVRAM and/or config file based setup. With X-Wrt, people can have 
all the benefits of OpenWrt with a minimal set up time.</p>
<p><br />
&nbsp;</p>
			<p><b><font size="5" color="#666699">How much is completed so far?</font></b></p>
<p>This project is still young, but we are accomplishing things at a rapid 
pace. All our work is currently in beta, but most of our code can be used today. You can keep up with the latest developments by checking the xwrt-svncheckins 
message list that archives commit logs as they happen:
<a href="https://lists.berlios.de/pipermail/xwrt-svncheckins/">
https://lists.berlios.de/pipermail/xwrt-svncheckins</a>. </p>
			<p><br />
&nbsp;</p>
			<p><font size="5" color="#666699"><b>How do I install X-Wrt?</b></font></p>
<p>X-Wrt is a set of packages that overlay OpenWrt. There are three ways to 
install and use X-Wrt on your router:</p>
			<ul>
				<li><b><font size="4"><u>Method #1</u> (recommended): </font>
				</b><font size="4">Flash OpenWrt White Russian RC5 or RC6 then 
				install X-Wrt packages like Webif^2.</font></li>
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
			<li>&nbsp;Flash it, let it reboot, then reboot it 
		again (in case you used JFFS2 image, which needs a second reboot and 
		doesn't do it automatically).</li>
			<li>Then use the following form to install the latest X-Wrt webif<sup>2</sup> on to your 
router:</li>
		</ol>
	</blockquote>
</blockquote>
<form action="" method="get" name="instform">	
	<blockquote>
		<blockquote>
			<blockquote>
				<p><b>Your Router's IP:</b>
				<input type="text" name="routerip" size="12" value="192.168.1.1"></input>
				<input type="submit" value=" Install Webif^2 " name="install_webif"  onclick="installWebif(this.form)"></input>
				<i>NOTE: this button will NOT work with Internet Explorer!</i></p>
			</blockquote>
		</blockquote>
	</blockquote>
</form>
<blockquote>
	<blockquote>
		<ol start="4">
			<li>Once the installation has completed, you may need to reboot your 
		router. </li>
			<li>If the display of the web management console pages looks funny, do a 
		hard refresh (hold down SHIFT and click REFRESH) to clear out the old 
		CSS.</li>
		</ol>
	</blockquote>
	<p><font size="4" color="#666699"><b>Step-by-step if you HAVE already 
	flashed OpenWrt</b></font></p>
	<blockquote>
		<p>You can install the latest build of X-Wrt's webif<sup>2</sup> if you are running 
OpenWrt White Russian RC5 or RC6. Kamikaze and pre-RC5 images are not supported. 
		To install the package, run this at the terminal (ssh) prompt:</p>
	</blockquote>
</blockquote>
			<table border="0" width="100%" bgcolor="#FFFFFF" id="table5">
				<tr>
					<td>
					<blockquote>
						<blockquote>
							<ol>
								<li><font size="2" face="Courier New"><b>ipkg install 
			http://ftp.berlios.de/pub/xwrt/packages/webif_0.3-2_mipsel.ipk</b></font></li>
							</ol>
						</blockquote>
					</blockquote></td>
				</tr>
			</table>
			<blockquote>
				<blockquote>
					<p><i>Conflicts? If you get a conflict error you may need to add '-force-overwrite'. 
		If you have problems accessing some or all pages, reboot your router to 
		force the httpd to be restart, or run 'killall httpd; 
		/etc/init.d/S50httpd'.</i></p>
					<p>&nbsp;</p>
				</blockquote>
			</blockquote>
			<ul>
				<li><b><font size="4"><u>Method #2</u>: </font></b>Flash 
				pre-built OpenWrt White Russian images that already contain 
				X-Wrt packages. 
				<blockquote>
					<ol>
						<li>Download firmware images from here:
						<a href="ftp://ftp.berlios.de/pub/xwrt/images/">ftp://ftp.berlios.de/pub/xwrt/images/</a> . They may be in a 7z 
				archive, which you should download and extract with compatible 
				software like <a href="http://www.7zip.org">7-Zip</a>. </li>
						<li>Once you've extracted the images, flash the squashfs 
						image appropriate to your router by following the 
						instructions on <a href="http://wiki.openwrt.org">OpenWrt's wiki</a>. 
						(<b>note:</b> X-Wrt does not use JFFS2 only images since our 
						squashfs images make use of a filesystem that make the 
						root appear writable, making JFFS2 only images less than 
						necessary).</li>
					</ol>
					<p>&nbsp;</p>
				</blockquote>
				</li>
			</ul>
			<ul>
				<li><b><font size="4"><u>Method #3</u>: </font></b>Build your 
				own OpenWrt images with X-Wrt packages pre-installed. The 
				OpenWrt image builder allows you to easily do this. You can also 
				use the X-Wrt image builder, which may be more convenient since 
				X-Wrt packages are already in the repository.</li>
			</ul>
<p><br />
&nbsp;</p>
			<p><font size="5" color="#666699"><b>I want to help!</b></font></p>
<p>Great! We really need developers, translators, documentation writers, testers, and plain users ;). Join the 
effort by visiting our forums or emailing
<a href="mailto:jeremy@bitsum.com">jeremy@bitsum.com</a>. </p>
			<p>&nbsp;</td>
		</tr>
		<tr>
			<td align="left">&nbsp;</td>
		</tr>
	</table>
</div>
<p align="center"><font color="#FFFFFF">(c)2006 Jeremy Collake / X-Wrt Project</font></p>
</body>
</html>
