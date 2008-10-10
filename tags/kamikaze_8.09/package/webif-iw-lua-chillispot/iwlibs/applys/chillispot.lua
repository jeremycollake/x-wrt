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
radiususers = tonumber(uci.get("chillispot.webadmin.radconf")) or 0

reboot = false                -- reboot device after all apply process
--exe_before = {} -- execute os process in this table before any process

exe_after  = {} -- execute os process after all apply process
if radiususers > 1 then
  call_parser = "freeradius freeradius_check freeradius_clients freeradius_proxy"
  exe_after["/etc/init.d/radiusd restart"]="freeradius"
end
exe_after["/etc/init.d/network restart"]="network"
exe_after["wifi"]="wifi"

script = "chilli"
init_script = "/etc/init.d/chilli"

-- depends_pkgs = "libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"
--[[
function set_network()
  local tun_network = uci.get("chillispot","webadmin","uamlisten")
  
  if tun_network then
    
  
  else
    uci.delete("chillispot","net","net")
    set_dynip()
    set_statip()
  end
end

function set_dynip(default)
  if default ~= true then
  else
    uci.delete("chillispot","net","dynip")
  end
end

function set_default_statip(default)
  uci.delete("chillispot","net","statip")
end
]]--

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

--[[
-- Esto todavia no esta hecho es para controlar las 
  local dynip = uci.get("chillispot","webadmin","dynip")
  local dynip_mask = uci.get("chillispot","webadmin","dynip_mask") or "255.255.255.0"
  local statip = uci.get("chillispot","settings","statip")
  local statip_mask = uci.get("chillispot","settings","statip") or "255.255.255.0"
  local tdynip = {}
  if dynip ~= nil then
    tdynip = ipcalc(dynip,dynip_mask)
  end
  if statip ~= nil then
    tstatip = ipcalc(statip,statip_mask)
  end
]]--      
--[[
#  net 192.168.182.0/24
#dynip 192.168.182.0/24
#statip 192.168.182.0/24
#dns1 172.16.0.5
#dns2 172.16.0.6
uamserver https://radius.chillispot.org/hotspotlogin
#uamhomepage http://192.168.182.1/welcome.html
#uamsecret ht2eb8ej6s4et3rg1ulp
#uamlisten 192.168.182.1
#uamport 3990
]]--   
--[[      
  local uamlisten = uci.get("chillispot","webadmin","uamlisten")
  if uamlisten == nil then set_default_network end
  local netmask = uci.get("chillispot","webadmin","netmask") or "255.255.255.0"
  
  local dynip = uci.get("chillispot","webadmin","dynip")
  local dynip_mask = uci.get("chillispot","webadmin","dynip_mask")
  
  local staticip = uci.get("chillispot","webadmin","staticip")
  local staticip_mask = uci.get("chillispot","webadmin","staticip_mask")

  if uamlisten then
    process_uamlisten
  else
    wwwprint("Assign 192.168.182.1 to uam")
  local tnetwork = ipcalc(uamlisten,netmask)
  uamlisten = tnetwork["IP"]
  netmask = tnetwork["NETMASK"]
  local network = tnetwork["NETWORK"]
  local netprefix = tnetwork["PREFIX"]
  local tdyn
  local tstatic
  if dynip then
    if dynip_mask then
      tdyn = ipcalc(dynip,dynip_mask)
    els
    local tstatic = ipcalc(staticip,staticip_mask)
  
  stat
]]--
end

function process()
--  if userlevel < 2 then basic_settings() end
--  wwwprint("Chilli Parsers...")
  process_networks_values()
  write_config()  
  
--[[  
  radiususers = tonumber(uci.get("chillispot.webadmin.radconf"))
  if radiususers > 1 then
    wwwprint("Checking freeradius installation")
    local write_file
    if io.exists("/usr/share/freeradius/dictionary") then
      local dict = io.totable("/usr/share/freeradius/dictionary",true)
      wwwprint("Updating /usr/share/freeradius/dictionary")
      if dict[1] ~= "$INCLUDE dictionary.chillispot" then
        table.insert(dict,1,"$INCLUDE dictionary.chillispot")
      end
      write_file = io.open("/usr/share/freeradius/dictionary","w")
      write_file:write(table.concat(dict,'\n'))
      write_file:close()
    end
  end
  local netnm = uci.check_set("chillispot","webadmin","netname","chilli")
  if userlevel < 2 then
    uci.set("chillispot","webadmin","ipaddr","192.168.20.1")
    uci.set("chillispot","webadmin","netmask","255.255.255.0")
    uci.set("chillispot","webadmin","device",uci.get("chillispot","webadmin","ifwifi"))
  end
  uci.save("chillispot")
  local chilli = uci.get_all("chillispot")
  local network = uci.get_all("network")
  if network[netnm] == nil then 
    uci.set("network",netnm,"interface")
    uci.save("network")
    network = uci.get_all("network")
  end
    
--  if uci.get("chillispot.webadmin.ifwifi") and uci.get("chillispot.net.dhcpif") == nil then
    uci.check_set("network",netnm,"interface")
    uci.set("network",netnm,"proto","static")
    uci.set("network",netnm,"type","bridge")
    uci.set("network",netnm,"ipaddr",chilli.webadmin.ipaddr)
    uci.set("network",netnm,"netmask",chilli.webadmin.netmask)
    uci.save("network")
    if uci.get("network",netnm,"ifname") == nil then
      uci.set("network",netnm,"ifname",uci.get("chillispot.webadmin.ifwifi"))
    elseif not string.gmatch(uci.get("network",netnm,"ifname"),uci.get("chillispot.webadmin.ifwifi")) then
      uci.set("network",netnm,"ifname", uci.get("network",netnm,"ifname").." "..uci.get("chillispot.webadmin.ifwifi"))
    end
    uci.save("network")
    network = uci.get_all("network")
    if network[netnm].type ~= "bridge" then
      if network[netnm].ifname ~= nil then
        uci.set("chillispot","net","dhcpif",network[netnm].ifname)
      end
    else
      uci.set("chillispot","net","dhcpif","br-"..netnm)
    end
    uci.save("chillispot")
--  end

  network = uci.get_all("network")
  if uci.get("chillispot","webadmin","enable") == "1" then
    local wififace = uci.get_type("wireless","wifi-iface")
    for i=1, #wififace do
      if wififace[i].device == network[netnm].ifname then
        if wififace[i].network == "lan" or wififace[i].network ~= "wifi" then
          uci.set("wireless",wififace[i][".name"],"network",uci.get("chillispot","webadmin","netname"))
        end
        uci.set("wireless",network[netnm].ifname,"disabled","0")
        break
      end
    end
  end    
  uci.commit("network")
  uci.commit("wireless")
  uci.commit("chillispot")
  write_init()
  write_config()
]]--
end

function write_init()
  wwwprint ("Writing init file /etc/init.d/chilli")
  local init_file = [[#!/bin/sh /etc/rc.common
START=69

RUN_D=/var/run
PID_F=$RUN_D/chilli.pid
CRONSET="* * * * * /usr/lib/lua/lua-wrt/pkgs/chilli/minute.cron"

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

function write_config()
  local conf_file ="#### This conf file was writed by iw-apply for chillispot ####\n"
  local chillisetting = uci.get_section("chillispot","settings")
  for k,v in pairs(chillisetting) do
    if not string.match(k,"[.]") then
      if k == "debug"
      or k == "macauth"
      or k == "uamanydns"
      or k == "coanoipcheck"
      or k == "acctupdate"
      or k == "fg"
      or k == "eapolenable" then
        if tonumber(v) == 1 then
          conf_file = conf_file .. k .. "\n"
        end
      else
        conf_file = conf_file .. k .. " " .. v .. "\n"
      end
    end
  end
  chillisetting = uci.get_type("chillispot","sitesallowed")
  if chillisetting then
    local sep = " "
    conf_file = conf_file .. "uamallowed"
    for i=1, #chillisetting do
      conf_file = conf_file .. sep .. chillisetting[i].site
      sep = ","
    end
  end
  conf_file = conf_file.."\n"
  write_file = io.open("/etc/chilli.conf","w")
  write_file:write(conf_file)
  write_file:close()
end

return parser
