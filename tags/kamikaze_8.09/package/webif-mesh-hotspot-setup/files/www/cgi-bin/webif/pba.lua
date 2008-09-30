#!/usr/bin/lua
print("Compile files... to save space")
local IPKG_INSTROOT = os.getenv("IPKG_INSTROOT") or ""
local IPKG_CONF_DIR = os.getenv("IPKG_CONF_DIR") or ""
local IPKG_OFFLINE_ROOT = os.getenv("IPKG_OFFLINE_ROOT") or ""
local path = {}
path[1] = "/usr/share/internet-wifi/lib/"
path[2] = "/usr/share/internet-wifi/pkgs/"
path[3] = "/usr/share/internet-wifi/applys/"
for i=1, #path do
  local libdir = io.popen("ls "..IPKG_INSTROOT..path[i])
  for file in libdir:lines() do
    if string.match(file,".lua") then
      io.write("Compilling "..file)
      local out = string.gsub(file,".lua",".out")
      if os.execute("luac -s -o "..IPKG_INSTROOT..path[i]..file.." "..IPKG_INSTROOT..path[i]..file) == 0 then
        print("..OK!!!")
      else
        print(" ERROR!!")
      end
    end
  end
end
