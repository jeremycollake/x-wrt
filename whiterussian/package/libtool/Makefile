# $Id: Makefile 4782 2006-09-12 12:32:27Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=libtool
PKG_VERSION:=1.5.22
PKG_RELEASE:=1
PKG_MD5SUM:=8e0ac9797b62ba4dcc8a2fb7936412b0

PKG_SOURCE_URL:=http://ftp.gnu.org/gnu/libtool/ \
	ftp://ftp.belnet.be/mirror/ftp.gnu.org/gnu/libtool/ \
	ftp://ftp.mirror.nl/pub/mirror/gnu/libtool/ \
	http://mirror.switch.ch/ftp/mirror/gnu/libtool/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,LIBLTDL,libltdl,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		libltdl_cv_sys_dlopen_deplibs=yes \
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
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_LIBLTDL):
	install -m0755 -d $(IDIR_LIBLTDL)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libltdl.so.* $(IDIR_LIBLTDL)/usr/lib/
	$(RSTRIP) $(IDIR_LIBLTDL)
	$(IPKG_BUILD) $(IDIR_LIBLTDL) $(PACKAGE_DIR)

$(STAGING_DIR)/usr/lib/libltdl.so: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/libtool* $(STAGING_DIR)/usr/bin/
	mkdir -p $(STAGING_DIR)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ltdl.h $(STAGING_DIR)/usr/include/
	mkdir -p $(I_LIBLTDL_DEV)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libltdl.{a,so*} $(STAGING_DIR)/usr/lib/
	mkdir -p $(I_LIBLTDL_DEV)/usr/share/aclocal
	$(CP) $(PKG_INSTALL_DIR)/usr/share/aclocal $(STAGING_DIR)/usr/share/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/libtool $(STAGING_DIR)/usr/share/
	# Fix development file
	$(SED) 's,$(STAGING_DIR)/bin,$${STAGING_DIR}/bin,g; s,$(STAGING_DIR)/lib,$${STAGING_DIR}/lib,g; s,^\(sys_lib_dlsearch_path_spec=\).*,\1"$${STAGING_DIR}/lib $${STAGING_DIR}usr/lib",g;' \
		$(STAGING_DIR)/usr/bin/libtool
	$(SED) 's,^\(prefix=\)\(.*\),\1"$${STAGING_DIR}\2",g;' \
		$(STAGING_DIR)/usr/bin/libtoolize

install-dev: $(STAGING_DIR)/usr/lib/libltdl.so

uninstall-dev:
	rm -rf \
		$(STAGING_DIR)/usr/bin/libtool* \
		$(STAGING_DIR)/usr/include/ltdl.h \
		$(STAGING_DIR)/usr/lib/libltdl.{a,so*} \
		$(STAGING_DIR)/usr/share/aclocal/libtool.* \
		$(STAGING_DIR)/usr/share/aclocal/ltdl.* \
		$(STAGING_DIR)/usr/share/libtool

compile: install-dev
clean: uninstall-dev
