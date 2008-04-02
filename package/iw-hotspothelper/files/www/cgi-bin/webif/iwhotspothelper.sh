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
local chillispot_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm,libltdl,chillispot,olsrd,olsrd-mod-dyn-gw,olsrd-mod-nameservice,olsrd-mod-txtinfo,ip,iw-chillispot,iw-freeradius,iw-olsr",true)

-- Chek if the packages are installed, if not install they.
-- I move the extra files to other dir to optimize time to make menu in X-Wrt
-- way, kepping in this directory only files needes to make menu
-- Simple Include menu for script
require(".files/iwhotspothelper-menu")
-- Load uci values in hotspot table 
iwhotspot = uciClass.new("iwhotspothelper")
network = uciClass.new("network")
wireless = uciClass.new("wireless")
chilli = uciClass.new("hotspot")
freeradius_check = uciClass.new("freeradius_check")
freeradius_reply = uciClass.new("freeradius_reply")
freeradius_proxy = uciClass.new("freeradius_proxy")
if iwhotspot.default == nil then default = iwhotspot:set("general","default")
else default = iwhotspot.default end

-- tmp table for easy write they are the same load config section  
--chilli = hotspot.chilli
--chillispot = hotspot.chillispot
---- Check if config section exist, if not set it
--if chilli == nil then chilli = hotspot:set("chilli") end
--if chillispot == nil then chillispot = hotspot:set("chillispot","service") end
--local cfg_chilli = hotspot.chilli[1].name
--local cfg_chillispot = hotspot.chillispot[1].name
--local chilli_val = hotspot.chilli[1].values
--local chillispot_val = hotspot.chillispot[1].values
---- pageClass is part of the framework 
--page.title = tr()
--print(page:header())
if __FORM.__ACTION == tr("Save Changes") then
--  page.__RELOAD = "http://10.128.12.1/cgi-bin/webif/iwhotspothelper.sh?__ACTION=applay_changes&__menu=11:1:1"
--  page.__RELOAD = __SERVER.SCRIPT_NAME .."?__ACTION=applay_changes&__menu="..__FORM.__menu
--  print(page:header())
    for i,v in pairs(network) do
      print(i,v,"<br>")
    end
else 

page.title = tr("iw_wizard_main_title#Internet-Wifi Hotspot helper Settings")
print(page:header())
for i,k in pairs(network) do
  print(i,k,"<br>")
  if type(k) == "table" then
    for u,v in pairs(k) do
      print("&nbsp;&nbsp;&nbsp;",u,v,"<br>")
      if type(v) == "table" then
        for j,t in pairs(v) do
          print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",j,t,"<br>")
        end
      end
    end
  end
end
print("<br><br>")
for i,k in pairs(wireless) do
  print(i,k,"<br>")
  if type(k) == "table" then
    for u,v in pairs(k) do
      print("&nbsp;&nbsp;&nbsp;",u,v,"<br>")
      if type(v) == "table" then
        for j,t in pairs(v) do
          print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",j,t,"<br>")
        end
      end
    end
  end
end
print("<br><br>")
for i,k in pairs(chilli) do
  print(i,k,"<br>")
  if type(k) == "table" then
    for u,v in pairs(k) do
      print("&nbsp;&nbsp;&nbsp;",u,v,"<br>")
      if type(v) == "table" then
        for j,t in pairs(v) do
          print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",j,t,"<br>")
        end
      end
    end
  end
end
print("<br><br>")
for i,k in pairs(freeradius_check) do
  print(i,k,"<br>")
  if type(k) == "table" then
    for u,v in pairs(k) do
      print("&nbsp;&nbsp;&nbsp;",u,v,"<br>")
      if type(v) == "table" then
        for j,t in pairs(v) do
          print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",j,t,"<br>")
        end
      end
    end
  end
end
print("<br><br>")
for i,k in pairs(freeradius_proxy) do
  print(i,k,"<br>")
  if type(k) == "table" then
    for u,v in pairs(k) do
      print("&nbsp;&nbsp;&nbsp;",u,v,"<br>")
      if type(v) == "table" then
        for j,t in pairs(v) do
          print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",j,t,"<br>")
        end
      end
    end
  end
end
print("<br>")
for i,k in pairs(__FORM) do
  print(i,k,"<br>")
end
local wifi_channel = wireless
local wifi_devices = {}
for i=1, #wireless["wifi-iface"] do
  wifi_devices[#wifi_devices+1] = wireless["wifi-iface"][i].values.device
end
cfg_name = iwhotspot.general[1].name
cfg_values = iwhotspot.general[1].values

local iw_interface  = cfg_values.interface  or "iwolsr"
local iw_ipaddress  = cfg_values.ipaddress  or "10.128.0.1"
local iw_ipmask     = cfg_values.ipamask    or "255.255.255.0"
local iw_dns        = cfg_values.dns        or "204.225.44.3"
local iw_device     = cfg_values.device     or "wl0"
local iw_channel    = cfg_values.channel    or "6"
local iw_ssid       = cfg_values.ssid       or "Internet-Wifi"
local iw_uamserver  = cfg_values.uamserver  or "http://www.internet-wifi.com.ar/hotspotlogin_m.php"
local iw_uamsecret  = cfg_values.uamsecret  or "Internet-Wifi"
local iw_uamallowed = cfg_values.uamallowed or "www.internet-wifi.com.ar,x-wrt.org,openwrt.org"
local iw_radsecret  = cfg_values.radsecret  or "testing123"
local iw_username   = cfg_values.username   or "steve"
local iw_password   = cfg_values.password   or "testing123"
local iw_rmtserver1 = cfg_values.rtmserver1 or "rad01.internet-wifi.com.ar"
local iw_rmtserver2 = cfg_values.rtmserver2 or "rad02.internet-wifi.com.ar"
local iw_rmtsecret  = cfg_values.rtmsecret  or "Internet-Wifi"
print ("<br><br>")
--[[
    Primero debo buscar si la interface que se usará para la mesh existe o no
    Si la interface no existe la debo crear, para crear la interface lo hago con
    el uci
    la interface se setea con uci.conf_set(pkg,grp,val) sin importar version del
    uci
    
]]--
print ([[uci_net_name = uci.conf_set("network","interface",]]..iw_interface..[[)]],"<br>")   
print ([[uci.set("network","interface",]]..iw_interface..[[)]],"<br>")   
__FORM.option = string.trim(__FORM.option)
if __FORM.option == "about" then
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
else
----	Input Section formservice
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
  form:print()
	form = formClass.new(tr("Mesh Network Configuration"),full)
	form:Add("button","btnext","Set Config","nose")
end
--form:Add_help_link("http://www.internet-wifi.com.ar",tr("More ".."about Internet-Wifi"))
form:print()

print (page:footer())
end