--[[
--------------------------------------------------------------------------------
-- olsrdata.lua
--
-- Description: library of framework
--      Library to manipulate forms
--
-- Author(s) [in order of work date]:
-- olsrdata is inspired by OLSR-Viz, Lorenz Schori <lo@znerol.ch>
-- and OLSR-Viz is inspired by Wi-viz: http://wiviz.natetrue.com 
-- Mdify and ported to LUA by
--       Fabián Omar Franzotti .
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
]]--

olsrdataClass = {} 
olsrdataClass_mt = {__index = olsrdataClass} 

function olsrdataClass.new () 
	local self = {}
	setmetatable(self,olsrdataClass_mt) 
  self["Links"] = {}
  self["Neighbors"] = {}
  self["Topology"] = {}
  self["HNA"] = {}
  self["MID"] = {}
  self["Routes"] = {}
  local tname = ""
  local tcount = 0
  pepe = io.popen([[wget -q -O - http://127.0.0.1:2006/]])
  for line in pepe:lines() do
    if string.trim(line) == "Table: Links" then
        tcount = 0
        tname = "Links"
    elseif string.trim(line) == "Table: Neighbors" then
        tcount = 0
        tname = "Neighbors"
    elseif string.trim(line) == "Table: Topology" then
        tcount = 0
        tname = "Topology"
    elseif string.trim(line) == "Table: HNA" then
        tcount = 0
        tname = "HNA"
    elseif string.trim(line) == "Table: MID" then
        tcount = 0
        tname = "MID"
    elseif string.trim(line) == "Table: Routes" then
        tcount = 0
        tname = "Routes"
    elseif string.trim(line) == "" then
      tcount = 0
      tname = ""
    else
      if tcount > 0 then
        self[tname][#self[tname]+1] = {}
        for v in string.gmatch(line,"[^\t]+") do
          self[tname][#self[tname]][#self[tname][#self[tname]]+1] = v
        end
      end
      tcount = tcount + 1
    end
  end
	return self 
end

function olsrdataClass:html ()
local str = [[<HTML>
<HEAD>
	<TITLE>OLSR Visualization</TITLE>
	<META CONTENT="text/html; charset=iso-8859-1" HTTP-EQUIV="Content-Type">
	<META CONTENT="no-cache" HTTP-EQUIV="cache-control">
</HEAD>
<BODY>
<script langauge='JavaScript1.2' type='text/javascript'>
	if(parent != window) {
]]
--[[
for n,m in pairs(self) do
  print(n,"<br>")
  for i,j in ipairs(m) do
    for k,v in ipairs(j) do
      print(v,"&nbsp;")
    end
    print("<br>")
  end
end
]]--
for i=1, #self["Links"] do
  str = str .. [[parent.touch_edge(parent.touch_node(']]..self["Links"][i][1]..[[').set_metric(1).update(),parent.touch_node(']]..self["Links"][i][2]..[[').set_metric(1).update(),']]..self["Links"][i][4]..[[');]]
end
--for i,t in ipairs(self["Links"]) do
--  str = str .. [[parent.touch_edge(parent.touch_node(']]..tostring(t[1])..[[').set_metric(1).update(),parent.touch_node(']]..tostring(t[2])..[[').set_metric(1).update(),']]..tostring(t[4])..[[');]]
--end
for i=1, #self["Topology"] do
  str = str .. "parent.touch_edge(parent.touch_node('"..self["Topology"][i][1].."').update(),parent.touch_node('"..self["Topology"][i][2].."').update(),'"..self["Topology"][i][4].."');"
end
--for i,t in ipairs(self["Topology"]) do
--  str = str .. "parent.touch_edge(parent.touch_node('"..t[1].."').update(),parent.touch_node('"..t[2].."').update(),'"..t[4].."');"
--end
for i=1, #self["HNA"] do
  str = str .. "parent.touch_hna(parent.touch_node('"..self["HNA"][i][3].."'),'"..self["HNA"][i][1].."','"..self["HNA"][i][2].."');"
end
for i=1, #self["Routes"] do
  if string.match(self["Routes"][i][1],"%/32") then
    str = str .. "parent.touch_node('"..string.gsub(self["Routes"][i][1],"%/%d+","").."').set_metric('"..self["Routes"][i][2].."').update();"
  end
end

--sed -n "
--s#\($re_ip\)$re_sep\($re_nosep\)$re_sep.*#
--parent.touch_node('\1').set_desc('\2');#p
--" < /etc/hosts

  str = str .. [[
	parent.viz_callback();
	} else {
		document.write("<h4>hmm.... you should not see this</h4>");
	}
  </script>
  </BODY></HTML>
  ]]
  return str
end
 