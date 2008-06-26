#!/usr/bin/lua
--------------------------------------------------------------------------------
-- coovachilli.sh
-- This script is writen in LUA, the extension is ".sh" for compatibilities
-- reasons width menu system of X-Wrt
--
-- Description:
--        Administrative console to Chillispot
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--         
-- Configuration files referenced:
--    hotspot
--
--------------------------------------------------------------------------------
--[[
##WEBIF:name:HotSpot:320:Coova-Chilli
]]--
-- config.lua 
-- LUA settings and load some functions files
-- 
--dofile("/usr/share/internet-wifi/set_path.lua")
require("set_path")
require("init")
require("coovaportal")
require("webpkg")
-- pageClass is part of the framework 
page.title = tr("chilli_main_title#Coova-Chilli")
cportal.set_menu()
__WIP=2
local forms = {}
__FORM.option = string.trim(__FORM.option)
if __FORM.option == "net" then
  forms[1] = cportal.net_form()
elseif __FORM.option == "uam" then
  forms[1] = cportal.uam_form()
elseif __FORM.option == "radius" then
  forms[1] = cportal.radius_form()
elseif __FORM.option == "nasid" then
  forms[1] = cportal.nasid_form()
elseif __FORM.option == "users" then
  pkg.check("iw-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm")
  require("radius")
  forms[1] = radius.add_usr_form()
  forms[2] = radius.user_form()
elseif __FORM.option == "communities" then
  require("radius")
  forms[1] = radius.community_form()
elseif __FORM.option == "connections" then
  page.savebutton = ""
  forms[1] = cportal.connect_form()
elseif __FORM.bt_pkg_install == "Install" then
  local freeradius_pkg = pkgInstalledClass.new("libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
else
  forms[1] = cportal.core_form()
end

print(page:header())
for i=1, #forms do
  forms[i]:print()
end
--[[
for i,v in pairs(__FORM) do
  print(i,v,"<br>")
end
]]--
print (page:footer())
