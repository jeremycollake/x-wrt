--------------------------------------------------------------------------------
-- uciUpdated.lua
--
-- Description: library of framework
--      library to manipulate uci values
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
require("common")
require("form")
require("validate")
require("uci_iwaddon")
uciUpdatedClass = {} 
uciUpdatedClass_mt = {__index = uciUpdatedClass} 

function uciUpdatedClass.new () 
	local self = {}
	setmetatable(self,uciUpdatedClass_mt) 
	self:countUpdated()
	return self 
end 

function uciUpdatedClass:countUpdated()
--
-- this is a very bad idea for security reasons...
-- but i keep it until i can think something more ...
-- or somebody suggests something...
--
  for i=1, #__UCI_MSG do 
    if __UCI_MSG[i]["cmd"] == "set" then
      uci.set(__UCI_MSG[i]["var"].."="..__UCI_MSG[i]["val"])
    elseif __UCI_MSG[i]["cmd"] == "add" then
      uci.add(__UCI_MSG[i]["var"].."="..__UCI_MSG[i]["val"])
    elseif __UCI_MSG[i]["cmd"] == "del" then
      uci.delete(__UCI_MSG[i]["var"])
    else
      print("Error :"..__UCI_MSG[i]["cmd"],__UCI_MSG[i]["var"],__UCI_MSG[i]["val"])
    end
  end
  for i=1, #__UCI_CMD do
    if __UCI_CMD[i].cmd == "snw" and __FORM.UCI_SET_VALUE ~= "" then
      __UCI_CMD[i].cmd = "set"
      __UCI_CMD[i].value = __UCI_CMD[i].value ..":"..__FORM.UCI_SET_VALUE
    end
    if __UCI_CMD[i].cmd == "set" then
      local grp, name = unpack(string.split(__UCI_CMD[i].value,":"))
      if name == nil then name = "" end
      if __UCI_VERSION == nil then	
        assert(os.execute("mkdir /tmp/.uci > /dev/null 2>&1"))
		    os.execute("echo \"config '"..grp.."' '"..name.."'\" >>/tmp/.uci/"..__UCI_CMD[i].varname)
		  else
        if name == "" then
          uci.add(__UCI_CMD[i].varname,grp)
--          os.execute("uci add "..__UCI_CMD[i].varname.." "..grp.." > /dev/null 2>&1")
--          os.execute("uci add "..self.__PACKAGE.." "..grp)
        else
          uci.set(__UCI_CMD[i].varname,name,grp)
--          os.execute("uci set "..__UCI_CMD[i].varname.."."..name.."="..grp.." > /dev/null 2>&1")
--          os.execute("uci set "..self.__PACKAGE.."."..name.."="..grp)
        end
		  end
    elseif __UCI_CMD[i].cmd == "del" then
      if __UCI_VERSION == nil then 
        os.execute("uci "..__UCI_CMD[i].cmd.." "..__UCI_CMD[i].varname)
      else
        uci.delete(__UCI_CMD[i].varname)
--        os.execute("uci "..__UCI_CMD[i].cmd.." "..__UCI_CMD[i].varname)
      end
    end
  end
--
-- End security risk
--

	for i, v in ipairs(__TOCHECK) do
--	   v = string.gsub(v,"-","___")
--[[
		local uci_val = io.popen("uci get "..v)
		local uci_value = string.trim(uci_val:read())
		uci_val:close()
]]--
		local uci_value = uci.get(v)
		if uci_value == nil then uci_value = "" end
		if __FORM[v] == nil then __FORM[v] = "" end
--		__FORM[v] = string.trim(__FORM[v])
--    print(uci_value,__FORM[v])
    
		local error = validate(__FORM["val_lbl_"..v],__FORM[v],__FORM["val_str_"..v],v)
		if error ~=nil then __ERROR[#__ERROR+1] = error end
		if __FORM[v] ~= uci_value and error==nil then
			if __FORM[v] == "" then 
--				os.execute("uci del "..v)
				uci.delete(v)
			else
--				os.execute("uci set "..v.."="..__FORM[v])
        uci.set(v.."="..__FORM[v])
			end
		end
	end
	uci.save()
end

function uciUpdatedClass:readUpdated()
	self["count"] = 0 --uci.changes()
	local BUFSIZE = 2^13     -- 8K
	assert(os.execute("mkdir /tmp/.uci > /dev/null 2>&1"))
	local filelist = assert(io.popen("ls /tmp/.uci")) 
	for filename in filelist:lines() do
		local lc = 0
		local f = io.input("/tmp/.uci/"..filename)   -- open input file
		self[filename]={}
		while true do
			local lines, rest = f:read(BUFSIZE, "*line")
			if not lines then break end
			if rest then lines = lines .. rest .. '\n' end
			for li in string.gmatch(lines,"[^\n]+") do
				self[filename][#self[filename]+1] = li
				self["count"] = self["count"] + 1
			end
		end
	end
end

function uciUpdatedClass:review()
  self:readUpdated()
	__MENU.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
	page.title = tr("Review Changes").." ("..self.count..")"
--	page.action_apply = ""
	page.action_review = ""
--	page.action_clear = ""
	
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
	print(page:header())
	for k,t in pairsByKeys(self) do
		if type(t) == "table" then
			local form = formClass.new(k,true)
			print (form:startFullForm())
			for i, linea in pairs(t) do
				print (linea,"<br>")
			end
			print (form:endForm())
		end
	end
	print(page:footer())
	os.exit()
end

function uciUpdatedClass:apply()
  self:readUpdated()
  dofile("/usr/share/internet-wifi/lib/apply.lua")
	os.exit()
end

function uciUpdatedClass:clear()
  self:readUpdated()
	__MENU.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
	page.title = tr("Clear Changes").." ("..self.count..")"
--	page.action_apply = ""
	page.action_review = ""
--	page.action_clear = ""
	
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
	print(page:header())
	for k,t in pairsByKeys(self) do
		if type(t) == "table" then
			local form = formClass.new(k,true)
			print (form:startFullForm())
			for i, linea in pairs(t) do
				print (linea,"... deleted...<br>")
			end
			print (form:endForm())
		end
	end
	print(page:footer())
	os.execute("rm /tmp/.uci/*")
	os.exit()

end

