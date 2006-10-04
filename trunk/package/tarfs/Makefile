#

include $(TOPDIR)/rules.mk

PKG_NAME := tarfs
PKG_RELEASE := 1
PKG_VERSION := 0.2
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,TARFS,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:	
	$(CP) -r ./files $(PKG_BUILD_DIR)/
	touch $@

$(IPKG_TARFS): 
	$(CP) -a $(PKG_BUILD_DIR)/files/* $(IDIR_TARFS)/
	$(IPKG_BUILD) $(IDIR_TARFS) $(PACKAGE_DIR)
