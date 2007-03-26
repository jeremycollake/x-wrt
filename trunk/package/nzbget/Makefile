#############################################################
#
# nzbget 
#
#############################################################
NZBGET_SOURCE:=nzbget-0.2.0.tar.gz
NZBGET_SITE:=http://ovh.dl.sourceforge.net/sourceforge/nzbget/
NZBGET_DIR:=$(BUILD_DIR)/nzbget-0.2.0
NZBGET_CAT:=zcat
NZBGET_BINARY:=nzbget
NZBGET_TARGET_BINARY:=usr/bin/nzbget
NZBGET_IPK:=$(BUILD_DIR)/nzbget_0.2.0_mipsel.ipk
NZBGET_IPK_DIR:=$(BUILD_DIR)/nzbget-0.2.0-ipk

$(DL_DIR)/$(NZBGET_SOURCE):
	 $(WGET) -P $(DL_DIR) $(NZBGET_SITE)/$(NZBGET_SOURCE)

nzbget-source: $(DL_DIR)/$(NZBGET_SOURCE)

$(NZBGET_DIR)/.unpacked: $(DL_DIR)/$(NZBGET_SOURCE)
	$(NZBGET_CAT) $(DL_DIR)/$(NZBGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	touch $(NZBGET_DIR)/.unpacked

$(NZBGET_DIR)/.configured: $(NZBGET_DIR)/.unpacked
	(cd $(NZBGET_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--with-gnu-ld \
		--with-libxml2-includes=$(STAGING_DIR)/include/libxml2 \
	);
	touch  $(NZBGET_DIR)/.configured

$(NZBGET_DIR)/$(NZBGET_BINARY): $(NZBGET_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(NZBGET_DIR)
	$(STRIP) $(NZBGET_DIR)/nzbget

$(TARGET_DIR)/$(NZBGET_TARGET_BINARY): $(NZBGET_DIR)/$(NZBGET_BINARY)
	cp $(NZBGET_DIR)/nzbget $(TARGET_DIR)/usr/sbin

$(NZBGET_IPK): $(NZBGET_DIR)/$(NZBGET_TARGET)
	mkdir -p $(NZBGET_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/openwrt/ipkg/nzbget/CONTROL/* $(NZBGET_IPK_DIR)/CONTROL
	mkdir -p $(NZBGET_IPK_DIR)/usr/sbin
	mkdir -p $(NZBGET_IPK_DIR)/etc
	mkdir -p $(NZBGET_IPK_DIR)/tmp/.nzbget/
	cp $(NZBGET_DIR)/nzbget $(NZBGET_IPK_DIR)/usr/sbin
	cp $(NZBGET_DIR)/nzbget.cfg.example $(NZBGET_IPK_DIR)/etc/nzbget.cfg
	chmod -R 755 $(NZBGET_IPK_DIR)/*
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NZBGET_IPK_DIR)
	
nzbget: uclibc $(TARGET_DIR)/$(NZBGET_TARGET_BINARY)
nzbget-ipk: $(NZBGET_IPK)
nzbget-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(NZBGET_DIR) uninstall
	-$(MAKE) -C $(NZBGET_DIR) clean

nzbget-dirclean:
	rm -rf $(NZBGET_DIR)