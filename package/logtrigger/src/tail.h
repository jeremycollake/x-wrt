#ifndef _LOGTRIGGER_TAIL_H
#define _LOGTRIGGER_TAIL_H
#ifndef OPENWRT
	#include "config.h"
#endif
#ifdef OPENWRT
	#include "uci.h"
#endif
char *readfile(FILE *fp);
char *readlines(const char *filename, long *last);
//long getsize(const char *filename);
int logsread(void);
#endif