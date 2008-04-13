<?php
/* Fetch the news from SMF */
require_once 'includes/rss_fetch.inc';
$rss = fetch_rss('http://forum.x-wrt.org/index.php/board,3.0.html?type=rss;action=.xml');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>
      Web interface for OpenWrt and more - X-Wrt.org
    </title>
    <link rel="stylesheet" type="text/css" href="/cssjs/style.css" />
  </head>
  <body>
    <div id="header">
      <h1>
        X-Wrt
      </h1><em>OpenWrt for end users</em>
    </div>
    <div id="mainnav">
      <h2>
        Navigation:
      </h2>
      <ul>
        <li class="active">
          <a href="./">Home</a>
        </li>
        <li>
          <a href="about.html">About</a>
        </li>
        <li>
          <a href="install.html">Downloads/Install</a>
        </li>
        <li>
          <a href="support.html">Support</a>
        </li>
        <li>
          <a href="contribute.html">Contribute</a>
        </li>
      </ul>
    </div>
	 <div id="leftmarginal" class="small">
	 <h2>Sitemap</h2>
	 <p>This list provides a quick entry to all the new pages on our Website:</p>
	  <ul class="sitemap">
        <li><a href="./">Home</a>
        </li>
        <li><a href="about.html">About</a>
          <ul>
            <li><a href="about/links.html">Project Links</a>
            </li>
            <li><a href="about/roadmap.html">Roadmap</a>
            </li>
            <li><a href="about/license.html">License</a>
            </li>
            <li class="last"><a href="about/developers.html">Developers</a>
            </li>
          </ul>
        </li>
        <li><a href="install.html">Downloads/Install</a>
        </li>
        <li><a href="support.html">Support</a>
          <ul>
            <li><a href="http://wiki.x-wrt.org">Wiki</a>
            </li>
            <li><a href="http://forum.x-wrt.org">Forum</a>
            </li>
            <li class="last"><a href="irc://irc.freenode.net/#x-wrt">IRC</a>
            </li>
          </ul>
        </li>
        <li><a href="contribute.html">Contribute</a>
        </li>
      </ul>
	 </div>
    <div id="content">
	   <h1>
        About X-Wrt
      </h1><p><strong>X-Wrt</strong> is a set of packages and patches to enhance the end user experience of OpenWrt. It is NOT a fork of OpenWrt.
        We work in conjunction with the OpenWrt developers to extend OpenWrt.</p>
	<p>
        Our packages currently work with the latest public release of OpenWrt, Kamikaze 7.09, and the previous release, White Russian.
        The packages for White Russian are the most stable, and we provide updated Whiterussian images with X-Wrt preinstalled. We also provide Kamikaze
        images with X-Wrt preinstalled. Please see the Downloads/Install page for more information.
	</p>
	<p>More on the <a href="about.html">about page</a></p>

	 <h1>News</h1>
<?php	foreach ($rss->items as $item ) { echo "
		<h2>" . $item[title] . "</h2>
		<em>" . date("l dS of F Y h:i:s A", $item[date_timestamp]) . "</em>
		<p>" . $item[description] . "</p>"; } ?>
    </div>
    <div id="footer">
      <hr />
      &copy; X-Wrt project 2007-2008
      <br />
      <a href="#mainnav">back to top</a> | <a href="sitemap.html">Sitemap</a>
    </div>
  </body>
</html>
