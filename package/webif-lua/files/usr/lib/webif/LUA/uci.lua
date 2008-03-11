--------------------------------------------------------------------------------
-- uci.lua
--
-- Description: library of framework
--      library to manipulate UCI values
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--
-- Configuration files referenced:
--   all
--------------------------------------------------------------------------------
require("common")
require("form")
--if __FORM == nil then __FORM = get_post() end

uciClass = {} 
uciClass_mt = {__index = uciClass} 

function uciClass.new (pkg) 
  local pkg_exists = io.exists("/etc/config/"..pkg)
  if pkg_exists == false then
    os.execute("echo \"# "..pkg.."\" > /etc/config/"..pkg)
  end
	local self = {}
	setmetatable(self,uciClass_mt) 
	self["__PACKAGE"] = pkg
	self.sections = {}
	self.version = 1
	self:load_conf(pkg)
	return self 
end 

function uciClass:set(grp,name)
	local found = false
	if name == nil then name = "" end
--	print(self[name],"<br>")
	if name ~= "" then
		if self[name] ~= nil then
			found = true
		end
	end
  if __UCI_VERSION == nil then	
  	if found == false then
      assert(os.execute("mkdir /tmp/.uci > /dev/null 2>&1"))
      os.execute("echo \"config '"..grp.."' '"..name.."'\" >>/tmp/.uci/"..self.__PACKAGE)
      self:load_conf(self.__PACKAGE)
      __UCI_UPDATED.count = __UCI_UPDATED.count + 1
    end
  else
    if name == "" then
      os.execute("uci add "..self.__PACKAGE.." "..grp.." > /dev/null 2>&1")
    else
      os.execute("uci set "..self.__PACKAGE.."."..name.."="..grp.." > /dev/null 2>&1")
    end
    self:load_conf(self.__PACKAGE)
    __UCI_UPDATED.count = __UCI_UPDATED.count + 1
  end
	return self[grp]
end

function uciClass:load_conf(package)
	local uci_show = io.popen("uci show "..package)
	for line in uci_show:lines() do
    local idx = string.find(line,"=")
    local var = string.sub(line,1,idx-1)
    local value = string.sub(line,idx+1)
--		_, _, var, value = string.find(line,"(.*)=(.*)")
		pkg, con, opt = unpack(string.split(var,"."))
		if self[con] == nil then self[con] = {} end
		if opt == nil then
      self.sections[#self.sections+1] = {}
      self.sections[#self.sections]["group"] = value
      self.sections[#self.sections]["name"] = con
      self.sections[#self.sections]["values"] = self[con]

			if self[value] == nil then self[value] = {} end
			local found = false
			for idx=1, #self[value] do
				if self[value][idx]["name"] == con then
					found = true
					break
				end
			end
			if found==false then
				self[value][#self[value]+1] = {}
				self[value][#self[value]]["name"] = self.__PACKAGE.."."..con
				self[value][#self[value]]["values"] = self[con]
			end
		else
--		  opt = string.gsub(opt,"%_%_%_","-")
			self[con][opt] = value
		end
	end
end
