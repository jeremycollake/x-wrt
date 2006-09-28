# $Id $

include $(TOPDIR)/rules.mk

PKG_NAME := wepkeygen
PKG_RELEASE := 1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,WEPKEYGEN,$(PKG_NAME),$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(TARGET_CC) $(TARGET_CFLAGS) \
		$(TARGET_CFLAGS_EXTRA) \
		$(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/wepkeygen \
		keygen.c md5.c
	touch $@

$(IPKG_WEPKEYGEN): 
	install -d -m0755 $(IDIR_WEPKEYGEN)/sbin
	install -m0755 $(PKG_BUILD_DIR)/wepkeygen $(IDIR_WEPKEYGEN)/sbin
	$(RSTRIP) $(IDIR_WEPKEYGEN)/sbin/*
	$(IPKG_BUILD) $(IDIR_WEPKEYGEN) $(PACKAGE_DIR)
