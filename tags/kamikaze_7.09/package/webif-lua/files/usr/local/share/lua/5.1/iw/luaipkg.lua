#!/usr/bin/lua
package.cpath = "?;./?.so;/usr/lib/lua/5.1/?.so" 
package.path = "?;./?.lua;/usr/local/share/lua/5.1/iw/?.lua;/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/lib/lua/5.1/?.lua" 
require("common")

function listpkgs(use_repo,use_version)
	local data = ""
	local repo = {}
	local repos_set = io.open("/etc/ipkg.conf")
	for line in repos:lines() do
    _, _, reponame, url = string.find(line,"src%s([a-zA-Z0-9_-]+)%s(.*)")
    if reponame ~= nil then 
      print(reponame,url)
      repo[reponame]=url
    end
  end
--[[  
  local files = io.popen("ls /usr/lib/ipkg/lists")
]]--
--[[
	for file in files:lines() do
		local data = load_file("/usr/lib/ipkg/lists/"..file)
		for line in string.gmatch(data,"[^\n]+") do
      print (line)
--     string.find(d, k,1,true) then
--					status[k] = true
--					break
--				end
--			end
		end
	end
]]--
end

function pkgs_load(use_repo,pkg_list)
	local data = load_file("/usr/lib/ipkg/lists/"..use_repo)
	local lastk = ""
	pkgs = {}

	local start = string.find(data,"Package: olsrd")
  if start ~= nil then
    data = string.sub(data,start) 
  	for line in string.gmatch(data,"[^\n]+") do
      _, _, k, v = string.find(line,"(%w+):%s(.*)")
      if k == "Package" then
        if not string.match(v,"olsrd") then break end
        pkgs[#pkgs+1] = {}
      end
    
      if k == nil then
        if line ~= nil then
          pkgs[#pkgs][lastk] = pkgs[#pkgs][lastk] .. line
        end
      else
        pkgs[#pkgs][k]=v
        lastk = k
      end
    end
	end
	for i=1, #pkgs do
    print(pkgs[i]["Package"],pkgs[i]["Version"])
  end
end

function repo_load()
	local repo = {}
	local repos_set = io.open("/etc/ipkg.conf")
	for line in repos_set:lines() do
    _, _, reponame, url = string.find(line,"src%s([a-zA-Z0-9_-]+)%s(.*)")
    if reponame ~= nil then 
      repo[reponame]=url
    end
  end
  return repo
end

function repo_list()
  for k, v in pairs(repo_load()) do
    print(k,v)
  end
end
   
local script = arg[0]
local cmd = arg[1]
for i=2, #arg do
  if string.match(arg[i],"-") then
    if arg[i] == "-r" then
      use_repo = arg[i+1]
      i = i + 1
    elseif arg[i] == "-v" then
      use_version = arg[i+1]
      i = i + 1
    end
  else 
    pkg_list[#pkg_list+1]=arg[i]
  end
end

if cmd == "list" then
  print("lista de packetes")
  print(use_repo)
  pkgs_load(use_repo,pkg_list)
elseif cmd == "repo_list" then
  print("Repository List")
  repo_list()
elseif cmd == "install" then
  print("install packages")
else
  print("help")
end