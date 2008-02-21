#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("freeradius-menu")
freeradius = uciClass.new("freeradius-modules")
--if freeradius.client == nil then client = freeradius:set("client") else client = freeradius.client end
page.title = tr("Freeradius Modules")
print(page:header())
print([[
	<style type='text/css'>
	<!--
	#content {
	position: relative;
	padding: 0 2% 6.5em 2%;
	height:100%;
  }
  #vmenu {
    float:left;
    height:100%;
  	line-height: 2.0em;
    width:200px;
    position:relative;
  	font-size: 0.8em;
    text-decoration: none;
/*
  	color: gray;
    background-color:#315579; 
*/
  }

  #vmenu a:hover { 
    background-color: #aac1d9;
    color:white; 
  }

  #vmenu .selected a {
    background-color: #224054; 
  }
  
  #vmenu li {
	list-style-type: none;
	width: 200px;
	text-align: left;
  }
  #vmenu li a {
    text-decoration: none;
	padding: 0 0.7em 0 0.7em;
	display: block;
	color: black;
  }

-->
  </style>
]])
print([[<div style="height:100%;width:100%;position:relative;">]])
print([[<div ID="vmenu">]])
print("<ul>")
local section = {}
for i,t in pairs(freeradius.sections) do
  local name = ""
  if not string.match(t.name,"cfg") then name = t.name end
  if __FORM.section == t.name then
    print([[<li class="selected"><a href="]]..__SERVER.SCRIPT_NAME..[[?section=]]..t.name..[[&__menu=]]..__FORM.__menu..[[">]]..t.group.." "..name.."</a></li>")
    section = t
  else
    print([[<li><a href="]]..__SERVER.SCRIPT_NAME..[[?section=]]..t.name..[[&__menu=]]..__FORM.__menu..[[">]]..t.group.." "..name.."</a></li>")
  end
----  for k,v in pairs(t.values) do
----    k = string.gsub(k,"%_%_%_","-")
----    print("&nbsp;",k,v,"<br>")
----  end
----  print("<br>")
end
print("<ul>")
print("</div>")

print([[<div style="float:left;height:100%;position:relative;">]])

form = formClass.new(section.group.." "..section.name)
for k,v in pairs(section.values) do
  k = string.gsub(k,"%_%_%_","-")
  form:Add("text",k,v,k,"string","width:99%")
end

--form:Add("text","pepe","","pepo")
form:Add_help("text","pepe adfasdf asdf asdf asdfasdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf asdf adsfpepo")
form:print()
print("</div>")
print("</div>")
print(page:footer())
