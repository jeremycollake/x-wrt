#!/usr/bin/lua
--------------------------------------------------------------------------------
-- xwrt-apply.lua
--
-- Description:
--       
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--         
-- Configuration files referenced:
--    all
--
--------------------------------------------------------------------------------
package.path = package.path .. ";/usr/lib/webif/LUA/?.lua;/usr/share//lua/5.1/?.lua"
__UCI_CMD = {}
__TOCHECK = {}
__RESTART = {}
-- Common Functions
require("common")
require("uciUpdated")
__SYSTEM  = loadsystemconf()
require("translator")
tr_load()
self = uciUpdatedClass.new()
require("uci")

--pepe = uciClass.new("freeradius")
  local handler_list = {}
  handler_dir = io.popen("ls /usr/lib/webif/apply")
  for line in handler_dir:lines() do
    handler_list[#handler_list+1] = line
  end
  for k,t in pairsByKeys(self) do
    if type(t) == "table" then
      local found = false
      for i = 1, #handler_list do
        if handler_list[i] == k then
          print (k)
          found = true
          dofile("/usr/lib/webif/apply/"..k)
          break
        end
      end
		end
	end
	for i, t in pairs(__RESTART) do 
    print("Restarting...<br>")
    local ucifile = uciClass.new(t.pkg)
    if ucifile[t.cfg][t.opt] == "1" then
      local myexec = io.popen(t.init.." enable")
      print ("Enabling "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
--  print("<br>")
      myexec = io.popen(t.init.." stop")
      print ("Stopping "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
--  print("<br>")
      myexec = io.popen(t.init.." start")
      print ("Starting "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
    else
      myexec = io.popen(t.init.." stop")
      print ("Stopping "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
      local myexec = io.popen(t.init.." disable")
      print ("Disabling "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
    end
  end
