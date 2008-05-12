lpkgClass = {} 
lpkgClass_mt = {__index = lpkgClass} 

function lpkgClass.new(str_pkgs,str_repos)
	local self = {}
	setmetatable(self,lpkgClass_mt)
  self.__repo = {}
	self.__installed = {}
  self.__toinstall = {}
  self.__notfound = {}
  self.__invalidrepo = {}
  self.repo_list = str_repos or ""
	self.search = str_pkgs or ""
	self:repos()
	self:installed()
--	self:loadRepo_list(self.repo_list)
	return self
end 

function lpkgClass:loadRepo_list(str_repos)
  if str_repos == nil or str_repos == "" then
    for i,v in pairsByKeys(self.__repo) do
      self:load_repo(i)
    end
  else
    for repo_name in string.gmatch(str_repos,"[^,]+") do
      self:load_repo(string.trim(repo_name))
    end
  end
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
  self:process_pkgs_file_new(installed_set)
end


function lpkgClass:load_repo(str_repo)
  local data = load_file("/usr/lib/ipkg/lists/"..str_repo)
  if data ~= "No such file or directory" then
    if self.search and self.search ~= "" then
      self:do_process(self.search,data,str_repo)
      if self.depend then
        self:do_process(self.depend,data,str_repo)
      end
    else
      self:process_pkgs_file_new(data,"",str_repo)
    end
  else
    self.__invalidrepo[#self.__invalidrepo+1] = str_repo
--    print("Invalid Repo")
  end
end

function lpkgClass:do_process(str_search,data,str_repo)
--  if str_search == nil then 
--    local newdata = data
--    self:process_pkgs_file(newdata,"",str_repo)
--  else
    local all = false
    for search in string.gmatch(str_search,"%S+") do
--      print(search)
      local mysearch = string.gsub(search,"*","")
      local newdata = data
      if string.match(search,"*") then
        all = true
        start = string.find(newdata,"Package: "..mysearch,1,true)
      else
        start = string.find(newdata,"Package: "..mysearch.."\n",1,true)
      end

      if start == nil and all == false then
        self.__notfound[mysearch] = mysearch
      else      
--        self.__notfound[mysearch] = nil
        if start ~= nil then
          newdata = string.sub(newdata,start)
        end
        self:process_pkgs_file_new(newdata,search,str_repo)
      end
--      print(self.depend)
    end
--  end
end

function lpkgClass:process_pkgs_file_new(data,search,repo)
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
        self:add_new(tidx,repo)
        tidx = {}
        pkg = desc
        if search ~= "" and search ~= nil then
          if all == true then
            if search ~= string.sub(pkg,1,string.len(search)) then
              tidx = nil
              break 
            end
          else
            if pkg ~= search then
              tidx = nil
              break 
            end
          end
        end
      end
      if key == "Description" then
        if tidx["Description"] == nil then
          tidx["Description"] = desc
        else
          tidx["Description"] = tidx["Description"]..desc
        end
      else
        tidx[key] = desc 
      end
    end
  end
  self:add_new(tidx,repo)
end

function lpkgClass:add_new(tidx,reponame)
  if tidx == nil then return end
  self[#self+1] = tidx
  if reponame == "inst" then
    self.__installed[tidx.Package] = self[#self]
    self[#self]["Repository"] = "Installed"
    self[tidx.Package] = self[#self]
  else
    if self.__installed[tidx.Package] == nil then
      self[#self]["url"] = self.__repo[reponame].url
      if self.__toinstall[tidx.Package] == nil then
        self.__toinstall[tidx.Package] = self[#self]
      else
        if self:compareVersion(self.__toinstall[tidx.Package].Version, tidx.Version) == true then
          self.__toinstall[tidx.Package] = self[#self]
        end
      end
    end
    self.__repo[reponame]["pkgs"][tidx.Package] = self[#self]
    self[#self]["Repository"] = reponame
    if self[tidx.Package] == nil then self[tidx.Package]= {} end
    if self[tidx.Package][tidx.Version] == nil then self[tidx.Package][tidx.Version]= {} end
    if self[tidx.Package][tidx.Version][reponame] == nil then self[tidx.Package][tidx.Version][reponame]= self[#self] end
    if tidx.Depends ~= nil and tidx.Depends ~= "" and repo ~= "inst" then
      self:check_depends(tidx.Depends)
    end
  end
end

function lpkgClass:compareVersion(a,b)
  local lena = string.len(a)
  local lenb = string.len(b)
  local len = 0
  if lena > lenb then len = lenb
  else len = lena end
  for i=1, len do
    if string.sub(a,i,i) < string.sub(b,i,i) then return true end
    if string.sub(a,i,i) > string.sub(b,i,i) then return false end
  end
  if lena < lenb then return true end
  return false
end

function lpkgClass:check_depends(str)
  local str = string.gsub(str,","," ")
  local found = false
  for addsearch in string.gmatch(str,"%S+") do
    if self.__installed[addsearch] == nil and not string.match(addsearch,"[(=]") then
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

function lpkgClass:check_notfound()
    for i,v in pairs(self.__notfound) do
      if self[i] ~= nil then
        self.__notfound[i] = nil
      end
    end
end

function lpkgClass:autoinstall_pkgs()
  local ctrl_dep = {}
  local tinstall = {}
  self:check_notfound()
  local repite = ""
  local deps =""
  local not_found = {}
  local numpkgs = self:tcount(self.__toinstall)
  local addcount = 0
       
  repeat
    for i,v in pairs(self.__toinstall) do
      local ok = true
      if v.Depends ~= nil and string.trim(v.Depends) ~= "" then
        local depends = string.gsub(v.Depends,","," ")
        for dep in string.gmatch(depends,"%S+") do
          deps = dep
          if not string.match(dep,"[(=]") then
          if self.__installed[dep] == nil and ctrl_dep[dep] == nil then
            ok = false
            break
          end
          end
        end
      end
      print(i,deps)
      if ok == false then
        if not_found[deps] == nil then not_found[deps] = 1
        else not_found[deps] = tonumber(not_found[deps]) + 1 end
        if not_found[deps] > numpkgs then
          print ("Error :",i,"in repository ",v.Repository, "need ",deps)
          os.exit(99) 
--          self:loadRepo_list()
        end
      end
      if ok == true then
--      if self.__installed[i] == nil then
        tinstall[#tinstall+1] = {}
        tinstall[#tinstall]["Package"] = v.Package
        tinstall[#tinstall]["Version"] = v.Version
        tinstall[#tinstall]["Repository"] = v.Repository
        tinstall[#tinstall]["url"] = v.url
        tinstall[#tinstall]["file"] = v.Filename
        tinstall[#tinstall]["MD5Sum"] = v.MD5Sum
        ctrl_dep[i] = #tinstall
        self.__toinstall[i] = nil
        end
--      end
    end

  until self:tcount(self.__toinstall) == 0 
  return tinstall
end

function lpkgClass:tcount(t)
  local i = 0
  for k,v in pairs(t) do
    i = i +1
  end
  return i
end

function lpkgClass:loadCtrl(tmpdir)
  local tidx = {}
  str_ctrl = load_file(tmpdir.."/control/control")
  for line in string.gmatch(str_ctrl,"[^\n]+") do
    local key, desc = unpack(string.split(line,":"))
    if string.trim(key) ~= "" then
      if key and desc == nil then
        desc = key
        key = "Description"
      end        
      if key == "Description" then
        if tidx["Description"] == nil then
          tidx["Description"] = desc
        else
          tidx["Description"] = tidx["Description"]..desc
        end
      else
        tidx[key] = desc 
      end
    end
  end
  return tidx  
end

function lpkgClass:download(url,file,str_pkgname)
  local tmpdir = "/tmp/luapkg/"..str_pkgname
  local tmpfile = string.gsub(file,"%./","")
  local tmpurl = url.."/"
  
  os.execute("mkdir /tmp/luapkg/ 2>/dev/null")
  os.execute("rm -R "..tmpdir.." 2>/dev/null")
  os.execute("mkdir "..tmpdir.." 2>/dev/null")
  return os.execute("wget -q -P "..tmpdir.." "..tmpurl..tmpfile)
end

function lpkgClass:unpack(tinstall,str_pkgname,overwrite) 
  local tmpdir = "/tmp/luapkg/"..str_pkgname
  local tmpfile = string.gsub(tinstall.file,"%./","")
  local overwrite = overwrite or false -- or uci.get("luapkg.")
  local warning_exists = false
  local str_list = ""
  local str_ctrl = ""
  
  os.execute("mkdir "..tmpdir.."/control 2>/dev/null")
  os.execute("mkdir "..tmpdir.."/data 2>/dev/null")
  os.execute("mkdir "..tmpdir.."/data/usr 2>/dev/null")
  os.execute("mkdir "..tmpdir.."/data/usr/lib 2>/dev/null")
  os.execute("mkdir "..tmpdir.."/data/usr/lib/ipkg 2>/dev/null")
  os.execute("mkdir "..tmpdir.."/data/usr/lib/ipkg/info 2>/dev/null")
  
  os.execute("tar xzf "..tmpdir.."/"..tmpfile.." -C "..tmpdir)
  os.execute("rm "..tmpdir.."/*.ipk 2>/dev/null")

  os.execute("tar xzf "..tmpdir.."/control.tar.gz -C "..tmpdir.."/control")
  os.execute("rm "..tmpdir.."/control.tar.gz 2>/dev/null")

  os.execute("tar xzf "..tmpdir.."/data.tar.gz -C "..tmpdir.."/data")
  os.execute("rm "..tmpdir.."/data.tar.gz 2>/dev/null")

  tctrl_file = self:loadCtrl(tmpdir)

  local list_file = io.popen("ls -R "..tmpdir.."/data")
  local t_list = {}
  local prevdir = "/"
  
  for line in list_file:lines() do
    if string.len(line) > 0 then
      line = string.gsub(line,tmpdir.."/data","")
      if string.match(line,":") then
        line = string.gsub(line,":","")
        prevdir = line
        if string.len(line) == 0 then line = "/" end
        t_list[line] = "DIR"
      else
        t_list[prevdir.."/"..line] = false
        if prevdir == "/etc" then
          if overwrite == true then
            t_list[prevdir.."/"..line] = false
          else
            t_list[prevdir.."/"..line] = io.exists(prevdir.."/"..line)
            if t_list[prevdir.."/"..line] == true then warning_exists = true end
          end
        end
      end
    end
  end
  
  for i,v in pairsByKeys(t_list) do
    str_list = str_list..i.."\n"
  end
  str_list = str_list.."\n"
  
  local str_exec = ""
  control_files = io.popen("ls "..tmpdir.."/control")
  for line in control_files:lines() do
    if line == "preinst" then 
      str_exec = tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package.."."..line
      t_list["/usr/lib/ipkg/info/"..tctrl_file.Package.."."..line] = true
    else
      t_list["/usr/lib/ipkg/info/"..tctrl_file.Package.."."..line] = false
    end  
    os.execute("cp -f "..tmpdir.."/control/"..line.." "..tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package.."."..line)
    os.execute("rm "..tmpdir.."/control/"..line)
  end
  os.execute("echo '"..str_list.."' >"..tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package..".list")
  t_list["/usr/lib/ipkg/info/"..tctrl_file.Package..".list"] = false
  return t_list, tctrl_file, warning_exists, str_exec
end

function lpkgClass:wath_we_do(t)
  for i,v in pairsByKeys(t) do
    if v == true then
      repeat
        print(i)
        io.write([[==> File on system created by you or by a script.
==> File also in package provided by package maintainer.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
--      D     : show the differences between the versions (if diff is installed)
 The default action is to keep your current version.

(Y/I/N/O/D) [default=N] ? ]]) 
        rspta = io.read()
        if rspta == "" then rspta = "N" end
        rspta = string.upper(rspta)
        if rspta == "Y"
        or rspta == "I" then
          t[i] = false
        end
      until rspta == "N" or rspta == "O" or rspta == "Y" or rspta == "I"
    end
  end
  return t
end

function lpkgClass:processFiles(t_list,pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  for i,v in pairsByKeys(t_list) do
    if v == "DIR" then
      os.execute("mkdir "..i.." 2> /dev/null")
      print("mkdir "..i)
    elseif v == false then
      local rspta = os.execute("cp -pdf "..tmpdir.."/data"..i.." "..i)
      print("cp -pdf "..tmpdir.."/data"..i.." "..i)
--      print (i,rspta,str_error)
      if rspta ~= 0 then
--        os.execute("rm -R "..tmpdir)
        return rspta, "cp -pdf "..tmpdir.."/data"..i.." "..i
      end
      os.execute("rm "..tmpdir.."/data"..i)
      print("rm "..tmpdir.."/data"..i)
    end
  end
  return 0
end

function lpkgClass:detailled_status()
  local str_status = ""
  for i,v in pairsByKeys(self.__installed) do
    str_status = str_status.."Package: "..v.Package.."\n"
    str_status = str_status.."Status: "..tostring(v.Status).."\n"
    str_status = str_status.."Root: "..tostring(v.Root).."\n"
    if v.Conffiles then str_status = str_status.."Conffiles: "..v.Conffiles.."\n" end
    str_status = str_status.."Version: "..v.Version.."\n"
--    if (v.Depends) then str_status = str_status.."Depends: "..v.Depends.."\n" end
--    str_status = str_status.."Provides: "..tostring(v.Provides).."\n"
--    str_status = str_status.."Architecture: "..v.Architecture.."\n"
--    if v["Installed-Time"] then str_status = str_status.."Installed-Time: "..v["Installed-Time"].."\n" end
    str_status = str_status.."\n"
  end
  return str_status
end

function lpkgClass:write_status(pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  os.execute("echo '"..self:detailled_status().."' >/usr/lib/ipkg/status")
  os.execute("rm -R "..tmpdir)
end
