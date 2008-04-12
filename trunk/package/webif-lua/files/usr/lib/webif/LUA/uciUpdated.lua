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
uciUpdatedClass = {} 
uciUpdatedClass_mt = {__index = uciUpdatedClass} 

function uciUpdatedClass.new () 
	local self = {}
	setmetatable(self,uciUpdatedClass_mt) 
	self:countUpdated()
	return self 
end 

function uciUpdatedClass:countUpdated()
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
          os.execute("uci add "..__UCI_CMD[i].varname.." "..grp.." > /dev/null 2>&1")
--          os.execute("uci add "..self.__PACKAGE.." "..grp)
        else
          os.execute("uci set "..__UCI_CMD[i].varname.."."..name.."="..grp.." > /dev/null 2>&1")
--          os.execute("uci set "..self.__PACKAGE.."."..name.."="..grp)
        end
		  end
    elseif __UCI_CMD[i].cmd == "del" then
      if __UCI_VERSION == nil then 
        os.execute("uci "..__UCI_CMD[i].cmd.." "..__UCI_CMD[i].varname)
      else
        os.execute("uci "..__UCI_CMD[i].cmd.." "..__UCI_CMD[i].varname)
      end
    end
  end
	for i, v in ipairs(__TOCHECK) do
--	   v = string.gsub(v,"-","___")
		local uci_val = io.popen("uci get "..v)
		local uci_value = string.trim(uci_val:read())
		uci_val:close()
		if uci_value == nil then uci_value = "" end
		if __FORM[v] == nil then __FORM[v] = "" end
		local error = validate(__FORM["val_lbl_"..v],__FORM[v],__FORM["val_str_"..v],v)
		if error ~=nil then __ERROR[#__ERROR+1] = error end
		if __FORM[v] ~= uci_value and error==nil then
			if __FORM[v] == "" then 
				os.execute("uci del "..v)
			else
				os.execute("uci set "..v.."="..__FORM[v])
			end
		end
	end
	self["count"] = 0
	local BUFSIZE = 2^13     -- 8K
	assert(os.execute("mkdir /tmp/.uci > /dev/null 2>&1"))
	local filelist = assert(io.popen("ls /tmp/.uci")) 
--	if filelist == 2 then  end
--	filelist = assert(io.popen("ls /tmp/.uci/"))
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

function uciUpdatedClass:review(page)
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

function uciUpdatedClass:apply(page)
  __RESTART = {}
	self.count = 0
	__MENU.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
	page.title = tr("Updating config")
	page.action_apply = ""
	page.action_review = ""
	page.action_clear = ""
	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
	print(page:header())
  local handler_list = {}
  handler_dir = io.popen("ls /usr/lib/webif/apply")
  for line in handler_dir:lines() do
    handler_list[#handler_list+1] = line
  end
  for k,t in pairsByKeys(self) do
    if type(t) == "table" then
      local found = false
      for i = 1, #handler_list do
        if handler_list[i] == k then
          local form = formClass.new(k,true)
		    	print (form:startFullForm())
          found = true
--          print("Committing ...")
--          os.execute("uci commit "..k)
--          print("Executing parser ...")
          dofile("/usr/lib/webif/apply/"..k)
    			print (form:endForm())
          break
        end
      end
		end
	end
	for i, t in pairs(__RESTART) do 
    local form = formClass.new("Restarting...",true)
    print (form:startFullForm())
    local opt = 1
    if t.pkg ~= "" then
      local ucifile = uciClass.new(t.pkg)
      opt = tonumber(ucifile[t.cfg][t.opt]) 
    end
    if  opt == 1 then
      print ("Enabling "..i.." service...<br>")
      io.stdout:flush()
      local myexec = io.popen(t.init.." enable")
      for li in myexec:lines() do
--        if string.len(li) > 1 then
          print(li,"<br>")
--        end
      end
      myexec:close()
      io.stdout:flush()
      myexec = io.popen(t.init.." stop")
      print ("Stopping "..i.." service...<br>")
      for li in myexec:lines() do
--        if string.len(li) > 1 then
          print(li,"<br>")
--        end
      end
      myexec:close()
      print ("Starting "..i.." service...<br>")
      io.stdout:flush()
      os.execute(t.init.." start > /tmp/start")
--      mystart, error = io.popen(t.init.." start ", "r")
      for li in io.input("/tmp/start"):lines() do
--        if string.len(li) > 1 then
          print(li,"<br>")
--          io.stdout:flush()
--        end
      end
--      mystart:close()
    else
      myexec = io.popen(t.init.." stop")
      print ("Stopping "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
      local myexec = io.popen(t.init.." disable")
      print ("Disabling "..i.." service...<br>")
      for li in myexec:lines() do
        if string.len(li) > 1 then
          print(li,"<br>")
        end
      end
      myexec:close()
    end
  	print (form:endForm())
  end
  local form = formClass.new("Apply...",true)
  print (form:startFullForm())
	changes_apply=io.popen ("/usr/lib/webif/apply.sh 2>&1")
	for linea in changes_apply:lines() do
		print(trsh(linea),"<br>")
	end
 	print (form:endForm())
	changes_apply:close()
	print(page:footer())
	os.exit()
end

function uciUpdatedClass:clear(page)
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

