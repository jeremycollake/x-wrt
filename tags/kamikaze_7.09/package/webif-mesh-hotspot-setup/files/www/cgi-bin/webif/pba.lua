#!/usr/bin/lua
require("init")
require("webpkg")
print(page:header())
pkg.check("iw-chillispot iw-freeradius olsrd-mod-dot-draw")
--pkg.check("iw-freeradius,olsrd-mod-dot-draw")
print("Hola")