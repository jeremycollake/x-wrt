require("uci_iwaddon")
require("net")
require("common")
parser = {}
local P = {}
parser = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local wwwprint = wwwprint
if wwwprint == nil then wwwprint=print end
local string = string
local table = table
local pairs = pairs
local uci = uci
local net = net
local tonumber = tonumber
-- no more external access after this point
setfenv(1, P)
name = "ChilliSpot"

enable = tonumber(uci.get("chillispot.webadmin.enable")) or 0
userlevel = tonumber(uci.get("chillispot.webadmin.userlevel")) or 0
radconf = tonumber(uci.get("chillispot.webadmin.radconf")) or 0

reboot = false                -- reboot device after all apply process
--exe_before = {} -- execute os process in this table before any process

exe_after  = {} -- execute os process after all apply process
if radconf > 1 then
  call_parser = "freeradius freeradius_check freeradius_clients freeradius_proxy"
  exe_after["/etc/init.d/radiusd restart"]="freeradius"
end
exe_after["/etc/init.d/network restart"]="network"
exe_after["wifi"]="wifi"

script = "chilli"
init_script = "/etc/init.d/chilli"

-- depends_pkgs = "libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"

function process_networks_values()
  local systemoption = tonumber(uci.get("chillispot","system","dhcpif"))
  if systemoption > 0 then
    local selected = nil
    if systemoption == 1 then
      selected = "lan"
    elseif systemoption == 2 then
      selected = "wifi"
    elseif systemoption == 3 then
      selected = "lan"
    end

    local netname = selected
    local networks = net.networks()
    local ipcalc = nil

    if networks[selected] then
      if networks[selected].ipaddr ~= nil
      and networks[selected].netmask then
        ipcalc = net.ipcalc(networks[selected].ipaddr,networks[selected].netmask)
      end
    end
    
    if systemoption == 1 
    or systemoption == 3 then 
      uci.set("chillispot","settings","net",ipcalc.NETWORK.."/"..ipcalc.NETMASK)
      uci.set("chillispot","webadmin","netmask",ipcalc.NETMASK)
      uci.set("chillispot","settings","uamlisten",networks[selected].ipaddr)
    else
      uci.delete("chillispot","webadmin","netmask")
      uci.delete("chillispot","settings","net")
      uci.delete("chillispot","settings","uamlisten")
    end

    dhcp = uci.get_all("dhcp")
    if dhcp[selected] ~= nil then
      uci.set("dhcp",selected,"ignore","1")
      uci.save("dhcp")
    end

    local wifidev = nil
    if systemoption > 1 then
      local allwifi = uci.get_all("wireless")
      local wifi = uci.get_type("wireless","wifi-iface")
      if wifi then
        if #wifi == 1 then
          wifidev = wifi[1]
        else
          for i=1, #wifi do 
            if wifi[i].network == selected then
              wifidev = wifi[i]
              break
            end
          end
          if wifidev == nil then
            for i=1,#wifi do
              if allwifi[wifi[i].device].disabled == "1" then
                wifidev = wifi[i]
                break
              end
            end
          end
          if wifidev == nil then
            wifidev = wifi[1]
          end
        end
      end
      uci.set("wireless",wifidev.device,"disabled","0")
      uci.set("wireless",wifidev[".name"],"network",selected)
    end

    if networks[selected] == nil then 
      uci.check_set("network","wifi","interface");
      uci.check_set("network","wifi","proto","static");
      uci.check_set("network","wifi","type","bridge");
      uci.check_set("network","wifi","ifname",wifidev.device);
      uci.check_set("network","wifi","ipaddr","192.168.20.1");
      uci.check_set("network","wifi","netmask","255.255.255.0");
      networks[selected]={}
      networks[selected].type="bridge";
      networks[selected].proto="static";
      networks[selected].ifname=wifidev.device;
      uci.save("network")
    end

    if networks[selected].type == "bridge" then
      netname = "br-"..selected
    end

    uci.set("chillispot","settings","dhcpif",netname)
    uci.save("network")
    uci.save("wireless")
    uci.commit("network")
    uci.commit("wireless")
    uci.commit("dhcp")
    uci.save("chillispot")
  end

  local dhcpif = uci.get("chillispot","settings","dhcpif")
  local dhcpif_state = false
  local interface = ""
  local error_msg = ""
  local dev_list = net.invert_dev_list()

  if dev_list[dhcpif] then
    interface = dev_list[dhcpif]
--    wwwprint("device "..dhcpif.." OK")
--    wwwprint("interface "..interface)
  else 
    wwwprint("device "..dhcpif.." not exists!!!")
    os.exit(0)
  end
-- Check DHCP over this interface --
  local dhcp_active = uci.get_type("dhcp","dhcp")
  for i=1, #dhcp_active do
    if dhcp_active[i].interface == interface then
      if tonumber(dhcp_active[i].interface.ignore) == 0 then
        wwwprint("This interface have a dhcp services running, you should deactivate it, or select other interface")
        os.exit(0)
      end
    end
  end
  wwwprint("interface "..interface.." OK")
  
  local uamlisten = uci.get("chillispot","settings","uamlisten")
  local netmask = uci.get("chillispot","webadmin","netmask")
  local uamport = uci.get("chillispot","settings","uamport")
  local clhillinet = uci.get("chillispot","settings","net")
  local tnetwork = {}

  if uamlisten ~= nil then
    tnetwork = net.ipcalc(uamlisten,netmask)
    uamlisten = tnetwork["IP"]
    netmask = tnetwork["NETMASK"]
    local network = tnetwork["NETWORK"]
    local netprefix = tnetwork["PREFIX"]
  end

  if chillinet ~= nil and chillinet ~= tnetwork["NETWORK"].."/"..tnetwork["NETMASK"] then
    wwwprint("Your net Configuration do not match.")
    wwwprint("Configuring your network to "..tnetwork["NETWORK"].."/"..tnetwork["NETMASK"])
    uci.set("chillispot","settings","net",tnetwork["NETWORK"].."/"..tnetwork["NETMASK"])
    uci.save("chillispot")
  end

end

function process()
  process_networks_values()
  write_config()  
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
	if chilli.settings.HS_RADIUS then tallow[chilli.settings.HS_RADIUS] = "" end
	if chilli.settings.HS_RADIUS2 then tallow[chilli.settings.HS_RADIUS2] ="" end
	if chilli.settings.HS_DNS1 then tallow[chilli.settings.HS_DNS1] ="" end
	if chilli.settings.HS_DNS2 then tallow[chilli.settings.HS_DNS2] ="" end
	if chilli.settings.HS_UAMLISTEN then tallow[chilli.settings.HS_UAMLISTEN] ="" end
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

function write_config()
  wwwprint ("Writing configuration file /etc/chilli/config")
	local settings = uci.get_section("coovachilli","settings")
	conf_str = "#### This conf file was writed by webif-iw-lua-coovachilli-apply ####\n"
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
