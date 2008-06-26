#!/usr/bin/lua
--------------------------------------------------------------------------------
-- chillispot.sh
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
##WEBIF:name:HotSpot:310:Chilli Spot
]]--
-- config.lua 
-- LUA settings and load some functions files
-- 
require("set_path")
require("init")
require("chilliportal")
require("webpkg")
-- pageClass is part of the framework 
page.title = tr("chilli_main_title#Chilli Spot")
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
elseif __FORM.option == "access" then
  forms[1] = cportal.access_form()
elseif __FORM.option == "proxy" then
  forms[1] = cportal.proxy_form()
elseif __FORM.option == "scripts" then
  forms[1] = cportal.script_form()
elseif __FORM.option == "users" then
  require("webpkg")
  pkg.check("iw-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm")
  require("radius")
  forms[1] = radius.add_usr_form()
  forms[2] = radius.user_form()
elseif __FORM.option == "communities" then
    pkg.check("iw-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm")
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
for i,v in pairs(__SERVER) do
  print(i,v,"<br>")
end
for i,v in pairs(__FORM) do
  print(i,v,"<br>")
end
]]--
print (page:footer())
