include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua-olsr
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua-olsr
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+haserl +lua +liblua +libuci-lua +luac +webif-iw-lua
  TITLE:=Olsrd configuration Script in LUA
endef

define Build/Compile
endef

define Package/webif-iw-lua-olsr/install
	$(CP) -a ./files/* $(1)/
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/applys/* $(1)/usr/lib/lua/lua-xwrt/applys/
	$(INSTALL_DIR) ./files/usr/lib/lua/lua-xwrt/pkgs/ $(1)/usr/lib/lua/lua-xwrt/pkgs/
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/pkgs/olsr/* $(1)/usr/lib/lua/lua-xwrt/pkgs/olsr/
	$(INSTALL_BIN) ./files/www/cgi-bin/webif/* $(1)/www/cgi-bin/webif/
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
endef

$(eval $(call BuildPackage,webif-iw-lua-olsr))
