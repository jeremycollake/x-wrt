# $Id: Makefile 3920 2006-06-09 01:30:19Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=openntpd
PKG_VERSION:=3.9p1
PKG_RELEASE:=2


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenNTPD/ \
	ftp://ftp.de.openbsd.org/pub/unix/OpenBSD/OpenNTPD/ \
	ftp://ftp.fr.openbsd.org/pub/OpenBSD/OpenNTPD/ \
	ftp://ftp.sunet.se/pub/OpenBSD/OpenNTPD/
PKG_MD5SUM:=afc34175f38d08867c1403d9008600b3
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,OPENNTPD,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

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
		  $(DISABLE_LARGEFILE) \
		  $(DISABLE_NLS) \
		  --with-builtin-arc4random \
		  --with-privsep-user=ntp \
		  --with-adjtimex \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DUSE_ADJTIMEX" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		STRIP_OPT="" \
		all install
	touch $@

$(IPKG_OPENNTPD):
	install -d -m0755 $(IDIR_OPENNTPD)/etc
	install -m0644 ./files/ntpd.conf $(IDIR_OPENNTPD)/etc/
	install -d -m0755 $(IDIR_OPENNTPD)/etc/init.d
	install -m0755 ./files/ntpd.init $(IDIR_OPENNTPD)/etc/init.d/ntpd
	install -d -m0755 $(IDIR_OPENNTPD)/etc/hotplug.d/iface
	install -m0755 ./files/ntpd.hotplug $(IDIR_OPENNTPD)/etc/hotplug.d/iface/20-ntpd
	install -d -m0755 $(IDIR_OPENNTPD)/usr/sbin/
	install -m0755 $(PKG_INSTALL_DIR)/usr/sbin/ntpd $(IDIR_OPENNTPD)/usr/sbin/
	$(RSTRIP) $(IDIR_OPENNTPD)
	$(IPKG_BUILD) $(IDIR_OPENNTPD) $(PACKAGE_DIR)
