/*
 * logread - this program was extracted from busybox logread and modified
 * to use in hostblock
 */

/*
 * circular buffer syslog implementation for busybox
 *
 * Copyright (C) 2000 by Gennady Feldman <gfeldman@gena01.com>
 *
 * Maintainer: Gennady Feldman <gfeldman@gena01.com> as of Mar 12, 2001
 *
 * Licensed under GPLv2 or later, see file LICENSE in this source tree.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#include <malloc.h>
#include <sys/types.h>

#include "logread.h"

extern int DEBUG;

/*
 * sem_up - up()'s a semaphore.
 */
static void sem_up(int semid)
{
	if (semop(semid, SMrup, 1) == -1){
		perror("semop[SMrup]");
		exit(1);
	}
}

size_t
strnlen (const char *string, size_t maxlen)
{
  const char *end = memchr (string, '\0', maxlen);
  return end ? (size_t) (end - string) : maxlen;
}

static void interrupted(int sig)
{
	signal(SIGINT, SIG_IGN);
	shmdt(shbuf);
	exit(0);
}

static void error_exit(const char *str)
{
	//release all acquired resources
	shmdt(shbuf);
	perror(str);
	exit(-1);
}

void fflush_all(void)
{
	fflush(stdin);
	fflush(stdout);
	fflush(stderr);
}

char *logread(int follow) {
	char *retval = NULL;
	unsigned cur;
	int log_semid; /* ipc semaphore id */
	int log_shmid; /* ipc shared memory id */
    /* We need to get the segment named KEY, created by the server. */
    key_t key = KEY;
	
	INIT_G();

    /* Locate the segment. */
    if((log_shmid = shmget(key, 0, 0)) < 0) {
        perror("shmget");
        return NULL;
    }

    /* Now we attach the segment to our data space. */
    shbuf = shmat(log_shmid, NULL, SHM_RDONLY);
	if (shbuf == NULL){
		perror("shmat");
        return NULL;
	}

	log_semid = semget(key, 0, 0);
	if (log_semid == -1){
		perror("shmat");
        return NULL;
	}
	signal(SIGINT, interrupted);
    /* Now read what the server put in the memory. */
	cur = shbuf->tail;

	/* Loop for logread -f, one pass if there was no -f */
	do {
		unsigned shbuf_size;
		unsigned shbuf_tail;
		const char *shbuf_data;

		int i;
		int len_first_part;
		int len_total = len_total; /* for gcc */
		char *copy = copy; /* for gcc */

		if (semop(log_semid, SMrdn, 2) == -1)
			error_exit("semop[SMrdn]");
		/* Copy the info, helps gcc to realize that it doesn't change */
		shbuf_size = shbuf->size;
		shbuf_tail = shbuf->tail;
		shbuf_data = shbuf->data; /* pointer! */

/*
		if (DEBUG)
			printf("cur:%d tail:%i size:%i\n",
					cur, shbuf_tail, shbuf_size);
*/
		if (!follow) {
			/* advance to oldest complete message */
			/* find NUL */
			cur += strlen(shbuf_data + cur);
			if (cur >= shbuf_size) { /* last byte in buffer? */
				cur = strnlen(shbuf_data, shbuf_tail);
				if (cur == shbuf_tail)
					goto unlock; /* no complete messages */
			}
			/* advance to first byte of the message */
			cur++;
			if (cur >= shbuf_size) /* last byte in buffer? */
				cur = 0;
		} else { /* logread -f */
			if (cur == shbuf_tail) {
				sem_up(log_semid);
				fflush_all();
				sleep(1); /* TODO: replace me with a sleep_on */
				continue;
			}
		}

		/* Read from cur to tail */
		len_first_part = len_total = shbuf_tail - cur;
		if (len_total < 0) {
			/* message wraps: */
			/* [SECOND PART.........FIRST PART] */
			/*  ^data      ^tail    ^cur      ^size */
			len_total += shbuf_size;
		}
		copy = malloc(len_total + 1);
		if (len_first_part < 0) {
			/* message wraps (see above) */
			len_first_part = shbuf_size - cur;
			memcpy(copy + len_first_part, shbuf_data, shbuf_tail);
		}
		memcpy(copy, shbuf_data + cur, len_first_part);
		copy[len_total] = '\0';
		cur = shbuf_tail;
 unlock:
		/* release the lock on the log chain */
		sem_up(log_semid);
		retval = realloc(retval, len_total + 1);
		memset(retval, 0, len_total+1);
		for (i = 0; i < len_total; i += strlen(copy + i) + 1) {
			strcat(retval, (char *) copy + i);
			follow = 0;
		}
		free(copy);
	} while (follow);
	shmdt(shbuf);
    return retval;
}
