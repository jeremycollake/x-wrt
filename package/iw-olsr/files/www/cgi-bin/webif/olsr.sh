#!/usr/bin/lua
--[[
##WEBIF:name:HotSpot:120:OLSR
]]--
--dofile("/usr/share/internet-wifi/set_path.lua")
require("set_path")
require("init")
require("webpkg")
pkg.check("ip olsrd olsrd-mod-dyn-gw olsrd-mod-nameservice olsrd-mod-txtinfo")

require("olsr")
--olsr = uciClass.new("olsr")
forms = {}
__WIP=2
olsrd.set_menu()
local option = string.trim(__FORM.option)
page.title = "OLSR"
local str_content = ""
if option == "" then option = "service" end
if option == "service" then
  forms[1] = olsrd.core_form()
elseif option == "general" then
  forms[1] = olsrd.general_form()
elseif option == "hna4" then
  forms[1] = olsrd.hna4_form()
elseif option == "interfaces" then
  forms[1] = olsrd.interfaces_form()
elseif option == "status" then
  page.__DOCTYPE = ""
  page.form = ""
  forms[1] = olsrd.status_form()
elseif option == "viz" then
  __WIP = 0
  page.__DOCTYPE = ""
  page.form = ""
--  forms[1] = olsrd.viz_form()
  str_content = olsrd.viz_form()
else
  form.title = __FORM.option.." ".. form.title
end
print(page:header())
print(str_content)
forms[#forms]:Add_help_link("http://www.olsr.org","About OLSR" )
if #forms > 0 then
  for i=1, #forms do
    forms[i]:print()
  end
end
print(page:footer())
