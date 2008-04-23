--[[
    Availables functions
    check_pkg
    core_form
    community_form

]]--
require("tbform")
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

local radconf = uciClass.new("freeradius")
local userlevel = tonumber(radconf.webadmin.userlevel) or 0

function set_menu()
--    if userlevel < 4 then 
    -- Muestra menu principiante
    __MENU.IW.Freeradius = menuClass.new()
    __MENU.IW.Freeradius:Add("Core","freeradius.sh")
    __MENU.IW.Freeradius:Add("Users")
    __MENU.IW.Freeradius.Users = menuClass.new()
    __MENU.IW.Freeradius.Users:Add("Users","freeradius.sh?option=users")
    __MENU.IW.Freeradius.Users:Add("Default Values","freeradius.sh?option=users_default")
    __MENU.IW.Freeradius:Add("Communities")
    __MENU.IW.Freeradius.Communities = menuClass.new()
    __MENU.IW.Freeradius.Communities:Add("Communities","freeradius.sh?option=communities")
    __MENU.IW.Freeradius.Communities:Add("Proxy Server","freeradius.sh?option=proxy")
    __MENU.IW.Freeradius:Add("Clients","freeradius.sh?option=client")
--    elseif userlevel == 4 then
    -- Menu de Experto edita los archivos directamente
--      __FORM.__menu = string.sub(__FORM.__menu,1,4)
--    end
end

function check_pkg()
  local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
end

function core_form()
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
	form[websettings[1].name..".userlevel"].options:Add("4","Expert")
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

function client_form()
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

function proxy_settings_form()
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

function community_form()
  local freeradius = uciClass.new("freeradius_proxy")
  if freeradius.server == nil then server = freeradius:set("server") else server = freeradius.server end
  local server_cfg = server[1].name
  local server_val = server[1].values
  form = formClass.new("Comunities Radius")
--  form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_proxy=realm&__menu="..__FORM.__menu.."&option=wizard&step=radius",tr("Add Community"))
  form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_proxy=realm&__menu="..__FORM.__menu.."&option=proxy",tr("Add Community"))
  if freeradius.realm ~= nil then
    for i = 1, #freeradius.realm do
      realm_cfg = freeradius.realm[i].name
      realm_val = freeradius.realm[i].values
      local name = realm_val.community
      if name == nil then name = "New Community" end
      form:Add("subtitle","&nbsp;"..name)
      form:Add("text",realm_cfg..".community", realm_val.community,"Community","string","width:99%")

      form:Add("select",realm_cfg..".type",realm_val.type,"Type","string")
      form[realm_cfg..".type"].options:Add("radius",tr("Radius"))

      form:Add("text",realm_cfg..".authhost", realm_val.authhost,"authhost","string","width:99%")
      form:Add("text",realm_cfg..".accthost", realm_val.accthost,"accthost","string","width:99%")
      form:Add("text",realm_cfg..".secret", realm_val.secret,"secret","string","width:99%")
      form:Add("checkbox",realm_cfg..".nostrip", realm_val.nostrip,"No Strip","string","width:99%")
      form:Add("select",realm_cfg..".ldflag",realm_val.ldflag,"ldflag","string")
      form[realm_cfg..".ldflag"].options:Add("",tr("&nbsp;"))
      form[realm_cfg..".ldflag"].options:Add("fail_over",tr("Fail over"))
      form[realm_cfg..".ldflag"].options:Add("round_robin",tr("Round robin"))
      form:Add("link","remove"..realm_cfg,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..realm_cfg.."=&__menu="..__FORM.__menu.."&option=proxy",tr("Remove Community"))
    end
  end
  return form
end

function defaul_user_form()
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

function user_form()
  local freeradius_check = uciClass.new("freeradius_check")
  local freeradius_reply = uciClass.new("freeradius_reply")
  local users = freeradius_check.sections
  form = tbformClass.new("Local Users")
  form:Add_col("label", "Username","Username", "120px")
  form:Add_col("text", "Password", "Password", "120px","string,len>5","width:120px")
  form:Add_col("text", "Expiration", "Expiration", "120px","string","width:120px")
  form:Add_col("select", "FallThrough", "Fall Through", "100px","string","width:100px")
    form.col[form.col.FallThrough].options:Add("yes","Yes")
    form.col[form.col.FallThrough].options:Add("no","No")
  form:Add_col("text", "Simultaneous", "Simultaneous", "80px","int","width:80px")
  form:Add_col("text", "IdleTimeout", "Idle Timeout", "80px","int","width:80px")
  form:Add_col("text", "AcctInterimInt", "Acct Interim Interval", "90px","int","width:90px")
  form:Add_col("text", "MaxDown", "MaxDown", "100px","int","width:100px")
  form:Add_col("text", "MaxUp", "MaxUp", "100px","int","width:100px")
  form:Add_col("link", "Remove","Remove ", "100px","","width:100px")
  for i=1, #users do
    local name = users[i].name
    if name ~= "default" then
      local checks = freeradius_check[name]
      local replys = freeradius_reply[name]

      password = checks.User_Password or ""
      expiration = checks.Expiration or ""
      fall = replys.Fall_Through or ""
      simul = checks.Simultaneous_Use or ""
      itimeout = replys.Idle_Timeout or ""
      acctii = replys.Acct_Interim_Interval or ""
      maxdown = replys.WISPr_Bandwidth_Max_Down or ""
      maxup = replys.WISPr_Bandwidth_Max_Up or ""
      form:New_row()

      form:set_col("Username","freeradius_check."..name..".Username", name)
      form:set_col("Password","freeradius_check."..name..".User_Password", password)
      form:set_col("Expiration","freeradius_check."..name..".Expiration", expiration)
      form:set_col("FallThrough", "freeradius_reply."..name..".Fall_Through", fall)
      form:set_col("Simultaneous", "freeradius_check."..name..".Simultaneous_Use", simul)
      form:set_col("IdleTimeout", "freeradius_reply."..name..".Idle_Timeout", itimeout)
      form:set_col("AcctInterimInt", "freeradius_reply."..name..".Acct_Interim_Interval", acctii)
      form:set_col("MaxDown", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Down", maxdown)
      form:set_col("MaxUp", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Up", maxup)
      form:set_col("Remove", "Remove_"..name, __SERVER.SCRIPT_NAME.."?".."UCI_CMD_delfreeradius_check."..name.."=&UCI_CMD_delfreeradius_reply."..name.."=&__menu="..__FORM.__menu)
    end
  end
  return form
end

function add_usr_form(form,user_level)
  if form == nil then
    form = formClass.new("Local Users")
  else
    form:Add("subtitle","Local Users")
  end
  
  form:Add("uci_set_config","freeradius_check,freeradius_reply","user",tr("freerad_add_user#New User"),"string")
  return form
end
