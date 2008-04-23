package.cpath = "?;./?.so;/usr/lib/lua/5.1/?.so" 
package.path = "?;./?.lua;/usr/local/share/lua/5.1/iw/?.lua;/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/lib/lua/5.1/?.lua" 
__WWW = os.getenv("SCRIPT_NAME")
require("common")

__SYSTEM  = loadsystemconf()

require("lpkg")
local pkg = lpkgClass.new("uci")
if pkg.uci ~= nil then
  if pkg.uci.Installed ~= nil then
    __UCI_VERSION = pkg.uci.Installed.Version
  end
end


require("translator")
tr_load()
-- Functions to manipulate UCI Files
require("iw-uci")
-- Functions to manipulate Packages
require ("checkpkg")
if __WWW then
  __WORK_STATE = {"Warning... WORK NOT DONE... Not usefull...","Warning... Work in progress...","Warning... Work Not Tested","Warning... Work in Test"}
  __WIP = 0 
  __ERROR   = {} -- __ERROR[#__ERROR][var_name], __ERROR[#__ERROR][msg]
  __TOCHECK = {} -- __TOCHECK[#__TOCHECK]
  __UCI_CMD = {} -- __UCI_CMD[#__UCI_CMD]["command"], __UCI_CMD[#__UCI_CMD_]["varname"]
  __SERVER  = get_vars()
--  if __SERVER.SCRIPT_NAME == nil then __SERVER.SCRIPT_NAME = "pba.sh"
--  else
  __FORM    = get_post()
--  end
  require("uciUpdated")
  __UCI_UPDATED = uciUpdatedClass.new()
  pbadata = ""
-- Functions to make forms
  require("form")
-- Function to validate form values
  require("validate")
-- Functions for menu
  require("menu")
__MENU = menuClass.new()
  if __SERVER.SCRIPT_NAME then
    if string.match(__SERVER.SCRIPT_NAME,"webif") then
      __MENU:loadXWRT()
    end
  end
-- menu   = menuClass.new()
-- menu:loadXWRT_Category()
  require("x-wrt-page")

--config = uciclass.new(nil)
-- validate_post()
  if page == nil then
  page = pageClass.new("Prueba")
  if __FORM.__ACTION=="clear_changes"  then __UCI_UPDATED:clear()  end
	if __FORM.__ACTION=="apply_changes"  then __UCI_UPDATED:apply() end
	if __FORM.__ACTION=="review_changes" then __UCI_UPDATED:review() end
--	if __FORM.__ACTION==tr("Save Changes") then config:save() end
  end
end
