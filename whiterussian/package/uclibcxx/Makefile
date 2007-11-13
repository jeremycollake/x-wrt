# $Id: Makefile 4782 2006-09-12 12:32:27Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=uclibc++
PKG_VERSION:=0.2.1
PKG_RELEASE:=1

PKG_SOURCE:=uClibc++-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://cxx.uclibc.org/src/
PKG_MD5SUM:=6e6032c49916b199ffe6a585552fd46b

PKG_BUILD_DIR:=$(BUILD_DIR)/uClibc++-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_CAT:=bzcat

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,UCLIBCXX,uclibcxx,$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))

UCLIBC_TARGET_ARCH:=$(shell echo $(ARCH) | sed -e s'/-.*//' \
	-e 's/i.86/i386/' \
	-e 's/sparc.*/sparc/' \
	-e 's/m68k.*/m68k/' \
	-e 's/ppc/powerpc/g' \
	-e 's/v850.*/v850/g' \
	-e 's/sh64/sh/' \
	-e 's/sh[234].*/sh/' \
	-e 's/mips.*/mips/' \
	-e 's/mipsel.*/mips/' \
	-e 's/cris.*/cris/' \
)

$(PKG_BUILD_DIR)/.configured:
	cp ./files/config.default $(PKG_BUILD_DIR)/.config;
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		TOPDIR="$(PKG_BUILD_DIR)/" \
		$(TARGET_CONFIGURE_OPTS) \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		CP="$(CP)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_UCLIBCXX):
	install -d -m0755 $(IDIR_UCLIBCXX)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libuClibc++.so.* $(IDIR_UCLIBCXX)/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/libuClibc++-*.so $(IDIR_UCLIBCXX)/lib/
	$(STRIP) $(IDIR_UCLIBCXX)/lib/*.so*
	$(IPKG_BUILD) $(IDIR_UCLIBCXX) $(PACKAGE_DIR)

install-dev: $(PKG_BUILD_DIR)/.built
	mkdir -p $(STAGING_DIR)/usr/include
	$(MAKE) -C $(PKG_BUILD_DIR) \
		TOPDIR="$(PKG_BUILD_DIR)/" \
		$(TARGET_CONFIGURE_OPTS) \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		CP="$(CP)" \
		DESTDIR="$(STAGING_DIR)" \
		install

file_includes := algorithm basic_definitions bitset cassert cctype cerrno cfloat climits \
	clocale cmath complex csetjmp csignal cstdarg cstddef cstdio cstdlib cstring ctime \
	cwctype cwchar deque exception fstream func_exception functional char_traits iomanip \
	ios iosfwd iostream istream istream_helpers iterator iterator_base limits list \
	locale map memory new numeric ostream ostream_helpers queue set sstream stack \
	stdexcept streambuf string string_iostream support system_configuration.h \
	typeinfo type_traits unwind-cxx.h utility valarray vector

uninstall-dev:
	rm -rf	$(STAGING_DIR)/usr/bin/g++-uc \
		$(STAGING_DIR)/usr/lib/libuClibc++*.{a,so*}
	for incl in $(file_includes); do \
		rm -f $$incl; \
	done

compile: install-dev
clean: uninstall-dev
