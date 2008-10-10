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
local table = table
local unpack = unpack
local tostring = tostring

--local uciClass = uciClass
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

if __FORM["allowed_site"] and __FORM["allowed_site"] ~= "" then
  local sitesallowed = uci.add("chillispot","sitesallowed")
  uci.set("chillispot",sitesallowed,"site",__FORM["allowed_site"])
end

--[[
local chillisetting = nil
if io.exists("/etc/chilli.conf") then
  chillisetting = io.totable("/etc/chilli.conf",true)
end

uci.set("chillispot","settings","chillispot")

local conf_file = {}
if chillisetting then
  for i=1, #chillisetting do
    local key, value = unpack(string.split(chillisetting[i]," "))
    conf_file[tostring(key)] = tostring(value)
--    uci.isdiff_set("chillispot", "settings", key, value)
  end
end
]]--

uci.check_set("chillispot","settings","chillispot")
uci.check_set("chillispot","webadmin","chillispot")
uci.check_set("chillispot","webadmin","enable","0")

uci.check_set("chillispot","system","chillispot")
uci.check_set("chillispot","system","apply","/usr/lib/lua/lua-wrt/applys/chillispot.lua")

local userlevel = tonumber(uci.check_set("chillispot","webadmin","userlevel","1"))
local radconf = tonumber(uci.check_set("chillispot","webadmin","radconf","1"))
uci.save("chillispot")

function set_menu()
  __MENU.HotSpot["Chilli Spot"] = menuClass.new()
  __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Core#Core","chillispot.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Network#Network","chillispot.sh?option=net")
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Portal#Portal","chillispot.sh?option=uam")

    if radconf < 2 then
    __MENU.HotSpot["Chilli Spot"]:Add("chilli_menu_Radius#Radius","chillispot.sh?option=radius")
    end
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

function core_form(form,user_level,rad_conf)
  local user_level = user_level or userlevel
  local rad_conf = rad_conf or radconf
  if user_level ~= userlevel then uci.set("chillispot","webadmin","userlevel",user_level) end   
  if rad_conf ~= radconf then uci.set("chillispot","webadmin","radconf",rad_conf) end
  if form == nil then
    form = formClass.new(tr("chilli_title_service#Service"))
  else
    form:Add("subtitle",tr("chilli_title_service#Service"))
  end
	form:Add("select","chillispot.webadmin.enable",uci.check_set("chillispot","webadmin","enable","0"),tr("chilli_var_service#Service"),"string")
	form["chillispot.webadmin.enable"].options:Add("0","Disable")
	form["chillispot.webadmin.enable"].options:Add("1","Enable")
  form:Add_help(tr("chillispot_var_enable#Service"),tr("chilli_help_enable#Enable or disable service."))

  if string.find(__SERVER["SCRIPT_FILENAME"],"chillispot.sh") then
    form:Add("select","chillispot.webadmin.userlevel",uci.check_set("chillispot","webadmin","userlevel",user_level),tr("userlevel#User Level"),"string")
    form["chillispot.webadmin.userlevel"].options:Add("0","Select Mode")
    form["chillispot.webadmin.userlevel"].options:Add("1","Beginer")
    form["chillispot.webadmin.userlevel"].options:Add("2","Medium")
    form["chillispot.webadmin.userlevel"].options:Add("3","Advanced")
--    form["chillispot.webadmin.userlevel"].options:Add("4","Expert")
  else
    uci.set("chillispot.webadmin.userlevel=1")
  end
--  if user_level > 1 then
    form:Add("select","chillispot.webadmin.radconf",uci.get("chillispot","webadmin","radconf"),tr("authentication_users#Authenticate Users Mode"),"string")
    form["chillispot.webadmin.radconf"].options:Add("2","Local Radius Users (Local Radius)")
    form["chillispot.webadmin.radconf"].options:Add("1","Communities Users (Remote Radius)")
    form["chillispot.webadmin.radconf"].options:Add("3","Communities & Local Users (Local Radius & Proxy Radius)")
    form:Add_help(tr("chillispot_var_authentication_users#Authenticate Users Mode"),tr("chillispot_help_authentication_users#Select authentication Mode."))
--  end
  if user_level < 2 then
    form = net_form(form,user_level)
    form = uam_form(form,user_level)
  print("radius_form")
    if string.match(__SERVER["SCRIPT_FILENAME"],"chillispot.sh") then
      form = radius_form(form,user_level)
    end
  end

--[[
  if user_level < 2 then
    if #ifwifi > 1 then
      form:Add("select","chillispot.webadmin.ifwifi",uci.get("chillispot","webadmin","ifwifi"),tr("cportal_var_ifwifi#Wireless Interface"),"string")
      for k, v in pairs(ifwifi) do
        form["chillispot.webadmin.ifwifi"].options:Add(v.device,v.device)
      end
    else
      uci.set("chillispot","webadmin","ifwifi",ifwifi[1].device)
    end    
  end
]]--

  uci.save("chillispot") 
--  if conf_file then
--    for k, v in pairs(conf_file) do
--      form:Add("text_line","conf_"..k, k.."="..v)
--    end
--  end   

  return form
end

function uam_form(form,user_level,localuam) 
  local user_level = user_level or userlevel
  if form == nil then
    form = formClass.new(tr("chilli_portal_title#Portal Settings"))
  else
    form:Add("subtitle",tr("chilli_portal_title#Portal Settings"))
  end
----	Input Section form
    form:Add("text","chillispot.settings.uamserver",uci.get("chillispot.settings.uamserver"),tr("chilli_var_uamserver#Login page"),"string,required,nospaces","width:90%")
    form:Add_help(tr("chilli_var_uamserver#Login page"),tr("chilli_help_uamserver#URL of a Webserver handling the authentication."))

    form:Add("text","chillispot.settings.uamsecret",uci.get("chillispot.settings.uamsecret"),tr("chilli_var_uamsecret#UAM Secret"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamsecret#UAM Secret"),tr("chilli_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))

  if user_level > 1 then
    form:Add("text","chillispot.settings.uamhomepage",uci.get("chillispot.settings.uamhomepage"),tr("chilli_var_uamhomepage#UAM Home Page"),"string","width:90%")
    form:Add_help(tr("chilli_var_uamhomepage#UAM Homepage"),tr("chilli_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))
  end
  form = add_allowed_site(form,user_level)
  return form
end

function add_allowed_site(form,user_level)
  if form == nil then
    form = formClass.new("Sites Allowed")
  else
    form:Add("subtitle",tr("Sites Allowed"))
  end
--  form:Add("uci_set_config","chillispot","sitesallowed",tr("uamallowed_add#Add Allowed"),"string","width:98%;")
  local t = {}
	local style = ""
	t.label = "Add Allowed 1"
	t.name = "add_sites_allowed"
	t.style = "width:98%;"
	t.script = ""
	t.btlabel = "bt_add_allowed#Add Allowed"
  if t.style ~= "" then style = "style=\""..t.style.."\" " end
  funcname = "funcionalgo"

	local str = ""
  str = str .. "<table cellspacing=\"2\" border=\"0\" style=\"width:100%;\" ><tr><td width=\"80%\">"
--  str = str .. "<input type=\"hidden\" name=\"FUNCTION\" value=\""..funcname.."\">"
  str = str .. "<input type=\"text\" name=\"allowed_site\""..style..t.script.." />"
  str = str .. "</td><td width=\"10%\" align=\"right\">"
	str = str .. "<input type=\"submit\" name=\""..t.name.."\" value=\""..tr(t.btlabel).."\""..t.script.." />"
  str = str .. "</td></tr></table>"
  form:Add("text_line","varname",str,"Aca Va el Label","string")

  form:Add_help(tr("chilli_var_uamallowed#Sites Allowed"),tr("chilli_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))
  local sitesallowed = uci.get_type("chillispot","sitesallowed")
  if sitesallowed then 
    form:Add("subtitle","&nbsp;")
    local strallowed = [[<table width="100%">]]

    for i=1, #sitesallowed do
      strallowed = strallowed..[[<tr><td width="80%">]]
      strallowed = strallowed .. sitesallowed[i].site
      strallowed = strallowed .. [[</td><td width="20%" ><a href="]]
      local sstep = ""
      if __FORM.step~=nil then sstep = "&step="..__FORM.step end
      strallowed = strallowed ..__SERVER.SCRIPT_NAME.."?".."UCI_CMD_delchillispot."..sitesallowed[i][".name"].."=&__menu="..__FORM.__menu.."&option="..__FORM.option..sstep
      strallowed = strallowed ..[[">]]..tr("remove_lnk#remove it")..[[</a></td></tr>]]
    end
    strallowed = strallowed..[[</table>]]
    form:Add("text_line","sitesallowed",strallowed)
  end

  return form
end


function net_form(form,user_level,localuam) 
  local user_level = user_level or userlevel
  if user_level == 1 then
    uci.set("chillispot","system","dhcpif","2")
    return form
  end
  if form == nil then
    form = formClass.new(tr("cportal_dhcp_title#Network Settings"))
  else
    form:Add("subtitle",tr("cportal_dhcp_title#Network Settings"))
  end
--[[
  if user_level == 1 then
    form:Add("select","chillispot.system.dhcpif",uci.check_set("chillispot","system","dhcpif","2"),tr("cportal_var_control#Control"),"string")
--    form["chillispot.system.dhcpif"].options:Add(v,k)
    form["chillispot.system.dhcpif"].options:Add("2","wifi")      
    form["chillispot.system.dhcpif"].options:Add("1","lan")      
    form["chillispot.system.dhcpif"].options:Add("3","wifi & lan ")      
--    form["chillispot.system.dhcpif"].options:Add("4","wifi & some ports of lan ")      
    form:Add_help(tr("chilli_var_control#Control"),tr("chilli_help_control#Select the network that you want ChilliSpot control the access."))
  else
]]--
    uci.set("chillispot","system","dhcpif","0")
    form:Add("select","chillispot.settings.dhcpif",uci.check_set("chillispot","settings","dhcpif","br-wifi"),tr("cportal_var_interface#Interface Network"),"string")
    for k, v in pairs(net.dev_list()) do
      if v ~= "lo" then
        form["chillispot.settings.dhcpif"].options:Add(v,k)
      end
    end
    form:Add_help(tr("chilli_var_dhcpif#Interface"),tr("chilli_help_dhcpif#This is the network interface which is connected to the access points."))
--  end
  

  if user_level > 2 then
    form:Add("subtitle","UAM Settings")
    form:Add("text","chillispot.settings.uamlisten",uci.get("chillispot.settings.uamlisten"),tr("cportal_var_uamlisten#HotSpot Internal IP Address"),"string")
    form:Add_help(tr("cportal_var_uamlisten#UAM Listen"),tr("cportal_help_uamlisten#IP Address to listen to for authentication requests."))

    form:Add("text","chillispot.webadmin.netmask",uci.get("chillispot.webadmin.netmask"),tr("cportal_var_netmask#HotSpot DHCP Netmask"),"string")
    form:Add_help(tr("cportal_var_uamlisten#UAM Listen"),tr("chilli_help_uamlisten#IP Address to listen to for authentication requests."))

    form:Add("text","chillispot.settings.uamport",uci.get("chillispot.settings.uamport"),tr("cportal_var_uamport#UAM Port"),"string")
    form:Add_help(tr("cportal_var_uamport#UAM Port"),tr("chilli_help_uamport#TCP port to listen to for authentication requests."))
  end

  if user_level > 2 then
    form:Add("subtitle","DHCP Settings")
    form:Add("text","chillispot.settings.domain",uci.get("chillispot.settings.domain"),tr("chilli_var_doman#Domain"),"string","width:90%")
    form:Add_help(tr("chilli_var_domain#Domain Name"),tr("chilli_help_domain#Will be suggested to the client."))

    form:Add("text","chillispot.settings.dynip",uci.get("chillispot.settings.dynip"),tr("chilli_var_dynip#Dynamic IP Pool"),"string")
    form:Add("text","chillispot.settings.dynip_mask",uci.get("chillispot.settings.dynip_mask"),tr("cportal_var_dynip_mask#Dynamic Netmask"),"string")
    form:Add_help(tr("chilli_var_dynip#Dynamic IP Pool"),tr("chilli_help_dynip#Allocation of dynamic IP Addresses to clients."))
    form:Add("text_line","blanck_line","&nbsp;","")
    form:Add("text","chillispot.settings.statip",uci.get("chillispot.settings.statip"),tr("chilli_var_staticip#Static IP Pool"),"string")
    form:Add("text","chillispot.settings.statip_mask",uci.get("chillispot.settings.statip_mask"),tr("cportal_var_statip_mask#Static Netmask"),"string")
    form:Add_help(tr("chilli_var_statip#Static IP Pool"),tr("chilli_help_statip#Allocation of static IP Addresses."))
    form:Add("text_line","blanck_line","&nbsp;","")
  end

  if user_level > 1 then
    form:Add("text","chillispot.settings.dns1",uci.get("chillispot.settings.dns1"),tr("chilli_var_dns1#Primary DNS"),"string")
    form:Add("text","chillispot.settings.dns2",uci.get("chillispot.settings.dns2"),tr("chilli_var_dns2#Secondary DNS"),"string")
  end
  
  form:Add("checkbox","chillispot.settings.uamanydns",uci.check_set("chillispot","settings","uamanydns","1"),tr("chilli_var_uamanydns#Any DNS"))
  form:Add_help(tr("chilli_var_uamanydns#Any DNS"),tr("chilli_help_uamanydns#If enabled, users will be allowed to user any other dns server they specify."))
  
  if user_level > 1 then
    if user_level > 2 then
      form:Add("text","chillispot.settings.dhcpmac",uci.get("chillispot.settings.dhcpmac"),tr("chilli_var_dhcpmac#DHCP MAC"),"string")
    	form:Add_help(tr("chilli_var_dhcpmac#DHCP MAC"),tr([[chilli_help_dhcpmac#
        MAC address to listen to. If not specified the MAC address of the interface will be used. The MAC address should be chosen so that it does not conflict with other addresses on the LAN. An address in the range 00:00:5E:00:02:00 - 00:00:5E:FF:FF:FF falls within the IANA range of addresses and is not allocated for other purposes.<br> 
        The --dhcpmac option can be used in conjunction with access filters in the access points, or with access points which supports packet forwarding to a specific MAC address. Thus it is possible at the MAC level to separate access point management traffic from user traffic for improved system security. <br>
        The --dhcpmac option will set the interface in promisc mode.
          ]]))
    end
    form:Add("text","chillispot.settings.lease",uci.get("chillispot.settings.lease"),tr("chilli_var_lease#Lease Time"),"string")
    form:Add_help(tr("chilli_var_lease#DHCP Lease"),tr("chilli_help_lease#Time before DHCP lease expires"))
    if user_level > 3 then
      form:Add("checkbox","chillispot.settings.eapolenable",uci.get("chillispot.settings.eapolenable"),tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),"string")
      form:Add_help(tr("chilli_var_eapolenable#Enable IEEE 802.1x authentication"),tr([[
        If this option is given IEEE 802.1x authentication is enabled. 
        ChilliSpot will listen for EAP authentication requests on the interface 
        specified by --dhcpif. EAP messages received on this interface are 
        forwarded to the radius server.
        ]]))
    end
  end
----	Help section	
  uci.save("chillispot") 
  return form
end

function set_rad_local(user_level, localrad)
  local localrad = localrad or radconf
  local user_level = user_level or userlevel
  uci.set("chillispot","webadmin","radconf",localrad)  
  uci.set("chillispot","webadmin","userlevel",user_level)

  uci.set("chillispot","settings","radiusserver1","127.0.0.1") 
  uci.set("chillispot","settings","radiusserver2","127.0.0.1") 
  uci.set("chillispot","settings","radiusauthport","1812") 
  uci.set("chillispot","settings","radiusacctport","1813") 
  uci.set("chillispot","settings","radiussecret","testing123")
  uci.save("chillispot") 
end
    
function radius_form(form,user_level,rad_conf)
  local user_level = user_level or userlevel
  local rad_conf = rad_conf or radconf
  if form == nil then
    form = formClass.new(tr("chilli_radius_title#Radius Settings"))
  else
    form:Add("subtitle",tr("chilli_radius_title#Radius Settings"))
  end
----	Input Section form
    form:Add("text","chillispot.settings.radiusserver1",     uci.get("chillispot.settings.radiusserver1"),tr("chilli_var_radiusserver1#Primary Radius"),"string,required","width:90%")
    form:Add("text","chillispot.settings.radiusserver2",     uci.get("chillispot.settings.radiusserver2"),tr("chilli_var_radiusserver2#Secondary Radius"),"string,required","width:90%")
--    form:Add("text","chillispot.settings.radiusserver1",     uci.get("chillispot.settings.radiusserver1"),tr("chilli_var_radiusserver1#Primary Radius"),"string","width:90%")
--    form:Add("text","chillispot.settings.radiusserver2",     uci.get("chillispot.settings.radiusserver2"),tr("chilli_var_radiusserver2#Secondary Radius"),"string","width:90%")
    form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))

    form:Add("text","chillispot.settings.radiussecret",      uci.get("chillispot.settings.radiussecret"),tr("chilli_var_radiussecret#Radius Secret"),"string")
    form:Add_help(tr("chilli_var_radiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))

    if user_level > 1 then
      if user_level > 2 then
        form:Add("text","chillispot.settings.radiusauthport",    uci.get("chillispot.settings.radiusauthport"),tr("chilli_var_radiusauthport#Authentication Port"),"string")
        form:Add("text","chillispot.settings.radiusacctport",    uci.get("chillispot.settings.radiusacctport"),tr("chilli_var_radiusacctport#Accounting Port"),"string")
        form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
      end
      form:Add("subtitle",tr("NAS Identification"))
      form:Add("text","chillispot.settings.radiusnasid",       uci.get("chillispot.settings.radiusnasid"),tr("chilli_var_radiusnasid#NAS ID"),"string")
      form:Add_help(tr("chilli_var_radiuslocationid#Location ID"),tr("chilli_help_radiuslocatioid#WISPr Location ID. Should be in the format: isocc=&lt;ISO_Country_Code&gt;, cc=&lt;E.164_Country_Code&gt;, ac=&lt;E.164_Area_Code&gt;, network=&lt;ssid/ZONE&gt;"))

      form:Add("text","chillispot.settings.radiusnasip",       uci.get("chillispot.settings.radiusnasip"),tr("chilli_var_radiusnasip#NAS IP"),"string")
      form:Add_help(tr("chilli_var_radiuscalled#Called station ID"),tr(
          [[Name to report in Called-Station-ID attribute. Defaults to mac 
          address of wireless interface which can be specified by the dhcpmac 
          option. ]]
	       ))
      form:Add("text","chillispot.settings.radiusnasporttype", uci.get("chillispot.settings.radiusnasporttype"),tr("chilli_var_radiusnasporttype#NAS Port type"),"int")
      form:Add("text","chillispot.settings.radiuslocationid",  uci.get("chillispot.settings.radiuslocationid"),tr("chilli_var_radiuslocationid#Location ID"),"string","width:90%")
      form:Add("text","chillispot.settings.radiuslocationname",uci.get("chillispot.settings.radiuslocationname"),tr("chilli_var_radiuslocationname#Location Name"),"string","width:90%")
      form:Add_help(tr("chilli_var_radiuslocationname#Location Name"),tr("chilli_help_radiuslocationname#WISPr Location Name. Should be in the format: &lt;HOTSPOT_OPERATOR_NAME&gt;, &lt;LOCATION&gt;"))

      form:Add("text","chillispot.settings.radiuslisten",      uci.get("chillispot.settings.radiuslisten"),tr("chilli_var_radiuslisten#Listen Interface IP"),"string")
      form:Add_help(tr("chilli_var_radiuslisten#Listen Interface IP"),tr([[
          chilli_help_radiuslisten#Local interface IP address to use for the 
          radius interface. This option also determines the value for the 
          NAS-IP-Address radius attribute. If radiuslisten is omitted then the 
          NAS-IP-Address attribute will be set to "0.0.0.0" and the source IP 
          address of the radius requests will be determined by the operating 
          system routing tables. ]]))

      form:Add("text","chillispot.settings.radiuscalled",      uci.get("chillispot.settings.radiuscalled"),tr("chilli_var_radiuscalled#Called Station ID"),"string","width:90%")
      if user_level > 2 then
        form:Add("subtitle","Radius request disconnection")

        form:Add("text","chillispot.settings.coaport",           uci.get("chillispot.settings.coaport"),tr("chilli_var_coaport#UDP port"),"string")
        form:Add_help(tr("chilli_var_coaport#UDP port"),tr(
          [[chilli_help_coaport#
          UDP port to listen to for accepting radius disconnect requests. 
          ]]))

        form:Add("checkbox","chillispot.settings.coanoipcheck",  uci.get("chillispot.settings.coanoipcheck") ,tr("chilli_var_coanoipcheck#No check radius IP"),"string")
        form:Add_help(tr("chilli_var_coanoipcheck#No check radius IP"),tr(
          [[
          If this option is given no check is performed on the source IP address 
          of radius disconnect requests. Otherwise it is checked that radius 
          disconnect requests originate from radiusserver1 or radiusserver2.  
          ]]))
      end
    end
  uci.save("chillispot") 
  return form
end

function access_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_access#Access List Setting"))

	form:Add("checkbox","chillispot.settings.macauth",uci.get("chillispot.settings.macauth"),tr("chilli_var_macauth#MAC Authentication"))
	form:Add_help(tr("chilli_var_macauth#MAC Authentication"),tr("chilli_help_macauth#If enabled, users will be authenticated only based on their MAC Address."))

	form:Add("text","chillispot.settings.macallowed",uci.get("chillispot.settings.macallowed"),tr("chilli_var_macallowed#MAC Allowed"),"string","width:90%")
	form:Add_help(tr("chilli_var_macallowed#MAC Allowed"),tr("chilli_help_macallowed#List of allowed MAC Addresses."))

	form:Add("text","chillispot.settings.macpassword",uci.get("chillispot.settings.macpassword"),tr("chilli_var_macpassword#MAC Password"),"string")
	form:Add_help(tr("chilli_var_macpassword#MAC Password"),tr("chilli_help_macpassword#Password to use for MAC authentication."))

	form:Add("text","chillispot.settings.macsuffix",uci.get("chillispot.settings.macsuffix"),tr("chilli_var_macsuffix#MAC Suffix"),"string")
	form:Add_help(tr("chilli_var_macsuffix#MAC Suffix"),tr("chilli_help_macsuffix#Suffix to add to the username in-order to form the username."))
  uci.save("chillispot") 
  return form
end

function proxy_form(form,user_level,localrad)
  local user_level = user_level or userlevel
	form = formClass.new(tr("chilli_title_proxy#Proxy Settings"))
	form:Add("text","chillispot.settings.proxylisten",uci.get("chillispot.settings.proxylisten"),tr("chilli_var_proxylisten#Listen"),"string")
	form:Add_help(tr("chilli_var_proxylisten#Listen"),tr("chilli_help_proxylisten#IP Address to listen to (advanced uses only)."))

	form:Add("text","chillispot.settings.porxyport",uci.get("chillispot.settings.porxyport"),tr("chilli_var_proxyport#Port"),"string")
	form:Add_help(tr("chilli_var_proxyport#Port"),tr("chilli_help_proxyport#UDP port to listen to."))

	form:Add("text","chillispot.settings.proxysecret",uci.get("chillispot.settings.proxysecret"),tr("chilli_var_proxysecret#Secret"),"string")
	form:Add_help(tr("chilli_var_proxysecret#Secret"),tr("chilli_help_proxysecret#RADIUS Shared Secret to accept for all clients."))

	form:Add("text","chillispot.settings.proxyclient",uci.get("chillispot.settings.proxyclient"),tr("chilli_var_proxyclient#Client"),"string")
	form:Add_help(tr("chilli_var_proxyclient#Client"),tr("chilli_help_proxyclient#Clients from which we accept RADIUS Requests."))
  uci.save("chillispot") 
  return form
end

function script_form(form,user_level,localrad)
  local user_level = user_level or userlevel

	form = formClass.new(tr("chilli_title_scripts#Scripts Settings"))
	form:Add("text","chillispot.settings.ipup",uci.get("chillispot","settings","ipup",""),tr("chilli_var_ipup#IP Up"),"string","width:90%")
	form:Add("text","chillispot.settings.ipdown",uci.get("chillispot","settings","ipdown",""),tr("chilli_var_ipdown#IP Down"),"string","width:90%")
	form:Add_help(tr("chilli_help_title_ip#/etc/chilli.ipup and /etc/chilli.ipdown"),tr("chilli_help_ip#Script executed after network interface has been brought up. Executed with the following parameters: (devicename) (ip address) (mask)."))

	form:Add("text","chillispot.settings.conup",uci.get("chillispot","settings","conup",""),tr("chilli_var_conup#Connection Up"),"string","width:90%")
	form:Add("text","chillispot.settings.condown",uci.get("chillispot","settings","condown",""),tr("chilli_var_condown#Connection Down"),"string","width:90%")
	form:Add_help(tr("chilli_help_title_con#/etc/chilli.conup and /etc/chilli.condown"),tr("chilli_help_con#Script executed after a user has disconnected. Executed with the following parameters: (devicename) (ip address) (mask) (user ip address) (user mac address) (filter ID)."))
  uci.save("chillispot")
  return form
end

function check_settings()
  local dnss = net.resolv() 
  local dhcpif = uci.get("chillispot","settings","dhcpif")
  local ip, mask = net.getipmask(dhcpif)
  local dhcp = uci.get_all("dhcp")
  local devs = net.invert_dev_list()
  if ip and devs[dhcpif] then
    return true, "Error!!! DHCP service activated on "..dhcpif
  end
  return false
--[[
dns1 = uci.check_set("chillispot","settings","dns1",dnss[1])
dns2 = uci.check_set("chillispot","settings","dns2",dnss[2])
uci.save("chillispot")
]]--

end
    
return cportal