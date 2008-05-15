require("iw-luaipkg")
require("common")
pkg = {}
local P = {}
pkg = P
-- Import Section:
-- declare everything this package needs from outside
local lpkgClass = lpkgClass
local pairsByKeys = pairsByKeys
local print = print
local pairs = pairs
local string = string
local formClass = formClass
local tr = tr
local page = page
local __MENU = __MENU
local __SERVER = __SERVER
local unpack = unpack
local __FORM = __FORM
local os = os
local tostring = tostring
local len = len

-- no more external access after this point
setfenv(1, P)
local hidden_values = {}

function add_hidden(key,val)
  hidden_values[key] = val
end

function set_hidden()
  local str_hidden = ""
  for key,val in pairs(hidden_values) do
		str_hidden = str_hidden .. "<input type=\"hidden\" name=\""..key.."\" value=\""..val.."\" />"
  end
  return str_hidden
end 
    
function check(pkg_list)
  if __FORM.bt_pkg_install then
    install()
  else
    local lpkg = lpkgClass.new()
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
    if lpkg.search == "" then return nil end
    form_select(lpkg)
--    return form_select()
  end
end

function form_select(lpkg)
  local forms = {}
  print("select")
  lpkg:loadRepo_list()
  lpkg:check_notfound()

	page.action_apply = ""
	page.action_review = ""
	page.action_clear = ""
	page.savebutton ="<input type=\"submit\" name=\"bt_pkg_install\" value=\"Install\" style=\"width:150px;\" />"..set_hidden()

  local inrepo = lpkg:tcount(lpkg.__toinstall)
  local notfound = lpkg:tcount(lpkg.__notfound)
  page.title = tr("Need install ("..inrepo+notfound..") package(s)")
  forms[#forms+1] = formClass.new(tr("Packages in repositories").. " ("..inrepo..")")

  for i, v in pairsByKeys(lpkg.__toinstall) do
    forms[#forms]:Add("select","rppkg_install_"..i,v.Repository,i,"","width:200px;")
    forms[#forms]["rppkg_install_"..i].options:Add("none",tr("No Install"))
    for k, t in pairs(lpkg[i]) do
      for u,j in pairs(t) do
        forms[#forms]["rppkg_install_"..i].options:Add(u,k.." "..tr("from").." "..u)
      end
    end
  end
  forms[#forms]:Add_help(tr("pkg_inRepo#Packages in repositries"),tr("pkg_help_inRepo#Select version and repository to install"))
  if notfound > 0 then
    forms[#forms]:Add("subtitle",tr("Not found in repositories").."("..notfound..")")
    for i,v in pairs(lpkg.__notfound) do
      forms[#forms]:Add("text","pkg_install_"..i,"","url of".." "..i,"","width:99%;")
    end
    forms[#forms]:Add_help(tr("pkg_notRepo#Packages not found in repositries"),tr("pkg_help_notRepo#Write the complete url or file name to install package"))
--    forms[#forms]:Add("subtitle",tr("pkg_addrepo#Add new repository"))
--		forms[#forms]:Add("text","pkg_repository_name","",tr("system_ipkg_reponame#Repo. Name"),"","width:99%")
--		forms[#forms]:Add("text","pkg_repository_url","",tr("system_ipkg_repourl#Repo. URL"),"","width:99%")
--		forms[#forms]:Add("button","bt_add_repository",tr("Add Repository"),"","","width:150px;float:right")
----		get_hidden(form)
--		forms[#forms]:Add_help(tr("pkg_addrepo#Add new repository"),tr("A repository is a server that contains a list of packages that can be installed on your OpenWrt device. Adding a new one allows you to list packages here that are not shown by default."))
  end
  do_form(forms,{})
end

function install()
  local t = {}
  local forms = {}
  local i = 0
	page.action_apply = ""
	page.action_review = ""
	page.action_clear = ""
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"..set_hidden()
	
  page.title = tr("Installing Packages")
  local search = ""
  local repos = ""

  for i,repo in pairs(__FORM) do
    if string.match(i,"rppkg_install_") then
      repo = string.trim(repo)
      if repo ~= "none" then
        if t[repo] == nil 
          then t[repo] = {} 
          if repos == "" then repos = repo
          else repos = repos .. "," .. repos end
        end
        local p = string.trim(string.gsub(i,"rppkg_install_",""))
        if t[repo][p] == nil then 
          t[repo][p] = true 
          if search == "" then 
            search = p
          else 
            search = search.." "..p
          end
        end
      end
    end
  end
  local lpkg = lpkgClass.new(search)
  lpkg:loadRepo_list()

  for reponame, p in pairs(t) do
    for package, v in pairs(p) do
      lpkg.__toinstall[package] = lpkg.__repo[reponame]["pkgs"][package]
    end
  end

  local tinstall = lpkg:autoinstall_pkgs()
  print(page:header())
  print("<pre>")

  print("Please wait... Installing".."&nbsp;("..tostring(#tinstall)..") package(s)")

  for i = 1, #tinstall do
    local dest = tinstall[i].Package.." ("..tinstall[i].Version..")"
    print("Installing "..dest)
    print("Downloading "..tinstall[i].url..tinstall[i].file)
    lpkg:download(tinstall[i].url,tinstall[i].file,i)

    print("Unpack file "..tinstall[i].file)
    local tfiles, tctrl_file, warning_exists, str_exec = lpkg:unpack(tinstall[i],i,true)

    tfiles, conffiles = pkg:web_wath_we_do(tfiles)
--[[
    esto hay que hacerlo para que pida por web la confirmacion
    if warning_exists == true then
      tfiles = lpkg:wath_we_do(tfiles)
    end
]]--

    print("Configuring "..dest)
    if string.len(str_exec) > 0 then
      print("Executing preinstall "..dest)
      os.execute(str_exec)
    end
    print("Copying files")
    rspta, str_cmd = lpkg:processFiles(tfiles,i)

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
    print(dest.." installed ok")
    lpkg:process_pkgs_file_new(str_installed)
    lpkg:write_status(i)
  end
  print("</pre>")
  print(page:footer())
  os.exit(0)
end

--[[
function get_hidden(form)
	for line in string.gmatch(__MENU.selected,"[^&]+") do
		key, val = unpack(string.split(line,"="))
		key = string.trim(key)
    val = string.trim(val)
		form:Add("hidden",key,val)
	end
end
]]--

function do_form(forms,t)
  print(page:header())
  for i=1, #forms do
    forms[i]:print()
  end
  print(page:footer())
  os.exit(0)
end
