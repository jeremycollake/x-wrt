#!/usr/bin/lua
--[[
##WEBNOIF:name:IW:250:Freeradius
]]--
dofile("/usr/lib/webif/LUA/config.lua")
local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("files/freeradius-menu")
__WIP = 2
require("tbform")
freeradius_check = uciClass.new("freeradius_check")
freeradius_reply = uciClass.new("freeradius_reply")
page.title = tr("Freeradius Users")
print(page:header())
--if freeradius_check.user == nil then freeradius_check:set("user") end 
--if freeradius_reply.user == nil then freeradius_reply:set("user") end 

if freeradius_check.default == nil then default_check = freeradius_check:set("default","default") 
else default_check = freeradius_check.default end 
check_cfg = default_check[1].name
check_val = default_check[1].values

if freeradius_reply.default == nil then default_reply = freeradius_reply:set("default","default") 
else default_reply = freeradius_reply.default end 
reply_cfg = default_reply[1].name
reply_val = default_reply[1].values

local formdef = formClass.new("Default Settings")
formdef:Add("subtitle","Check Settings")
formdef:Add("text",check_cfg..".Simultaneous_Use",check_val.Simultaneous_Use,tr("freerad_var_simultaneous#Simultaneos Use"),"int")
formdef:Add("subtitle","Reply Settings")
formdef:Add("text",reply_cfg..".Idle_Timeout",reply_val.Idle_Timeout,tr("freerad_var_idle_timeout#Idle Timeout"),"int")
formdef:Add("text",reply_cfg..".Acct_Interim_Interval",reply_val.Acct_Interim_Interval,tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),"int")
formdef:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Down",reply_val.WISPr_Bandwidth_Max_Down,tr("freerad_var_maxdown#Max Bandwidth Down"),"int")
formdef:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Up",reply_val.WISPr_Bandwidth_Max_Up,tr("freerad_var_maxup#Max Bandwidth Up"),"int")

formdef:Add("uci_set_config","freeradius_check,freeradius_reply","user",tr("freerad_add_user#New User"),"string")

formdef:Add_help(tr("freerad_var_simultaneous#Simultaneos Use"),tr([[freerad_help_simultaneous#Set max simultaneous connection for account.]]))
formdef:Add_help(tr("freerad_var_idle_timeout#Idle Timeout"),tr([[freerad_help_idle_timeout#Specifies the maximum length of time, in seconds, that a subscriber session can remain idle before it is disconnected.]]))
formdef:Add_help(tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),tr([[freerad_help_Acct_Interim_Interval#
        This attribute indicates the number of seconds between each interim
        update in seconds for this specific session.
      ]]))
formdef:Add_help(tr("freerad_var_bandwith#Max Bandwidth Up/Down"),tr([[freerad_help_bandwidth#
        Set Max up/down stream bandwidth.
      ]]))
formdef:print()

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

users = freeradius_check.sections
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

    form:set_col("Username","freeradius_check."..name..".Username",name)
    form:set_col("Password","freeradius_check."..name..".User_Password",password)
    form:set_col("Expiration","freeradius_check."..name..".Expiration",expiration)
    form:set_col("FallThrough", "freeradius_reply."..name..".Fall_Through", fall)
    form:set_col("Simultaneous", "freeradius_check."..name..".Simultaneous_Use", simul)
    form:set_col("IdleTimeout", "freeradius_reply."..name..".Idle_Timeout", itimeout)
    form:set_col("AcctInterimInt", "freeradius_reply."..name..".Acct_Interim_Interval", acctii)
    form:set_col("MaxDown", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Down", maxdown)
    form:set_col("MaxUp", "freeradius_reply."..name..".WISPr_Bandwidth_Max_Down", maxup)
    form:set_col("Remove", "Remove_"..name, __SERVER.SCRIPT_NAME.."?".."UCI_CMD_delfreeradius_check."..name.."=&UCI_CMD_delfreeradius_reply."..name.."=&__menu="..__FORM.__menu)
  end
end
form:print()
print(page:footer())
