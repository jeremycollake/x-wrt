#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("files/freeradius-menu")
freeradius = uciClass.new("freeradius_clients")
if freeradius.client == nil then client = freeradius:set("client") else client = freeradius.client end
page.title = tr("Freeradius Clients")
print(page:header())
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
  form:Add("link","remove_"..client[i].name,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..client[i].name.."= &__menu="..__FORM.__menu,tr("Remove Client"))
end
form:Add("link","add_client",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius_clients=client&__menu="..__FORM.__menu,tr("Add Client"))
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
        
form:print()
print(page:footer())
