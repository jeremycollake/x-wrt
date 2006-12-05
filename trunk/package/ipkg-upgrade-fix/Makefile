#

include $(TOPDIR)/rules.mk

PKG_NAME:=ipkg-upgrade-fix
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,IPKG_UPGRADE_FIX,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_IPKG_UPGRADE_FIX): 
	install -d $(IDIR_IPKG_UPGRADE_FIX)/bin		
	$(CP) -a ./files/* $(IDIR_IPKG_UPGRADE_FIX)/
	chmod -R 755 $(IDIR_IPKG_UPGRADE_FIX)/*	
	find $(IDIR_IPKG_UPGRADE_FIX) -name CVS | xargs rm -rf
	find $(IDIR_IPKG_UPGRADE_FIX) -name .svn | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_IPKG_UPGRADE_FIX) $(PACKAGE_DIR)
