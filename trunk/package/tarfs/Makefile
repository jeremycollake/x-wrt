# $Id: Makefile 3198 2006-02-09 03:21:01Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME := tarfs
PKG_RELEASE := 1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,TARFS,$(PKG_NAME),$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $@
	touch $@

$(PKG_BUILD_DIR)/.built:	
	cp ./tarfs $(PKG_BUILD_DIR)/tarfs
	touch $@

$(IPKG_TARFS): 
	install -d -m0755 $(IDIR_TARFS)/sbin
	install -m0755 $(PKG_BUILD_DIR)/tarfs $(IDIR_TARFS)/sbin	
	$(RSTRIP) $(IDIR_TARFS)/sbin/*
	$(IPKG_BUILD) $(IDIR_TARFS) $(PACKAGE_DIR)
