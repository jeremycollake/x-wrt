#!/usr/bin/lua
require("set_path")
require("uci_iwaddon")
require("net")
--[[
systemoption = 2
  if systemoption > 0 then
    local selected = nil
    if systemoption == 1 then
      selected = "lan"
    elseif systemoption == 2 then
      selected = "wifi"
    elseif systemoption == 3 then
      selected = "lan"
    end
    local netname = selected
    local networks = net.networks()

    local ipcalc = nil
    if networks[selected] == nil then 
      uci.check_set("network","wifi","interface");
      uci.check_set("network","wifi","proto","static");
      uci.check_set("network","wifi","type","bridge");
      uci.save("network")
      networks = net.networks()
    end
    
    if networks[selected].type == "bridge" then
      netname = "br-"..networks[netname][".name"]
    end

    if networks[selected].ipaddr ~= nil
    and networks[selected].netmask then
      ipcalc = net.ipcalc(networks[selected].ipaddr,networks[selected].netmask)
    end

    if systemoption == 1 
    or systemoption == 3 then 
      uci.set("chillispot","settings","net",ipcalc.NETWORK.."/"..ipcalc.NETMASK)
      uci.set("chillispot","webadmin","netmask",ipcalc.NETMASK)
      uci.set("chillispot","settings","uamlisten",networks[selected].ipaddr)
    else
      uci.delete("chillispot","webadmin","netmask")
      uci.delete("chillispot","settings","net")
      uci.delete("chillispot","settings","uamlisten")
    end

    dhcp = uci.get_all("dhcp")
    if dhcp[selected] ~= nil then
      uci.set("dhcp",selected,"ignore","1")
      uci.save("dhcp")
    end
    if systemoption > 1 then
      local allwifi = uci.get_all("wireless")
      local wifi = uci.get_type("wireless","wifi-iface")
      local wifidev = nil
      if wifi then
        if #wifi == 1 then
          wifidev = wifi[1]
        else
          for i=1, #wifi do 
            if wifi[i].network == selected then
              wifidev = wifi[i]
              break
            end
          end
          if wifidev == nil then
            for i=1,#wifi do
              if allwifi[wifi[i].device].disabled == "1" then
                wifidev = wifi[i]
                break
              end
            end
          end
          if wifidev == nil then
            wifidev = wifi[1]
          end
        end
      end
      uci.set("wireless",wifidev.device,"disabled","0")
      uci.set("wireless",wifidev[".name"],"network",selected)
--      for i, t in pairs(wifidev) do
--        print(i,t)
--        for k,v in pairs(t) do
--          print("",k,v)
--        end
--      end
      print("done...")
      print("")
    end
  end
pepe = uci.changes()
for i, t in pairs(pepe) do
  print(i)
  for k, v in pairs(t) do
    print("",k)
    for m, n in pairs(v) do
      print("","",m,n)
      if type(n) == "table" then
        for u,c in pairs(n) do
          print("","","",u,c)
        end
      end
    end
  end
  print("")
end
]]--
myfirewall = uci.get_all_types("firewall")
-- myfirewall = uci.get_all("firewall")
for i,t in pairs(myfirewall) do
  print(i,t)
  for k, v in pairs(t) do
    print("",k,v)
  end
end
 