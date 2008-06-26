#!/usr/bin/lua
require("set_path")
require("init")
require("uci_iwaddon")
local coovadir = uci.get_type("coovachilli","coovadir")
local str_set="#### This conf file was writed by iw-apply for coova-chilli ####\n"
for x,y in pairs(coovadir) do
  for k, v in pairs(y) do
    if k ~= ".type"
    and k ~= ".name" then
      str_set = str_set..k.."="..v.."\n"
    end
  end
end

local chillisettings = uci.get_type("coovachilli","settings")
for x,y in pairs(chillisettings) do
  for k, v in pairs(y) do
    if k ~= ".type"
    and k ~= ".name" then
      if string.match(v,"%s") then v = "\""..v.."\"" end
--      if k == "HS_LOC_NAME"
--      or k == "HS_LOC_NETWORK" then
--        str_set = str_set..k.."=\""..v.."\"\n"
--      else
        str_set = str_set..k.."="..v.."\n"
--      end
    end
  end
end
print(str_set)
local conf_file ="#### This conf file was writed by iw-apply for chillispot ####\n"
local chillisetting = uci.get_type("chillispot","settings")
for n=1, #chillisetting do
  for k,v in pairs(chillisetting[n]) do
    if k ~= ".type"
    and k ~= ".name" then
      if k == "debug"
      or k == "macauth"
      or k == "uamanydns"
      or k == "coanoipcheck"
      or k == "acctupdate"
      or k == "fg"
      or k == "eapolenable" then
        if tonumber(v) == 1 then
          conf_file = conf_file .. k .. "\n"
        end
      else
        conf_file = conf_file .. k .. " " .. v .. "\n"
      end
    end
  end
end
print(conf_file) 
