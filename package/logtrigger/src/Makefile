ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif
#LIBS=-lnl

all: logtrigger

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

mytail: tail.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

config: config.o files.o util.o pairs.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

logtrigger: cli.o util.o pairs.o config.o trigger.o logread.o scan.o files.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm *.o logtrigger
	