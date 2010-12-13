include $(TOPDIR)/rules.mk

PKG_NAME:=webif-theme-urbalink
PKG_VERSION:=0.3
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)


include $(INCLUDE_DIR)/package.mk

define Package/webif-theme-urbalink
  SECTION:=admin
  CATEGORY:=Urbalink
  SUBMENU:=Configuracion para todos
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  TITLE:=Urbalink theme for webif^2
  PKGARCH:=all
endef

define Package/webif-theme-urbalink/description
  Urbalink customized theme for webif^2
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) -a files ipkg/* $(PKG_BUILD_DIR)
	find $(PKG_BUILD_DIR)/files -name 'CVS' -o -name '.svn' -o -name '*~' | $(XARGS) rm -rf
endef

define Build/Compile
endef

define Package/webif-theme-urbalink/install
	$(CP) -a $(PKG_BUILD_DIR)/files/* $(1)/
endef

$(eval $(call BuildPackage,webif-theme-urbalink))
