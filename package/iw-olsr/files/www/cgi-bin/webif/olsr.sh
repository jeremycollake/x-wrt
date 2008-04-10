#!/usr/bin/lua
--[[
##WEBIF:name:IW:400:OLSR
]]--
dofile("/usr/lib/webif/LUA/config.lua")
local olsr_pkg = pkgInstalledClass.new("olsrd",true)
require("olsr")
--olsr = uciClass.new("olsr")
forms = {}
olsrd.set_menu()
local option = string.trim(__FORM.option)
page.title = "OLSR Settings"
if option == "" then option = "service" end
if option == "service" then
  forms[1] = olsrd.core_form()
elseif option == "general" then
  forms[1] = olsrd.general_form()
elseif option == "hna4" then
  forms[1] = olsrd.hna4_form()
elseif option == "interfaces" then
  forms[1] = olsrd.interfaces_form()
else
  form.title = __FORM.option.." ".. form.title
end
print(page:header())
forms[#forms]:Add_help_link("http://www.olsr.org","About OLSR" )
for i=1, #forms do
  forms[i]:print()
end
print(page:footer())
