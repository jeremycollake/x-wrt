#
# Copyright (C) 2006 X-Wrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=ntp
PKG_VERSION:=4.2.4p4
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4
PKG_MD5SUM:=fcb32a01e1ae3f9ed5bac86b12c7a1cc
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,NTPD,$(PKG_NAME)d,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,NTPD_TOOLS,$(PKG_NAME)d-tools,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/libelf -I$(STAGING_DIR)/include" \
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
		  --sysconfdir=/etc/ntp \
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --disable-all-clocks \
		  --disable-parse-clocks \
		  --enable-NMEA \
		  --enable-LOCAL-CLOCK \
		  --enable-SHM \
		  --enable-linuxcaps \
		  --enable-shared \
		  --disable-static \
		  --enable-ipv6 \
		  --without-rpath \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		bindir=/usr/sbin \
		install
	touch $@

$(IPKG_NTPD):
	install -d -m0755 $(IDIR_NTPD)/etc/default
	install -m0644 ./files/step-servers $(IDIR_NTPD)/etc/default
	install -m0644 ./files/ntp.conf $(IDIR_NTPD)/etc/
	install -d -m0755 $(IDIR_NTPD)/etc/init.d
	install -m0755 ./files/ntpd.init $(IDIR_NTPD)/etc/init.d/ntpd
	install -d -m0755 $(IDIR_NTPD)/etc/hotplug.d/iface
	install -m0755 ./files/ntpd.hotplug $(IDIR_NTPD)/etc/hotplug.d/iface/20-ntpd
	install -d -m0755 $(IDIR_NTPD)/usr/sbin/
	for tool in ntpd ntpdate ntpdc ntpq; do \
		install -m0755 $(PKG_INSTALL_DIR)/usr/sbin/$$tool $(IDIR_NTPD)/usr/sbin/; \
	done
	$(RSTRIP) $(IDIR_NTPD)
	$(IPKG_BUILD) $(IDIR_NTPD) $(PACKAGE_DIR)

$(IPKG_NTPD_TOOLS):
	install -d -m0755 $(IDIR_NTPD_TOOLS)/usr/sbin/
	for tool in ntptime tickadj; do \
		install -m0755 $(PKG_INSTALL_DIR)/usr/sbin/$$tool $(IDIR_NTPD_TOOLS)/usr/sbin/; \
	done
	$(RSTRIP) $(IDIR_NTPD_TOOLS)
	$(IPKG_BUILD) $(IDIR_NTPD_TOOLS) $(PACKAGE_DIR)
