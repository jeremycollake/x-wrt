#!/usr/bin/lua
--[[
--------------------------------------------------------------------------------
-- chillispot.sh
-- This script is writen in LUA, the extension is ".sh" for compatibilities
-- reasons width menu system of X-Wrt
--
-- Description:
--        Administrative console to Chillispot
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--         
-- Configuration files referenced:
--    hotspot
--
--------------------------------------------------------------------------------
--
--
-- config.lua 
-- LUA settings and load some functions files
-- 
]]--
dofile("/usr/lib/webif/LUA/config.lua")
require("files/olsr-menu")
page.title = "OLSR Status"
--page.__DOCTYPE = ""
page.form = ""
print(page:header())
pepe = io.popen([[wget -q -O - http://127.0.0.1:2006/]])
for line in pepe:lines() do
  if string.trim(line) == "Table: Links" then
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"8\">"..line.."</td></tr>")
  elseif string.trim(line) == "Table: Neighbors" then
    print ("</table>")
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"6\">"..line.."</td></tr>")
  elseif string.trim(line) == "Table: Topology" then
    print ("</table>")
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"5\">"..line.."</td></tr>")
  elseif string.trim(line) == "Table: HNA" then
    print ("</table>")
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"3\">"..line.."</td></tr>")
  elseif string.trim(line) == "Table: MID" then
    print ("</table>")
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"2\">"..line.."</td></tr>")
  elseif string.trim(line) == "Table: Routes" then
    print ("</table>")
    print ("<table border=\"1\">")
    print ("<tr><td colspan=\"5\">"..line.."</td></tr>")
  else
--    local t = string.gmatch(line,"^ ")
    print ("<tr>")
    for t in string.gmatch(line,"[^\t]+") do
      print("<td>",t,"<td>")
    end
    print ("</tr>")
  end
end
print ("</table>")
print(page:footer())