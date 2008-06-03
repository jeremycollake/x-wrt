#!/usr/bin/lua
dofile("/usr/share/internet-wifi/set_path.lua")
require("init")
require("iw-uci")
chilli = uciClass.new("chilli")
--dofile("/usr/lib/webif/LUA/config.lua")
io.write([[
Content-Type: text/html;
Pragma: no-cache 
]])
io.write([[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head>
<title>X-Wrt for end users</title>
<link rel="stylesheet" type="text/css" href="http://]]..chilli.uam.HS_UAMSERVER..[[/themes/active/waitbox.css" media="screen" />
<link rel="stylesheet" type="text/css" href="http://]]..chilli.uam.HS_UAMSERVER..[[/themes/active/webif.css" />
<SCRIPT SRC="http://]]..chilli.uam.HS_UAMSERVER..[[:]]..chilli.uam.HS_UAMPORT..[[/www/ChilliLibrary.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
chilliController.host = ']]..chilli.uam.HS_UAMSERVER..[[';
chilliController.port = ]]..chilli.uam.HS_UAMPORT..[[;

</SCRIPT>

<SCRIPT SRC="http://]]..chilli.uam.HS_UAMSERVER..[[:]]..chilli.uam.HS_UAMPORT..[[/www/chilliController.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript" >
</SCRIPT>

<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
setTimeout('chilliController.refresh()', 0);
</SCRIPT>

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
local chilliwww = "http://"..chilli.uam.HS_UAMSERVER..":"..chilli.uam.HS_UAMPORT
tmpl = string.gsub(tmpl,"CHILLIWWW",chilliwww) 
print( tmpl )
print("</body></html>")
