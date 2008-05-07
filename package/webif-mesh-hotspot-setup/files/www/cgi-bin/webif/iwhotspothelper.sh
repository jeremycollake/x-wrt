#!/usr/bin/lua
--[[
  iw-settings.sh
  This script is writen in LUA, the extension is ".sh" for compatibilities
  reasons width menu system of X-Wrt

  Description:
          Administrative console to configure hotspot with 
          Chillispot captive portal
          Freeradius Server Authorization and Accounting 
          OLSR Routing protocol for mesh Network

  Author(s) [in order of work date]:
         Fabián Omar Franzotti
         
    Configuration files referenced:
      iw_settings
      hotspot
      networks
      wireless
      hotspot
      freeradius
      freeradius_check
      freeradius_reply
      freeradius_client
      freeradius_proxy
]]--

--[[
##WEBIF:name:HotSpot:100:Wizard
]]--
-- config.lua 
-- LUA settings and load some functions files
-- 

require("init")
require("ipkg")
require("checkpkg")
require("iwuci")
local olsr_pkgs = "ip,olsrd,olsrd-mod-dyn-gw,olsrd-mod-nameservice,olsrd-mod-txtinfo,iw-olsr"
local freeradius_pkgs = "libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm,iw-freeradius"
local coova_pkgs = "coova-chilli,coova-chilli-xwrt"
local chilli_pkgs = "chillispot,iw-chillispot"

function setfooter(form)
  page.savebutton = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Next").."\" style=\"width:100px;\" />"
  page.action_apply = ""
  page.action_clear = ""
  page.action_review = ""
  form:Add("hidden","__ShowMenu","yes")
  form:Add("hidden","option","wizard")
end

function nothing()
    local forms = {}
    forms[1] = formClass.new(tr("Nothing to do !!!"))
    forms[1]:Add("text_line","nothing dfadf", tr("You would have to select something !!!"))
    setfooter(forms[1])
    page.savebutton = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Continue").."\" style=\"width:100px;\" />"
    forms[1]:Add("hidden","option","")
    return forms
end

function set_mesh(general)
  local forms = {}
  if tonumber(general.values.mesh) == 0 then
    forms = set_portal(general)
  else
    check = pkgInstalledClass.new(ipkg.check(olsr_pkgs),true)
    iwuci.set("olsr.webadmin.enable","1")
    iwuci.set("olsr.webadmin.userlevel","1")
    require("olsr")
    forms[1] = olsrd.core_form()
    forms[1].title = "Mesh Network Settings (OLSR)"
    forms[1]:Add("hidden","step","portal")
    setfooter(forms[1])
  end
  return forms
end 

function set_portal(general)
  local forms = {}
  if tonumber(general.values.portal) == 0 then
    forms = set_users(general)
  else
    check = pkgInstalledClass.new(coova_pkgs,true)
    iwuci.set("chilli.service","websettings") 
    iwuci.set("chilli.service.enable","1")
    iwuci.set("chilli.service.userlevel","1")
    require("coovaportal")
    local user_level = tonumber(general.values.user_level) or 0
    local localradius = tonumber(general.values.radius) or 0
    forms[1] = cportal.core_form()
    forms[1].title = "Coova Chilli Service"
--    forms[1] = formClass.new(tr("Captive Portal"))
--    cportal.net_form(forms[1],user_level)
--    cportal.radius_form(forms[1],user_level,localradius)
    setfooter(forms[1])
    forms[1]:Add("hidden","step","users")
  end
  return forms
end

function set_users(general)
  local forms = {}
  if tonumber(general.values.radius) == 0 then
    if tonumber(general.values.portal) == 1 then 
      general.values.radius = 2
    elseif tonumber(general.values.portal) == 2 then 
      general.values.radius = 3
    elseif tonumber(general.values.portal) == 3 then
      general.values.radius = 3
    end    
    iwuci.set("iw_hotspot_wizard.general.radius",general.values.radius)
  end
  if tonumber(general.values.radius) > 1 then
    check = pkgInstalledClass.new(freeradius_pkgs,true)
    require("radius")
    forms[1] = radius.add_usr_form()
    forms[2] = radius.user_form()
    setfooter(forms[1])
    forms[1]:Add("hidden","step","communities")
  else
    forms = set_communities(general)
  end
  return forms
end

function set_communities(general)
  local forms = {}
  if tonumber(general.values.radius) == 1
  or tonumber(general.values.radius) == 3 then -- Local Users
    check = pkgInstalledClass.new(freeradius_pkgs,true)
    require("radius")
    forms[1] = radius.community_form()
--    forms[2] = add_communities(general)
    setfooter(forms[1])
    forms[1]:Add("hidden","step","set_end")
  else
    return set_end(general)
  end
  return forms
end

function set_end(general)
  local forms = {}
  if tonumber(general.values.mesh) > 0 then
    forms[#forms+1] = formClass.new(tr("Mesh Network Configuration"))
	end
  if tonumber(general.values.portal) > 0 then
    forms[#forms+1] = formClass.new(tr("Captive portal configured"))
	end
  if tonumber(general.values.radius) > 0 then
    forms[#forms+1] = formClass.new(tr("Radius Server configured"))
	end
	return forms
end

local pkgs_tocheck = ""
local forms ={}

iw_hotspot = uciClass.new("iw_hotspot_wizard")
if iw_hotspot.general == nil then iw_hotspot:set("settings","general") end
local general = {}
general["name"] = iw_hotspot.__PACKAGE..".general"
general["values"] = iw_hotspot.general
-- require(".files/iwhotspothelper-menu")
for k,v in pairs(__FORM) do
  if k == "UCI_SET_VALUE" and string.trim(v) ~= "" then
    if __FORM.UCI_CMD_snwfreeradius_check then
      __FORM.step = "users"
      break
    end
  end
  if string.match(k,"UCI_CMD_delfreeradius") then
    __FORM.option = "wizard"
    __FORM.step = "radius"
    break
  end
end
__FORM.option = string.trim(__FORM.option)
if __FORM.option == "about" then
  forms[1] = about()
elseif __FORM.bt_pkg_install == "Install" then
  isntall = pkgInstalledClass.new("",true)
elseif __FORM.option == "config" then
  forms[1] = config() 
elseif __FORM.option == "wizard" then
  if tonumber(general.values.mesh) + tonumber(general.values.portal) + tonumber(general.values.radius) == 0 
  then
    __FORM.step = "nothing"
  end
  if tonumber(general.values.mesh) == 1 then 
    pkgs_tocheck = olsr_pkgs 
  end
  if tonumber(general.values.portal) == 1 then
    if pkgs_tocheck == "" then
      pkgs_tocheck = coova_pkgs..","..freeradius_pkgs
    else
      pkgs_tocheck = coova_pkgs..","..freeradius_pkgs..","..pkgs_tocheck
    end
  end
  pkgInstalledClass.new(pkgs_tocheck,true)
  if __FORM.step == "nothing" then
    forms = nothing()
  elseif __FORM.step == "network" then
    forms = set_mesh(general)
  elseif __FORM.step == "portal" then
    forms = set_portal(general)
  elseif __FORM.step == "users" then
    forms = set_users(general)
  elseif __FORM.step == "communities" then
      forms = set_communities(general)
  elseif __FORM.step == "set_end" then
    forms = set_end(general)
  end
  -- Check packages to remove --
-- Need function  
  -- Check packages to install --
--  local pkgs = pkgInstalledClass.new(check_pkgs,true)
else
  form = formClass.new(tr("Select what you want"))
	form:Add("select",general.name..".mesh",general.values.mesh,tr("iw_wizard_var_portal#Configure Mesh Network"),"string")
	form[general.name..".mesh"].options:Add("0",tr("No"))
	form[general.name..".mesh"].options:Add("1",tr("OLSR"))
  form:Add_help(tr("iwhotspothelper_var_mesh#Mesh Network"),tr([[iwhotspothelper_help_mesh#
    Mesh networking is a way to route data, voice and instructions between nodes. 
    It allows for continuous connections and reconfiguration around broken or 
    blocked paths by "hopping" from node to node until the destination is reached. 
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Mesh_network",tr("Extracted from Wikipedia"))

	form:Add("select",general.name..".portal",general.values.portal,tr("iw_wizard_var_portal#Configure Captive Portal"),"string")
	form[general.name..".portal"].options:Add("0",tr("No"))
	form[general.name..".portal"].options:Add("1",tr("Local Coova-Chilli"))
--	form[general.name..".portal"].options:Add("2",tr("Remote Coova-Chilli"))
--	form[general.name..".portal"].options:Add("3",tr("Remote ChilliSpot"))
  form:Add_help(tr("iwhotspothelper_var_portal#Captive Portal"),tr([[iwhotspothelper_help_portal#
    The captive portal technique forces an HTTP client on a network to see a 
    special web page (usually for authentication purposes) before surfing the 
    Internet normally. Captive portal turns a Web browser into a secure 
    authentication device.
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Captive_portal",tr("Extracted from Wikipedia"))
  
	form:Add("select",general.name..".radius",general.values.radius,tr("iw_wizard_var_portal#Configure Radius Server"),"string")
	form[general.name..".radius"].options:Add("0","No")
	form[general.name..".radius"].options:Add("2","Local Users")
	form[general.name..".radius"].options:Add("1","Communities Users")
	form[general.name..".radius"].options:Add("3","Local and Communities Users")
  form:Add_help(tr("iwhotspothelper_var_radius#Radius Server"),tr([[iwhotspothelper_help_radius#
    Radius server is an AAA (authentication, authorization, and accounting) protocol
    for controlling access to network resources.
    ]]))

  page.savebutton = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Next").."\" style=\"width:100px;\" />"
  page.action_apply = ""
  page.action_clear = ""
  page.action_review = ""

  form:Add("hidden","__ShowMenu","yes")
  form:Add("hidden","option","wizard")
  form:Add("hidden","step","network")
  forms[1]=form
end
page.title = tr("iw_wizard_main_title#Hotspot helper Settings")
print(page:header())
for i=1, #forms do
  forms[i]:print()
end
--[[
for i, t in pairs(__FORM) do
  print(i,t,"<br>")
end
]]--
print (page:footer())

