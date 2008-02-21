#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
-- local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("files/freeradius-menu")
page.title = tr("Freeradius Clients")
print(page:header())

local radiusd_str = [[
prefix = /usr
exec_prefix = /usr
sysconfdir = /etc
localstatedir = /var
sbindir = /usr/sbin
logdir = ${localstatedir}/log/radius
raddbdir = /etc/freeradius
radacctdir = ${logdir}/radacct
#  Location of config and logfiles.
confdir = ${raddbdir}
run_dir = ${localstatedir}/run
log_file = ${logdir}/radiusd.log
libdir = /usr/lib/
pidfile = ${run_dir}/radiusd.pid
max_request_time = 30
delete_blocked_requests = no
cleanup_delay = 5
max_requests = 1024
bind_address = *
port = 0
hostname_lookups = no
allow_core_dumps = no
regular_expressions	= yes
extended_expressions	= yes
log_stripped_names = no
log_auth = no
log_auth_badpass = no
log_auth_goodpass = no
usercollide = no
lower_user = no
lower_pass = no
nospace_user = no
nospace_pass = no
security {
	max_attributes = 200
	reject_delay = 1
	status_server = no
}
proxy_requests  = yes
$INCLUDE  ${confdir}/proxy.conf
$INCLUDE  ${confdir}/clients.conf
# SNMP CONFIGURATION
#
#  Snmp configuration is only valid if SNMP support was enabled
#  at compile time.
#
#  To enable SNMP querying of the server, set the value of the
#  'snmp' attribute to 'yes'
#
snmp	= no
#$INCLUDE  ${confdir}/snmp.conf


thread pool {
	start_servers = 5
	max_servers = 32
	min_spare_servers = 3
	max_spare_servers = 10
	max_requests_per_server = 0
}

modules {
#	pap {
#		auto_header = yes
#	}
	chap {
		authtype = CHAP
	}
	pam {
		#
		#  The name to use for PAM authentication.
		#  PAM looks in /etc/pam.d/${pam_auth_name}
		#  for it's configuration.  See 'redhat/radiusd-pam'
		#  for a sample PAM configuration file.
		#
		#  Note that any Pam-Auth attribute set in the 'authorize'
		#  section will over-ride this one.
		#
		pam_auth = radiusd
	}

	# Unix /etc/passwd style authentication
	#
	unix {
		cache = no
		cache_reload = 600
		radwtmp = ${logdir}/radwtmp
	}
	realm suffix {
		format = suffix
		delimiter = "@"
		ignore_default = no
		ignore_null = no
	}

	#  'username%realm'
	#
	realm realmpercent {
		format = suffix
		delimiter = "%"
		ignore_default = no
		ignore_null = no
	}

	#
	#  'domain\user'
	#
	realm ntdomain {
		format = prefix
		delimiter = "\\"
		ignore_default = no
		ignore_null = no
	}	

	checkval {
		# The attribute to look for in the request
		item-name = Calling-Station-Id

		# The attribute to look for in check items. Can be multi valued
		check-name = Calling-Station-Id

		# The data type. Can be
		# string,integer,ipaddr,date,abinary,octets
		data-type = string

		# If set to yes and we dont find the item-name attribute in the
		# request then we send back a reject
		# DEFAULT is no
		#notfound-reject = no
	}
	
	preprocess {
		huntgroups = ${confdir}/huntgroups
		hints = ${confdir}/hints
		with_ascend_hack = no
		ascend_channels_per_line = 23
		with_ntdomain_hack = no
		with_specialix_jetstream_hack = no
		with_cisco_vsa_hack = no
	}

	files {
		usersfile = ${confdir}/users
		acctusersfile = ${confdir}/acct_users
#		preproxy_usersfile = ${confdir}/preproxy_users
		compat = no
	}

	detail {
		detailfile = ${radacctdir}/%{Client-IP-Address}/detail-%Y%m%d
		detailperm = 0600
		#suppress {
			# User-Password
		#}
	}

	acct_unique {
		key = "User-Name, Acct-Session-Id, NAS-IP-Address, Client-IP-Address, NAS-Port"
	}
	radutmp {
		filename = ${logdir}/radutmp
		username = %{User-Name}
		case_sensitive = yes
		check_with_nas = yes		
		perm = 0600
		callerid = "yes"
	}
	radutmp sradutmp {
		filename = ${logdir}/sradutmp
		perm = 0644
		callerid = "no"
	}
	attr_filter {
		attrsfile = ${confdir}/attrs
	}
	always fail {
		rcode = fail
	}
	always reject {
		rcode = reject
	}
	always ok {
		rcode = ok
		simulcount = 0
		mpp = no
	}
	expr {
	}
	digest {
	}
	exec {
		wait = yes
		input_pairs = request
	}
	exec echo {
		wait = yes
		program = "/bin/echo %{User-Name}"
		input_pairs = request
		output_pairs = reply

		#
		#  When to execute the program.  If the packet
		#  type does NOT match what's listed here, then
		#  the module does NOT execute the program.
		#
		#  For a list of allowed packet types, see
		#  the 'dictionary' file, and look for VALUEs
		#  of the Packet-Type attribute.
		#
		#  By default, the module executes on ANY packet.
		#  Un-comment out the following line to tell the
		#  module to execute only if an Access-Accept is
		#  being sent to the NAS.
		#
		#packet_type = Access-Accept
	}

#	ippool main_pool {
#		range-start = 192.168.1.1
#		range-stop = 192.168.3.254
#		netmask = 255.255.255.0
#		cache-size = 800
#		session-db = ${raddbdir}/db.ippool
#		ip-index = ${raddbdir}/db.ipindex
#		override = no
#		maximum-timeout = 0
#	}
}

instantiate {
#	exec
#	expr
#	daily
}

authorize {
#	preprocess
#	auth_log
#	attr_filter
	chap
#	mschap
#	digest
	suffix
#	ntdomain
	files
#	sql
#	etc_smbpasswd
#	ldap
#	daily
#	checkval
#	pap
}


authenticate {
#	Auth-Type PAP {
#		pap
#	}
	Auth-Type CHAP {
		chap
	}
#	digest
#	pam
#	unix
#	Auth-Type LDAP {
#		ldap
#	}
#	eap
}


preacct {
#	preprocess
#	acct_unique
	suffix
#	ntdomain
	files
}
accounting {
#	detail
#	daily
#	unix
	radutmp
#	sradutmp
#	main_pool
#	sql
#	sql_log
#	pgsql-voip
}
session {
	radutmp
#	sql
}
post-auth {
#	main_pool
#	reply_log
#	sql
#	sql_log
#	ldap
#	Post-Auth-Type REJECT {
#		insert-module-name-here
#	}
}
pre-proxy {
#	attr_rewrite
#	files
#	pre_proxy_log
}
post-proxy {
#	post_proxy_log
#	attr_rewrite
#	attr_filter
#	eap
}

]]

print("Commiting radius.conf<br>")
os.execute("uci commit freeradius")
pepe = io.open("/etc/freeradius/radiusd.conf","w")
pepe:write(radiusd_str)
pepe:close()

local sep = ""

-- Process proxy.conf
print("Commiting proxy.conf<br>")
os.execute("uci commit freeradius-proxy")
proxy = uciClass.new("freeradius-proxy")
local proxy_str = "proxy server {\n"
for i, v in pairs (proxy.server) do
  for k, val in pairs(v.values) do
    proxy_str = proxy_str .. k .."="..val.."\n"
  end
end

proxy_str = proxy_str .. "}\n\n"
for i, v in pairs (proxy.realm) do
  proxy_str = proxy_str .. "realm "..v.values.community .." {\n"
  for k, val in pairs(v.values) do
    if k ~= "community" then
      if k == "nostrip" then
        proxy_str = proxy_str.."\t".."nostrip\n"
      else
        proxy_str = proxy_str .. "\t"..k.."="..val.."\n"
      end
    end
  end
  proxy_str = proxy_str .. "}\n\n"
end
pepe = io.open("/etc/freeradius/proxy.conf","w")
pepe:write(proxy_str)
pepe:close()

print("Commiting users<br>")
-- Process users
os.execute("uci commit freeradius-check")
os.execute("uci commit freeradius-reply")
local user_str = ""
users_chk = uciClass.new("freeradius-check")
users_rpl = uciClass.new("freeradius-reply")

for i=1, #users_chk.user do
  user_str = user_str.."\n\n"..users_chk.user[i].values.Username
  sep = "\t"
  for j, k in pairs (users_chk.user[i].values) do
    if j ~= "Username" then
      if string.trim(j) == "User_Password" then
        user_str = user_str..sep.. string.gsub(j,"_","-").." := \""..k.."\""
      else
        user_str = user_str..sep.. string.gsub(j,"_","-").." := "..k
      end
      sep = ", "
    end
  end
  sep = "\n\t"
  for j, k in pairs (users_rpl.user[i].values) do
    if j ~= "Username" then
      user_str = user_str..sep.. string.gsub(j,"_","-").." = "..k
      sep = ", "
    end
  end
end
sep = ""
user_str = user_str.."\n\nDEFAULT\t"
for i, v in pairs (users_chk.default) do
  if type(v) ~= "table" then
    user_str = user_str..sep..string.gsub(i,"_","-").." := "..v
    sep = ", "
  end
end
sep = "\n\t"
for i, v in pairs (users_rpl.default) do
  if type(v) ~= "table" then
    user_str = user_str..sep..string.gsub(i,"_","-").." = "..v
    sep = ",\n\t"
  end
end

pepe = io.open("/etc/freeradius/users","w")
pepe:write(user_str)
pepe:close()

-- Process clients.conf
os.execute("uci commit freeradius-clients")
clients = uciClass.new("freeradius-clients")
local client_str = ""
print("Commiting clients.conf<br>")
for i=1, #clients.client do
  client_str = client_str .. "client "..clients.client[i].values.client.." {\n"
--  print (clients.client[i].values.client,"<br>")
  sep = "\t"
  for k,v in pairs(clients.client[i].values) do
    if k ~= "client" then
      client_str = client_str..sep..k.."\t= "..v
      sep = "\n\t"
--      print (k,v,"<br>")
    end
  end
  client_str = client_str.."\n}\n"
end

pepe = io.open("/etc/freeradius/clients.conf","w")
pepe:write(client_str)
pepe:close()

freeradius = uciClass.new("freeradius")
if freeradius.webadmin.enable == "1" then
  print ("Reloading Freeradius settings...<br>")
  local myexec = io.popen("/etc/init.d/radiusd enable")
  print ("Enabling Freeradius service...<br>")
  for li in myexec:lines() do
    if string.len(li) > 1 then
      print(li,"<br>")
    end
  end
  myexec:close()
--  print("<br>")
  myexec = io.popen("/etc/init.d/radiusd stop")
  print ("Stopping Freeradius service...<br>")
  for li in myexec:lines() do
    if string.len(li) > 1 then
      print(li,"<br>")
    end
  end
  myexec:close()
--  print("<br>")
  myexec = io.popen("/etc/init.d/radiusd start")
  print ("Starting Freeradius service...<br>")
  for li in myexec:lines() do
    if string.len(li) > 1 then
      print(li,"<br>")
    end
  end
  myexec:close()
else
  myexec = io.popen("/etc/init.d/radiusd stop")
  print ("Stopping Freeradius service...<br>")
  for li in myexec:lines() do
    if string.len(li) > 1 then
      print(li,"<br>")
    end
  end
  myexec:close()
  myexec = io.popen("/etc/init.d/radiusd disable")
  print ("Disabling Freeradius service...<br>")
  for li in myexec:lines() do
    if string.len(li) > 1 then
      print(li,"<br>")
    end
  end
  myexec:close()
end

  

print(page:footer())
