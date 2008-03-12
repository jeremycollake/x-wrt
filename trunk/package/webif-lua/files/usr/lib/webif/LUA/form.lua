--------------------------------------------------------------------------------
-- form.lua
--
-- Description: library of framework
--      Library to manipulate forms
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
inputoptionsClass = {} 
inputoptionsClass_mt = {__index = inputoptionsClass} 

function inputoptionsClass.new () 
	local self = {}
	setmetatable(self,inputoptionsClass_mt) 
	return self 
end
 
function inputoptionsClass:Add(str_value,str_label)
	self[#self+1] = {}
	self[#self]["value"] = str_value
	self[#self]["label"] = str_label
	self[str_value]=self[#self]
end

formClass = {} 
formClass_mt = {__index = formClass} 

function formClass.new (str_title,bool_full) 
	local self = {}
	setmetatable(self,formClass_mt) 
	self["title"] = str_title or "Title of Form"
	self["__help"] = {}
	self["__help_link"] = ""
	self["__full"]=bool_full or false
	return self 
end 

function formClass:print (name)
	print(self:tostring(name))
end

function formClass:tostring(name)
	if name ~= nil then 
		if self[name].input == "text" then
			return self:text(self[name])
		elseif self[name].input == "checkbox" then
			return self:checkbox(self[name])
		elseif self[name].input == "password" then
			return self:password(self[name])
		elseif self[name].input == "select" then
			return self:select(self[name])
		elseif self[name].input == "button" then
			return self:button(self[name])
		elseif self[name].input == "hidden" then
			return self:hidden(self[name])
		elseif self[name].input == "subtitle" then
			return self:subtitle(self[name])
		elseif self[name].input == "link" then
			return self:link(self[name])
		elseif self[name].input == "uci_set_config" then
			return self:uci_set_config(self[name])
		else
			return self:ful_line(self[name])
		end
	else
		local ret = ""
		if self["__full"] == true then
			ret = self:startFullForm()
		else
			ret = self:startForm()
		end
		for i,v in ipairs(self) do
			ret = ret .. self:tostring(v.name)
		end
		ret = ret .. self:endForm()
		return ret
	end
--	if #__ERROR > 0 then 
----		self.__help = {}
--		for i,error in ipairs(__ERROR) do
--			form:Add_help(error["var_name"],error["msg"])
--		end
--	end
end

function formClass:Add(str_input,str_name,str_value,str_label,str_validate,str_style,str_script)
	if str_name == nil or str_name == "" then return false end
	self[#self+1] = {}
	self[#self]["name"]     = str_name
	self[#self]["value"]    = str_value or ""
	self[#self]["label"]    = str_label or str_name
	self[#self]["input"]    = str_input or "text"
	self[#self]["validate"] = str_validate or "string"
	self[#self]["style"]    = str_style or ""
	self[#self]["script"]   = str_script or ""
	self[#self]["checked"]  = str_checked or 1
	self[#self]["options"]  = inputoptionsClass.new()
	self[str_name]=self[#self]
end

function formClass:full_line(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR>"
	str = str .. "<TD colspan=\"2\">"
	str = str .. "<input type=\"text\" name=\""..t.name.."\" value=\""..t.value.."\" "..style..t.script.." />"
	str = str .. "</TD></TR>"
	return str
end

function formClass:subtitle(t)
  return [[<tr><td colspan="2">	<h3><strong>]]..t.name..[[</strong></h3></td></tr>]]
end

function formClass:hidden(t)
	return "<input type=\"hidden\" name=\""..t.name.."\" value=\""..t.value.."\" />"
end

function formClass:link(t)
  return [[<tr><td><a href="]]..t.value..[[">]]..t.label..[[</a></td></tr>]]
end

function formClass:UCI_CMD_link(t)
  
end

function formClass:uci_set_config(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR><TD width=\"40%\">" .. t.label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
  str = str .. "<table cellspacing=\"0\" border=\"0\"><tr><td width=\"80%\">"
  local conf = string.split(t.name,",") 
  for i = 1, #conf do
    str = str .. "<input type=\"hidden\" name=\"UCI_CMD_snw"..conf[i].."\" value=\""..t.value.."\">"
  end
  str = str .. "<input type=\"text\" name=\"UCI_SET_VALUE\""..style..t.script.." />"
  str = str .. "</td><td width=\"20%\">"
	str = str .. "&nbsp;<input type=\"submit\" name=\""..t.name.."\" value=\""..tr("Add").."\""..style..t.script.." />"
  str = str .. "</td></tr></table>"
	str = str .. "</TD></TR>"
	
	return str
end

function formClass:button(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR>"
	if self.__full == true then
		str = str .. "<TD>"
	else
		str = str .. "<TD colspan=\"2\">"
	end
	str = str .. "<input type=\"submit\" name=\""..t.name.."\" value=\""..t.value.."\" "..style..t.script.." />"
	str = str .. "</TD></TR>"
	return str
end

function formClass:text(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR><TD width=\"40%\">" .. t.label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
	if t.validate ~= "" then
	str = str .. "<input type=\"hidden\" name=\"val_str_"..t.name.."\" value=\""..t.validate.."\" />"
	str = str .. "<input type=\"hidden\" name=\"val_lbl_"..t.name.."\" value=\""..t.label.."\" />"
	end
	str = str .. "<input type=\"text\" name=\""..t.name.."\" value=\""..t.value.."\" "..style..t.script.." />"
	str = str .. "</TD></TR>"
	return str
end

function formClass:password(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR><TD width=\"40%\">" .. t.label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
	if t.validate ~= "" then
	str = str .. "<input type=\"hidden\" name=\"val_str_"..t.name.."\" value=\""..t.validate.."\" />"
	str = str .. "<input type=\"hidden\" name=\"val_lbl_"..t.name.."\" value=\""..t.label.."\" />"
	end
	str = str .. "<input type=\"password\" name=\""..t.name.."\" value=\""..t.value.."\" "..style..t.script..">"
	str = str .. "</TD></TR>"
	return str
end

function formClass:select(t)
	local style = ""
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	local str  = "<TR><TD width=\"40%\">" .. t.label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
	if t.validate ~= "" then
	str = str .. "<input type=\"hidden\" name=\"val_str_"..t.name.."\" value=\""..t.validate.."\" />"
	str = str .. "<input type=\"hidden\" name=\"val_lbl_"..t.name.."\" value=\""..t.label.."\" />"
	end
	str = str .. "<SELECT name=\""..t.name.."\" "..style.." "..t.script..">"
	for v,op in ipairs(t.options) do
		if string.trim(op.value) == string.trim(t.value) then 
			str = str .. "<OPTION VALUE=\""..op.value.."\" SELECTED>"..op.label.."</OPTION>"
		else
			str = str .. "<OPTION VALUE=\""..op.value.."\" >"..op.label.."</OPTION>"
		end
	end
	str = str .. "</SELECT>"
	str = str .. "</TD></TR>"
	return str
end

function formClass:checkbox(t)
	local style = ""
	local checked = "" 
	if t.style ~= "" then style = "style=\""..t.style.."\" " end
	if string.trim(t.value) == string.trim(t.checked) then checked = " checked" end
	local str  = "<TR><TD width=\"40%\">" .. t.label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
	if t.validate ~= "" then
	str = str .. "<input type=\"hidden\" name=\"val_str_"..t.name.."\" value=\""..t.validate.."\" />"
	str = str .. "<input type=\"hidden\" name=\"val_lbl_"..t.name.."\" value=\""..t.label.."\" />"
	end
	str = str .. "<input type=\"checkbox\" name=\""..t.name.."\" value=\"1\""..t.style..t.script.." "..checked.."/>"
	str = str .. "</TD></TR>"
	return str
end

function formClass:radio(name,value,label,options,style,script)
	if label == nil then label = name end
	if value == nil then value = "" end
	if style == nil then style = "" end
	if string.trim(value) == string.trim(options) then options = " checked" end
	if script == nil then script = "" end
	local str  = "<TR><TD width=\"40%\">" .. label .. "</TD>"
	str = str .. "<TD width=\"60%\">"
	str = str .. "<input type=\"hidden\" name=\"val_str_"..name.."\" value=\"string\" />"
	str = str .. "<input type=\"hidden\" name=\"val_lbl_"..name.."\" value=\""..label.."\" />"
	str = str .. "<input TYPE=\"radio\" name=\""..name.."\" style=\""..style.."\" "..script.." "..options.."/>"
	str = str .. "</TD></TR>"
	return str
end

function formClass:startForm()
	local str =[[
	<div class="settings">
	<h3><strong>]]..self.title..[[</strong></h3>
	<div class="settings-content">
	<table width="100%">
]]
	return str
end

function formClass:startFullForm()
	local str =[[
	<div class="settings">
	<h3><strong>]]..self.title..[[</strong></h3>
	<table width="100%">
]]
	return str
end

function formClass:endForm()
	local str =[[
	</table>
	</div>
]]
	if self.__full == true then srt = "</table>" 
	else
    local found = false
    local str_error = ""
    if #__ERROR > 0 then
			str_error = str_error..[[<blockquote class="settings-help"><font color="red">]]
			str_error = str_error..[[<h1><strong>]]..tr("Invalid input!!!")..[[</strong></h1>]]
		  for i,error in ipairs(__ERROR) do
		    if self[error.var] ~= nil then
		      found = true
          str_error = str_error .. "<h4>"..error.var_name.." :</h4><p>"..error.msg.."</p>"
        end
		  end
			str_error = str_error.."</font></blockquote>"
    end
    if found then str = str .. str_error end
		if #self.__help > 0 then
			str = str..[[<blockquote class="settings-help">]]
			str = str..[[<h3><strong>tr(Short help) :</strong></h3>]]
			for i, v in ipairs(self.__help) do
				str = str..v
			end
			str = str.."</blockquote>"
		end
	end
	if self.__full == true then
		str = str..[[	<div class="clearfix">&nbsp;</div>]]
	else
		str = str..[[	<div class="clearfix">&nbsp;</div></div> ]]
	end
	return str
end

function formClass:Add_help(title,text)
	if title == nil then title = "Error help title = nil" end
	if text == nil then text = "Error help text = nil" end
	self.__help[#self.__help+1] = "<h4>"..title..":</h4>".."<p>"..text.."</p>"
end

function formClass:Add_help_link(link,text,blanck)
    if blanck == false then blanck = "" else blanck = "target=\"_blanck\" " end
    if link == nil then link = "Error help link = nil" end
    if text == nil then text = "Error help text = nil" end
    self.__help[#self.__help+1] = [[<a class="more-help" href="]]..link..[["]]..blanck..[[ >]]..text..[[...</a>]]
end
