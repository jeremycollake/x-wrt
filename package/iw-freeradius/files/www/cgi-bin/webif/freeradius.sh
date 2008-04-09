#!/usr/bin/lua
--[[
##WEBIF:name:IW:250:Freeradius
]]--
dofile("/usr/lib/webif/LUA/config.lua")
local chillispot_pkg = pkgInstalledClass.new("libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("radius")
radius.set_menu()
--require("files/freeradius-menu")
local option = string.trim(__FORM.option)
local forms = {}
if option == "users" then
  __WIP = 4
  page.title = tr("Freeradius Users")
  forms[#forms+1] = radius.defaul_user_form()
  forms[#forms+1] = radius.user_form()
elseif option == "proxy" then
  __WIP = 4
  page.title = tr("Freeradius Proxy")
  forms[#forms+1] = radius.proxy_settings_form()
  forms[#forms+1] = radius.community_form()
elseif option == "client" then
  __WIP = 4
  page.title = tr("Freeradius Clients")
  forms[#forms+1] = radius.client_form()
else
  __WIP = 4
  page.title = "Freeradius Settings"
  forms[#forms+1] = radius.core_form()
end
print(page:header())
for i=1, #forms do
  forms[i]:print()
end
print (page:footer())
