ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif

ifdef OPENWRT
LOGTRIGGEROBJS = cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o tail.o uci.o
LIBS=-lnl
endif

ifndef OPENWRT
LOGTRIGGEROBJS = cli.o util.o pairs.o config.o trigger.o logread.o scan.o files.o confreg.o tail.o
endif

all: logtrigger

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

mytail: tailmain.o tail.o confreg.o config.o pairs.o files.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

config: config.o files.o util.o pairs.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

logtrigger: cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o tail.o uci.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm *.o logtrigger
	