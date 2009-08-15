#!/usr/bin/lua
--------------------------------------------------------------------------------
-- mroute.sh
-- This script is writen in LUA, the extension is ".sh" for compatibilities
-- reasons width menu system of X-Wrt
--
-- Description:
--        Administrative console to configure load balancing route
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--         
-- Configuration files referenced:
--    mroute
--
--------------------------------------------------------------------------------
--[[
##WEBIF:name:Network:510:M-Routes
]]--
require("set_path")
require("init")
require("mroute")
require("webpkg")
-- pageClass is part of the framework 
	local mrState = uci.cursor(nil,"/var/state");
--	local lan_list = mrState:get_type("mroute","lanif")
--	local wan_list = mrState:get_type("mroute","wanif")
	local fstat = ""
	local wan_list = {}
	mrState:foreach("mroute","wanif",  function(section)
		wan_list[#wan_list+1] = section
		end)

	for w = 1, #wan_list do
		if wan_list[w]["status"] == "1" then
			fstat = fstat .. (wan_list[w]["name"] or wan_list[w][".name"] ).. " Routing by "..wan_list[w]["gateway"].."<br>"
		end
	end
	page.title = "Multi-Route"
--[[
	if #wan_list > 1 then
		page.title = "Multi-Route - "..fstat
	else
		page.title = "Multi-Route - "..fstat
	end
]]--	
--[[
local fstat, f = load_file("/var/run/mroute.active")
if f == false then
	f=io.popen("/etc/init.d/mroute status")
	for line in f:lines() do
		page.title = "Multi-Route is "..line
	end
else
	page.title = "Multi-Route - "..fstat
end
]]--

mroute.set_menu()
__WIP=2

if __FORM.__menu == nil then
  __FORM.__menu = "7:8"
end

__FORM.option = string.trim(__FORM.option) or ""
forms = {}
if __FORM.option == "status" then
--	forms[#forms+1] = mroute.status_form()
elseif __FORM.option == "ifaces" then
	forms[#forms+1] = mroute.interfaces_form()
elseif __FORM.option == "tuneup" then
	forms[#forms+1] = mroute.tuneup_form()
else
	forms[#forms+1] = mroute.core_form()
--	forms[#forms+1] = mroute.interfaces_form()
end

print(page:header())
for i=1, #forms do
  forms[i]:print()
end
--[[
for k, v in pairs(__FORM) do
	print(k,v,"<br>")
end
]]--
print (page:footer())
