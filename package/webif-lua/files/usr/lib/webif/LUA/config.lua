--------------------------------------------------------------------------------
-- config.lua
--
-- Description:
--        Setting Framwork VARS and load require functions.
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti .
--       fofware@users.berlios.de
--
-- Configuration files referenced:
--   none
--------------------------------------------------------------------------------
package.cpath = "./?.so;/usr/lib/lua/5.1/?.so" 
package.path = "./?.lua;/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua" 
--package.path = package.path .. ";/usr/lib/webif/LUA/?.lua;/usr/lib/webif/LUA/pkgs/?.lua;/usr/share//lua/5.1/?.lua"
-- Common Functions
require("common")
require("lpkg")
local pkg = lpkgClass.new("uci")
if pkg.uci ~= nil then
  if pkg.uci.Installed ~= neil then
    __UCI_VERSION = pkg.uci.Installed.Version
  end
end

require("uciUpdated")
__WORK_STATE = {"Warning... WORK NOT DONE... Not usefull...","Warning... Work in progress...","Warning... Work Not Tested","Warning... Work in Test"}
__WIP = 0 
__ERROR   = {} -- __ERROR[#__ERROR][var_name], __ERROR[#__ERROR][msg]
__TOCHECK = {} -- __TOCHECK[#__TOCHECK]
__UCI_CMD = {} -- __UCI_CMD[#__UCI_CMD]["command"], __UCI_CMD[#__UCI_CMD_]["varname"]
__SERVER  = get_vars()
__FORM    = get_post()
__SYSTEM  = loadsystemconf()
require("translator")
tr_load()
__UCI_UPDATED = uciUpdatedClass.new()
pbadata = ""
-- Functions to make forms
require("form")
-- Functions to manipulate UCI Files
require("iw-uci")
-- Functions to manipulate Packages
require ("checkpkg")
-- Function to validate form values
require("validate")
-- Functions for menu
require("menu")
__MENU = menuClass.new()
if string.match(__SERVER.SCRIPT_NAME,"webif") then
  __MENU:loadXWRT()
end
-- menu   = menuClass.new()
-- menu:loadXWRT_Category()
require("x-wrt-page")

--config = uciclass.new(nil)
-- validate_post()
page = pageClass.new("Prueba")

