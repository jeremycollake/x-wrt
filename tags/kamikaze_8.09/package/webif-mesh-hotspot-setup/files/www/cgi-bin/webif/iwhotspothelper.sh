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
require("set_path")
require("init")
require("webpkg")
require("uci_iwaddon")

if uci.get("iw_hotspot_wizard.general") == nil then
  uci.set("iw_hotspot_wizard.general=settings")
end
if uci.get("iw_hotspot_wizard.general.portal") == nil then
  uci.set("iw_hotspot_wizard.general.portal=0")
end
if uci.get("iw_hotspot_wizard.general.mesh") == nil then
  uci.set("iw_hotspot_wizard.general.mesh=0")
end
if uci.get("iw_hotspot_wizard.general.radius") == nil then
  uci.set("iw_hotspot_wizard.general.radius=0")
end
uci.save("iw_hotspot_wizard")

local pkgs_tocheck = ""
local forms ={}
local wz = {}

wz.mesh   = tonumber(uci.get("iw_hotspot_wizard.general.mesh"))
wz.radius = tonumber(uci.get("iw_hotspot_wizard.general.radius")) 
wz.portal = tonumber(uci.get("iw_hotspot_wizard.general.portal"))

local olsr_pkgs = "ip olsrd olsrd-mod-dyn-gw olsrd-mod-nameservice olsrd-mod-txtinfo iw-olsr"
local freeradius_pkgs = "iw-freeradius libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"
local coova_pkgs = "coova-chilli coova-chilli-xwrt"
local chilli_pkgs = "chillispot iw-chillispot"

function setfooter(form)
  page.savebutton = "<input type=\"submit\" name=\"__ACTION\" value=\""..tr("Next").."\" style=\"width:100px;\" />"
--  page.action_apply = ""
--  page.action_clear = ""
--  page.action_review = ""
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

function set_mesh()
  local forms = {}
  if tonumber(wz.mesh) == 0 then
    forms = set_portal()
  else
    require("olsr")
    olsrd.get_installed_plugin()
    forms[1] = olsrd.core_form()
    forms[1].title = "Mesh Network Settings (OLSR)"
    forms[1]:Add("hidden","step","portal")
    setfooter(forms[1])
  end
  return forms
end 

function set_portal()
  local forms = {}
  if wz.portal == 0 then
    forms = set_communities()
  else
    if wz.radius == 0 then 
      wz.radius = 1
      uci.set("iw_hotspot_wizard.general.radius=1")
      uci.save("iw_hotspot_wizard")
    end
    if wz.portal == 1 then
      pkg.check(coova_pkgs)
      require("coovaportal")
      forms[1] = cportal.core_form(nil,1,wz.radius)
      forms[1].title = "Coova Chilli Service"
      setfooter(forms[1])
    else
      pkg.check(chilli_pkgs)
      require("chilliportal")
      forms[1] = cportal.core_form(nil,1,wz.radius)
      setfooter(forms[1])
    end  
    forms[1]:Add("hidden","step","communities")
  end
  return forms
end

function set_users()
  local forms = {}
  if wz.radius > 1 then
    pkg.check(freeradius_pkgs)
    require("radius")
    forms[1] = radius.add_usr_form()
    forms[2] = radius.user_form()
    setfooter(forms[1])
    forms[1]:Add("hidden","step","set_end")
  else
    forms = set_end()
  end
  return forms
end

function set_communities()
  local forms = {}
  if wz.radius == 0 then
    if wz.portal ~= 0 then 
      wz.radius = 1
    end    
    uci.set("iw_hotspot_wizard","general","radius",wz.radius)
  end
  if wz.radius == 1 then
  -- configura el raduis en el cportal
    if wz.portal == 0 then
--      mensaje de eroor
    elseif wz.portal == 1 then
      pkg.check(coova_pkgs)
      require("coovaportal")
    elseif wz.portal == 3 then
      pkg.check(chilli_pkgs)
      require("chilliportal")
    end          
    forms[1] = cportal.radius_form(nil,1,wz.radius)
    forms[1]:Add("hidden","step","set_end")
    setfooter(forms[1])
  elseif wz.radius == 3 then
    pkg.check(freeradius_pkgs)
    require("radius")
    forms[1] = radius.community_form()
    for i,k in pairs(forms[1]) do
      if i == "add_community" then
        forms[1].add_community.value = __SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_proxy=realm&__menu="..__FORM.__menu.."&option=wizard&step=communities"
      elseif string.match(i,"remove") then
        local realm_cfg = string.gsub(i,"remove","")
        forms[1][i].value = __SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..realm_cfg.."=&__menu="..__FORM.__menu.."&option=wizard&step=communities"
      end
    end    
    setfooter(forms[1])
    if wz.radius == 3 then
      forms[1]:Add("hidden","step","users")
    else
      forms[1]:Add("hidden","step","set_end")
    end
  elseif wz.radius == 2 then
    forms = set_users()
  else
    forms = set_end()
  end
  if wz.radius > 1 then
    if wz.portal == 1 then
      require("coovaportal")
    elseif wz.portal == 3 then
      require("chilliportal")
    end
    cportal.set_rad_local(1,wz.radius)
  end
  return forms
end

function set_end()
  local forms = {}
  if wz.mesh > 0 then
    forms[#forms+1] = formClass.new(tr("Mesh Network Configuration"))
	end
  if wz.portal > 0 then
    forms[#forms+1] = formClass.new(tr("Captive portal configured"))
	end
  if wz.radius > 0 then
    forms[#forms+1] = formClass.new(tr("Radius Server configured"))
	end
	return forms
end


for k,v in pairs(__FORM) do
  if k == "UCI_SET_VALUE" and string.trim(v) ~= "" then
    if __FORM.UCI_CMD_snwfreeradius_check then
      __FORM.step = "users"
      break
    end
  end
  if string.match(k,"UCI_CMD_delfreeradius_proxy") then
    __FORM.option = "wizard"
    __FORM.step = "communities"
    break
  end
  if string.match(k,"UCI_CMD_delfreeradius_check") then
    __FORM.option = "wizard"
    __FORM.step = "users"
    break
  end
end

__FORM.option = string.trim(__FORM.option)
pkg.add_hidden("__ShowMenu","yes")
pkg.add_hidden("option",__FORM.option)
pkg.add_hidden("step",__FORM.step)

if __FORM.option == "about" then
  forms[1] = about()
elseif __FORM.bt_pkg_install == "Install" then
  pkg.check()
elseif __FORM.option == "config" then
  forms[1] = config() 
elseif __FORM.option == "wizard" then

  if wz.mesh + wz.portal + wz.radius == 0 then
    __FORM.step = nothing()
  elseif wz.portal == 0 and wz.radius == 1 then
    __FORM.step = no_portal()
  end
  if wz.mesh == 1 then 
    pkgs_tocheck = olsr_pkgs 
  end
  if wz.portal == 1 then
    pkgs_tocheck = coova_pkgs.." "..pkgs_tocheck
  end
  if wz.portal == 2 then
    pkgs_tocheck = chilli_pkgs.." "..pkgs_tocheck
  end
  if wz.radius > 1 then
      pkgs_tocheck = freeradius_pkgs.." "..pkgs_tocheck
  end
  pkg.check(pkgs_tocheck)
  if __FORM.step == "network" then
    forms = set_mesh()
  elseif __FORM.step == "portal" then
    forms = set_portal()
  elseif __FORM.step == "users" then
    forms = set_users()
  elseif __FORM.step == "communities" then
      forms = set_communities()
  elseif __FORM.step == "set_end" then
    forms = set_end()
  end
  -- Check packages to remove --
-- Need function  
  -- Check packages to install --
--  local pkgs = pkgInstalledClass.new(check_pkgs,true)

else
  form = formClass.new(tr("Select what you want"))
	form:Add("select","iw_hotspot_wizard.general.mesh",uci.get("iw_hotspot_wizard.general.mesh"),tr("iw_wizard_var_portal#Configure Mesh Network"),"string")
	form["iw_hotspot_wizard.general.mesh"].options:Add("0",tr("No"))
	form["iw_hotspot_wizard.general.mesh"].options:Add("1",tr("OLSR"))
  form:Add_help(tr("iwhotspothelper_var_mesh#Mesh Network"),tr([[iwhotspothelper_help_mesh#
    Mesh networking is a way to route data, voice and instructions between nodes. 
    It allows for continuous connections and reconfiguration around broken or 
    blocked paths by "hopping" from node to node until the destination is reached. 
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Mesh_network",tr("Extracted from Wikipedia"))

	form:Add("select","iw_hotspot_wizard.general.portal",uci.get("iw_hotspot_wizard.general.portal"),tr("iw_wizard_var_portal#Configure Captive Portal"),"string")
	form["iw_hotspot_wizard.general.portal"].options:Add("0",tr("No"))
	form["iw_hotspot_wizard.general.portal"].options:Add("1",tr("Local Coova-Chilli"))
--	form["iw_hotspot_wizard.general.portal"].options:Add("2",tr("Remote Coova-Chilli"))
	form["iw_hotspot_wizard.general.portal"].options:Add("3",tr("Remote ChilliSpot"))
  form:Add_help(tr("iwhotspothelper_var_portal#Captive Portal"),tr([[iwhotspothelper_help_portal#
    The captive portal technique forces an HTTP client on a network to see a 
    special web page (usually for authentication purposes) before surfing the 
    Internet normally. Captive portal turns a Web browser into a secure 
    authentication device.
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Captive_portal",tr("Extracted from Wikipedia"))
  
	form:Add("select","iw_hotspot_wizard.general.radius",uci.get("iw_hotspot_wizard.general.radius"),tr("iw_wizard_var_portal#Authentication Users"),"string")
	form["iw_hotspot_wizard.general.radius"].options:Add("0","No")
	form["iw_hotspot_wizard.general.radius"].options:Add("2","Local Users")
	form["iw_hotspot_wizard.general.radius"].options:Add("1","Communities Users")
	form["iw_hotspot_wizard.general.radius"].options:Add("3","Communities & Local Users")
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
for i,v in pairs(__SERVER) do
  print(i,v,"<br>")
end
]]--
print (page:footer())

