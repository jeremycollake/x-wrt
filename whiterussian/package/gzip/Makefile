#
# Copyright (C) 2007 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gzip
#PKG_VERSION:=1.3.11
PKG_VERSION:=1.3.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME) \
	ftp://wuarchive.wustl.edu/mirrors/gnu/gzip \
	http://www.gzip.org
#PKG_MD5SUM:=a41a6a4b11f941cb7fc13df320f3af5f
PKG_MD5SUM:=b5bac2d21840ae077e0217bc5e4845b1
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,GZIP,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		  --target=$(GNU_TARGET_NAME) \
		  --host=$(GNU_TARGET_NAME) \
		  --build=$(GNU_HOST_NAME) \
		  --program-prefix="" \
		  --program-suffix="" \
		  --prefix=/usr \
		  --exec-prefix=/usr \
		  --bindir=/bin \
		  --datadir=/usr/share \
		  --includedir=/usr/include \
		  --infodir=/usr/share/info \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/lib \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --sbindir=/usr/sbin \
		  --sysconfdir=/etc \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
	)
	touch $@

$(PKG_BUILD_DIR)/.built:
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_GZIP):
	install -m0755 -d $(IDIR_GZIP)/bin
	install -m0755  $(PKG_INSTALL_DIR)/bin/gzip $(IDIR_GZIP)/bin/gzip.real
	ln -sf gzip.real $(IDIR_GZIP)/bin/gzip
	ln -sf gzip.real $(IDIR_GZIP)/bin/gunzip
	ln -sf gzip.real $(IDIR_GZIP)/bin/zcat
	$(RSTRIP) $(IDIR_GZIP)
	$(IPKG_BUILD) $(IDIR_GZIP) $(PACKAGE_DIR)
