lpkgClass = {} 
lpkgClass_mt = {__index = lpkgClass} 

function lpkgClass.new(str_pkgs)
	local self = {}
	setmetatable(self,lpkgClass_mt)
	self.__repo = {}
	self.__installed = {}
  self.__toinstall = {}
	self.search = str_pkgs
	return self
end 


function lpkgClass:repos()
	local repos_set = load_file("/etc/ipkg.conf")
	for line in string.gmatch(repos_set,"[^\n]+") do
    _, _, reponame, url = string.find(line,"src%s([a-zA-Z0-9_-]+)%s(.*)")
    if reponame ~= nil then
      if self.__repo[reponame] == nil then
        self.__repo[reponame] = {}
        self.__repo[reponame]["url"] = url
        self.__repo[reponame]["pkgs"] = {}
      end
    end
  end
end

function lpkgClass:installed()
	local installed_set = load_file("/usr/lib/ipkg/status")
  self:process_pkgs_file(installed_set)
end

function lpkgClass:load_repo(str_repo)
  data = load_file("/usr/lib/ipkg/lists/"..str_repo)
  if self.search then
    self:do_process(self.search,data,str_repo)
    self:do_process(self.depend,data,str_repo)
  else
    self:process_pkgs_file(newdata,"",str_repo)
  end
end

function lpkgClass:do_process(str_search,data,str_repo)
  if str_search == nil then return end
    for search in string.gmatch(str_search,"%S+") do
--      print(search)
      local mysearch = string.gsub(search,"*","")
      local newdata = data
      if string.match(search,"*") then
        start = string.find(newdata,"Package: "..mysearch,1,true)
      else
        start = string.find(newdata,"Package: "..mysearch.."\n",1,true)
      end
      if start ~= nil then
        newdata = string.sub(newdata,start)
      end
      self:process_pkgs_file(newdata,search,str_repo)
--      print(self.depend)
    end
end

function lpkgClass:process_pkgs_file(data,search,repo)
  local pkg = ""
  local ver = ""
  local repo = repo or "inst"
  local all = nil
  if search then
    if string.match(search,"*") then
      all = true
      search = string.gsub(search,"*","")
    else
      all = false
    end
  end
  local tidx = nil
	for line in string.gmatch(data,"[^\n]+") do
    local key, desc = unpack(string.split(line,":"))
    if string.trim(key) ~= "" then
      if key and desc == nil then
        desc = key
        key = "Description"
      end        
      if key == "Package" then
       tidx = nil
       pkg = desc
        if search ~= "" and search ~= nil then
          if all == true then
            if search ~= string.sub(pkg,1,string.len(search)) then break end
          else
            if pkg ~= search then break end
          end
        end
      elseif key == "Version" then
        ver = desc
        if self[pkg] ~= nil then
          if self[pkg][ver] ~= nil then
            tidx = self[pkg][ver]
          else
            self[#self+1] = {}
            tidx = self[#self]
          end
        else
          self[#self+1] = {}
          tidx = self[#self]
        end
      end
      self:add(tidx,pkg,ver,repo,key,desc)
    end
  end
end

function lpkgClass:add(tidx,pkg,ver,repo,key,desc)
  if pkg == nil
  or ver == nil
  or repo == nil 
  or tidx == nil
  then return end
  if self[pkg] == nil then self[pkg] = {} end
  if self[pkg][ver] == nil then self[pkg][ver] = tidx end
  if repo == "inst" then
    if self.__installed[pkg] == nil then self.__installed[pkg] = tidx end
  else
    if self.__installed[pkg] == nil then
      if self.__toinstall[pkg] == nil then
        tidx["url"] = self.__repo[repo].url
        self.__toinstall[pkg] = tidx
      else
        if self.__toinstall[pkg].Version < ver then
          tidx["url"] = self.__repo[repo].url
          self.__toinstall[pkg] = tidx
        end
      end
    end
    if self.__repo[repo].pkgs[pkg] == nil then self.__repo[repo].pkgs[pkg] = tidx end
  end
  if key == "Depends" and repo ~= "inst" then
      self:check_depends(desc)
  end
  if key == "Description" then
    if tidx["Description"] == nil then
      tidx["Description"] = desc
    else
      tidx["Description"] = tidx["Description"]..desc
    end
  else
    tidx["Package"] = pkg
    tidx[key] = desc 
  end
end

function lpkgClass:check_depends(str)
  local str = string.gsub(str,","," ")
  local found = false
  for addsearch in string.gmatch(str,"%S+") do
    if self.__installed[addsearch] == nil then
      local found = false
      for search in string.gmatch(self.search,"%S+") do
        if search == addsearch then
          found = true
          break
        end
      end
      if found == false then
        if self.depend then
          found = false
          for search in string.gmatch(self.depend,"%S+") do
            if search == addsearch then
              found = true
              break
            end
          end
        end
        if found == false then
          if self.depend == nil then self.depend = addsearch
          else self.depend = self.depend .. " " .. addsearch end
        end
      end
    end
  end
end
