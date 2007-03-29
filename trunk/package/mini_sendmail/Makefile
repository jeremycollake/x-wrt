#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=mini-sendmail
PKG_VERSION:=1.3.5
PKG_RELEASE:=1
PKG_MD5SUM:=fff344184e98cff0ea4d817da9d29383

PKG_SOURCE:=mini_sendmail-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.acme.com/software/mini_sendmail/
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/mini_sendmail-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,MINI_SENDMAIL,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		OFLAGS="$(TARGET_CFLAGS)" \
		all
	touch $@

$(IPKG_MINI_SENDMAIL):
	install -m0755 -d $(IDIR_MINI_SENDMAIL)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/mini_sendmail $(IDIR_MINI_SENDMAIL)/usr/sbin/
	ln -sf mini_sendmail $(IDIR_MINI_SENDMAIL)/usr/sbin/sendmail
	$(RSTRIP) $(IDIR_MINI_SENDMAIL)
	$(IPKG_BUILD) $(IDIR_MINI_SENDMAIL) $(PACKAGE_DIR)
