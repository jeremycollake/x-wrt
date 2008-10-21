#!/usr/bin/lua
require("set_path")
require("uci_iwaddon")
require("init")
require("common")
local extrahead = [[
<SCRIPT SRC="/js/ChilliLibrary.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
chilliController.host = ']]..uci.get("coovachilli","settings","HS_UAMSERVER")..[[';
chilliController.port = ]]..uci.get("coovachilli","settings","HS_UAMPORT")..[[;
</SCRIPT>
<SCRIPT SRC="/js/chilliController.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
setTimeout('chilliController.refresh()', 0);
</SCRIPT>

]]
local uamPort = uci.get("coovachilli","settings","HS_UAMPORT") or "3990"
local uamServer = uci.get("coovachilli","settings","HS_UAMSERVER") or "192.168.182.1"
page.savebutton = ""
page.action_apply = ""
page.action_clear = ""
page.action_review = ""
--page.extrahead = extrahead
if tonumber(uci.get("coovachilli","homepage","redirect")) > 0 then
	page.redirect=[[<meta http-equiv="refresh" content="]]..uci.get("coovachilli","homepage","redirect")..[[; URL=http://]]..uamServer..[[:]]..uamPort..[[/prelogin">]]
end
__MENU:Add("Go to Internet",[[http://]]..uamServer..[[:]]..uamPort..[[/prelogin]])
__MENU:Add("Info","home.lua")
__MENU.Info = menuClass.new()
__MENU.Info:Add("Wellcome","home.lua?option=wellcome&load=about.tmpl")
__MENU.Info:Add("Owner","home.lua?option=owner")
__MENU.Info:Add("Location","home.lua?option=location")
page.title = uci.get("coovachilli","settings","HS_LOC_NAME")    
local option = string.trim(__FORM.option)
local load   = string.trim(__FORM.load)
if option == "" then
	load = "about.tmpl"
end
if load ~= "" then
	dofile(load)
end
print(page:header())
if option == "owner" then
	local form = formClass.new("Owner Data")
	form:Add("text","owner_name",uci.get("coovachilli","homepage","ownername"),tr("Name"))
	form:Add("text","owner_addres",uci.get("coovachilli","homepage","owneraddress"),tr("Address"))
	form:Add("text","owner_phone",uci.get("coovachilli","homepage","ownerphone"),tr("Phone"))
	form:print()
elseif option == "location" then
	local form = formClass.new("Location Data")
	form:Add("text","location_nasId",uci.get("coovachilli","settings","HS_NASID"),tr("Nas ID"))
	form:print()
else
	if useForm and useForm ~= "" then 
		local form = formClass.new(useForm)
		form:Add("text_line","html_code",htmlCode)
		form:print()
	else
		print(htmlCode)
	end
end
print(page:footer())