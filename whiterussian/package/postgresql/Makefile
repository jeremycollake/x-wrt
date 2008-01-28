# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=postgresql
PKG_VERSION:=7.4.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=\
	ftp://ftp.us.postgresql.org/pub/mirrors/postgresql/source/v$(PKG_VERSION) \
	ftp://ftp-archives.postgresql.org/pub/source/v$(PKG_VERSION)
PKG_MD5SUM:=2e0e82552f8463343df5d89348356481
PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBPQ,libpq,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(eval $(call PKG_template,PGSQL_CLI,pgsql-cli,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured:
#	./configure advertise "--infodir", but does not support it, replaced with "--docdir"
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib" \
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
		--docdir=/usr/share/info \
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
		--disable-integer-datetimes \
		--disable-rpath \
		--without-java \
		--without-krb4 \
		--without-krb5 \
		--without-openssl \
		--without-pam \
		--without-perl \
		--without-python \
		--without-readline \
		--without-rendezvous \
		--without-tcl \
		--without-tk \
		--with-zlib="yes" \
	);
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C "$(PKG_BUILD_DIR)/src/include" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	$(MAKE) -C "$(PKG_BUILD_DIR)/src/interfaces/libpq" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	$(MAKE) -C "$(PKG_BUILD_DIR)/src/bin/pg_config" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		includedir="$(STAGING_DIR)/usr/include" \
		libdir="$(STAGING_DIR)/usr/lib" \
		all install
	$(MAKE) -C "$(PKG_BUILD_DIR)/src/bin/psql" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBPQ):
	install -d -m0755 $(IDIR_LIBPQ)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpq.so.* $(IDIR_LIBPQ)/usr/lib/
	$(RSTRIP) $(IDIR_LIBPQ)
	$(IPKG_BUILD) $(IDIR_LIBPQ) $(PACKAGE_DIR)

$(IPKG_PGSQL_CLI):
	install -d -m0755 $(IDIR_PGSQL_CLI)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/psql $(IDIR_PGSQL_CLI)/usr/bin/
	$(RSTRIP) $(IDIR_PGSQL_CLI)
	$(IPKG_BUILD) $(IDIR_PGSQL_CLI) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libpq.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/pg_config $(STAGING_DIR)/usr/bin/
	$(SED) 's,='\''/usr\(.*\)'\''\(.*\),="$${STAGING_DIR}/usr\1"\2,g' $(STAGING_DIR)/usr/bin/pg_config
	$(SED) 's,='\''$(STAGING_DIR)\(.*\)'\''\(.*\),="$${STAGING_DIR}\1"\2,g' $(STAGING_DIR)/usr/bin/pg_config
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpq $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpq-fe.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pg_config.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/postgres_ext.h $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/postgresql $(STAGING_DIR)/usr/include/
	mkdir -p $(STAGING_DIR)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpq.{a,so*} $(STAGING_DIR)/usr/lib/
	touch $@

install-dev: $(STAGING_DIR)/usr/lib/libpq.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/bin/pg_config \
		$(STAGING_DIR)/usr/include/libpq \
		$(STAGING_DIR)/usr/include/libpq-fe.h \
		$(STAGING_DIR)/usr/include/pg_config.h \
		$(STAGING_DIR)/usr/include/postgres_ext.h \
		$(STAGING_DIR)/usr/include/postgresql \
		$(STAGING_DIR)/usr/lib/libpq.{a,so*}

compile: install-dev
clean: uninstall-dev
