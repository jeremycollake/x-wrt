--------------------------------------------------------------------------------
-- lpkg.lua
--
-- Description: Manipulatin packages
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
lpkgClass = {} 
lpkgClass_mt = {__index = lpkgClass} 

function lpkgClass.new(str_pkgs)
  pkgs = str_pkgs or ""
	local self = {}
	self["RepoList"] = {}
	setmetatable(self,lpkgClass_mt)
	self["search"] = str_pkgs or ""
	self:init(self.search)
	return self
end 

function lpkgClass:init()
  local data = load_file("/usr/lib/ipkg/status")
  local co = coroutine.create (function (data)
      self:load(data)
    end)
  coroutine.resume(co,data)
  self:findrepo()
--  self:load(data,pkgs)
end

function lpkgClass:findrepo()
	local repos_set = io.open("/etc/ipkg.conf")
	for line in repos_set:lines() do
    _, _, reponame, url = string.find(line,"src%s([a-zA-Z0-9_-]+)%s(.*)")
    if reponame ~= nil then
      if self.RepoList[reponame] == nil then
        self.RepoList[reponame]={}
        self.RepoList[reponame]["url"] = url
      end
    end
  end
--  return repo
--[[
  
  local files = io.popen("ls /usr/lib/ipkg/lists")
  for file in files:lines() do
--    local data = load_file("/usr/lib/ipkg/lists/"..file)
    if self.RepoList[file] == nil then self.RepoList[file] = {} end
--      local co = coroutine.create (function (data,search,file)
--        self:load(data,search, file)
--      end)
--      coroutine.resume(co,data,self.search,file)
  end
]]--
end

function lpkgClass:loadRepo(str_repo)
  local data =""
  if str_repo == nil then
    self:findrepo()
  else
--      local co = coroutine.create(function (data)
    data = load_file("/usr/lib/ipkg/lists/"..str_repo)
--        end)
--      coroutine.resume(co)
    local da = coroutine.create (function (data,file)
        self:load(data, file)
      end)
    coroutine.resume(da,data,str_repo)
--    self:load(data, self.search, str_repo)
  end
end

function lpkgClass:load(data,str_repo)
  local repo = str_repo or "Installed"

--    self:processData(data,start,repo)
  local co = coroutine.create (function (data,search,repo)
      self:processData(data,search,repo)
      end)
  if repo == "Installed" then
    coroutine.resume(co,data,"",repo)
  elseif self.search == "" then
    coroutine.resume(co,data,self.search,repo)
  else    
    for search in string.gmatch(self.search,"%S+") do
      local co = coroutine.create (function (data,search,repo)
        self:processData(data,search,repo)
        end)
      local newdata = data
      local all = false
      if string.match(search,"*") then all = true end
      local mysearch = string.gsub(search,"*","")
      local start 
      if all == true then
        start = string.find(newdata,"Package: "..mysearch,1,true)
      else
        start = string.find(newdata,"Package: "..mysearch.."\n",1,true)
      end
      if start ~= nil then
        newdata = string.sub(newdata,start)
      end
--    print(search)
      coroutine.resume(co,newdata,search,repo)
    end
  end
end

function lpkgClass:processData(data,search,repo)
  local pkg, ver
  local co = coroutine.create (function (data,search,repo)
    local all = false
    if string.match(search,"*") then
      all = true
      search = string.gsub(search,"*","")
    end
    for line in string.gmatch(data,"[^\n]+") do
      local key, desc = unpack(string.split(line,":"))
      if string.trim(key) ~= "" then
        if key and desc == nil then
          desc = key
          key = "Description"
        end        
--        if key == "Description"
--        or key == "Package"
--        or key == "Version" then
        if key == "Package" then
          pkg = desc
          if search ~= "" and search ~= nil then
          if all == true then
            if search ~= string.sub(pkg,1,string.len(search)) then break end
          else
            if pkg ~= search then break end
          end
          end
          self[#self+1]={}
        elseif key == "Version" then
          ver = desc
        end
--        self[#self][key] = desc
        self:add(pkg,ver,repo,key,desc)
--          print (key,desc,"<br>")
--        end
      end
    end
  end )
  coroutine.resume(co,data,search,repo)
end

function lpkgClass:add(pkg,ver,repo,key,desc)
  if pkg == nil
  or ver == nil
  or repo == nil then return end
  if repo == "Installed" then
    if self[repo] == nil then self[repo] = {} end
    if self[repo][pkg] == nil then self[repo][pkg] = self[#self] end
  else
--    if self.Installed[pkg] ~= nil then return end
    if self.RepoList[repo] == nil then self.RepoList[repo] = {} end
    if self.RepoList[repo][pkg] == nil then self.RepoList[repo][pkg] = self[#self] end
  end
  if self[pkg] == nil then self[pkg] = {} end
  if self[pkg][repo] == nil then self[pkg][repo] = self[#self] end
--  if key == "Depends" and repo ~= "Installed" then
--    desc = string.gsub(desc,","," ")
--    for depend in string.gmatch(desc,"%S+") do
--      if self.Installed[depend] == nil then
--        self.search = self.search .. " " .. depend
--      end
--    end
--  end
  
  if key == "Description" then
    if self[#self]["Description"] == nil then
      self[#self]["Description"] = desc
    else
      self[#self]["Description"] = self[#self]["Description"]..desc
    end
  else
    self[#self][key] = desc 
  end
end
