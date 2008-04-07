include $(TOPDIR)/rules.mk
include ../../rules.mk

PKG_NAME:=mos7715
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-2.4-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/mos7715
PKG_MD5SUM:=d3d079ec6b3621e92cb4ed3a8f7e225d
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-2.4-$(PKG_VERSION)

ifeq ($(KERNEL_DIR),)
KERNEL_DIR:=$(LINUX_DIR)
endif

include $(TOPDIR)/package/rules.mk

$(eval $(call PKG_template,KMOD_USB_MOS7715,kmod-usb-mos7715,$(LINUX_VERSION)+$(PKG_VERSION)-$(BOARD)-$(PKG_RELEASE),$(ARCH),kernel ($(LINUX_VERSION)-$(BOARD)-$(KERNEL_RELEASE))))

$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); \
		mv -f Makefile Makefile.full; \
		mv -f Makefile.Openwrt Makefile; \
		$(SED) 's/\r$$//' Makefile* README *.c *.h \
	);
	touch $@

$(PKG_BUILD_DIR)/.built: $(PKG_BUILD_DIR)/.configured
	$(MAKE) -C "$(KERNEL_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		PATH="$(TARGET_PATH)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="" \
		modules
	touch $@

$(IPKG_KMOD_USB_MOS7715): $(PKG_BUILD_DIR)/.built
	install -m0755 -d $(IDIR_KMOD_USB_MOS7715)/etc/modules.d
	install -m0644 ./files/modules/* $(IDIR_KMOD_USB_MOS7715)/etc/modules.d/
	install -m0755 -d $(IDIR_KMOD_USB_MOS7715)/lib/modules/$(LINUX_VERSION)
	cp -fpR $(PKG_BUILD_DIR)/mos7715.o \
		$(IDIR_KMOD_USB_MOS7715)/lib/modules/$(LINUX_VERSION)/
	$(IPKG_BUILD) $(IDIR_KMOD_USB_MOS7715) $(PACKAGE_DIR)

