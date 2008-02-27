include $(TOPDIR)/rules.mk

PKG_NAME:=iw-freeradius
PKG_VERSION:=0.001
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/iw-freeradius
  SECTION:=admin
  CATEGORY:=Administration
  SUBMENU:=webif
  DEPENDS:=+webif-lua
  TITLE:=Freeradius Administrative Console in LUA for X-Wrt.
endef

define Package/iw-freeradius/description
 Basic Freeradius Administrative Console in LUA for X-Wrt.
endef

define Build/Compile
endef

define Package/iw-freeradius/install
	$(CP) -a ./files/* $(1)/
	chmod -R 755 $(1)/*
	$(CP) -a ./ipkg/iw-freeradius.postinst $(1)/CONTROL/preinst
	chmod 755 $(1)/CONTROL/*inst
	find $(1) -name CVS | xargs rm -rf
	find $(1) -name .svn | xargs rm -rf
	find $(1) -name *~ | xargs rm -rf
endef

$(eval $(call BuildPackage,iw-freeradius))
