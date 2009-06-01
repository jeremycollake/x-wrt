--[[
	firewall handle functions
 	Copyright (C) 2008 Fabian Omar Franzotti <fofware@gmail.com>	
	
	functions:
		set_zone(zone,input,output,forward,masq)
			input, output, forward, masq can be nil
			this function create or modify the values of zone

		delete_zone(zone)
			this function delete zones and all forwardings to this zone name

		set_forwarding(src,dest)
			this functin create forwarding

		delete_forwarding(src,dest)
			this function delete forwarding

		set_rule(name, src, src_ip, src_mac, src_port, dest, dest_ip, dest_port, proto, target)
			this functin create rule

		set_redirect(args)
			this functin create rule
			args=	{name=".....", src="....", src_ip=".....", src_mac=".....", src_port="....", 
						 src_dport=".....", dest_ip=".....", dest_port=".....", proto="....."
						}
			return name_of_uci_section	if create or modify redirect
						 nil									if redirect have a multiple matches, need more parameters
		get_name(f_type, args)
			this function find uci name
			args is a table {	src="....", src_ip="....", src_mac="....", 
												src_port=".....", src_dport="....", dest="....", 
												dest_ip="....", dest_port="....", proto="....."}
			returns name_of_uci_section if have a single match
							"duplicate"					if have multiple matches
							nil 								if have not matches
]]--
require("uci_iwaddon")
require("common")

firewall = {}
local P = {}
firewall = P
-- Import Section:
-- declare everything this package needs from outside
local print = print
local pairs = pairs
local uci = uci
local string = string
 
-- no more external access after this point
setfenv(1, P)

function reset()
	uci.save("firewall")
	all = {}
	zones = {}
	rules = {}
	redirects = {}
	forwardings = {}
	defaults = {}
	all = uci.get_all("firewall")
	for i,t in pairs(all) do
		if t[".type"] == "zone" then
			zones[t.name] = i
		end
		if t[".type"] == "forwarding" then
			if forwardings[t.src] == nil then forwardings[t.src] = {} end
			forwardings[t.src][t.dest] = i
		end
		if t[".type"] == "rule" then
			if rules[i] == nil then rules[i] = {} end
			rules[i] = t
		end
		if t[".type"] == "redirect" then
			if redirects[i] == nil then redirects[i] = {} end
			redirects[i] = t
		end
		if t[".type"] == "defaults" then
			defaults = t
		end
	end
end

function check_valid_value(val)
	local val = has_value(val)
	if val == nil then return nil end
	if val then
		val = string.trim(val)
		if val ~= "ACCEPT"
		or val ~= "REJECT"
		or val ~= "DROP" then
			val = nil
		end
	end
	return val
end
		 
function has_value(val)
	local val = val
	if val == nil then return nil end
	val = string.trim(val)
	if val == "" then val = nil end
	return val
end
		 
function zone(zone)
	local zone = has_value(zone)
	if zone then
		return zones[zone]
	else
		return zones
	end
end

function set_zone(zone,input,output,forward,masq)
	local cfgret = nil
	local zone = has_value(zone)
	if zone then
		networks = uci.get_all("network")
		if networks[zone] == nil then 
--			print(zone," Not found")
			return nil
		end
		local input = check_valid_value(input)
		local output = check_valid_value(output)
		local forward = check_valid_value(forward)
		if string.trim(masq) == "" then masq = nil end
		
		if zones[zone] then
			cfgret = zones[zone]
			input = input or uci.get("firewall",cfgret,"input")
			output = output or uci.get("firewall",cfgret,"output")
			forward = forward or uci.get("firewall",cfgret,"forward")
			masq = masq or uci.get("firewall",cfgret,"masq")
		else
			input = input or defaults.input
			output = output or defaults.output
			forward = forward or defaults.forward
			masq = masq or defaults.masq
			cfgret = uci.add("firewall","zone")
		end
		if cfgret then
			uci.set("firewall",cfgret,"name",zone)
			uci.set("firewall",cfgret,"input",input)
			uci.set("firewall",cfgret,"output",output)
			uci.set("firewall",cfgret,"forward",forward)
			if masq then uci.set("firewall",cfgret,"masq",masq) end
			reset()
		end
	end
	return cfgret
end

function delete_zone(zone)
	local zone = has_value(zone)
	ret = false
	if zone then
		if forwardings then
			for i,t in pairs(forwardings) do
				for k,cfg in pairs(t) do
					if i == zone
					or k == zone then
						uci.delete("firewall",cfg)
					end
				end
			end
		end 
		if zones[zone] then			
			ret = uci.delete("firewall",zones[zone])
			reset()
		end
	end
	return ret
end

function forwarding(src,dest)
	local src = has_value(src)
	local dest = has_value(dest)
	if src then
		if dest then
			return forwardings[src][dest]
		else
			return forwardings[src]
		end
	else
		return forwardings
	end
end

function set_forwarding(src,dest)
	cfgret = nil
	local src = has_value(src)
	local dest = has_value(dest)
--	print(src, dest)
	if src and dest then
		set_zone(src)
		set_zone(dest)
		if forwardings[src] and forwardings[src][dest] then
--			print("dice que existe")
			cfgret = forwardings[src][dest]
		else
--			print("set_zone ",src)
--			print("set_zone ",dest)
			cfgret = uci.add("firewall","forwarding")
			if cfgret then
				uci.set("firewall",cfgret,"src",src)
				uci.set("firewall",cfgret,"dest",dest)
				reset()
			end
		end
	end
	return cfgret
end

function delete_forwarding(src,dest)
	local ret = false
	local src = has_value(src)
	local dest = has_value(dest)
	if src and dest then
		if forwardings[src][dest] then
			ret = uci.delete("firewall",forwardings[src][dest])
			reset()
		end
	end
	return ret
end

function get_name(f_type,a)
	local tfind = {}
	local f_type=f_type
	local src=a.src
	local src_ip=a.src_ip
	local src_mac=a.src_mac
	local src_port=a.src_port
	local src_dport=a.src_dport
	local dest_ip=a.dest_ip
	local dest_port=a.dest_port
	local proto=a.proto
	local search = ""
	for k,v in pairs(a) do
		search = search..k.."="..v.." "
	end
--	print(f_type, search)
	if f_type == "forwarding" then
		if forwardings[a.src] == nil then return nil end
		return forwardings[a.src][a.dest]
	elseif f_type == "rule" then
		tfind = rules
	elseif f_type == "redirect" then
		tfind = redirects
	else
		tfind = all
	end

	local cnt=0
	local name=nil
	for nm, tf in pairs(tfind) do
		local ok=true
		for k, v in pairs(a) do
			if k ~= "name" then
				if has_value(tf[k])~=has_value(v) then ok=false end
			end
		end
		if ok == true then
			cnt=cnt+1
			name=nm
		end
	end
	if cnt > 1 then name = "duplicate" end
	return name
end

function set_redirect(a)
	return set_firewall("redirect", redirects, a)
end

function set_rule(a)
--print("set_rule")
	return set_firewall("rule", rules, a)
end

function set_firewall(f_type,t_find,a)
	local f_type = f_type
	local t_find = t_find
	local exists = false
	local name = get_name(f_type,a)
	if name == "duplicate" then return nil end
	if name ~= nil then exists = true end
	a.name = has_value(a.name)

	if exists == true then
		if a.name == nil then a.name = name
		elseif a.name ~= name then 
--print("uci.rename")
			uci.rename("firewall",name,a.name) 
		end
	else
		if a.name == nil then 
--print("uci.add")
			a.name = uci.add("firewall",f_type)
		else 
--print("uci.set")
			uci.set("firewall",a.name,f_type)
		end
	end
	
	if exists == true then
		for op, vl in pairs(t_find[name]) do
--print(op, vl)
			if a[op] == nil then
				uci.delete("firewall",a.name,op)
			end
		end
	end

	for op, vl in pairs(a) do
		if op ~= "name" then
--print(a.name,op,vl)
			uci.isdiff_set("firewall",a.name,op,vl)
		end
	end
	reset()

	return a.name
end
-- defaults --
all = {}
zones = {}
rules = {}
redirects = {}
forwardings = {}
defaults = {}
reset()

return firewall