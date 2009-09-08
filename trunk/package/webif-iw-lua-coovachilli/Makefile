include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua-coovachilli
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua-coovachilli
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif-iw-lua
  TITLE:=coovachilli Configuration Script in LUA
endef

define Build/Compile
endef

define Package/webif-iw-lua-coovachilli/install
	$(CP) -a ./files/* $(1)/
	$(INSTALL_BIN) ./files/etc/init.d/chilli $(1)/etc/init.d/chilli
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/applys/* $(1)/usr/lib/lua/lua-xwrt/applys/
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/pkgs/coovaportal.lua $(1)/usr/lib/lua/lua-xwrt/pkgs/coovaportal.lua
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/pkgs/coovachilli/* $(1)/usr/lib/lua/lua-xwrt/pkgs/coovachilli/
	$(INSTALL_BIN) ./files/www/cgi-bin/webif/* $(1)/www/cgi-bin/webif/
	$(INSTALL_BIN) ./files/www/cgi-bin/login/* $(1)/www/cgi-bin/login/
endef

$(eval $(call BuildPackage,webif-iw-lua-coovachilli))
