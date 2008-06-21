--[[
    Availables functions

]]--
require("net")
require("tbform")
require("iw-uci")
require("uci_iwaddon")

olsrd = {}
local P = {}
olsrd = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local math = math
local pairs = pairs
local pairsByKeys = pairsByKeys
local assert = assert
local string = string
local tonumber = tonumber
local net = net
local uci = uci
local __UCI_UPDATED = __UCI_UPDATED
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
if __WWW ~= nil then
if __FORM["Library_name"] and __FORM["Library_file"] then
  uci.set("olsr",__FORM["Library_name"],"LoadPlugin")
  uci.set("olsr",__FORM["Library_name"],"Library",__FORM["Library_file"])
  uci.save("olsr")
end
end

local olsr = uciClass.new("olsr")
if olsr.webadmin == nil then webadmin = olsr:set("websettings","webadmin") end
--if olsr.general == nil then general = olsr:set("olsr","general") end 
--if olsr.Hna4 == nil then hna4 = olsr:set("Hna4") end 
--if olsr.Interface == nil then interface = olsr:set("Interface") end 
 
local loc_userlevel = tonumber(olsr.webadmin.userlevel) or 0
--local userlevel = tonumber(olsr.websettings.userlevel) or 0

function dyn_gw_default(library)
  local extra_gw = uci.get_type("olsr","dyn_gw")
  for i=1, #extra_gw do
    uci.delete("olsr",extra_gw[i][".name"])
  end
  uci.delete("olsr","dyn_gw")
  uci.set("olsr","dyn_gw","LoadPlugin")
  uci.set("olsr","dyn_gw","Library",library)
  uci.set("olsr","dyn_gw","Ping","141.1.1.1")
  local extraparam = uci.add("olsr","dyn_gw")
  uci.set("olsr",extraparam,"Ping","194.25.2.129")
  uci.save("olsr")
--  __UCI_UPDATED:countUpdated()
end

function nameservice_default(library)
  local config = uci.get_all("olsr")
  uci.delete("olsr","nameservice")
  local ip = uci.get("network",config.webadmin.netname,"ipaddr")
  local host = "host"..string.gsub(ip,"(%d+)%.(%d+)%.(%d+)%.(%d+)","%4\.%1\-%2\-%3")
  uci.set("olsr","nameservice","LoadPlugin")
  uci.set("olsr","nameservice","Library",library)
  uci.set("olsr","nameservice","hosts_file","/etc/hosts")
  uci.set("olsr","nameservice","name",host)
  uci.set("olsr","nameservice","suffix",".olsr")
  uci.set("olsr","nameservice","lat","-27.448232")         
  uci.set("olsr","nameservice","lon","-58.989523")
  uci.save("olsr")
--  __UCI_UPDATED:countUpdated()
end

function txtinfo_default(library)
  uci.delete("olsr","txtinfo")
  uci.set("olsr","txtinfo","LoadPlugin")
  uci.set("olsr","txtinfo","Library",library)
  uci.set("olsr","txtinfo","accept","127.0.0.1")
  uci.save("olsr")
--  __UCI_UPDATED:countUpdated()
end
    
function get_installed_plugin(idxfile)
  idxfile = idxfile or false
  local t = {}
  local ok = false
  local config = uci.get_all("olsr")
  local files = io.popen("ls /usr/lib/olsrd_*")
  for line in files:lines() do
    ok = true 
    local name = string.gsub(line,".+olsrd_([a-zA-z0-9_]+)\.so.+","%1")
    local library = string.gsub(line,"\/usr\/lib\/","") 
    if idxfile == true then
      t[library] = name
    else
      t[name] = library
    end
    if name == "dyn_gw" then
      if config[name] == nil then
        dyn_gw_default(library)
--        uci.set("olsr",name,"LoadPlugin")
--        uci.set("olsr",name,"Library",library)
--        uci.set("olsr",name,"Ping","141.1.1.1")
--        local extraparam = uci.add("olsr",name)
--        uci.set("olsr",extraparam,"Ping","194.25.2.129")
      end
    elseif name == "nameservice" then
      if config[name] == nil then
        nameservice_default(library)
--[[        
        local ip = uci.get("network",config.webadmin.netname,"ipaddr")
        local host = "host"..string.gsub(ip,"(%d+)%.(%d+)%.(%d+)%.(%d+)","%4\.%1\-%2\-%3")
        uci.set("olsr",name,"LoadPlugin")
        uci.set("olsr",name,"Library",library)
        uci.set("olsr",name,"hosts_file","/etc/hosts")
        uci.set("olsr",name,"name",host)
        uci.set("olsr",name,"suffix",".olsr")
        uci.set("olsr",name,"lat","-27.448232")         
        uci.set("olsr",name,"lon","-58.989523")
]]--
      end
    elseif name == "txtinfo" then
      if config[name] == nil then 
        txtinfo_default()
--[[        
        uci.set("olsr",name,"LoadPlugin")
        uci.set("olsr",name,"accept","127.0.0.1")
]]--
      end

    end
    uci.save("olsr")
  end
  
  if ok == false then
    t = nil
  end
  return t
end 

function get_bad_plugin()
  local plugin = uci.get_type("olsr","LoadPlugin")
  local insplugin = get_installed_plugin(true)
  local badplugin = {}
  local ok = false
  local confplugin = uci.get_all("olsr")

  for i=1, #plugin do
    local library = plugin[i].Library
    local name = plugin[i][".name"]
    if insplugin[library] == nil 
    and io.exists("/usr/lib/"..library) == false then
      badplugin[name] = library
      ok = true
--[[
    else
      local newname = string.gsub(library,".*olsrd_([a-zA-z0-9_]+)\.so.+","%1") 
      if name ~= newname then
        uci.set("olsr",newname,"LoadPlugin")
        for k, v in pairs(confplugin[name]) do
          if k ~= ".name"
          and k ~= ".type" then
            uci.set("olsr",newname,k,v)
          end
        end
        uci.delete("olsr",name)
        uci.commit("olsr")
      end
]]--
    end
  end

  if ok == false then
    badplugin = nil
  end
  return badplugin
end

function set_menu()
  local tplugins = get_installed_plugin()
  local badplugin = get_bad_plugin() 
  local user_level = loc_userlevel
  local molsr = uci.get_all("olsr")
  __MENU.HotSpot.OLSR = menuClass.new()
  __MENU.HotSpot.OLSR:Add("Core","olsr.sh")
  if user_level > 1 then
    if user_level > 2 then __MENU.HotSpot.OLSR:Add("General","olsr.sh?option=general") end 
--    __MENU.HotSpot.OLSR:Add("Ip Connect","olsr.sh?option=ipconnect")
    __MENU.HotSpot.OLSR:Add("Hna4","olsr.sh?option=hna4")
--    __MENU.HotSpot.OLSR:Add("Hna6","olsr.sh?option=hna6")

    if tplugins ~= nil or badplugin ~= nil then
      __MENU.HotSpot.OLSR:Add("Plugins")
      __MENU.HotSpot.OLSR.Plugins = menuClass.new()
      if badplugin ~= nil then
        __MENU.HotSpot.OLSR.Plugins:Add("Plugins List","olsr.sh?option=plugin")
      end
      
      for n, file in pairsByKeys(tplugins) do
        if molsr[n] ~= nil then
          __MENU.HotSpot.OLSR.Plugins:Add(n,"olsr.sh?option=plugin&plname="..n.."&library="..file)
        end
      end
    end
    __MENU.HotSpot.OLSR:Add("Interfaces","olsr.sh?option=interfaces")
  end
  __MENU.HotSpot.OLSR:Add("Status","olsr.sh?option=status")
  __MENU.HotSpot.OLSR:Add("Visualization","olsr.sh?option=viz")
end

function check_pkg()
  local olsr_pkg = pkgInstalledClass.new("olsrd",true)
end

function core_form()
  if olsr.websettings == nil then websettings = olsr:set("websettings","webadmin") 
  else websettings = olsr.websettings end
  websettings_values = websettings[1].values
  if websettings_values.netname == nil then websettings_values.netname = "olsrnet" end
  if websettings_values.ssid == nil then websettings_values.ssid = "X-Wrt" end
  if websettings_values.channel == nil then websettings_values.channel = "6" end
  local mydev 
  mydev = net.wireless()
   
  local form = formClass.new(tr("Service Settings"))
  form:Add("select",websettings[1].name..".enable",websettings_values.enable,"Service","string")
	form[websettings[1].name..".enable"].options:Add("0","Disable")
	form[websettings[1].name..".enable"].options:Add("1","Enable")
	form:Add_help(tr("olsr_msg#Olsr"),tr([[olsr_help_msg#OLSR is a great routing protocol.<br />
    Remember set all Access Point in Ad-hoc mode, the same ESSID at everyone and
    thoes IP in same subnet "10.128.1.1" mask "255.255.0.0" 
    ]]))
	form:Add_help(tr("olsr_var_service#Service"),tr("olsr_help_service#Turns olsr enable or disable"))

	form:Add("select",websettings[1].name..".userlevel",websettings_values.userlevel,"Configuration Mode","string")
	form[websettings[1].name..".userlevel"].options:Add("0","Select Mode")
	form[websettings[1].name..".userlevel"].options:Add("1","Beginer")
	form[websettings[1].name..".userlevel"].options:Add("2","Medium")
--	form[websettings[1].name..".userlevel"].options:Add("2","Advanced")
--	form[websettings[1].name..".userlevel"].options:Add("3","Expert")
	form:Add_help(tr("_var_mode#Configuration Mode"),tr("_help_mode#"..[[
          Select mode of configuration page.<br />
          <strong>Beginer :</strong><br />
          This basic mode write the propers configuration files.
          <br /><br />
          <strong>Expert :</strong><br />
          This mode keep your configurations file and you edit they by your self.
          ]]))
  form:Add("text",websettings[1].name..".netname",websettings_values.netname,tr("olsrdNetName#OLSR Net Name"),"string")
  form:Add("text",websettings[1].name..".nodenumber",websettings_values.nodenumber,tr("olsrdNodeNum#OLSR Node Number"))
  form:Add("select",websettings[1].name..".device",websettings_values.device,tr("cportal_var_device#Device Network"),"string")
  for k, v in pairs(net.wireless()) do
    form[websettings[1].name..".device"].options:Add(k,k)
  end    
  form:Add("text",websettings[1].name..".ssid",websettings_values.ssid,tr("olsrdSsId#SSID"),"string")
  form:Add("text",websettings[1].name..".channel",websettings_values.channel,tr("olsrdChannel#Wifi Channel"),"int,>0,<15")
  return form
end

function general_form()
  if olsr.general == nil then general = olsr:set("olsr","general") 
  else general = olsr.general end
--  general_values = general[1].values
  local form = formClass.new(tr("General Settings"))
--[[
  form:Add("select","olsr.general.DebugLevel",general.DebugLevel,tr("Debug Level"),"string")
	form["olsr.general.DebugLevel"].options:Add("0","0")
	form["olsr.general.DebugLevel"].options:Add("1","1")
	form["olsr.general.DebugLevel"].options:Add("2","2")
	form["olsr.general.DebugLevel"].options:Add("3","3")
	form["olsr.general.DebugLevel"].options:Add("4","4")
	form["olsr.general.DebugLevel"].options:Add("5","5")
	form["olsr.general.DebugLevel"].options:Add("6","6")
	form["olsr.general.DebugLevel"].options:Add("7","7")
	form["olsr.general.DebugLevel"].options:Add("8","8")
	form["olsr.general.DebugLevel"].options:Add("9","9")
]]--
--	form:Add_help(tr("olsr_var_DebugLeve#Debug Level"),tr([[Controls the amount of
--   debug output olsrd sends to stdout. If set to 0, olsrd will detatch from the 
--   current process and run in the background. A value of 9 yields a maximum of 
--   debug output. Defaults to 0. 
--  ]]))
  form:Add("select","olsr.general.IpVersion",general.IpVersion,tr("Ip Version"),"string")
	form["olsr.general.IpVersion"].options:Add("4","4")
	form["olsr.general.IpVersion"].options:Add("6","6")
	form:Add_help(tr("olsr_var_IpVersion#Ip Version"),tr([[Olsrd supports both IP
   version 4 and 6. This option controls what IP version olsrd is to use. 
   Defaults to 4. 
  ]]))
	
  form:Add("select","olsr.general.AllowNoInt",general.AllowNoInt,tr("Allow No Interface"),"string")
	form["olsr.general.AllowNoInt"].options:Add("yes",tr("Yes"))
	form["olsr.general.AllowNoInt"].options:Add("no",tr("No"))
	form:Add_help(tr("olsr_var_AllowNoInt#Allow No Interface"),tr([[
    Olsrd supports dynamic configuration of network interfaces. This means that 
    interfaces on which olsrd runs, can be reconfigured and olsrd will update 
    itself with no need to be restarted. Olsrd also supports removal and 
    addittion of interfaces in run-time. This option specifies if olsrd should 
    keep running if no network interfaces are available. Defaults to yes.
    ]]))
  form:Add("select","olsr.general.TosValue",general.TosValue,tr("Tos Value"),"string")
	form["olsr.general.TosValue"].options:Add("16","16")
	form["olsr.general.TosValue"].options:Add("0","0")
	form["olsr.general.TosValue"].options:Add("1","1")
	form["olsr.general.TosValue"].options:Add("2","2")
	form["olsr.general.TosValue"].options:Add("3","3")
	form["olsr.general.TosValue"].options:Add("4","4")
	form["olsr.general.TosValue"].options:Add("5","5")
	form["olsr.general.TosValue"].options:Add("6","6")
	form["olsr.general.TosValue"].options:Add("7","7")
	form["olsr.general.TosValue"].options:Add("8","8")
	form["olsr.general.TosValue"].options:Add("9","9")
	form["olsr.general.TosValue"].options:Add("10","10")
	form["olsr.general.TosValue"].options:Add("11","11")
	form["olsr.general.TosValue"].options:Add("12","12")
	form["olsr.general.TosValue"].options:Add("13","13")
	form["olsr.general.TosValue"].options:Add("14","14")
	form["olsr.general.TosValue"].options:Add("15","15")
	form:Add_help(tr("olsr_var_TosValuet#Tos Value"),tr([[
    This value controls the type of service value to set in the IP header of 
    OLSR control traffic. Defaults to 16
    ]]))
  form:Add("text","olsr.general.Willingness",general.Willingness,tr("Willingness"),"int,>=0,<8")
	form:Add_help(tr("olsr_var_Willingness#Willingness"),tr([[
    Nodes participating in a OLSR routed network will announce their willingness 
    to act as relays for OLSR control traffic for their neighbors. This option 
    specifies a fixed willingness value to be announced by the local node. 4 is 
    a neutral option here, while 0 specifies that this node will never act as a 
    relay, and 7 specifies that this node will always act as such a relay. If 
    this option is not set in the configuration file, then olsrd will try to 
    retrieve information about the system power and dynamically update 
    willingness according to this info. If no such info can be retrieved 
    willingness is set to 4. 
    ]]))
  form:Add("select","olsr.general.UseHysteresis",general.UseHysteresis,tr("Use Hysteresis"),"string")
	form["olsr.general.UseHysteresis"].options:Add("yes",tr("Yes"))
	form["olsr.general.UseHysteresis"].options:Add("no",tr("No"))
	form:Add_help(tr("olsr_var_UseHysteresis#Use Hysteresis"),tr([[
    If set to yes hysteresis will be used as explained in section 14 of RFC3626. 
    ]]))
  if olsr.general.UseHysteresis == "yes" then
    form:Add("text","olsr.general.HystScaling",general.HystScaling,tr("Hysteresis Scaling"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystScaling#Hysteresis Scaling"),tr([[
      Sets the scaling value used by the hysteresis algorithm. This must be a 
      positive floating point value smaller than 1.0. Consult RFC3626 for 
      details. The default value is 0.5.  
      ]]))
    form:Add("text","olsr.general.HystThrHigh",general.HystThrHigh,tr("Hysteresis High Mark"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystThrHigh#Hysteresis High Mark"),tr([[
      This option sets the upper threshold for accepting a link in hysteresis 
      calculation. The value must be higher than the one set as the lower 
      threshold. Defaults to 0.8.  
      ]]))
    form:Add("text","olsr.general.HystThrLow",general.HystThrLow,tr("Hysteresis Low Mark"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystThrLow#Hysteresis Low Mark"),tr([[
      This option sets the lower threshold for setting a link to asymmetric 
      using hysteresis. The value must be lower than the one set as the upper 
      threshold. Defaults to 0.3.  
      ]]))
  end
  form:Add("text","olsr.general.Pollrate",general.Pollrate,tr("Poll rate"),"int")
  form:Add_help(tr("olsr_var_Pollratew#Poll rate"),tr([[
      This option sets the interval, in seconds, that the olsrd event scheduler 
      should be set to poll. A setting of 0.2 will set olsrd to poll for events 
      every 0.2 seconds. Defaults to 0.1.  
    ]]))

  form:Add("select","olsr.general.TcRedundancy",general.TcRedundancy,tr("TC Redundancy"),"string")
	form["olsr.general.TcRedundancy"].options:Add("0","0")
	form["olsr.general.TcRedundancy"].options:Add("1","1")
	form["olsr.general.TcRedundancy"].options:Add("2","2")
  form:Add_help(tr("olsr_var_TcRedundancy#TC Redundancy"),tr([[
      This value controls the TC redundancy used by the local node in TC message 
      generation. To enable a more robust understanding of the topology, nodes 
      can be set to announce more than just their MPR selector set in TC 
      messages. If set to 0 the advertised link set of the node is limited to 
      the MPR selectors. If set to 1 the advertised link set of the node is the 
      union of its MPR set and its MPR selector set. Finally, if set to 2 the 
      advertised link set of the node is the full symmetric neighbor set of the 
      node. Defaults to 0.    
      ]]))

  form:Add("text","olsr.general.MprCoverage",general.MprCoverage,tr("Mpr Coverage"),"int")
  form:Add_help(tr("olsr_var_MprCoverage#Mpr Coverage"),tr([[
      This value decides how many MPRs a node should attempt to select for every 
      two hop neighbor. Defaults to 1 , and any other setting will severly 
      reduce the optimization introduced by the MPR secheme!  
    ]]))

  form:Add("select","olsr.general.LinkQualityLevel",general.LinkQualityLevel,tr("Link Quality Level"),"string")
	form["olsr.general.LinkQualityLevel"].options:Add("0","0")
	form["olsr.general.LinkQualityLevel"].options:Add("1","1")
	form["olsr.general.LinkQualityLevel"].options:Add("2","2")
  form:Add_help(tr("olsr_var_LinkQualityLevel#Link Quality Level"),tr([[
      This setting decides the Link Quality scheme to use. If set to 0 link 
      quality is not regarded and olsrd runs in "RFC3626 mode". If set to 1 link 
      quality is used when calculating MPRs. If set to 2 routes will also be 
      calculated based on distributed link quality information. Note that a 
      setting of 1 or 2 breaks RFC3626 compability! This option should therefore 
      only be set to 1 or 2 if such a setting is used by all other nodes in the 
      network.  
    ]]))
  form:Add("checkbox","olsr.general.LinkQualityFishEye",general.LinkQualityFishEye,tr("Link Quality Fish Eye"),"string")
  form:Add_help(tr("olsr_var_LinkQualityFishEye#Link Quality Fish Eye"),tr([[
    Looking for documentation
    ]]))
  form:Add("text","olsr.general.LinkQualityWinSize",general.LinkQualityWinSize,tr("Link Quality WinSize"),"string")
  form:Add_help(tr("olsr_var_LinkQualityWinSize#Link Quality WinSize"),tr([[
    Looking for documentation
    ]]))
  form:Add("text","olsr.general.LinkQualityDijkstraLimit",general.LinkQualityDijkstraLimit,tr("Link Quality DijkstraLimit"),"string")
  form:Add_help(tr("olsr_var_LinkQualityDijkstraLimit#Link Quality DijkstraLimit"),tr([[
    Looking for documentation
    ]]))
--
--  form:Add("text","olsr.general.FIBMetric",general.FIBMetric,tr("FIBMetric"),"string")
--  form:Add_help(tr("olsr_var_FIBMetric#FIBMetric"),tr([[
--    Looking for documentation
--    ]]))
--  form:Add("text","olsr.general.NatThreshold",general.NatThreshold,tr("NatThreshold"),"string")
--  form:Add_help(tr("olsr_var_NatThreshold#NatThreshold"),tr([[
--    Looking for documentation
--    ]]))
--
  return form
end

function hna4_form()
--  if olsr.Hna4 == nil then hna4 = olsr:set("Hna4") 
--  else 
    hna4 = olsr.Hna4 
--  end
  local form = formClass.new(tr("Hna4 Settings"))
  if hna4 then
    hna4_values = hna4[1].values
    for i=1,#hna4 do
      if i > 1 then form:Add("subtitle","Interface") end
      form:Add("text",hna4[i].name..".NetAddr",hna4[i].values.NetAddr,"Net Address","string","width:99%")
      form:Add("text",hna4[i].name..".NetMask",hna4[i].values.NetMask,"Net Mask","string","width:99%")
      form:Add("link","remove_"..hna4[i].name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..hna4[i].name.."= &__menu="..__FORM.__menu.."&option=hna4",tr("Remove Network"))
    end
    form:Add_help(tr("olsr_var_NetMask#Net Address"),tr([[
        This optionblock specifies one or more network interfaces on which olsrd 
        should run. Atleast one network interface block must be specified for 
        olsrd to run! Various parameters can be specified on individual interfaces 
        or groups of interfaces. This optionblock can be repeated to add multiple 
        interface configurations. 
        ]]))
    form:Add_help(tr("olsr_var_NetMask#Net Mask"),tr([[
        This optionblock specifies one or more network interfaces on which olsrd 
        should run. Atleast one network interface block must be specified for 
        olsrd to run! Various parameters can be specified on individual interfaces 
        or groups of interfaces. This optionblock can be repeated to add multiple 
        interface configurations. 
        ]]))
  end
  form:Add("link","add_Hna4",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setolsr=Hna4&__menu="..__FORM.__menu.."&option=hna4",tr("Add Network"))
  return form
end

function hna6_form()
--  if olsr.Hna6 == nil then hna4 = olsr:set("Hna4") 
--  else 
    hna6 = olsr.Hna6 
--  end
  local form = formClass.new(tr("Hna6 Settings"))
  if hna6 then
    hna6_values = hna6[1].values
    for i=1,#hna6 do
      if i > 1 then form:Add("subtitle","Interface") end
      form:Add("text",hna6[i].name..".NetAddr",hna6[i].values.NetAddr,"Net Address","string","width:99%")
      form:Add("text",hna6[i].name..".NetMask",hna6[i].values.NetMask,"Net Mask","string","width:99%")
      form:Add("link","remove_"..hna6[i].name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..hna6[i].name.."= &__menu="..__FORM.__menu.."&option=hna6",tr("Remove Network"))
    end
    form:Add_help(tr("olsr_var_NetMask#Net Address"),tr([[
        This optionblock specifies one or more network interfaces on which olsrd 
        should run. Atleast one network interface block must be specified for 
        olsrd to run! Various parameters can be specified on individual interfaces 
        or groups of interfaces. This optionblock can be repeated to add multiple 
        interface configurations. 
        ]]))
    form:Add_help(tr("olsr_var_NetMask#Net Mask"),tr([[
        This optionblock specifies one or more network interfaces on which olsrd 
        should run. Atleast one network interface block must be specified for 
        olsrd to run! Various parameters can be specified on individual interfaces 
        or groups of interfaces. This optionblock can be repeated to add multiple 
        interface configurations. 
        ]]))
  end
  form:Add("link","add_hna6",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setolsr=hna6&__menu="..__FORM.__menu.."&option=hna6",tr("Add Network"))
  return form
end

function interfaces_form(form,user_level)
  local form = form
  local user_level = user_level or loc_userlevel
  local mydev 
  mydev = net.wireless()
  if olsr.Interface == nil then interface = olsr:set("Interface") 
  else interface = olsr.Interface end
--  interface_values = interface[1].values
  form = formClass.new(tr("Interfaces Settings"))
  for i=1,#interface do
    if i > 1 then form:Add("subtitle","Interface") end
    form:Add("select",interface[i].name..".Interface",interface[i].values.Interface,tr("cportal_var_device#Device Network"),"string")
      form[interface[i].name..".Interface"].options:Add("wl0","wl0")
--      form[interface[i].name..".Interface"].options:Add(type(mydev),type(mydev))
    if mydev == nil then 
      form[interface[i].name..".Interface"].options:Add("nil","nil")
    end    
--    for k, v in pairs(dev) do
--      form[interface[i].name..".Interface"].options:Add(k,k)
--    end
--    form:Add("text",interface[i].name..".Interface",interface[i].values.Interface,"Interface","string")
    form:Add_help(tr("olsr_var_Interface#Interface"),tr([[
      This optionblock specifies one or more network interfaces on which olsrd 
      should run. Atleast one network interface block must be specified for 
      olsrd to run! Various parameters can be specified on individual interfaces 
      or groups of interfaces. This optionblock can be repeated to add multiple 
      interface configurations. 
      ]]))

    if user_level > 1 then
      form:Add("select",interface[i].name..".AutoDetectChanges",interface[i].values.AutoDetectChanges,"AutoDetectChanges","string")
    	form[interface[i].name..".AutoDetectChanges"].options:Add("no","No")  
      form[interface[i].name..".AutoDetectChanges"].options:Add("yes",tr("Yes"))  

      form:Add("text",interface[i].name..".Ip4Broadcast",interface[i].values.Ip4Broadcast,"Ip4Broadcast","string")
      form:Add_help(tr("olsr_var_Ip4Broadcast#Ip4Broadcast"),tr([[
        Forces the given IPv4 broadcast address to be used as destination address 
        for all outgoing OLSR traffic on the interface. In reallity only the 
        address 255.255.255.255 makes sense to set here. If this option is not set 
        the broadcast address that the interface is configured with will be used. 
        This address will also be updated in run-time if a change is detected. 
        ]]))

      form:Add("select",interface[i].name..".Ip6AddrType",interface[i].values.Ip6AddrType,"Ip6AddrType","string")
      form[interface[i].name..".Ip6AddrType"].options:Add(""," ")  
      form[interface[i].name..".Ip6AddrType"].options:Add("site-local",tr("site-local"))  
      form[interface[i].name..".Ip6AddrType"].options:Add("global","global")  
      form:Add_help(tr("olsr_var_Ip6AddrType#Ip6AddrType"),tr([[
        This option sets what IPv6 address type is to be used in interface address 
        detection. Defaults to site-local.  
        ]]))

      form:Add("text",interface[i].name..".Ip6MulticastSite",interface[i].values.Ip6MulticastSite,"Ip6MulticastSite","string")
      form:Add_help(tr("olsr_var_Ip6MulticastSite#Ip6MulticastSite"),tr([[
        Sets the destionation of outgoing OLSR traffic on this interface to use 
        the specified IPv6 multicast address as destination if the site-local 
        address type is set on this interface.  
        ]]))

      form:Add("text",interface[i].name..".Ip6MulticastGlobal",interface[i].values.Ip6MulticastGlobal,"Ip6MulticastGlobal","string")
      form:Add_help(tr("olsr_var_Ip6MulticastGlobal#Ip6MulticastGlobal"),tr([[
        Sets the destionation of outgoing OLSR traffic on this interface to use 
        the specified IPv6 multicast address as destination if the global address 
        type is set on this interface.  
        ]]))

      form:Add("subtitle","&nbsp;")
      form:Add("text",interface[i].name..".HelloInterval",interface[i].values.HelloInterval,"HelloInterval","int,>=0")
      form:Add_help(tr("olsr_var_HelloInterval#HelloInterval"),tr([[
        Sets the interval on which HELLO messages will be generated and 
        transmitted on this interface.   
        ]]))

      form:Add("text",interface[i].name..".HelloValidityTime",interface[i].values.HelloValidityTime,"HelloValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_HelloValidityTime#HelloValidityTime"),tr([[
        Sets the validity time to be announced in HELLO messages generated by this 
        host on this interface. This value must be larger than than the HELLO 
        generation interval to make any sense. Defaults to 3 * the generation interval.  
        ]]))

      form:Add("text",interface[i].name..".TcInterval",interface[i].values.TcInterval,"TcInterval","int,>=0")
      form:Add_help(tr("olsr_var_TcInterval#TcInterval"),tr([[
        Sets the interval on which TC messages will be generated and transmitted 
        on this interface.   
        ]]))

      form:Add("text",interface[i].name..".TcValidityTime",interface[i].values.TcValidityTime,"TcValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_TcValidityTime#TcValidityTime"),tr([[
        Sets the validity time to be announced in TC messages generated by this 
        host on this interface. This value must be larger than than the TC 
        generation interval to make any sense. Defaults to 3 * the generation 
        interval.   
        ]]))

      form:Add("text",interface[i].name..".MidInterval",interface[i].values.MidInterval,"MidInterval","int,>=0")
      form:Add_help(tr("olsr_var_MidInterval#MidInterval"),tr([[
        Sets the interval on which MID messages will be generated and transmitted 
        on this interface.   
        ]]))

      form:Add("text",interface[i].name..".MidValidityTime",interface[i].values.MidValidityTime,"MidValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_MidValidityTime#MidValidityTime"),tr([[
        Sets the validity time to be announced in MID messages generated by this 
        host on this interface. This value must be larger than than the MID 
        generation interval to make any sense. Defaults to 3 * the generation 
        interval.    
        ]]))

      form:Add("text",interface[i].name..".HnaInterval",interface[i].values.HnaInterval,"HnaInterval","int,>=0")
      form:Add_help(tr("olsr_var_HnaInterval#HnaInterval"),tr([[
        Sets the interval on which HNA messages will be generated and transmitted 
        on this interface.    
        ]]))

      form:Add("text",interface[i].name..".HnaValidityTime",interface[i].values.HnaValidityTime,"HnaValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_HnaValidityTime#HnaValidityTime"),tr([[
        Sets the validity time to be announced in HNA messages generated by this 
        host on this interface. This value must be larger than than the HNA generation 
        interval to make any sense. Defaults to 3 * the generation interval.    
        ]]))

      form:Add("text",interface[i].name..".Weight",interface[i].values.Weight,"Weight","int,>=0")
      form:Add_help(tr("olsr_var_Weight#Weight"),tr([[
        When multiple links exist between hosts the weight of the interface is used 
        to determine the link to route by. Normally the weight is automatically 
        calculated by olsrd based on the characteristics of the interface, but here 
        you can specify a fixed value. Olsrd will choose links with the lowest value.   
        ]]))
    end
  end
  return form
end

function status_form()
  local str = status_str()
  local vizstr = viz_str()
  form = formClass.new("Status")
  form:Add("text_line","viz",str)
  form:Add_help("Network Vizualitation",vizstr)
  return form
end

function viz_form()
  local vizstr = viz_str()
  form = formClass.new("Network Vizualitation",true)
  form:Add("text_line","viz",vizstr)
--  return form
  return vizstr
end

function status_str()
  local pepe = io.popen([[wget -q -O - http://127.0.0.1:2006/]])
  local str = ""
  for line in pepe:lines() do
    if string.trim(line) == "Table: Links" then
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"8\">"..line.."</td></tr>"
    elseif string.trim(line) == "Table: Neighbors" then
      str = str .."</table>"
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"6\">"..line.."</td></tr>"
    elseif string.trim(line) == "Table: Topology" then
      str = str .."</table>"
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"5\">"..line.."</td></tr>"
    elseif string.trim(line) == "Table: HNA" then
      str = str .."</table>"
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"3\">"..line.."</td></tr>"
    elseif string.trim(line) == "Table: MID" then
      str = str .."</table>"
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"2\">"..line.."</td></tr>"
    elseif string.trim(line) == "Table: Routes" then
      str = str .."</table>"
      str = str .."<table border=\"1\">"
      str = str .."<tr><td colspan=\"5\">"..line.."</td></tr>"
    else
--    local t = string.gmatch(line,"^ ")
      str = str .."<tr>"
      for t in string.gmatch(line,"[^\t]+") do
        str = str .."<td>"..t.."<td>"
      end
      str = str .."</tr>"
    end
  end
  str = str .."</table>"
  return str
end

function viz_str()
local vizstr = [[
<NOSCRIPT>
<H1>OLSR Viz</H1>
<TABLE BORDER="0" CLASS="note"><TR><TD>No JavaScript - no Viz.</TD></TR>
</TABLE>
<P>&nbsp;</P></NOSCRIPT>
<SCRIPT SRC="/js/olsr-viz.js" LANGUAGE="JavaScript1.2" TYPE="text/javascript"></SCRIPT>

<DIV ID="main" STYLE="width: 100%; height: 400px; border: 1px solid #ccc; margin-left:auto; margin-right:auto; text-align:center; overflow: scroll">
  <DIV ID="edges" STYLE="width: 1px; height: 1px; position: relative; z-index:2"></DIV>
  <DIV ID="nodes" STYLE="width: 1px; height: 1px; position: relative; z-index:4"></DIV>
</DIV>
<DIV STYLE="z-index:99">
<FORM ACTION="">
<P><B TITLE="Defines the display magification.">Zoom</B>&nbsp;
<A HREF="javascript:set_scale(scale+0.1)">+</A>&nbsp;
<A HREF="javascript:set_scale(scale-0.1)">&ndash;</A>&nbsp;
<INPUT ID="zoom" NAME="zoom" TYPE="text" VALUE="2.0" SIZE="5" ONCHANGE="set_scale()">&nbsp;&nbsp;
<B TITLE="Limits the view to a maximal hop distance.">Metric</B>&nbsp;
<A HREF="javascript:set_maxmetric(maxmetric+1)">+</A>&nbsp;
<A HREF="javascript:if(0<maxmetric)set_maxmetric(maxmetric-1)">&ndash;</A>&nbsp;
<INPUT ID="maxmetric" NAME="maxmetric" TYPE="text" VALUE="3" SIZE="4" ONCHANGE="set_maxmetric(this.value)">&nbsp;&nbsp;
<B TITLE="Enables the automatic layout optimization.">Optimization</B>
<INPUT ID="auto_declump" NAME="auto_declump" TYPE="checkbox" ONCHANGE="set_autodeclump(this.checked)" CHECKED="CHECKED">&nbsp;&nbsp;
<B TITLE="Show hostnames.">Hostnames</B>
<INPUT ID="show_hostnames" NAME="show_hostnames" TYPE="checkbox" ONCHANGE="set_showdesc(this.checked)" CHECKED="CHECKED">&nbsp;&nbsp;
<A HREF="javascript:viz_save()" TITLE="Saves the current settings to a cookie.">Save</A>&nbsp;&nbsp;
<A HREF="javascript:viz_reset()" TITLE="Restarts the Viz script.">Reset</A>
</P>
</FORM>
</DIV>
<P><SPAN ID="debug" STYLE="visibility:hidden;"></SPAN>
<IFRAME ID="RSIFrame" NAME="RSIFrame" STYLE="border:0px; width:0px; height:0px; visibility:hidden;">
</IFRAME>

<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
  viz_setup("RSIFrame","main","nodes","edges");
  viz_update();
</SCRIPT> </P>
]]

return vizstr

end

function plugin_list_form(form,user_level)
  local tplugins = get_installed_plugin()
  local badplugins = get_bad_plugin()
  local pl_name = __FORM[plname]
  local molsr = uci.get_all("olsr")
  local form = form
  local user_level = user_level or loc_userlevel
  form = formClass.new(tr("Plugins List"))

  if badplugins ~= nil then
    form:Add("subtitle","Configured with unknow Library")
    for i, v in pairsByKeys(badplugins) do
--[[
      form:Add("select","olsr."..i,"keep",i,"string")
      form["olsr."..i].options:Add("bad","Remove Configuration")
      form["olsr."..i].options:Add("keep","Keep Configuration")
]]--
      for k, v in pairs(molsr[i]) do
        if k ~= ".name"
        and k ~= ".type" then
          form:Add("link","remove_"..v,__SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option=plugin&".."UCI_CMD_delolsr."..molsr[i][".name"].."=",tr("Remove").." "..tr("Configuration for").." "..k.." "..v)
        end
      end
      form:Add("text_line","separacion","&nbsp;","algo","algomas")
    end
  end

  if tplugins ~= nil then
    form:Add("subtitle","Libraries installed but not configured")
    for i, v in pairsByKeys(tplugins) do
      if molsr[i] == nil then
        form:Add("link","Add_plugin_"..v,__SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option=plugin&".."plname="..i.."&UCI_MSG_setolsr."..i.."=LoadPlugin&UCI_MSG_setolsr."..i..".Library="..v,tr("Configure plugin for Library").." "..v)
      end
      form:Add("text_line","separacion","&nbsp;","algo")
    end
  end
  return form
end

function add_plugin_form(form,user_level)
  if form == nil then
    form = formClass.new("Add plugin")
  else
    form:Add("subtitle","Add plugin")
  end
  form:Add("text_line","add_plugin",[[<table width="99%">
  <tr><td width="150px">Plugin name</td><td width="400px" >Library file</td></tr>
  <tr><td ><input type="text" name="Library_name" /></td>
  <td><input type="text" name="Library_file" style="width:99%" /></td></tr>
  <tr><td>&nbsp;</td><td align="right"><input type="submit" name="Add_Plagin" value="]]..tr("Add Plugin")..[[" ></td></tr>
  </table>]])
  return form
end

function plugins_form(form,user_level)
--[[
  local tplugins = get_installed_plugin()
  local molsr = uci.get_all("olsr")
  local form = form
  local user_level = user_level or loc_userlevel
  form = formClass.new(pl_name)
  for k, v in pairs(molsr[pl_name]) do
    if k ~= ".name"
    and k ~= ".type" then
      form:Add("text","olsr."..pl_name.."."..k,v,k,"string","width:99%;")
    end
  end
]]--
--[[
  for k, v in pairs(plugin) do
    if k ~= ".name"
    and k ~= ".type"
    and k ~= "Library" then
      local paramname = uci.add("olsr",pl_name)
      uci.set("olsr",paramname,k,v)
      uci.delete("olsr",pl_name,k)
    end
  end
  uci.save("olsr")
  __UCI_UPDATED:countUpdated()
]]--
  local pl_name = __FORM["plname"]
  local plugin = uci.get_section("olsr",pl_name)
  form = tbformClass.new(pl_name.." "..tr("Configuration of").." "..plugin.Library)
  form:Add_col("label", "PlParam", "PlParam", "220px","string,len>1","width:220px")
  form:Add_col("text", "value", "Value", "220px","string","width:220px")
  form:Add_col("link", "Remove","Remove", "100px","","width:100px")
  for k, v in pairs(plugin) do
    if  k ~= ".name"
    and k ~= ".type"
    and k ~= "Library" then
      form:New_row()
      form:set_col("PlParam","olsr."..pl_name.."."..k, k)
      form:set_col("value","olsr."..pl_name.."."..k, v)
      form:set_col("Remove", "Remove_"..k, __SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option="..__FORM.option.."&plname="..__FORM["plname"].."&UCI_MSG_delolsr."..pl_name.."."..k.."=")
    end
  end
  return form
end

return olsrd
