#!/usr/bin/lua
--[[
##WEBIF:name:IW:250:Freeradius
]]--
--dofile("/usr/lib/webif/LUA/config.lua")
require("init")
local chillispot_pkg = pkgInstalledClass.new("libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)

require("radius")
radius.set_menu()

local option = string.trim(__FORM.option)
local forms = {}
page.title = tr("Freeradius")
__WIP = 4

if option == "users" then
--  page.title = tr("Freeradius Users")
--  forms[#forms+1] = radius.defaul_user_form()
  forms[#forms+1] = radius.add_usr_form()
--  radius.add_usr_form(forms[#forms])
  forms[#forms+1] = radius.user_form()
elseif option == "users_default" then
  forms[#forms+1] = radius.defaul_user_form()
elseif option == "proxy" then
--  page.title = tr("Freeradius Proxy")
  forms[#forms+1] = radius.proxy_settings_form()
elseif option == "communities" then
--  page.title = tr("Freeradius Proxy")
  forms[#forms+1] = radius.community_form()
elseif option == "client" then
  forms[#forms+1] = radius.client_form()
else
  forms[#forms+1] = radius.core_form()
end
print(page:header())
for i=1, #forms do
  forms[i]:print()
end
print (page:footer())
