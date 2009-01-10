include $(TOPDIR)/rules.mk

PKG_NAME:=m-route
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/m-route
  SECTION:=admin
  CATEGORY:=Network
#  SUBMENU:=
  DEPENDS:=+ip
  TITLE:=Load Balancing scrip for Multi Wan Connections
endef

define Build/Compile
endef

define Package/m-route/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	rm -rf $(1)/usr/lib/webif/lang/
	rm -f $(1)/www/cgi-bin/webif/*.wip

	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,webif-iw-lua-olsr))
