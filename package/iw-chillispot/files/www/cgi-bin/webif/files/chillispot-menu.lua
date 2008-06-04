--------------------------------------------------------------------------------
-- chillispot-menu.lua
-- This script is writen in LUA, the extension is ".sh" for compatibilities
-- reasons width menu system of X-Wrt
--
-- Description:
--        Administrative console to Chillispot
--
-- Author(s) [in order of work date]:
--       Fabián Omar Franzotti
--         
-- Configuration files referenced:
--    hotspot
--
--------------------------------------------------------------------------------
__MENU.IW.ChilliSpot = menuClass.new()
__MENU.IW.ChilliSpot:Add("chilli_menu_Core#Core","chillispot1.sh")
__MENU.IW.ChilliSpot:Add("chilli_menu_DHCP#DHCP","chillispot1.sh?option=dhcp")
__MENU.IW.ChilliSpot:Add("chilli_menu_Portal#Portal","chillispot1.sh?option=portal")
__MENU.IW.ChilliSpot:Add("chilli_menu_Radius#Radius","chillispot1.sh?option=radius")
__MENU.IW.ChilliSpot:Add("chilli_menu_Access#Access","chillispot1.sh?option=access")
__MENU.IW.ChilliSpot:Add("chilli_menu_Proxy#Proxy","chillispot1.sh?option=proxy")
__MENU.IW.ChilliSpot:Add("chilli_menu_Scripts#Scripts","chillispot1.sh?option=scripts")
__WIP = 4