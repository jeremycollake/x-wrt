chkconflict = {}
local P = {}
chkconflict = P
-- Import Section:
-- declare everything this package needs from outside
local io = io
local os = os
local assert = assert
local string = string
local load_file = load_file
local page = page
local print = print

local menuClass = menuClass
local __UCI_VERSION = __UCI_VERSION
local formClass = formClass
local __SERVER = __SERVER
local __FORM = __FORM
local __MENU = __MENU
local tr = tr
-- no more external access after this point
setfenv(1, P)


function check(pkg_list)
	local count = 0
	local checked = {}
	local data = load_file("/usr/lib/ipkg/status")
	for pkg in string.gmatch(pkg_list,"[^,]+") do
		if string.find(data,"Package: "..pkg,1,true) then
			checked[#checked+1] = pkg
		end
	end
  if #checked > 0 then
    remove(checked)
  end
  return false
end

function remove(tpackages)
	__MENU.selected = string.gsub(__SERVER.REQUEST_URI,"(.*)_changes&(.*)","%2")
	page.title = tr("Need Remove").." ("..#tpackages..") packages..."
	page.action_review = ""
	local pkg_title = ""
	page.savebutton ="<input type=\"submit\" name=\"bt_pkg_remove\" value=\"Remove\" style=\"width:150px;\" />"

	print(page:header())
	local form = formClass.new(tr("Packages to Remove"))
  for i = 1, #tpackages do
		form:Add("checkbox","pkg_toremove_"..tpackages[i],1,"Remove "..tpackages[i],"")
	end
	form:print()
	print(page:footer())
	os.exit()
end
