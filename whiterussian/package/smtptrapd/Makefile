#
# Copyright (C) 2008 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smtptrapd
PKG_VERSION:=1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://smtptrapd.inodes.org
PKG_MD5SUM:=edc5f2f3ea9f9bdd9e0f479a58903bf1
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,SMTPTRAPD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-D_REENTRANT \
		$(PKG_BUILD_DIR)/smtptrapd.c \
		-o $(PKG_BUILD_DIR)/smtptrapd \
		-lpthread
	touch $@

$(IPKG_SMTPTRAPD):
	install -d -m0755 $(IDIR_SMTPTRAPD)/etc/init.d
	install -m0755 files/smtptrapd.init $(IDIR_SMTPTRAPD)/etc/init.d/smtptrapd
	install -d -m0755 $(IDIR_SMTPTRAPD)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/smtptrapd $(IDIR_SMTPTRAPD)/usr/sbin/
	$(RSTRIP) $(IDIR_SMTPTRAPD)
	$(IPKG_BUILD) $(IDIR_SMTPTRAPD) $(PACKAGE_DIR)
