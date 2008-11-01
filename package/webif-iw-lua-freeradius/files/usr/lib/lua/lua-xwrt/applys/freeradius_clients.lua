--require("iw-uci")
--require("iwuci")
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
--local iwuci = iwuci
--local uciClass = uciClass
local tonumber = tonumber
local uci = uci

local freeradius = uciClass.new("freeradius")
-- no more external access after this point
setfenv(1, P)

enable    = tonumber(freeradius.webadmin.enable)    or 0
userlevel = tonumber(freeradius.webadmin.userlevel) or 0
reboot    = false                -- reboot device after all apply process

call_parser = "freeradius freeradius_check freeradius_proxy"

name = "Freeradius Clients"
script = "radiusd"
init_script = "/etc/init.d/radiusd"

function process()
  uci.commit("freeradius_clients")
  -- Process clients.conf
		local config = uci.get_all("freeradius_clients")
		local client_str = ""
		local sep = "\n"
		for i,t in pairs(config) do
			if i ~= "system" then
				client_str = client_str .."client "..(t.client).." {"
				for k,v in pairs(t) do
					if not string.match(k,"[.]")
					and k ~= "client"
					then
						client_str = client_str .. sep .. k .. "=" .. v
--						print("",k,v)
					end
				end
				client_str = client_str .. sep .. "}\n"
			end
		end
    local pepe = io.open("/etc/freeradius/clients.conf","w")
    pepe:write(client_str)
    pepe:close()
end
