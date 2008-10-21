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
local os = os
local io = io
local string = string
local uci = uci
local next = next

local menuClass = menuClass
--local __UCI_VERSION = __UCI_VERSION
local formClass = formClass
local __SERVER = __SERVER
local __FORM = __FORM
local __MENU = __MENU
local tr = tr
local tbformClass = tbformClass
-- no more external access after this point
setfenv(1, P)

if __FORM["allowed_site"] and __FORM["allowed_site"] ~= "" then
  local sitesallowed = uci.add("coovachilli","sitesallowed")
  uci.set("coovachilli",sitesallowed,"site",__FORM["allowed_site"])
end
if __FORM["DeleteAllowed"] then
	uci.delete("coovachilli",__FORM["DeleteAllowed"])
end

uci.check_set("coovachilli","webadmin","coovachilli")
uci.check_set("coovachilli","system","coovachilli")

uci.check_set("coovachilli","webadmin","enable","1")
uci.check_set("coovachilli","system","apply","/usr/lib/lua/lua-xwrt/applys/coovachilli.lua")

uci.check_set("coovachilli","settings","coovachilli")
uci.check_set("coovachilli","homepage","coovachilli")
uci.check_set("coovachilli","checked","coovachilli")

--uci.check_set("coovachilli","settings","HS_WWWDIR","/etc/chilli/www")
--uci.check_set("coovachilli","settings","HS_WWWBIN","/etc/chilli/wwwsh")
uci.check_set("coovachilli","homepage","redirect","0")

local userlevel = tonumber(uci.check_set("coovachilli","webadmin","userlevel","1"))
local radconf   = tonumber(uci.check_set("coovachilli","webadmin","radconf","0"))
-- portal = 1 la pagina de login en el AP
-- portal = 2 la página de login en un servidor Externo
local portal    = tonumber(uci.check_set("coovachilli","webadmin","portal","1"))
uci.check_set("coovachilli","settings","HS_MODE","hotspot")
uci.check_set("coovachilli","settings","HS_ANYDNS","on")
uci.check_set("coovachilli","settings","HS_DNS1","192.168.182.1")
uci.check_set("coovachilli","settings","HS_DNS2","204.225.44.3")
uci.check_set("coovachilli","settings","HS_NETMASK","255.255.255.0")
uci.check_set("coovachilli","settings","HS_NETWORK","192.168.182.0")
uci.check_set("coovachilli","settings","HS_LANIF","br-wifi")

uci.check_set("coovachilli","settings","HS_UAMSERVER","192.168.182.1")
uci.check_set("coovachilli","settings","HS_UAMLISTEN","192.168.182.1")
uci.check_set("coovachilli","settings","HS_UAMPORT","3990")
--uci.check_set("coovachilli","settings","HS_UAMHOMEPAGE","http://$HS_UAMLISTEN:$HS_UAMPORT/www/coova.html")
--uci.check_set("coovachilli","settings","HS_UAMFORMAT","http://$HS_UAMSERVER/cgi-bin/login/login")


uci.check_set("coovachilli","settings","HS_NASID","X-Wrtnas")
uci.check_set("coovachilli","settings","HS_LOC_NAME","My X-Wrt Hotspot")
uci.check_set("coovachilli","settings","HS_LOC_NETWORK","X-Wrt Network")

--uci.check_set("coovachilli","settings","HS_UAMALLOW","x-wrt.org,coova.org,www.internet-wifi.com.ar")

uci.check_set("coovachilli","settings","HS_RADAUTH","1812")
uci.check_set("coovachilli","settings","HS_RADACCT","1813")

if radconf > 0 then
  uci.check_set("coovachilli","settings","HS_RADIUS2","127.0.0.1")
  uci.check_set("coovachilli","settings","HS_RADIUS","127.0.0.1")
  uci.check_set("coovachilli","settings","HS_RADSECRET","testing123")
end
uci.save("coovachilli")

function set_menu()
  __MENU.HotSpot["Coova-Chilli"] = menuClass.new()
  __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Core#Core","coovachilli.sh")
  if userlevel > 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_DHCP#Network","coovachilli.sh?option=net")
  	__MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Portal#Portal","coovachilli.sh?option=uam")

  	if radconf < 2 then
    	__MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Radius#Radius","coovachilli.sh?option=radius")
  	end
  	__MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_NasId#NAS ID","coovachilli.sh?option=nasid")
  	if radconf > 1 then
    	__MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Users#Users","coovachilli.sh?option=users")
  	end
  	if radconf > 1 then
    	__MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Communities#Communities","coovachilli.sh?option=communities")
  	end
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Access#Access","coovachilli.sh?option=access")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Proxy#Proxy","coovachilli.sh?option=proxy")
--    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Scripts#Extras","coovachilli.sh?option=extras")
  end
--  if tonumber(hotspot.service.enable) == 1 then
    __MENU.HotSpot["Coova-Chilli"]:Add("chilli_menu_Connections#Connections","coovachilli.sh?option=connections")
--  end
  
  __WIP = 4
end

function get_wifinet(user_level)
	local user_level = user_level or userlevel
  local t = {}
  local n = 0
  local filternet = {}
  filternet["wan"] = ""
  filternet["loopback"] = ""
  if user_level < 2 then
  	filternet["lan"] = ""
  end
	uci.check_set("network","wifi","interface")
	uci.check_set("network","wifi","proto","static")
	uci.check_set("network","wifi","type","bridge")
--	uci.check_set("network","wifi","ifname",iwifi[i].device)
--	uci.check_set("network","wifi","ipaddr","192.168.2.2")
--	uci.check_set("network","wifi","netmask","255.255.255.0")
	uci.save("network")
  
  local nets = net.networks()
  local iwifi = uci.get_type("wireless","wifi-iface")
	for i, u in pairs(nets) do
		if filternet[i] == nil then
			for j=1, #iwifi do
				local name = i.." on "..iwifi[j].device
				t[name]=i..":"..iwifi[j].device
        n = n + 1
			end
		end
	end
  local unico = next(t)
  return t, n, t[unico]
end

function core_form(form,user_level,rad_conf)
  local user_level = user_level or userlevel;
  local rad_conf = rad_conf or radconf
  local form = form
  
  if form == nil then
    form = formClass.new(tr("chilli_title_service#Service"))
  else
    form:Add("subtitle",tr("chilli_title_service#Service"))
  end

	form:Add("select","coovachilli.webadmin.enable",uci.check_set("coovachilli","webadmin","enable","1"),tr("chilli_var_service#Service"),"string")
	form["coovachilli.webadmin.enable"].options:Add("0","Disable")
	form["coovachilli.webadmin.enable"].options:Add("1","Enable")
  form:Add_help(tr("chillispot_var_enable#Service"),tr("chilli_help_enable#Enable or disable service."))

  if string.match(__SERVER["SCRIPT_FILENAME"],"coovachilli.sh") then
  	form:Add("select","coovachilli.webadmin.userlevel",uci.check_set("coovachilli","webadmin","userlevel","0"),tr("userlevel#User Level"),"string")
    form["coovachilli.webadmin.userlevel"].options:Add("0","Select Mode")
    form["coovachilli.webadmin.userlevel"].options:Add("1","Beginer")
    form["coovachilli.webadmin.userlevel"].options:Add("2","Medium")
    form["coovachilli.webadmin.userlevel"].options:Add("3","Advanced")
--    form["coovachilli.webadmin.userlevel"].options:Add("4","Expert")
	  form:Add("select","coovachilli.webadmin.radconf",uci.check_set("coovachilli","webadmin","radconf","0"),tr("authentication_users#Authenticate Users Mode"),"string")
  	form["coovachilli.webadmin.radconf"].options:Add("0","Communities Users with Remote Radius")
  	form["coovachilli.webadmin.radconf"].options:Add("1","Local Users with Local Radius")
  	form["coovachilli.webadmin.radconf"].options:Add("2","Comunities Users with Local Radius")
  	form["coovachilli.webadmin.radconf"].options:Add("3","Communities & Local Users with Local Radius")
  	form:Add_help(tr("chillispot_var_authentication_users#Authenticate Users Mode"),tr("chillispot_help_authentication_users#Select authentication Mode."))
  else
    uci.set("coovachilli","webadmin","userlevel",user_level)
    uci.set("coovachilli","webadmin","radconf",rad_conf)
  end
--[[
  if user_level > 1 then
  	form:Add("select","coovachilli.webadmin.portal",uci.check_set("coovachilli","webadmin","portal","2"),tr("portal#Portal Settings"),"string")
--  	form["coovachilli.webadmin.portal"].options:Add("0","Coova Server")
    form["coovachilli.webadmin.portal"].options:Add("1","Internal Server")
    form["coovachilli.webadmin.portal"].options:Add("2","Remote Server")
  end
]]--
  uci.save("coovachilli")
  if user_level < 2 then
		form = nasid_form(form, user_level)
  	form = net_form(form,user_level,portal)
		form = uam_form(form,user_level,portal)
		form = radius_form(form,user_level, rad_conf)
	end    
  return form
end

function net_form(form,user_level,localuam)
  local user_level = user_level or userlevel
  local form = form
  local ifiw, n, unico = get_wifinet(user_level)
	if user_level > 1 or n > 1 then
  	if form == nil then
    	form = formClass.new(tr("Network Settings"))
  	else
    	form:Add("subtitle",tr("Network Settings"))
  	end

  	if user_level < 2 then
    	if tonumber(n) > 1 then
      	form:Add("select","coovachilli.webadmin.HS_LANIF",uci.get("coovachilli","settings","HS_LANIF"),tr("cportal_var_ifwifi#Wireless Interface"),"string")
      	for k, v in pairs(ifiw) do
        	form["coovachilli.webadmin.HS_LANIF"].options:Add(v,k)
      	end
    	end    
  	end
  else
    uci.set("coovachilli","webadmin","HS_LANIF",unico)
    uci.save("coovachilli")
	end

  if user_level > 1 then

	  local dev
    dev = net.invert_dev_list() -- for advanced users
	  form:Add("select","coovachilli.settings.HS_LANIF",uci.check_set("coovachilli","settings","HS_LANIF","br-wifi"),tr("cportal_var_device#Device Network"),"string")
  	for k, v in pairs(dev) do
    	if v ~= "loopback"
    	and v ~= "wan" then
				form["coovachilli.settings.HS_LANIF"].options:Add(k,v)
			end
  	end

	  form:Add("text", "coovachilli.settings.HS_UAMLISTEN", uci.check_set("coovachilli","settings","HS_UAMLISTEN","192.168.182.1"),tr("cportal_var_uamlisten#HotSpot Internal IP Address"),"string")
--  This param can be calculated 
--  form:Add("text", "coovachilli.settings.HS_NETWORK", uci.check_set("coovachilli","settings","HS_NETWORK","192.168.182.0"),tr("cportal_var_net#HotSpot DHCP Network"),"string")
  	form:Add("text", "coovachilli.settings.HS_NETMASK", uci.check_set("coovachilli","settings","HS_NETMASK","255.255.255.0"),tr("cportal_var_net#HotSpot DHCP Netmask"),"string")
  	form:Add("subtitle","Optional Advanced Settings")
  	form:Add("text", "coovachilli.settings.HS_DYNIP", uci.get("coovachilli","settings","HS_DYNIP"),tr("cportal_var_dynip#Dynamic IP"),"string")
  	form:Add("text", "coovachilli.settings.HS_DYNIP_MASK", uci.get("coovachilli","settings","HS_DYNIP_MASK"),tr("cportal_var_staticip#Dynamic IP Mask"),"string")
  	form:Add("text", "coovachilli.settings.HS_STATIP", uci.get("coovachilli","settings","HS_STATIP"),tr("cportal_var_staticip#Static IP"),"string")
  	form:Add("text", "coovachilli.settings.HS_STATIP_MASK", uci.get("coovachilli","settings","HS_STATIP_MASK"),tr("cportal_var_staticip#Static IP Mask"),"string")

--  This do not work or I don't understand How it work  
--  	form:Add("select","coovachilli.check.HS_ANYIP", uci.check_set("coovachilli","check","HS_ANYIP","1"),tr("cportal_var_anyip#Allow Any IP"),"int")
--  	form["coovachilli.check.HS_ANYIP"].options:Add("no",tr("disable#Disable"))
--  	form["coovachilli.check.HS_ANYIP"].options:Add("",tr("enable#Enable"))

  	form:Add("subtitle","Extras")  
  	form:Add("text", "coovachilli.settings.HS_DNS_DOMAIN", uci.get("coovachilli","settings","HS_DNS_DOMAIN"),tr("cportal_var_net#Domain"),"string")
  	form:Add("text", "coovachilli.settings.HS_DNS1", uci.check_set("coovachilli","settings","HS_DNS1","192.168.182.1"),tr("cportal_var_dns#DNS Server").." 1","string")
  	form:Add("text", "coovachilli.settings.HS_DNS2", uci.check_set("coovachilli","settings","HS_DNS2","204.225.44.3"),tr("cportal_var_dns#DNS Server").." 2","string")

--  form:Add("text", "coovachilli.settings.HS_UAMSERVER", uci.check_set("coovachilli","settings","HS_UAMSERVER","192.168.182.1"),tr("cportal_var_uamserver#Server"),"string")
--  form:Add("text", "coovachilli.settings.HS_UAMPORT", uci.check_set("coovachilli","settings","HS_UAMPORT","3990"),tr("cportal_var_net#Port"),"string")
	end
	uci.save("coovachilli")
  return form
end

function radius_form(form,user_level,rad_conf)
  local user_level = user_level or userlevel
  local form = form
  local rad_conf = rad_conf or radconf

  if form == nil then
    form = formClass.new(tr("Coovachilli - Radius Settings"))
  else
    form:Add("subtitle",tr("Radius Settings"))
  end
----	Input Section form
	if rad_conf == 0 then
	  form:Add("text","coovachilli.settings.HS_RADIUS",uci.check_set("coovachilli","settings","HS_RADIUS","rad01.internet-wifi.com.ar"),tr("chilli_var_radiusserver1#Primary Radius"),"string,required","width:90%")
  	form:Add("text","coovachilli.settings.HS_RADIUS2",uci.check_set("coovachilli","settings","HS_RADIUS2","rad02.internet-wifi.com.ar"),tr("chilli_var_radiusserver2#Secondary Radius"),"string,required","width:90%")
  	form:Add_help(tr("chilli_help_title_radiusserver#Primary / Secondary Radius"),tr("chilli_help_radiusserver#Primary and Secondary Radius Server|Ip or url address of Radius Servers. If you have only one radius server you should set Secondary radius server to the same value as Primary radius server."))
  	form:Add("text","coovachilli.settings.HS_RADAUTH",uci.check_set("coovachilli","settings","HS_RADAUTH","1812"),tr("chilli_var_radiusauthport#Authentication Port"),"int,>0")
  	form:Add("text","coovachilli.settings.HS_RADACCT",uci.check_set("coovachilli","settings","HS_RADACCT","1813"),tr("chilli_var_radiusacctport#Accounting Port"),"int,>0")
  	form:Add_help(tr("chilli_help_title_radiusports#Authentication / Accounting Ports"),tr("chilli_help_radiusports#Radius authentication and accounting port|The UDP port number to use for radius authentication and accounting requests. The same port number is used for both radiusserver1 and radiusserver2."))
	else
    uci.set("coovachilli","settings","HS_RADIUS","127.0.0.1") 
    uci.set("coovachilli","settings","HS_RADIUS2","127.0.0.1") 
    uci.set("coovachilli","settings","HS_RADAUTH","1812") 
    uci.set("coovachilli","settings","HS_RADACCT","1813") 
    uci.save("coovachilli") 
	end
  form:Add("text","coovachilli.settings.HS_RADSECRET",uci.check_set("coovachilli","settings","HS_RADSECRET","testing123"),tr("chilli_var_rradiussecret#Remote Radius Secret"),"string")
  form:Add_help(tr("chilli_var_rradiussecret#Radius Secret"),tr("chilli_help_radiussecret#Radius shared secret for both servers."))
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
	form:Add("text","coovachilli.settings.HS_NASID",uci.check_set("coovachilli","settings","HS_NASID","X-Wrt NAS"),tr("cportal_var_radiusnasid#NAS ID"),"string")
  form:Add("text","coovachilli.settings.HS_LOC_NAME",uci.get("coovachilli","settings","HS_LOC_NAME"),tr("cportal_var_radiusnasip#Location Name"),"string")
  form:Add_help(tr("chilli_var_radiuslocationname#Location Name"),tr("chilli_help_radiuslocationname#WISPr Location Name. Should be in the format: &lt;HOTSPOT_OPERATOR_NAME&gt;, &lt;LOCATION&gt;"))
	if user_level > 1 then
		form:Add("text","coovachilli.settings.HS_LOC_NETWORK",uci.check_set("coovachilli","settings","HS_LOC_NETWORK","X-Wrt Network"),tr("cportal_var_radiusnasporttype#Network name"),"string")
		form:Add("text","coovachilli.settings.HS_LOC_ISOCC",uci.get("coovachilli","settings","HS_LOC_ISOCC",""),tr("cportal_var_isocc#ISO Country code"),"string")
		form:Add("text","coovachilli.settings.HS_LOC_CC",uci.get("coovachilli","settings","HS_LOC_CC",""),tr("cportal_var_radiuslocationname#Phone country code"),"string")
		form:Add("text","coovachilli.settings.HS_LOC_AC",uci.get("coovachilli","settings","HS_LOC_AC",""),tr("cportal_var_radiuslocationid#Phone area code"),"string")
	end
  uci.save("coovachilli")
  return form
end

function uam_form(form,user_level,local_portal)
	local user_level = user_level or userlevel
	local local_portal = local_portal or portal
	local form = form
	 
	  if form ~= nil then form:Add("subtitle","Captive Portal - Universal Authentication Method")
	  else form = form or formClass.new("Captive Portal - Universal Authentication Method") end
	if user_level > 1 then
  	local user_level = user_level or userlevel
  	local localuam = localuam or portal
--  	if user_level > 1 and local_portal < 2 then
  	if user_level > 1 then
    	form:Add("text","coovachilli.settings.HS_UAMSERVER",uci.check_set("coovachilli","settings","HS_UAMSERVER","192.168.182.1"),tr("cportal_var_uamserver#URL of Web Server"),"string","width:90%")
    	form:Add_help(tr("cportal_var_uamserver#URL of Web Server"),tr("cportal_help_uamserver#URL of a Webserver handling the authentication."))
			local def_hompage = "http://"..uci.get("coovachilli","settings","HS_UAMSERVER").."/cgi-bin/login/home.lua"
--    	form:Add("text","coovachilli.settings.HS_UAMFORMAT",uci.get("coovachilli","settings","HS_UAMFORMAT","http://\$HS_UAMSERVER/cgi-bin/login/login"),tr("cportal_var_format#Path of Login Page"),"string","width:90%")
    	form:Add("text","coovachilli.settings.HS_UAMFORMAT",uci.check_set("coovachilli","settings","HS_UAMFORMAT",def_homepage),tr("cportal_var_format#Login Page"),"string","width:90%")
    	form:Add_help(tr("cportal_var_format#URL of Web Server"),tr("cportal_help_format#URL of a Webserver handling the authentication."))

    	form:Add("text","coovachilli.settings.HS_UAMSECRET",uci.get("coovachilli","settings","HS_UAMSECRET"),tr("cportal_var_uamsecret#UAM Secret"),"string")
    	form:Add_help(tr("cportal_var_uamsecret#Web Secret"),tr("cportal_help_uamsecret#Shared secret between HotSpot and Webserver (UAM Server)."))
  	end
  	if user_level > 2 then
--    	form:Add("text","coovachilli.settings.HS_UAMHOMEPAGE",uci.check_set("coovachilli","settings","HS_UAMHOMEPAGE","http://\$HS_UAMLISTEN:\$HS_UAMPORT/www/coova.html"),tr("cportal_var_uamhomepage#UAM Home Page"),"string","width:90%")
    	form:Add("text","coovachilli.settings.HS_UAMHOMEPAGE",uci.get("coovachilli","settings","HS_UAMHOMEPAGE"),tr("cportal_var_uamhomepage#UAM Home Page"),"string","width:90%")
    	form:Add_help(tr("cportal_var_uamhomepage#Homepage"),tr("cportal_help_uamhomepage#URL of Welcome Page. Unauthenticated users will be redirected to this address, otherwise specified, they will be redirected to UAM Server instead."))
    	form:Add("text","coovachilli.homepage.redirect",uci.get("coovachilli","homepage","redirect"),tr("cportal_var_uamhomepage#Redirection time"),"int,required,>=0")
    	form:Add_help(tr("cportal_var_homepage_redirection#Redirection time"),tr("cportal_help_homepage_redirection#Seconds of redirection time. 0 = not redirection"))

  	end
  	uci.save("coovachilli")
  end
  form =  add_allowed_site(form,user_level)
  return form
end

function add_allowed_site(form,user_level)
	local user_level = user_level or userlevel
	local form = form
  if form == nil then
    form = formClass.new("Sites Allowed")
  else
    form:Add("subtitle",tr("Sites Allowed"))
  end
--  form:Add("uci_set_config","coovachilli","sitesallowed",tr("uamallowed_add#Add Allowed"),"string","width:98%;")
  local t = {}
	local style = ""
	t.label = "Add Allowed 1"
	t.name = "add_sites_allowed"
	t.style = "width:98%;"
	t.script = ""
	t.btlabel = "bt_add_allowed#Add Allowed"
  if t.style ~= "" then style = "style=\""..t.style.."\" " end
  funcname = "funcionalgo"
	form:Add("checkbox","coovachilli.system.paypal",uci.get("coovachilli","system","paypal"),tr("uamallow_paypal#Paypal Allowed"))
	local str = ""
  str = str .. "<table cellspacing=\"2\" border=\"0\" style=\"width:100%;\" ><tr><td width=\"80%\">"
--  str = str .. "<input type=\"hidden\" name=\"FUNCTION\" value=\""..funcname.."\">"
  str = str .. "<input type=\"text\" name=\"allowed_site\""..style..t.script.." />"
  str = str .. "</td><td width=\"10%\" align=\"right\">"
	str = str .. "<input type=\"submit\" name=\""..t.name.."\" value=\""..tr(t.btlabel).."\""..t.script.." />"
  str = str .. "</td></tr></table>"
  form:Add("text_line","varname",str,"Aca Va el Label","string")
  form:Add_help(tr("chilli_var_uamallowed#Sites Allowed"),tr("chilli_help_uamallowed#Comma-seperated list of domain names, urls or network subnets the client can access without authentication (walled gardened)."))
  local sitesallowed = uci.get_type("coovachilli","sitesallowed")
  if sitesallowed then 
    form:Add("subtitle","&nbsp;")
    local strallowed = [[<table width="100%">]]

    for i=1, #sitesallowed do
      strallowed = strallowed..[[<tr><td width="80%">]]
      strallowed = strallowed .. sitesallowed[i].site
      strallowed = strallowed .. [[</td><td width="20%" ><a href="]]
      local sstep = ""
      local soption = ""
      if __FORM.option~=nil then soption = "&option="..__FORM.option end
      if __FORM.step~=nil then sstep = "&step="..__FORM.step end
      strallowed = strallowed ..__SERVER.SCRIPT_NAME.."?".."DeleteAllowed="..sitesallowed[i][".name"].."&__menu="..__FORM.__menu..soption..sstep
      strallowed = strallowed ..[[">]]..tr("remove_lnk#remove it")..[[</a></td></tr>]]
    end
    strallowed = strallowed..[[</table>]]
    form:Add("text_line","sitesallowed",strallowed)
  end
  return form
end

function connect_form(form,user_level,localuam)
  if __FORM["authorize"] ~= nil then
    os.execute("chilli_query authorize sessionid "..__FORM["authorize"])
  end
  if __FORM["release"] ~= nil then
    os.execute("chilli_query dhcp-release "..__FORM["release"])
  end
  local authenticated = {["0"] = "No",["1"] = "Yes"}
  local form = tbformClass.new("Captive Portal - Connection List")
  form = tbformClass.new("Local Users")
  form:Add_col("label", "Username","Username", "width:150px;font-size:11px;","","width:150px;font-size:11px;")
  form:Add_col("label", "MAC-Address", "MAC Address", "width:160px;font-size:11px;","string","width:160px;font-size:11px;")
  form:Add_col("label", "IP-Address", "IP Address", "width:140px;font-size:11px;","string","width:140px;font-size:11px;")
  form:Add_col("label", "Status", "Status", "width:60px;font-size:11px;","string","width:60px;font-size:11px;")
  form:Add_col("label", "Session-ID", "Session ID", "width:170px;font-size:11px;","int","width:170px;font-size:11px;")
  form:Add_col("label", "Auth", "Aut", "width:40px;font-size:11px;","int","width:40px;font-size:11px;")
  form:Add_col("label", "SessTime", "Session Time", "width:90px;font-size:11px;","int","width:90px;font-size:11px;")
  form:Add_col("label", "IdleTime", "Idle Time", "width:100px;font-size:11px;","int","width:100px;font-size:11px;")
  form:Add_col("label", "action", " ", "width:200px;font-size:11px;","int","width:200px;font-size:11px;")
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
    if tonumber(tline[5]) == 1 then
      action = [[<a href="?release=]]..tline[1].."&__menu="..__FORM["__menu"].."&option="..__FORM["option"]..[[">logout</a>]]
    else
      action = "<a href=\"?release="..tline[1].."&__menu="..__FORM["__menu"].."&option="..__FORM["option"].."\">release</a> - <a href=\"?authorize="..tline[4].."&__menu="..__FORM["__menu"].."&option="..__FORM["option"].."\">authorize</a>"
    end
  
    form:New_row()

    form:set_col("Username",sessId..".Username",user)
    form:set_col("MAC-Address",sessId..".MAC-Address",mac)
    form:set_col("IP-Address",sessId..".IP-Address",ip)
    form:set_col("Status",sessId..".Status",status)
    form:set_col("Session-ID",sessId..".Session-ID",sessId)
    form:set_col("Auth",sessId..".Auth",authen)
    form:set_col("SessTime",sessId..".SessTime",sessTime)
    form:set_col("IdleTime",sessId..".IdleTime",idleTime)
    form:set_col("action",sessId..".action",action)
  end
  return form
end

return cportal