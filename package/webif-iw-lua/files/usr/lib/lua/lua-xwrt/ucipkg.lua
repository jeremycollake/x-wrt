--[[
    Availables functions
    uci.show [<package>[.<config>] ]
    uci.get <package>.<config>.<option>
    uci.set <package>.<config>[.<option>]=<value>
    uci.del <package>.<config>[.<option>]
    uci.rename <package> <config> <name>
    uci.commit [<package> ... ]

]]--
uci = {}
local P = {}
uci = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local uciClass = uciClass
local assert = assert
local string = string
local __UCI_VERSION = __UCI_VERSION
 
-- no more external access after this point
setfenv(1, P)

function get(varname)
  local myuci = io.popen("uci get "..varname)
  local str = ""
  for res in myuci:lines() do
    io.write(res.."\n")
    str = str ..res.."<br>\n"
  end
  return str
end

function del(varname)
--  os.execute("uci del "..varname)
  local myuci = io.popen("uci del "..varname)
  local str = ""
  for res in myuci:lines() do
    io.write(res.."\n")
    str = str ..res.."<br>\n"
  end
  return str
end

function set(varname,value)
--  os.execute("uci set "..varname.."="..value)
  local myuci = io.popen("uci set "..varname.."="..value)
  local str = ""
  for res in myuci:lines() do
    io.write(res.."\n")
    str = str ..res.."<br>\n"
  end
  return str
end

function add(pkg,conf,opt)
  local myuci = nil
  if __UCI_VERSION == nil then	
    if opt == neil or opt == "" then
      local myuci = uciClass.new(pkg)
      opt="cfg"..#myuci.sections+1
      assert(os.execute("mkdir /tmp/.uci > /dev/null 2>&1"))
		  os.execute("echo \"config '"..conf.."'\" >>/tmp/.uci/"..pkg)
		else
		  uci.set(pkg.."."..conf,opt)
		end
  else
    if opt == "" then
      myuci = io.popen("uci add "..pkg.." "..grp)
      for res in myuci:lines() do
        opt = res
      end
    else
      os.execute("uci set "..pkg.."."..conf.."="..opt.." > /dev/null 2>&1")
    end
  end
  return pkg.."."..opt
end

function show(varname)
  local myuci = io.popen("uci show "..varname)
  local str = ""
  for res in myuci:lines() do
--    io.write(res.."\n")
    str = str ..res.."\n"
  end
  return str
end

function list(pkg,opt)
  local myuci = io.popen("uci show "..pkg)
  local str = {}
  for res in myuci:lines() do
--    io.write(res.."\n")
    if string.match(res,opt) then
      res = string.gsub(res,"(.+)[=](%a+)","%1")
      str[#str+1] = res
    end
  end
  return str
end

function commit(pkg)
  os.execute("uci commit "..pkg)
--  os.execute("rm /tmp/.uci/"..pkg)
  os.execute("rm /tmp/.uci/"..pkg..".lock")
end

function rename(pkg,config,name)
  os.execute("uci rename "..pkg.." "..config.." "..name)
end

return uci