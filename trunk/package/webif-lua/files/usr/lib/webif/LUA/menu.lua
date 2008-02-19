--------------------------------------------------------------------------------
-- menu.lua
--
-- Description: library of framework
--      library to menu functions
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
menuClass = {} 
menuClass_mt = {__index = menuClass} 

function menuClass.new () 
	local self = {}
	setmetatable(self,menuClass_mt)
	self["selected"] = ""
--	self["html"] = "" 
	return self 
end 

function menuClass:print() 
  print(self) 
end 

function menuClass:Add(name,val)
	if val == nil then val = "" end
	if self[name]==nil or name == "-" then
		self[#self+1] = {}
		self[#self]["name"] = name
		self[#self]["value"]= val
		self[name]=self[#self]
	else
		self[name]=val
		for i=1, #self do
			if self[i].name==name then 
				self[i].value = val
				break
			end
		end
	end

end

function menuClass:Show()
	print ("<Table border=\"1\">")
	print ("<tr>")
	print ("<td>i</td>")
	print ("<td>v.name</td>")
	print ("<td>v.value</td>")
	print ("<td>self[v.name][1].name</td>")
	print ("<td>self[v.name][1].value</td>")
	print ("<td>v</td>")
	print ("<tr>")
	for i,v in ipairs(self) do
		if (v.name) ~= "-" then
			print ("<tr><td>");
			print(i)
			print("</td><td>")
			print (v.name)
			print("</td><td>")
			print (v.value)
			print ("</td><td>")
			if self[v.name][1] ~= nil then
				print (self[v.name][1].name)
				print ("</td><td>")
				print (self[v.name][1].value)
				print ("</td><td>")
			else
				print (type(self[v.name]))
				print ("</td><td>")
				print (type(self[v.name]))
				print ("</td><td>")
			end
			print (v)
			print ("</td><tr>")
		end
	end
	self:ShowT()
end

function menuClass:ShowT()
	print ("</Table>")
	print ("<Table border=\"1\">")
	print ("<tr>")
	print ("<td>i</td>")
	print ("<td>v[1].name</td>")
	print ("<td>v[1].value</td>")
	print ("<td>v[1][v[1].name]</td>")
	print ("<td>self[v.value]</td>")
	print ("<td>v</td>")
	print ("</tr>")
	for i,v in pairs(self) do
		if type(i) == "string" and i ~= "-" then
			print ("<tr><td>");
			print(i)
			print("</td><td>")
			if v[1] ~= nil then
				print (v[1].name)
				print("</td><td>")
				print (v[1].value)
				print ("</td><td>")
			else
				print (v[1])
				print("</td><td>")
				print (v[1])
				print ("</td><td>")
			end
			print (v[v.name])
			print ("</td><td>")
			print (self[v.value])
			print ("</td><td>")
			print (v)
			print ("</td></tr>")
		end
	end
	print ("</Table>")
end

function menuClass:tohtml()
	local typemenu = "mainmenu"
	local t = self
	local _strMenu = ""
	local menupath =""
	local mymenu=""
	local submenucount = 0
	collectgarbage ("collect")
	if __FORM.__ACTION == nil or string.trim(__FORM.__ACTION) == tr("Save Changes") then
	if __FORM.__menu~=nil and __FORM.__menu ~= "" then
		for m in string.gmatch(__FORM.__menu,"[^:]+") do
			mymenu, menupath = self:selmenu(t,typemenu,menupath,m)
			submenucount = submenucount + 1
			_strMenu = _strMenu..mymenu
			t = t[t[tonumber(m)].name]
			typemenu = "submenu"
		end
	else
		mymenu, menupath = self:selmenu(t,typemenu,menupath)
		submenucount = submenucount + 1
		_strMenu = _strMenu..mymenu
		if menupath then
		if t[tonumber(menupath)] ~= nil then
			t = t[t[tonumber(menupath)].name]
		else t = nil end
		end
		typemenu = "submenu"
	end		
	if t ~= nil and type(t)=="table" then
		repeat 
			if type(t) == "table" and t[1] ~= nil then
				mymenu, menupath = self:selmenu(t,typemenu,menupath,1) 
				submenucount = submenucount + 1
				_strMenu = _strMenu..mymenu 
			end
			if t[1] ~= nil then
				if t[1].name ~= nil then
					t = t[t[1].name] 
				else
					t = nil
				end
			else
				t = nil
			end
		until t==nil
	end
	end
	if submenucount == 0 then submenucount = 7
	else submenucount = submenucount + 8.03 + (submenucount-1) * 0.85 end
newstyle =[[
	<style type='text/css'>
	<!--
	#colorswitcher {
	position: absolute;
	top: ]]..submenucount..[[em;
	right: 1.5em;
	z-index: 100;
	}
	-->
	</style>
]]
	return _strMenu..newstyle
end

function menuClass:selmenu(menu,menutype,menupath,sel)
	local vars
	if vars == nil then vars = get_vars() end
	local _strMenu=""
	if sel~=nil then 
		sel = tonumber(sel)
	end
	if sel == 0 then sel = nil end
	menupath = string.trim(menupath)
	if string.len(menupath) > 0 then
		menupath = menupath .. ":"
	end 
	_strMenu = "<div id=\""..menutype.."\"><ul>"
	for i,v in ipairs(menu) do
		local injectpath = ""
		local option = ""
		local link = v.value
		if link == nil or link == "" then
			link = self:get_link(menu[v.name])
		end
		if sel == nil and string.match(__SERVER.SCRIPT_NAME,link) == link then sel = i end
--		local pepe = string.find(__SERVER.SCRIPT_NAME,link,1,true)
--		if sel == nil and pepe ~= nil and pepe > 1 then sel = i end
		link, option = unpack(string.split(link,"?"))
		if option == nil then option = ""
		else option = "&"..option end
		if i == sel then 
			_strMenu = _strMenu.."<li class=\"selected\"><a href=\""..link.."?__menu="..menupath..i..option.."\">"..tr(v.name).."</a></li>"
			self.selected = "__menu="..menupath..i..tostring(option)
			sel = i
 		else
			if v.name == "-" then 
				_strMenu = _strMenu.."<li class=\"separator\">-</li>"
			else
				_strMenu = _strMenu.."<li><a href=\""..link.."?__menu="..menupath..i..option.."\">"..tr(v.name).."</a></li>"
			end
		end
	end
	_strMenu = _strMenu.."</ul></div>"
	if sel ~= nil then menupath = menupath ..sel end
	return _strMenu, menupath
end

function menuClass:get_selected(prev)
	local t = self
	local idx
	local tt = {}
	if prev == nil then prev = 1 end
	for v in string.gmatch(__FORM.__menu,"[^%:]+") do
		tt[#tt+1] = v
	end
	for i=1,#tt-prev do
		t = t[t[ tonumber(tt[i]) ].name]
	end
	idx = t[ tonumber(tt[#tt-prev+1]) ].name
	return t, idx
end

function menuClass:get_link(t)
	local ret=""
	if type(t) == "table" then
		if t[1] ~= nil then
			local a, b = pairs(t[1])
			if t[1].value == "" or t[1].value == nil then
				return self:get_link(t[b.name])
			else 
				return t[1].value
			end
		end
	else
		return "Error no es tabla"
	end
	return "No entro en ningun lado"
end

function menuClass:loadXWRT()
	for linea in io.lines("/www/cgi-bin/webif/.categories") do
		linea = string.gsub(linea,"%##WEBIF:category:","")
		self:Add(linea)
	end
	self:loadXWRT_Subcategory(self)
end	

function menuClass:loadXWRT_Subcategory()
	local t = {}
	listfile = io.popen("ls /www/cgi-bin/webif/")
	for i in listfile:lines() do

		local data = ""
		local BUFSIZE = 2^15
		local f = io.input(i)   -- open input file
		while true do
			local lines, rest = f:read(BUFSIZE, "*line")
			if not lines then break end
			if rest then lines = lines .. rest .. '\n' end
			local ini = string.find(lines,"##WEBIF")
			if ini then 
				lines = string.sub(lines,ini)
				ini = string.find(lines,"\n")
				if ini then lines = string.sub(lines,1,ini-1) end
				lines = string.sub(lines,14)..":"..i
--				print (lines,"<br>")
--				lines = string.gsub(lines,"(.*)WEBIF:(%a*):(.-)", "%3")
				local mcategory, morder, mname, mvalue = unpack(string.split(lines,":"))
				if mcategory ~= "Graphs" then 
					if t[mcategory] == nil then
						t[mcategory] = {}
						t[mcategory][morder]= {}
					end
					if t[mcategory][morder] == nil then
						t[mcategory][morder] = {}
					end
					t[mcategory][morder]["name"]=mname
					t[mcategory][morder]["value"]=mvalue
				else
					if t[mcategory] == nil then
						t[mcategory] = {}
						t[mcategory][morder]= {}
					end
					if t[mcategory][morder] == nil then
						t[mcategory][morder] = {}
					end
					t[mcategory][morder]["name"]="CPU Graphs"
					t[mcategory][morder]["value"]="/cgi-bin/webif/graphs-cpu.sh"
				end
				break
			end
		end
		f:close()
	end
	listfile:close()
	for category, order in pairsByKeys(t) do
		if self[category] == nil then
			self:Add(category)
		end
		self[category] = menuClass.new()
		for i,v in pairsByKeys(order) do
			self[category]:Add(v.name,v.value)
		end
	end
end


function menuClass:tb_find(menu,name)
	for i,v in ipairs(menu) do
		if v.name == name then
			return v
		end
	end
	return nil
end
