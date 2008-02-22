#!/usr/bin/lua
--
--##WEBIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local chillispot_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)

require("files/freeradius-menu")
page.title = "Freeradius Settings"
print(page:header())
__FORM.option = string.trim(__FORM.option)
----	Input Section formservice
  if freeradius.websettings == nil then websettings = freeradius:set("websettings","webadmin") 
  else websettings = freeradius.websettings end
  websettings_values = websettings[1].values
	form = formClass.new("Service Settings")
	form:Add("select",websettings[1].name..".enable",websettings_values.enable,"Service","string")
	form[websettings[1].name..".enable"].options:Add("0","Disable")
	form[websettings[1].name..".enable"].options:Add("1","Enable")
	form:Add("select",websettings[1].name..".mode",websettings_values.mode,"Configuration Mode","string")
	form[websettings[1].name..".mode"].options:Add("-1","Select Mode")
	form[websettings[1].name..".mode"].options:Add("0","Beginer")
--	form[websettings[1].name..".mode"].options:Add("1","Medium")
--	form[websettings[1].name..".mode"].options:Add("2","Advanced")
	form[websettings[1].name..".mode"].options:Add("3","Expert")
--  if freeradius.settings == nil then settings = freeradius:set("settings") 
--  else settings = freeradius.settings end
--	form:Add("select","freeradius.settings.proxy_request",freeradius.settings.proxy_request,"Proxy Request","string")
--	form["freeradius.settings.proxy_request"].options:Add("yes",tr("Yes"))
--	form["freeradius.settings.proxy_request"].options:Add("no",tr("No"))
--	form:Add("select","freeradius.settings.snmp",freeradius.settings.snmp,"SNMP","string")
--	form["freeradius.settings.snmp"].options:Add("no",tr("No"))
--	form["freeradius.settings.snmp"].options:Add("yes",tr("Yes"))
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
--	form:Add_help("proxy_requests#Proxy Requests",[[Turns proxying of RADIUS requests on or off.<br>
--      The server has proxying turned on by default.  If your system is NOT
--      set up to proxy requests to another server, then you can turn proxying
--      off here.  This will save a small amount of resources on the server.<br>
--      If you have proxying turned off, and your configuration files say 
--      to proxy a request, then an error message will be logged.<br>
--      To disable proxying, change the "yes" to "no"]])
--	form:Add_help("snmp#SNMP",[[Snmp configuration is only valid if SNMP support was enabled at compile time.<br>
--        To enable SNMP querying of the server, set the value of the 'snmp' attribute to 'yes' ]])
--	form:Add_help("mysql#MySQL","The maximum number of requests which the server keeps track of. This should be 256 multiplied by the number of clients. e.g. With 4 clients, this number should be 1024.")
if #__ERROR > 0 then 
	form.__help = {}
	for i,error in ipairs(__ERROR) do
		form:Add_help(error["var_name"],error["msg"])
	end
end
form:Add_help_link("http://www.freeradius.org","More information")
form:print()

if form1 then form1:print() end
if form2 then form2:print() end
print (page:footer())
