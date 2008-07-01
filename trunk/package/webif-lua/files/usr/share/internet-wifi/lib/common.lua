--------------------------------------------------------------------------------
-- common.lua
--
-- Description:
--      library...
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
require("uci_iwaddon")
-- This functions read the system settings
function loadsystemconf()
	local self = sys_info_load()
  self = loadconf("webif","",self)
	return self
end
-- Load conf Files formated "UCI files" 
function loadconf(filename,path,t)
  local self = {}
  if t ~= nil then self = t end 
	local config = ""
	local i = 0
	local compare_var
	if path == nil or path == "" then path = "/etc/config/" end
	for line in io.lines(path..filename) do
		linea = string.gsub (line, "\t", " ")
		local ctype, name, value
		if string.len(linea) > 0 then 
			ctype, name, value = listtovars(linea,3)
		end
		if ctype == "config" then
			i = i + 1
			if value == nil or string.trim(value) == "" then value = "cfg"..i end 
			name, value = value, name
			config = name
			self[config]={}
		end
		if ctype == "option" then		 
			self[config][name]=value
		end
	end
	return self
end
-- Load File
function load_file(filename)
	local data = ""
	local error = ""
	local BUFSIZE = 2^15     -- 32K
	local f = io.exists( filename )
	if f == true then
    f = assert(io.open(filename,"r"))   -- open input file
  else f = false end

	if f then 
    while true do
		  local lines, rest = f:read(BUFSIZE, "*line")
		  if not lines then break end
		  if rest then lines = lines .. rest .. '\n' end
      data = data ..lines
    end
  else
    return "No such file or directory", f
	end
	return data, string.len(data)
end

function io.exists( file )
    local f = io.open( file, "r" )
    if f then
        io.close( f )
        return true
    else
        return false
    end
end

function io.totable(filename,clean)
  local t = {}
	local data, f = load_file(filename)
	if f ~= false then
    if clean then
      for i,v in pairs(string.split(data,'\n')) do
        if string.find(string.trim(v),"#",1,true) ~= 1 then 
          if string.trim(v) ~= "" then
            t[#t+1] = v
          end
        end
      end
      return t
    end
    if data then return string.split(data,'\n') end
  end
  return t
end

--function count_updated()
--	for i, v in ipairs(__TOCHECK) do
--		local uci_val = io.popen("uci get "..v)
--		local uci_value = string.trim(uci_val:read())
--		uci_val:close()
--		if uci_value == nil then uci_value = "" end
--		if __FORM[v] == nil then __FORM[v] = "" end
--		if __FORM[v] ~= uci_value then
--			if __FORM[v] == "" then 
--				os.execute("uci del "..v)
--			else
--				os.execute("uci set "..v.."="..__FORM[v])
--			end
--		end
--		__FORM[v] = __FORM[v] .."-".. uci_value
--	end
--	local i = 0
--	local BUFSIZE = 2^13     -- 8K
--	local filelist = io.popen("ls /tmp/.uci/")
--	for filename in filelist:lines() do
--		local lc = 0
--		local f = io.input("/tmp/.uci/"..filename)   -- open input file
--		while true do
--			local lines, rest = f:read(BUFSIZE, "*line")
--			if not lines then break end
--			if rest then lines = lines .. rest .. '\n' end
--			local _,t = string.gsub(lines, "\n", "\n")
--			lc = lc + t
--		end
--		i = i + lc
--	end
--	return i
--end

--function review(page)
--	self:update_count()
--	menu.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
--	page.title = tr("Review Changes").." ("..config.updated.count..")"
--	page.action_apply = ""
--	page.action_review = ""
--	page.action_clear = ""
--	
--	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
--	print(page:header())
--	for k,t in pairsByKeys(self.updated) do
--		if type(t) == "table" then
--			local form = formClass.new(k,true)
--			print (form:startFullForm())
--			print(return_page,"<br>")
--			for i, linea in pairs(t) do
--				print (linea,"<br>")
--			end
--			print (form:endForm())
--		end
--	end
--	print(page:footer())
--	os.exit()
--end

--function apply(page)
--	self.updated.count = 0
--	menu.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
--	page.title = tr("Updating config")
--	page.action_apply = ""
--	page.action_review = ""
--	page.action_clear = ""
--	page.savebutton ="<input type=\"submit\" name=\"continue\" value=\"Continue\" style=\"width:150px;\" />"
--	print(page:header())
--	changes_apply=io.popen ("/usr/lib/webif/apply.sh 2>&1")
--	for linea in changes_apply:lines() do
--		print(trsh(linea),"<BR>")
--	end
--	changes_apply:close()
--	print(page:footer())
--	os.exit()
--end

--function Show_itable(t,idx)
--	for i=1, #t do
--		if #t[t[i].name]==0 then 
--			print("Tin "..tostring(t),"idx "..tostring(idx),"#t",#t,"Ti"..i..tostring(t[i]),"Ti"..i.."name",t[i].name,"value",tostring(t[i].value),#t[t[i].name],"<br>")
--			print(t[i].name,t[i].value," - ",__SERVER.SCRIPT_NAME," - ",__SERVER.SCRIPT_FILENAME," - ",__SERVER.REQUEST_URI,"<BR>")			
--		else
--			if type(t[t[i].name]) == "table" then
--				Show_itable(t[t[i].name],i)
--			end
--		end
--	end
--end

--function Show_table(menu,idx)
--	if idx == nil then idx = 0 end
--	local idxl = idx
--	space=string.rep(".....",idxl)
--	for i,v in pairs(menu) do
--		if type(v)=="table" then
--			s,t = pairs(v)
--			Show_table(t,idxl+1)
--		else
--			print(space,i,v,"<BR>")
--		end
--	end
----	print("<BR>")
--end

--function table_show(t,i,j)
--	if i == nil then i = 0 end
--	if j == nil then j = 0 end
--	local n = j
--	local idx = i
--	sep = string.rep(".",idx)
--	for k, v in pairs(t) do
--		n = n +1
--		if type(v) == "table" then
--			print (sep,"New Table<BR>")
--			table_show(v,idx+1,n)
--			print("<BR>")
--		else
--			print (n,sep,k,v)
--		end
--	end
--end

-- To read a tables sort by Keys
function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
end
-- Input Table output string
function listtovars(strlist,cnt)
	local t = {}
	for col in string.gmatch(strlist, "%S+") do
		col = string.gsub (col, "'", "")
		col = string.gsub (col, '"', "")
		table.insert(t,col)
	end
	local tlen = table.maxn(t)
	if tlen ~= nil then
		for i=cnt+1, tlen do
			t[cnt]=t[cnt].." "..t[i]
		end
	end 
	return unpack(t)
end

function string.totable(strlist)
	local t = {}
	for col in string.gmatch(strlist, "%S+") do
		col = string.gsub (col, "'", "")
		col = string.gsub (col, '"', "")
    t[#t+1] = col
	end
	return t
end

function string.trim (str)
	if str == nil then return "" end
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function string.split(str,sep)
	local t = {}
	local ini = 1
	local seplen = string.len(sep)
	local len = string.len(str)
	local iend= string.find(str,sep,ini,true)
	if iend == nil then iend = len+1 end
	repeat
		t[#t+1] = string.trim(string.sub(str,ini,iend-1))
		ini = iend+seplen
		iend = string.find(str,sep,ini,true)
	until iend == nil
	if ini <= len+1 then 
		t[#t+1] = string.trim(string.sub(str,ini))
	end
	return t
end

function string.capital(s)
	return s:gsub("%a", string.upper, 1)
end

function get_vars()
	local var = {}
	var["DOCUMENT_ROOT"] = os.getenv("DOCUMENT_ROOT") -- The root directory of your server 

	var["HTTP_COOKIE"] = os.getenv("HTTP_COOKIE") -- The visitor's cookie, if one is set 
	var["HTTP_HOST"] = os.getenv("HTTP_HOST") -- The hostname of the page being attempted 
	var["HTTP_REFERER"] = os.getenv("HTTP_REFERER") -- The URL of the page that called your program 
	var["HTTP_USER_AGENT"] = os.getenv("HTTP_USER_AGENT") -- The browser type of the visitor 

	var["HTTPS"] = os.getenv("HTTPS") -- "on" if the program is being called through a secure server 
	
	var["PATH"] = os.getenv("PATH") -- The system path your server is running under 

	var["QUERY_STRING"] = os.getenv("QUERY_STRING") -- The query string (see GET, below) 

	var["REMOTE_ADDR"] = os.getenv("REMOTE_ADDR") -- The IP address of the visitor 
	var["REMOTE_HOST"] = os.getenv("REMOTE_HOST") -- The hostname of the visitor (if your server has reverse-name-lookups on; otherwise this is the IP address again) 
	var["REMOTE_PORT"] = os.getenv("REMOTE_PORT") -- The port the visitor is connected to on the web server 
	var["REMOTE_USER"] = os.getenv("REMOTE_USER") -- The visitor's username (for .htaccess-protected pages) 
	
	var["REQUEST_METHOD"] = os.getenv("REQUEST_METHOD") -- GET or POST 
	var["REQUEST_URI"] = os.getenv("REQUEST_URI") -- The interpreted pathname of the requested document or CGI (relative to the document root) 

	var["SCRIPT_FILENAME"] = os.getenv("SCRIPT_FILENAME") -- The full pathname of the current CGI 
	var["SCRIPT_NAME"] = os.getenv("SCRIPT_NAME") -- The interpreted pathname of the current CGI (relative to the document root) 

	var["SERVER_ADMIN"] = os.getenv("SERVER_ADMIN") -- The email address for your server's webmaster 
	var["SERVER_NAME"] = os.getenv("SERVER_NAME") -- Your server's fully qualified domain name (e.g. www.cgi101.com)  
	var["SERVER_PORT"] = os.getenv("SERVER_PORT") -- The port number your server is listening on 
	var["SERVER_SOFTWARE"] = os.getenv("SERVER_SOFTWARE") -- The server software you're using (e.g. Apache 1.3)  
	return var
end

function get_post()
	local post = {}
	local char = string.char(255)
	local lowchar = string.char(0)
	local data = os.getenv("QUERY_STRING")
	if os.getenv("REQUEST_METHOD") == "GET" then char = "=" end
	local key, value
	collectgarbage()
	if data==nil or data=="" then
		data = io.stdin:read"*a"
		data = string.gsub(data,"[-]+%x+%s+%w+[-]%w+[:]%s+%w+[-]%w+[;]%s+%w+[=]\"","&")
		data = string.gsub(data,"[-][-][-]+%x+[-][-]","")
		data = string.sub(data,2)
		data = string.gsub(data,"\"%s", char)
	end
	for l in string.gmatch(data,"[^&]+") do
		l = string.gsub(l,"["..char.."]%s+",char)
		_, _, key, value = string.find(l, "(.+)%s*["..char.."]%s*(.*)")
		key = string.trim(key)
		value = string.trim(value)
		if key ~= nil then
			if string.match(key,"val_str_") then __TOCHECK[#__TOCHECK+1]=string.sub(key,9) end
			if string.match(key,"UCI_CMD_") then
        __UCI_CMD[#__UCI_CMD+1]={}
        __UCI_CMD[#__UCI_CMD]["cmd"] = string.sub(key,9)
        __UCI_CMD[#__UCI_CMD].cmd = string.sub(__UCI_CMD[#__UCI_CMD].cmd,1,3)
        if __UCI_CMD[#__UCI_CMD].cmd == nil or __UCI_CMD[#__UCI_CMD].cmd == "" then
          __UCI_CMD[#__UCI_CMD].cmd = "show"
        end
        __UCI_CMD[#__UCI_CMD].varname = string.sub(key,12)
        __UCI_CMD[#__UCI_CMD].value = value 
      end
      if string.match(key, "UCI_MSG_") then
        __UCI_MSG[#__UCI_MSG+1] = {}
        __UCI_MSG[#__UCI_MSG]["cmd"] = string.sub(key,9,11)
--        __UCI_MSG[#__UCI_MSG]["cmd"] = string.sub(__UCI_MSG[#__UCI_MSG]["cmd"],9,11)
        __UCI_MSG[#__UCI_MSG]["var"] = string.sub(key,12)
        __UCI_MSG[#__UCI_MSG]["val"] = value
      end
			post[key]=value
		end
	end
	return post
end

function uname_load()
	local t = {}
	local tt = {}
	local uname = {}
	uname_file = io.open("/tmp/iw/uname_tmp")
	if uname_file == nil then
		os.execute("uname -a > /tmp/uname_tmp")
		os.execute("uname -v >> /tmp/uname_tmp")
		uname_file = io.open("/tmp/uname_tmp")
	end
	for linea in uname_file:lines() do
		table.insert(t,linea)
	end
	uname["a"] = t[1]	
	uname["v"] = t[2]
	local tmp = string.gsub(t[1],t[2],"")
	for tmpv in string.gmatch(tmp, "%S+") do
		table.insert(tt,tmpv)
	end
	local idx = {"s","n","r","m","p"}
	for i,v in pairs(idx) do
		uname[v]=tt[i]
	end
	return uname
end

-- Load values of device
function sys_info_load()
	local sys = {}
	local cpu = {}
	local idx = 0
	for name in io.lines("/proc/sys/kernel/hostname") do
		sys["hostname"] = name;
--		print("Hostname",hostname,"<BR>")
	end
	info = io.popen("cat /proc/cpuinfo")
-- | sed -e 's/: /:/' -e 's/. *:/:/' -e 's/ :/:/' -e 's/ /_/' -e 's/	//' -e 's/:/ /'")
	sys["cpu"] = {}
--	for linea in info:lines() do
--		_, _, key, value = string.find(linea, "(.+)%s*[:]%s*(.*)")
--		key = string.trim(key)
--		key = string.gsub(key," ", "_")
--		value = string.trim(value)
--		sys["cpu"][key]=value
--	end
--	info:close()
--	sys["if"] = {}
--	info = io.popen("/sbin/ifconfig 2>/dev/null | grep 'Link' | sed -e 's/ .* HWaddr//'")
--	for linea in info:lines() do
--		local ifname, ifmac = listtovars(linea,2)
--		sys["if"][ifname]=ifmac
--	end
--	info:close()

--	sys["iw"] = {}
--	info = io.popen("/usr/sbin/iwconfig")
--	for linea in info:lines() do
--		idx = print(linea,"<BR>")
--	end		
--	info:close()

--	info = io.popen("uptime | sed -e 's/.* up//' -e 's/ load .*://' -e 's/,//g' -e 's/ d/_d/'")
	info = io.popen("uptime")
	for linea in info:lines() do
		local i,e = string.find(linea,"load average: ")
		sys["loadavg"]=string.sub(linea,e)
		sys["uptime"]=string.sub(linea,11,i-2)
--		local days, time, load_avg = listtovars(linea,3)
--		days = string.gsub(days,"_"," ")
--		sys["uptime"]=string.format("%s %s",days,time)
--		sys["loadavg"]=load_avg
	end		
	info:close()
	return sys
end
-- Table of availables NIC
function get_interfaces()
	t={}
	info = io.popen("/sbin/ifconfig 2>/dev/null | grep -A 1 'Link' | sed -e 's/ .* HWaddr//' | sed -e ")
	for linea in info:lines() do
		local ifname, ifmac = listtovars(linea,2)
		t[ifname]=ifmac
	end
	info:close()
	return t
end

function get_ifname(netname)
  for i,v in pairs(get_interfaces) do
    print(i,v,"<br>")
  end
end

function get_wireless()
  local t = {}
  local wifi = uciClass.new("wireless")
  for i=1, #wifi["wifi-iface"] do
    t[#t+1]={}
    for k,v in pairs(wifi["wifi-iface"][i].values) do
      t[#t][k] = v
    end
    for k,v in pairs(wifi[wifi["wifi-iface"][i].values.device]) do
      t[#t][k] = v
    end
  end
  print("aca va")
  for i=1, #t do
    for k,v in pairs(t[i]) do
      print (k,v)
    end
  end
  return t
end