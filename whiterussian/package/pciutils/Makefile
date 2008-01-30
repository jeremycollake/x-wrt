# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pciutils
PKG_VERSION:=2.2.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.kernel.org/pub/software/utils/pciutils/ \
	ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci
PKG_MD5SUM:=c18e2a5f04e9abae5a42439de294f086
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,PCIUTILS,pciutils,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		OPT="$(TARGET_CFLAGS)" \
		PREFIX="/usr" \
		HOST="$(GNU_TARGET_NAME)"
	touch $@

$(IPKG_PCIUTILS): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_PCIUTILS)/usr/sbin
	install -m0755 $(PKG_BUILD_DIR)/lspci $(IDIR_PCIUTILS)/usr/sbin/
	install -m0755 $(PKG_BUILD_DIR)/setpci $(IDIR_PCIUTILS)/usr/sbin/
	install -m0755 ./files/update-pciids $(IDIR_PCIUTILS)/usr/sbin/
	install -d -m0755 $(IDIR_PCIUTILS)/usr/share
	install -m0644 $(PKG_BUILD_DIR)/pci.ids $(IDIR_PCIUTILS)/usr/share/
	$(RSTRIP) $(IDIR_PCIUTILS)/
	$(IPKG_BUILD) $(IDIR_PCIUTILS) $(PACKAGE_DIR)
