#!/usr/bin/lua
require("init")
require("webpkg")
pkg.check("algo iw-chillispot iw-freeradius olsrd-mod-dot-draw freeradius-mod-chap") 
--[[
print(page:header())
for i, v in pairs(__FORM) do
  print(i,v,"<br>")
end
print(page:footer())  
]]--
--pkg.check("iw-freeradius,olsrd-mod-dot-draw")
--print("Hola")
--print("Hola")