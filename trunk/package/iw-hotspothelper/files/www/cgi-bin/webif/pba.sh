#!/usr/bin/lua
--[[
##WEBIF:name:IW:500:Pba
]]--
dofile("/usr/lib/webif/LUA/config.lua")
require("ucipkg")
print(uci.show("chilli"))
print("\nempieza a setear\n")
print("uci set chilli.interface=wlan")
print(uci.set("chilli.interface","wlan"))
print("uci set chilli.interface.device=wl0")
print(uci.set("chilli.interface.device","wl0"))
print("\n\n")
print(uci.show("chilli"))
print("\n\n")
print("uci add chilli algo")
juan = uci.add("chilli","algo")
print(juan,"\n")
print("uci.list(chilli,algo)")
pepe = uci.list("chilli","algo")
--for i=1, #pepe do
--  if pepe[i] ~= juan then
--    uci.del(pepe[i])
--  else
    uci.set(juan..".pendorcho",juan)
--  end
--end
uci.rename("chilli","cfg1",tostring(os.date()))
print("uci.show(chilli)")
print(uci.show("chilli"))
--uci.del("chilli.interface")
uci.commit("chilli")
print(uci.show("chilli"))
