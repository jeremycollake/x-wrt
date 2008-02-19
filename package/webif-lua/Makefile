include $(TOPDIR)/rules.mk

PKG_NAME:=webif-lua
PKG_VERSION:=0.001
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/webif-lua
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif +lua +liblua
  TITLE:=Framework in LUA for X-Wrt. 
  DESCRIPTION:=Basic framewor to XWrt in LUA.
endef

define Build/Compile
endef

define Package/webif-lua/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,webif-lua))
