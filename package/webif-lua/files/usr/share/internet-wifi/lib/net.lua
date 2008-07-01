--[[
    Network package
    Availables functions
    uci.show [<package>[.<config>] ]
    uci.get <package>.<config>.<option>
    uci.set <package>.<config>[.<option>]=<value>
    uci.del <package>.<config>[.<option>]
    uci.rename <package> <config> <name>
    uci.commit [<package> ... ]

]]--
require("uci_iwaddon")

net = {}
local P = {}
net = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local uciClass = uciClass
local assert = assert
local string = string
local __UCI_VERSION = __UCI_VERSION
local pairs = pairs
local listtovars = listtovars
local uci = uci
 
-- no more external access after this point
setfenv(1, P)

-- Table of availables NIC
function interfaces()
	t={}
--[[
	info = io.popen("/sbin/ifconfig 2>/dev/null | grep -A 1 'Link' | sed -e 's/ .* HWaddr//'")
	for linea in info:lines() do
		local ifname, ifmac = listtovars(linea,2)
		t[ifname]=ifmac
	end
	info:close()
	return t
]]--
	local info = io.popen("/sbin/ifconfig 2>/dev/null")
	local str = ""
	for line in info:lines() do
    if string.trim(line) == "" then
      t[#t+1] = str
      str = ""
    end
    str = str .. string.gsub(line,"\n", "")
  end
  for i=1, #t do
    _, _, iface, nada = string.find(t[i], "(.+)%s*Link(.*)")
    _, _, mac, nada = string.find(t[i], ".+ HWaddr%s(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)(.*)" )
    _, _, ip, nada = string.find(t[i], ".+ inet addr:(%d+.%d+.%d+.%d+)" )
    _, _, mask, nada =  string.find(t[i], ".+ Mask:(%d+.%d+.%d+.%d+)" )
    print(iface, mac, ip, mask)
  end
end

function networks()
  local t = {}
  local dev = ifname()
  local network = uciClass.new("network")
  for i=1, #network.sections do
    if network.sections[i].group == "interface" then
      if network.sections[i].values.ifname == nil then
        network.sections[i].values.ifname, dev = setdev(network.sections[i].values.ipaddr, dev)
      end
      for j,v in pairs(dev[network.sections[i].values.ifname]) do
        network.sections[i].values[j] = v
      end
      t[network.sections[i].name] = network.sections[i].values
    end
  end
  return t
end

function wireless()
  local t = {}
  local wifi = uciClass.new("wireless")
  for i=1, #wifi["wifi-iface"] do
    local device = wifi["wifi-iface"][i].values.device
    t[device]={}
    local dev = ifname(device)
    t[device]["mac"] = dev[device].mac
    t[device]["ipaddr"] = dev[device].ipaddr
    t[device]["netmask"] = dev[device].netmask
    t[device]["state"] = dev[device].state
    for k,v in pairs(wifi["wifi-iface"][i].values) do
      if k ~= device then
        t[device][k] = v
      end
    end
    for k,v in pairs(wifi[wifi["wifi-iface"][i].values.device]) do
      t[device][k] = v
    end
  end
  return t
end

function ifname(dev)
  if dev == nil then devname ="2>/dev/null"
  else devname = dev.." 2>/dev/null" end
	local t = {}
  local ret = {} 
  local info = io.popen("/sbin/ifconfig "..devname)
	local str = ""

	for line in info:lines() do
    if string.trim(line) == "" then
      t[#t+1] = str
      str = ""
    end
    str = str .. string.gsub(line,"\n", "")
  end

  for i=1, #t do
    local iface, mac, ip, mask, state
    iface = dev or string.trim(string.gsub(t[i],"(.+)%s*Link.*","%1"))
    if iface ~= "lo" then
      mac = string.match(t[i],".*Link.*HWaddr%s*(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)")
    end
    ip = string.match(t[i],".*inet addr:(%d+.%d+.%d+.%d+)")
    if ip then mask = string.match(t[i],".* Mask:(%d+.%d+.%d+.%d+)") end
    state = string.match(t[i],".*%s(%a+)%s.*%sRUNN.*")
    ret[iface] = {}
    ret[iface]["mac"] = mac
    ret[iface]["ipaddr"] = ip
    ret[iface]["netmask"] = mask
    ret[iface]["state"] = state
  end
  return ret
end

function setdev(ipaddr,dev)
  local dev = dev or ifname()
  for i,t in pairs(dev) do
    if t.ipaddr == ipaddr then
      return i, dev
    end
  end
  return nil, dev
end

function getipmask(device, dev)
  local dev = dev or ifname(device)
  return dev[device].ipaddr, dev[device].mask, dev
end

function getdev(lan)
  local lans = networks()
  for k,v in pairs(lans) do
    if k == lan then return v.ifname end
    if v.ifname == lan then return v.ifname end
  end
  return nil
end

function dev_list()
  wireless =uci.get_type("wireless","wifi-iface")
  local nets = {}
  for i=1, #wireless do
    local netname = wireless[i].device
    local t = uci.get_section("network",wireless[i].network)
    if t ~= nil then
      uci.check_set("network",wireless[i].network,"ifname",device)
      netname = t[".name"]
    end
    nets[netname] = wireless[i].device
  end
  networks = uci.get_type("network","interface")
  for i, t in pairs(networks) do
    if networks[i].type == "bridge" then
      nets[networks[i][".name"]] = "br-"..networks[i][".name"]
    else
      if nets[networks[i][".name"]] == nil then
        nets[networks[i][".name"]] = networks[i].ifname
      else
        if networks[i].ifname then
          if not string.match(networks[i].ifname,nets[networks[i][".name"]]) then
            nets[networks[i][".name"]] = networks[i].ifname .. nets[networks[i][".name"]]
          else
            nets[networks[i][".name"]] = networks[i].ifname
          end
        end
      end
    end 
  end
  return nets
end

return net