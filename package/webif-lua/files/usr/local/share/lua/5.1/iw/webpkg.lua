require("iw-luaipkg")
require("common")
pkg = {}
local P = {}
pkg = P
-- Import Section:
-- declare everything this package needs from outside
--local lpkgClass = lpkgClass
local pairsByKeys = pairsByKeys
local print = print
local pairs = pairs
local string = string
  local lpkg = lpkgClass.new()

-- no more external access after this point
setfenv(1, P)

function check(pkg_list)
  if pkg_list == nil
  or pkg_list == "" then return end
  local new_pkg_list = ""
  for search in string.gmatch(pkg_list,"%S+") do
    if lpkg.__installed[search] == nil then
      if lpkg.search == "" then 
        lpkg.search = search
      else 
        lpkg.search = lpkg.search.." "..search 
      end
    end
  end
  
  to_install()
end

function to_install()
--  print(lpkg.search)
  lpkg:loadRepo_list()
--  for i,v in pairs(lpkg.__repo) do
--    print(i,v)
--  end
  print(lpkg.search,"<br>")
  for p in string.gmatch(lpkg.search,"%S+") do
    if lpkg[p] ~= nil then
      for version,t in pairsByKeys(lpkg[p]) do
        print(p,version)
        for repository,v in pairsByKeys(t) do 
          print(repository,"<br>") 
        end 
      end
    else
      print(p,"not found!!!<br>")
    end
  end  
end
