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
__MENU.IW.ChilliSpot:Add("chilli_menu_Core#Core","chillispot.sh")
__MENU.IW.ChilliSpot:Add("chilli_menu_DHCP#DHCP","chillispot.sh?option=dhcp")
__MENU.IW.ChilliSpot:Add("chilli_menu_Portal#Portal","chillispot.sh?option=portal")
__MENU.IW.ChilliSpot:Add("chilli_menu_Radius#Radius","chillispot.sh?option=radius")
__MENU.IW.ChilliSpot:Add("chilli_menu_Access#Access","chillispot.sh?option=access")
__MENU.IW.ChilliSpot:Add("chilli_menu_Proxy#Proxy","chillispot.sh?option=proxy")
__MENU.IW.ChilliSpot:Add("chilli_menu_Scripts#Scripts","chillispot.sh?option=scripts")
