--------------------------------------------------------------------------------
-- htmlpageClass.lua
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--
--------------------------------------------------------------------------------
--
--	usage : page = xwrtpageClass.new(title_of_page)
--	page instances
--		page.content_type		(get or set) default value come from htmlpageClass
--		page.doc_type				(get or set) default value come from htmlpageClass
--		page.html						(get or set) default value come from htmlpageClass
--		page.head						(get or set)
--		page.head.title			(get or set)
--		page.head.links			(get or set)
--		page.head.metas			(get or set)
--		page.head.scripts		(get or set)
--		page.body						(get or set)
--		page.container			(get or set)
--		page.container.header
--		page.container.content
--		page.content = page.container.content (this is a shortcat to real instance )
--		page.savebutton
--		page.action_apply
--		page.action_clear
--		page.action_review
--		page.image
--	page functions
--		page.head.links:add({rel="stylesheet",type="text/css",href="/path/to/file.css", media="screen", ......})
--			or you can set it page.head.links = [[<link rel="stylesheet" type="text/css" href="/themes/active/waitbox.css" media="screen" />
--	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css" />
--	]]
--				but this way destroy the page.head.links:add(...) funtions.
--		also you can set page.head = [[
--<head>
--<title>System - OpenWrt Kamikaze Administrative Console</title>
--	<link rel="stylesheet" type="text/css" href="/themes/active/waitbox.css" media="screen" />
--	<link rel="stylesheet" type="text/css" href="/themes/active/webif.css" />
--	
--	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
--	<meta http-equiv="expires" content="-1" />
--	<script type="text/javascript" src="/js/styleswitcher.js"></script>
--</head>
--]]
--			but this way destroy all page.head instances and funtions to add values in dinamic way
--
--		page.head.metas:add({["http-equiv"] = "Content-Type", content = [[text/html; charset=UTF-8]], ......})
--		page.head.metas:add({["http-equiv"] = "Content-Type", content = [[text/html; charset=UTF-8]], ......})
--		page.container:add("add html code to container")
--
--------------------------------------------------------------------------------
require("htmlClass")

xwrtpageClass = htmlpageClass

function xwrtpageClass:init()
	self.head.title = self.title .. " - "..__SYSTEM.general.firmware_name.." "..tr("Administrative Console") 
	self["savebutton"]    = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Save Changes").."\" />"
	self["action_apply"] = nil
	self["action_clear"]  = nil
	self["action_review"] = nil
	self["image"] = nil
	if __SERVER then
	self["form"] = [[<form enctype="multipart/form-data" action="]]..__SERVER.SCRIPT_NAME..[[" method="post">
	]]
	end
	self.head.links:add({rel="stylesheet", type="text/css", href="/themes/active/waitbox.css", media="screen"})
	self.head.links:add({rel = "stylesheet", type = "text/css", href = "/themes/active/webif.css"})
	self.head.scripts:add({	type="text/javascript", src="/js/styleswitcher.js"})
	self.head.metas:add({
				{ ["http-equiv"] = "Content-Type", content = [[text/html; charset=UTF-8]]},
				{ ["http-equiv"] = "expires", content = "-1" }
			})
	self.container:add(htmlsectionClass.new("div","header"))
	self.container.header:add(self:set_header())

	self.container:add(self:set_menu())

	if uci.get("webif.general.use_progressbar") == "1" then
		self.container:add([[
<SCRIPT type='text/javascript'>
start=0; 
end=5;
</SCRIPT>
<SCRIPT src='/js/pageload.js' type='text/javascript'></SCRIPT>
<DIV id='loadmain'>
<SCRIPT type='text/javascript'>document.getElementById("loadmain").style.display = "none";</SCRIPT>
]])
		self.container:add([[<script type="text/javascript" src="/js/waitbox.js"></script>]])
		self.container:add([[</DIV> <!-- loadmain -->]])
	end

	if self.form then
		self.container:add(self.form)
	end

	self.container:add(htmlsectionClass.new("div","content"))
	self.container.content:add(self:set_content())

	self.container:add(self:set_footer())

	self.content = self.container.content
end

--------------------------------------------------------------------------------
-- functions to set defaults values of header, content and footer or x-wrt page
--------------------------------------------------------------------------------
function xwrtpageClass:set_header()
	return function()
					return [[
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
]]
				end
end

function xwrtpageClass:set_menu()
	return	function()
						return __MENU:text()
					end
end

function xwrtpageClass:set_content()
	return function()
					local str = "<h2>"
					if self.container.content.image then
						str = str .."<img src=\""..self.container.content.image.."\" alt=\""..tr(self.title).."\" />&nbsp;"..tr(self.title)
					else
						str = str .. tr(self.title)
					end
					str = str .."</h2>\n"
--					self.container.content:add(str)
--					if __WIP ~= nil and __WIP >0 then self.container.content:add("<h3 CLASS=\"warning\"> "..tr(__WORK_STATE[__WIP]).."</h3>") end
					return str 
				end
end

function xwrtpageClass:set_footer()
	return function ()
  local uci_count = uci.updated()
	local str = "<div class=\"page-save\">"
	for line in string.gmatch(__MENU.selected,"[^&]+") do
    line = string.trim(string.gsub(line,"amp;",""))
    local _, _, key, val = string.find(line,"(.+)%s*=%s*(.+)")
		str = str .. [[<input type="hidden" name="]]..key..[[" value="]]..val..[[" />]]
	end
	if self.savebutton == nil then
		self.savebutton = str.."<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Save Changes").."\" />".."</div>"
	elseif self.savebutton ~= "" then
		self.savebutton = str..self.savebutton.."</div>"
	end

	if self.action_apply == nil then
		self.action_apply = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=apply_changes]]..__MENU.selected..[["  rel="lightbox" >]]..tr("Apply Changes")..[[ &laquo;</a>]]
	elseif self.action_apply ~= "" then
		if string.match(self.action_apply,"?") then
			self.action_apply = string.gsub(self.action_apply,"?","?"..__MENU.selected.."&")
		else
			self.action_apply = self.action_apply.."?"..__MENU.selected
		end
	end

	if self.action_clear == nil then
		self.action_clear = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=clear_changes]]..__MENU.selected..[[" >]]..tr("Clear Changes")..[[ &laquo;</a>]]
	elseif self.action_clear ~= "" then
		if string.match(self.action_clear,"?") then
			self.action_clear = string.gsub(self.action_clear,"?","?"..__MENU.selected.."&")
		else
			self.action_clear = self.action_clear.."?"..__MENU.selected
		end
	end

	if self.action_review == nil then
		self.action_review = [[<a href="]]..__SERVER.SCRIPT_NAME.. [[?__ACTION=review_changes]]..__MENU.selected..[[" >]]..tr("Review Changes")..[[ (]]..uci_count..[[) &laquo;</a>]]
	elseif self.action_review ~= "" then
		if string.match(self.action_review,"?") then
			self.action_review = string.gsub(self.action_review,"?","?"..__MENU.selected.."&")..[[ (]]..uci_count..[[) &laquo;</a>]]
		else
			self.action_review = self.action_review.."?"..__MENU.selected..[[ (]]..uci_count..[[) &laquo;</a>]]
		end
	end
local footer = [[
<br />
<fieldset id="save">
	<legend><strong>]]..tr("Proceed Changes")..[[</strong></legend>
]]
if self.form ~= nil and self.form ~= "" then footer = footer..tr(self.savebutton) end

footer = footer .. [[
	<ul class="apply">
]]
if uci_count > 0 then
footer = footer ..[[
		<li>]]..self.action_apply..[[</li>
		<li>]]..self.action_clear..[[</li>
		<li>]]..self.action_review..[[</li>
]]
end
footer = footer .. [[
	</ul>
]]

footer = footer ..[[

</fieldset>
]]
if self.form ~= nil and self.form ~= "" then footer = footer.."</form>" end
footer = footer ..[[

<hr />
<div id="footer">
	<h3>X-Wrt</h3>
	<em>]]..tr("making_usable#End user extensions for OpenWrt")..[[</em>
</div>]]
return footer
	end
end
