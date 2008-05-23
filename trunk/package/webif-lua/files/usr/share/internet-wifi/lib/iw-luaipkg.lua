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
	self:setparent()
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

function lpkgClass:installed_list()
  local str_list = ""
  for pkg, t in pairs(self.__installed) do
    str_list = str_list.." "..pkg
  end
  return string.trim(str_list)
end

function lpkgClass:update()
  self.search = self:installed_list()
  for reponame, t in pairsByKeys(self.__repo) do
    print("Repository: "..reponame)
    print(t.url)
    os.execute("mkdir /usr/lib/ipkg/lists 2>/dev/null")
    os.execute("wget -q "..t.url.."/Packages -O /usr/lib/ipkg/lists/"..reponame )
    self:load_repo(reponame)
  end
  os.execute("echo '"..self:detailled_status().."' >/usr/lib/ipkg/status")
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
    local all = false
    for search in string.gmatch(str_search,"%S+") do
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
        self.__notfound[mysearch] = nil
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
  local desc = ""
  local key = ""
  for line in string.gmatch(data,"[^\n]+") do
    if string.trim(line) ~= "" then
    if not string.match(line,":") then
      if tidx[key] == "" then tidx[key] = line
      else tidx[key] = tidx[key].." "..line end
    else 
      key, desc = unpack(string.split(line,":"))
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
    if self[tidx.Package][tidx.Version] == nil then self[tidx.Package][tidx.Version] = {} end
--    if self[tidx.Package][tidx.Version] == nil then self[tidx.Package][tidx.Version] = self[#self] end
    if self[tidx.Package][tidx.Version][reponame] == nil then self[tidx.Package][tidx.Version][reponame] = self[#self] end

    if tidx.Depends ~= nil and tidx.Depends ~= "" and repo ~= "inst" then
      if self.__installed[tidx.Package] ~= nil then
        if self.__installed[tidx.Package].Depends == nil
        and self.__installed[tidx.Package].Version == tidx.Version then 
          self.__installed[tidx.Package].Depends = tidx.Depends 
        end
      end 
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
--      print(i,deps)
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
        tinstall[#tinstall]["Depends"] = v.Depends
        tinstall[#tinstall]["file"] = v.Filename
        tinstall[#tinstall]["MD5Sum"] = v.MD5Sum
        ctrl_dep[i] = #tinstall
        self.__toinstall[i] = nil
--        end
      end
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

function lpkgClass:loadCtrl(file)
  local tidx = {}
  str_ctrl = load_file(file)
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
--  os.execute("rm -R "..tmpdir.." 2>/dev/null")
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

  tctrl_file = self:loadCtrl(tmpdir.."/control/control")
  t_list,str_list = self:make_list(str_pkgname)

  self.__tprovider_conf = {}
  local str_exec = ""
  control_files = io.popen("ls "..tmpdir.."/control")
  for fileline in control_files:lines() do
    if fileline == "preinst" then 
      str_exec = tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package.."."..fileline
      t_list["/usr/lib/ipkg/info/"..tctrl_file.Package.."."..fileline] = false
    elseif fileline == "conffiles" then
      local oldconf = io.open(tmpdir.."/control/"..fileline)
      for conffile in oldconf:lines() do
--        print(conffile)
        self.__tprovider_conf[conffile] = self:calc_md5sum(tmpdir.."/data/"..conffile )
      end
      t_list["/usr/lib/ipkg/info/"..tctrl_file.Package.."."..fileline] = false
    else
      t_list["/usr/lib/ipkg/info/"..tctrl_file.Package.."."..fileline] = false
    end  
    os.execute("cp -f "..tmpdir.."/control/"..fileline.." "..tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package.."."..fileline)
    os.execute("rm "..tmpdir.."/control/"..fileline)
  end
  
  os.execute("echo '"..str_list.."' >"..tmpdir.."/data/usr/lib/ipkg/info/"..tctrl_file.Package..".list")
  
  t_list["/usr/lib/ipkg/info/"..tctrl_file.Package..".list"] = false
--  return t_list, tctrl_file, warning_exists, str_exec, self.__tprovider_conf
  for filename, md5_val in pairs(self.__tprovider_conf) do
    if overwrite == true then
      t_list[filename] = false
    else
      if io.exists(filename) == false then
        t_list[filename] = false
      else
        t_list[filename] = self:calc_md5sum(filename)
      end
    end
--    print(filename,self.__tprovider_conf[filename],t_list[filename])
  end
  return t_list, tctrl_file, str_exec
end

function lpkgClass:make_list(pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  local str_list = ""
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
      end
    end
  end
  
  for i,v in pairsByKeys(t_list) do
    str_list = str_list..i.."\n"
  end
  str_list = str_list.."\n"
  return t_list, str_list
end

function lpkgClass:calc_md5sum(file)
  local md5 = ""
--  local calc_file = io.popen("md5sum < "..file)
  local calc_file = io.popen("md5sum "..file)
  for line in calc_file:lines() do
    md5 = unpack(string.split(line," "))
--    md5 = line
  end
  return md5
end 

function lpkgClass:what_we_do(tfiles,pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  local msg =[[==> File on system created by you or by a script.
==> File also in package provided by package maintainer.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions (if diff is installed)
 The default action is to keep your current version.

(Y/I/N/O/D) [default=N] ? ]]

  for filename, md5_provider in pairs(self.__tprovider_conf) do
    if type(tfiles[filename]) == "string" then
      if tfiles[filename] ~= self.__tprovider_conf[filename] then
        repeat
          print(filename)
          io.write(msg) 
          rspta = io.read()
          if rspta == "" then 
            rspta = "N"
          end
          rspta = string.upper(rspta)
          if rspta == "Y"
          or rspta == "I" then
--          self.__tprovider_conf[filename] = tfiles[filename]
            tfiles[filename] = false
          end
          if rspta == "N"
          or rspta == "O" then
            self.__tprovider_conf[filename] = tfiles[filename]
            tfiles[filename] = true
          end
          if rspta == "D" then
            os.execute("diff "..tmpdir.."/data/"..filename.." "..filename.." | less")
          end
        until rspta == "N" or rspta == "O" or rspta == "Y" or rspta == "I"
      end
    end
  end
  local str_conffiles = ""
  for filestr, md5str in pairs(self.__tprovider_conf) do
    if str_conffiles == "" then str_conffiles = filestr.." "..md5str
    else str_conffiles = str_conffiles.." "..filestr.." "..md5str end
  end
  return tfiles, str_conffiles
end

function lpkgClass:processFiles(t_list,pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  for i,v in pairsByKeys(t_list) do
    if v == "DIR" then
      os.execute("mkdir "..i.." 2> /dev/null")
--      print("mkdir "..i)
    elseif v == false then
      local rspta = os.execute("cp -pdf "..tmpdir.."/data"..i.." "..i)
--      print("cp -pdf "..tmpdir.."/data"..i.." "..i)
----      print (i,rspta,str_error)
      if rspta ~= 0 then
----        os.execute("rm -R "..tmpdir)
        return rspta, "cp -pdf "..tmpdir.."/data"..i.." "..i
      end
      os.execute("rm "..tmpdir.."/data"..i)
--      print("rm "..tmpdir.."/data"..i)
    end
  end
  return 0
end

function lpkgClass:detailled_status()
	local status_field_list = "Depends Status Conffiles Description"
  local str_status = ""
  for i,v in pairsByKeys(self.__installed) do
    str_status = str_status.."Package: "..i.."\n"
    str_status = str_status.."Version: "..v.Version.."\n"
    if status_field_list == nil or string.trim(status_field_list) == "" then
      for k,n in pairsByKeys(v) do
        if k ~= "Package" and k ~= "Version" and n ~= "Installed" and type(n) ~= "table"  and n ~= nil and n ~= "" then
          str_status = str_status..k..": "..n.."\n"
        end
      end
    else    
      for field in string.gmatch(status_field_list,"%S+") do
        field = string.trim(field)
        if field ~= "Package" and field ~= "Version" then
          if string.trim(v[field]) ~= "" then
            if v[field] then str_status = str_status..field..": "..v[field].."\n" end
          end
        end
      end
    end
    str_status = str_status.."\n"
  end
  return str_status
end

function lpkgClass:write_status(pkgname)
  local tmpdir = "/tmp/luapkg/"..pkgname
  os.execute("echo '"..self:detailled_status().."' >/usr/lib/ipkg/status")
  os.execute("rm -R "..tmpdir)
end

function lpkgClass:setparent()
  for i,t in pairs(self.__installed) do
    if t.Depends then
      local str = string.gsub(t.Depends,","," ")
      local found = false
      for parent in string.gmatch(str,"%S+") do
        if not string.match(parent,"[(=]") then
          if self.__installed[parent].child == nil then self.__installed[parent].child = i
          else self.__installed[parent].child = self.__installed[parent].child.." "..i end
        end
      end
    end  
  end
end

function lpkgClass:remove_make_list()
  self.__toremove = {}
  self:remove_order(self.search)
end

function lpkgClass:remove_order(str_child,num)
  local num = num or 0
  local tsearch = {}
  for pkg in string.gmatch(self.search,"%S+") do
    tsearch[pkg] = 0
  end
  for pkg in string.gmatch(str_child,"%S+") do
    if self.__installed[pkg] then
      if  self.__toremove[pkg] == nil then
        if self.__installed[pkg].child ~= nil then
          self:remove_order(self.__installed[pkg].child,num+1)
        end
        self.__toremove[pkg] = num
--        self.__toremove[pkg] = self.__installed[pkg].Depends
        self.__toremove[#self.__toremove+1] = pkg
      end
      if tsearch[pkg] ~= nil then
        if self.__toremove[pkg] then self.__toremove[pkg] = 0 end
--        if self.__toremove[pkg] then self.__toremove[pkg] = "0" end
      end
    else
      self.__notfound[pkg] = 0
    end
  end
end

function lpkgClass:remove_check_child(recursive)
  local str_msg = "\n\nDo you want remove all this packages (Y/N) [default=N] ? "
  local ask = false
  for i = 1, #self.__toremove do
    if recursive == true then self.__toremove[self.__toremove[i]] = 0 end
    str_msg = string.rep("\t",self.__toremove[self.__toremove[i]])..self.__toremove[i].."\n"..str_msg
    if self.__toremove[self.__toremove[i]] > 0 then
      ask = true
--      print(self.__toremove[i],self.__toremove[self.__toremove[i]])
--    else
--      print(self.__toremove[i].."... removing")
    end
  end
  return ask, str_msg
end

function lpkgClass:remove_pkgs(pkgname)
  local infodir = self.__installed[pkgname].infodir or "/usr/lib/ipkg/info/"
  local tfiles = {}
  local tconffiles = {}
  if self.__installed[pkgname].Conffiles then
    tconffiles = self:read_conffiles(pkgname)
  end
  str_files, error = load_file(infodir..pkgname..".list")
  if error == false then
    print("Error : "..infodir..pkgname..".list is missing")
    os.exit(99)
  end
  for line in string.gmatch(str_files,"[^\n]+") do
    if os.execute("[ -f "..line.." ]") == 0 then
      if tconffiles[line] ~= nil then
        tfiles[line] = true
      else
        tfiles[line] = false
      end
    end
  end
  return tfiles
end

function lpkgClass:remove_done(pkgname)
  local infodir = self.__installed[pkgname].infodir or "/usr/lib/ipkg/info/"
  os.execute("rm "..infodir..pkgname..".* 2>/dev/null")
--  print ("rm "..infodir..pkgname..".*")
  self.__installed[pkgname] = nil
  os.execute("echo '"..self:detailled_status().."' >/usr/lib/ipkg/status")
  print("Remove "..pkgname.." done.")
end

function lpkgClass:execute(str_filename,str_script)
  local infodir = self.__installed[str_filename].infodir or "/usr/lib/ipkg/info/"
  local rslt = 0
  if io.exists(infodir..str_filename..str_script) then 
    print("Executing "..infodir..str_filename..str_script)
    rslt = os.execute(infodir..str_filename..str_script)
    if rslt ~= 0 then
      print("Error while execute "..infodir..str_filename..str_script)
    end
  end
  return rslt
end

function lpkgClass:read_conffiles(pkgname)
  local tr = {}
  if self.__installed[pkgname].Conffiles ~= nil then
    local file = ""
    for line in string.gmatch(self.__installed[pkgname].Conffiles,"%S+") do
      if file == "" then 
        file = line
      else
        local md5_str = self:calc_md5sum(file)
--        print(file,line,md5_str)
        if md5_str ~= line then
          tr[file]=line
        end
        file = ""
      end
    end
  end
  return tr
end
      