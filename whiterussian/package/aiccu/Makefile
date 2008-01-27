#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=aiccu
PKG_VERSION:=20070115
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.sixxs.net/archive/sixxs/aiccu/unix
PKG_MD5SUM:=c9bcc83644ed788e22a7c3f3d4021350
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,AICCU,aiccu,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	$(SED) "s,strip,$(STRIP)," $(PKG_BUILD_DIR)/unix-console/Makefile
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC=$(TARGET_CC) \
	        CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE -DAICCU_CONSOLE -DHAS_IFHEAD -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib -lpthread" \
		DEBUG=0
	touch $@

$(IPKG_AICCU):
	mkdir -p $(IDIR_AICCU)/usr/sbin
	install -m 755 $(PKG_BUILD_DIR)/unix-console/$(PKG_NAME) $(IDIR_AICCU)/usr/sbin/
	mkdir -p $(IDIR_AICCU)/etc/init.d
	install -m 644 ./files/aiccu.conf $(IDIR_AICCU)/etc/
	install -m 755 ./files/aiccu.init $(IDIR_AICCU)/etc/init.d/S51aiccu
	$(RSTRIP) $(IDIR_AICCU)
	$(IPKG_BUILD) $(IDIR_AICCU) $(PACKAGE_DIR)
