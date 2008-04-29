--[[
    Availables functions
    check_pkg
    core_form
    community_form

]]--
require("net")
require("tbform")
require("checkpkg")
cportal = {}
local P = {}
cportal = P
-- Import Section:
-- declare everything this package needs from outside
local tonumber = tonumber
local pairs = pairs
local print = print
local net = net
local io = io
local string = string

local uciClass = uciClass
local menuClass = menuClass
local __UCI_VERSION = __UCI_VERSION
local formClass = formClass
local __SERVER = __SERVER
local __FORM = __FORM
local __MENU = __MENU
local tr = tr
local tbformClass = tbformClass
-- no more external access after this point
setfenv(1, P)
local hotspot = uciClass.new("chilli")
local service = hotspot.service or hotspot:set("websettings","service")
local userlevel = tonumber(hotspot.service.userlevel) or 0
local portal = tonumber(hotspot.service.portal) or 0
local users = tonumber(hotspot.service.users) or 0

function set_menu()
  __MENU.HotSpot["Coova-Chilli"] = menuClass.new()
  __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Core#Core","coova-chilli.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_DHCP#Network","coova-chilli.sh?option=net")
--  if portal > 0 then
      __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Portal#Portal","coova-chilli.sh?option=uam")
--  end
    if users == 0 then
      __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Radius#Radius","coova-chilli.sh?option=radius")
    end
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_NasId#NAS ID","coova-chilli.sh?option=nasid")
  end
  if users == 1
  or users == 3 then 
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Users#Users","coova-chilli.sh?option=users")
  end
  if users > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Communities#Communities","coova-chilli.sh?option=communities")
  end
  if tonumber(hotspot.service.enable) == 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Connections#Connections","coova-chilli.sh?option=connections")
  end
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Access#Access","coova-chilli.sh?option=access")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Proxy#Proxy","coova-chilli.sh?option=proxy")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Scripts#Extras","coova-chilli.sh?option=extras")
  
  __WIP = 4
end

function core_form()
  local service = {}
  service["values"] = hotspot.service or hotspot:set("chilli","service")
  service["name"] = hotspot.__PACKAGE..".service"
  local network = {}
  network["values"] = hotspot.network or hotspot:set("chilli","network")
  network["name"] = hotspot.__PACKAGE..".network"
  cp_enable = service.values.enable or "0"
  cp_userlevel = service.values.userlevel or "0"
  cp_portal = service.values.portal or "0"
  cp_users = service.values.users or "1"


  form = formClass.new(tr("chilli_title_service#Service"))
	form:Add("select",service.name..".enable",cp_enable,tr("chilli_var_service#Service"),"string")
	form[service.name..".enable"].options:Add("0","Disable")
	form[service.name..".enable"].options:Add("1","Enable")

	form:Add("select",service.name..".userlevel",cp_userlevel,tr("userlevel#User Level"),"string")
	form[service.name..".userlevel"].options:Add("0","Select Mode")
	form[service.name..".userlevel"].options:Add("1","Beginer")
	form[service.name..".userlevel"].options:Add("2","Medium")
	form[service.name..".userlevel"].options:Add("3","Advanced")
	form[service.name..".userlevel"].options:Add("4","Expert")
  if userlevel > 1 then
  	form:Add("select",service.name..".portal",cp_portal,tr("portal#Portal Settings"),"string")
--  	form[service.name..".portal"].options:Add("0","Coova Server")
    form[service.name..".portal"].options:Add("2","Internal Server")
    form[service.name..".portal"].options:Add("1","Remote Server")

    form:Add("select",service.name..".users",cp_users,tr("authentication_users#Authenticate Users Mode"),"string")
    form[service.name..".users"].options:Add("1","Local Radius Users")
    form[service.name..".users"].options:Add("0","Remote Radius")
    form[service.name..".users"].options:Add("2","Communities Users")
    form[service.name..".users"].options:Add("3","Remote & Local Users")
  end
  form:Add("select",network.name..".HS_LANIF",network.values.HS_LANIF,tr("cportal_var_device#Device Network"),"string")
  for k, v in pairs(net.wireless()) do
    form[network.name..".HS_LANIF"].options:Add(k,k)
  end    
   
  return form
end

function net_form(form,user_level,localuam)
  local user_level = user_level or userlevel
  local form = form
  local network = {}
  network["values"] = hotspot.network or hotspot:set("chilli","network")
  network["name"] = hotspot.__PACKAGE..".network"
  if form == nil then
    form = formClass.new(tr("Network Settings"))
  else
    form:Add("subtitle",tr("Networ Settings"))
  end
  local dev
  if user_level > 0 then
    dev = net.ifname() -- for advanced users
  else
    dev = net.wireless() -- for beginers users
  end
  local cp_HSWANIF       = network.values.HSWANIF 
  local cp_HSLANIF       = network.values.HSLANIF
  local cp_HS_NETWORK    = network.values.HS_NETWORK or "192.168.182.0"
  local cp_HS_NETMASK    = network.values.HS_NETMASK or "255.255.255.0"
  local cp_HS_UAMLISTEN  = network.values.HS_UAMLISTEN or "192.168.182.1"
  local cp_HS_UAMPORT    = network.values.HS_UAMPORT or "3990"
  local cp_HS_DYNIP      = network.values.HS_DYNIP
  local cp_HS_DYNIP_MASK = network.values.HS_DYNIP_MASK
  local cp_HS_STATIP     = network.values.HS_STATIP
  local cp_HS_STATIP_MASK= network.values.HS_STATIP_MASK
  local cp_HS_DNS_DOMAIN = network.values.HS_DNS_DOMAIN
  local cp_HS_DNS1       = network.values.HS_DNS1 or "192.168.182.1"
  local cp_HS_DNS2       = network.values.HS_DNS2 or "204.225.44.3"
  form:Add("select",network.name..".HS_LANIF",network.values.HS_LANIF,tr("cportal_var_device#Device Network"),"string")
  for k, v in pairs(dev) do
    form[network.name..".HS_LANIF"].options:Add(k,k)
  end
--[[
  if localuam == 2 then
    form:Add("hidden",network.name..".HS_DNS_DOMAIN",cp_HS_DNS_DOMAIN)
    form:Add("hidden",network.name..".HS_NETWORK",cp_HS_NETWORK)
    form:Add("hidden",network.name..".HS_NETMASK",cp_HS_NETMASK)
    form:Add("hidden",network.name..".HS_UAMLISTEN",cp_HS_UAMLISTEN)
    form:Add("hidden",network.name..".HS_DNS1",cp_HS_DNS1)
    form:Add("hidden",network.name..".HS_DNS2",cp_HS_DNS2)
    return form
  end
]]--
--  if user_level > 1 then
--[[
    form:Add("select", network.name..".HS_WANIF", cp_HS_WANIF,tr("cportal_var_wan#WAN Device"),"string")
  for k, v in pairs(ifname("wan")) do
    form[network.name..".HS_LANIF"].options:Add(k,k)
  end
    form:Add("text", network.name..".HS_WANIF", cp_HS_WANIF,tr("cportal_var_wan#WAN Device"),"string")
]]--
    form:Add("text", network.name..".HS_DNS_DOMAIN", cp_HS_DNS_DOMAIN,tr("cportal_var_net#Domain"),"string")
    form:Add("text", network.name..".HS_UAMLISTEN", cp_HS_UAMLISTEN,tr("cportal_var_net#Listen"),"string")
    form:Add("text", network.name..".HS_UAMPORT", cp_HSUAMPORT,tr("cportal_var_net#Port"),"string")
    form:Add("text", network.name..".HS_NETWORK", cp_HS_NETWORK,tr("cportal_var_net#Network"),"string")
    form:Add("text", network.name..".HS_NETMASK", cp_HS_NETMASK,tr("cportal_var_net#Network"),"string")
    form:Add("text", network.name..".HS_STATIP", cp_HS_STATIP,tr("cportal_var_staticip#Static IP"),"string")
    form:Add("text", network.name..".HS_STATIP_MASK", cp_HS_STATIP_MASK,tr("cportal_var_staticip#Static IP Mask"),"string")
    form:Add("text", network.name..".HS_DYNIP", cp_HS_DYNIP,tr("cportal_var_dynip#Dynamic IP"),"string")
    form:Add("text", network.name..".HS_DYNIP_MASK", cp_HS_DYNIP_MASK,tr("cportal_var_staticip#Dynamic IP Mask"),"string")
    form:Add("text", network.name..".HS_DNS1", cp_HS_DNS1,tr("cportal_var_dns#DNS Server").." 1","string")
    form:Add("text", network.name..".HS_DNS2", cp_HS_DNS2,tr("cportal_var_dns#DNS Server").." 2","string")
--[[
  else
    form:Add("hidden", network.name..".HS_WANIF", "")
    form:Add("hidden", network.name..".HS_DNS_DOMAIN", cp_HS_DNS_DOMAIN)
    form:Add("hidden", network.name..".HS_UAMLISTEN", cp_HS_UAMLISTEN)
    form:Add("hidden", network.name..".HS_UAMPORT", cp_HSUAMPORT)
    form:Add("hidden", network.name..".HS_NETWORK", cp_HS_NETWORK)
    form:Add("hidden", network.name..".HS_NETMASK", cp_HS_NETMASK)
    form:Add("hidden", network.name..".HS_STATIP", cp_HS_STATIP)
    form:Add("hidden", network.name..".HS_STATIP_MASK", cp_HS_STATIP_MASK)
    form:Add("hidden", network.name..".HS_DYNIP", cp_HS_DYNIP)
    form:Add("hidden", network.name..".HS_DYNIP_MASK", cp_HS_DYNIP_MASK)
    form:Add("hidden", network.name..".HS_DNS1", cp_HS_DNS1)
    form:Add("hidden", network.name..".HS_DNS2", cp_HS_DNS2)
  end
]]--
  return form
end
  
function radius_form(form,user_level,localrad)
  local form = form
  local user_level = user_level or 0
  local localrad = localrad or 0
  local radius = {}
  radius["values"] = hotspot.radius or hotspot:set("chilli","radius")
  radius["name"] = hotspot.__PACKAGE..".radius"
  
  cp_HS_RADIUS = radius.values.HS_RADIUS
  cp_HS_RADIUS2 = radius.values.HS_RADIUS2
  cp_HS_RADSECRET = radius.values.HS_RADSECRET or 'testing123'
  cp_HS_RADAUTH   = radius.values.HS_RADAUTH or '1812'
  cp_HS_RADACCT   = radius.values.HS_RADACCT or '1813'

  if form == nil then
    form = formClass.new(tr("Captive Portal - Radius Settings"))
  else
    if localrad == 0 then
      form:Add("subtitle",tr("Remote").." "..tr("Radius Settings"))
    else
      form:Add("subtitle",tr("Local").." "..tr("Radius Settings"))
    end    
  end

  if localrad > 0 then
    cp_HS_RADIUS = "127.0.0.1"
    cp_HS_RADIUS2 = "172.0.0.1"
    cp_HS_RADAUTH = ""
    cp_HS_RADACCT = ""
  	form:Add("hidden",radius.name..".HS_RADIUS",  cp_HS_RADIUS)
    form:Add("hidden",radius.name..".HS_RADIUS2", cp_HS_RADIUS2)
    form:Add("hidden",radius.name..".HS_RADAUTH", cp_HS_RADAUTH)
    form:Add("hidden",radius.name..".HS_RADACCT", cp_HS_RADACCT)
    form:Add("text",radius.name..".HS_RADSECERT", cp_HS_RADSECERT)
    form:Add_help(tr("chilli_var_rradiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))
  else  
----	Input Section form
    form:Add("text",radius.name..".HS_RADIUS",cp_HS_RADIUS,tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
    form:Add("text",radius.name..".HS_RADIUS2",cp_HS_RADIUS2,tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
    form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))

    form:Add("text",radius.name..".HS_RADSECRET",      cp_HS_RADSECRET,tr("chilli_var_rradiussecret#Remote Radius Secret"),"string")
    form:Add_help(tr("chilli_var_rradiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))

    form:Add("text",radius.name..".HS_RADAUTH",    cp_HS_RADAUTH,tr("chilli_var_radiusauthport#Authentication Port"),"string")
    form:Add("text",radius.name..".HS_RADACCT",    cp_HS_RADACCT,tr("chilli_var_radiusacctport#Accounting Port"),"string")
    form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
  end
  return form
end

function nasid_form(form,user_level)
  local form = form
  local user_level = user_level or userlevel
  local nas = {}
  nas["values"] = hotspot.nasid or hotspot:set("chilli","nasid") 
  nas["name"] = hotspot.__PACKAGE..".nasid"
  if form == nil then
    form = formClass.new(tr("Captive Portal - NAS Identification"))
  else
    form:Add("subtitle",tr("NAS Identification"))
  end
  cp_HS_NASID = nas.values.HS_NASID or "X-Wrt nas"
  cp_HS_LOC_NAME = nas.values.HS_LOC_NAME or "My X-Wrt Hotspot"
  cp_HS_LOC_NETWORK = nas.values.HS_LOC_NETWORK or "X-Wrt Network"
  cp_HS_LOC_AC = nas.values.HS_LOC_AC
  cp_HS_LOC_CC = nas.values.HS_LOC_CC
  cp_HS_LOC_ISOCC = nas.values.HS_LOC_ISOCC

--  form:Add("subtitle",tr("NAS Identification"))
	form:Add("text",nas.name..".HS_NASID",cp_HS_NASID,tr("cportal_var_radiusnasid#NAS ID"),"string")
  form:Add("text",nas.name..".HS_LOC_NAME",cp_HS_LOC_NAME,tr("cportal_var_radiusnasip#Location Name"),"string")
	form:Add("text",nas.name..".HS_LOC_NETWORK",cp_HS_LOC_NETWORK,tr("cportal_var_radiusnasporttype#Network name"),"string")
	form:Add("text",nas.name..".HS_LOC_AC",cp_HS_LOC_AC,tr("cportal_var_radiuslocationid#Phone area code"),"string")
	form:Add("text",nas.name..".HS_LOC_CC",cp_HS_LOC_CC,tr("cportal_var_radiuslocationname#Phone country code"),"string")
	form:Add("text",nas.name..".HS_LOC_ISOCC",cp_HS_LOC_ISOCC,tr("cportal_var_isocc#ISO Country code"),"string")
  return form
end

function disconnect_form()
  form:Add("subtitle","Radius request disconnection")
	form:Add("text",cfg_chilli..".coaport",      chilli_val.coaport,tr("chilli_var_coaport#UDP port"),"string")
	form:Add("checkbox",cfg_chilli..".coanoipcheck",chilli_val.coanoipcheck ,tr("chilli_var_coanoipcheck#No check radius IP"),"string")
----	Help section	

	form:Add_help(tr("chilli_var_coaport#UDP port"),tr(
          [[chilli_help_coaport#
          UDP port to listen to for accepting radius disconnect requests. 
          ]]))
	form:Add_help(tr("chilli_var_coanoipcheck#No check radius IP"),tr(
          [[
          If this option is given no check is performed on the source IP address 
          of radius disconnect requests. Otherwise it is checked that radius 
          disconnect requests originate from radiusserver1 or radiusserver2.  
          ]]))
  return form
end

function uam_form(form,user_level,localuam)
  if form ~= nil then form:Add("subtitle","Captive Portal - Universal Authentication Method") end
  local form = form or formClass.new("Captive Portal - Univesal Authentication Method")
  local user_level = user_level or userlevel
  local localuam = localuam or portal
  local uam = {}
  uam["values"] = hotspot.uam or hotspot:set("chilli","uam")
  uam["name"] = hotspot.__PACKAGE..".uam"
  
  cp_HS_UAMSERVER   = uam.values.HS_UAMSERVER or "192.168.182.1"
  cp_HS_UAMFORMAT   = uam.values.HS_UAMFORMAT or "http://\$HS_UAMSERVER/cgi-bin/login/pba.lua"
  cp_HS_UAMSECRET   = uam.values.HS_UAMSECRET or ""
  cp_HS_UAMHOMEPAGE = uam.values.HS_UAMHOMEPAGE or "http://\$HS_UAMLISTEN:\$HS_UAMPORT/www/coova.html"
  cp_HS_UAMALLOW  = uam.values.HS_UAMALLOW or "x-wrt.org"

  if localuam == 2 and user_level < 2 then
    cp_HS_UAMSERVER   = "192.168.182.1"
    cp_HS_UAMFORMAT   = "http://\$HS_UAMSERVER/cgi-bin/login/pba.lua"
    cp_HS_UAMSECRET   = ""
    cp_HS_UAMHOMEPAGE = "http://\$HS_UAMLISTEN:\$HS_UAMPORT/www/coova.html"
    cp_HS_UAMALLOW  = "x-wrt.org"
    form:Add("hidden",uam.name..".HS_UAMSERVER",cp_HS_UAMSERVER)
    form:Add("hidden",uam.name..".HS_UAMFORMAT",cp_HS_UAMFORMAT)
    form:Add("hidden",uam.name..".HS_UAMLISTEN",cp_HS_UAMLISTEN)
  end
  
  if user_level > 1 or localuam < 2 then
    form:Add("text",uam.name..".HS_UAMSERVER",cp_HS_UAMSERVER,tr("cportal_var_uamserver#URL of Web Server"),"string","width:90%")
    form:Add_help(tr("cportal_var_uamserver#URL of Web Server"),tr("cportal_help_uamserver#URL of a Webserver handling the authentication."))

    form:Add("text",uam.name..".HS_UAMFORMAT",cp_HS_UAMFORMAT,tr("cportal_var_format#Path of Login Page"),"string","width:90%")
    form:Add_help(tr("cportal_var_format#URL of Web Server"),tr("cportal_help_format#URL of a Webserver handling the authentication."))

    form:Add("text",uam.name..".HS_UAMSECRET",cp_HS_UAMSECRET,tr("cportal_var_uamsecret#UAM Secret"),"string")
    form:Add_help(tr("cportal_var_uamsecret#Web Secret"),tr("cportal_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))
    if user_level > 2 then
      form:Add("text",uam.name..".HS_UAMHOMEPAGE",cp_HS_UAMHOMEPAGE,tr("cportal_var_uamhomepage#UAM Home Page"),"string","width:90%")
      form:Add_help(tr("cportal_var_uamhomepage#Homepage"),tr("cportal_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))
    end
  end
  form:Add("text",uam.name..".HS_UAMALLOW",cp_HS_UAMALLOW,tr("cportal_var_uamallowed#UAM Allowed"),"string","width:90%")
  form:Add_help(tr("cportal_var_uamallowed#Allowed URLs"),tr("cportal_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))
  return form
end

function extras_form()
--[[
  local form = form
  local user_level = user_level or 0
  local localuam = localuam or 0
  local extras = {}
  extras["values"] = hotspot.extas or hotspot:set("chilli","extras")
  extras["name"] = hotspot.__PACKAGE..".extras"

  cp_HS_RADCONF     = extras.values.HS_RADCONF or "off"
#
# HS_ANYIP=on		   # Allow any IP address on subscriber LAN
#
# HS_MACAUTH=on		   # To turn on MAC Authentication
#
# HS_MACAUTHMODE=local	   # To allow MAC Authentication based on macallowed, not RADIUS
#
# HS_MACALLOWED="..."      # List of MAC addresses to authenticate (comma seperated)
#
# HS_USELOCALUSERS=on      # To use the /etc/chilli/localusers file
#
# HS_OPENIDAUTH=on	   # To inform the RADIUS server to allow OpenID Auth
#
# HS_WPAGUESTS=on	   # To inform the RADIUS server to allow WPA Guests
#
# HS_DNSPARANOIA=on	   # To drop DNS packets containing something other
#			   # than A, CNAME, SOA, or MX records
#
# HS_OPENIDAUTH=on	   # To inform the RADIUS server to allow OpenID Auth
#			   # Will also configure the embedded login forms for OpenID
#
# HS_USE_MAP=on		   # Short hand for allowing the required google
#			   # sites to use Google maps (adds many google sites!)
#
###
#   Other feature settings and their defaults
#
# HS_DEFSESSIONTIMEOUT=0   # Default session-timeout if not defined by RADIUS (0 for unlimited)
#
# HS_DEFIDLETIMEOUT=0	   # Default idle-timeout if not defined by RADIUS (0 for unlimited)
]]--
--[[
  form:Add("select",extras.name..".HS_RADCONF",cp_HS_RADCONF,tr("cportal_var_HS_RADCONF#Radius Configuration"),"string")
    form[extras.name..".HS_RADCONF"].options:Add("off",tr("Off))
    form[extras.name..".HS_RADCONF"].options:Add("on",tr("On))
  Add_help(tr("cportal_var_HS_RADCONF#Radius Configuration"),tr("Get some configurations from RADIUS or a URL ('on' and 'url' respectively)")
]]--
end

function connect_form(form,user_level,localuam)
  local authenticated = {["0"] = "No",["1"] = "Yes"}
  local form = tbformClass.new("Captive Portal - Connection List")
  form = tbformClass.new("Local Users")
  form:Add_col("label", "Username","Username", "120px")
  form:Add_col("label", "MAC-Address", "MAC Address", "160px","string","width:160px")
  form:Add_col("label", "IP-Address", "IP Address", "140px","string","width:140px")
  form:Add_col("label", "Status", "Status", "60px","string","width:60px")
  form:Add_col("label", "Session-ID", "Session ID", "170px","int","width:170px")
  form:Add_col("label", "Auth", "Aut", "40px","int","width:40px")
  form:Add_col("label", "SessTime", "Session Time", "90px","int","width:90px")
  form:Add_col("label", "IdleTime", "Idle Time", "100px","int","width:100px")
--  form:Add_col("label", "startpage", "Start Page", "100px","int","width:100px")
  connected = io.popen("chilli_query list")
  for line in connected:lines() do
    local tline = string.split(line," ")
    mac = tline[1]
    ip = tline[2]
    status = tline[3]
    sessId = tline[4]
    authen = authenticated[tline[5]]
    user = tline[6]         
    sessTime = tline[7]         
    idleTime = tline[8]
    startPage = tline[9]         
    form:New_row()

    form:set_col("Username",sessId..".Username",user)
    form:set_col("MAC-Address",sessId..".MAC-Address",mac)
    form:set_col("IP-Address",sessId..".IP-Address",ip)
    form:set_col("Status",sessId..".Status",status)
    form:set_col("Session-ID",sessId..".Session-ID",sessId)
    form:set_col("Auth",sessId..".Auth",authen)
    form:set_col("SessTime",sessId..".SessTime",sessTime)
    form:set_col("IdleTime",sessId..".IdleTime",idleTime)
--    form:set_col("startpage",sessId..".startpage",startPage)
  end
  return form
end

