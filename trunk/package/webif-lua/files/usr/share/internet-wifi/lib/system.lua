#!/usr/bin/lua
package.cpath = "?;./?.so;/usr/lib/lua/5.1/?.so" 
package.path = "?;./?.lua;/usr/local/share/lua/5.1/iw/?.lua;/usr/local/share/lua/5.1/iw/?;/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/lib/lua/5.1/?.lua" 
--[[
system = {}
local P = {}
system = P

-- Import Section:
-- declare everything this package needs from outside
local io = io
local print = print
local pairs = pairs
-- no more external access after this point
setfenv(1, P)
]]--
--function uptime()
	info = io.popen("ls /tmp")
	for linea in info:lines() do
	 print(linea)
--[[
		local i,e = string.find(linea,"load average: ")
		sys["loadavg"]=string.sub(linea,e)
		sys["uptime"]=string.sub(linea,11,i-2)
		local days, time, load_avg = listtovars(linea,3)
		days = string.gsub(days,"_"," ")
		sys["uptime"]=string.format("%s %s",days,time)
		sys["loadavg"]=load_avg
]]--
	end		
	info:close()
  for i, k in pairs(sys) do
    print(i,k)
  end
--end
