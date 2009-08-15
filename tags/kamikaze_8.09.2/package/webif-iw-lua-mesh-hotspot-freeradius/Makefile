include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua-mesh-hotspot-freeradius
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua-mesh-hotspot-freeradius
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+haserl +lua +liblua +libuci-lua +luac +webif-iw-lua
  TITLE:=Chillispot Configuration Script in LUA
endef

define Build/Compile
endef

define Package/webif-iw-lua-mesh-hotspot-freeradius/install
	$(CP) -a ./files/* $(1)/
	$(INSTALL_BIN) ./files/www/cgi-bin/webif/* $(1)/www/cgi-bin/webif/
endef

$(eval $(call BuildPackage,webif-iw-lua-mesh-hotspot-freeradius))
