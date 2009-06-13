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
##WEBIF:name:HotSpot:410:Coova-Chilli
]]--
-- config.lua 
-- LUA settings and load some functions files
-- 
require("set_path")
require("init")
require("coovaportal")
require("webpkg")
-- pageClass is part of the framework 
page.title = "Coova-Chilli"
cportal.set_menu()
__WIP=4
local forms = {}
__FORM.option = string.trim(__FORM.option) or ""
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
  pkg.check("webif-iw-lua-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm")
  require("radius")
  forms[1] = radius.add_usr_form()
  forms[2] = radius.user_form()
elseif __FORM.option == "communities" then
    pkg.check("webif-iw-lua-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm")
    require("radius")
    forms[1] = radius.community_form()
elseif __FORM.option == "connections" then
  page.savebutton = ""
  forms[1] = cportal.connect_form()
elseif __FORM.option == "pages" then
  forms[#forms+1] = cportal.pages_form()
  forms[#forms+1] = cportal.add_page_form()
elseif __FORM.option == "login" then
  forms[#forms+1] = cportal.login_form()
elseif __FORM.option == "edit" then
  forms = cportal.edit_page_form(nil,__FORM.page)
--elseif __FORM.bt_pkg_install == "Install" then
--  local freeradius_pkg = pkgInstalledClass.new("libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
else
  forms[1] = cportal.core_form()
end

print(page:header())
for i=1, #forms do
  forms[i]:print()
end
--[[
for m,n in pairs(forms[1]) do
  print(m,n,"<br>")
  for u,v in pairs(n) do
    print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",u,v,"<br>")
  end
end
]]--
--[[
for i,v in pairs(__SERVER) do
  print(i,v,"<br>")
end
for i,v in pairs(__FORM) do
  print(i,v,"<br>")
end
]]--
print (page:footer())
