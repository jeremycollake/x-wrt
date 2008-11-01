require("uci_iwaddon")

parser = {}
local P = {}
parser = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local wwwprint = wwwprint
if wwwprint == nil then wwwprint=print end
local oldprint = oldprint
local table = table
local type = type
local string = string
local pairs = pairs
local tonumber = tonumber
local uci = uci
-- no more external access after this point
setfenv(1, P)

enable    = tonumber(uci.check_set("freeradius","webadmin","enable","1"))
userlevel = tonumber(uci.check_set("freeradius","webadmin","userlevel","1"))
reboot    = false                -- reboot device after all apply process

call_parser = "freeradius freeradius_check freeradius_clients"

name = "Freeradius Proxy"
script = "radiusd"
init_script = "/etc/init.d/radiusd"

function process()
  wwwprint(name.." Parsers...")
  uci.commit("freeradius_proxy")
  wwwprint ("Writing proxy.conf ...")
  -- Process proxy.conf
		local config = uci.get_type("freeradius_proxy","server")
		local proxy_str = ""
		local sep = "\n"
		for i, t in pairs(config) do
			proxy_str = "proxy server {"
			sep = "\n"
			for k,v in pairs(t) do
				if not string.match(k,"[.]") then
					proxy_str = proxy_str .. sep .. k .. "=" .. v
				end
			end
			proxy_str = proxy_str .. sep .."}\n\n" 
		end

		config = uci.get_type("freeradius_proxy","realm")
		for i, t in pairs(config) do
			proxy_str = proxy_str.."realm "..t["community"].." {"
			sep = "\n"
			for k,v in pairs(t) do
				if not string.match(k,"[.]")
				and k ~= "community" 
				then
					proxy_str = proxy_str .. sep .. k .. "=" .. v
				end
			end
			proxy_str = proxy_str .. sep .."}\n\n" 
		end
    local pepe = io.open("/etc/freeradius/proxy.conf","w")
    pepe:write(proxy_str)
    pepe:close()
  wwwprint("/etc/freeradius/proxy.conf writed OK!")
end

return parser
