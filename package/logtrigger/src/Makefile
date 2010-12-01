ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif
LIBS=-lnl

all: logtrigger

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

logtrigger: cli.o util.o pairs.o uci.o trigger.o logread.o scan.o 
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)
