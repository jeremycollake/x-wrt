strform = {}
local P = {}
strform = P

local print = print
local string = string
local ipairs = ipairs

setfenv(1, P)

local style = ""
local script = ""
local checked = ""
local str = ""

function set_style (t)
	if t.style == nil then return "" end
	if t.style ~= "" then 
		return "style=\""..t.style.."\" "
	else
		return ""
	end
end

function set_script (t)
	if t.script == nil then return "" end
	if t.script ~= "" then 
		return t.style
	else
		return ""
	end
end

function set_checked (t,op)
	if (op ~= nil) then
		if string.trim(op.value) == string.trim(t.value) then 
			if t.input == "radio" then
				return " checked "
			elseif t.input == "select" then
				return " selected=\"selected\" "
			end
		end
	end
	if t.input == "checkbox" then
		if t.checked == nil then t.checked = "1" end
		if string.trim(t.value) == string.trim(t.checked) then 
			return " checked=\"checked\" " 
		end
	end
	return ""
end

function set_validate(t)
	local str = ""
	if t.validate ~= "" then
		str = str .. "<input type=\"hidden\" name=\"val_str_"..t.name.."\" value=\""..t.validate.."\" />"
		str = str .. "<input type=\"hidden\" name=\"val_lbl_"..t.name.."\" value=\""..t.label.."\" />"
	end
	return str
end

function set_values (t)
	style = set_style(t)
	script = set_script(t)
	checked = set_checked(t)
	str = set_validate(t)
end

function checkbox (t)
	set_values(t)
	str = str .. "<input type=\"checkbox\" name=\""..t.name.."\" value=\"1\""..style.." "..script.." "..checked.."/>"
	return str
end

function text_box (t)
	set_values(t)
	str = str .. "<input type=\"text\" name=\""..t.name.."\" value=\""..t.value.."\" "..style.." "..script.." />"
	return str
end

function button (t)
	set_values(t)
	str = str .. "<input type=\"text\" name=\""..t.name.."\" value=\""..t.value.."\" "..style.." "..script.." />"
	return str
end

function radio (t)
	set_values(t)
	for v,op in ipairs(t.options) do
		checked = set_checked(t,op)
		str = str .. "<input type=\"radio\" name=\""..t.name.."\" value=\""..op.value.."\""..set_checked(t,op)..style.." "..script.." />"..op.label.."\n"
	end
	return str
end

function hidden (t)
	set_values(t)
	str = str .. "<input type=\"hidden\" name=\""..t.name.."\" value=\""..t.value.."\" />\n"
	return str
end

function disabled_text(t)
	set_values(t)
	str = str .. "<input type=\"text\" name=\""..t.name.."\" value=\""..t.value.."\" "..style.." "..script.." disabled=\"disabled\"/>\n"
	return str
end

function text_area(t)
	set_values(t)
	str = str .. "<TEXTAREA name=\""..t.name.."\" rows=\"6\" wrap=\"off\" "..style.." "..script.." >"..t.value.."</TEXTAREA>\n"
	return str
end

function password(t)
	set_values(t)
	str = str .. "<input type=\"password\" name=\""..t.name.."\" value=\""..t.value.."\" "..style.." "..script..">\n"
	return str
end

function select(t)
	set_values(t)
	str = str .. "<select name=\""..t.name.."\" "..style.." "..script..">\n"
	for v,op in ipairs(t.options) do
			str = str .. "\t<option value=\""..op.value.."\""..set_checked(t,op)..">"..op.label.."</option>"
	end
	str = str .. "</select>\n"
	return str
end


return strform