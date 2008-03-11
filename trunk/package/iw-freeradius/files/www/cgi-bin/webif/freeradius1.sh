#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local chillispot_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)

require("files/freeradius-menu")
page.title = "Freeradius Settings"
print(page:header())
__FORM.option = string.trim(__FORM.option)
if __FORM.option == "instantiate" then
	form = formClass.new("Instantiation")
	local instantiate
  if freeradius.instantiate == nil then instantiate = freeradius:set("instantiate","server") 
  else pool = freeradius.pool end
----	Input Section form
--	form:Add("text","freeradius.pool.start_servers",pool.start_servers,tr("start_servers#Start Servers"),"int")
----	Help section	
	form:Add_help(tr("Instantiation"),[[
        Allows the execution of external scripts.<br>
        The entire command line (and output) must fit into 253 bytes.<br>
        <br>e.g. Framed-Pool = `%{exec:/bin/echo foo}`<br>
        exec<br><br>
        The expression module doesn't do authorization,
        authentication, or accounting.  It only does dynamic
        translation, of the form:<br><br>
        Session-Timeout = `%{expr:2 + 3}`<br><br>
        So the module needs to be instantiated, but CANNOT be
        listed in any other section.  See 'doc/rlm_expr' for
        more information.<br><br>
        expr<br><br>
        We add the counter module here so that it registers
        the check-name attribute before any module which sets
        it<br>
        daily<br><br>
        Authorization. First preprocess (hints and huntgroups files),
        then realms, and finally look in the "users" file.<br><br>
        The order of the realm modules will determine the order that
        we try to find a matching realm.
        <br><br>
        Make *sure* that 'preprocess' comes before any realm if you
        need to setup hints for the remote radius server
        ]])
	
elseif __FORM.option == "thread" then
	form = formClass.new("Thread Pool Settings")
	local pool
  if freeradius.pool == nil then pool = freeradius:set("thread","pool") 
  else pool = freeradius.pool end
----	Input Section form
	form:Add("text","freeradius.pool.start_servers",pool.start_servers,tr("start_servers#Start Servers"),"int")
	form:Add("text","freeradius.pool.max_servers",pool.max_servers,tr("max_servers#Max Servers"),"int")
	form:Add("text","freeradius.pool.min_spare_servers",pool.min_spare_servers,tr("min_spare_servers#Min spare servers"),"int")
	form:Add("text","freeradius.pool.max_spare_servers",pool.max_spare_servers,tr("max_spare_servers#Max spare servers"),"int")
	form:Add("text","freeradius.pool.max_requests_per_server",pool.max_requests_per_server,tr("max_requests_per_server#Max requests per server"),"int")
----	Help section	
	form:Add_help(tr("start_servers#Start Servers"),[[
        Number of servers to start initially --- should be a reasonable ballpark figure.
        ]])
	form:Add_help(tr("max_servers#Max Servers"),[[
        Limit on the total number of servers running.<BR>
        If this limit is ever reached, clients will be LOCKED OUT, so it
        should NOT BE SET TOO LOW.  It is intended mainly as a brake to
        keep a runaway server from taking the system with it as it spirals
        down...<br>
        You may find that the server is regularly reaching the
        'max_servers' number of threads, and that increasing
        'max_servers' doesn't seem to make much difference.<br>
        If this is the case, then the problem is MOST LIKELY that
        your back-end databases are taking too long to respond, and
        are preventing the server from responding in a timely manner.<br>
        The solution is NOT do keep increasing the 'max_servers'
        value, but instead to fix the underlying cause of the
        problem: slow database, or 'hostname_lookups=yes'.<br>
        For more information, see 'max_request_time', above.
        ]])
	form:Add_help(tr("min_spare_servers#Min spare servers").." / "..tr("max_spare_servers#Max spare servers"),[[
        Server-pool size regulation.  Rather than making you guess
        how many servers you need, FreeRADIUS dynamically adapts to
        the load it sees, that is, it tries to maintain enough
        servers to handle the current load, plus a few spare
        servers to handle transient load spikes.<br>
        It does this by periodically checking how many servers are
        waiting for a request.  If there are fewer than
        min_spare_servers, it creates a new spare.  If there are
        more than max_spare_servers, some of the spares die off.
        The default values are probably OK for most sites.
        ]])
	form:Add_help(tr("max_requests_per_server#Max requests per server"),[[
        There may be memory leaks or resource allocation problems with
        the server.  If so, set this value to 300 or so, so that the
        resources will be cleaned up periodically.<br>
        This should only be necessary if there are serious bugs in the
        server which have not yet been fixed.<br>
        '0' is a special value meaning 'infinity', or 'the servers never exit'
        ]])
elseif __FORM.option == "files_settings" then
	form = formClass.new("Files Settings")
	local files
  if freeradius.files == nil then files = freeradius:set("files","server") 
  else files = freeradius.files end
----	Input Section form
	form:Add("text","freeradius.files.prefix",files.prefix,"Prefix")
	form:Add("text","freeradius.files.exec_prefix",files.exec_prefix,"Exec-Prefix")
	form:Add("text","freeradius.files.sysconffir",files.sysconfdir,"System Configuration dir")
	form:Add("text","freeradius.files.localstatedir",files.localstatedir,"State dir")
	form:Add("text","freeradius.files.sbindir",files.sbindir,"sbin dir")
	form:Add("text","freeradius.files.logdir",files.logdir,"log. dir &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"..files.localstatedir)
	form:Add("text","freeradius.files.raddbdir",files.raddbdir,"radius db dir")
	form:Add("text","freeradius.files.radacctdir",files.radacctdir,"Account dir &nbsp;&nbsp;&nbsp;&nbsp;"..files.localstatedir..files.logdir)
--	form:Add("text","freeradius.files.confdir",files.confdir,"Conf dir")
	form:Add("text","freeradius.files.run_dir",files.run_dir,"run dir &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"..files.localstatedir)
	form:Add("text","freeradius.files.log_file",files.log_file,"Log File")
	form:Add("text","freeradius.files.libdir",files.libdir,"Lib dir")
	form:Add("text","freeradius.files.pidfile",files.pidfile,"pid file &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"..files.localstatedir..files.run_dir)
----	Help section	

elseif __FORM.option == "listen_settings" then
  if freeradius.settings == nil then settings = freeradius:set("settings","server") 
  else settings = freeradius.settings end
  if freeradius.listen == nil then listen = freeradius:set("listen","server") 
  else listen = freeradius.listen end
	form = formClass.new("Listen Settings")
----	Input Section form
	form:Add("text","freeradius.settings.bind_address",settings.bind_address,tr("bind_address#Bind Address"),"string","width=99%;")
	form:Add("text","freeradius.settings.port",settings.port,tr("port#Port"),"string")
	form:Add("subtitle","Listen Section")
----	Input Section form
	form:Add("text","freeradius.listen.ipaddr",listen.ipaddr,tr("bind_address#Bind Address"),"string","width=99%;")
	form:Add("text","freeradius.listen.port",listen.port,tr("port#Port"),"string")
  form:Add("select","freeradius.listen.type",listen.type,"Type","string")
	form["freeradius.listen.type"].options:Add("",tr("Select one"))
	form["freeradius.listen.type"].options:Add("auth",tr("Authorization"))
	form["freeradius.listen.type"].options:Add("acct",tr("Accounting"))
----	Help section	
	form:Add_help("bind_address#Bind Address","Make the server listen on a particular IP address, and send replies out from that address.  This directive is most useful for machines with multiple IP addresses on one interface. It can either contain *, or an IP address, or a fully qualified Internet domain name.  The default is *")
	form:Add_help("port#Port","Allows you to bind FreeRADIUS to a specific port. The default port that most NAS boxes use is 1645, which is historical. RFC 2138 defines 1812 to be the new port.  Many new servers and NAS boxes use 1812, which can create interoperability problems. The port is defined here to be 0 so that the server will pick up the machine's local configuration for the radius port, as defined in /etc/services. If you want to use the default RADIUS port as defined on your server, (usually through 'grep radius /etc/services') set this to 0 (zero).")
	form:Add_help("listen#Listen Section",[[By default, the server uses "bind_address" to listen to all IP's on a machine, or just one IP.  The "port" configuration is used to select the authentication port used when listening on those addresses.<br>If you want the server to listen on additional addresses, you can   use the "listen" section.<br>A sample section (commented out) is included
  below.  This "listen" section duplicates the functionality of the
  "bind_address" and "port" configuration entries, but it only listens
  for authentication packets.<br>
  If you comment out the "bind_address" and "port" configuration entries,
  then it becomes possible to make the server accept only accounting,
  or authentication packets.  Previously, it always listened for both
  types of packets, and it was impossible to make it listen for only
  one type of packet.<br>
  If you comment out the "bind_address" and "port" configuration entries,
  then it becomes possible to make the server accept only accounting,
  or authentication packets.  Previously, it always listened for both
  types of packets, and it was impossible to make it listen for only
  one type of packet.]])
elseif __FORM.option == "requests" then
  if freeradius.settings == nil then settings = freeradius:set("settings","server") 
  else settings = freeradius.settings end
  form = formClass.new("Requests Settings")
----	Input Section form
	form:Add("text","freeradius.settings.max_request_time",settings.max_request_time,tr("max_request_time#Max Request Time"),"int,>4,<121")
  
  form:Add("select","freeradius.settings.delete_blocked_requests",settings.delete_blocked_requests,tr("delete_blocked_requests#Delete Blocked Requests"),"string")
	form["freeradius.settings.delete_blocked_requests"].options:Add("no",tr("No"))
	form["freeradius.settings.delete_blocked_requests"].options:Add("yes",tr("Yes"))

	form:Add("text","freeradius.settings.cleanup_delay",settings.cleanup_delay,tr("cleanup_delay#Cleanup Delay"),"int,>1,<11")
	form:Add("text","freeradius.settings.max_requests",settings.max_requests,tr("max_requests#Max Requests"),"int,>255")

----	Help section	
	form:Add_help("max_request_time#Max Request Time","Useful range of values 5 to 120<br>The maximum time (in seconds) to handle a request.<br>Requests which take more time than this to process may be killed, and a REJECT message is returned.")
	form:Add_help("delete_blocked_requests#Delete Blocked Requests","If the request takes MORE THAN 'max_request_time' to be handled, then maybe the server should delete it.<br>If you're running in threaded, or thread pool mode, this setting should probably be 'no'.  Setting it to 'yes' when using a threaded server MAY cause the server to crash!")
	form:Add_help("cleanup_delay#Cleanup Delay","The time to wait (in seconds) before cleaning up a reply which was sent to the NAS.<br>Useful range of values: 2 to 10")
	form:Add_help("max_requests#Max Requests","The maximum number of requests which the server keeps track of. This should be 256 multiplied by the number of clients. e.g. With 4 clients, this number should be 1024.")

elseif __FORM.option == "miselaneous" then
  if freeradius.settings == nil then settings = freeradius:set("settings","server") 
  else settings = freeradius.settings end
  form = formClass.new("Miselaneous Settings")
----	Input Section form
  
  form:Add("select","freeradius.settings.hostname_lookups",settings.hostname_lookups,tr("hostname_lookups#Hostname Lookups"),"string")
	form["freeradius.settings.hostname_lookups"].options:Add("no",tr("No"))
	form["freeradius.settings.hostname_lookups"].options:Add("yes",tr("Yes"))

  form:Add("select","freeradius.settings.allow_core_dumps",settings.allow_core_dumps,tr("allow_core_dumps#Allow Core Dumps"),"string")
	form["freeradius.settings.allow_core_dumps"].options:Add("no",tr("No"))
	form["freeradius.settings.allow_core_dumps"].options:Add("yes",tr("Yes"))
  form:Add("subtitle","Regular Expressions")
  form:Add("select","freeradius.settings.regular_expressions",settings.regular_expressions,tr("regular_expressions#Regular Expressions"),"string")
	form["freeradius.settings.regular_expressions"].options:Add("no",tr("No"))
	form["freeradius.settings.regular_expressions"].options:Add("yes",tr("Yes"))

  form:Add("select","freeradius.settings.extended_expressions",settings.extended_expressions,tr("extended_expressions#Extended Expressions"),"string")
	form["freeradius.settings.extended_expressions"].options:Add("no",tr("No"))
	form["freeradius.settings.extended_expressions"].options:Add("yes",tr("Yes"))
  form:Add("subtitle","Logs")
  form:Add("select","freeradius.settings.log_stripped_names",settings.log_stripped_names,tr("log_stripped_names#Log stripped names"),"string")
	form["freeradius.settings.log_stripped_names"].options:Add("no",tr("No"))
	form["freeradius.settings.log_stripped_names"].options:Add("yes",tr("Yes"))

  form:Add("select","freeradius.settings.log_auth",settings.log_auth,tr("log_auth#Log authentication requests"),"string")
	form["freeradius.settings.log_auth"].options:Add("no",tr("No"))
	form["freeradius.settings.log_auth"].options:Add("yes",tr("Yes"))

  form:Add("select","freeradius.settings.log_auth_badpass",settings.log_auth_badpass,tr("log_auth_badpass#Log bad password"),"string")
	form["freeradius.settings.log_auth_badpass"].options:Add("no",tr("No"))
	form["freeradius.settings.log_auth_badpass"].options:Add("yes",tr("Yes"))

  form:Add("select","freeradius.settings.log_auth_goodpass",settings.log_auth_goodpass,tr("log_auth_goodpass#Log good password"),"string")
	form["freeradius.settings.log_auth_goodpass"].options:Add("no",tr("No"))
	form["freeradius.settings.log_auth_goodpass"].options:Add("yes",tr("Yes"))

  form:Add("subtitle","Username collision")
  form:Add("select","freeradius.settings.usercollide",settings.usercollide,tr("usercollide#Username collision"),"string")
	form["freeradius.settings.usercollide"].options:Add("no",tr("No"))
	form["freeradius.settings.usercollide"].options:Add("yes",tr("Yes"))

  form:Add("subtitle","Username & Password options")
  form:Add("select","freeradius.settings.lower_user",settings.lower_user,tr("lower_user#Lower Username"),"string")
	form["freeradius.settings.lower_user"].options:Add("no",tr("No"))
	form["freeradius.settings.lower_user"].options:Add("befor",tr("Before"))
	form["freeradius.settings.lower_user"].options:Add("after",tr("After"))

  form:Add("select","freeradius.settings.lower_pass",settings.lower_pass,tr("lower_pass#Lower Password"),"string")
	form["freeradius.settings.lower_pass"].options:Add("no",tr("No"))
	form["freeradius.settings.lower_pass"].options:Add("before",tr("Before"))
	form["freeradius.settings.lower_pass"].options:Add("after",tr("After"))

  form:Add("select","freeradius.settings.nospace_user",settings.nospace_user,tr("nospace_user#No space Username"),"string")
	form["freeradius.settings.nospace_user"].options:Add("no",tr("No"))
	form["freeradius.settings.nospace_user"].options:Add("before",tr("Before"))
	form["freeradius.settings.nospace_user"].options:Add("after",tr("After"))

  form:Add("select","freeradius.settings.nospace_pass",settings.nospace_pass,tr("nospace_pass#No space password"),"string")
	form["freeradius.settings.nospace_pass"].options:Add("no",tr("No"))
	form["freeradius.settings.nospace_pass"].options:Add("before",tr("Before"))
	form["freeradius.settings.nospace_pass"].options:Add("after",tr("After"))

----	Help section	
	form:Add_help("hostname_lookups#Hostname Lookups",[[
        Log the names of clients or just their IP addresses e.g., www.freeradius.org (on) or 206.47.27.232 (off).<br>
        The default is 'off' because it would be overall better for the net if people had to knowingly turn this feature on, since enabling it
        means that each client request will result in AT LEAST one lookup request to the nameserver.   Enabling hostname_lookups will also
        mean that your server may stop randomly for 30 seconds from time to time, if the DNS requests take too long.<br>
        Turning hostname lookups off also means that the server won't block for 30 seconds, if it sees an IP address which has no name associated with it.]])
	form:Add_help("allow_core_dumps#Allow Core Dumps",[[Core dumps are a bad thing.<br>This should only be set to 'yes' if you're debugging a problem with the server.]])
  form:Add_help("Regular Expression",[[These items are set at configure time.  If they're set to "yes", then setting them to "no" turns off regular expression support.<br>
        If they're set to "no" at configure time, then setting them to "yes" WILL NOT WORK.  It will give you an error.]])
  form:Add_help("log_stripped_names#Log stripped names","Log the full User-Name attribute, as it was found in the request.")
  form:Add_help("log_auth#Log authentication requests","Log authentication requests to the log file.")
  form:Add_help("usercollide#Username collision",[[Turn "username collision" code on and off.  See the "doc/duplicate-users" file<br>
                <font color="red">WARNING<br>
                Setting this to "yes" may result in the server behaving
                strangely.  The "username collision" code will ONLY work
                with clear-text passwords.  Even then, it may not do what
                you want, or what you expect.<br>
                We STRONGLY RECOMMEND that you do not use this feature,
                and that you find another way of acheiving the same goal.
                e,g. module fail-over.  See 'doc/configurable_failover'
                </font>]])
  form:Add_help("lower_user_pass#Lower Username / Password",[[Lower case the username/password "before" or "after" attempting to authenticate.<br>
        If "before", the server will first modify the request and then try
        to auth the user.  If "after", the server will first auth using the
        values provided by the user.  If that fails it will reprocess the
        request after modifying it as you specify below.<br>
        This is as close as we can get to case insensitivity.  It is the
        admin's job to ensure that the username on the auth db side is
        *also* lowercase to make this work<br>
        Default is 'no' (don't lowercase values)]])
  form:Add_help("nospace_user_pass#No space Username / Password",[[
        Some users like to enter spaces in their username or password
        incorrectly.  To save yourself the tech support call, you can
        eliminate those spaces here:<br>
        Default is 'no' (don't remove spaces)]])

elseif __FORM.option == "security" then
  if freeradius.security == nil then security = freeradius:set("security","server") 
  else security = freeradius.security end
  form = formClass.new("Security Configuration")
	form:Add("text","freeradius.security.max_attributes",security.max_attributes,tr("max_attributes#Max Attributes"),"int,>=0")
	form:Add("text","freeradius.security.reject_delay",security.reject_delay,tr("reject_delay#Reject delay"),"int,>=0,<6")
  form:Add("select","freeradius.settings.status_server",security.status_server,tr("status_server#Status server respond"),"string")
	form["freeradius.settings.status_server"].options:Add("no",tr("No"))
	form["freeradius.settings.status_server"].options:Add("yes",tr("Yes"))
  
----	Help section	
	form:Add_help(tr("security#Security Configuration"),[[
        There may be multiple methods of attacking on the server.  This
        section holds the configuration items which minimize the impact
        of those attacks]])
	form:Add_help(tr("max_attributes#Max Attributes"),[[
        The maximum number of attributes
        permitted in a RADIUS packet.  Packets which have MORE
        than this number of attributes in them will be dropped.<br>
        If this number is set too low, then no RADIUS packets
        will be accepted.<br>
        If this number is set too high, then an attacker may be
        able to send a small number of packets which will cause
        the server to use all available memory on the machine.<br>
        Setting this number to 0 means "allow any number of attributes"
          ]])
	form:Add_help(tr("reject_delay#Reject delay"),[[
        When sending an Access-Reject, it can be
        delayed for a few seconds.  This may help slow down a DoS
        attack.  It also helps to slow down people trying to brute-force
        crack a users password.<br>
        Setting this number to 0 means "send rejects immediately"<br>
        If this number is set higher than 'cleanup_delay', then the
        rejects will be sent at 'cleanup_delay' time, when the request
        is deleted from the internal cache of requests.<br>
        Useful ranges: 1 to 5
          ]])
	form:Add_help(tr("status_server#Status server respond"),[[
        Whether or not the server will respond to Status-Server requests.<br>
        Normally this should be set to "no", because they're useless.<br>
        See: <a href="http://www.freeradius.org/rfc/rfc2865.html#Keep-Alives"> http://www.freeradius.org/rfc/rfc2865.html#Keep-Alives</a><br>
        However, certain NAS boxes may require them.<br>
        When sent a Status-Server message, the server responds with
        an Access-Accept packet, containing a Reply-Message attribute,
        which is a string describing how long the server has been running.
            ]])
else
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
end
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
