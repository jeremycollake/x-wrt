include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+haserl +lua +liblua +libuci-lua
  TITLE:=LUA libraries for X-Wrt
endef

define Build/Compile
endef

define Package/webif-iw-lua/install
	$(CP) -a ./files/* $(1)/
	$(INSTALL_BIN) ./files/usr/lib/lua/set_path.lua $(1)/usr/lib/lua/set_path.lua
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/* $(1)/usr/lib/lua/lua-xwrt/
endef

$(eval $(call BuildPackage,webif-iw-lua))
