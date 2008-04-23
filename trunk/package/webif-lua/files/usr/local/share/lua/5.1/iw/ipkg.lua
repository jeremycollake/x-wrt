require ("checkpkg")

ipkg = {}
local P = {}
ipkg = P

-- Import Section:
-- declare everything this package needs from outside
local __WWW = __WWW
local load_file = load_file
local os = os
local io = io
local print = print
local string = string
local table = table
local pkgInstalledClass = pkgInstalledClass
local page = page
local __MENU = __MENU

-- no more external access after this point
setfenv(1, P)

function check(pkg_list)
  local t = {}
  if pkg_list == nil
  or pkg_list == "" then return end
  local installed, f = load_file("/usr/lib/ipkg/status")
  if f == false then
    print("Error: /usr/lib/ipkg/statuss - Not Found") 
    os.exit(1) end
  for pkg in string.gmatch(pkg_list,"[^,]+") do
    if not string.find(installed,"Package: "..pkg,1,true) then
      t[#t+1]=pkg
    end
  end
  if #t > 0 then
    return table.concat(t,",")
  end
  return ""
end

function install(pkg_list)
  if pkg_list == nil
  or pkg_list == "" then return end
  if __WWW then webInstall(pkg_list)
  else consoleInstall(pkg_list) end
end

function consoleInstall(pkg_list)
  print("This packages must be instaled:")
  for pkg in string.gmatch(pkg_list,"[^,]+") do
    print("\t",pkg)
  end
  io.write("Do you want install they? [Y,N]")
  local rspta = io.stdin:read()
  if string.upper(rspta) == "Y" then
    return true
  else 
    return false
  end 
end

function webInstall(pkg_list)
  local pepep = pkgInstalledClass.new(pkg_list,true)
--  print(page:header())
--  print(page:footer())
end