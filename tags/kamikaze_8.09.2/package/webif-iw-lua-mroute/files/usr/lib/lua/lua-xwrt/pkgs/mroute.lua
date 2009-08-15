require("net")
require("tbform")
require("uci_iwaddon")
require("firewall")
require("common-form")
mroute = {}
local P = {}
mroute = P
-- Import Section:
-- declare everything this package needs from outside
local menuClass = menuClass
local formClass = formClass
local __SERVER = __SERVER
local __FORM = __FORM
local __MENU = __MENU
local service_state_select = service_state_select
local print = print
local tr = tr
local uci = uci
local tbformClass = tbformClass
local pairs = pairs
local net = net
local firewall = firewall
-- no more external access after this point
setfenv(1, P)

uci.check_set("mroute","webadmin","mroute")
uci.check_set("mroute","system","mroute")
uci.check_set("mroute","webadmin","enable","1")
uci.check_set("mroute","system","apply","/usr/lib/lua/lua-xwrt/applys/mroute.lua")
uci.save("mroute")

function set_firewall()
	local lan_list = uci.get_type("mroute","lanif")
	local wan_list = uci.get_type("mroute","wanif")
	for l = 1, #lan_list do
		for w = 1, #wan_list do
			firewall.set_zone(wan_list[w][".name"],"REJECT","ACCEPT","REJECT","1")
			firewall.set_forwarding(lan_list[l][".name"],wan_list[w][".name"])
		end
	end
end

function set_menu()
  __MENU.Network["M-Routes"] = menuClass.new()
  __MENU.Network["M-Routes"]:Add("mroute_menu_Core#Core","network-mroute.sh?option=core")
  __MENU.Network["M-Routes"]:Add("mroute_menu_Interfaces#Interfaces","network-mroute.sh?option=ifaces")
  __MENU.Network["M-Routes"]:Add("mroute_menu_TuneUp#Tune UP","network-mroute.sh?option=tuneup")
--  __MENU.Network["M-Routes"]:Add("mroute_menu_Status#Status","network-mroute.sh?option=status")
end

function core_form()
	local form = formClass.new(tr("Service Settings"))
--	user_level_select(form,"mroute",1,4,"webadmin","userlevel")
	service_state_select(form,"mroute",0)
	form:Add("select","mroute.settings.debug",uci.check_set("mroute","settings","debug","0"),tr("mroute_settings_debug#Debug"),"string")
	form["mroute.settings.debug"].options:Add("0","Disable")
	form["mroute.settings.debug"].options:Add("4","Errors")
	form["mroute.settings.debug"].options:Add("5","Full")
	form:Add_help(tr("mroute_settings_debug#Debug"),tr([[mroute_sttings_debug_help#Enable or Disable debug mode 
    ]]))
	return form
end

function tuneup_form(form, userlevel)
  local form = form
	local userlevel = userlevel or 1
  if form == nil then
		form = formClass.new(tr("Tune Up Failover"))
	else
		form:Add("subtitle",tr("Tune Up Failover"))
	end
--	form:Add("subtitle","Tune UP&nbsp;")
	form:Add("text","mroute.settings.testip",uci.check_set("mroute","settings","testip","204.225.44.3"),tr("mroute_settings_seleeptime#Test Ip"),"string")
	form:Add("select","mroute.settings.sleeptime",uci.check_set("mroute","settings","sleeptime","2"),tr("mroute_settings_sleeptime#Sleep Time"),"string")
	for i=1, 30 do
		form["mroute.settings.sleeptime"].options:Add(i,i)
	end
	
	form:Add("select","mroute.settings.timeout",uci.check_set("mroute","settings","timeout","2"),tr("mroute_settings_timeout#Ping Time Out"),"string")
	for i=1, 5 do
		form["mroute.settings.timeout"].options:Add(i,i)
	end

	form:Add("select","mroute.settings.success",uci.check_set("mroute","settings","success","2"),tr("mroute_settings_success#Success count"),"string")
	for i=1, 15 do
		form["mroute.settings.success"].options:Add(i,i)
	end

	form:Add("select","mroute.settings.failure",uci.check_set("mroute","settings","failure","2"),tr("mroute_settings_failure#Failure count"),"string")
	for i=1, 15 do
		form["mroute.settings.failure"].options:Add(i,i)
	end

	form:Add("select","mroute.settings.resetif",uci.check_set("mroute","settings","resetif","2"),tr("mroute_settings_resetif#Reset IF count"),"string")
	for i=1, 15 do
		form["mroute.settings.resetif"].options:Add(i,i)
	end
	return form
end

function interfaces_form(form, userlevel)
  form = tbformClass.new(tr("mroute_form_Interfaces#Interfaces settings"))
  form:Add_col("label", "Interface","Interface", "120px")
  form:Add_col("select", "ifname", "Network", "120px","","width:120px")
  form.col[form.col.ifname].options:Add("none","Not Used")
  form.col[form.col.ifname].options:Add("wanif","WAN (Internet)")
  form.col[form.col.ifname].options:Add("lanif","LAN (Local Net)")
  form:Add_col("text", "name","Name", "120px","string","width:120px")
  form:Add_col("text", "weight", "Weight", "60px","int","width:60px")
--  form:Add_col("text", "ports", "Ports", "200px","string","width:200px")
  form:Add_col("label", "status", "Status", "60px","int","width:60px")
  form:Add_col("label", "ipv4", "IPv4", "160px","int","width:160px")
  form:Add_col("label", "gateway", "Gateway", "160px","int","width:160px")
	local mrState = uci.cursor(nil,"/var/state") 
	for k, v in pairs (net.dev_list()) do
		if k ~= "loopback" then
			if __FORM["Type"..k] ~= nil then
				if __FORM["Type"..k] == "none" then
					uci.delete("mroute",k)
				else
					if __FORM["Type"..k] == "lanif" then
						uci.check_set("mroute",k,"lanif")
					elseif __FORM["Type"..k] == "wanif" then
						uci.check_set("mroute",k,"wanif")
					end
					local weight = __FORM["mroute."..k..".weight"] or 1
					local name = __FORM["mroute."..k..".name"] or k
					local ports = __FORM["mroute."..k..".ports"] or ""
					uci.set("mroute",k,"name", name) 
					if __FORM["Type"..k] ~= "lanif" then
						uci.set("mroute",k,"weight", weight)
						if ports ~= "" then
							uci.set("mroute",k,"ports",ports) end
					end
				end
				uci.save("mroute")
			end
			form:New_row()
			local ifvalues = uci.get_section("mroute",k)
			form:set_col("Interface","mroute."..k..".interface", k)
			local network = "none"
			local name = k
			local weight = ""
			local ports = ""
			local status = ""
			local ipv4 = ""
			local gateway =""
			
			if ifvalues then
				network = ifvalues[".type"] or "none"
				name = ifvalues.name or k
				weight = ifvalues.weight or ""
				ports = ifvalues.ports or ""
				if mrState:get("mroute",k,"status") == "1" then status = "Up" else status = "Down" end
				ipv4 = mrState:get("mroute",k,"ipaddr") or "   .    .   .   "
				gateway = mrState:get("mroute",k,"gateway") or "   .   .   .   "
			end
			if network ~= "lanif" then
				form:set_col("weight","mroute."..k..".weight",weight)
--				form:set_col("ports","mroute."..k..".ports",ports)
				form:set_col("status","mroute."..k..".status",status)
				form:set_col("ipv4","mroute."..k..".ipaddr",ipv4)
				form:set_col("gateway","mroute."..k..".gateway",gateway)
			end
			form:set_col("name","mroute."..k..".name",name)
			form:set_col("ifname","Type"..k, network)
		end
	end
--	set_firewall()
  return form
end

return mroute
