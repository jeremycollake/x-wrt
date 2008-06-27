--[[
    Availables functions
    check_pkg
    core_form
    community_form

]]--
require("net")
require("tbform")
--require("checkpkg")
--require("iw-luaipkg")
require("uci_iwaddon")

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
local uci = uci

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

uci.check_set("coovachilli","webadmin","coova")
uci.check_set("coovachilli","net","settings")
local userlevel = tonumber(uci.check_set("coovachilli","webadmin","userlevel","1"))
local radconf = tonumber(uci.check_set("coovachilli","webadmin","radconf","1"))
local portal = tonumber(uci.check_set("coovachilli","webadmin","portal","2"))

uci.check_set("coovachilli","dir","coovadir")
uci.check_set("coovachilli","dir","HS_WWWDIR","/etc/chilli/www")
uci.check_set("coovachilli","dir","HS_WWWBIN","/etc/chilli/wwwsh")

uci.check_set("coovachilli","net","settings")
uci.check_set("coovachilli","net","HS_DNS1","192.168.182.1")
uci.check_set("coovachilli","net","HS_DNS2","204.225.44.3")
uci.check_set("coovachilli","net","HS_NETWORK","192.168.182.0")
uci.check_set("coovachilli","net","HS_NETMASK","255.255.255.0")
uci.check_set("coovachilli","net","HS_LANIF","wl0")

uci.check_set("coovachilli","uam","settings")
uci.check_set("coovachilli","uam","HS_UAMSERVER","192.168.182.1")
uci.check_set("coovachilli","uam","HS_UAMPORT","3990")
uci.check_set("coovachilli","uam","HS_UAMLISTEN","192.168.182.1")
uci.check_set("coovachilli","uam","HS_UAMALLOW","x-wrt.org,coova.org,www.internet-wifi.com.ar")
uci.check_set("coovachilli","uam","HS_UAMHOMEPAGE","http://$HS_UAMLISTEN:$HS_UAMPORT/www/coova.html")
uci.check_set("coovachilli","uam","HS_UAMFORMAT","http://$HS_UAMSERVER/cgi-bin/login/login")

uci.check_set("coovachilli","nas","settings")
uci.check_set("coovachilli","nas","HS_NASID","X-Wrtnas")
uci.check_set("coovachilli","nas","HS_LOC_NAME","My X-Wrt Hotspot")
uci.check_set("coovachilli","nas","HS_LOC_NETWORK","X-Wrt Network")

uci.check_set("coovachilli","radius","settings")
uci.check_set("coovachilli","radius","HS_RADAUTH","1812")
uci.check_set("coovachilli","radius","HS_RADIUS2","127.0.0.1")
uci.check_set("coovachilli","radius","HS_RADACCT","1813")
uci.check_set("coovachilli","radius","HS_RADIUS","127.0.0.1")
uci.check_set("coovachilli","radius","HS_RADSECRET","testing123")
uci.save("coovachilli")
if portal == 2 and userlevel < 2 then
  uci.set("coovachilli","uam","HS_UAMSERVER","192.168.182.1")
  uci.set("coovachilli","uam","HS_UAMFORMAT","http://\$HS_UAMSERVER/cgi-bin/login/login")
  uci.delete("coovachilli","uam","HS_UAMSECRET","")
  uci.set("coovachilli","uam","HS_UAMHOMEPAGE","http://\$HS_UAMLISTEN:\$HS_UAMPORT/www/coova.html")
  uci.set("coovachilli","uam","HS_UAMALLOW","x-wrt.org,coova.org,www.internet-wifi.com.ar")
--[[
  uci.set("coovachilli","radius","HS_RADAUTH","1812")
  uci.set("coovachilli","radius","HS_RADIUS2","127.0.0.1")
  uci.set("coovachilli","radius","HS_RADACCT","1813")
  uci.set("coovachilli","radius","HS_RADIUS","127.0.0.1")
  uci.set("coovachilli","radius","HS_RADSECRET","testing123")
]]--
end
uci.save("coovachilli")

function set_menu()
  __MENU.HotSpot["Coova-Chilli"] = menuClass.new()
  __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Core#Core","coova-chilli.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_DHCP#Network","coova-chilli.sh?option=net")
  end
  __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Portal#Portal","coova-chilli.sh?option=uam")

  if radconf < 2 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Radius#Radius","coova-chilli.sh?option=radius")
  end
  __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_NasId#NAS ID","coova-chilli.sh?option=nasid")
  if radconf > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Users#Users","coova-chilli.sh?option=users")
  end
  if radconf > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Communities#Communities","coova-chilli.sh?option=communities")
  end
--  if tonumber(hotspot.service.enable) == 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Connections#Connections","coova-chilli.sh?option=connections")
--  end
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Access#Access","coova-chilli.sh?option=access")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Proxy#Proxy","coova-chilli.sh?option=proxy")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Scripts#Extras","coova-chilli.sh?option=extras")
  
  __WIP = 4
end

function core_form()
  form = formClass.new(tr("chilli_title_service#Service"))
	form:Add("select","coovachilli.webadmin.enable",uci.check_set("coovachilli","webadmin","enable","0"),tr("chilli_var_service#Service"),"string")
	form["coovachilli.webadmin.enable"].options:Add("0","Disable")
	form["coovachilli.webadmin.enable"].options:Add("1","Enable")
	form:Add("select","coovachilli.webadmin.userlevel",uci.check_set("coovachilli","webadmin","userlevel","0"),tr("userlevel#User Level"),"string")
	form["coovachilli.webadmin.userlevel"].options:Add("0","Select Mode")
	form["coovachilli.webadmin.userlevel"].options:Add("1","Beginer")
	form["coovachilli.webadmin.userlevel"].options:Add("2","Medium")
--	form["coovachilli.webadmin.userlevel"].options:Add("3","Advanced")
--	form["coovachilli.webadmin.userlevel"].options:Add("4","Expert")
  if userlevel > 1 then
  	form:Add("select","coovachilli.webadmin.portal",uci.check_set("coovachilli","webadmin","portal","2"),tr("portal#Portal Settings"),"string")
--  	form["coovachilli.webadmin.portal"].options:Add("0","Coova Server")
    form["coovachilli.webadmin.portal"].options:Add("2","Internal Server")
    form["coovachilli.webadmin.portal"].options:Add("1","Remote Server")

    form:Add("select","coovachilli.webadmin.radconf",uci.check_set("coovachilli","webadmin","radconf","1"),tr("authentication_users#Authenticate Users Mode"),"string")
    form["coovachilli.webadmin.radconf"].options:Add("2","Local Radius Users")
--    form["coovachilli.webadmin.radconf"].options:Add("0","Remote Radius")
    form["coovachilli.webadmin.radconf"].options:Add("1","Communities Users")
    form["coovachilli.webadmin.radconf"].options:Add("3","Remote & Local Users")
  end
  if userlevel < 2 then
    form:Add("select","coovachilli.net.HS_LANIF",uci.check_set("coovachilli","net","HS_LANIF","wl0"),tr("cportal_var_device#Device Network"),"string")
    for k, v in pairs(net.wireless()) do
      form["coovachilli.net.HS_LANIF"].options:Add(k,k)
    end
  end
  uci.save("coovachilli")
  return form
end

function net_form(form,user_level,localuam)
  local user_level = user_level or userlevel
  local form = form
--  local network = {}
--  network["values"] = hotspot.network or hotspot:set("chilli","network")
--  network["name"] = hotspot.__PACKAGE..".network"
  if form == nil then
    form = formClass.new(tr("Network Settings"))
  else
    form:Add("subtitle",tr("Networ Settings"))
  end
  local dev
  if user_level > 1 then
    dev = net.ifname() -- for advanced users
  else
    dev = net.wireless() -- for beginers users
  end
  form:Add("select","coovachilli.net.HS_LANIF",uci.check_set("coovachilli.net.HS_LANIF"),tr("cportal_var_device#Device Network"),"string")
  for k, v in pairs(dev) do
    form["coovachilli.net.HS_LANIF"].options:Add(k,k)
  end
  form:Add("text", "coovachilli.net.HS_DNS_DOMAIN", uci.check_set("coovachilli","net","HS_DNS_DOMAIN",""),tr("cportal_var_net#Domain"),"string")
  form:Add("text", "coovachilli.net.HS_UAMLISTEN", uci.check_set("coovachilli","net","HS_UAMLISTEN","192.168.182.1"),tr("cportal_var_net#Listen"),"string")
  form:Add("text", "coovachilli.net.HS_UAMPORT", uci.check_set("coovachilli","net","HS_UAMPORT","3990"),tr("cportal_var_net#Port"),"string")
  form:Add("text", "coovachilli.net.HS_NETWORK", uci.check_set("coovachilli","net","HS_NETWORK","192.168.182.0"),tr("cportal_var_net#Network"),"string")
  form:Add("text", "coovachilli.net.HS_NETMASK", uci.check_set("coovachilli","net","HS_NETMASK","255.255.255.0"),tr("cportal_var_net#Network"),"string")
  form:Add("text", "coovachilli.net.HS_STATIP", uci.check_set("coovachilli","net","HS_STATIP",""),tr("cportal_var_staticip#Static IP"),"string")
  form:Add("text", "coovachilli.net.HS_STATIP_MASK", uci.check_set("coovachilli","net","HS_STATIP_MASK",""),tr("cportal_var_staticip#Static IP Mask"),"string")
  form:Add("text", "coovachilli.net.HS_DYNIP", uci.check_set("coovachilli","net","HS_DYNIP","1"),tr("cportal_var_dynip#Dynamic IP"),"string")
  form:Add("text", "coovachilli.net.HS_DYNIP_MASK", uci.check_set("coovachilli","net","HS_DYNIP_MASK",""),tr("cportal_var_staticip#Dynamic IP Mask"),"string")
  form:Add("text", "coovachilli.net.HS_DNS1", uci.check_set("coovachilli","net","HS_DNS1","192.168.182.1"),tr("cportal_var_dns#DNS Server").." 1","string")
  form:Add("text", "coovachilli.net.HS_DNS2", uci.check_set("coovachilli","net","HS_DNS2","204.225.44.3"),tr("cportal_var_dns#DNS Server").." 2","string")
  return form
end

function set_rad_local(user_level, localrad)
  local localrad = localrad or radconf
  local user_level = user_level or userlevel
  uci.set("coovachilli","webadmin","radconf",localrad)  
  uci.set("coovachilli","webadmin","userlevel",user_level)

  uci.set("coovachilli","radius","HS_RADIUS","127.0.0.1") 
  uci.set("coovachilli","radius","HS_RADIUS2","127.0.0.1") 
  uci.set("coovachilli","radius","HS_RADAUTH","1812") 
  uci.set("coovachilli","radius","HS_RADACCT","1813") 
  uci.set("coovachilli","radius","HS_RADSECRET","testing123")
  uci.save("coovachilli") 
end
    
function radius_form(form,user_level,localrad)
  local form = form
  local user_level = user_level or userlevel
  local localrad = localrad or radconf

  if userlevel ~= user_level then uci.set("coovachilli","webadmin","user",user_level) end
  if localrad ~= radconf then 
    uci.set("coovachilli","webadmin","radconf",localrad)
  end
  if localrad == 1 then 
    uci.set("coovachilli","radius","HS_RADIUS","rad01.internet-wifi.com.ar") 
    uci.set("coovachilli","radius","HS_RADIUS2","rad02.internet-wifi.com.ar") 
    uci.set("coovachilli","radius","HS_RADAUTH","1812") 
    uci.set("coovachilli","radius","HS_RADACCT","1813") 
    uci.set("coovachilli","radius","HS_RADSECRET","Internet-Wifi")
    uci.save("coovachilli") 
  end

  if form == nil then
    form = formClass.new(tr("Captive Portal - Radius Settings"))
  else
    if localrad == 0 then
      form:Add("subtitle",tr("Remote").." "..tr("Radius Settings"))
    else
      form:Add("subtitle",tr("Local").." "..tr("Radius Settings"))
    end    
  end
----	Input Section form
    form:Add("text","coovachilli.radius.HS_RADIUS",uci.check_set("coovachilli","radius","HS_RADIUS","rad01.internet-wifi.com.ar"),tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
    form:Add("text","coovachilli.radius.HS_RADIUS2",uci.check_set("coovachilli","radius","HS_RADIUS2","rad02.internet-wifi.com.ar"),tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
    form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))

    form:Add("text","coovachilli.radius.HS_RADSECRET",uci.check_set("coovachilli","radius","HS_RADSECRET","testing123"),tr("chilli_var_rradiussecret#Remote Radius Secret"),"string")
    form:Add_help(tr("chilli_var_rradiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))

    form:Add("text","coovachilli.radius.HS_RADAUTH",uci.check_set("coovachilli","radius","HS_RADAUTH",""),tr("chilli_var_radiusauthport#Authentication Port"),"string")
    form:Add("text","coovachilli.radius.HS_RADACCT",uci.check_set("coovachilli","radius","HS_RADACCT",""),tr("chilli_var_radiusacctport#Accounting Port"),"string")
    form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
--  end
  return form
end

function nasid_form(form,user_level)
  local form = form
  local user_level = user_level or userlevel

  if form == nil then
    form = formClass.new(tr("Captive Portal - NAS Identification"))
  else
    form:Add("subtitle",tr("NAS Identification"))
  end
--  form:Add("subtitle",tr("NAS Identification"))
	form:Add("text","coovachilli.nas.HS_NASID",uci.check_set("coovachilli","nas","HS_NASID","X-Wrt NAS"),tr("cportal_var_radiusnasid#NAS ID"),"string")
  form:Add("text","coovachilli.nas.HS_LOC_NAME",uci.check_set("coovachilli","nas","HS_LOC_NAME","My X-Wrt HotSpot"),tr("cportal_var_radiusnasip#Location Name"),"string")
	form:Add("text","coovachilli.nas.HS_LOC_NETWORK",uci.check_set("coovachilli","nas","HS_LOC_NETWORK","X-Wrt Network"),tr("cportal_var_radiusnasporttype#Network name"),"string")
	form:Add("text","coovachilli.nas.HS_LOC_AC",uci.check_set("coovachilli","nas","HS_LOC_AC",""),tr("cportal_var_radiuslocationid#Phone area code"),"string")
	form:Add("text","coovachilli.nas.HS_LOC_CC",uci.check_set("coovachilli","nas","HS_LOC_CC",""),tr("cportal_var_radiuslocationname#Phone country code"),"string")
	form:Add("text","coovachilli.nas.HS_LOC_ISOCC",uci.check_set("coovachilli","nas","HS_LOC_ISOCC",""),tr("cportal_var_isocc#ISO Country code"),"string")
  uci.save("coovachilli")
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

  if user_level > 1 and localuam < 2 then
    form:Add("text","coovachilli.uam.HS_UAMSERVER",uci.check_set("coovachilli","uam","HS_UAMSERVER","192.168.182.1"),tr("cportal_var_uamserver#URL of Web Server"),"string","width:90%")
    form:Add_help(tr("cportal_var_uamserver#URL of Web Server"),tr("cportal_help_uamserver#URL of a Webserver handling the authentication."))

    form:Add("text","coovachilli.uam.HS_UAMFORMAT",uci.check_set("coovachilli","uam","HS_UAMFORMAT","http://\$HS_UAMSERVER/cgi-bin/login/login"),tr("cportal_var_format#Path of Login Page"),"string","width:90%")
    form:Add_help(tr("cportal_var_format#URL of Web Server"),tr("cportal_help_format#URL of a Webserver handling the authentication."))

    form:Add("text","coovachilli.uam.HS_UAMSECRET",uci.check_set("coovachilli","uam","HS_UAMSECRET",""),tr("cportal_var_uamsecret#UAM Secret"),"string")
    form:Add_help(tr("cportal_var_uamsecret#Web Secret"),tr("cportal_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))

    if user_level > 2 then
      form:Add("text","coovachilli.uam.HS_UAMHOMEPAGE",uci.check_set("coovachilli","uam","HS_UAMHOMEPAGE","http://\$HS_UAMLISTEN:\$HS_UAMPORT/www/coova.html"),tr("cportal_var_uamhomepage#UAM Home Page"),"string","width:90%")
      form:Add_help(tr("cportal_var_uamhomepage#Homepage"),tr("cportal_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))
    end
  end
  form:Add("text_area","coovachilli.uam.HS_UAMALLOW",uci.check_set("coovachilli","uam","HS_UAMALLOW","x-wrt.org,coova.org,www.internet-wifi.com.ar"),tr("cportal_var_uamallowed#UAM Allowed"),"string","width:90%")
  form:Add_help(tr("cportal_var_uamallowed#Allowed URLs"),tr("cportal_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))
  uci.save("coovachilli")
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

