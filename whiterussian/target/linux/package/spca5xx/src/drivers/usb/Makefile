VERSION    = 00.60.00.1
CVSVERSION = "$Experimental work Michel Xhaard && Reza Jelveh 03/02/2004"
DEFINES    =

###
# The following flags enable experimental features.
# By default, these are enabled for development versions of the driver, and
# disabled for release versions.

# Optional: Enable driver debugging
#DEFINES   += -DSPCA50X_ENABLE_DEBUG

# Optional: Enable direct register read/write for PAC207 development
#DEFINES   += -DSPCA5XX_ENABLE_REGISTERPLAY

###
# The following flags enable features that aren't yet implemented, and
# therefore are disabled by default.

# Optional: Enable compression
DEFINES   += -DSPCA50X_ENABLE_COMPRESSION

###
# Rest of Makefile follows here. You probably won't need to touch this.

# Setup defines
DEFINES   += -DCONFIG_USB_SPCA5XX_MODULE=1
DEFINES   += -DVID_HARDWARE_SPCA5XX=0xFF -DSPCA5XX_VERSION=\"$(VERSION)\"

EXTRA_CFLAGS += $(DEFINES) 

spca5xx-objs := spcadecoder.o spca5xx.o
obj-m := ../spca5xx.o

include $(TOPDIR)/Rules.make

../spca5xx.o: $(spca5xx-objs)
	$(LD) -r -o $@ $(spca5xx-objs)
