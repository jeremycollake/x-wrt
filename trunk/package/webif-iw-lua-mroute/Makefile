include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua-mroute
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua-mroute
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+m-route
  TITLE:=M-Route Configuration Script in LUA
endef

define Build/Compile
endef

define Package/webif-iw-lua-mroute/install
	$(CP) -a ./files/* $(1)/
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/applys/* $(1)/usr/lib/lua/lua-xwrt/applys/
	$(INSTALL_BIN) ./files/usr/lib/lua/lua-xwrt/pkgs/* $(1)/usr/lib/lua/lua-xwrt/pkgs/
	$(INSTALL_BIN) ./files/www/cgi-bin/webif/* $(1)/www/cgi-bin/webif/
endef

$(eval $(call BuildPackage,webif-iw-lua-mroute))
