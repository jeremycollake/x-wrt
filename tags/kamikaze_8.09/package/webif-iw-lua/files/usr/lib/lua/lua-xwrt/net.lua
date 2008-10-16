--[[
    Network package
    Availables functions

]]--
require("uci_iwaddon")
require("common")

net = {}
local P = {}
net = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local assert = assert
local string = string

-- local __UCI_VERSION = __UCI_VERSION
local pairs = pairs
local listtovars = listtovars
local uci = uci
local print = print
local tonumber = tonumber

-- no more external access after this point
setfenv(1, P)

function resolv()
  local dnss = io.totable("/etc/resolv.conf")
  local t = {}
  for i,v in pairs(dnss) do
    local dns, res = string.gsub(v,"nameserver ","")
    if res == 1 then
      t[#t+1] = dns
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

local devices = ifname()

function ifconfig(dev)
  if dev then
    return devices[dev]
  end
  return devices
end

function ipcalc(ip,mask,start,num)
  local getcalc
  if ip ~= nil 
  and mask ~= nil
  and start ~= nil
  and num ~= nil then
    getcalc = io.popen("/bin/ipcalc.sh "..ip.." "..mask.." "..start.." "..num)
  elseif ip ~= nil
  and mask ~= nil
  and start ~= nil then
    getcalc = io.popen("/bin/ipcalc.sh "..ip.." "..mask.." "..start)
  elseif ip ~= nil
  and mask ~= nil then
    getcalc = io.popen("/bin/ipcalc.sh "..ip.." "..mask)
  else
    return nil
  end

  local t = {}

  if getcalc then   
    for line in getcalc:lines() do
      local i = string.find(line,"=")
      local key = string.sub(line,1,i-1)
      local value = string.sub(line,i+1)
      t[key]=value
    end
    getcalc:close()
  else 
    t = nil
  end
  return t
end


-- Table of availables NIC
function interfaces()
  t={}
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
  local dev = devices
  local network = uci.get_type("network","interface")
  for i=1, #network do
    if network[i].ifname == nil then
      network[i].ifname, dev = setdev(network[i].ipaddr, dev)
    end
--    for j,v in pairs(dev[network[i].ifname]) do
--      network[i][j] = v
--    end
    t[network[i][".name"]] = network[i]
  end
  return t
end

function wireless()
  local t = {}
  local wifi = uci.get_type("wireless","wifi-iface")
  local wall = uci.get_all("wireless")
  for i=1, #wifi do
    local device = wifi[i].device
    t[device]={}
    for k,v in pairs(wifi[i]) do
      if not string.match(k,"[.]") then
        t[device][k] = v
      end
    end
    for k,v in pairs(wall[device]) do
      if not string.match(k,"[.]") then
        t[device][k] = v
      end
    end
    local dev = devices[device]
    if dev then
      t[device]["mac"] = dev.mac
      t[device]["ipaddr"] = dev.ipaddr
      t[device]["netmask"] = dev.netmask
      t[device]["state"] = dev.state
    end
  end
  return t
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

function getipmask(lan)
--  local dev = ifname(lan)
--  return dev[lan].ipaddr, dev[lan].mask, dev
  return devices[lan].ipaddr, devices[lan].netmask
end

function getdev(lan)
  local lans = networks()
  for k,v in pairs(lans) do
    if k == lan then return v.ifname end
    if v.ifname == lan then return v.ifname end
  end
  return nil
end

function invert_dev_list()
  local nets = dev_list()
  local t = {}
  for k, v in pairs(nets) do
    t[v]=k
  end
  return t
end

function dev_list()
  local wirelessif =uci.get_type("wireless","wifi-iface")
  local nets = {}
  for i=1, #wirelessif do
    local netname = wirelessif[i].device
    local t = uci.get_section("network",wirelessif[i].network)
    if t ~= nil then
      uci.check_set("network",wirelessif[i].network,"ifname",device)
      netname = t[".name"]
    end
    nets[netname] = wirelessif[i].device
  end
  local networks = uci.get_type("network","interface")
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

function other_ip(tnet,iflan)
	repeat 
		local ip = string.split(tnet.IP,".")
		local mask = string.split(tnet.NETMASK,".")
		local idx = 3
		for i=3,1,-1 do
			if tonumber(mask[i]) ~= 0 then 
				idx = i 
				break
			end 
		end
		ip[idx] = tonumber(ip[idx])+1
		if ip[idx] > 254 then ip[idx] = 1 end
		local newip = ""
		local sep = ""
		for i = 1, 4 do
			newip = newip..sep..ip[i]
			sep = "."
		end

		tnet = ipcalc(newip,tnet.NETMASK)
		local ok = check_dup_ip(tnet,iflan)
	until ok == true
	return tnet
end

function check_dup_ip(tnet,iflan)
	local ok = true
	local tifaces = {}
	for i, t in pairs(ifconfig()) do
		if t.ipaddr 
		and t.ipaddr ~= "127.0.0.1" 
		and i ~= iflan
		and i ~= "br-"..iflan
		then
			tifaces[#tifaces+1] = {}
			local tif = ipcalc(t.ipaddr,t.netmask)
			tifaces[#tifaces]["name"] = i
			tifaces[#tifaces]["ipaddr"] = t.ipaddr
			tifaces[#tifaces]["netmask"] = t.netmask
			tifaces[#tifaces]["NETWORK"] = tif.NETWORK
		end
	end
	for i=1, #tifaces do
		if tifaces[i].NETWORK == tnet.NETWORK then
			ok = false
			break
		end
	end
	return ok
end

function get_unique_ip(ip,mask,iflan)
	if ip == nil or ip == "" then
		ip = "10.11.0.1"
	end
	if mask == nil or mask == "" then
		mask = "255.255.255.0"
	end
	tnet = ipcalc(ip,mask)

	if check_dup_ip(tnet,iflan) == false then
		tnet = other_ip(tnet,iflan)
	end
	return tnet
end

return net