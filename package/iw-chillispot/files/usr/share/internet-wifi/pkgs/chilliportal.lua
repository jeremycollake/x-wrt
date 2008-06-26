require("net")
require("tbform")
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
  if uci.get("chillispot.radius") == nil then
    uci.set("chillispot.radius=settings")
  end
  if uci.get("chillispot.uam") == nil then
    uci.set("chillispot.uam=settings")
  end
  if uci.get("chillispot.net") == nil then
    uci.set("chillispot.net=settings")
  end

  if uci.get("chillispot","webadmin","chillispot") == nil then
    uci.set("chillispot","webadmin","chillispot")
  end
  if uci.get("chillispot","webadmin","enable") == nil then
    uci.set("chillispot","webadmin","enable","1")
  end
  if uci.get("chillispot","webadmin","userlevel") == nil then
    uci.set("chillispot","webadmin","userlevel","1")
  end
  if uci.get("chillispot","webadmin","portal") == nil then
    uci.set("chillispot","webadmin","portal","0")
  end
  if uci.get("chillispot","webadmin","radconf") == nil then
    uci.set("chillispot","webadmin","radconf","1")
  end
--  if uci.get("chillispot","settings") == nil then
--    uci.set("chillispot","settings","chilli")
--  end
  uci.save("chillispot")
  if uci.get("chillispot","uam","uamserver") == nil then
    uci.set("chillispot","uam","uamserver","http://www.internet-wifi.com.ar/hotspotlogin_m.php")
  end
  if uci.get("chillispot","uam","uamsecret") == nil then
    uci.set("chillispot","uam","uamsecret","Internet-Wifi")
  end
  if uci.get("chillispot","uam","uamhomepage") == nil then
    uci.set("chillispot","uam","uamhomepage","http://192.168.182.1/owner.html")
  end
  if uci.get("chillispot.uam.uamlisten") == nil then
    uci.set("chillispot.uam.uamlisten=192.168.182.1")
  end
  if uci.get("chillispot.uam.uamport") == nil then
    uci.set("chillispot.uam.uamport=3990")
  end
  if uci.get("chillispot.uam.uamallowed") == nil then
    uci.set("chillispot","uam","uamallowed","x-wrt.org,www.internet-wifi.com.ar")
  end
  uci.save("chillispot")
  if uci.get("chillispot.net.net") == nil then
    uci.set("chillispot","net","net",uci.get("chillispot.uam.uamlisten").."/24")
  end
  if uci.get("chillispot.net.uamanydns") == nil then
    uci.set("chillispot.net.uamanydns=1")
  end
  if uci.get("chillispot.net.dns1") == nil then
    uci.set("chillispot","net","dns1",uci.get("chillispot.uam.uamlisten"))
  end
  
  uci.save("chillispot")

local userlevel = tonumber(uci.get("chillispot","webadmin","userlevel"))
local radconf = tonumber(uci.get("chillispot","webadmin","radconf"))

if uci.get("chillispot","radius","radiusserver1") == nil then 
  uci.set("chillispot","radius","radiusserver1","rad01.internet-wifi.com.ar")
end
if uci.get("chillispot","radius","radiusserver2") == nil then
  uci.set("chillispot","radius","radiusserver2","rad02.internet-wifi.com.ar")
end
if uci.get("chillispot.radius.radiussecret") == nil then
  uci.set("chillispot.radius.radiussecret=Internet-Wifi")
end
uci.save("chillispot")


function set_menu()
  __MENU.HotSpot["Chilli Spot"] = menuClass.new()
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Core#Core","chillispot.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Network#Network","chillispot.sh?option=net")
  end
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Portal#Portal","chillispot.sh?option=uam")
  if radconf < 2 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Radius#Radius","chillispot.sh?option=radius")
  end
  if radconf > 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Users#Users","chillispot.sh?option=users")
    if radconf > 2 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Communities#Communities","chillispot.sh?option=communities")
    end
  end
  if userlevel > 2 then
    if radconf < 2 then
      __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Access#Access","chillispot.sh?option=access")
      __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Proxy#Proxy","chillispot.sh?option=proxy")
    end
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Scripts#Scripts","chillispot.sh?option=scripts")
  end
  __WIP = 4
end

function core_form(form,user_level)
  local user_level = user_level or userlevel
  if user_level ~= userlevel then uci.set("chillispot","webadmin","userlevel",user_level) end   

  form = formClass.new(tr("chilli_title_service#Service"))
	form:Add("select","chillispot.webadmin.enable",uci.get("chillispot","webadmin","enable"),tr("chilli_var_service#Service"),"string")
	form["chillispot.webadmin.enable"].options:Add("0","Disable")
	form["chillispot.webadmin.enable"].options:Add("1","Enable")

  if string.find(__SERVER["SCRIPT_FILENAME"],"chillispot.sh") then
	form:Add("select","chillispot.webadmin.userlevel",uci.get("chillispot","webadmin","userlevel"),tr("userlevel#User Level"),"string")
	form["chillispot.webadmin.userlevel"].options:Add("0","Select Mode")
	form["chillispot.webadmin.userlevel"].options:Add("1","Beginer")
	form["chillispot.webadmin.userlevel"].options:Add("2","Medium")
	form["chillispot.webadmin.userlevel"].options:Add("3","Advanced")
--	form["chillispot.webadmin.userlevel"].options:Add("4","Expert")
  end
  if user_level > 1 then
    form:Add("select","chillispot.webadmin.radconf",uci.get("chillispot","webadmin","radconf"),tr("authentication_users#Authenticate Users Mode"),"string")
    form["chillispot.webadmin.radconf"].options:Add("2","Local Radius Users")
    form["chillispot.webadmin.radconf"].options:Add("1","Communities Users")
    form["chillispot.webadmin.radconf"].options:Add("3","Communities & Local Users")
  end

--  if userlevel < 2 then
    form:Add("select","chillispot.net.dhcpif",uci.get("chillispot","net","dhcpif"),tr("cportal_var_device#Device Network"),"string")
    for k, v in pairs(net.wireless()) do
      form["chillispot.net.dhcpif"].options:Add(k,k)
    end
--  end    
  return form
end

function uam_form(form,user_level,localuam) 
  local user_level = user_level or userlevel
  
	form = formClass.new(tr("chilli_portal_title#Portal Settings"))
----	Input Section form
  if user_level > 1 then
    form:Add("text","chillispot.uam.uamserver",uci.get("chillispot.uam.uamserver"),tr("chilli_var_uamserver#UAM Server"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamserver#UAM Server"),tr("chilli_help_uamserver#URL of a Webserver handling the authentication."))

    form:Add("text","chillispot.uam.uamsecret",uci.get("chillispot.uam.uamsecret"),tr("chilli_var_uamsecret#UAM Secret"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamsecret#UAM Secret"),tr("chilli_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))

    form:Add("text","chillispot.uam.uamhomepage",uci.get("chillispot.uam.uamhomepage"),tr("chilli_var_uamhomepage#UAM Home Page"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamhomepage#UAM Homepage"),tr("chilli_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))
    if user_level > 2 then
      form:Add("text","chillispot.uam.uamlisten",uci.get("chillispot.uam.uamlisten"),tr("chilli_var_uamlisten#UAM Listen"),"string","width:90%")
      form:Add_help(tr("chilli_var_uamlisten#UAM Listen"),tr("chilli_help_uamlisten#IP Address to listen to for authentication requests."))

      form:Add("text","chillispot.uam.uamport",uci.get("chillispot.uam.uamport"),tr("chilli_var_uamport#UAM Port"),"string")
      form:Add_help(tr("chilli_var_uamport#UAM Port"),tr("chilli_help_uamport#TCP port to listen to for authentication requests."))
    end
  end
  form:Add("text_area","chillispot.uam.uamallowed",uci.get("chillispot.uam.uamallowed"),tr("chilli_var_uamallowed#UAM Allowed"),"string","width:90%")
  form:Add_help(tr("chilli_var_uamallowed#UAM Allowed"),tr("chilli_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))
  return form
end

function net_form(form,user_level,localuam) 
  local user_level = user_level or userlevel

  if user_level > 1 then 
    form = formClass.new(tr("chilli_dhcp_title#DHCP Settings"))
----	Input Section form
    form:Add("select","chillispot.net.dhcpif",uci.get("chillispot.net.dhcpif"),tr("chilli_var_dhcpif#Interface"))
--    for i,v in pairsByKeys(get_interfaces()) do
--      form["chillispot.net.dhcpif"].options:Add(i,i)
--    end
  	form:Add_help(tr("chilli_var_dhcpif#Interface"),tr("chilli_help_dhcpif#This is the network interface which is connected to the access points."))
    if user_level > 2 then
      form:Add("text","chillispot.net.domain",uci.get("chillispot.net.domain"),tr("chilli_var_doman#Domain"),"string","width:90%")
      form:Add_help(tr("chilli_var_domain#Domain Name"),tr("chilli_help_domain#Will be suggested to the client."))
    end
    form:Add("text","chillispot.net.net",uci.get("chillispot.net.net"),tr("chilli_var_net#Network"),"string")
  	form:Add_help(tr("chilli_var_net#Network"),tr("chilli_help_net#Client's DHCP Network IP Subnet (192.168.182.0/24 by default)."))
    if user_level > 2 then
      form:Add("text","chillispot.net.dynip",uci.get("chillispot.net.dynip"),tr("chilli_var_dynip#Dynamic IP Pool"),"string")
      form:Add_help(tr("chilli_var_dynip#Dynamic IP Pool"),tr("chilli_help_dynip#Allocation of dynamic IP Addresses to clients."))

      form:Add("text","chillispot.net.statip",uci.get("chillispot.net.statip"),tr("chilli_var_statip#Static IP Pool"),"string")
      form:Add_help(tr("chilli_var_statip#Static IP Pool"),tr("chilli_help_statip#Allocation of static IP Addresses."))
    end
  end
	form:Add("checkbox","chillispot.net.uamanydns",uci.get("chillispot.net.uamanydns"),tr("chilli_var_uamanydns#Any DNS"))
  if user_level > 1 then
    form:Add("text","chillispot.net.dns1",uci.get("chillispot.net.dns1"),tr("chilli_var_dns1#Primary DNS"),"string")
    form:Add("text","chillispot.net.dns2",uci.get("chillispot.net.dns2"),tr("chilli_var_dns2#Secondary DNS"),"string")
  	form:Add_help(tr("chilli_var_uamanydns#Any DNS"),tr("chilli_help_uamanydns#If enabled, users will be allowed to user any other dns server they specify."))
    if user_level > 2 then
      form:Add("text","chillispot.net.dhcpmac",uci.get("chillispot.net.dhcpmac"),tr("chilli_var_dhcpmac#DHCP MAC"),"string")
    	form:Add_help(tr("chilli_var_dhcpmac#DHCP MAC"),tr([[chilli_help_dhcpmac#
        MAC address to listen to. If not specified the MAC address of the interface will be used. The MAC address should be chosen so that it does not conflict with other addresses on the LAN. An address in the range 00:00:5E:00:02:00 - 00:00:5E:FF:FF:FF falls within the IANA range of addresses and is not allocated for other purposes.<br> 
        The --dhcpmac option can be used in conjunction with access filters in the access points, or with access points which supports packet forwarding to a specific MAC address. Thus it is possible at the MAC level to separate access point management traffic from user traffic for improved system security. <br>
        The --dhcpmac option will set the interface in promisc mode.
          ]]))
    end
    form:Add("text","chillispot.net.lease",uci.get("chillispot.net.lease"),tr("chilli_var_lease#Lease"),"string")
    form:Add_help(tr("chilli_var_lease#DHCP Lease"),tr("chilli_help_lease#Time before DHCP lease expires"))
    if user_level > 3 then
      form:Add("checkbox","chillispot.net.eapolenable",uci.get("chillispot.net.eapolenable"),tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),"string")
      form:Add_help(tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),tr([[
        If this option is given IEEE 802.1x authentication is enabled. 
        ChilliSpot will listen for EAP authentication requests on the interface 
        specified by --dhcpif. EAP messages received on this interface are 
        forwarded to the radius server.
        ]]))
    end
  end
----	Help section	
  return form
end

function set_rad_local(user_level, localrad)
  local localrad = localrad or radconf
  local user_level = user_level or userlevel
  uci.set("chillispot","webadmin","radconf",localrad)  
  uci.set("chillispot","webadmin","userlevel",user_level)

  uci.set("chillispot","radius","radiusserver1","127.0.0.1") 
  uci.set("chillispot","radius","radiusserver2","127.0.0.1") 
  uci.set("chillispot","radius","radiusauthport","1812") 
  uci.set("chillispot","radius","radiusacctport","1813") 
  uci.set("chillispot","radius","radiussecret","testing123")
  uci.save("chillispot") 
end
    
function radius_form(form,user_level,rad_conf)
  local user_level = user_level or userlevel
  local rad_conf = rad_conf or radconf
    form = formClass.new(tr("chilli_radius_title#Radius Settings"))
----	Input Section form
    form:Add("text","chillispot.radius.radiusserver1",     uci.get("chillispot.settings.radiusserver1"),tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
    form:Add("text","chillispot.radius.radiusserver2",     uci.get("chillispot.settings.radiusserver2"),tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
    form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))

    form:Add("text","chillispot.radius.radiusauthport",    uci.get("chillispot.settings.radiusauthport"),tr("chilli_var_radiusauthport#Authentication Port"),"string")
    form:Add("text","chillispot.radius.radiusacctport",    uci.get("chillispot.settings.radiusacctport"),tr("chilli_var_radiusacctport#Accounting Port"),"string")
    form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))

    form:Add("text","chillispot.radius.radiussecret",      uci.get("chillispot.settings.radiussecret"),tr("chilli_var_radiussecret#Radius Secret"),"string")
    form:Add_help(tr("chilli_var_radiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))
    if user_level > 1 then
      form:Add("subtitle",tr("NAS Identification"))
      form:Add("text","chillispot.radius.radiusnasid",       uci.get("chillispot.settings.radiusnasid"),tr("chilli_var_radiusnasid#NAS ID"),"string")
      form:Add_help(tr("chilli_var_radiuslocationid#Location ID"),tr("chilli_help_radiuslocatioid#WISPr Location ID. Should be in the format: isocc=&lt;ISO_Country_Code&gt;, cc=&lt;E.164_Country_Code&gt;, ac=&lt;E.164_Area_Code&gt;, network=&lt;ssid/ZONE&gt;"))

      form:Add("text","chillispot.radius.radiusnasip",       uci.get("chillispot.settings.radiusnasip"),tr("chilli_var_radiusnasip#NAS IP"),"string")
      form:Add_help(tr("chilli_var_radiuscalled#Called station ID"),tr(
          [[Name to report in Called-Station-ID attribute. Defaults to mac 
          address of wireless interface which can be specified by the dhcpmac 
          option. ]]
	       ))
      form:Add("text","chillispot.radius.radiusnasporttype", uci.get("chillispot.settings.radiusnasporttype"),tr("chilli_var_radiusnasporttype#NAS Port type"),"int")
      form:Add("text","chillispot.radius.radiuslocationid",  uci.get("chillispot.settings.radiuslocationid"),tr("chilli_var_radiuslocationid#Location ID"),"string","width:90%")
      form:Add("text","chillispot.radius.radiuslocationname",uci.get("chillispot.settings.radiuslocationname"),tr("chilli_var_radiuslocationname#Location Name"),"string","width:90%")
      form:Add_help(tr("chilli_var_radiuslocationname#Location Name"),tr("chilli_help_radiuslocationname#WISPr Location Name. Should be in the format: &lt;HOTSPOT_OPERATOR_NAME&gt;, &lt;LOCATION&gt;"))

      form:Add("text","chillispot.radius.radiuslisten",      uci.get("chillispot.settings.radiuslisten"),tr("chilli_var_radiuslisten#Listen Interface IP"),"string")
      form:Add_help(tr("chilli_var_radiuslisten#Listen Interface IP"),tr([[
          chilli_help_radiuslisten#Local interface IP address to use for the 
          radius interface. This option also determines the value for the 
          NAS-IP-Address radius attribute. If radiuslisten is omitted then the 
          NAS-IP-Address attribute will be set to "0.0.0.0" and the source IP 
          address of the radius requests will be determined by the operating 
          system routing tables. ]]))

      form:Add("text","chillispot.radius.radiuscalled",      uci.get("chillispot.settings.radiuscalled"),tr("chilli_var_radiuscalled#Called Station ID"),"string","width:90%")
      if user_level > 2 then
        form:Add("subtitle","Radius request disconnection")

        form:Add("text","chillispot.radius.coaport",           uci.get("chillispot.settings.coaport"),tr("chilli_var_coaport#UDP port"),"string")
        form:Add_help(tr("chilli_var_coaport#UDP port"),tr(
          [[chilli_help_coaport#
          UDP port to listen to for accepting radius disconnect requests. 
          ]]))

        form:Add("checkbox","chillispot.radius.coanoipcheck",  uci.get("chillispot.settings.coanoipcheck") ,tr("chilli_var_coanoipcheck#No check radius IP"),"string")
        form:Add_help(tr("chilli_var_coanoipcheck#No check radius IP"),tr(
          [[
          If this option is given no check is performed on the source IP address 
          of radius disconnect requests. Otherwise it is checked that radius 
          disconnect requests originate from radiusserver1 or radiusserver2.  
          ]]))
      end
    end
  return form
end

function access_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_access#Access List Setting"))

	form:Add("checkbox","chillispot.access.macauth",uci.get("chillispot.access.macauth"),tr("chilli_var_macauth#MAC Authentication"))
	form:Add_help(tr("chilli_var_macauth#MAC Authentication"),tr("chilli_help_macauth#If enabled, users will be authenticated only based on their MAC Address."))

	form:Add("text","chillispot.access.macallowed",uci.get("chillispot.access.macallowed"),tr("chilli_var_macallowed#MAC Allowed"),"string","width:90%")
	form:Add_help(tr("chilli_var_macallowed#MAC Allowed"),tr("chilli_help_macallowed#List of allowed MAC Addresses."))

	form:Add("text","chillispot.access.macpassword",uci.get("chillispot.access.macpassword"),tr("chilli_var_macpassword#MAC Password"),"string")
	form:Add_help(tr("chilli_var_macpassword#MAC Password"),tr("chilli_help_macpassword#Password to use for MAC authentication."))

	form:Add("text","chillispot.access.macsuffix",uci.get("chillispot.access.macsuffix"),tr("chilli_var_macsuffix#MAC Suffix"),"string")
	form:Add_help(tr("chilli_var_macsuffix#MAC Suffix"),tr("chilli_help_macsuffix#Suffix to add to the username in-order to form the username."))
  return form
end

function proxy_form(form,user_level,localrad)
  local user_level = user_level or userlevel
	form = formClass.new(tr("chilli_title_proxy#Proxy Settings"))
	form:Add("text","chillispot.proxy.proxylisten",uci.get("chillispot.proxy.proxylisten"),tr("chilli_var_proxylisten#Listen"),"string")
	form:Add_help(tr("chilli_var_proxylisten#Listen"),tr("chilli_help_proxylisten#IP Address to listen to (advanced uses only)."))

	form:Add("text","chillispot.proxy.porxyport",uci.get("chillispot.proxy.porxyport"),tr("chilli_var_proxyport#Port"),"string")
	form:Add_help(tr("chilli_var_proxyport#Port"),tr("chilli_help_proxyport#UDP port to listen to."))

	form:Add("text","chillispot.proxy.proxysecret",uci.get("chillispot.proxy.proxysecret"),tr("chilli_var_proxysecret#Secret"),"string")
	form:Add_help(tr("chilli_var_proxysecret#Secret"),tr("chilli_help_proxysecret#RADIUS Shared Secret to accept for all clients."))

	form:Add("text","chillispot.proxy.proxyclient",uci.get("chillispot.proxy.proxyclient"),tr("chilli_var_proxyclient#Client"),"string")
	form:Add_help(tr("chilli_var_proxyclient#Client"),tr("chilli_help_proxyclient#Clients from which we accept RADIUS Requests."))
  return form
end

function script_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_scripts#Scripts Settings"))

	form:Add("text","chillispot.scripts.ipup",uci.get("chillispot.scripts.ipup"),tr("chilli_var_ipup#IP Up"),"string","width:90%")
	form:Add("text","chillispot.scripts.ipdown",uci.get("chillispot.scripts.ipdown"),tr("chilli_var_ipdown#IP Down"),"string","width:90%")
	form:Add_help(tr("chilli_help_title_ip#/etc/chilli.ipup and /etc/chilli.ipdown"),tr("chilli_help_ip#Script executed after network interface has been brought up. Executed with the following parameters: (devicename) (ip address) (mask)."))

	form:Add("text","chillispot.scripts.conup",uci.get("chillispot.scripts.conup"),tr("chilli_var_conup#Connection Up"),"string","width:90%")
	form:Add("text","chillispot.scripts.condown",uci.get("chillispot.scripts.condown"),tr("chilli_var_condown#Connection Down"),"string","width:90%")
	form:Add_help(tr("chilli_help_title_con#/etc/chilli.conup and /etc/chilli.condown"),tr("chilli_help_con#Script executed after a user has disconnected. Executed with the following parameters: (devicename) (ip address) (mask) (user ip address) (user mac address) (filter ID)."))
  return form
end

 