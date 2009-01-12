function user_level_select (form,conffile,default,maxlevel,confsection,confuserlevel)
	local confsection = confsection or "webadmin"
	local confuserlevel = confuserlevel or "userlevel"
	local default = default or 1
	local maxlevel = maxlevel or 4
	local uci_var = conffile.."."..confsection.."."..confuserlevel
	
  	form:Add("select",uci_var,uci.check_set(conffile,confsection,confuserlevel,default),tr("all_user_level#User Level"),"string")
    form[uci_var].options:Add("0","Select Mode")
    form[uci_var].options:Add("1","Beginer")
	if maxlevel > 2 then
		form[uci_var].options:Add("2","Medium")
	end
	if maxlevel > 2 then
		form[uci_var].options:Add("3","Advanced")
	end
	if maxlevel > 3 then
		form[uci_var].options:Add("4","Expert")
	end
    form:Add_help(tr("all_user_level#User Level"),tr("all_help_user_level#"..[[
          <strong>Beginer :</strong>
          This basic mode write the propers configuration files.
		  ]]))
--          <br /><br />
--          <strong>Expert :</strong><br />
--          This mode keep your configurations file and you edit they by your self.
--          ]]))
end

function service_state_select (form,conffile,default,confsection,confenable)
	local confsection = confsection or "webadmin"
	local conf_var = conf_var or "enable"
	local default = default or 0
	local uci_var = conffile.."."..confsection.."."..conf_var
	
  	form:Add("select",uci_var,uci.check_set(conffile,confsection,conf_var,default),tr("all_service_state#Service State"),"string")
    form[uci_var].options:Add("0","Disable")
    form[uci_var].options:Add("1","Enable")
    form:Add_help(tr("all_service_state#Service State"),tr("all_help_service_enable#"..[[
          Enable or Disable service.
          ]]))
end

require("net")
require("tbform")
require("uci_iwaddon")
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
local user_level_select = user_level_select
local service_state_select = service_state_select
local tr = tr
local uci = uci
local tbformClass = tbformClass
local pairs = pairs
local net = net
-- no more external access after this point
setfenv(1, P)

function set_menu()
  __MENU.Network["M-Routes"] = menuClass.new()
  __MENU.Network["M-Routes"]:Add("mroute_menu_Core#Core","network-mroute.sh?option=core")
  __MENU.Network["M-Routes"]:Add("mroute_menu_TuneUp#Tune UP","network-mroute.sh?option=tuneup")
  __MENU.Network["M-Routes"]:Add("mroute_menu_Status#Status","network-mroute.sh?option=status")
end

function core_form()
	local form = formClass.new(tr("Service Settings"))
	user_level_select(form,"mroute",1,4,"webadmin","userlevel")
	service_state_select(form,"mroute",0)
	form:Add("select","mroute.settings.debug",uci.check_set("mroute","settings","debug","1"),tr("mroute_settings_debug#Debug"),"string")
	form["mroute.settings.debug"].options:Add("0","Disable")
	form["mroute.settings.debug"].options:Add("1","Enable")
	form:Add_help(tr("mroute_settings_debug#Debug"),tr([[mroute_sttings_debug_help#Enable or Disable debug mode 
    ]]))
	form:Add("text","mroute.settings.testip",uci.check_set("mroute","settings","testip","204.225.44.3"),tr("mroute_settings_seleeptime#Test Ip"),"string")
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
  form:Add_col("text", "weight", "Weight", "60px","int, >0","width:60px")
  form:Add_col("text", "ports", "Ports", "200px","string","width:200px")
	for k, v in pairs (net.dev_list()) do
		if k ~= "loopback" then
			if __FORM["Type"..k] == "none" then
				uci.delete("mroute",k)
				uci.save("mroute")
			end
			form:New_row()
			local ifvalues = uci.get_section("mroute",k)
			form:set_col("Interface","mroute."..k..".interface", k)
			local network = "none"
			local name = k
			local weight = ""
			local ports = ""
			if ifvalues then
				network = ifvalues[".type"] or "none"
				name = ifvalues.name or k
				weight = ifvalues.weight or ""
				ports = ifvalues.ports or ""
				form:set_col("name","mroute."..k..".name",name)
				form:set_col("weight","mroute."..k..".weight",weight)
				form:set_col("ports","mroute."..k..".ports",ports)
			end
			form:set_col("ifname","Type"..k, network)
		end
	end
--	local checks = uci.get_type("freeradius_check","user")
--	local replys = uci.get_type("freeradius_reply","user")
--	local users = {}
--	if checks then
--	for i, t in pairs(checks) do
--		users[t[".name"]] = t
--	end
--	end
--	if replys then
--	for i, t in pairs(replys) do
--		users[t[".name"]] = t
--	end
--	end
--	for name, t in pairs(users) do
--			local reply = uci.get_section("freeradius_reply",name)
--			local check = uci.get_section("freeradius_check",name)
--    	local password = check.User_Password or ""
--    	local expiration = check.Expiration or ""
--    	local fall = reply.Fall_Through or ""
--    	local simul = check.Simultaneous_Use or ""
--    	local itimeout = reply.Idle_Timeout or ""
--    	local acctii = reply.Acct_Interim_Interval or ""
--    	local maxdown = reply.WISPr_Bandwidth_Max_Down or ""
--    	local maxup = reply.WISPr_Bandwidth_Max_Up or ""
--      form:New_row()

--      form:set_col("Username","freeradius_check."..name..".Username", name)
--      form:set_col("Password","freeradius_check."..name..".User_Password", password)
----      form:set_col("Expiration","freeradius_check."..name..".Expiration", expiration)
--      form:set_col("FallThrough", "freeradius_reply."..name..".Fall_Through", fall)
--      form:set_col("Simultaneous", "freeradius_check."..name..".Simultaneous_Use", simul)
--      form:set_col("IdleTimeout", "freeradius_reply."..name..".Idle_Timeout", itimeout)
--      form:set_col("AcctInterimInt", "freeradius_reply."..name..".Acct_Interim_Interval", acctii)
--      form:set_col("MaxDown", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Down", maxdown)
--      form:set_col("MaxUp", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Up", maxup)
--      form:set_col("Remove", "Remove_"..name, __SERVER.SCRIPT_NAME.."?".."UCI_CMD_delfreeradius_check."..name.."=&UCI_CMD_delfreeradius_reply."..name.."=&__menu="..__FORM.__menu.."&option="..__FORM.option)
--  end
  return form
end

return mroute
