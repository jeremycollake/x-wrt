ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif

ifndef OPENWRT
LOGTRIGGEROBJS = cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o config.o 
else
LIBS=-lnl
LOGTRIGGEROBJS = cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o tail.o uci.o
endif

all: logtrigger

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

mytail: tailmain.o tail.o confreg.o config.o pairs.o files.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

config: config.o files.o util.o pairs.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

logtrigger: $(LOGTRIGGEROBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm *.o logtrigger
	