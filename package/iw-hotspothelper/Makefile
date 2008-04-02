include $(TOPDIR)/rules.mk

PKG_NAME:=iw-hotspothelper
PKG_VERSION:=0.001-Beta
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/iw-hotspothelper
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif-lua
  TITLE:=HotSpot helper settings
endef

define Build/Compile
endef

define Package/iw-hotspothelper/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip
#	$(CP) -a ./ipkg/iw-hotspothelper.postinst $(1)/CONTROL/preinst
#	$(CP) -a ./ipkg/iw-hotspothelper.postrm $(1)/CONTROL/postrm
#	chmod 755 $(1)/CONTROL/*inst
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,iw-hotspothelper))
