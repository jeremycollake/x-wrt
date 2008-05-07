--------------------------------------------------------------------------------
-- checkpkg.lua
--
-- Description: library of framework
--      library to check and install packages
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
require("iw-luaipkg")
pkgInstalledClass = {} 
pkgInstalledClass_mt = {__index = pkgInstalledClass} 

function pkgInstalledClass.new (pkgs,auto)
	if auto == nil then auto = false end
	if pkgs == nil then return true end 
	local self = {}
	setmetatable(self,pkgInstalledClass_mt)
	self["available"] = {}
	self["available"]["count"] = 0
	self["notavailable"] = {}
	self["notavailable"]["count"] = 0
	self["installed"] = {}
	self["installed"]["count"] = 0
	self["__auto"] = auto
	self["require"] = {}
	self["require"]["count"] = 0
	if __FORM.bt_add_repository ~= nil then
		self:add_repo()
	elseif __FORM.bt_pkg_install ~= nil then
		self:install_pkg()
	else
		self:check(pkgs)
	end
	return self
end 

function pkgInstalledClass:check(pkg_list)
	local count = 0
	local checked = {}
	local data = load_file("/usr/lib/ipkg/status")
	for pkg in string.gmatch(pkg_list,"[^,]+") do
--		if not string.match(data,pkg) then
		if not string.find(data,"Package: "..pkg,1,true) then
			checked[pkg] = false
			self.require.count = self.require.count + 1
			self.require[pkg] = false
		else
			self.installed[pkg] = true
			self.installed.count = self.installed.count + 1
		end
	end
	if self.require.count > 0 then self:install() end
end

function pkgInstalledClass:available_pkg()
	local data = ""
	file_list = {}
	status = {}
	local files = io.popen("ls /usr/lib/ipkg/lists")
	for file in files:lines() do
		file_list[file] = ""
	end
	for k, v in pairs(self.require) do
		if k ~= "count" then
			status[k] = false
			for i, d in pairs(file_list) do
				if d == "" then d = load_file("/usr/lib/ipkg/lists/"..i) end
--				if string.match(d, k) then
				if string.find(d, k,1,true) then
					status[k] = true
					break
				end
			end
		end
	end
	for i,v in pairs(status) do
		if v == true then
			self.available[i] = true
			self.available.count = self.available.count + 1
		else
			self.notavailable.count = self.notavailable.count + 1
			self.notavailable[i] = false
		end
	end
end

function pkgInstalledClass:install()
	self:available_pkg()
	if self.__auto == true then 
		self:display()
	end
end

function pkgInstalledClass:get_hidden(form)
	for line in string.gmatch(__MENU.selected,"[^&]+") do
		key, val = unpack(string.split(line,"="))
		key = string.trim(key)
		val = string.trim(val)
		form:Add("hidden",key,val)
	end
end

function pkgInstalledClass:display()
	__MENU.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
	page.title = tr("Need Install").." ("..self.require.count..") packages..."
--	page.action_apply = ""
	page.action_review = ""
--	page.action_clear = ""
	local pkg_title = ""
	page.savebutton ="<input type=\"submit\" name=\"bt_pkg_install\" value=\"Install\" style=\"width:150px;\" />"
--	page.savebutton =""

	print(page:header())
	if self.available.count > 0 then 
		if self.available.count > 1 then pkg_title = " "..tr("packages") else pkg_title = " "..tr("package") end
		local form = formClass.new(tr("Available")..pkg_title.." ("..self.available.count..") in repository")
		for k,t in pairsByKeys(self.available) do
			if k ~= "count" then
				form:Add("checkbox","pkg_toinstall_"..k,1,"Install "..k,"")
			end
		end
		self:get_hidden(form)
--		form:Add("button","bt_available_install","Install from Repository","","","width:150px;float:right")
		form:Add_help(tr("pkg_available#Package Available"),tr("Check available package in repository to install them"))
		form:print()
	end

	if self.notavailable.count > 0 then 
		if self.notavailable.count > 1 then pkg_title = " "..tr("packages") else pkg_title = " "..tr("package") end
		local form = formClass.new(tr("Install from URL"))
		for k,t in pairsByKeys(self.notavailable) do
			if k ~= "count" then
				form:Add("text","url_install_"..k,"",k,"","width:99%")
			end
		end
		self:get_hidden(form)
--		form:Add("button","bt_url_install","Install from URL","","","width:150px;float:right")
		form:Add_help(tr("pkg_fromURL#Install from URL"),tr("You can install a package not listed in the known repositories here."))
		form:print()

		local form = formClass.new(tr("Add new repository"))
		form:Add("text","pkg_repository_name","",tr("system_ipkg_reponame#Repo. Name"),"","width:99%")
		form:Add("text","pkg_repository_url","",tr("system_ipkg_repourl#Repo. URL"),"","width:99%")
		form:Add("button","bt_add_repository",tr("Add Repository"),"","","width:150px;float:right")
		self:get_hidden(form)
		form:Add_help(tr("Add Repository"),tr("A repository is a server that contains a list of packages that can be installed on your OpenWrt device. Adding a new one allows you to list packages here that are not shown by default."))
		form:print()
	end
--	for k,v in pairsByKeys(__FORM) do
--		print(k,v,"<br>")
--	end
	print(page:footer())
	os.exit()
end

function pkgInstalledClass:install_pkg()
	local str_list =""
	for i, v in pairs(__FORM) do
		if string.find(i,"pkg_toinstall_",1,true) then
			if v == "1" then
				str_list = str_list .. " " .. string.gsub(i,"pkg_toinstall_","")
			end
		elseif string.find(i,"url_install_",1,true) then
			if string.trim(v) ~= "" then
				str_list = str_list .. " " .. v
			end
		end
	end
	page.title = tr("Installing Package")
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
	print(page:header())
	for line in string.gmatch(__MENU.selected,"[^&]+") do
		key, val = unpack(string.split(line,"="))
		key = string.trim(key)
		val = string.trim(val)
		print ("<input type=\"hidden\" name=\""..key.."\" value=\""..val.."\" />") 
	end
	
	print("<pre>")
  local pkg = lpkgClass.new(str_list)
  pkg:loadRepo_list(pkg.repo_list)
  print(str_list)
  local tinstall = pkg:autoinstall_pkgs()
  print("Please wait... ")
  for i = 1, #tinstall do
    local dest = tinstall[i].Package.." ("..tinstall[i].Version..")"
    print("Installing "..dest)
    print("Downloading "..tinstall[i].url..tinstall[i].file)
    pkg:download(tinstall[i].url,tinstall[i].file,i)

    print("Unpack file "..tinstall[i].file)
    local tfiles, tctrl_file, warning_exists, str_exec = pkg:unpack(tinstall[i],i,true)

--[[
    esto hay que hacerlo para que pida por web la confirmacion
    if warning_exists == true then
      tfiles = pkg:wath_we_do(tfiles)
    end
]]--

    print("Configuring "..dest)
    if string.len(str_exec) > 0 then
      print("Executing preinstall "..dest)
      os.execute(str_exec)
    end
    print("Copying files")
    rspta, str_cmd = pkg:processFiles(tfiles,i)
    if rspta ~= 0 then
      print ("Error: "..str_cmd)
    	print("</pre>")
      print(page:footer())
      os.exit()
    end
      
    local str_installed = "Package: "..tctrl_file.Package.."\n"
    str_installed = str_installed.."Version: "..tctrl_file.Version.."\n"
    if tctrl_file.Depends ~= nil then
      str_installed = str_installed.."Depends: "..tctrl_file.Depends.."\n"
    end
    str_installed = str_installed.."Provides: "..tctrl_file.Provides.."\n"
    str_installed = str_installed.."Root: /\n"
    str_installed = str_installed.."Status: install ok installed\n"
    str_installed = str_installed.."Architecture: "..tctrl_file.Architecture.."\n"
    if conffiles ~= nil then
      str_installed = str_installed.."Conffiles: "..conffiles.."\n"
    end
    str_installed = str_installed.."Installed-Time: "..tostring(os.time()).."\n"
    print(str_installed)
    pkg:process_pkgs_file_new(str_installed)
    pkg:write_status(i)
  end
	print("</pre>")
	print(page:footer())
	os.exit()
end

function pkgInstalledClass:add_repo()
	local str_list =""
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
	print(page:header())
	if __FORM.pkg_repository_name ~= nil and __FORM.pkg_repository_name ~= "" 
	and __FORM.pkg_repository_url ~= nil and __FORM.pkg_repository_url then
		local data = "src "..__FORM.pkg_repository_name.." "..__FORM.pkg_repository_url.."\n"
		data = data .. load_file("/etc/ipkg.conf")
		os.execute("echo \""..data.."\" > /etc/ipkg.conf")
		print("Repository : ",__FORM.pkg_repository_name,__FORM.pkg_repository_url," Added...<br><br>")
		data = io.popen("ipkg update")
		for line in data:lines() do
			print(line,"<br>")
		end
	else
		print(tr("Repositoy not Added..."))
	end 
	print(page:footer())
	os.exit()
end

