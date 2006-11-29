# $Id: Makefile 4885 2006-10-02 17:38:17Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=busybox_micro
PKG_RELEASE:=6

ifeq ($(strip $(BR2_PACKAGE_BUSYBOX_MICRO_SNAPSHOT)),y)
# Be aware that this changes daily....
PKG_VERSION:=0.${shell date +"%G%m%d"}
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_SOURCE:=busybox-snapshot.tar.bz2
PKG_SOURCE_URL:=http://www.busybox_micro.net/downloads/snapshots
PKG_MD5SUM:=x
else
PKG_VERSION:=1.2.1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=busybox-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.busybox_micro.net/downloads
PKG_MD5SUM:=362b3dc0f2023ddfda901dc1f1a74391
endif
PKG_CAT:=bzcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,BUSYBOX_MICRO,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	$(SCRIPT_DIR)/gen_busybox_config.pl $(TOPDIR)/.config > $(PKG_BUILD_DIR)/.config
	yes '' | $(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" -C $(PKG_BUILD_DIR) oldconfig
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" PREFIX="$(IDIR_BUSYBOX_MICRO)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(PKG_BUILD_DIR)
	touch $@

$(IPKG_BUSYBOX_MICRO):
	$(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" PREFIX="$(IDIR_BUSYBOX_MICRO)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(PKG_BUILD_DIR) install
	$(STRIP) $(IDIR_BUSYBOX_MICRO)/bin/busybox
	$(IPKG_BUILD) $(IDIR_BUSYBOX_MICRO) $(PACKAGE_DIR)
