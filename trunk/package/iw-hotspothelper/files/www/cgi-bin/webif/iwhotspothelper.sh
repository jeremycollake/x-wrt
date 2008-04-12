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
##WEBIF:name:IW:150:Wizard
]]--
-- config.lua 
-- LUA settings and load some functions files
-- 
dofile("/usr/lib/webif/LUA/config.lua")
require("tbform")
require("radius")
require("captiveportal")

function about()
	form = formClass.new(tr("About"))
	form:Add_help(tr("iw_var_iw#Internet-Wifi"),tr([[iw_help_iw#
        Internet-Wifi is a personal project of community wireless like others. 
        This settings helper is to help you to configure a hotspot, but is not  
        only for that community.<br>
        You can use this to configure your stand-alone hotspot or your own community.
        If your community will be big, you will need install a server with webserver,
        radius server, and something to storage the users, time connections, 
        serve the captive portal and many things more or you can join to 
        <a href="http://dev.internet-wifi.com.ar/users">Internet-Wifi</a><strong> 
        (Internet-Wifi is WORK IN PROGRESS the site is not ready yet, but you can
         use the login page to test your configuration)</strong>. 
        ]]))
  return form
end

function add_communities()
  local form = formClass.new(tr("Add Community"))
  form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_proxy=realm&__menu="..__FORM.__menu,tr("Add Community"))
  return form
end

function communities()
  form = radius.community_form()
--  form.add_community.value = "nada"
  return form
end

function add_user()
  local form = formClass.new(tr("Add User"))
  form:Add("uci_set_config","freeradius_check,freeradius_reply","user",tr("freerad_add_user#New User"),"string")
  return form
end

function localusers(general)
  return radius.user_form()
end

function olsrd(general)
  if general.values.mesh == "1" then
    if iw_hotspot.interface == nil then iw_hotspot:set("settings","interface") end
    local interface = {}
    interface["name"] = iw_hotspot.__PACKAGE..".interface"
    interface["values"] = iw_hotspot.interface
   
    local iw_interface  = interface.values.interface  or "wlan"
    local iw_ipaddress  = interface.values.ipaddress  or "10.128.0.1"
    local iw_ipmask     = interface.values.ipamask    or "255.255.0.0"

    if iw_hotspot.wireless == nil then iw_hotspot:set("settings", "wireless") end
    local wifi = {}
    wifi["name"] = iw_hotspot.__PACKAGE..".wireless"
    wifi["values"] = iw_hotspot.wireless
  
    wireless = uciClass.new("wireless")
    local wifi_devices = {}
    for i=1, #wireless["wifi-iface"] do
      wifi_devices[#wifi_devices+1] = wireless["wifi-iface"][i].values.device
    end

    local iw_device     = wifi.values.device     or "wl0"
    local iw_channel    = wifi.values.channel    or "6"
    local iw_ssid       = wifi.values.ssid       or "X-WRT-Mesh"

    cfg_name = "algo"
    if general.values.mesh ~= "1" then 
      form = set_radius(general)
    else
      form = formClass.new(tr("Mesh Network Configuration"))
      form:Add("text",interface.name..".interface",iw_interface,tr("iw_wizard_var_interface#Mesh Network"),"string")
      form:Add("text",interface.name..".ipaddress",iw_ipaddress,tr("iw_wizard_var_ip#IP Address"),"string")
      form:Add_help(tr("iwhotspothelper_var_ipaddress#IP Address & Mask"),tr([[All device 
        in mesh network must be at the same sub-net.<br>
        node (1) Ip Address : 10.128.0.1 MASK 255.255.255.0 <br>
        node (2) Ip Address : 10.128.0.2 MASK 255.255.255.0 <br>
        node (n) Ip Address : 10.128.0.n MASK 255.255.255.0 <br>
        OR <br>
        node (1) Ip Address : 10.128.1.1 MASK 255.255.0.0 <br>
        node (2) Ip Address : 10.128.2.1 MASK 255.255.0.0 <br>
        node (n) Ip Address : 10.128.n.1 MASK 255.255.0.0 <br>
        ]]))
      form:Add("text",interface.name..".ipmask",iw_ipmask,tr("iw_wizard_var_mask#IP Mask"),"string")

      form:Add("subtitle","Wireless")
      form:Add("select",wifi.name..".device",iw_device,tr("iw_wizard_var_wireless_device#Wireless Device"),"string")
      for i = 1, #wifi_devices do
        form[wifi.name..".device"].options:Add(wifi_devices[i],wifi_devices[i])
      end
      form:Add("text",wifi.name..".channel",iw_channel,tr("iw_wizard_var_wifi_channel#Wireless Channel"),"string")
      form:Add("text",wifi.name..".ssid",iw_ssid,tr("iw_wizard_var_wifi_essid#SSID"),"string")
      form:Add_help(tr("iwhotspothelper_var_wireless#Wireless"),tr([[iwhotspothelper_help_wireless#
        All device must be in Adhoc Mode, have same channel and same ESSID.<br>
        Channels allocation on the mesh node is usually very simple. Can choose between 
        three channels (1,6,11), use channel 6 to normal nodes, 11 to backbone noedes
        and 1 to standart hotspot (not in mesh) access inside of location. This will 
        ensure that the two networks do not interfere with each other. Less interference
        will result in better performance.<br>
        ]]))
    end
    form:Add_help_link("http://wirelessafrica.meraka.org.za/wiki/images/f/fe/Building_a_Rural_Wireless_Mesh_Network_-_A_DIY_Guide_v0.7_65.pdf",tr("Extracted from Meraka Institute"))
    form:Add("hidden","__ShowMenu","yes")
    form:Add("hidden","option","second")
    form:Add("hidden","step","radius")
  else
    form = portal(general)
  end    
  return form
end

function uam_server(form)
	form:Add("text",cfg_name..".uamserver",iw_uamserver,tr("iw_wizard_var_chilli_uamserver#URL Login Page"),"string","width:90%")
	form:Add("text",cfg_name..".uamsecret",iw_uamsecret,tr("iw_wizard_var_chilli_secret#Login Page Secret"),"string")
	form:Add("text",cfg_name..".uamallowed",iw_uamallowed,tr("iw_wizard_var_chilli_allowed#URLs Allowed"),"string","width:90%")
end

function radius_server(form)
  cfg_chilli = "algo_chilli"
  form:Add("subtitle",tr("External Radius Server"))
	form:Add("text",cfg_chilli..".radiusserver1",     chilli_val_radiusserver1,tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiusserver2",     chilli_val_radiusserver2,tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiusauthport",    chilli_val_radiusauthport,tr("chilli_var_radiusauthport#Authentication Port"),"string")
	form:Add("text",cfg_chilli..".radiusacctport",    chilli_val_radiusacctport,tr("chilli_var_radiusacctport#Accounting Port"),"string")
  form:Add("text",cfg_chilli..".radiussecret",      chilli_val_radiussecret,tr("chilli_var_radiussecret#Radius Secret"),"string")
----	Help section	
	form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))
	form:Add_help(tr("chilli_var_radiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))
	form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
end

function nas_id(form)
  cfg_chilli = "algo_chilli"
  form:Add("subtitle",tr("NAS Identification"))
	form:Add("text",cfg_chilli..".radiusnasid",       chilli_val_radiusnasid,tr("chilli_var_radiusnasid#NAS ID"),"string")
	form:Add("text",cfg_chilli..".radiuslocationid",  chilli_val_radiuslocationid,tr("chilli_var_radiuslocationid#Location ID"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiuslocationname",chilli_val_radiuslocationname,tr("chilli_var_radiuslocationname#Location Name"),"string","width:90%")
	form:Add_help(tr("chilli_var_radiuslocationid#Location ID"),tr("chilli_help_radiuslocatioid#WISPr Location ID. Should be in the format: isocc=&lt;ISO_Country_Code&gt;, cc=&lt;E.164_Country_Code&gt;, ac=&lt;E.164_Area_Code&gt;, network=&lt;ssid/ZONE&gt;"))
	form:Add_help(tr("chilli_var_radiuslocationname#Location Name"),tr("chilli_help_radiuslocationname#WISPr Location Name. Should be in the format: &lt;HOTSPOT_OPERATOR_NAME&gt;, &lt;LOCATION&gt;"))
end

function coova(general)
  cfg_name = "algo"
	form = formClass.new(tr("Coova Captive Portal"))
  uam_server(form)
--[[
	form:Add("text",cfg_name..".uamserver",iw_uamserver,tr("iw_wizard_var_chilli_uamserver#UAM Server"),"string","width:90%")
	form:Add("text",cfg_name..".uamsecret",iw_uamsecret,tr("iw_wizard_var_chilli_secret#UAM Secret"),"string")
	form:Add("text",cfg_name..".uamallowed",iw_uamallowed,tr("iw_wizard_var_chilli_allowed#UAM Allowed"),"string","width:90%")
]]--
	form:Add_help(tr("iw_var_coovaservice#Coova Captive Portal"),tr([[iw_help_coovaservice#
    <strong><a href="http://www.coova.org/">CoovaChilli</a></strong> - is an 
    open-source software access controller, based on the popular ChilliSpot 
    project. It is a feature rich software access controller that provides a 
    captive portal / walled-garden environment and uses RADIUS for access 
    provisioning.
    ]]))
  form:Add_help_link("http://coova.org/wiki/index.php/CoovaChilli",tr("Extracted from Coova"))
  form:Add_help(tr("iwhotspothelper_var_uamserver#UAM Server"),tr([[iwhotspothelper_help_uamserver#
    Is an url of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamsecret#UAM Secret"),tr([[iwhotspothelper_help_uamsecret#
    Must be the same of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamallowed#UAM Allowed"),tr([[iwhotspothelper_help_uamallowed#
    List of allowed urls without authentication (for free access).
    ]]))
  return form
end

function chilli(general)
  cfg_name = "algo"
	form = formClass.new(tr("Chilli Captive Portal"))
  uam_server(form)
--[[
	form:Add("text",cfg_name..".uamserver",iw_uamserver,tr("iw_wizard_var_chilli_uamserver#UAM Server"),"string","width:90%")
	form:Add("text",cfg_name..".uamsecret",iw_uamsecret,tr("iw_wizard_var_chilli_secret#UAM Secret"),"string")
	form:Add("text",cfg_name..".uamallowed",iw_uamallowed,tr("iw_wizard_var_chilli_allowed#UAM Allowed"),"string","width:90%")
]]--
	form:Add_help(tr("iw_var_chilliservice#Captive Portal"),tr([[iw_help_chilliservice#
    <strong><a href="http://www.chillispot.info/">Chillispot</a></strong> - The captive portal technique forces an HTTP 
    client on a network to see a special web page (usually for authentication 
    purposes) before surfing the Internet normally. Captive portal turns a Web 
    browser into a secure authentication device.
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Captive_portal",tr("Extracted from Wikipedia"))
  form:Add_help(tr("iwhotspothelper_var_uamserver#UAM Server"),tr([[iwhotspothelper_help_uamserver#
    Is an url of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamsecret#UAM Secret"),tr([[iwhotspothelper_help_uamsecret#
    Must be the same of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamallowed#UAM Allowed"),tr([[iwhotspothelper_help_uamallowed#
    List of allowed urls without authentication (for free access).
    ]]))
  if tonumber(general.values.radius) == 0 then
    radius_server(form)
  end
  return form
end

function config()
  wireless = uciClass.new("wireless")
  local wifi_channel = wireless
  local wifi_devices = {}
  for i=1, #wireless["wifi-iface"] do
    wifi_devices[#wifi_devices+1] = wireless["wifi-iface"][i].values.device
  end
----	Input Section formservice
  if iw_hotspot.interface == nil then iw_hotspot:set("settings","interface") end
  local interface = {}
  interface["name"] = iw_hotspot.__PACKAGE..".interface"
  interface["values"] = iw_hotspot.interface
   
  local iw_interface  = interface.values.interface  or "wlan"
  local iw_ipaddress  = interface.values.ipaddress  or "10.128.0.1"
  local iw_ipmask     = interface.values.ipamask    or "255.255.255.0"
  cfg_name = "algo"
	form = formClass.new(tr("Mesh Network Configuration"))
--	form:Add("select",cfg_name..".mesh","yes",tr("iw_wizard_var_mesh#Mesh Network"),"string")
--	form[cfg_name..".mesh"].options:Add("no","Disable")
--	form[cfg_name..".mesh"].options:Add("yes","Enable")
	form:Add("text",cfg_name..".interface",iw_interface,tr("iw_wizard_var_interface#Mesh Network"),"string")
	form:Add("text",cfg_name..".ipaddress",iw_ipaddress,tr("iw_wizard_var_ip#IP Address"),"string")
  form:Add_help(tr("iwhotspothelper_var_ipaddress#IP Address & Mask"),tr([[All device 
    in mesh network must be at the same sub-net.<br>
    node (1) Ip Address : 10.128.0.1 MASK 255.255.255.0 <br>
    node (2) Ip Address : 10.128.0.2 MASK 255.255.255.0 <br>
    node (n) Ip Address : 10.128.0.n MASK 255.255.255.0 <br>
    OR <br>
    node (1) Ip Address : 10.128.1.1 MASK 255.255.0.0 <br>
    node (2) Ip Address : 10.128.2.1 MASK 255.255.0.0 <br>
    node (n) Ip Address : 10.128.n.1 MASK 255.255.0.0 <br>
    ]]))
	form:Add("text",cfg_name..".ipmask",iw_ipmask,tr("iw_wizard_var_mask#IP Mask"),"string")
  
  form:Add("subtitle","Wireless")
	form:Add("select",cfg_name..".device",iw_device,tr("iw_wizard_var_wireless_device#Wireless Device"),"string")
	for i = 1, #wifi_devices do
    form[cfg_name..".device"].options:Add(wifi_devices[i],wifi_devices[i])
  end
	form:Add("text",cfg_name..".channel",iw_channel,tr("iw_wizard_var_wifi_channel#Wireless Channel"),"string")
	form:Add("text",cfg_name..".ssid",iw_ssid,tr("iw_wizard_var_wifi_essid#SSID"),"string")
	form:Add_help(tr("iwhotspothelper_var_wireless#Wireless"),tr([[iwhotspothelper_help_wireless#
    All device must be in Adhoc Mode, have same channel and same ESSID.<br>
    Channels allocation on the mesh node is usually very simple. Can choose between 
    three channels (1,6,11), use channel 6 to normal nodes, 11 to backbone noedes
    and 1 to standart hotspot (not in mesh) access inside of location. This will 
    ensure that the two networks do not interfere with each other. Less interference
    will result in better performance.<br>
    ]]))
  form:Add_help_link("http://wirelessafrica.meraka.org.za/wiki/images/f/fe/Building_a_Rural_Wireless_Mesh_Network_-_A_DIY_Guide_v0.7_65.pdf",tr("Extracted from Meraka Institute"))
  
  form:Add("subtitle","Captive Portal")
	form:Add("text",cfg_name..".uamserver",iw_uamserver,tr("iw_wizard_var_chilli_uamserver#UAM Server"),"string","width:90%")
	form:Add("text",cfg_name..".uamsecret",iw_uamsecret,tr("iw_wizard_var_chilli_secret#UAM Secret"),"string")
	form:Add("text",cfg_name..".uamallowed",iw_uamallowed,tr("iw_wizard_var_chilli_allowed#UAM Allowed"),"string","width:90%")
	form:Add_help(tr("iw_var_chilliservice#Captive Portal"),tr([[iw_help_chilliservice#
    <strong><a href="http://www.chillispot.info/">Chillispot</a></strong> - The captive portal technique forces an HTTP 
    client on a network to see a special web page (usually for authentication 
    purposes) before surfing the Internet normally. Captive portal turns a Web 
    browser into a secure authentication device.
    ]]))
  form:Add_help_link("http://en.wikipedia.org/wiki/Captive_portal",tr("Extracted from Wikipedia"))
  form:Add_help(tr("iwhotspothelper_var_uamserver#UAM Server"),tr([[iwhotspothelper_help_uamserver#
    Is an url of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamsecret#UAM Secret"),tr([[iwhotspothelper_help_uamsecret#
    Must be the same of authentication page.
    ]]))
  form:Add_help(tr("iwhotspothelper_var_uamallowed#UAM Allowed"),tr([[iwhotspothelper_help_uamallowed#
    List of allowed urls without authentication (for free access).
    ]]))
  form:Add("subtitle","Local Radius")
	form:Add("text",cfg_name..".secret","testing123",tr("iw_wizard_var_freeradius_secret#Local Radius Secret"),"string")
  form:Add("subtitle","Local User")
	form:Add("text",cfg_name..".username",iw_username,tr("iw_wizard_var_freeradius_secret#Local Radius Secret"),"string")
	form:Add("text",cfg_name..".password",iw_password,tr("iw_wizard_var_freeradius_secret#Local Radius Secret"),"string")

  form:Add("subtitle","Communities Radius")
	form:Add("text",cfg_name..".rmtserver1",iw_rmtserver1,tr("iw_wizard_var_remoteradius_server#Primary Radius"),"string","width:90%")
	form:Add("text",cfg_name..".rmtserver2",iw_rmtserver2,tr("iw_wizard_var_remoteradius_server#Secondary Radius"),"string","width:90%")
	form:Add("text",cfg_name..".rmtsecret",iw_rmtsecret,tr("iw_wizard_var_remoteradius_secret#Radius Secret"),"string")
  form:Add_help(tr("iwhotspothelper_var_communities#Communities Radius"),tr([[iwhotspothelper_help_communities#
    Remote radius server to provide authentication, authorization, and accounting.
    ]]))
    return form
end

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
    forms[1] = olsrd(general)
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
    local user_level = tonumber(general.values.user_level) or 0
    local localradius = tonumber(general.values.radius) or 0
    forms[1] = formClass.new(tr("Captive Portal"))
    cportal.net_form(forms[1],user_level)
    cportal.radius_form(forms[1],user_level,localradius)
    setfooter(forms[1])
    forms[1]:Add("hidden","step","users")
  end
  return forms
end

function set_users(general)
  local forms = {}
  if tonumber(general.values.radius) < 2 then
    forms = set_communities(general)
  else
    forms[1] = radius.add_usr_form()
    forms[2] = radius.user_form()
    setfooter(forms[1])
    forms[1]:Add("hidden","step","communities")
  end
  return forms
end
 
function set_radius(general)
  local forms = {}
  if tonumber(general.values.radius) == 1 then -- Local Users
    forms[1] = radius.add_usr_form()
    forms[2] = localusers(general)
    setfooter(forms[1])
    forms[1]:Add("hidden","step","set_end")
  elseif tonumber(general.values.radius) == 2 then -- Communities Users
    forms = set_communities(general)
  elseif tonumber(general.values.radius) == 3 then -- Local & Communities Users
    forms[1] = radius.add_usr_form()
    forms[2] = localusers(general)
    setfooter(forms[1])
    forms[1]:Add("hidden","step","communities")
  else
    return set_end(general)
  end
  return forms
end

function set_communities(general)
  local forms = {}
  if tonumber(general.values.radius) > 1 then -- Local Users
    forms[1] = communities(general)
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

local olsr_pkgs = "ip,olsrd,olsrd-mod-dyn-gw,olsrd-mod-nameservice,olsrd-mod-txtinfo,iw-olsr"
local freeradius_pkgs = "libltdl,freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm,iw-freeradius"
local coova_pkgs = "coova,coova-chilli-xwrt"
local chilli_pkgs = "chillispot,iw-chillispot"
local check_pkgs = ""
local forms ={}

iw_hotspot = uciClass.new("iw_hotspot_wizard")
if iw_hotspot.general == nil then iw_hotspot:set("settings","general") end
local general = {}
general["name"] = iw_hotspot.__PACKAGE..".general"
general["values"] = iw_hotspot.general
require(".files/iwhotspothelper-menu")
for k,v in pairs(__FORM) do
  if k == "UCI_SET_VALUE" and string.trim(v) ~= "" then
    if __FORM.UCI_CMD_snwfreeradius_check then
      __FORM.step = "radius"
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
elseif __FORM.option == "config" then
  forms[1] = config() 
elseif __FORM.option == "wizard" then
  if tonumber(general.values.mesh) + tonumber(general.values.portal) + tonumber(general.values.radius) == 0 
  then
    __FORM.step = "nothing"
  end
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
	form[general.name..".portal"].options:Add("2",tr("Remote Coova-Chilli"))
	form[general.name..".portal"].options:Add("3",tr("Remote ChilliSpot"))
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
--for i, t in pairs(__FORM) do
--  print(i,t,"<br>")
--end
print (page:footer())

