#!/usr/bin/lua
require("set_path")
require("init")
require("uci_iwaddon")
require("firewall")


for i, t in pairs(firewall.forwardings) do
	print(i,t)
	for k, v in pairs(t) do
		print("",k,v)
	end
end


print("")
print( firewall.get_name("forwarding", {src="lan", dest="wan"}) )
print("")
print("DMZ")
print( firewall.get_name("redirect", {src="wan", dest="lan",dest_ip="192.168.16.235"}) )

print("")
print("DMZ")
print( firewall.get_name("redirect", {src="wan1", dest="lan",dest_ip="192.168.16.235"}) )


print("")
firewall.set_rule{name="OLSR",src="wifi", src_port=968, dest_port=968, proto="udp"}
print("OLSR")
print( firewall.get_name("rule", {name="OLSR",src="wifi", src_port=968, dest_port=968, proto="udp"}) )

print("")
print("SSH")
print( firewall.get_name("rule", {src="wan", dest_port=22, proto="tcp"}) )

print("")
print("HTTP1")
print( firewall.get_name("rule", {src="wan2", proto="tcp", dest_port=80}) )

print("")
print("coso")
algo = firewall.set_rule({src="wan2", proto="tcp", dest_port=80})
print(algo)

print("")
print("HTTP")
print( firewall.get_name("rule", {src="wan2", proto="tcp", dest_port=80}) )
--[[
for i, t in pairs(firewall.all) do
	print(i,t)
	for k, v in pairs(t) do
		print("",k,v)
	end
end
]]--