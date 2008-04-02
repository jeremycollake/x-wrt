#!/usr/bin/lua
--[[
##WEBnoIF:name:IW:300:OLSR
]]--
dofile("/usr/lib/webif/LUA/config.lua")
-- local olsr_pkg = pkgInstalledClass.new("olsrd",true)
-- olsr = uciClass.new("olsr")
require("files/olsr-menu")
__WIP = 0
page.title = "OLSR Visualization"
page.__DOCTYPE = ""
page.form = ""
print(page:header())
print ([[
<NOSCRIPT>
<H1>OLSR Viz</H1>
<TABLE BORDER="0" CLASS="note"><TR><TD>No JavaScript - no Viz.</TD></TR>
</TABLE>
<P>&nbsp;</P></NOSCRIPT>
<SCRIPT SRC="/js/olsr-viz.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>

<DIV ID="main" STYLE="width: 100%; height: 400px; border: 1px solid #ccc; margin-left:auto; margin-right:auto; text-align:center; overflow: scroll">
  <DIV ID="edges" STYLE="width: 1px; height: 1px; position: relative; z-index:2"></DIV>
  <DIV ID="nodes" STYLE="width: 1px; height: 1px; position: relative; z-index:4"></DIV>
</DIV>
<DIV STYLE="z-index:99">
<FORM ACTION="">
<P><B TITLE="Defines the display magification.">Zoom</B>&nbsp;
<A HREF="javascript:set_scale(scale+0.1)">+</A>&nbsp;
<A HREF="javascript:set_scale(scale-0.1)">&ndash;</A>&nbsp;
<INPUT ID="zoom" NAME="zoom" TYPE="text" VALUE="2.0" SIZE="5" ONCHANGE="set_scale()">&nbsp;&nbsp;
<B TITLE="Limits the view to a maximal hop distance.">Metric</B>&nbsp;
<A HREF="javascript:set_maxmetric(maxmetric+1)">+</A>&nbsp;
<A HREF="javascript:if(0<maxmetric)set_maxmetric(maxmetric-1)">&ndash;</A>&nbsp;
<INPUT ID="maxmetric" NAME="maxmetric" TYPE="text" VALUE="3" SIZE="4" ONCHANGE="set_maxmetric(this.value)">&nbsp;&nbsp;
<B TITLE="Enables the automatic layout optimization.">Optimization</B>
<INPUT ID="auto_declump" NAME="auto_declump" TYPE="checkbox" ONCHANGE="set_autodeclump(this.checked)" CHECKED="CHECKED">&nbsp;&nbsp;
<B TITLE="Show hostnames.">Hostnames</B>
<INPUT ID="show_hostnames" NAME="show_hostnames" TYPE="checkbox" ONCHANGE="set_showdesc(this.checked)" CHECKED="CHECKED">&nbsp;&nbsp;
<A HREF="javascript:viz_save()" TITLE="Saves the current settings to a cookie.">Save</A>&nbsp;&nbsp;
<A HREF="javascript:viz_reset()" TITLE="Restarts the Viz script.">Reset</A>
</P>
</FORM>
</DIV>
<P><SPAN ID="debug" STYLE="visibility:hidden;"></SPAN>
<IFRAME ID="RSIFrame" NAME="RSIFrame" STYLE="border:0px; width:0px; height:0px; visibility:hidden;">
</IFRAME>

<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
  viz_setup("RSIFrame","main","nodes","edges");
  viz_update();
</SCRIPT> </P>
]])
print (page:footer())
