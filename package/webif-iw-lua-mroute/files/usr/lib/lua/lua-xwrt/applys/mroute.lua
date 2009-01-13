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

name = "M-Route"
script = "mroute"
init_script = "/etc/init.d/mroute"

enable = tonumber(uci.get("mroute.webadmin.enable")) or 0
local userlevel = tonumber(uci.get("mroute.webadmin.userlevel")) or 0
call_parser = nil
reboot = false                -- reboot device after all apply process
--exe_before = {} -- execute os process in this table before any process
exe_after  = {} -- execute os process after all apply process
--if radconf > 1 then
--	call_parser = "freeradius freeradius_check freeradius_clients freeradius_proxy"
--  exe_after["/etc/init.d/radiusd restart"]="freeradius"
--end
--depends_pkgs = "libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"
--exe_after["/etc/init.d/network restart"]="network"
--exe_after["wifi"]="wifi"
exe_after["/etc/init.d/firewall restart"]="firewallwifi"

-- depends_pkgs = "libltdl freeradius freeradius-mod-files freeradius-mod-chap freeradius-mod-radutmp freeradius-mod-realm iw-freeradius"

function process()
	wwwprint("Setting firewall")
	local lan_list = uci.get_type("mroute","lanif")
	local wan_list = uci.get_type("mroute","wanif")
	for l = 1, #lan_list do
		for w = 1, #wan_list do
			firewall.set_zone(wan_list[w][".name"],"REJECT","ACCEPT","REJECT","1")
			firewall.set_forwarding(lan_list[l][".name"],wan_list[w][".name"])
		end
	end
  uci.commit("mroute")
	uci.commit("firewall")
end

return parser
