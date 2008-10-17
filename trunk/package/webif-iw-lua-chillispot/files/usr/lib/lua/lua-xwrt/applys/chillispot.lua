require("uci_iwaddon")
require("firewall")
require("common")
require("net")

parser = {}
local P = {}
parser = P
-- Import Section:
-- declare everything this package needs from outside
local wwwprint = wwwprint
if wwwprint == nil then wwwprint=print end
local uci = uci
local io = io
local string = string
local unpack = unpack
local oldprint = oldprint
local pairs = pairs
local tonumber = tonumber
local firewall = firewall
local net = net
-- no more external access after this point
setfenv(1, P)

name = "ChilliSpot"
script = "chilli"
init_script = "/etc/init.d/chilli"

enable = tonumber(uci.get("chillispot.webadmin.enable")) or 0
local userlevel = tonumber(uci.get("chillispot.webadmin.userlevel")) or 0
local radconf = tonumber(uci.get("chillispot.webadmin.radconf")) or 0
call_parser = nil

reboot = false                -- reboot device after all apply process

--exe_before = {} -- execute os process in this table before any process
exe_after  = {} -- execute os process after all apply process
if radconf > 1 then
  call_parser = "freeradius freeradius_check freeradius_clients freeradius_proxy"
  exe_after["/etc/init.d/radiusd restart"]="freeradius"
end
exe_after["/etc/init.d/network restart"]="network"
exe_after["wifi"]="wifi"
exe_after["/etc/init.d/firewall restart"]="firewall"

-- depends_pkgs = "libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"

function process()
--  process_networks_values()
  write_config()  
  uci.commit("coovachilli")
  uci.commit("network")
  uci.commit("wireless")
end

function write_init()
  wwwprint ("Writing init file /etc/init.d/chilli")
  local init_file = [[#!/bin/sh /etc/rc.common
START=69

RUN_D=/var/run
PID_F=$RUN_D/chilli.pid
CRONSET="* * * * * /usr/lib/lua/lua-xwrt/pkgs/chilli/minute.cron"

start() {
	/usr/sbin/chilli
  /usr/lib/lua/lua-wrt/cron_ctrl add "$CRONSET"
}

stop() {
  /usr/lib/lua/lua-wrt/cron_ctrl del "$CRONSET"
	[ -f $PID_F ] && kill $(cat $PID_F) >/dev/null 2>&1
}

]]
  wwwprint ("init file /etc/init.d/chilli writed OK!".."<br>")
  write_file = io.open("/etc/init.d/chilli","w")
  write_file:write(init_file)
  write_file:close()
end

function set_alloweds()
	chilli = uci.get_all("chillispot")
	allowed = uci.get_type("chillispot","sitesallowed")
	tallow = {}
	if allowed then
		for i,t in pairs(allowed) do
			sites = string.gsub(t.site," ","")
			for site in string.gmatch(sites,"[^,]+") do
				tallow[site] = "" 
			end
		end
	end
	if chilli.settings.radiusserver1 then tallow[chilli.settings.radiusserver1] = "" end
	if chilli.settings.radiusserver2 then tallow[chilli.settings.radiusserver2] ="" end
	if chilli.settings.dns1 then tallow[chilli.settings.dns1] ="" end
	if chilli.settings.dns2 then tallow[chilli.settings.dns2] ="" end
	if chilli.settings.uamlisten then tallow[chilli.settings.uamlisten] ="" end
	tallow["x-wrt.org"] = ""
	tallow["openwrt.org"] = ""
	tallow["www.internet-wifi.com.ar"] = ""
	tallow["www.chillispot.info"] = ""
	if chilli.system.paypal ~= nil then
		tallow["www.paypal.com"] = ""
		tallow["66.211.168.0/24"] = ""
		tallow["64.4.241.0/24"] = ""
		tallow["216.113.188.0/24"] = ""
		tallow["www.paypalobjects.com"] = ""
		tallow["88.221.0.0/16"] = ""
		tallow["84.53.0.0/16"] = ""
		tallow["67.133.200.0/22"] = ""
		tallow["72.246.0.0/15"] = ""
		tallow["paypal.112.2o7.net"] = ""
		tallow["216.52.17.0/24"] = ""
		tallow["70.42.134.0/24"] = ""
		tallow["128.242.125.0/24"] = ""
	end 
	local allow_str =""
	local sep_str = ""
	for i, v in pairs(tallow) do
		allow_str = allow_str..sep_str..i
		sep_str=","
	end
	return allow_str
end

function set_networks()
	wwwprint("Configuring Networks")
	local hs_iflan = uci.get("chillispot","webadmin","dhcpif")
	local iflan, ifwifi = unpack(string.split(hs_iflan,":"))
	uci.set("wireless",ifwifi,"disabled","0")
	local wireless = uci.get_type("wireless","wifi-iface")
	wwwprint("Network "..iflan)
	for i=1, #wireless do
		if wireless[i].device == ifwifi then
			wwwprint("Wireless "..ifwifi)
			uci.set("wireless",wireless[i][".name"],"network",iflan)
			break
		end
	end
	uci.set("network",iflan,"ifname",ifwifi)
	firewall.set_forwarding(iflan,"wan")
	wwwprint("Setting firewall")
	if iflan ~= "lan" then
		firewall.set_forwarding(iflan,"lan")
		firewall.set_forwarding("lan","wifi")
	end
	local devlan = iflan
	if uci.get("network",iflan,"type") == "bridge" then devlan = "br-"..iflan end
	uci.set("chillispot","settings","dhcpif",devlan)
	wwwprint("Set dhcpif = "..iflan)
	local ip = uci.get("network",iflan,"ipaddr")
	local mask = uci.get("network",iflan,"netmask")
	tnet = net.get_unique_ip(ip,mask,iflan)
	uci.check_set("network",iflan,"ipaddr",tnet.IP)
	uci.check_set("network",iflan,"netmask",tnet.NETMASK)
	uci.save("network")
	uci.save("wireless")
	uci.save("chillispot")
	wwwprint("Network setting ok")
end

function write_config()
  wwwprint ("Writing configuration file /etc/chilli/config")
	local settings = uci.get_section("chillispot","settings")
	conf_str = "#### This conf file was writed by webif-iw-lua-chillispot-apply ####\n"
	if settings then
		for i, t in pairs(settings) do
			if not string.match(i,"[.]") then
      	if string.match(t,"%s") then t = "\""..t.."\"" end
				conf_str = conf_str .. i.." "..t.."\n"
			end
		end
	end
	conf_str = conf_str.."uamallowed "..set_alloweds().."\n"
  local setting = uci.get_section("chillispot","checked")
  for k,v in pairs(setting) do
    if not string.match(k,"[.]") then
      if tonumber(v) == 1 then
        conf_str = conf_file .. k .. "\n"
      end
    end
  end
  chillisetting = uci.get_section("chillispot","webadmin")
  if chillisetting then
    if chillisetting.isocc
    or chillisetting.cc
    or chillisetting.ac
    or chillisetting.netname then
    	local isocc = chillisetting.isocc or ""
    	local cc = chillisetting.cc or ""
    	local ac = chillisetting.ac or ""
    	local netname = chillisetting.netname or ""
    	netname = string.gsub(netname," ","_")
    	conf_file = conf_file .. "radiuslocationid isocc="..isocc..",cc="..cc..",ac="..ac..",network="..netname
    	isocc=AR,cc=54,ac=372,network=Coova,X_Wrt_Network
    end
	end
	conf_str .. "\n"
  write_file = io.open("/etc/chilli/config","w")
  write_file:write(conf_str)
  write_file:close()
  wwwprint("/etc/chilli/config writed OK!")
end

return parser
