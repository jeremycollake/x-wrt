ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif

ifndef OPENWRT
LOGTRIGGEROBJS = cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o config.o 
else
LIBS=-lnl
LOGTRIGGEROBJS = cli.o util.o pairs.o trigger.o logread.o scan.o files.o confreg.o uci.o
endif

all: logtrigger

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

logtrigger: $(LOGTRIGGEROBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm *.o logtrigger
	