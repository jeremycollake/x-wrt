# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=util-linux
PKG_VERSION:=2.12r
PKG_RELEASE:=1
PKG_MD5SUM:=c261230b27fc0fbcc287c76884caf2d3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.kernel.org/pub/linux/utils/$(PKG_NAME)/ \
	http://ftp.kernel.org/pub/linux/utils/$(PKG_NAME)/ \
	ftp://ftp.de.kernel.org/pub/linux/utils/$(PKG_NAME)/ \
	http://ftp.de.kernel.org/pub/linux/utils/$(PKG_NAME)/

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_CAT:=zcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,FDISK,fdisk,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LOSETUP,losetup,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,SWAP_UTILS,swap-utils,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)/lib" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	$(MAKE) -C $(PKG_BUILD_DIR) \
		OPT="$(TARGET_CFLAGS) -I$(PKG_BUILD_DIR)/lib" \
		INSTALLSUID="install -m 4755" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_FDISK):
	install -d -m0755 $(IDIR_FDISK)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/fdisk $(IDIR_FDISK)/usr/sbin
	$(RSTRIP) $(IDIR_FDISK)
	$(IPKG_BUILD) $(IDIR_FDISK) $(PACKAGE_DIR)

$(IPKG_LOSETUP):
	install -d -m0755 $(IDIR_LOSETUP)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/losetup $(IDIR_LOSETUP)/usr/sbin
	$(RSTRIP) $(IDIR_LOSETUP)
	$(IPKG_BUILD) $(IDIR_LOSETUP) $(PACKAGE_DIR)

$(IPKG_SWAP_UTILS):
	install -d -m0755 $(IDIR_SWAP_UTILS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/mkswap $(IDIR_SWAP_UTILS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/swapon $(IDIR_SWAP_UTILS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/swapoff $(IDIR_SWAP_UTILS)/usr/sbin
	$(RSTRIP) $(IDIR_SWAP_UTILS)
	$(IPKG_BUILD) $(IDIR_SWAP_UTILS) $(PACKAGE_DIR)

