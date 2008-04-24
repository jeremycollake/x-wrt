include $(TOPDIR)/rules.mk

PKG_NAME:=webif-mesh-hotspot-setup
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

define Package/webif-mesh-hotspot-setup
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif-lua
  TITLE:=XWrt Mesh-Network and HotSpot configuration pages
endef

define Build/Compile
endef

define Package/webif-mesh-hotspot-setup/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
	$(CP) -a ./ipkg/webif-mesh-hotspot-setup.postinst $(1)/CONTROL/preinst
	$(CP) -a ./ipkg/webif-mesh-hotspot-setup.postrm $(1)/CONTROL/postrm
	chmod 755 $(1)/CONTROL/*inst
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,webif-mesh-hotspot-setup))
