#!/usr/bin/lua
require("init")
--dofile("/usr/lib/webif/LUA/config.lua")
io.write([[
Content-Type: text/html;
Pragma: no-cache 
]])
io.write([[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head>
<title>X-Wrt for end users</title>
<link rel="stylesheet" type="text/css" href="http://192.168.182.1/themes/active/waitbox.css" media="screen" />
<link rel="stylesheet" type="text/css" href="http://192.168.182.1/themes/active/webif.css" />
<SCRIPT SRC="http://192.168.182.1:3990/www/ChilliLibrary.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>
<!--
<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript>
chilliController.host = '192.168.182.1';
chilliController.port = 3990;
</SCRIPT>
-->
<SCRIPT SRC="http://192.168.182.1:3990/www/chilliController.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>
<!--
<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript>
setTimeout('chilliController.refresh()', 0);
</SCRIPT>
-->
</head>
<body>
<div id="container"> 
<div id="header"><h1>X-Wrt</h1>
<em>OpenWrt for end users</em>
<div id="mainmenu">
</div>
</div>
]])
local tmpl = load_file("/etc/chilli/www/json_html.tmpl") 
print( tmpl )
print("</body></html>")
