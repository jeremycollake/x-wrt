# $Id: Makefile 3198 2006-02-09 03:21:01Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME := flashfs
PKG_RELEASE := 1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,FLASHFS,$(PKG_NAME),$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:	
	cp flashfs.sh $(PKG_BUILD_DIR)/flashfs.sh
	touch $@

$(IPKG_FLASHFS): 
	install -d -m0755 $(IDIR_FLASHFS)/sbin
	install -m0755 $(PKG_BUILD_DIR)/flashfs.sh $(IDIR_FLASHFS)/sbin
	$(RSTRIP) $(IDIR_FLASHFS)/sbin/*
	$(IPKG_BUILD) $(IDIR_FLASHFS) $(PACKAGE_DIR)
