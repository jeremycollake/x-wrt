# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=e2fsprogs
PKG_VERSION:=1.39
PKG_RELEASE:=1
PKG_MD5SUM:=06f7806782e357797fad1d34b7ced0c6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/e2fsprogs

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_CAT:=zcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,E2FSPROGS,e2fsprogs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,LIBUUID,libuuid,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,TUNE2FS,tune2fs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,RESIZE2FS,resize2fs,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
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
		--enable-shared \
		--enable-static \
		--disable-rpath \
		--enable-elf-shlibs \
		--enable-dynamic-e2fsck \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	$(MAKE) -C $(PKG_BUILD_DIR)/util \
		BUILDCC="$(HOSTCC)" \
		CFLAGS="" \
		CPPFLAGS="" \
		LDFLAGS="" \
		subst
	$(MAKE) -C $(PKG_BUILD_DIR) \
		BUILDCC="$(HOSTCC)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_E2FSPROGS): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_E2FSPROGS)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/mke2fs.conf $(IDIR_E2FSPROGS)/etc
	install -d -m0755 $(IDIR_E2FSPROGS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/e2fsck $(IDIR_E2FSPROGS)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/mke2fs $(IDIR_E2FSPROGS)/usr/sbin/
	ln -sf mke2fs $(IDIR_E2FSPROGS)/usr/sbin/mkfs.ext2
	ln -sf mke2fs $(IDIR_E2FSPROGS)/usr/sbin/mkfs.ext3
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/badblocks $(IDIR_E2FSPROGS)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/e2label $(IDIR_E2FSPROGS)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/filefrag $(IDIR_E2FSPROGS)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/logsave $(IDIR_E2FSPROGS)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/mklost+found $(IDIR_E2FSPROGS)/usr/sbin/
	install -d -m0755 $(IDIR_E2FSPROGS)/usr/lib
	$(CP) $(foreach lib,blkid com_err e2p ext2fs,$(PKG_INSTALL_DIR)/usr/lib/lib$(lib).so.*) $(IDIR_E2FSPROGS)/usr/lib/
	$(RSTRIP) $(IDIR_E2FSPROGS)
	$(IPKG_BUILD) $(IDIR_E2FSPROGS) $(PACKAGE_DIR)

$(IPKG_LIBUUID): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_LIBUUID)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libuuid.so.* $(IDIR_LIBUUID)/usr/lib/
	$(RSTRIP) $(IDIR_LIBUUID)
	$(IPKG_BUILD) $(IDIR_LIBUUID) $(PACKAGE_DIR)

$(IPKG_TUNE2FS): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_TUNE2FS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/tune2fs $(IDIR_TUNE2FS)/usr/sbin/
	$(RSTRIP) $(IDIR_TUNE2FS)
	$(IPKG_BUILD) $(IDIR_TUNE2FS) $(PACKAGE_DIR)

$(IPKG_RESIZE2FS): $(PKG_BUILD_DIR)/.built
	install -d -m0755 $(IDIR_RESIZE2FS)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/resize2fs $(IDIR_RESIZE2FS)/usr/sbin/
	$(RSTRIP) $(IDIR_RESIZE2FS)
	$(IPKG_BUILD) $(IDIR_RESIZE2FS) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/{libblkid,libcom_err,libext2fs,libe2p,libss,libuuid}.{a,so}*: $(PKG_BUILD_DIR)/.built
	$(MAKE) -C $(PKG_BUILD_DIR) \
		BUILDCC="$(HOSTCC)" \
		DESTDIR="$(STAGING_DIR)" \
		root_libdir="$(STAGING_DIR)/usr/lib" \
		install-libs
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/{libblkid,libcom_err,libext2fs,libe2p,libss,libuuid}.{a,so}*

uninstall-dev:
	rm -rf $(STAGING_DIR)/usr/include/blkid
	rm -f $(STAGING_DIR)/usr/lib/libblkid.{a,so}*
	rm -rf $(STAGING_DIR)/usr/include/et
	rm -f $(STAGING_DIR)/usr/lib/libcom_err.{a,so}*
	rm -rf $(STAGING_DIR)/usr/include/ext2fs
	rm -f $(STAGING_DIR)/usr/lib/libext2fs.{a,so}*
	rm -rf $(STAGING_DIR)/usr/include/e2p
	rm -f $(STAGING_DIR)/usr/lib/libe2p.{a,so}*
	rm -rf $(STAGING_DIR)/usr/include/ss
	rm -f $(STAGING_DIR)/usr/lib/libss.{a,so}*
	rm -rf $(STAGING_DIR)/usr/include/uuid
	rm -f $(STAGING_DIR)/usr/lib/libuuid.{a,so}*
	rm -f $(STAGING_DIR)/usr/lib/pkgconfig/{blkid,com_err,ext2fs,e2p,ss,uuid}.pc
	rm -f $(STAGING_DIR)/usr/bin/{compile_et,mk_cmds}
	rm -f $(STAGING_DIR)/usr/share/et/et_{c,h}.awk
	rm -f $(STAGING_DIR)/usr/share/ss/ct_c.{awk,sed}
	rm -f $(STAGING_DIR)/usr/share/man/man1/{compile_et.*,mk_cmds.*}
	rm -f $(STAGING_DIR)/usr/share/man/man3/{com_err.*,libblkid.*,uuid_*.*,uuid.*}

compile-targets: install-dev
clean-targets: uninstall-dev

mostlyclean:
	-$(MAKE) -C $(PKG_BUILD_DIR) clean
	rm -f $(PKG_BUILD_DIR)/.built
