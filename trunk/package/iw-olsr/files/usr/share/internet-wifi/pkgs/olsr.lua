--[[
    Availables functions

]]--
require("net")
require("tbform")
-- require("iw-uci")
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
local tostring = tostring
local net = net
local uci = uci
local __UCI_UPDATED = __UCI_UPDATED
-- local uciClass = uciClass
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
local ifwifi = uci.get_type("wireless","wifi-iface")

  if __FORM["Library_name"] and __FORM["Library_file"] then
    uci.set("olsr",__FORM["Library_name"],"LoadPlugin")
    uci.set("olsr",__FORM["Library_name"],"Library",__FORM["Library_file"])
    uci.save("olsr")
  end
  if __FORM["Parameter_name"] and __FORM["Parameter_value"] then
    local name = __FORM["plname"]
    if uci.get("olsr",name,__FORM["Parameter_name"]) ~= nil then
      name = uci.add("olsr",name)
    end
    uci.set("olsr",name,__FORM["Parameter_name"],__FORM["Parameter_value"])
    uci.save("olsr")
  end
  if __FORM["IpcHostIpAddr"] and __FORM["IpcHostIpAddr"] ~= "" then
    name = uci.add("olsr","ipcHost")
    uci.set("olsr",name,"Host",__FORM["IpcHostIpAddr"])
    uci.save("olsr")
  end
  if __FORM["IpcNetAddr"] 
  and __FORM["IpcNetAddr"] ~= ""
  and __FORM["IpcNetMask"]
  and __FORM["IpcNetMask"] ~= "" then
    name = uci.add("olsr","ipcNet")
    uci.set("olsr",name,"NetAddr",__FORM["IpcNetAddr"])
    uci.set("olsr",name,"NetMask",__FORM["IpcNetMask"])
    uci.save("olsr")
  end

  local molsr = uci.get_all("olsr")
  if molsr == nil then
    os.execute("echo -n '' > /etc/config/olsr 2> /dev/null") 
    uci.set("olsr","webadmin","websettings")
    uci.save("olsr")
  end  
  if uci.get("olsr","webadmin") == nil then
    uci.unload("olsr")
    os.execute("cp /etc/config/olsr /etc/config/olsr.backup 2> /dev/null")
    os.execute("echo -n '' > /etc/config/olsr 2> /dev/null") 
  end
  if uci.get("olsr","webadmin") == nil then
    uci.set("olsr","webadmin","websettings")
  end

  local userlevel = tonumber(uci.check_set("olsr","webadmin","userlevel","1")) or 1

  if #ifwifi == 1 and uci.get("olsr","webadmin","ifwifi") ~= ifwifi[1].device then
    uci.set("olsr","webadmin","ifwifi",ifwifi[1].device)
  end

  uci.check_set("olsr","webadmin","netname","wifi")
  local set_nodenumber = uci.check_set("olsr","webadmin","nodenumber","1")
  uci.check_set("olsr","webadmin","ipaddr","10.128."..set_nodenumber..".1")
  uci.check_set("olsr","webadmin","netmask","255.255.0.0")
  if userlevel < 2 then
    uci.isdiff_set("olsr","webadmin","ipaddr","10.128."..set_nodenumber..".1")
    uci.isdiff_set("olsr","webadmin","netmask","255.255.0.0")
  end

  local set_device = uci.check_set("olsr","webadmin","device","br-wifi")
  uci.check_set("olsr","webadmin","ssid","X-Wrt")
  uci.check_set("olsr","webadmin","channel","6")

-- olsr --
  if uci.get("olsr","general") == nil then uci.set("olsr","general","olsr") end
--[[
  uci.check_set("olsr","webadmin","netname",set_netname)
  uci.check_set("olsr","webadmin","userlevel", "1")
  uci.check_set("olsr","webadmin","nodenumber",set_nodenumber)
  uci.check_set("olsr","webadmin","netmask", set_netmask)
  uci.check_set("olsr","webadmin","ipaddr", set_netaddr)
  uci.check_set("olsr","webadmin","device", set_device)
  uci.check_set("olsr","webadmin","ssid", set_ssid)
  uci.check_set("olsr","webadmin","channel", set_channel)
  uci.check_set("olsr","webadmin","enable", "1")
]]--
  if uci.get("olsr","IpcConnect") == nil then
    uci.set("olsr","IpcConnect","ipc")
  end
  uci.check_set("olsr","IpcConnect","MaxConnections","1")

  if uci.get_type("olsr","ipcHost") == nil then
    local name = uci.add("olsr","ipcHost")
    uci.set("olsr",name,"Host","127.0.0.1")
  end

  uci.check_set("olsr","general","UseHysteresis","no")
  uci.check_set("olsr","general","LinkQualityFishEye","1")
  uci.check_set("olsr","general","IpVersion","4")
  uci.check_set("olsr","general","AllowNoInt","yes")
  uci.check_set("olsr","general","TcRedundancy","2")
  uci.check_set("olsr","general","LinkQualityLevel","2")
  uci.check_set("olsr","general","MprCoverage","7")
  uci.check_set("olsr","general","LinkQualityWinSize","100")
  uci.check_set("olsr","general","LinkQualityDijkstraLimit","0 9.0")
  uci.check_set("olsr","general","DebugLevel","0")
  uci.check_set("olsr","general","Pollrate","0.025")
  uci.check_set("olsr","general","TosValue","16")
  uci.save("olsr")

  local interfaces = uci.get_type("olsr","Interface")
  if interfaces == nil then
    interface = uci.add("olsr","Interface")
    uci.set("olsr",interface,"Interface",set_device)
  end
  uci.save("olsr")
--   
  local iok = false
  interfaces = uci.get_type("olsr","Interface")
  for i=1, #interfaces do
      uci.check_set("olsr",interfaces[i][".name"],"MidValidityTime","324.0") 
      uci.check_set("olsr",interfaces[i][".name"],"TcInterval","4.0")
      uci.check_set("olsr",interfaces[i][".name"],"HnaValidityTime","108.0")
      uci.check_set("olsr",interfaces[i][".name"],"HelloValidityTime","108.0")
      uci.check_set("olsr",interfaces[i][".name"],"TcValidityTime","324.0")
      uci.check_set("olsr",interfaces[i][".name"],"HnaInterval","18.0")
      uci.check_set("olsr",interfaces[i][".name"],"HelloInterval","6.0")
      uci.check_set("olsr",interfaces[i][".name"],"MidInterval","18.0")
      uci.check_set("olsr",interfaces[i][".name"],"AutoDetectChanges","yes")

    if #interfaces == 1 then 
      uci.set("olsr",interfaces[i][".name"],"Interface",set_device)
    else
      if uci.get("olsr",interfaces[i][".name"],"Interface") == set_device then
        iok = true
        break
      end
    end
  end

  uci.save("olsr")

  
function dyn_gw_default(library)
  local extra_gw = uci.get_type("olsr","dyn_gw")
  if extra_gw ~= nil then
    for i=1, #extra_gw do
      uci.delete("olsr",extra_gw[i][".name"])
    end
  end
  uci.delete("olsr","dyn_gw")
  uci.set("olsr","dyn_gw","LoadPlugin")
  uci.set("olsr","dyn_gw","Library",library)
  uci.set("olsr","dyn_gw","Ping","141.1.1.1")
  local extraparam = uci.add("olsr","dyn_gw")
  uci.set("olsr",extraparam,"Ping","194.25.2.129")
  uci.save("olsr")
end

function nameservice_default(library)
  local config = uci.get_all("olsr")
  uci.delete("olsr","nameservice")
  local ip = uci.get("olsr","webadmin","ipaddr")
  local host = "host"..string.gsub(ip,"(%d+)%.(%d+)%.(%d+)%.(%d+)","%4\.%1\-%2\-%3")
  uci.set("olsr","nameservice","LoadPlugin")
  uci.set("olsr","nameservice","Library",library)
  uci.set("olsr","nameservice","hosts_file","/etc/hosts")
  uci.set("olsr","nameservice","name",host)
  uci.set("olsr","nameservice","suffix",".olsr")
  uci.set("olsr","nameservice","lat","-27.448232")         
  uci.set("olsr","nameservice","lon","-58.989523")
  uci.save("olsr")
end

function txtinfo_default(library)
  uci.delete("olsr","txtinfo")
  uci.set("olsr","txtinfo","LoadPlugin")
  uci.set("olsr","txtinfo","Library",library)
  uci.set("olsr","txtinfo","accept","127.0.0.1")
  uci.save("olsr")
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
      end
    elseif name == "nameservice" then
      if config[name] == nil then
        nameservice_default(library)
      end
    elseif name == "txtinfo" then
      if config[name] == nil then 
        txtinfo_default(library)
      end
--    else
--      uci.delete("olsr",name)
--      uci.set("olsr",name,"LoadPlugin")
--      uci.set("olsr",name,"Library",library)
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
    end
  end

  if ok == false then
    badplugin = nil
  end
  return badplugin
end

function set_default()

end

function set_menu()
  local tplugins = get_installed_plugin()
  local badplugin = get_bad_plugin() 
  local user_level = userlevel or 1
  local molsr = uci.get_all("olsr")
  local plnotconf = false
  for n, file in pairsByKeys(tplugins) do
    if molsr[n] == nil then
      plnotconf = true
    end
  end
  __MENU.HotSpot.OLSR = menuClass.new()
  __MENU.HotSpot.OLSR:Add("Core","olsr.sh")
  if user_level > 1 then
    if user_level > 2 then __MENU.HotSpot.OLSR:Add("General","olsr.sh?option=general") end 
    __MENU.HotSpot.OLSR:Add("Ip Connect","olsr.sh?option=Ipc")
    __MENU.HotSpot.OLSR:Add("Hna4","olsr.sh?option=Hna4")
    if uci.get("olsr","general","IpVersion") == 6 then
      __MENU.HotSpot.OLSR:Add("Hna6","olsr.sh?option=Hna6")
    end

    if tplugins ~= nil or badplugin ~= nil then
      __MENU.HotSpot.OLSR:Add("Plugins")
      __MENU.HotSpot.OLSR.Plugins = menuClass.new()
      if badplugin ~= nil
      or plnotconf == true then
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
  set_default()

  local form = formClass.new(tr("Service Settings"))
  form:Add("select","olsr.webadmin.enable",uci.check_set("olsr","webadmin","enable","1"),"Service","string")
	form["olsr.webadmin.enable"].options:Add("0","Disable")
	form["olsr.webadmin.enable"].options:Add("1","Enable")
	form:Add_help(tr("olsr_msg#Olsr"),tr([[olsr_help_msg#OLSR is a great routing protocol.<br />
    Remember set all Access Point in Ad-hoc mode, the same ESSID at everyone and
    thoes IP in same subnet "10.128.1.1" mask "255.255.0.0" 
    ]]))
	form:Add_help(tr("olsr_var_service#Service"),tr("olsr_help_service#Turns olsr enable or disable"))

  if string.match(__SERVER["SCRIPT_FILENAME"],"olsr.sh") then
  	form:Add("select","olsr.webadmin.userlevel",uci.check_set("olsr","webadmin","userlevel","1"),"Configuration Mode","string")
    form["olsr.webadmin.userlevel"].options:Add("0","Select Mode")
    form["olsr.webadmin.userlevel"].options:Add("1","Beginer")
    form["olsr.webadmin.userlevel"].options:Add("2","Medium")
    form["olsr.webadmin.userlevel"].options:Add("3","Advanced")
--    form[websettings[1].name..".userlevel"].options:Add("4","Expert")
    form:Add_help(tr("_var_mode#Configuration Mode"),tr("_help_mode#"..[[
          Select mode of configuration page.<br />
          <strong>Beginer :</strong><br />
          This basic mode write the propers configuration files.
          <br /><br />
          <strong>Expert :</strong><br />
          This mode keep your configurations file and you edit they by your self.
          ]]))
  else
    uci.set("olsr","webadmin","userlevel","1")
  end
  if userlevel > 1 then
    form:Add("text","olsr.webadmin.netname",uci.check_set("olsr","webadmin","netname","wifi"),tr("olsrdNetName#Network Name"),"string")
  end
  if userlevel < 2 then
    form:Add("text","olsr.webadmin.nodenumber",uci.check_set("olsr","webadmin","nodenumber","1"),tr("olsrdNodeNum#OLSR Node Number"))
  else
    form:Add("text","olsr.webadmin.ipaddr",uci.check_set("olsr","webadmin","ipaddr","10.128.1.1"),tr("olsrdNodeNum#OLSR Node Number"))
    form:Add("text","olsr.webadmin.netmask",uci.check_set("olsr","webadmin","netmask","255.255.0.0"),tr("olsrdNodeNum#OLSR Node Number"))
  end
  if #ifwifi > 1 then
    form:Add("select","olsr.webadmin.ifwifi",uci.check_set("olsr","webadmin","device","br-wifi"),tr("cportal_var_device#Device Network"),"string")
    for k, v in pairs(ifwifi) do
      form["olsr.webadmin.ifwifi"].options:Add(v.device,v.device)
    end
  else
    uci.set("olsr","webadmin","ifwifi",ifwifi[1].device)
  end    
  form:Add("text","olsr.webadmin.ssid",uci.check_set("olsr","webadmin","ssid","X-Wrt"),tr("olsrdSsId#SSID"),"string")
  form:Add("text","olsr.webadmin.channel",uci.check_set("olsr","webadmin","channel","6"),tr("olsrdChannel#Wifi Channel"),"int,>0,<15")
  uci.save("olsr")
  return form
end

function general_form()
  local form = formClass.new(tr("General Settings"))
  form:Add("select","olsr.general.IpVersion",uci.check_set("olsr","general","IpVersion","4"),tr("Ip Version"),"string")
	form["olsr.general.IpVersion"].options:Add("4","4")
	form["olsr.general.IpVersion"].options:Add("6","6")
	form:Add_help(tr("olsr_var_IpVersion#Ip Version"),tr([[Olsrd supports both IP
   version 4 and 6. This option controls what IP version olsrd is to use. 
   Defaults to 4. 
  ]]))
	
  form:Add("select","olsr.general.AllowNoInt",uci.check_set("olsr","general","AllowNoInt","yes"),tr("Allow No Interface"),"string")
	form["olsr.general.AllowNoInt"].options:Add("yes",tr("Yes"))
	form["olsr.general.AllowNoInt"].options:Add("no",tr("No"))
	form:Add_help(tr("olsr_var_AllowNoInt#Allow No Interface"),tr([[
    Olsrd supports dynamic configuration of network interfaces. This means that 
    interfaces on which olsrd runs, can be reconfigured and olsrd will update 
    itself with no need to be restarted. Olsrd also supports removal and 
    addittion of interfaces in run-time. This option specifies if olsrd should 
    keep running if no network interfaces are available. Defaults to yes.
    ]]))
  form:Add("select","olsr.general.TosValue",uci.check_set("olsr","general","TosValue","16"),tr("Tos Value"),"string")
	form["olsr.general.TosValue"].options:Add("16","16")
  for i=0, 15 do
    local j = tostring(i)
    form["olsr.general.TosValue"].options:Add(j,j)
	end
	form:Add_help(tr("olsr_var_TosValuet#Tos Value"),tr([[
    This value controls the type of service value to set in the IP header of 
    OLSR control traffic. Defaults to 16
    ]]))
  form:Add("text","olsr.general.Willingness",uci.get("olsr","general","Willingness"),tr("Willingness"),"int,>=0,<8")
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
  form:Add("select","olsr.general.UseHysteresis",uci.check_set("olsr","general","UseHysteresis","no"),tr("Use Hysteresis"),"string")
	form["olsr.general.UseHysteresis"].options:Add("yes",tr("Yes"))
	form["olsr.general.UseHysteresis"].options:Add("no",tr("No"))
	form:Add_help(tr("olsr_var_UseHysteresis#Use Hysteresis"),tr([[
    If set to yes hysteresis will be used as explained in section 14 of RFC3626. 
    ]]))
  if uci.get("olsr","general","UseHysteresis") == "yes" then
    form:Add("text","olsr.general.HystScaling",uci.get("olsr","general","HystScaling"),tr("Hysteresis Scaling"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystScaling#Hysteresis Scaling"),tr([[
      Sets the scaling value used by the hysteresis algorithm. This must be a 
      positive floating point value smaller than 1.0. Consult RFC3626 for 
      details. The default value is 0.5.  
      ]]))
    form:Add("text","olsr.general.HystThrHigh",uci.get("olsr","general","HystThrHigh"),tr("Hysteresis High Mark"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystThrHigh#Hysteresis High Mark"),tr([[
      This option sets the upper threshold for accepting a link in hysteresis 
      calculation. The value must be higher than the one set as the lower 
      threshold. Defaults to 0.8.  
      ]]))
    form:Add("text","olsr.general.HystThrLow",uci.get("olsr","general","HystThrLow"),tr("Hysteresis Low Mark"),"int,>=0.01,<=0.99")
  	form:Add_help(tr("olsr_var_HystThrLow#Hysteresis Low Mark"),tr([[
      This option sets the lower threshold for setting a link to asymmetric 
      using hysteresis. The value must be lower than the one set as the upper 
      threshold. Defaults to 0.3.  
      ]]))
  end
  form:Add("text","olsr.general.Pollrate",uci.check_set("olsr","general","Pollrate","0.025"),tr("Poll rate"),"int")
  form:Add_help(tr("olsr_var_Pollratew#Poll rate"),tr([[
      This option sets the interval, in seconds, that the olsrd event scheduler 
      should be set to poll. A setting of 0.2 will set olsrd to poll for events 
      every 0.2 seconds. Defaults to 0.1.  
    ]]))

  form:Add("select","olsr.general.TcRedundancy",uci.check_set("olsr","general","TcRedundancy","2"),tr("TC Redundancy"),"string")
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

  form:Add("text","olsr.general.MprCoverage",uci.get("olsr","general","MprCoverage",""),tr("Mpr Coverage"),"int")
  form:Add_help(tr("olsr_var_MprCoverage#Mpr Coverage"),tr([[
      This value decides how many MPRs a node should attempt to select for every 
      two hop neighbor. Defaults to 1 , and any other setting will severly 
      reduce the optimization introduced by the MPR secheme!  
    ]]))

  form:Add("select","olsr.general.LinkQualityLevel",uci.check_set("olsr","general","LinkQualityLevel","2"),tr("Link Quality Level"),"string")
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
  form:Add("checkbox","olsr.general.LinkQualityFishEye",uci.get("olsr","general","LinkQualityFishEye"),tr("Link Quality Fish Eye"),"string")
  form:Add_help(tr("olsr_var_LinkQualityFishEye#Link Quality Fish Eye"),tr([[
    Looking for documentation
    ]]))
  form:Add("text","olsr.general.LinkQualityWinSize",uci.get("olsr","general","LinkQualityWinSize"),tr("Link Quality WinSize"),"string")
  form:Add_help(tr("olsr_var_LinkQualityWinSize#Link Quality WinSize"),tr([[
    Looking for documentation
    ]]))
  form:Add("text","olsr.general.LinkQualityDijkstraLimit",uci.get("olsr","general","LinkQualityDijkstraLimit"),tr("Link Quality DijkstraLimit"),"string")
  form:Add_help(tr("olsr_var_LinkQualityDijkstraLimit#Link Quality DijkstraLimit"),tr([[
    Looking for documentation
    ]]))
  uci.save("olsr")
  return form
end

function ipc_form()
  local forms = {}
  forms[#forms+1] = formClass.new("IpcConnect "..tr("Settings"))
  forms[#forms]:Add("text","olsr.IpcConnect.MaxConnections",uci.get("olsr.IpcConnect.MaxConnections"), tr("Max Connections"),"string")

  local t = uci.get_type("olsr","ipcHost")
  if t then
    local form = tbformClass.new(tr("Hosts"))
    form:Add_col("label", "nothing", "", "220px","string,len>1","width:220px")
    form:Add_col("text", "Host", tr("Ip Address"), "220px","string","width:220px")
    form:Add_col("link", "Remove","Remove", "100px","","width:100px")
    for i = 1, #t do
      form:New_row()
      form:set_col("nothing","nothing", "Host")
      form:set_col("Host","olsr."..t[i][".name"]..".Host", t[i].Host)
      form:set_col("Remove", "Remove_"..t[i][".name"], __SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option="..__FORM.option.."&UCI_MSG_delolsr."..t[i][".name"].."=")
    end
    forms[#forms+1] = form
  end
  forms[#forms+1] = formClass.new(tr("Add new Host"))
  forms[#forms]:Add("text_line","add_parameter",[[<table width="280px">
  <tr>
    <td width="180px"><strong>]]..tr("Host Ip Address")..[[</strong></td>
    <td width="100px">&nbsp;</td>
  </tr>
  <tr>
    <td ><input type="text" name="IpcHostIpAddr" style="width:180px;"/></td>
    <td width="100px"><input type="submit" name="Add_Plagin" value="]]..tr("Add new")..[[" style="width:100px;" ></td>
  </tr>
  </table>]])
  
  t = uci.get_type("olsr","ipcNet")
  if t then
    local form = tbformClass.new(tr("Nets"))
    form:Add_col("label", "nothing", "", "220px","string,len>1","width:220px")
    form:Add_col("text", "netaddr", tr("Net Address"), "220px","string","width:220px")
    form:Add_col("text", "netmask", tr("Net Mask"), "220px","string","width:220px")
    form:Add_col("link", "Remove","Remove", "100px","","width:100px")
    for i = 1, #t do
      form:New_row()
      form:set_col("nothing","nothing", "Net")
      form:set_col("netaddr","olsr."..t[i][".name"]..".NetAddr", t[i].NetAddr)
      form:set_col("netmask","olsr."..t[i][".name"]..".NetMask", t[i].NetMask)
      form:set_col("Remove", "Remove_"..t[i][".name"], __SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option="..__FORM.option.."&UCI_MSG_delolsr."..t[i][".name"].."=")
    end
    forms[#forms+1] = form
  end
  forms[#forms+1] = formClass.new(tr("Add new Net"))
  forms[#forms]:Add("text_line","add_net",[[<table width="460px">
  <tr>
    <td width="180px"><strong>]]..tr("Net Ip Address")..[[</strong></td>
    <td width="220px" ><strong>]]..tr("Net Mask")..[[</strong></td>
    <td width="100px" >&nbsp;</td>
  </tr>
  <tr>
    <td ><input type="text" name="IpcNetAddr" style="width:180px;"/></td>
    <td><input type="text" name="IpcNetMask" style="width:180px;" /></td>
    <td width="100px"><input type="submit" name="Add_Plagin" value="]]..tr("Add new")..[[" style="width:100px;" ></td>
  </tr>
  </table>]])
  
  return forms
end

function hna_form()
  local hnaname = __FORM["option"] 
  local form = formClass.new(hnaname.." "..tr("Settings"))
  local hnat = uci.get_type("olsr",hnaname) 
  if hnat then
    for i=1,#hnat do
--      if i > 1 then form:Add("subtitle","Interface") end
      form:Add("text","olsr."..hnat[i][".name"]..".NetAddr",hnat[i].NetAddr,"Net Address","string","width:99%")
      form:Add("text","olsr."..hnat[i][".name"]..".NetMask",hnat[i].NetMask,"Net Mask","string","width:99%")
      form:Add("link","remove_"..hnat[i][".name"],__SERVER.SCRIPT_NAME.."?".."UCI_CMD_delolsr."..hnat[i][".name"].."= &__menu="..__FORM.__menu.."&option="..hnaname,tr("Remove Network"))
    end
--    if hnaname = "Hna4" then
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
--    else
    form:Add_help(tr("olsr_var_NetMask#Net Address"),tr([[
        This optionblock specifies one or more network interfaces on which olsrd 
        should run. Atleast one network interface block must be specified for 
        olsrd to run! Various parameters can be specified on individual interfaces 
        or groups of interfaces. This optionblock can be repeated to add multiple 
        interface configurations. 
        ]]))
--    end
  end
  form:Add("link","add_Hna",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setolsr="..hnaname.."&__menu="..__FORM.__menu.."&option="..hnaname,tr("Add Network"))
  return form
end

function interfaces_form(form,user_level)
  local form = form
  local user_level = user_level or userlevel

  interface = uci.get_type("olsr","Interface")
  form = formClass.new(tr("Interfaces Settings"))
  for i=1,#interface do
    if i > 1 then form:Add("subtitle","Interface") end
    form:Add("select","olsr."..interface[i][".name"]..".Interface",uci.check_set("olsr",interface[i][".name"],"Interface","br-wifi"),tr("cportal_var_device#Device Network"),"string")
    for k, v in pairs(net.dev_list()) do
      form["olsr."..interface[i][".name"]..".Interface"].options:Add(k,k)
    end
    form:Add_help(tr("olsr_var_Interface#Interface"),tr([[
      This optionblock specifies one or more network interfaces on which olsrd 
      should run. Atleast one network interface block must be specified for 
      olsrd to run! Various parameters can be specified on individual interfaces 
      or groups of interfaces. This optionblock can be repeated to add multiple 
      interface configurations. 
      ]]))

    if user_level > 1 then
      form:Add("select","olsr."..interface[i][".name"]..".AutoDetectChanges",uci.check_set("olsr",interface[i][".name"],"AutoDetectChanges","yes"),"AutoDetectChanges","string")
    	form["olsr."..interface[i][".name"]..".AutoDetectChanges"].options:Add("no","No")  
      form["olsr."..interface[i][".name"]..".AutoDetectChanges"].options:Add("yes",tr("Yes"))  

      form:Add("text","olsr."..interface[i][".name"]..".Ip4Broadcast",uci.get("olsr.",interface[i][".name"],"Ip4Broadcast",""),"Ip4Broadcast","string")
      form:Add_help(tr("olsr_var_Ip4Broadcast#Ip4Broadcast"),tr([[
        Forces the given IPv4 broadcast address to be used as destination address 
        for all outgoing OLSR traffic on the interface. In reallity only the 
        address 255.255.255.255 makes sense to set here. If this option is not set 
        the broadcast address that the interface is configured with will be used. 
        This address will also be updated in run-time if a change is detected. 
        ]]))

      form:Add("select","olsr."..interface[i][".name"]..".Ip6AddrType",uci.get("olsr",interface[i][".name"],"Ip6AddrType",""),"Ip6AddrType","string")
      form["olsr."..interface[i][".name"]..".Ip6AddrType"].options:Add(""," ")  
      form["olsr."..interface[i][".name"]..".Ip6AddrType"].options:Add("site-local",tr("site-local"))  
      form["olsr."..interface[i][".name"]..".Ip6AddrType"].options:Add("global","global")  
      form:Add_help(tr("olsr_var_Ip6AddrType#Ip6AddrType"),tr([[
        This option sets what IPv6 address type is to be used in interface address 
        detection. Defaults to site-local.  
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".Ip6MulticastSite",uci.get("olsr",interface[i][".name"],"Ip6MulticastSite",""),"Ip6MulticastSite","string")
      form:Add_help(tr("olsr_var_Ip6MulticastSite#Ip6MulticastSite"),tr([[
        Sets the destionation of outgoing OLSR traffic on this interface to use 
        the specified IPv6 multicast address as destination if the site-local 
        address type is set on this interface.  
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".Ip6MulticastGlobal",uci.get("olsr",interface[i][".name"],"Ip6MulticastGlobal",""),"Ip6MulticastGlobal","string")
      form:Add_help(tr("olsr_var_Ip6MulticastGlobal#Ip6MulticastGlobal"),tr([[
        Sets the destionation of outgoing OLSR traffic on this interface to use 
        the specified IPv6 multicast address as destination if the global address 
        type is set on this interface.  
        ]]))

      form:Add("subtitle","&nbsp;")
      form:Add("text","olsr."..interface[i][".name"]..".HelloInterval",uci.check_set("olsr",interface[i][".name"],"HelloInterval","18.0"),"HelloInterval","int,>=0")
      form:Add_help(tr("olsr_var_HelloInterval#HelloInterval"),tr([[
        Sets the interval on which HELLO messages will be generated and 
        transmitted on this interface.   
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".HelloValidityTime",uci.check_set("olsr",interface[i][".name"],"HelloValidityTime","108.0"),"HelloValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_HelloValidityTime#HelloValidityTime"),tr([[
        Sets the validity time to be announced in HELLO messages generated by this 
        host on this interface. This value must be larger than than the HELLO 
        generation interval to make any sense. Defaults to 3 * the generation interval.  
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".TcInterval",uci.check_set("olsr",interface[i][".name"],"TcInterval","4.0"),"TcInterval","int,>=0")
      form:Add_help(tr("olsr_var_TcInterval#TcInterval"),tr([[
        Sets the interval on which TC messages will be generated and transmitted 
        on this interface.   
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".TcValidityTime",uci.check_set("olsr",interface[i][".name"],"TcValidityTime","324.0"),"TcValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_TcValidityTime#TcValidityTime"),tr([[
        Sets the validity time to be announced in TC messages generated by this 
        host on this interface. This value must be larger than than the TC 
        generation interval to make any sense. Defaults to 3 * the generation 
        interval.   
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".MidInterval",uci.check_set("olsr",interface[i][".name"],"MidInterval","18.0"),"MidInterval","int,>=0")
      form:Add_help(tr("olsr_var_MidInterval#MidInterval"),tr([[
        Sets the interval on which MID messages will be generated and transmitted 
        on this interface.   
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".MidValidityTime",uci.check_set("olsr",interface[i][".name"],"MidValidityTime","324.0"),"MidValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_MidValidityTime#MidValidityTime"),tr([[
        Sets the validity time to be announced in MID messages generated by this 
        host on this interface. This value must be larger than than the MID 
        generation interval to make any sense. Defaults to 3 * the generation 
        interval.    
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".HnaInterval",uci.check_set("olsr",interface[i][".name"],"HnaInterval","18.0"),"HnaInterval","int,>=0")
      form:Add_help(tr("olsr_var_HnaInterval#HnaInterval"),tr([[
        Sets the interval on which HNA messages will be generated and transmitted 
        on this interface.    
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".HnaValidityTime",uci.check_set("olsr",interface[i][".name"],"HnaValidityTime","108.0"),"HnaValidityTime","int,>=0")
      form:Add_help(tr("olsr_var_HnaValidityTime#HnaValidityTime"),tr([[
        Sets the validity time to be announced in HNA messages generated by this 
        host on this interface. This value must be larger than than the HNA generation 
        interval to make any sense. Defaults to 3 * the generation interval.    
        ]]))

      form:Add("text","olsr."..interface[i][".name"]..".Weight",uci.get("olsr",interface[i][".name"],"Weight"),"Weight","int,>=0")
      form:Add_help(tr("olsr_var_Weight#Weight"),tr([[
        When multiple links exist between hosts the weight of the interface is used 
        to determine the link to route by. Normally the weight is automatically 
        calculated by olsrd based on the characteristics of the interface, but here 
        you can specify a fixed value. Olsrd will choose links with the lowest value.   
        ]]))
    end
  end
  uci.save("olsr")
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
  local user_level = user_level or userlevel
  form = formClass.new(tr("Plugins List"))

  if badplugins ~= nil then
    form:Add("subtitle","Configured with unknow Library")
    for i, v in pairsByKeys(badplugins) do
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
  local forms = {}
  local pl_name = __FORM["plname"]
  local plugin = uci.get_section("olsr",pl_name)
  form = tbformClass.new(pl_name.." "..tr("Configuration of").." "..plugin.Library)
  form:Add_col("label", "PlParam", "PlParam", "220px","string,len>1","width:220px")
  form:Add_col("text", "value", "Value", "220px","string","width:220px")
  form:Add_col("link", "Remove","Remove", "100px","","width:100px")
  for k, v in pairsByKeys(plugin) do
    if  k ~= ".name"
    and k ~= ".type"
    and k ~= "Library" then
      form:New_row()
      form:set_col("PlParam","olsr."..pl_name.."."..k, k)
      form:set_col("value","olsr."..pl_name.."."..k, v)
      form:set_col("Remove", "Remove_"..k, __SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option="..__FORM.option.."&plname="..__FORM["plname"].."&UCI_MSG_delolsr."..pl_name.."."..k.."=")
    end
  end
  duplicate_param = uci.get_type("olsr",pl_name)
  if duplicate_param ~= nil then
    for i=1, #duplicate_param do
      form:New_row()
      for k, v in pairs(duplicate_param[i]) do
        form:set_col("PlParam","olsr."..duplicate_param[i][".name"].."."..k,k)
        form:set_col("value","olsr."..duplicate_param[i][".name"].."."..k,v) 
        form:set_col("Remove", "Remove_"..k, __SERVER.SCRIPT_NAME.."?__menu="..__FORM.__menu.."&option="..__FORM.option.."&plname="..__FORM["plname"].."&UCI_MSG_delolsr."..duplicate_param[i][".name"].."=")
      end
    end
  end
  forms[1] = form
  form = formClass.new(tr("Add new parameter"))
  form:Add("text_line","add_parameter",[[<table width="500px">
  <tr><td width="180px"><strong>]]..tr("Parameter name")..[[</strong></td><td width="220px" ><strong>]]..tr("Parameter Value")..[[</strong></td></tr>
  <tr><td ><input type="text" name="Parameter_name" style="width:180px;"/></td>
  <td><input type="text" name="Parameter_value" style="width:220px;" /></td>
  <td width="100px"><input type="submit" name="Add_Plagin" value="]]..tr("Add new")..[[" style="width:100px;" ></td></tr>
  </table>]])
  forms[2] = form
  return forms
end

return olsrd
