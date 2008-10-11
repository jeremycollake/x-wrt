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
