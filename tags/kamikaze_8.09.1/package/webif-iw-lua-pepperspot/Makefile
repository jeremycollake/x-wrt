include $(TOPDIR)/rules.mk

PKG_NAME:=webif-iw-lua-pepperspot
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/webif-iw-lua-pepperspot
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+haserl +lua +liblua +libuci-lua +luac +webif-iw-lua
  TITLE:=This package is a webif to help you to configure chillispot, coova-chilli or peperspot in LUA
endef

define Build/Compile
endef

define Package/webif-iw-lua-pepperspot/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
#	$(CP) -a ./ipkg/webif-iw-lua-pepperspot.postinst $(1)/CONTROL/postinst

	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,webif-iw-lua-pepperspot))
