# int2human

include $(TOPDIR)/rules.mk

PKG_NAME := int2human
PKG_RELEASE := 3

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,INT2HUMAN,$(PKG_NAME),$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(TARGET_CC) $(TARGET_CFLAGS) \
		$(TARGET_CFLAGS_EXTRA) \
		$(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/int2human \
		main.c human_readable.c
	touch $@

$(IPKG_INT2HUMAN): 
	install -d -m0755 $(IDIR_INT2HUMAN)/sbin
	install -m0755 $(PKG_BUILD_DIR)/int2human $(IDIR_INT2HUMAN)/sbin
	$(RSTRIP) $(IDIR_INT2HUMAN)/usr/sbin/*
	$(IPKG_BUILD) $(IDIR_INT2HUMAN) $(PACKAGE_DIR)
