#
include $(TOPDIR)/rules.mk

KDIR:=$(BUILD_DIR)/linux-$(KERNEL)-$(BOARD)

lzma-loader-clean:
	$(MAKE) -C lzma-loader clean

lzma-loader-prepare:
	$(MAKE) -C lzma-loader prepare

lzma-loader-compile: lzma-loader-prepare
	$(MAKE) -C lzma-loader compile

ifeq ($(IB),)
$(KDIR)/vmlinux.lzma: $(KDIR)/vmlinux
	cat $^ | $(STAGING_DIR)/bin/lzma e -si -so -eos -lc1 -lp2 -pb2 > $@ || (rm -f $@ && false)

$(KDIR)/loader.tmp.gz: compile
$(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx: $(KDIR)/vmlinux.lzma
endif

ifeq ($(FS),jffs2-8MB)
TRXALIGN:=-a 0x20000
endif
ifeq ($(FS),jffs2-4MB)
TRXALIGN:=-a 0x10000
endif
# see ticket #155
ifeq ($(FS),squashfs)
TRXALIGN:=-a 1024
endif

$(KDIR)/loader.tmp.gz:
	cp $(BUILD_DIR)/loader.gz $@
	echo -ne "\\x00" >> $@

$(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)


ifeq ($(KERNEL),2.4)
FSNAME:=$(patsubst jffs2-%,jffs2,$(FS))

ifeq ($(FS),squashfs)
# $(BIN_DIR)/openwrt-wap54g-$(FSNAME).trx: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
# 	cp $< $@
# 	echo -ne '\x01' >> $@
# 	
# install: $(BIN_DIR)/openwrt-wap54g-$(FSNAME).trx

$(BIN_DIR)/openwrt-usr5461-$(FS).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/trx2usr $< $@

install: $(BIN_DIR)/openwrt-usr5461-$(FS).bin
endif

ifneq ($(FS),jffs2-8MB)
$(BIN_DIR)/openwrt-wrt54g3g-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/addpattern -4 -p W54F -v v2.01.1 -i $< -o $@ -g

$(BIN_DIR)/openwrt-wrt54g-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/addpattern -4 -p W54G -v v4.60.1 -i $< -o $@ -g

$(BIN_DIR)/openwrt-wrt54gs_v4-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/addpattern -4 -p W54s -v v1.09.1 -i $< -o $@ -g

$(BIN_DIR)/openwrt-wr850g-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/motorola-bin -1 $< $@

$(BIN_DIR)/openwrt-wa840g-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/motorola-bin -2 $< $@

$(BIN_DIR)/openwrt-we800g-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/motorola-bin -3 $< $@

$(BIN_DIR)/openwrt-wl300g-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL300g -v 1.9.3.7 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl320ge-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL320gE -v 1.9.8.0 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl320gp-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL320gP -v 1.9.8.0 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl500b-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL500b -v 1.8.2.4 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl500g-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL500g -v 1.9.5.0 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl500gx-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL500gx -v 1.9.6.0 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wlhdd-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WLHDD -v 1.2.3.9 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

install: \
	$(BIN_DIR)/openwrt-wa840g-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-we800g-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-wlhdd-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl300g-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl320ge-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl320gp-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl500b-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl500g-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl500gx-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wrt54g-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-wrt54gs_v4-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-wrt54g3g-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-wr850g-$(FSNAME).bin
endif

ifneq ($(FS),jffs2-4MB)
$(BIN_DIR)/openwrt-wrt54gs-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/addpattern -4 -p W54S -v v4.80.1 -i $< -o $@ -g

$(BIN_DIR)/openwrt-wrtsl54gs-$(FSNAME).bin: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	$(STAGING_DIR)/bin/addpattern -4 -p W54U -v v2.08.1 -i $< -o $@ -g

$(BIN_DIR)/openwrt-wl500gp-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL500gp -v 1.9.7.5 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

$(BIN_DIR)/openwrt-wl500w-$(FSNAME).trx: $(KDIR)/loader.tmp.gz
	$(STAGING_DIR)/bin/trx -p WL500W -v 1.9.8.9 -o $@ $(KDIR)/loader.tmp.gz $(KDIR)/vmlinux.lzma $(TRXALIGN) $(KDIR)/root.$(FS)

install: \
	$(BIN_DIR)/openwrt-wl500gp-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wl500w-$(FSNAME).trx \
	$(BIN_DIR)/openwrt-wrt54gs-$(FSNAME).bin \
	$(BIN_DIR)/openwrt-wrtsl54gs-$(FSNAME).bin
endif
endif

ifeq ($(IB),)
clean: lzma-loader-clean
prepare: lzma-loader-prepare
compile: lzma-loader-compile
else
clean:
prepare:
compile:
endif
install: $(BIN_DIR)/openwrt-$(BOARD)-$(KERNEL)-$(FS).trx
	(cd $(BIN_DIR); md5sum -b *.{bin,trx} > md5sums.txt)
install-ib:
	mkdir -p $(IB_DIR)/staging_dir_$(ARCH)/bin
	cp -fpR $(STAGING_DIR)/bin/trx $(STAGING_DIR)/bin/addpattern $(STAGING_DIR)/bin/trx2usr $(STAGING_DIR)/bin/motorola-bin $(IB_DIR)/staging_dir_$(ARCH)/bin
	mkdir -p $(IB_DIR)/build_$(ARCH)/linux-$(KERNEL)-$(BOARD)
	cp -fpR $(BUILD_DIR)/loader.gz $(IB_DIR)/build_$(ARCH)/
	cp -fpR $(KDIR)/vmlinux.lzma $(IB_DIR)/build_$(ARCH)/linux-$(KERNEL)-$(BOARD)/
