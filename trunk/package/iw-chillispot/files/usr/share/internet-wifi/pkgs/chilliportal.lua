require("net")
require("tbform")

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
local hotspot = uciClass.new("chillispot")
local service = hotspot.service or hotspot:set("websettings","service")
local userlevel = tonumber(hotspot.service.userlevel) or 0
local portal = tonumber(hotspot.service.portal) or 0
local users = tonumber(hotspot.service.users) or 0
local chilli = hotspot.chilli
local chillispot = hotspot.chillispot
-- Check if config section exist, if not set it
if chilli == nil then chilli = hotspot:set("chilli") end
if chillispot == nil then chillispot = hotspot:set("chillispot","service") end
local cfg_chilli = hotspot.chilli[1].name
local cfg_chillispot = hotspot.chillispot[1].name
local chilli_val = hotspot.chilli[1].values
local chillispot_val = hotspot.chillispot[1].values



function set_menu()
  __MENU.HotSpot["Chilli Spot"] = menuClass.new()
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Core#Core","chillispot.sh")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Network#Network","chillispot.sh?option=net")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Portal#Portal","chillispot.sh?option=uam")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Radius#Radius","chillispot.sh?option=radius")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Access#Access","chillispot.sh?option=access")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Proxy#Proxy","chillispot.sh?option=proxy")
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Scripts#Scripts","chillispot.sh?option=scripts")

--[[
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Core#Core","coova-chilli.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_DHCP#Network","coova-chilli.sh?option=net")
  end
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Portal#Portal","coova-chilli.sh?option=uam")

  if userlevel > 1 then
    if users == 0 then
      __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Radius#Radius","coova-chilli.sh?option=radius")
    end
  end
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_NasId#NAS ID","coova-chilli.sh?option=nasid")
  if users == 1
  or users == 3 then 
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Users#Users","coova-chilli.sh?option=users")
  end
  if users > 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Communities#Communities","coova-chilli.sh?option=communities")
  end
  if tonumber(hotspot.service.enable) == 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Connections#Connections","coova-chilli.sh?option=connections")
  end
--    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Access#Access","coova-chilli.sh?option=access")
--    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Proxy#Proxy","coova-chilli.sh?option=proxy")
--    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Scripts#Extras","coova-chilli.sh?option=extras")
]]--  
  __WIP = 4
end

function core_form()
  local service = {}
  service["values"] = hotspot.service or hotspot:set("chillispot","service")
  service["name"] = hotspot.__PACKAGE..".service"
  local network = {}
  network["values"] = hotspot.network or hotspot:set("chillispot","network")
  network["name"] = hotspot.__PACKAGE..".network"
  cp_enable = service.values.enable or "0"
  cp_userlevel = service.values.userlevel or "0"
  cp_portal = service.values.portal or "0"
  cp_users = service.values.users or "1"
  

  local forms = {}
	forms[1] = formClass.new(tr("chilli_title_service#Service"))
	forms[1]:Add("select",cfg_chillispot..".enable",chillispot_val.enable,tr("chilli_var_service#Service"),"string")
	forms[1][cfg_chillispot..".enable"].options:Add("0","Disable")
	forms[1][cfg_chillispot..".enable"].options:Add("1","Enable")
	forms[2] = formClass.new(tr("Core Settings"))
----	Input Section form
--	forms[2]:Add("checkbox",cfg_chilli..".fg",chilli_val.fg,tr("chilli_var_foreground#Foreground"))
--	forms[2]:Add("checkbox",cfg_chilli..".debug",chilli_val.debug,tr("chilli_var_debug#Debug"))
	forms[2]:Add("text",cfg_chilli..".interval",chilli_val.interval,tr("chilli_var_interval#Interval"),"int,>1800")
	forms[2]:Add("text",cfg_chilli..".pidfile",chilli_val.pidfile,tr("chilli_var_pidfile#Pid file"),"string","width:90%")
	forms[2]:Add("text",cfg_chilli..".statedir",chilli_val.statedir,tr("chilli_var_statedir#State dir"),"string","width:90%")
	forms[2]:Add("text",cfg_chilli..".confusername",chilli_val.confusername,tr("chilli_var_confusername#Conf username"),"string")
	forms[2]:Add("text",cfg_chilli..".confpassword",chilli_val.confpassword,tr("chilli_var_confpassword#Conf password"),"string")
--	forms[2][cfg_chilli..".fg"].checked = 1
--	forms[2][cfg_chilli..".debug"].checked = 1
----	Help section	
	forms[2]:Add_help(tr("chilli_var_interval#Interval"),tr("chilli_help_interval#Re-read configuration file at this interval. Will also cause new domain name lookups to be performed. 	Value is given in seconds. Default value is 3600."))
	forms[2]:Add_help(tr("chilli_var_pidfile#Pid File"),tr("chilli_help_pidfile#File to store information about the process id of the program. The program must have write access to this file/directory. Default is pidfile /var/run/chilli.pid"))
	forms[2]:Add_help(tr("chilli_var_statedir#State Dir"),tr("chilli_help_statedir#Directory to use for nonvolatile storage. The program must have write access to this directory. This tag is currently ignored."))
	forms[2]:Add_help(tr("chilli_var_confuser_pass#Configuration Username and Password"),tr([[chilli_help_confuser_pass#
        If confusername is specified together with confpassword chillispot will 
        at regular intervals specified by the interval option query the radius 
        server for configuration information. The reply from the radius server 
        must have the Service-Type attribute set to ChilliSpot-Authorize-Only 
        in order to have any effect. Currently ChilliSpot-UAM-Allowed, 
        ChilliSpot-MAC-Allowed and ChilliSpot-Interval is supported. These 
        attributes override the uamallowed , macallowed and interval options 
        respectively.          
        ]]))
  return forms

--[[
  form = formClass.new(tr("chilli_title_service#Service"))
	form:Add("select",service.name..".enable",cp_enable,tr("chilli_var_service#Service"),"string")
	form[service.name..".enable"].options:Add("0","Disable")
	form[service.name..".enable"].options:Add("1","Enable")

	form:Add("select",service.name..".userlevel",cp_userlevel,tr("userlevel#User Level"),"string")
	form[service.name..".userlevel"].options:Add("0","Select Mode")
	form[service.name..".userlevel"].options:Add("1","Beginer")
	form[service.name..".userlevel"].options:Add("2","Medium")
--	form[service.name..".userlevel"].options:Add("3","Advanced")
--	form[service.name..".userlevel"].options:Add("4","Expert")
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
  if userlevel < 2 then
    form:Add("select",network.name..".HS_LANIF",network.values.HS_LANIF,tr("cportal_var_device#Device Network"),"string")
    for k, v in pairs(net.wireless()) do
      form[network.name..".HS_LANIF"].options:Add(k,k)
    end
  end
  return form
]]--      

end

function uam_form(form,user_level,localuam) 
  local user_level = user_level or userlevel
  
	form = formClass.new(tr("chilli_portal_title#Portal Settings"))
----	Input Section form
  if user_level > 1 then
  	form:Add("text",cfg_chilli..".uamserver",chilli_val.uamserver,tr("chilli_var_uamserver#UAM Server"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamserver#UAM Server"),tr("chilli_help_uamserver#URL of a Webserver handling the authentication."))

    form:Add("text",cfg_chilli..".uamsecret",chilli_val.uamsecret,tr("chilli_var_uamsecret#UAM Secret"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamsecret#UAM Secret"),tr("chilli_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))

    form:Add("text",cfg_chilli..".uamhomepage",chilli_val.uamhomepage,tr("chilli_var_uamhomepage#UAM Home Page"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamhomepage#UAM Homepage"),tr("chilli_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))

    form:Add("text",cfg_chilli..".uamlisten",chilli_val.uamlisten,tr("chilli_var_uamlisten#UAM Listen"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamlisten#UAM Listen"),tr("chilli_help_uamlisten#IP Address to listen to for authentication requests."))

    form:Add("text",cfg_chilli..".uamport",chilli_val.uamport,tr("chilli_var_uamport#UAM Port"),"string")
    form:Add_help(tr("chilli_var_uamport#UAM Port"),tr("chilli_help_uamport#TCP port to listen to for authentication requests."))
  end
  form:Add("text_area",cfg_chilli..".uamallowed",chilli_val.uamallowed,tr("chilli_var_uamallowed#UAM Allowed"),"string","width:90%")
  form:Add_help(tr("chilli_var_uamallowed#UAM Allowed"),tr("chilli_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))

  return form
end

function net_form(form,user_level,localuam) 
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_dhcp_title#DHCP Settings"))
----	Input Section form
	form:Add("select",cfg_chilli..".dhcpif",chilli_val.dhcpif,tr("chilli_var_dhcpif#Interface"))
--	for i,v in pairsByKeys(get_interfaces()) do
--		form[cfg_chilli..".dhcpif"].options:Add(i,i)
--	end
	form:Add("text",cfg_chilli..".domain",chilli_val.domain,tr("chilli_var_doman#Domain"),"string","width:90%")
	form:Add("text",cfg_chilli..".net",chilli_val.net,tr("chilli_var_net#Network"),"string")
	form:Add("text",cfg_chilli..".dynip",chilli_val.dynip,tr("chilli_var_dynip#Dynamic IP Pool"),"string")
	form:Add("text",cfg_chilli..".statip",chilli_val.statip,tr("chilli_var_statip#Static IP Pool"),"string")
	form:Add("checkbox",cfg_chilli..".uamanydns",chilli_val.uamanydns,tr("chilli_var_uamanydns#Any DNS"))
	form:Add("text",cfg_chilli..".dns1",chilli_val.dns1,tr("chilli_var_dns1#Primary DNS"),"string")
	form:Add("text",cfg_chilli..".dns2",chilli_val.dns2,tr("chilli_var_dns2#Secondary DNS"),"string")
	form:Add("text",cfg_chilli..".dhcpmac",chilli_val.dhcpmac,tr("chilli_var_dhcpmac#DHCP MAC"),"string")
	form:Add("text",cfg_chilli..".lease",chilli_val.lease,tr("chilli_var_lease#Lease"),"string")
	form:Add("checkbox",cfg_chilli..".eapolenable",chilli_val.eapolenable ,tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),"string")
----	Help section	
	form:Add_help(tr("chilli_var_dhcpif#Interface"),tr("chilli_help_dhcpif#This is the network interface which is connected to the access points."))
	form:Add_help(tr("chilli_var_domain#Domain Name"),tr("chilli_help_domain#Will be suggested to the client."))
	form:Add_help(tr("chilli_var_net#Network"),tr("chilli_help_net#Client's DHCP Network IP Subnet (192.168.182.0/24 by default)."))
	form:Add_help(tr("chilli_var_dynip#Dynamic IP Pool"),tr("chilli_help_dynip#Allocation of dynamic IP Addresses to clients."))
	form:Add_help(tr("chilli_var_statip#Static IP Pool"),tr("chilli_help_statip#Allocation of static IP Addresses."))
	form:Add_help(tr("chilli_var_uamanydns#Any DNS"),tr("chilli_help_uamanydns#If enabled, users will be allowed to user any other dns server they specify."))
	form:Add_help(tr("chilli_var_dhcpmac#DHCP MAC"),tr([[chilli_help_dhcpmac#
        MAC address to listen to. If not specified the MAC address of the interface will be used. The MAC address should be chosen so that it does not conflict with other addresses on the LAN. An address in the range 00:00:5E:00:02:00 - 00:00:5E:FF:FF:FF falls within the IANA range of addresses and is not allocated for other purposes.<br> 
        The --dhcpmac option can be used in conjunction with access filters in the access points, or with access points which supports packet forwarding to a specific MAC address. Thus it is possible at the MAC level to separate access point management traffic from user traffic for improved system security. <br>
        The --dhcpmac option will set the interface in promisc mode.
          ]]))
	form:Add_help(tr("chilli_var_lease#DHCP Lease"),tr("chilli_help_lease#Time before DHCP lease expires"))
	form:Add_help(tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),tr([[
        If this option is given IEEE 802.1x authentication is enabled. 
        ChilliSpot will listen for EAP authentication requests on the interface 
        specified by --dhcpif. EAP messages received on this interface are 
        forwarded to the radius server.
        ]]))
  return form
end

function radius_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_radius_title#Radius Settings"))
----	Input Section form
	form:Add("text",cfg_chilli..".radiusserver1",     chilli_val.radiusserver1,tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiusserver2",     chilli_val.radiusserver2,tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiusauthport",    chilli_val.radiusauthport,tr("chilli_var_radiusauthport#Authentication Port"),"string")
	form:Add("text",cfg_chilli..".radiusacctport",    chilli_val.radiusacctport,tr("chilli_var_radiusacctport#Accounting Port"),"string")
  form:Add("text",cfg_chilli..".radiussecret",      chilli_val.radiussecret,tr("chilli_var_radiussecret#Radius Secret"),"string")
  form:Add("subtitle",tr("NAS Identification"))
	form:Add("text",cfg_chilli..".radiusnasid",       chilli_val.radiusnasid,tr("chilli_var_radiusnasid#NAS ID"),"string")
	form:Add("text",cfg_chilli..".radiusnasip",       chilli_val.radiusnasip,tr("chilli_var_radiusnasip#NAS IP"),"string")
	form:Add("text",cfg_chilli..".radiusnasporttype", chilli_val.radiusporttype,tr("chilli_var_radiusnasporttype#NAS Port type"),"int")
	form:Add("text",cfg_chilli..".radiuslocationid",  chilli_val.radiuslocationid,tr("chilli_var_radiuslocationid#Location ID"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiuslocationname",chilli_val.radiuslocationname,tr("chilli_var_radiuslocationname#Location Name"),"string","width:90%")
	form:Add("text",cfg_chilli..".radiuslisten",      chilli_val.radiuslisten,tr("chilli_var_radiuslisten#Listen Interface IP"),"string")
	form:Add("text",cfg_chilli..".radiuscalled",      chilli_val.radiuscalled,tr("chilli_var_radiuscalled#Called Station ID"),"string","width:90%")
  form:Add("subtitle","Radius request disconnection")
	form:Add("text",cfg_chilli..".coaport",      chilli_val.coaport,tr("chilli_var_coaport#UDP port"),"string")
	form:Add("checkbox",cfg_chilli..".coanoipcheck",chilli_val.coanoipcheck ,tr("chilli_var_coanoipcheck#No check radius IP"),"string")
----	Help section	
	form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))
	form:Add_help(tr("chilli_var_radiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))
	form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
	form:Add_help(tr("chilli_var_radiuslocationid#Location ID"),tr("chilli_help_radiuslocatioid#WISPr Location ID. Should be in the format: isocc=&lt;ISO_Country_Code&gt;, cc=&lt;E.164_Country_Code&gt;, ac=&lt;E.164_Area_Code&gt;, network=&lt;ssid/ZONE&gt;"))
	form:Add_help(tr("chilli_var_radiuslocationname#Location Name"),tr("chilli_help_radiuslocationname#WISPr Location Name. Should be in the format: &lt;HOTSPOT_OPERATOR_NAME&gt;, &lt;LOCATION&gt;"))
	form:Add_help(tr("chilli_var_radiuslisten#Listen Interface IP"),tr([[
          chilli_help_radiuslisten#Local interface IP address to use for the 
          radius interface. This option also determines the value for the 
          NAS-IP-Address radius attribute. If radiuslisten is omitted then the 
          NAS-IP-Address attribute will be set to "0.0.0.0" and the source IP 
          address of the radius requests will be determined by the operating 
          system routing tables. ]]))
	form:Add_help(tr("chilli_var_radiuscalled#Called station ID"),tr(
          [[Name to report in Called-Station-ID attribute. Defaults to mac 
          address of wireless interface which can be specified by the dhcpmac 
          option. ]]
	       ))
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

function access_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_access#Access List Setting"))
----	Input Section form
	form:Add("checkbox",cfg_chilli..".macauth",chilli_val.macauth,tr("chilli_var_macauth#MAC Authentication"))
	form:Add("text",cfg_chilli..".macallowed",chilli_val.macallowed,tr("chilli_var_macallowed#MAC Allowed"),"string","width:90%")
	form:Add("text",cfg_chilli..".macpassword",chilli_val.macpassword,tr("chilli_var_macpassword#MAC Password"),"string")
	form:Add("text",cfg_chilli..".macsuffix",chilli_val.macsuffix,tr("chilli_var_macsuffix#MAC Suffix"),"string")
----	Help section	
	form:Add_help(tr("chilli_var_macauth#MAC Authentication"),tr("chilli_help_macauth#If enabled, users will be authenticated only based on their MAC Address."))
	form:Add_help(tr("chilli_var_macallowed#MAC Allowed"),tr("chilli_help_macallowed#List of allowed MAC Addresses."))
	form:Add_help(tr("chilli_var_macpassword#MAC Password"),tr("chilli_help_macpassword#Password to use for MAC authentication."))
	form:Add_help(tr("chilli_var_macsuffix#MAC Suffix"),tr("chilli_help_macsuffix#Suffix to add to the username in-order to form the username."))
  return form
end

function proxy_form(form,user_level,localrad)
  local user_level = user_level or userlevel
	form = formClass.new(tr("chilli_title_proxy#Proxy Settings"))
----	Input Section form
	form:Add("text",cfg_chilli..".proxylisten",chilli_val.proxylisten,tr("chilli_var_proxylisten#Listen"),"string")
	form:Add("text",cfg_chilli..".porxyport",chilli_val.proxyport,tr("chilli_var_proxyport#Port"),"string")
	form:Add("text",cfg_chilli..".proxysecret",chilli_val.proxysecret,tr("chilli_var_proxysecret#Secret"),"string")
	form:Add("text",cfg_chilli..".proxyclient",chilli_val.proxyclient,tr("chilli_var_proxyclient#Client"),"string")
----	Help section	
	form:Add_help(tr("chilli_var_proxylisten#Listen"),tr("chilli_help_proxylisten#IP Address to listen to (advanced uses only)."))
	form:Add_help(tr("chilli_var_proxyport#Port"),tr("chilli_help_proxyport#UDP port to listen to."))
	form:Add_help(tr("chilli_var_proxysecret#Secret"),tr("chilli_help_proxysecret#RADIUS Shared Secret to accept for all clients."))
	form:Add_help(tr("chilli_var_proxyclient#Client"),tr("chilli_help_proxyclient#Clients from which we accept RADIUS Requests."))

  return form
end

function script_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_scripts#Scripts Settings"))
----	Input Section form
	form:Add("text",cfg_chilli..".ipup",chilli_val.ipup,tr("chilli_var_ipup#IP Up"),"string","width:90%")
	form:Add("text",cfg_chilli..".ipdown",chilli_val.ipdown,tr("chilli_var_ipdown#IP Down"),"string","width:90%")
	form:Add("text",cfg_chilli..".conup",chilli_val.conup,tr("chilli_var_conup#Connection Up"),"string","width:90%")
	form:Add("text",cfg_chilli..".condown",chilli_val.condown,tr("chilli_var_condown#Connection Down"),"string","width:90%")
----	Help section	
	form:Add_help(tr("chilli_help_title_ip#/etc/chilli.ipup and /etc/chilli.ipdown"),tr("chilli_help_ip#Script executed after network interface has been brought up. Executed with the following parameters: (devicename) (ip address) (mask)."))
	form:Add_help(tr("chilli_help_title_con#/etc/chilli.conup and /etc/chilli.condown"),tr("chilli_help_con#Script executed after a user has disconnected. Executed with the following parameters: (devicename) (ip address) (mask) (user ip address) (user mac address) (filter ID)."))

  return form
end

 