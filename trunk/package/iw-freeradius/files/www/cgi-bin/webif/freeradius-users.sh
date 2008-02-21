#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("files/freeradius-menu")
freeradius_check = uciClass.new("freeradius-check")
freeradius_reply = uciClass.new("freeradius-reply")
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

--print(type(default_check),"<br>")
----print(check_cfg,"<br>")
--for i,v in pairs(freeradius_check) do
--  print (i,v,"<br>")
--  if type(v) == "table" then
--  for k, val in pairs(v) do
--    print ("&nbsp;",k,val,"<br>")
--    if type(val) == "table" then 
--      for j, l in pairs(val) do
--        print("&nbsp;&nbsp;",j,l,"<br>")
--      end
--    end
--  end
--  end
--end
----print("<br>"..freeradius_check[1].name..":",default_check.Simultaneous_Use,"<br>")
--print("<br><br>")

--for i,v in pairs(defaul_check) do
--  print (i,v,"<br>")
--end



users = freeradius_check.sections
--for i,v in pairs(users) do
--  print (i,v,"<br>")
--  for k, val in pairs(v) do
--    print (k,val,"<br>")
--  end
--end

local formdef = formClass.new("Default Settings")
formdef:Add("subtitle","Check Settings")
formdef:Add("text",check_cfg..".Simultaneous_Use",check_val.Simultaneous_Use,tr("freerad_var_simultaneous#Simultaneos Use"),"int")
formdef:Add("subtitle","Reply Settings")
formdef:Add("text",reply_cfg..".Idle_Timeout",reply_val.Idle_Timeout,tr("freerad_var_idle_timeout#Idle Timeout"),"int")
formdef:Add("text",reply_cfg..".Acct_Interim_Interval",reply_val.Acct_Interim_Interval,tr("freerad_var_Acct_Interim_Interval#Account Interim Interval"),"int")
formdef:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Down",reply_val.WISPr_Bandwidth_Max_Down,tr("freerad_var_maxdown#Max Bandwidth Down"),"int")
formdef:Add("text",reply_cfg..".WISPr_Bandwidth_Max_Up",reply_val.WISPr_Bandwidth_Max_Up,tr("freerad_var_maxup#Max Bandwidth Up"),"int")
formdef:Add("link","add_user",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius-check=user&UCI_CMD_setfreeradius-reply=user&__menu="..__FORM.__menu,tr("Add Client"))
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
local form = {}
for i=1, #users do
  local name = users[i].name
  if name ~= "default" then
    local checks = freeradius_check[name]
    local replys = freeradius_reply[name]
    form[i] = formClass.new(name.." Settings")
    form[i]:Add("text","freeradius-check."..users[i].name..".Username",freeradius_check[name].Username,"Username","string")
    form[i]:Add("subtitle","Check Settings")
--    for k,v in pairs(checks) do
--      form[i]:Add("text","freeradius-check."..users[i].name.."."..k,v,k,"string")
--    end
    form[i]:Add("text","freeradius-check."..users[i].name..".User_Password",freeradius_check[name].User_Password,"Password","string")
    form[i]:Add("text","freeradius-check."..users[i].name..".Simultaneous_Use",freeradius_check[name].Simultaneous_Use,"Simultaneous Use","int")
    form[i]:Add("text","freeradius-check."..users[i].name..".Expiration",freeradius_check[name].Expiration,"Expiration","string")
    form[i]:Add("subtitle","Reply Settings")
--    for k,v in pairs(replys) do
--      form[i]:Add("text","freeradius-reply."..users[i].name.."."..k,v,k,"string","width:99%")
--    end
    form[i]:Add("select","freeradius-reply."..users[i].name..".Fall_Through",freeradius_reply[name].Fall_Through,"Fall Through")
    form[i]["freeradius-reply."..users[i].name..".Fall_Through"].options:Add("no","No")  
    form[i]["freeradius-reply."..users[i].name..".Fall_Through"].options:Add("yes","Yes")  
    form[i]:Add("text","freeradius-reply."..users[i].name..".Idle_Timeout",freeradius_reply[name].Idle_Timeout,"Idle Timeout","int")
    form[i]:Add("text","freeradius-reply."..users[i].name..".Acct_Interim_Interval",freeradius_reply[name].Acct_Interim_Interval,"Account Interim Interval","int")
    form[i]:Add("text","freeradius-reply."..users[i].name..".WISPr_Bandwidth_Max_Down",freeradius_reply[name].WISPr_Bandwidth_Max_Down,"Max Bandwith Down","int")
    form[i]:Add("text","freeradius-reply."..users[i].name..".WISPr_Bandwidth_Max_Up",freeradius_reply[name].WISPr_Bandwidth_Max_Up,"Max Bandwith Up","int")
    form[i]:Add("link","remove_freeradius-reply"..users[i].name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_delfreeradius-reply."..users[i].name.."=&".."UCI_CMD_delfreeradius-check."..users[i].name.."=&__menu="..__FORM.__menu,tr("Remove User"))
    form[i]:print()
  end
end 

        
--form:print()
print(page:footer())
