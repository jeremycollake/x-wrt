--[[
    Availables functions
    check_pkg
    core_form
    community_form

]]--
require("tbform")
require("uci_iwaddon")
radius = {}
local P = {}
radius = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local assert = assert
local string = string
local tonumber = tonumber
local tostring = tostring
local type = type
local uci = uci
local print = print
local pairs = pairs

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

uci.check_set("freeradius","system","freeradius")
uci.check_set("freeradius","system","apply","/usr/lib/lua/lua-xwrt/applys/freeradius.lua")
uci.check_set("freeradius_check","system","freeradius")
uci.check_set("freeradius_check","system","apply","/usr/lib/lua/lua-xwrt/applys/freeradius_check.lua")
uci.check_set("freeradius_reply","system","freeradius")
uci.check_set("freeradius_reply","system","apply","/usr/lib/lua/lua-xwrt/applys/freeradius_reply.lua")
uci.check_set("freeradius_clients","system","freeradius")
uci.check_set("freeradius_proxy","system","apply","/usr/lib/lua/lua-xwrt/applys/freeradius_proxy.lua")
uci.check_set("freeradius_proxy","system","freeradius")
uci.check_set("freeradius_proxy","system","apply","/usr/lib/lua/lua-xwrt/applys/freeradius_proxy.lua")

local radconf = uciClass.new("freeradius")
local userlevel = tonumber(radconf.webadmin.userlevel) or 0
if __FORM["Add_Proxy"] then 
	uci.add("freeradius_proxy","realm") 
	uci.save("freeradius_proxy")
end

if __FORM["Remove_Proxy"] then 
	uci.delete("freeradius_proxy",__FORM["Remove_Proxy"]) 
	uci.save("freeradius_proxy")
end

function set_menu()
--    if userlevel < 4 then 
    -- Muestra menu principiante
    __MENU.HotSpot.Freeradius = menuClass.new()
    __MENU.HotSpot.Freeradius:Add("Core","freeradius.sh")
    __MENU.HotSpot.Freeradius:Add("Users")
    __MENU.HotSpot.Freeradius.Users = menuClass.new()
    __MENU.HotSpot.Freeradius.Users:Add("Users","freeradius.sh?option=users")
    __MENU.HotSpot.Freeradius.Users:Add("Default Values","freeradius.sh?option=users_default")
    __MENU.HotSpot.Freeradius:Add("Communities")
    __MENU.HotSpot.Freeradius.Communities = menuClass.new()
    __MENU.HotSpot.Freeradius.Communities:Add("Communities","freeradius.sh?option=communities")
    __MENU.HotSpot.Freeradius.Communities:Add("Proxy Server","freeradius.sh?option=proxy")
    __MENU.HotSpot.Freeradius:Add("Clients","freeradius.sh?option=client")
--    elseif userlevel == 4 then
    -- Menu de Experto edita los archivos directamente
--      __FORM.__menu = string.sub(__FORM.__menu,1,4)
--    end
end

function check_pkg()
  local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
end

function core_form1()
----	Input Section formservice
	local form = formClass.new("Service Settings")
  local websettings
  if radconf.websettings == nil then websettings = radconf:set("websettings","webadmin") 
  else websettings = radconf.websettings end
  websettings_values = websettings[1].values

	form:Add("select",websettings[1].name..".enable",websettings_values.enable,"Service","string")
	form[websettings[1].name..".enable"].options:Add("0","Disable")
	form[websettings[1].name..".enable"].options:Add("1","Enable")
	form:Add("select",websettings[1].name..".userlevel",websettings_values.userlevel,"Configuration Mode","string")
	form[websettings[1].name..".userlevel"].options:Add("0","Select Mode")
	form[websettings[1].name..".userlevel"].options:Add("1","Beginer")
--	form[websettings[1].name..".userlevel"].options:Add("2","Medium")
--	form[websettings[1].name..".userlevel"].options:Add("3","Advanced")
--	form[websettings[1].name..".userlevel"].options:Add("4","Expert")
----	Help section	
	form:Add_help(tr("freeradius_var_service#Service"),tr("freeradius_help_service#Turns freeradius server enable or disable"))
	form:Add_help(tr("freeradius_var_mode#Configuration Mode"),tr("freeradius_help_mode#"..[[
          Select mode of configuration page.<br>
          Freeradius have many configurations param and they depend of modules 
          you install. So if want give access to your own users, maybe the users
          of other radis server and or control the access of some Hotspot, use
          the basic configuration mode in other case you need know about freeradius
          configuration and edit the files that you need change.<br><br>
          <strong>Beginer :</strong><br>
          This basic mode write the propers configuration files to create, modify and delete,
          Users, Clients and Proxy to other radius.
          <br><br>
          <strong>Expert :</strong><br>
          This mode keep your configurations file and you edit they by your self.
          
          ]]))
  form:Add_help_link("http://www.freeradius.org","More information")
  return form
end

function core_form()
----	Input Section formservice
	local form = formClass.new("Service Settings")
	uci.check_set("freeradius","webadmin","websettings")
	form:Add("select","freeradius.webadmin.enable",uci.check_set("freeradius","webadmin","enable","1"),"Service","string")
	form["freeradius.webadmin.enable"].options:Add("0","Disable")
	form["freeradius.webadmin.enable"].options:Add("1","Enable")
	form:Add("select","freeradius.webadmin.userlevel",uci.check_set("freeradius","webadmin","userlevel","1"),"Configuration Mode","string")
	form["freeradius.webadmin.userlevel"].options:Add("0","Select Mode")
	form["freeradius.webadmin.userlevel"].options:Add("1","Beginer")
--	form[websettings[1].name..".userlevel"].options:Add("2","Medium")
--	form[websettings[1].name..".userlevel"].options:Add("3","Advanced")
--	form[websettings[1].name..".userlevel"].options:Add("4","Expert")
----	Help section	
	form:Add_help(tr("freeradius_var_service#Service"),tr("freeradius_help_service#Turns freeradius server enable or disable"))
	form:Add_help(tr("freeradius_var_mode#Configuration Mode"),tr("freeradius_help_mode#"..[[
          Select mode of configuration page.<br>
          Freeradius have many configurations param and they depend of modules 
          you install. So if want give access to your own users, maybe the users
          of other radis server and or control the access of some Hotspot, use
          the basic configuration mode in other case you need know about freeradius
          configuration and edit the files that you need change.<br><br>
          <strong>Beginer :</strong><br>
          This basic mode write the propers configuration files to create, modify and delete,
          Users, Clients and Proxy to other radius.
          <br><br>
          <strong>Expert :</strong><br>
          This mode keep your configurations file and you edit they by your self.
          
          ]]))
  form:Add_help_link("http://www.freeradius.org","More information")
  uci.save("freeradius")
  return form
end

function client_form1()
  local freeradius = uciClass.new("freeradius_clients")
  local client
  if freeradius.client == nil then client = freeradius:set("client") else client = freeradius.client end

  local form = formClass.new("Client Settings")
  for i=1,#client do
    if i > 1 then form:Add("subtitle","Client") end
    form:Add("text",client[i].name..".client",client[i].values.client,"Client","string","width:99%")
    form:Add("text",client[i].name..".shortname",client[i].values.shortname,"Short Name","string","width:99%")
    form:Add("text",client[i].name..".secret",client[i].values.secret,"Secret","string","width:99%")
    form:Add("select",client[i].name..".nastype",client[i].values.nastype,"NAS Type","string")
    form[client[i].name..".nastype"].options:Add("cisco","Cisco")  
    form[client[i].name..".nastype"].options:Add("chillispot","Chillispot")  
    form[client[i].name..".nastype"].options:Add("computone","Computone")  
    form[client[i].name..".nastype"].options:Add("livingston","Livingston")  
    form[client[i].name..".nastype"].options:Add("max40xx","Max40xx")  
    form[client[i].name..".nastype"].options:Add("multitech","Multitech")  
    form[client[i].name..".nastype"].options:Add("netserver","NetServer")  
    form[client[i].name..".nastype"].options:Add("pathras","PathRAS")  
    form[client[i].name..".nastype"].options:Add("patton","Patton")  
    form[client[i].name..".nastype"].options:Add("portslave","PortSlave")  
    form[client[i].name..".nastype"].options:Add("tc","TC")  
    form[client[i].name..".nastype"].options:Add("usrhiper","USRHiper")  
    form[client[i].name..".nastype"].options:Add("other","Other")  
    form:Add("text",client[i].name..".login",client[i].values.login,"Login","string")
    form:Add("text",client[i].name..".password",client[i].values.password,"Password")
    form:Add("link","remove_"..client[i].name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..client[i].name.."= &__menu="..__FORM.__menu.."&option=client",tr("Remove Client"))
  end
  form:Add("link","add_client",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_clients=client&__menu="..__FORM.__menu.."&option=client",tr("Add Client"))
  form:Add_help("client",[[
      Defines a RADIUS client.  The format is 'client [hostname|ip-address]'<br>
      '127.0.0.1' is another name for 'localhost'.  It is enabled by default,
      to allow testing of the server after an initial installation.  If you
      are not going to be permitting RADIUS queries from localhost, we suggest
      that you delete this entry.
      ]])
  form:Add_help(tr("shortname"),[[
      The "shortname" is be used for logging.  The "nastype", "login" and
      "password" fields are mainly used for checkrad and are optional.
        ]])

  form:Add_help(tr("Login / Password"),[[
      This two configurations are for future use.
      The 'naspasswd' file is currently used to store the NAS
      login name and password, which is used by checkrad.pl
      when querying the NAS for simultaneous use.
      ]])
  return form        
end

function client_form()
  local freeradius = uci.get_all("freeradius_clients")
  local form = formClass.new("Client Settings")
  local i = 0
	for name , t in pairs(freeradius) do
    if i > 0 then form:Add("subtitle","Client") end
    form:Add("text","freeradius_clients."..name..".client",uci.get("freeradius_clients",name,"client"),"Client","string","width:99%")
    form:Add("text","freeradius_clients."..name..".shortname",uci.get("freeradius_clients",name,"shortname"),"Short Name","string","width:99%")
    form:Add("text","freeradius_clients."..name..".secret",uci.get("freeradius_clients",name,"secret"),"Secret","string","width:99%")
    form:Add("select","freeradius_clients."..name..".nastype",uci.get("freeradius_clients",name,"nastype"),"NAS Type","string")
    form["freeradius_clients."..name..".nastype"].options:Add("cisco","Cisco")  
    form["freeradius_clients."..name..".nastype"].options:Add("chillispot","Chillispot")  
    form["freeradius_clients."..name..".nastype"].options:Add("computone","Computone")  
    form["freeradius_clients."..name..".nastype"].options:Add("livingston","Livingston")  
    form["freeradius_clients."..name..".nastype"].options:Add("max40xx","Max40xx")  
    form["freeradius_clients."..name..".nastype"].options:Add("multitech","Multitech")  
    form["freeradius_clients."..name..".nastype"].options:Add("netserver","NetServer")  
    form["freeradius_clients."..name..".nastype"].options:Add("pathras","PathRAS")  
    form["freeradius_clients."..name..".nastype"].options:Add("patton","Patton")  
    form["freeradius_clients."..name..".nastype"].options:Add("portslave","PortSlave")  
    form["freeradius_clients."..name..".nastype"].options:Add("tc","TC")  
    form["freeradius_clients."..name..".nastype"].options:Add("usrhiper","USRHiper")  
    form["freeradius_clients."..name..".nastype"].options:Add("other","Other")  
    form:Add("text","freeradius_clients."..name..".login",uci.get("freeradius_clients",name,"login"),"Login","string")
    form:Add("text","freeradius_clients."..name..".password",uci.get("freeradius_clients",name,"password"),"Password","string")
    form:Add("link","remove_".."freeradius_clients."..name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del".."freeradius_clients."..name.."= &__menu="..__FORM.__menu.."&option=client",tr("Remove Client"))
    i = 1
  end
  form:Add("link","add_client",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_clients=client&__menu="..__FORM.__menu.."&option=client",tr("Add Client"))
  form:Add_help("client",[[
      Defines a RADIUS client.  The format is 'client [hostname|ip-address]'<br>
      '127.0.0.1' is another name for 'localhost'.  It is enabled by default,
      to allow testing of the server after an initial installation.  If you
      are not going to be permitting RADIUS queries from localhost, we suggest
      that you delete this entry.
      ]])
  form:Add_help(tr("shortname"),[[
      The "shortname" is be used for logging.  The "nastype", "login" and
      "password" fields are mainly used for checkrad and are optional.
        ]])

  form:Add_help(tr("Login / Password"),[[
      This two configurations are for future use.
      The 'naspasswd' file is currently used to store the NAS
      login name and password, which is used by checkrad.pl
      when querying the NAS for simultaneous use.
      ]])
  return form        
end

function proxy_settings_form1()
  local freeradius = uciClass.new("freeradius_proxy")
  if freeradius.server == nil then server = freeradius:set("server") else server = freeradius.server end
  local server_cfg = server[1].name
  local server_val = server[1].values
  local form = formClass.new("Proxy Settings")
  form:Add("select",server_cfg..".synchronous",server_val.synchronous,"Synchronous","string")
  form[server_cfg..".synchronous"].options:Add("no",tr("No"))
  form[server_cfg..".synchronous"].options:Add("yes",tr("Yes"))
  form:Add("text",server_cfg..".retry_delay",server_val.retry_delay,"Retry Delay","int")
  form:Add("text",server_cfg..".retry_count",server_val.retry_count,"Retry Count" ,"int")
  form:Add("text",server_cfg..".dead_time",server_val.dead_time,"Dead Time" ,"int")
  form:Add("select",server_cfg..".default_fallback",server_val.default_fallback,"Default Fallback","string")
  form[server_cfg..".default_fallback"].options:Add("yes",tr("Yes"))
  form[server_cfg..".default_fallback"].options:Add("no",tr("No"))
  form:Add("select",server_cfg..".post_proxy_authorize",server_val.post_proxy_authorize,"Post proxy authorize","string")
  form[server_cfg..".post_proxy_authorize"].options:Add("no",tr("No"))
  form[server_cfg..".post_proxy_authorize"].options:Add("yes",tr("Yes"))
--  form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_proxy=realm&__menu="..__FORM.__menu,tr("Add Community"))
  return form
end

function proxy_settings_form()
  local freeradius = uci.get_type("freeradius_proxy","server")
  local server = ""
	if freeradius == nil then 
		server = uci.add("freeradius_proxy","server")
	else
		server = freeradius[1][".name"]
	end
  local form = formClass.new("Proxy Settings")
  form:Add("select","freeradius_proxy."..server..".synchronous",uci.check_set("freeradius_proxy",server,"synchronous","no"),"Synchronous","string")
  form["freeradius_proxy."..server..".synchronous"].options:Add("no",tr("No"))
  form["freeradius_proxy."..server..".synchronous"].options:Add("yes",tr("Yes"))
  
  form:Add("text","freeradius_proxy."..server..".retry_delay",uci.check_set("freeradius_proxy",server,"retry_delay","5"),"Retry Delay","int")
  
	form:Add("text","freeradius_proxy."..server..".retry_count",uci.check_set("freeradius_proxy",server,"retry_count","3"),"Retry Count" ,"int")
  
	form:Add("text","freeradius_proxy."..server..".dead_time",uci.check_set("freeradius_proxy",server,"dead_time","121"),"Dead Time" ,"int")
  
	form:Add("select","freeradius_proxy."..server..".default_fallback",uci.check_set("freeradius_proxy",server,"default_fallback","yes"),"Default Fallback","string")
  form["freeradius_proxy."..server..".default_fallback"].options:Add("yes",tr("Yes"))
  form["freeradius_proxy."..server..".default_fallback"].options:Add("no",tr("No"))
  
	form:Add("select","freeradius_proxy."..server..".post_proxy_authorize",uci.check_set("freeradius_proxy",server,"post_proxy_authorize","no"),"Post proxy authorize","string")
  form["freeradius_proxy."..server..".post_proxy_authorize"].options:Add("no",tr("No"))
  form["freeradius_proxy."..server..".post_proxy_authorize"].options:Add("yes",tr("Yes"))
  return form
end

function community_form()
	local proxy = uci.get_type("freeradius_proxy","realm")
  form = formClass.new("Comunities Radius")
  form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."Add_Proxy=realm&__menu="..__FORM.__menu.."&option=communities",tr("Add Community"))
	if proxy then
    for i = 1, #proxy do
      local name = proxy[i].community
      local cfg_name = "freeradius_proxy."..proxy[i][".name"]
      if name == nil then name = "New Community" end
      form:Add("subtitle","&nbsp;"..name)
      form:Add("text",cfg_name..".community", proxy[i].community, tr("Community name"), "string", "width:99%")

      form:Add("select",cfg_name..".type",proxy[i].type,"Type","string")
      form[cfg_name..".type"].options:Add("radius",tr("Radius"))

      form:Add("text",cfg_name..".authhost", proxy[i].authhost,"authhost","string","width:99%")
      form:Add("text",cfg_name..".accthost", proxy[i].accthost,"accthost","string","width:99%")
      form:Add("text",cfg_name..".secret", proxy[i].secret,"secret","string","width:99%")
      form:Add("checkbox",cfg_name..".nostrip", proxy[i].nostrip,"No Strip","string","width:99%")
      form:Add("select",cfg_name..".ldflag", proxy[i].ldflag,"ldflag","string")
      form[cfg_name..".ldflag"].options:Add("",tr("&nbsp;"))
      form[cfg_name..".ldflag"].options:Add("fail_over",tr("Fail over"))
      form[cfg_name..".ldflag"].options:Add("round_robin",tr("Round robin"))
--      form:Add("link","remove"..realm_cfg,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..realm_cfg.."=&__menu="..__FORM.__menu.."&option=communities",tr("Remove Community"))
      form:Add("link","remove"..proxy[i][".name"],__SERVER.SCRIPT_NAME.."?".."Remove_Proxy="..proxy[i][".name"].."&__menu="..__FORM.__menu.."&option=communities",tr("Remove Community"))
    end
  end
  return form
end

function defaul_user_form1()
  local freeradius_check = uciClass.new("freeradius_check")
  local freeradius_reply = uciClass.new("freeradius_reply")

  local defaul_check
  local check_cfg
  local check_val

  local defaul_reply
  local reply_cfg
  local reply_val

  if freeradius_check.default == nil then default_check = freeradius_check:set("default","default") 
  else default_check = freeradius_check.default end 
  check_cfg = default_check[1].name
  check_val = default_check[1].values

  if freeradius_reply.default == nil then default_reply = freeradius_reply:set("default","default") 
  else default_reply = freeradius_reply.default end 
  reply_cfg = default_reply[1].name
  reply_val = default_reply[1].values

  local form = formClass.new("Default Settings")
  form:Add("subtitle","Check Settings")
  form:Add("text",check_cfg..".Simultaneous_Use",check_val.Simultaneous_Use,tr("freerad_var_simultaneous#Simultaneos Use"),"int")
  form:Add("subtitle","Reply Settings")
  form:Add("text",reply_cfg..".Idle_Timeout",reply_val.Idle_Timeout,tr("freerad_var_idle_timeout#Idle Timeout"),"int")
  form:Add("text",reply_cfg..".Acct_Interim_Interval",reply_val.Acct_Interim_Interval,tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),"int")
  form:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Down",reply_val.WISPr_Bandwidth_Max_Down,tr("freerad_var_maxdown#Max Bandwidth Down"),"int")
  form:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Up",reply_val.WISPr_Bandwidth_Max_Up,tr("freerad_var_maxup#Max Bandwidth Up"),"int")


  form:Add_help(tr("freerad_var_simultaneous#Simultaneos Use"),tr([[freerad_help_simultaneous#Set max simultaneous connection for account.]]))
  form:Add_help(tr("freerad_var_idle_timeout#Idle Timeout"),tr([[freerad_help_idle_timeout#Specifies the maximum length of time, in seconds, that a subscriber session can remain idle before it is disconnected.]]))
  form:Add_help(tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),tr([[freerad_help_Acct_Interim_Interval#
        This attribute indicates the number of seconds between each interim
        update in seconds for this specific session.
      ]]))
  form:Add_help(tr("freerad_var_bandwith#Max Bandwidth Up/Down"),tr([[freerad_help_bandwidth#
        Set Max up/down stream bandwidth.
      ]]))
  return form
end

function defaul_user_form()
  local form = formClass.new("Default Settings")
  form:Add("subtitle","Check Settings")
  form:Add("text","freeradius_check.default.Simultaneous_Use",uci.check_set("freeradius_check","default","Simultaneous_Use","1"),tr("freerad_var_simultaneous#Simultaneos Use"),"int")
  form:Add("subtitle","Reply Settings")
  form:Add("text","freeradius_reply.default.Idle_Timeout",uci.check_set("freeradius_reply","default","Idle_Timeout","700"),tr("freerad_var_idle_timeout#Idle Timeout"),"int")
  form:Add("text","freeradius_reply.default.Acct_Interim_Interval",uci.check_set("freeradius_reply","default","Acct_Interim_Interval","600"),tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),"int")
  form:Add("text","freeradius_reply.default.WISPr_Bandwidth_Max_Down",uci.check_set("freeradius_reply","default","WISPr_Bandwidth_Max_Down","512000"),tr("freerad_var_maxdown#Max Bandwidth Down"),"int")
  form:Add("text","freeradius_reply.default.WISPr_Bandwidth_Max_Up",uci.check_set("freeradius_reply","default","WISPr_Bandwidth_Max_Up","25600"),tr("freerad_var_maxup#Max Bandwidth Up"),"int")

  form:Add_help(tr("freerad_var_simultaneous#Simultaneos Use"),tr([[freerad_help_simultaneous#Set max simultaneous connection for account.]]))
  form:Add_help(tr("freerad_var_idle_timeout#Idle Timeout"),tr([[freerad_help_idle_timeout#Specifies the maximum length of time, in seconds, that a subscriber session can remain idle before it is disconnected.]]))
  form:Add_help(tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),tr([[freerad_help_Acct_Interim_Interval#
        This attribute indicates the number of seconds between each interim
        update in seconds for this specific session.
      ]]))
  form:Add_help(tr("freerad_var_bandwith#Max Bandwidth Up/Down"),tr([[freerad_help_bandwidth#
        Set Max up/down stream bandwidth.
      ]]))
  return form
end

function user_form()

  form = tbformClass.new("Local Users")
  form:Add_col("label", "Username","Username", "120px")
  form:Add_col("text", "Password","Password", "120px","string,len>5","width:120px")
--  form:Add_col("text", "Expiration", "Expiration", "120px","string","width:120px")
  form:Add_col("select", "FallThrough", "Fall Through", "100px","string","width:100px")
  form.col[form.col.FallThrough].options:Add("yes","Yes")
  form.col[form.col.FallThrough].options:Add("no","No")
  form:Add_col("text", "Simultaneous", "Simultaneous", "80px","int","width:80px")
  form:Add_col("text", "IdleTimeout", "Idle Timeout", "80px","int","width:80px")
  form:Add_col("text", "AcctInterimInt", "Interim Int", "90px","int","width:90px")
  form:Add_col("text", "MaxDown", "MaxDown", "100px","int","width:100px")
  form:Add_col("text", "MaxUp", "MaxUp", "100px","int","width:100px")
  form:Add_col("link", "Remove","Remove ", "100px","","width:100px")

	local checks = uci.get_type("freeradius_check","user")
	local replys = uci.get_type("freeradius_reply","user")
	local users = {}
	if checks then
	for i, t in pairs(checks) do
		users[t[".name"]] = t
	end
	end
	if replys then
	for i, t in pairs(replys) do
		users[t[".name"]] = t
	end
	end
	for name, t in pairs(users) do
			local reply = uci.get_section("freeradius_reply",name)
			local check = uci.get_section("freeradius_check",name)
    	local password = check.User_Password or ""
    	local expiration = check.Expiration or ""
    	local fall = reply.Fall_Through or ""
    	local simul = check.Simultaneous_Use or ""
    	local itimeout = reply.Idle_Timeout or ""
    	local acctii = reply.Acct_Interim_Interval or ""
    	local maxdown = reply.WISPr_Bandwidth_Max_Down or ""
    	local maxup = reply.WISPr_Bandwidth_Max_Up or ""
      form:New_row()

      form:set_col("Username","freeradius_check."..name..".Username", name)
      form:set_col("Password","freeradius_check."..name..".User_Password", password)
--      form:set_col("Expiration","freeradius_check."..name..".Expiration", expiration)
      form:set_col("FallThrough", "freeradius_reply."..name..".Fall_Through", fall)
      form:set_col("Simultaneous", "freeradius_check."..name..".Simultaneous_Use", simul)
      form:set_col("IdleTimeout", "freeradius_reply."..name..".Idle_Timeout", itimeout)
      form:set_col("AcctInterimInt", "freeradius_reply."..name..".Acct_Interim_Interval", acctii)
      form:set_col("MaxDown", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Down", maxdown)
      form:set_col("MaxUp", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Up", maxup)
      form:set_col("Remove", "Remove_"..name, __SERVER.SCRIPT_NAME.."?".."UCI_CMD_delfreeradius_check."..name.."=&UCI_CMD_delfreeradius_reply."..name.."=&__menu="..__FORM.__menu.."&option="..__FORM.option)
  end
  return form
end

function add_usr_form(form,user_level)
	local user = string.trim(__FORM.username)
	local pass = string.trim(__FORM.password)
	if user ~= ""
	and pass ~= ""
	then 
		uci.set("freeradius_check",user,"user")
		uci.set("freeradius_reply",user,"user")
		uci.set("freeradius_check",user,"User_Password",pass)
		uci.save("freeradius_check")
		uci.save("freeradius_reply")
	end
  if form == nil then
    form = formClass.new("Add Users")
  else
    form:Add("subtitle","Add Users")
  end
--  form:Add("uci_set_config","freeradius_check,freeradius_reply","user",tr("freerad_add_user#New User"),"string")
  form:Add("text_line","add_user",[[
	<table>
  <tr>
		<td >Username</td>
		<td >Password</td>
		<td >&nbsp;</td>
	</tr>
  <tr>
		<td><input type="text" name="username" /></td>
		<td><input type="text" name="password" /></td>
		<td ><input type="submit" name="Add_User" value="Add User" /></td>
	</tr>
  </table>]])
  return form
end
return radius