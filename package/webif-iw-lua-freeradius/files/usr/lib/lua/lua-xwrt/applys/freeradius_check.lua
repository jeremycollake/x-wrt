require("set_path")
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
local print = print
-- no more external access after this point
setfenv(1, P)

enable    = tonumber(uci.check_set("freeradius","webadmin","enable","1"))
userlevel = tonumber(uci.check_set("freeradius","webadmin","userlevel","1"))
reboot    = false                -- reboot device after all apply process
call_parser = "freeradius freeradius_clients freeradius_proxy"

name = "Freeradius Users"
script = "radiusd"
init_script = "/etc/init.d/radiusd"

function process()
	uci.commit("freeradius_check")
	uci.commit("freeradius_reply")
  if tonumber(uci.get("freeradius","webadmin","userlevel")) < 4 then
    wwwprint ("Writing users...<br>")
-- Process users
	  local user_str = ""
  	local sep = ""
		local users = {}
		if uci.get_section("freeradius_check","default")
		or uci.get_section("freeradius_reply","default")
		then users["default"] = "DEFAULT" end

		for i,t in pairs(uci.get_type("freeradius_check","user")) do
			users[t[".name"]] = t[".name"]
		end 

		for i,t in pairs(uci.get_type("freeradius_reply","user")) do
			users[t[".name"]] = t[".name"] 
		end 
	
		for name, n in pairs(users) do
			user_str = user_str..sep..n
			sep = "\t"
			for k,v in pairs(uci.get_section("freeradius_check",name)) do
				if not string.match(k,"[.]") then
      		if string.trim(k) == "User_Password" then
        		user_str = user_str..sep.. string.gsub(k,"_","-").." := \""..v.."\""
      		else
        		user_str = user_str..sep.. string.gsub(k,"_","-").." := "..v
      		end
      		sep = ", "
				end
			end
			sep = "\n\t"
			for k,v in pairs(uci.get_section("freeradius_reply",name)) do
				if not string.match(k,"[.]") then
					user_str = user_str .. sep.. string.gsub(k,"_","-").." = "..v
    	    sep = ",\n\t"
				end
			end
			sep = "\n\n"
		end
    local pepe = io.open("/etc/freeradius/users","w")
    pepe:write(user_str)
    pepe:close()
  end
end
