#ifndef _LOGTRIGGER_LOGREAD_H
#define _LOGTRIGGER_LOGREAD_H

#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>

enum { KEY = 0x414e4547 }; /* "GENA" */

#ifndef BUFSIZ
# define BUFSIZ 4096
#endif

//#define DEBUG 1
enum { COMMON_BUFSIZE = (BUFSIZ >= 256*sizeof(void*) ? BUFSIZ+1 : 256*sizeof(void*)) };
char bb_common_bufsiz1[COMMON_BUFSIZE];

struct shbuf_ds {
	int32_t size;           // size of data - 1
	int32_t tail;           // end of message list
	char data[1];           // messages
};

static const struct sembuf init_sem[3] = {
	{0, -1, IPC_NOWAIT | SEM_UNDO},
	{1, 0}, {0, +1, SEM_UNDO}
};

struct globals {
	struct sembuf SMrup[1]; // {0, -1, IPC_NOWAIT | SEM_UNDO},
	struct sembuf SMrdn[2]; // {1, 0}, {0, +1, SEM_UNDO}
	struct shbuf_ds *shbuf;
};

#define G (*(struct globals*)&bb_common_bufsiz1)
#define SMrup (G.SMrup)
#define SMrdn (G.SMrdn)
#define shbuf (G.shbuf)
#define INIT_G() do { \
	memcpy(SMrup, init_sem, sizeof(init_sem)); \
} while (0)


char *logread(int follow);
unsigned get_tail();
char *logreadlast(unsigned cur, long* last);

#endif
