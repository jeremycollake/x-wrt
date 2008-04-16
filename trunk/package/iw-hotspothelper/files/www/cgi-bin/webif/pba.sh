#!/usr/bin/lua
--[[
##WEBIF:name:IW:500:Pba
]]--
-- dofile("/usr/lib/webif/LUA/config.lua")
package.cpath = "./?.so;/usr/lib/lua/5.1/?.so" 
package.path = "./?.lua;/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua" 
require("uci")
pepe = uci.load("pba")
pepe = uci.set("pba=pepe")
print ("pba=pepe", type(pepe),tostring(pepe))
pepe = uci.set("pba.algo=pepe")
print ("pba.algo=pepe", type(pepe),tostring(pepe),uci.get("pba.algo"))

pepe = uci.set("pba.algo.uno=primero")
print ("pba.algo.uno=primero", type(pepe),tostring(pepe),uci.get("pba.algo.uno"))

--[[
print("Hola mundo")

for k, v in pairs(package) do
  print (k,v)
end
]]--
