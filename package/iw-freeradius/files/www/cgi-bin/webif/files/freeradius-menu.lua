freeradius = uciClass.new("freeradius")
if freeradius.websettings ~= nil then
  if freeradius.webadmin.mode == "0" then 
  -- Muestra menu principiante
  __MENU.IW.Freeradius = menuClass.new()
  __MENU.IW.Freeradius:Add("Core","freeradius.sh")
--  __MENU.IW.Freeradius.Core = menuClass.new()
  __MENU.IW.Freeradius:Add("Users","freeradius-users.sh")
  __MENU.IW.Freeradius:Add("Proxy","freeradius-proxy.sh")
  __MENU.IW.Freeradius:Add("Clients","freeradius-clients.sh")
--  __MENU.IW.Freeradius:Add("To conf","freeradius-conf.sh")
  elseif freeradius.webadmin.mode == "3" then
  -- Menu de Experto edita los archivos directamente
    __FORM.__menu = string.sub(__FORM.__menu,1,4)
  end
else
  -- Todavía no configuró como quiere manejar la configuracion
end

--__MENU.IW.Freeradius.Core:Add("Files","freeradius.sh?option=files_settings")
--__MENU.IW.Freeradius.Core:Add("Listen","freeradius.sh?option=listen_settings")
--__MENU.IW.Freeradius.Core:Add("Requests","freeradius.sh?option=requests")
--__MENU.IW.Freeradius.Core:Add("Miselaneous","freeradius.sh?option=miselaneous")
--__MENU.IW.Freeradius.Core:Add("Security","freeradius.sh?option=security")
--__MENU.IW.Freeradius.Core:Add("Clients","freeradius-clients.sh")
--__MENU.IW.Freeradius.Core:Add("Thread Pool","freeradius.sh?option=thread")
--__MENU.IW.Freeradius.Core:Add("Instantiation","freeradius.sh?option=instantiate")
--__MENU.IW.Freeradius.Core:Add("Authorization","freeradius.sh?option=portal")
--__MENU.IW.Freeradius.Core:Add("Authentication","freeradius.sh?option=authentication")

--if freeradius.settings.proxy_request == "yes" then
--__MENU.IW.Freeradius:Add("PROXY","freeradius.sh?option=radius")
--end
--if freeradius.settings.snmp == "yes" then
--__MENU.IW.Freeradius:Add("SNMP","freeradius.sh?option=radius")
--end

--__MENU.IW.Freeradius:Add("Modules")
--__MENU.IW.Freeradius.Modules = menuClass.new()
--__MENU.IW.Freeradius.Modules:Add("Selection","freeradius-modules.sh")

--__MENU.IW.Freeradius:Add("Pre-accounting","freeradius.sh?option=proxy")
--__MENU.IW.Freeradius:Add("Accounting","freeradius.sh?option=scripts")
--__MENU.IW.Freeradius:Add("Session database","freeradius.sh?option=scripts")
--__MENU.IW.Freeradius:Add("Post-Authentication","freeradius.sh?option=scripts")
--__MENU.IW.Freeradius:Add("pre-proxy","freeradius.sh?option=scripts")
--__MENU.IW.Freeradius:Add("post-proxy","freeradius.sh?option=scripts")
--__MENU.IW.Freeradius:Add("Users","freeradius.sh?option=scripts")
