#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=base-files-uci
PKG_VERSION:=0
PKG_RELEASE:=4

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,BASE_FILES_UCI,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.prepared:
	mkdir -p $(PKG_BUILD_DIR)
	touch $@
	
$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	touch $@

$(IPKG_BASE_FILES_UCI): 
	$(CP) -a ./files/* $(IDIR_BASE_FILES_UCI)/
	chmod -R 755 $(IDIR_BASE_FILES_UCI)/*
	find $(IDIR_BASE_FILES_UCI) -name .svn | xargs rm -rf
	find $(IDIR_BASE_FILES_UCI) -name *~ | xargs rm -rf
	$(IPKG_BUILD) $(IDIR_BASE_FILES_UCI) $(PACKAGE_DIR)
