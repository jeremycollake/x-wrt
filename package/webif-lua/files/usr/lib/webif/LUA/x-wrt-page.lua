--------------------------------------------------------------------------------
-- x-wrt-page.lua
--
-- Description: library of framework
--      library to render pages like X-WRT
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
pageClass = {} 
pageClass_mt = {__index = pageClass} 

function pageClass.new (title) 
	local self = {}
	self["title"] = tr(title)
	self["body"] = "<body>"
--	self["menu"] = menu:tohtml()
--	self["savebutton"] ="<div class=\"page-save\"><input type=\"submit\" name=\"__ACTION\" value=\""..tr("Save Changes").."\" /></div></form>"
--	self["action_applay"]  = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=applay_changes]] ..[[" >]]..tr("Apply Changes")..[[ &laquo;</a>]]
--	self["action_clear"]  = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=clear_changes]] ..[[" >]]..tr("Clear Changes")..[[ &laquo;</a>]]
--	self["action_review"] = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=review_changes]]..[[" >]]..tr("Review Changes")..[[ (]]..config.updated.count..[[) &laquo;</a>]]
--	if __FORM.__menu ~= nil then __options = "<input type=\"hidden\" name=\"menu\" value=\""..__FORM.__menu.."\" />" else __options="" end
--	self["form"]="<form enctype=\"multipart/form-data\" action=\""..__SERVER.SCRIPT_NAME.."\" method=\"post\"><input type=\"hidden\" name=\"submit\" value=\"1\" />"..__options
	self["savebutton"]    = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Save Changes").."\" />"
	self["action_applay"] = nil
	self["action_clear"]  = nil
	self["action_review"] = nil
	self["form"]          = [[<form enctype="multipart/form-data" action="]]..__SERVER.SCRIPT_NAME..[[" method="post">]]
--	self.form = self.form .. [[<input type="hidden" name="submit" value="1" />]]


	setmetatable(self,pageClass_mt) 
	self:Init()
	return self 
end 

function pageClass:Init()
	if __FORM.__ACTION=="clear_changes"  then __UCI_UPDATED:clear(self)  end
	if __FORM.__ACTION=="applay_changes" then __UCI_UPDATED:applay(self) end
	if __FORM.__ACTION=="review_changes" then __UCI_UPDATED:review(self) end
--	if __FORM.__ACTION==tr("Save Changes") then config:save(self) end
end

function pageClass:print()
	print (header)str = self:startForm()
	str = str + self:endForm()
	return str
end

function pageClass:header()
local header = [[
Content-Type: text/html; charset=UTF-8
Pragma: no-cache

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>]]..self.title.." "..__SYSTEM.general.firmware_name..tr("Administrative Console")..[[</title>
	<link rel="stylesheet" type="text/css" href="/themes/active/waitbox.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css" />
	<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_white.css" title="white" />
	<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_brown.css" title="brown" />
	<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_green.css" title="green" />
	<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_navyblue.css" title="navyblue" />
	<link rel="alternate stylesheet" type="text/css" href="/themes/active/color_black.css" title="black" />
	<!--[if lt IE 7]>
		<link rel="stylesheet" type="text/css" href="/themes/active/ie_lt7.css" />
	<![endif]-->
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta http-equiv="expires" content="-1" />
	<script type="text/javascript" src="/js/styleswitcher.js"></script>
</head>
]] .. self.body .. [[
<div id="container">
<div id="header">
	<em>]]..tr("making_usable#End user extensions for OpenWrt")..[[</em>
	<h1>]]..tr("X-Wrt Administration Console")..[[</h1>
	<div id="short-status">
		<h3><strong>]]..tr("Status")..[[ :</strong></h3>
		<ul>
			<li><strong> ]].. __SYSTEM.general.firmware_name.." "..__SYSTEM.general.firmware_version..[[</strong></li>
			<li><strong>]]..tr("Host")..[[ :</strong> ]]..__SYSTEM.hostname..[[</li>
			<li><strong>]]..tr("Uptime")..[[ :</strong> ]]..__SYSTEM.uptime..[[</li>
			<li><strong>]]..tr("Load")..[[ :</strong> ]]..__SYSTEM.loadavg..[[</li>
		</ul>
	</div>
</div>
]].. __MENU:tohtml() ..[[
<div id="colorswitcher">
	<div style="background: #000000" title="black" onclick="setActiveStyleSheet('black'); return false;"></div>
	<div style="background: #192a65" title="navyblue" onclick="setActiveStyleSheet('navyblue'); return false;"></div>
	<div style="background: #114488" title="blue" onclick="setActiveStyleSheet('default'); return false;"></div>
	<div style="background: #2b6d21" title="green" onclick="setActiveStyleSheet('green'); return false;"></div>
	<div style="background: #e8ca9e" title="brown" onclick="setActiveStyleSheet('brown'); return false;"></div>
	<div style="background: #fff" title="white" onclick="setActiveStyleSheet('white'); return false;"></div>
</div>
]]
if __SYSTEM.general.use_progressbar == 1 then 
	header = header .. [[
	<script type="text/javascript">start=0; end=10</SCRIPT>
	<script src="/js/pageload.js" type="text/javascript"></SCRIPT>
	<div id="loadmain">
	<script type="text/javascript">document.getElementById(\"loadmain\").style.display = \"none\";</script>";
	_JSload="<script type='text/javascript'>load()</script>
]]
else header = header ..  "<script type=\"text/javascript\">function load() { }</script>\n" end

header = header..self.form..[[

<div id="content">
	<h2>]]
if self.image ~= nil then
	header = header .. "<img src=\""..self.image.."\" />&nbsp;"..tr(self.title).."</h2>"
else
	header = header ..tr(self.title).."</h2>"
end

return header
end

function pageClass:footer()
	local key, val = "", "" 
	local str = "<div class=\"page-save\">"
--	str = str .. [[<input type="hidden" name="__PREVIUS_PAGE" value="]]..menu.selected..[[" />]]
	for line in string.gmatch(__MENU.selected,"[^&]+") do
		key, val = unpack(string.split(line,"="))
		key = string.trim(key)
		val = string.trim(val)
--		print ("<br>",key,val)
		str = str .. [[<input type="hidden" name="]]..key..[[" value="]]..val..[[" />]]
	end
	if self.savebutton == nil then
		self.savebutton = str.."<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Save Changes").."\" />".."</div>"
	elseif self.savebutton ~= "" then
		self.savebutton = str..self.savebutton.."</div>"
	end

	if self.action_applay == nil then
		self.action_applay = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=applay_changes&]]..__MENU.selected..[[" >]]..tr("Apply Changes")..[[ &laquo;</a>]]
	elseif self.action_applay ~= "" then
		if string.match(self.action_applay,"?") then
			self.action_applay = string.gsub(self.action_applay,"?","?"..__MENU.selected.."&")
		else
			self.action_applay = self.action_applay.."?"..__MENU.selected
		end
	end

	if self.action_clear == nil then
		self.action_clear = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=clear_changes&]]..__MENU.selected..[[" >]]..tr("Clear Changes")..[[ &laquo;</a>]]
	elseif self.action_clear ~= "" then
		if string.match(self.action_clear,"?") then
			self.action_clear = string.gsub(self.action_clear,"?","?"..__MENU.selected.."&")
		else
			self.action_clear = self.action_clear.."?"..__MENU.selected
		end
	end

	if self.action_review == nil then
		self.action_review = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=review_changes&]]..__MENU.selected..[[" >]]..tr("Review Changes")..[[ (]]..__UCI_UPDATED.count..[[) &laquo;</a>]]
	elseif self.action_review ~= "" then
		if string.match(self.action_review,"?") then
			self.action_review = string.gsub(self.action_review,"?","?"..__MENU.selected.."&")..[[ (]]..__UCI_UPDATED.count..[[) &laquo;</a>]]
		else
			self.action_review = self.action_review.."?"..__MENU.selected..[[ (]]..__UCI_UPDATED.count..[[) &laquo;</a>]]
		end
	end
local footer = [[
</div>
<br />
<fieldset id="save">
	<legend><strong>]]..tr("Proceed Changes")..[[</strong></legend>
]]
if self.form ~= nil and self.form ~= "" then footer = footer..tr(self.savebutton) end
--
--	equal "$_use_progressbar" "1" && {
--	echo '<script type="text/javascript" src="/js/waitbox.js"></script>'
--	}
if tonumber(__SYSTEM.general.use_progressbar) == 1 then footer = footer .. '<script type="text/javascript" src="/js/waitbox.js"></script>' end
if __UCI_UPDATED.count > 0 then
footer = footer ..[[
	<ul class="apply">
		<li>]]..self.action_applay..[[</li>
		<li>]]..self.action_clear..[[</li>
		<li>]]..self.action_review..[[</li>
	</ul>
]]
end
-- $_endform
footer = footer ..[[

</fieldset>
]]
if self.form ~= nil and self.form ~= "" then footer = footer.."</form>" end
footer = footer ..[[

<hr />
<div id="footer">
	<h3>X-Wrt</h3>
	<em>]]..tr("making_usable#End user extensions for OpenWrt")..[[</em>
</div>
</div> <!-- End #container -->
</body>
</html>
]]
return footer

end