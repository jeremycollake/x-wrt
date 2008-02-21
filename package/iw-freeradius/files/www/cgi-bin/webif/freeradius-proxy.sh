#!/usr/bin/lua
--
--##WEBNOIF:name:IW:250:Freeradius
--
dofile("/usr/lib/webif/LUA/config.lua")
local freeradius_pkg = pkgInstalledClass.new("freeradius,freeradius-mod-files,freeradius-mod-chap,freeradius-mod-radutmp,freeradius-mod-realm",true)
require("files/freeradius-menu")
freeradius = uciClass.new("freeradius-proxy")
if freeradius.server == nil then server = freeradius:set("server") else server = freeradius.server end
server_cfg = server[1].name
server_val = server[1].values

page.title = tr("Freeradius Clients")
print(page:header())
local form = formClass.new("Server Settings")
form:Add("select",server_cfg..".synchronous",server_val.synchronous,"Synchronous","string")
form[server_cfg..".synchronous"].options:Add("no",tr("No"))
form[server_cfg..".synchronous"].options:Add("yes",tr("Yes"))
form:Add("text",server_cfg..".retry_delay",server_val.retry_delay,"Retry Delay","int")
form:Add("text",server_cfg..".retry_count",server_val.retry_count,"Retry Count" ,"int")
form:Add("text",server_cfg..".dead_time",server_val.dead_time,"Dead Time" ,"int")
form:Add("select",server_cfg..".default_fallback",server_val.default_fallback,"Default Fallback","string")
form[server_cfg..".default_fallback"].options:Add("yes",tr("Yes"))
form[server_cfg..".default_fallback"].options:Add("no",tr("No"))
form:Add("select",server_cfg..".post_proxy_authorize",server_val.post_proxy_authorize,"Post proxy authorize","string")
form[server_cfg..".post_proxy_authorize"].options:Add("no",tr("No"))
form[server_cfg..".post_proxy_authorize"].options:Add("yes",tr("Yes"))
form:Add("link","add_community",__SERVER.SCRIPT_NAME.."?".."UCI_CMD_setfreeradius-proxy=realm&__menu="..__FORM.__menu,tr("Add Community"))
form:print()
form = formClass.new("Comunities Settings")
if freeradius.realm ~= nil then
for i = 1, #freeradius.realm do
  realm_cfg = freeradius.realm[i].name
  realm_val = freeradius.realm[i].values
  local name = realm_val.community
  if name == nil then name = "New Community" end
  form:Add("subtitle","&nbsp;"..name)
  form:Add("text",realm_cfg..".community", realm_val.community,"Community","string","width:99%")
--  form:Add("text",realm_cfg..".type", realm_val.type,"Type","string","width:99%")

  form:Add("select",realm_cfg..".type",realm_val.type,"Type","string")
  form[realm_cfg..".type"].options:Add("radius",tr("Radius"))

  form:Add("text",realm_cfg..".authhost", realm_val.authhost,"authhost","string","width:99%")
  form:Add("text",realm_cfg..".accthost", realm_val.accthost,"accthost","string","width:99%")
  form:Add("text",realm_cfg..".secret", realm_val.secret,"secret","string","width:99%")
  form:Add("checkbox",realm_cfg..".nostrip", realm_val.nostrip,"No Strip","string","width:99%")
--  form:Add("text",realm_cfg..".strip", realm_val.strip,"strip","string","width:99%")
--  form:Add("text",realm_cfg..".ldflag", realm_val.ldflag,"ldflag","string","width:99%")
  form:Add("select",realm_cfg..".ldflag",realm_val.ldflag,"ldflag","string")
  form[realm_cfg..".ldflag"].options:Add("",tr("&nbsp;"))
  form[realm_cfg..".ldflag"].options:Add("fail_over",tr("Fail over"))
  form[realm_cfg..".ldflag"].options:Add("round_robin",tr("Round robin"))
  form:Add("link","remove"..realm_cfg,__SERVER.SCRIPT_NAME.."?".."UCI_CMD_del"..realm_cfg.."=&__menu="..__FORM.__menu,tr("Remove Community"))
end
end
form:print()
print(page:footer())
