#!/usr/bin/lua
--[[
##WEBIF:name:Status:982:OLSR
]]--
require("set_path")
require("init")
require("webpkg")
require("uci_iwaddon")
require("olsrdata")
local olsrdata = olsrdataClass.new()

if __FORM.__menu == nil then
  __FORM.__menu = "3:18"
end
require("olsr")
  __MENU.Status.OLSR = menuClass.new()
  __MENU.Status.OLSR:Add("Links","status-olsr.sh")
  __MENU.Status.OLSR:Add("Neighbors","status-olsr.sh?option=Neighbors")
  __MENU.Status.OLSR:Add("Topology","status-olsr.sh?option=Topology")
  __MENU.Status.OLSR:Add("HNA","status-olsr.sh?option=HNA")
  __MENU.Status.OLSR:Add("MID","status-olsr.sh?option=MID")
  __MENU.Status.OLSR:Add("Routes","status-olsr.sh?option=Routes")
  __MENU.Status.OLSR:Add("Visualization","status-olsr.sh?option=viz")
  __WIP = 0
  page.form = ""
local option = string.trim(__FORM.option)
page.title = "OLSR"
local forms = {}
local str_content = ""
if option == "viz" then
  __WIP = 0
  page.__DOCTYPE = ""
  page.form = ""
  str_content = olsrd.viz_form()
else
  if __FORM["option"] == nil then option = "Links" end 
  __WIP = 0
  forms[1] = olsrdata:htmlData(nil,option)    
end
print(page:header())
print(str_content)
if #forms > 0 then
  for i=1, #forms do
    forms[i]:print()
  end
end
print(page:footer())
